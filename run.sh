#!/usr/bin/bash

### ========================================================================== ###
###                         - HELPER FUNCTIONS -                               ###
### ========================================================================== ###

## VARIABLES------------------------------------------------------##

RED='\033[1;31m'
BLUE='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
LIGHTPURP='\033[1;35m'
NOCOLOR='\033[0m'
WHITEN='\033[0;37m'

PROJECT="UltimateShooter"


## FUNCTIONS------------------------------------------------------##

#-- Generate files for unreal project code
function generate_project_files()
{
  "${UNREAL_PATH}/Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh" "${PWD}/${PROJECT}.uproject"
}

#-- Compile unreal project code
function compile_code()
{
  make "${PROJECT}Editor"
  
  RESULT=$?

  if [[ ${RESULT} -gt 0 ]]; then
      echo -e "|------------ ${RED}FAILED TO COMPILE APPLICATION SOURCE CODE${NOCOLOR} ------------|"
      return 1
  else
      echo -e "|------------ ${GREEN}SUCCESSFUL COMPILE OF APPLICATION SOURCE CODE${NOCOLOR} ------------|"
      return 0
  fi
}

#-- Run unreal project code in Editor
function run_editor()
{
  "${UNREAL_PATH}/Engine/Binaries/Linux/UnrealEditor" "${PWD}/${PROJECT}.uproject"
}

#-- Handle Unreal unit and component tests
function run_tests()
{
  # make sure code works
  compile_code
  RESULT=$?
  if [[ RESULT -eq 1 ]]; then
    exit 1
  fi

  # Delete old test Result
  if [[ -s "${PWD}/Saved/Testing/index.json" ]]; then
    rm ${PWD}/Saved/Testing/index.json
  fi

  # Set test flags for test to render on or off screen
  RENDER_FLAGS="-RenderOffScreen"
  if [[ $3 == "EDITOR" ]]; then 
    RENDER_FLAGS=""
  fi
  if [[ $3 == "NOGPU" ]]; then 
    RENDER_FLAGS="-NullRHI"
  fi

  # flag to set whether running unit or functional tests
  TEST_TYPE=""
  TEST_NAME="$2"
  TEST_STRING=""
  if [[ $1 == "--unit-test" || "$1" == "-u" ]]; then 
    FAILED_TEST_TYPE="fullTestPath"
    TEST_TYPE="UEUnitTests."
    TEST_STRING="UEUnitTests"
    RENDER_FLAGS="-NullRHI"
  fi
  if [[ $1 == "--func-test" || "$1" == "-f" ]]; then 
    FAILED_TEST_TYPE="testDisplayName"
    TEST_TYPE="Project.Functional Tests.Maps.TestLevel."
    TEST_STRING="UEFuncTests"
    if [[ $2 == "EDITOR" ]]; then
      TEST_NAME=""
      RENDER_FLAGS=""
    fi
  fi

  # Execute automation unit test
  "${UNREAL_PATH}/Engine/Binaries/Linux/UnrealEditor" "${PWD}/${PROJECT}.uproject" \
    "/Game/Main" -NoSound -ExecCmds="Automation RunTests ${TEST_TYPE}${TEST_NAME}" -Unattended \
    "${RENDER_FLAGS}" -NoSplash -TestExit="Automation Test Queue Empty" \
    -ReportExportPath="${PWD}/Saved/Testing/" -log="unreal_unit_text.txt"

  # Parse output and log
  if [[ -s "${PWD}/Saved/Testing/index.json" ]]; then
    echo -e "|---------------------------------------------------------------------------------------|"
    echo -e "  *** Unit Test Results for ${LIGHTPURP}${TEST_STRING}.${TEST_NAME} ${NOCOLOR} ***"
    echo -e "|---------------------------------------------------------------------------------------|"
    tput setaf 2
    grep '"succeeded"' ${PWD}/Saved/Testing/index.json | sed -r 's/^[^:]*:(.*),$/| --- Tests Succeeded:               \1/'
    tput setaf 3
    grep '"succeededWithWarnings"' ${PWD}/Saved/Testing/index.json | sed -r 's/^[^:]*:(.*),$/| --- Tests Succeeded with Warnings: \1/'
    tput setaf 1
    grep '"\failed\"' ${PWD}/Saved/Testing/index.json | sed -r 's/^[^:]*:(.*),$/| --- Tests Failed:                  \1/'
    tput sgr0

    FAILED=$(grep '"\failed\"' ${PWD}/Saved/Testing/index.json | sed -r 's/^[^:]*:(.*),$/\1/')

    grep '"\notRun\"' ${PWD}/Saved/Testing/index.json | sed -r 's/^[^:]*:(.*),$/| --- Tests Not Run:                 \1/'
    tput setaf 4
    grep '"\totalDuration\"' ${PWD}/Saved/Testing/index.json | sed -r 's/^[^:]*:(.*),$/| Execution Time: \1 seconds/'
    tput sgr0

    echo -e "|---------------------------------------------------------------------------------------|"

    # Print failures of tests
    if [[ "${FAILED}" -gt "0" ]]; then
      FAILED=$(grep -B 2 -rn '"state": "Fail"' "${PWD}/Saved/Testing/index.json" | grep -E "${FAILED_TEST_TYPE}" | grep -o -P "(?<=${FAILED_TEST_TYPE}\": \").*(?=\",)")
      echo -e "${RED}- FAILED TESTS: \n${NOCOLOR}${FAILED}"
    fi

    # Finish the output previous before the failure code above
    echo -e "|---------------------------------------------------------------------------------------|"
  else
    echo -e "|---------------------- ${RED}Unable to Run tests. ${NOCOLOR} ---------------------|"
    exit 1
  fi
}

