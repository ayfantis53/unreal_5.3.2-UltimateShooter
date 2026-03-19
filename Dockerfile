############################################################################################
#
#   _   _                      _       _____             _              ____  
#  | | | |_ __  _ __ ___  __ _| |     | ____|_ __   __ _(_)_ __   ___  | ___| 
#  | | | | '_ \| '__/ _ \/ _` | |_____|  _| | '_ \ / _` | | '_ \ / _ \ |___ \ 
#  | |_| | | | | | |  __/ (_| | |_____| |___| | | | (_| | | | | |  __/  ___) |
#   \___/|_| |_|_|  \___|\__,_|_|     |_____|_| |_|\__, |_|_| |_|\___| |____/ 
#                                                 |___/                                               
#
# UNREAL-ENGINE 5
#
# https://github.com/ayfantis53/unreal_5.3.2-UltimateShooter/edit/master/Dockerfile

############################################################################################
# Unreal Engine 5 Building Layer
# This is a MINIMAL RUNTIME image to build Unreal Engine 5 game
# For building environment to run UltimateShooter app
############################################################################################

# ============================================
# Stage 1: Builder
# ============================================
# Use a pre-built Unreal Engine 5 development image.
# This stage uses a large image with all necessary build tools (compilers, Unreal Engine source).
FROM ghcr.io/epicgames/unreal-engine:dev-5.3 AS builder

# Set environment variables for project name, paths, and build directory.
ENV UE_PROJECT_NAME="UltimateShooter"
ENV UNREAL_PATH="/home/ue4/UnrealEngine"

# Switch to root user to handle file permissions and installations.
USER root

# Set the working directory for subsequent instructions.
WORKDIR /$UE_PROJECT_NAME

# Copy project files from the local machine into the container.
COPY . .

# Install dependencies for Linux Editor/Target
RUN apt-get update && apt-get install -y --no-install-recommends \
        libglib2.0-dev \
        libatk1.0-0 \
        libgtk-3-0 \
        libdrm2 \
        libgbm-dev \
        libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Switch to the non-root user (UID 1000).
USER 1000

# Adjust file permissions to allow the 'ue4' user to access project and engine files.
# Remove Windows-style line endings from a script if present.
# Generate Linux-specific project files.
RUN sudo chown -R 1000 /$UE_PROJECT_NAME \
    && sed -i -e 's/\r$//' ./run.sh \
    && ./run.sh -g 
 
# Cook and build the project for Linux.
RUN /home/ue4/UnrealEngine/Engine/Build/BatchFiles/RunUAT.sh \
        BuildCookRun \
        -utf8output \
        -platform=Linux \
        -clientconfig=Development \
        -serverconfig=Development \
        -project=/$UE_PROJECT_NAME/$UE_PROJECT_NAME.uproject \
        -noP4 -nodebuginfo -allmaps \
        -cook -build -stage -prereqs -pak -archive \
        -archivedirectory=/$UE_PROJECT_NAME

# Run unit tests.
ENTRYPOINT ["./run.sh", "-u"]


# # ============================================
# # Stage 2: Runtime
# # ============================================
# # Use a lighter runtime image for the final, smaller container image.
# # This image only contains the necessary shared libraries and engine binaries to run the packaged game, not build it.
# FROM ghcr.io/epicgames/unreal-engine:dev-slim-5.7

# ENV UE_PROJECT_NAME="UltimateShooter"

# # Set the working directory for the runtime container.
# WORKDIR /$UE_PROJECT_NAME

# # Copy the packaged files from the builder stage's archive directory to the current stage's working directory.
# COPY --from=builder /tmp/dist/LinuxServer ./

# # Define the command to run when the container starts.
# # It executes the project's start-up script with specific command-line arguments:
# # -log: Enables logging to standard output.
# # -Port=7777: Sets the network port for the server.
# CMD ["./run.sh","NOGPU"]