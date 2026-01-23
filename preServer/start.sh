#!/bin/sh
set -eu
NEOFORGE_VERSION=21.1.218
# To use a specific Java runtime, set an environment variable named CCE_JAVA to the full path of java.exe.
# To disable automatic restarts, set an environment variable named CCE_RESTART to false.
# To install the pack without starting the server, set an environment variable named CCE_INSTALL_ONLY to true.

INSTALLER="neoforge-$NEOFORGE_VERSION-installer.jar"
NEOFORGE_URL="https://maven.neoforged.net/releases/net/neoforged/neoforge/$NEOFORGE_VERSION/neoforge-$NEOFORGE_VERSION-installer.jar"

pause() {
    printf "%s\n" "Press enter to continue..."
    read -r ans
}

if ! command -v "${CCE_JAVA:-java}" >/dev/null 2>&1; then
    echo "Create Chronicles: The Endventure requires Java 21 - Java not found"
    pause
    exit 1
fi\

cd "$(dirname "$0")"
if [ ! -d libraries ]; then
    echo "NeoForge not installed, installing now."
    if [ ! -f "$INSTALLER" ]; then
        echo "NeoForge installer not found. Downloading NeoForge..."
        if command -v wget >/dev/null 2>&1; then
            wget -O "$INSTALLER" "$NEOFORGE_URL"
        elif command -v curl >/dev/null 2>&1; then
            curl -o "$INSTALLER" -L "$NEOFORGE_URL"
        else
            echo "Neither wget nor curl were found on your system. Please install one and try again."
            pause
            exit 1
        fi
    fi

    echo "Running NeoForge installer."
    "${CCE_JAVA:-java}" -jar "$INSTALLER" --installServer
fi

# Create server.properties if not exist
if [ ! -f "server.properties" ]; then
    {
        echo "allow-flight=true"
        echo "motd=Create Chronicles: The Endventure"
        echo "max-tick-time=180000"
    } > "server.properties"
fi

if [ "${CCE_INSTALL_ONLY:-false}" = "true" ]; then
    echo "INSTALL_ONLY: complete"
    exit 0
fi

JAVA_VERSION=$("${CCE_JAVA:-java}" -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d. -f1)
if [ "$JAVA_VERSION" -lt 21 ]; then
    echo "Create Chronicles: The Endventure requires Java 21. Found Java $JAVA_VERSION."
    pause
    exit 1
fi

while true
do
    "${CCE_JAVA:-java}" @user_jvm_args.txt @libraries/net/neoforged/neoforge/$NEOFORGE_VERSION/unix_args.txt nogui

    if [ "${CCE_RESTART:-true}" = "false" ]; then
        exit 0
    fi

    echo "Restarting automatically in 10 seconds (press Ctrl + C to cancel)"
    sleep 10
done