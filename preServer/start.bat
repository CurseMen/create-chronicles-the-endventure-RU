@echo off

set NEOFORGE_VERSION=21.1.218
:: Update these variables if needed
set INSTALLER="%~dp0neoforge-%NEOFORGE_VERSION%-installer.jar"
set NEOFORGE_URL="https://maven.neoforged.net/releases/net/neoforged/neoforge/%NEOFORGE_VERSION%/neoforge-%NEOFORGE_VERSION%-installer.jar"


:: Use a specific Java version if CCE_JAVA environment variable is set
if defined CCE_JAVA (
    set JAVA_CMD=%CCE_JAVA%
) else (
    set JAVA_CMD=java
)

:: Check Java version
for /f tokens^=2-5^ delims^=.-_^" %%j in ('%JAVA_CMD% -version 2^>^&1') do set "jver=%%j"
if "%jver%" LSS "21" (
    echo Create Chronicles: The Endventure requires Java 21 or newer. Found Java %jver%.
    pause
    exit /b 1
)

:: Download NeoForge installer if not present
if not exist "%INSTALLER%" (
    echo NeoForge installer not found. Downloading NeoForge...
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%NEOFORGE_URL%', '%INSTALLER%')"
)

:: Install NeoForge if not already installed
if not exist "libraries\" (
    echo Forge not installed, installing now.
    %JAVA_CMD% -jar %INSTALLER% --installServer
)

:: Create server.properties if it does not exist
if not exist server.properties (
    echo allow-flight=true > server.properties
    echo motd=Create Chronicles: The Endventure >> server.properties
    echo max-tick-time=180000 >> server.properties
)

:: Install only, without starting the server
if "%CCE_INSTALL_ONLY%"=="true" (
    echo INSTALL_ONLY: complete
    goto :eof
)

:: Start server and handle automatic restarts
:server_start
%JAVA_CMD% @user_jvm_args.txt @libraries/net/neoforged/neoforge/%NEOFORGE_VERSION%/win_args.txt nogui
if "%CCE_RESTART%"=="false" (
    goto :eof
) else (
    echo Restarting automatically in 10 seconds (press Ctrl + C to cancel)
    timeout /t 10 /nobreak
    goto :server_start
)