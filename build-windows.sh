#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== AssetRipper Premium Recreation - Windows Build Script (Linux Host) ===${NC}"

# Check if running on Linux (cross-compile from Linux to Windows)
if [[ "$(uname -s)" != "Linux" ]]; then
    echo -e "${RED}This script is intended to run on Linux for cross-compilation to Windows.${NC}"
    echo -e "${RED}Detected OS: $(uname -s)${NC}"
    echo -e "${YELLOW}On Windows, use build-windows.bat instead.${NC}"
    exit 1
fi

# Install .NET 10 SDK if needed
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

# Build for Windows x64
echo -e "${GREEN}=== Building for Windows x64 ===${NC}"
dotnet publish Source/AssetRipper.GUI.PremiumRecreation/AssetRipper.GUI.PremiumRecreation.csproj \
    -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false

echo -e "${GREEN}Windows x64 build complete!${NC}"
rm -f Source/0Bins/AssetRipper.GUI.PremiumRecreation/Release/win-x64/publish/{appsettings*.json,*.staticwebassets.endpoints.json,web.config}
mkdir -p Dist/AssetRipper_win-x64
cp -r Source/0Bins/AssetRipper.GUI.PremiumRecreation/Release/win-x64/publish/* Dist/AssetRipper_win-x64/
date -u > Dist/AssetRipper_win-x64/compile_time.txt
ls -lh Dist/AssetRipper_win-x64/AssetRipper.GUI.PremiumRecreation.exe

# Build for Windows ARM64
echo -e "${GREEN}=== Building for Windows ARM64 ===${NC}"
dotnet publish Source/AssetRipper.GUI.PremiumRecreation/AssetRipper.GUI.PremiumRecreation.csproj \
    -c Release -r win-arm64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:DebugType=None /p:DebugSymbols=false

echo -e "${GREEN}Windows ARM64 build complete!${NC}"
rm -f Source/0Bins/AssetRipper.GUI.PremiumRecreation/Release/win-arm64/publish/{appsettings*.json,*.staticwebassets.endpoints.json,web.config}
mkdir -p Dist/AssetRipper_win-arm64
cp -r Source/0Bins/AssetRipper.GUI.PremiumRecreation/Release/win-arm64/publish/* Dist/AssetRipper_win-arm64/
date -u > Dist/AssetRipper_win-arm64/compile_time.txt
ls -lh Dist/AssetRipper_win-arm64/AssetRipper.GUI.PremiumRecreation.exe

echo -e "${GREEN}=== All Windows builds complete! ===${NC}"
echo -e "${GREEN}Output directory: Dist/${NC}"
