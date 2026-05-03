#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== AssetRipper CE - Multi-Platform Build Script ===${NC}"

# Check if running on Linux or macOS
CURRENT_OS="$(uname -s)"
if [[ "$CURRENT_OS" != "Linux" ]] && [[ "$CURRENT_OS" != "Darwin" ]]; then
    echo -e "${RED}This script is intended to run on Linux or macOS.${NC}"
    echo -e "${RED}Detected OS: $CURRENT_OS${NC}"
    exit 1
fi

echo -e "${GREEN}Running on: $CURRENT_OS${NC}"

# Setup dotnet environment
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Verify dotnet is available
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}dotnet not found. Please run build-linux.sh first to install .NET 10 SDK.${NC}"
    exit 1
fi

echo -e "${GREEN}Using dotnet: $(dotnet --version)${NC}"

# Parse arguments
BUILD_LINUX=false
BUILD_WINDOWS=false
BUILD_MAC=false
BUILD_ALL=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --linux)
            BUILD_LINUX=true
            BUILD_ALL=false
            shift
            ;;
        --windows)
            BUILD_WINDOWS=true
            BUILD_ALL=false
            shift
            ;;
        --mac|--macos)
            BUILD_MAC=true
            BUILD_ALL=false
            shift
            ;;
        --all)
            BUILD_ALL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--linux] [--windows] [--mac] [--all]"
            exit 1
            ;;
    esac
done

if [ "$BUILD_ALL" = true ]; then
    BUILD_LINUX=true
    BUILD_WINDOWS=true
    BUILD_MAC=true
fi

# Restore packages once
echo -e "${YELLOW}Restoring NuGet packages...${NC}"
dotnet restore AssetRipper.slnx

