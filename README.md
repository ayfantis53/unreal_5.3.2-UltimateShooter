# ULTIMATE SHOOTER 5.3.2 

- Tank game built in cpp (No Blueprints)

## (WINDOWS)
--------------------------------------------------------------------------------------------
### Game Initialization
#### Dependencies
- **IDE**
    * Need Visual Studio Installed (Purple one)
- **Build binaries**
    * Need Epics Game Launcher installed
    * Need to install `Unreal Engine 5.3.2`
        - `Library` -> Yellow plus icon `Install New version of Unreal Engine`

#### Unreal Editor
- **Enable Shader Model 6 (SM6)**
    * `Project Settings -> Platforms -> Linux -> Targeted RHIs`
- Animation Blueprints have to be found as classes and their paths have to have a **"_C"** at the end of the reference.

### Running Game
- **Compiling and Running Editor**
    * Navigate to project path and right click `UltimateShooter.uproject` [Unreal Engine Project].
    * Select `Generate Visual Studio Project Files`.
    * Double click the `UltimateShooter.sln`
    * In `Solution Explorer` under `Solution 'UltimateShooter'/Games/UltimateShooter` left click
    * Select `Set as startup project`
    * press play `Local Windows Debugger`

### Testing
#### Running Unit tests
- Run any amount of Unit test
    * Select `Tools` -> `Automation Tools` -> `UEUnitTests`
    * Select any amount of tests you wish to run.
### Running Functional tests
- Run any amount of Unit test
    * Select `Tools` -> `Automation Tools` -> `Projects` -> `FunctionalTests`
    * Select any amount of tests you wish to run.


## (LINUX)
--------------------------------------------------------------------------------------------
### Game Initialization
#### Dependencies
- **Unreal Engine Binaries (need a github account)**
    * Navigate to Unreal Github **[https://github.com/EpicGames/UnrealEngine/tree/5.3.2-release]**
        ```bash
        # Clone specific repo
        git clone git@github.com:EpicGames/UnrealEngine.git
        ```
- **Set **[$UNREAL_PATH]** env var**
    * in **`~/.basrc`** set path to wherever your binaries are located on your computer.
    * export `UNREAL_PATH=< path-to-your-binaries >`
- **Build binaries**
    ```bash
    ./Setup.sh
    ./GenerateProjectFiles.sh
    Engine/Build/BatchFiles/RunUAT.sh BuildGraph -target="Make Installed Build Linux" -script="Engine/Build"
    ```
#### Generate necessary files
```bash
# Link Engine to project (Makefile and etc)
./run.sh -g  ||  ./run.sh --generate
```

#### Unreal Editor
- **Enable Shader Model 6 (SM6)**
    * `Project Settings -> Platforms -> Linux -> Targeted RHIs`
- Animation Blueprints have to be found as classes and their paths have to have a **"_C"** at the end of the reference.

### Running Game
- **Compiling and Running Editor**
    ```bash
    # Compile Unreal cpp code
    ./run.sh -c  ||  ./run.sh --compile

    # Run Compiled Unreal cpp code in editor
    ./run.sh -e  ||  ./run.sh --editor
    ```
- **Packaging (Development, Shipping,Debug)**
    ```bash
    ./run.sh -p <BuildType>  ||  ./run.sh --package <BuildType>

    # Examples:
    ./run.sh -p Development 
    ./run.sh --package Shipping    
    ./run.sh --package Debug
    ```  
- **Running packaged game**
    ```bash 
    # Run packaged game
    ./run.sh -r      ||  ./run.sh --run

    # Package a game and Run packaged game
    ./run.sh -b      ||  ./run.sh --build
    ```
- **Cleanup (Binaries, Intermediate, Saved, Build) or all .core crash files**
    ```bash 
    ./run.sh -x      ||  ./run.sh --clean
    ./run.sh -x all  ||  ./run.sh --clean all
    ```

### Testing
#### Running Unit tests
- **Individual tests**
    ```bash 
    # Single tests 
    ./run.sh -u <TestName>              ||      ./run.sh --unit-test<TestName>

    # Examples:
    ./run.sh -u Pawns  
    ./run.sh -u Pawns.BasePawn
    ./run.sh -u Pawns.BasePawn.SpawnActor
    ```
- **Every test**
    ```bash 
    # All tests
    ./run.sh -u                         ||      ./run.sh --unit-test
    ```
### Running Functional tests
- **Individual tests**
    ```bash 
    # Single tests (Headless)
    ./run.sh -f <TestName>              ||      ./run.sh --func-test <TestName>

    # Examples:
    ./run.sh -f TT_functional_test_player

    # Single tests (Editor)
    ./run.sh -f <TestName> EDITOR       ||      ./run.sh --func-test <TestName> EDITOR

    # Examples:
    ./run.sh -f TT_functional_test_player EDITOR
    ```
- **Every test**
    ```bash 
    # All tests (Headless)
    ./run.sh -f             ||      ./run.sh -func

    # All tests (Editor)
    ./run.sh -f EDITOR      ||      ./run.sh -func EDITOR
    ```

### Docker
#### Files to update
- Add `bOverrideBuildEnvironment = true;` to `project.target.cs` file.

#### Permissions to download Unreal Image from Epic
- Navigate to [https://github.com/orgs/epicgames/packages/container/package/unreal-engine] for most recent images.
    ```bash
    # Login to Github that is subscribed to UnrealEngine repo.
    echo <git_hub_token> | docker login ghcr.io -u <Github_username> --password-stdin

    # Build Image for game
    docker build -t unreal-test .

    # Run Image for game
    docker run -it --rm --gpus all --network host --entrypoint=bash unreal-test
    ```

#### Troubleshooting
- **Check nvidia and vulkan drivers**:
    ```bash
    # provides monitoring and management capabilities for each of NVIDIA's Tesla, Quadro, GRID and GeForce devices
    nvidia-smi

    # display detailed information about the Vulkan API support on a system
    vulkaninfo

    # Confirm if the container can communicate with the driver.
    docker run -it --gpus all unreal-test nvidia-smi -L
    ```