#-- Package project
function package_game()
{
  # Get the package type from args
  PACKAGE_TYPE="$2"
  if [[ "${PACKAGE_TYPE}" != "Development" && "${PACKAGE_TYPE}" != "Shipping"  && "${PACKAGE_TYPE}" != "DebugGame" ]]; then
    echo -e "${WHITE} -Package Type Invalid. Please provide valid Package type ${YELLOW}(Development, Shipping, or DebugGame). ${NOCOLOR}" 
    exit 1
  fi

  echo -e "|----------------------- ${YELLOW}Cooking project........ ${NOCOLOR} -----------------------|" 

  # Package project command
  "${UNREAL_PATH}/Engine/Build/BatchFiles/RunUAT.sh" -ScriptsForProject="${PWD}/${PROJECT}.uproject" Turnkey \
    -command=VerifySdk -platform=Linux -UpdateIfNeeded -EditorIO -EditorIOPort=39887 \
    -project="${PWD}/${PROJECT}.uproject" BuildCookRun -nop4 -utf8output -nocompileeditor \
    -skipbuildeditor -cook -project="${PWD}/${PROJECT}.uproject" -target="${PROJECT}"  \
    -unrealexe="${UNREAL_PATH}/Engine/Binaries/Linux/UnrealEditor" -platform="Linux" -installed \
    -stage -archive -package -build -pak -iostore -compressed -prereqs \
    -archivedirectory="${PWD}/" -clientconfig="${PACKAGE_TYPE}" -nocompile -nocompileuat 
  
  # Did cook pass or fail
  RESULT=$?
  if [[ RESULT -eq 1 ]]; then
    echo -e "|------------------------ ${RED}Unable to Package Game. ${NOCOLOR} -----------------------|"
    exit 1
  fi

  echo -e "${GREEN}Done Cooking........  ${NOCOLOR} " 

  # Copy Configs
  echo -e "${YELLOW}Copying Config files........ ${NOCOLOR}"
  STAGED_GAME_CONFIG="${PWD}/Saved/StagedBuilds/Linux/${PROJECT}/Config"
  mkdir -p "${STAGED_GAME_CONFIG}"
  # cp "${PWD}"/Config/*.json "${STAGED_GAME_CONFIG}"
  cp "${PWD}"/Config/*.ini "${STAGED_GAME_CONFIG}"

  echo -e "|-------------------------- ${GREEN}Done Copying Files ${NOCOLOR} --------------------------|" 
  echo -e "|--------------------------- ${GREEN}Package Complete ${NOCOLOR} ---------------------------|" 
}

#-- run packaged game
function run_game()
{
  GAME="${PWD}/Saved/StagedBuilds/Linux/${PROJECT}.sh"
  if [[ -f "${GAME}" ]]; then
    if [[ $2 == "NOGPU" ]]; then 
      "${GAME}" -nullRhi
    else
       "${GAME}"
    fi
  else
    echo -e "${RED}ERROR: ${NOCOLOR}${PROJECT}.sh does not exist"
  fi
}

#-- clean up unreal folders.
function clean()
{
  # remove folders that get rebuilt
  rm -rf $PWD/.vscode $PWD/Binaries $PWD/Build $PWD/DerivedDataCache $PWD/Intermediate $PWD/Linux $PWD/Saved

  # remove all core files
  if [[ $2 == "all" ]]; then
    find $UNREAL_PATH/Engine/Binaries/Linux/ -name 'core.Unreal*' -exec rm {} \;
  fi 
}

#-- clean up unneeded resources.
function run_clean_resources()
{
    # Clean all core files out of $UNREAL_ENGINE binaries.
    if [[ $2 == "bin" ]]; then
        find "$UNREAL_PATH"/Engine/Binaries/Linux/ -name 'core.Unreal*' -exec rm {} \;
        echo "All *.core files in binaries removed!"
    # Kill and remove all running docker containers on machine.
    elif [[ $2 == "containers" ]]; then
        docker rm -f $(docker ps -aq)
        echo "All docker containers removed!"
    # Remove all unused docker images on machine.
    elif [[ $2 == "images" ]]; then
        docker image prune --all --force
        echo "All docker images removed!"
    # Incorrect input.
    else
        echo "Invalid Args For!: $1"
        echo "Valid Args include: ./run.sh -xr bin  --OR--   ./run.sh -xr containers  --OR--   ./run.sh -xr images"
    fi
}

### ========================================================================== ###
###                         - /HELPER FUNCTIONS -                              ###
### ========================================================================== ###


### ========================================================================== ###
###                                                                            ###
###                     - RUN SCRIPT TO MAKE LIFE EASIER -                     ###
###                                                                            ###
### ========================================================================== ###

# Check if any arguments were provided
if [ $# -eq 0 ]; then
  echo -e "|----- ${YELLOW}No arguments provided. Please provide at least one argument.${NOCOLOR} -----|"
  exit 1
fi

# Perform action on project based on user args
case "$1" in
    # Generate unreal project files.
    # Example: ./run.sh -g
    -g|--generate)
        generate_project_files
    ;;
    # Command to compile project code.
    # Example: ./run.sh -c
    -c|--compile)
        compile_code
    ;;
    # Command to launch editor with project.
    # Example: ./run.sh -e
    -e|--editor)
        run_editor
    ;;
    # Command to compile code and to launch editor with project.
    # Example: ./run.sh -m
    -m|--make)
        compile_code
        run_editor
    ;;
    # Command to kick off unit tests of your choosing. Run all tests with no testname provided
    # Example Run all:       ./run.sh -u
    # Example Single test:   ./run.sh -u Pawns.BasePawn.SpawnActor
    -u|--unit-test)
        run_tests "$@"
    ;;
    # Command to kick off funcitonal component tests of your choosing. Run all tests with no testname provided
    # Example Run all:     ./run.sh -f                          -- OR --  ./run.sh -f EDITOR
    # Example Single test: ./run.sh -f TT_functional_test_tank  -- OR --  ./run.sh -f TT_functional_test_tank EDITOR
    -f|--func-test)
        run_tests "$@"
    ;;
    # Command to package project code.
    # Example: ./run.sh -p Development
    -p|--package)
        package_game "$@"
    ;;
    # Command to launch project packaged game.
    # Example: ./run.sh -r
    -r|--run)
        run_game "$@"
    ;;
    # Command to package project code and launch project packaged game.
    # Example: ./run.sh -b
    -b|--build)
        package_game "$@"
        run_game
    ;;
    # Command to clean untracked folders in project.
    # Example: ./run.sh -x
    -x|--clean)
        clean "$@"
    ;;
    # Command to delete all .core crash files from ENGINE repo or remove all docker containers active.
    # Example: ./run.sh -xr bin      --OR--      ./run.sh -xr containers      --OR--      ./run.sh -xr images 
    -xr|--clean-res)
        run_clean_resources "$@"
    ;;
    *)
    echo -e "| ----- ${YELLOW}No valid arguments provided. Please provide valid argument: ${NOCOLOR}----- |"
    echo -e "${RED}Invalid Option!: $1${NOCOLOR}"
        echo -e  "Options include:"
        echo "  -g : generate files,       -c  : compile code,       -e : editor"
        echo "  -m : compile & run editor, -u  : run unit tests,     -f : run comp tests"
        echo "  -p : package game,         -r  : run game,           -b : package and run game"
        echo "  -x : clean up dirs         -xr : clean up resources"
        exit 1
    ;;
esac

### ========================================================================== ###
###                                                                            ###
###                     - /RUN SCRIPT TO MAKE LIFE EASIER -                    ###
###                                                                            ###
### ========================================================================== ###