@echo off
setlocal

echo === AssetRipper Premium Recreation - Windows Build Script ===

REM Check if dotnet is installed
where dotnet >nul 2>&1
if %errorlevel% neq 0 (
    echo dotnet not found. Please install .NET 10 SDK from https://dotnet.microsoft.com/download
    exit /b 1
)

echo Using dotnet: 
dotnet --version

REM Restore packages
echo Restoring NuGet packages...
dotnet restore AssetRipper.slnx

REM Build for Windows x64
echo === Building for Windows x64 ===
dotnet publish Source\AssetRipper.GUI.PremiumRecreation\AssetRipper.GUI.PremiumRecreation.csproj ^
    -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false

echo Windows x64 build complete!
del Source\0Bins\AssetRipper.GUI.PremiumRecreation\Release\win-x64\publish\appsettings*.json
del Source\0Bins\AssetRipper.GUI.PremiumRecreation\Release\win-x64\publish\*staticwebassets.endpoints.json
del Source\0Bins\AssetRipper.GUI.PremiumRecreation\Release\win-x64\publish\web.config
if not exist Dist mkdir Dist
xcopy /E /Y Source\0Bins\AssetRipper.GUI.PremiumRecreation\Release\win-x64\publish Dist\AssetRipper_win-x64\
date /t > Dist\AssetRipper_win-x64\compile_time.txt
dir Dist\AssetRipper_win-x64\AssetRipper.GUI.PremiumRecreation.exe

REM Build for Windows ARM64
echo === Building for Windows ARM64 ===
dotnet publish Source\AssetRipper.GUI.PremiumRecreation\AssetRipper.GUI.PremiumRecreation.csproj ^
    -c Release -r win-arm64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=false /p:DebugType=None /p:DebugSymbols=false

echo Windows ARM64 build complete!
del Source\0Bins\AssetRipper.GUI.PremiumRecreation\Release\win-arm64\publish\appsettings*.json
del Source\0Bins\AssetRipper.GUI.PremiumRecreation\Release\win-arm64\publish\*staticwebassets.endpoints.json
del Source\0Bins\AssetRipper.GUI.PremiumRecreation\Release\win-arm64\publish\web.config
xcopy /E /Y Source\0Bins\AssetRipper.GUI.PremiumRecreation\Release\win-arm64\publish Dist\AssetRipper_win-arm64\
date /t > Dist\AssetRipper_win-arm64\compile_time.txt
dir Dist\AssetRipper_win-arm64\AssetRipper.GUI.PremiumRecreation.exe

echo === All Windows builds complete! ===
echo Output directory: Dist\
pause
