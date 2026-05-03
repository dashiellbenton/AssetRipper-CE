#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== AssetRipper Premium Recreation - Linux Build Script ===${NC}"

# Check if running on Linux
if [[ "$(uname -s)" != "Linux" ]]; then
    echo -e "${RED}This script is intended to run on Linux only.${NC}"
    echo -e "${RED}Detected OS: $(uname -s)${NC}"
    exit 1
fi

# Install .NET 10 SDK if needed
if ! command -v dotnet &> /dev/null; then
    echo -e "${YELLOW}dotnet not found. Installing .NET 10 SDK...${NC}"
    
    # Detect package manager
    if command -v pacman &> /dev/null; then
        echo -e "${GREEN}Detected Arch-based system. Installing via pacman...${NC}"
        sudo pacman -S --needed dotnet-sdk-10.0 aspnet-runtime-10.0
    elif command -v apt-get &> /dev/null; then
        echo -e "${GREEN}Detected Debian-based system. Installing via Microsoft repository...${NC}"
        wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        rm packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y dotnet-sdk-10.0
    else
        echo -e "${YELLOW}Using dotnet-install script...${NC}"
        curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
        chmod +x /tmp/dotnet-install.sh
        /tmp/dotnet-install.sh --channel 10.0 --install-dir "$HOME/.dotnet"
        export DOTNET_ROOT="$HOME/.dotnet"
        export PATH="$DOTNET_ROOT:$PATH"
    fi
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

# Build for Linux x64
echo -e "${GREEN}=== Building for Linux x64 ===${NC}"
dotnet publish Source/AssetRipper.GUI.PremiumRecreation/AssetRipper.GUI.PremiumRecreation.csproj \
    -c Release -r linux-x64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false

echo -e "${GREEN}=== Linux x64 Build Complete! ===${NC}"
rm -f Source/0Bins/AssetRipper.GUI.PremiumRecreation/Release/linux-x64/publish/{appsettings*.json,*.staticwebassets.endpoints.json}
mkdir -p Dist/AssetRipper_linux-x64
cp -r Source/0Bins/AssetRipper.GUI.PremiumRecreation/Release/linux-x64/publish/* Dist/AssetRipper_linux-x64/
date -u > Dist/AssetRipper_linux-x64/compile_time.txt
chmod +x Dist/AssetRipper_linux-x64/AssetRipper.GUI.PremiumRecreation

echo -e "${GREEN}Binary: Dist/AssetRipper_linux-x64/AssetRipper.GUI.PremiumRecreation${NC}"
ls -lh Dist/AssetRipper_linux-x64/
