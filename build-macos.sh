#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== AssetRipper Premium Recreation - macOS Build Script ===${NC}"

# Check if running on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}This script is intended to run on macOS only.${NC}"
    echo -e "${RED}Detected OS: $(uname -s)${NC}"
    echo -e "${YELLOW}Cross-compiling for macOS from Linux is not supported in this script.${NC}"
    exit 1
fi

echo -e "${GREEN}Running on macOS - proceeding with build.${NC}"

# Check if dotnet is installed
if ! command -v dotnet &> /dev/null; then
    echo -e "${YELLOW}dotnet not found. Installing .NET 10 SDK...${NC}"
    curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
    chmod +x /tmp/dotnet-install.sh
    /tmp/dotnet-install.sh --channel 10.0 --install-dir "$HOME/.dotnet"
fi

# Setup dotnet environment
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Verify installation
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}dotnet installation failed${NC}"
    exit 1
fi

echo -e "${GREEN}Using dotnet: $(dotnet --version)${NC}"

# Restore packages
echo -e "${YELLOW}Restoring NuGet packages...${NC}"
dotnet restore AssetRipper.slnx

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    RUNTIME="osx-x64"
    echo -e "${GREEN}Detected x64 architecture${NC}"
elif [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
    RUNTIME="osx-arm64"
    echo -e "${GREEN}Detected ARM64 architecture${NC}"
else
    echo -e "${RED}Unsupported architecture: $ARCH${NC}"
    exit 1
fi

# Build for detected architecture
echo -e "${GREEN}=== Building for macOS ($RUNTIME) ===${NC}"
dotnet publish Source/AssetRipper.GUI.PremiumRecreation/AssetRipper.GUI.PremiumRecreation.csproj \
    -c Release -r $RUNTIME --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false

echo -e "${GREEN}=== macOS ($RUNTIME) build complete! ===${NC}"
rm -f Source/0Bins/AssetRipper.GUI.PremiumRecreation/Release/$RUNTIME/publish/{appsettings*.json,*.staticwebassets.endpoints.json}
mkdir -p Dist/AssetRipper_$RUNTIME
cp -r Source/0Bins/AssetRipper.GUI.PremiumRecreation/Release/$RUNTIME/publish/* Dist/AssetRipper_$RUNTIME/
date -u > Dist/AssetRipper_$RUNTIME/compile_time.txt
chmod +x Dist/AssetRipper_$RUNTIME/AssetRipper.GUI.PremiumRecreation

echo -e "${GREEN}Binary: Dist/AssetRipper_$RUNTIME/AssetRipper.GUI.PremiumRecreation${NC}"
ls -lh Dist/AssetRipper_$RUNTIME/