# Build for Linux x64
if [ "$BUILD_LINUX" = true ]; then
    echo -e "${GREEN}=== Building for Linux x64 ===${NC}"
    dotnet publish Source/AssetRipper.GUI.CE/AssetRipper.GUI.CE.csproj \
        -c Release -r linux-x64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:DebugType=None /p:DebugSymbols=false
    rm -f Source/0Bins/AssetRipper.GUI.CE/Release/linux-x64/publish/{appsettings*.json,*.staticwebassets.endpoints.json}
    mkdir -p Dist/AssetRipper_linux-x64
    cp -r Source/0Bins/AssetRipper.GUI.CE/Release/linux-x64/publish/* Dist/AssetRipper_linux-x64/
    date -u > Dist/AssetRipper_linux-x64/compile_time.txt
    echo -e "${GREEN}Linux x64 build complete!${NC}"
    ls -lh Dist/AssetRipper_linux-x64/AssetRipper.GUI.CE
fi

# Build for Linux ARM64
if [ "$BUILD_LINUX" = true ]; then
    echo -e "${GREEN}=== Building for Linux ARM64 ===${NC}"
    dotnet publish Source/AssetRipper.GUI.CE/AssetRipper.GUI.CE.csproj \
        -c Release -r linux-arm64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:DebugType=None /p:DebugSymbols=false
    rm -f Source/0Bins/AssetRipper.GUI.CE/Release/linux-arm64/publish/{appsettings*.json,*.staticwebassets.endpoints.json}
    mkdir -p Dist/AssetRipper_linux-arm64
    cp -r Source/0Bins/AssetRipper.GUI.CE/Release/linux-arm64/publish/* Dist/AssetRipper_linux-arm64/
    date -u > Dist/AssetRipper_linux-arm64/compile_time.txt
    echo -e "${GREEN}Linux ARM64 build complete!${NC}"
    ls -lh Dist/AssetRipper_linux-arm64/AssetRipper.GUI.CE
fi

# Build for Windows x64
if [ "$BUILD_WINDOWS" = true ]; then
    echo -e "${GREEN}=== Building for Windows x64 ===${NC}"
    dotnet publish Source/AssetRipper.GUI.CE/AssetRipper.GUI.CE.csproj \
        -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:DebugType=None /p:DebugSymbols=false
    rm -f Source/0Bins/AssetRipper.GUI.CE/Release/win-x64/publish/{appsettings*.json,*.staticwebassets.endpoints.json,web.config}
    mkdir -p Dist/AssetRipper_win-x64
    cp -r Source/0Bins/AssetRipper.GUI.CE/Release/win-x64/publish/* Dist/AssetRipper_win-x64/
    date -u > Dist/AssetRipper_win-x64/compile_time.txt
    echo -e "${GREEN}Windows x64 build complete!${NC}"
    ls -lh Dist/AssetRipper_win-x64/AssetRipper.GUI.CE.exe
fi

# Build for Windows ARM64
if [ "$BUILD_WINDOWS" = true ]; then
    echo -e "${GREEN}=== Building for Windows ARM64 ===${NC}"
    dotnet publish Source/AssetRipper.GUI.CE/AssetRipper.GUI.CE.csproj \
        -c Release -r win-arm64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:DebugType=None /p:DebugSymbols=false
    rm -f Source/0Bins/AssetRipper.GUI.CE/Release/win-arm64/publish/{appsettings*.json,*.staticwebassets.endpoints.json,web.config}
    mkdir -p Dist/AssetRipper_win-arm64
    cp -r Source/0Bins/AssetRipper.GUI.CE/Release/win-arm64/publish/* Dist/AssetRipper_win-arm64/
    date -u > Dist/AssetRipper_win-arm64/compile_time.txt
    echo -e "${GREEN}Windows ARM64 build complete!${NC}"
    ls -lh Dist/AssetRipper_win-arm64/AssetRipper.GUI.CE.exe
fi

# Build for macOS x64
if [ "$BUILD_MAC" = true ]; then
    echo -e "${GREEN}=== Building for macOS x64 ===${NC}"
    dotnet publish Source/AssetRipper.GUI.CE/AssetRipper.GUI.CE.csproj \
        -c Release -r osx-x64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:DebugType=None /p:DebugSymbols=false
    rm -f Source/0Bins/AssetRipper.GUI.CE/Release/osx-x64/publish/{appsettings*.json,*.staticwebassets.endpoints.json}
    mkdir -p Dist/AssetRipper_osx-x64
    cp -r Source/0Bins/AssetRipper.GUI.CE/Release/osx-x64/publish/* Dist/AssetRipper_osx-x64/
    date -u > Dist/AssetRipper_osx-x64/compile_time.txt
    echo -e "${GREEN}macOS x64 build complete!${NC}"
    ls -lh Dist/AssetRipper_osx-x64/AssetRipper.GUI.CE
fi

# Build for macOS ARM64
if [ "$BUILD_MAC" = true ]; then
    echo -e "${GREEN}=== Building for macOS ARM64 ===${NC}"
    dotnet publish Source/AssetRipper.GUI.CE/AssetRipper.GUI.CE.csproj \
        -c Release -r osx-arm64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:DebugType=None /p:DebugSymbols=false
    rm -f Source/0Bins/AssetRipper.GUI.CE/Release/osx-arm64/publish/{appsettings*.json,*.staticwebassets.endpoints.json}
    mkdir -p Dist/AssetRipper_osx-arm64
    cp -r Source/0Bins/AssetRipper.GUI.CE/Release/osx-arm64/publish/* Dist/AssetRipper_osx-arm64/
    date -u > Dist/AssetRipper_osx-arm64/compile_time.txt
    echo -e "${GREEN}macOS ARM64 build complete!${NC}"
    ls -lh Dist/AssetRipper_osx-arm64/AssetRipper.GUI.CE
fi

echo -e "${GREEN}=== All builds complete! ===${NC}"
echo -e "${GREEN}Output directory: Dist/${NC}"
echo -e "${YELLOW}Contents:${NC}"
ls -la Dist/
