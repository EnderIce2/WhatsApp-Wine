#!/bin/bash

## https://github.com/EnderIce2

## Config Files (Writing files and check if exists)
## installed
## not_installed
## prefix.conf (prefix)

# TODO: app.ico is buggy in gnome-shell

SCRIPT_VERSION="1.4" ## Version
echo "SCRIPT VERSION $SCRIPT_VERSION" ## Writing version
CONFIG_FILE=/home/$USER/.config/WhatsApp-wine/prefix.conf ## Reading Wine prefix
if [ -f "$CONFIG_FILE" ]; then ## If exists prefix.conf
    wineConfigPrefix=$(head -n 1 /home/$USER/.config/WhatsApp-wine/prefix.conf)
fi
MACHINE_TYPE=`uname -m` ## Get system architecture

killserver_whatsapp() ## Kill WhatsApp.exe and other processes
{
    echo "Please wait..."
    WINEPREFIX="/home/$USER/$wineConfigPrefix" wineserver -k ## Kill all wine processes under config prefix
    echo "Done"
    exit 0
}

repair_whatsapp() ## Repair the installation without taking all steps again
{
    rm -f /home/$USER/.config/WhatsApp-wine/installed
    echo "Removing prefix..."
    rm -r -f /home/$USER/$wineConfigPrefix ## Deleting the prefix
    echo "Downloading WhatsApp Web $MACHINE_TYPE"
    if [[ ${MACHINE_TYPE} == "x86_64" ]]; then
        wget -O tmp_repair https://web.whatsapp.com/desktop/windows/release/x64/WhatsAppSetup.exe -q --show-progress
    else
        wget -O tmp_repair https://web.whatsapp.com/desktop/windows/release/ia32/WhatsAppSetup.exe -q --show-progress
    fi
    echo "Extracting files..."
    7z e tmp_repair -aoa > /dev/null 2>&1
    files=( ./*.nupkg )
    7z x '-i!lib/net45' ${files[0]} -aoa > /dev/null 2>&1
    echo "Creating prefix for $MACHINE_TYPE..."
    echo -e "\e[5m[ NOTE ]\e[25m"
    echo "When \"Wine configurator\" shows up, just click \"OK\"."
    if [ ${MACHINE_TYPE} == 'x86_64' ]; then
        WINEPREFIX="/home/$USER/$wineConfigPrefix" WINEARCH=win64 winecfg > /dev/null 2>&1
    else
        WINEPREFIX="/home/$USER/$wineConfigPrefix" WINEARCH=win32 winecfg > /dev/null 2>&1
    fi
    echo "Creating directory..."
    mkdir -p "/home/$USER/$wineConfigPrefix/drive_c/users/$USER/Application Data/WhatsApp"
    echo "Copying files..."
    cp setupIcon.ico "/home/$USER/$wineConfigPrefix/drive_c/users/$USER/Application Data/WhatsApp/app.ico"
    cp -r $PWD/lib/net45/* "/home/$USER/$wineConfigPrefix/drive_c/users/$USER/Application Data/WhatsApp"
    clear
    echo -e "\e[5m[ NOTE ]\e[25m"
    echo "If you got stuck with"
    echo "\"Running /usr/bin/wineserver -w. This will hang until all wine processes in prefix=/home/$USER/$winePrefixName terminate\""
    echo "Or"
    echo "\"0614:err:ntdll:RtlpWaitForCriticalSection section 7BC6C600 \"loader.c: fls_section\" wait timed out in thread 0614, blocked by 0558, retrying (60 sec)\""
    echo "Or something else like that"
    echo "Open another Terminal and paste this:"
    echo -e "\e[7mWINEPREFIX=\"/home/$USER/$wineConfigPrefix\" wineserver -k\e[27m"
    echo "This process may take a while!"
    read -p 'Press <enter> to continue'
    clear
    echo "Installing dotnet45 in $wineConfigPrefix"
    WINEPREFIX="/home/$USER/$wineConfigPrefix" winetricks -q nocrashdialog dotnet45 dxvk win10
    echo "Removing useless files..."
    rm ${files[0]}
    rm background.gif
    rm RELEASES
    rm Update.exe
    rm tmp
    rm -r $PWD/lib
    rm setupIcon.ico
    echo "Checking for files..."
    touch /home/$USER/.config/WhatsApp-wine/installed
    WHATSAPP_FILE=/home/$USER/$wineConfigPrefix/drive_c/users/$USER/Application\ Data/WhatsApp/WhatsApp.exe
    if [ -f "$WHATSAPP_FILE" ]; then
        read -p "Do you want to run WhatsApp now? [Y/n]: " answer
        answer=${answer:Y}
        [[ $answer =~ [Yy] ]] && WINEPREFIX="/home/$USER/$wineConfigPrefix" wine "/home/$USER/$wineConfigPrefix/drive_c/users/$USER/Application Data/WhatsApp/WhatsApp.exe"
        rm -f /home/$USER/.config/WhatsApp-wine/not_installed
        exit 0
    else 
        echo "WhatsApp still not installed! Something with this script is wrong..."
        touch /home/$USER/.config/WhatsApp-wine/not_installed
        exit 0
    fi
}

uninstall_whatsapp() ## Deletes everything that this script did
{
    rm -f /home/$USER/.local/share/applications/wine-whatsapp.desktop
    rm -r -f /home/$USER/$wineConfigPrefix
    rm -r -f /home/$USER/.config/WhatsApp-wine
    echo "Done"
    exit 0
}

about_whatsapp() ## Shows credit and this script version
{
    clear
    echo "======================================================"
    echo "| Script by EnderIce2 (https://github.com/EnderIce2) |"
    echo "| Version: $SCRIPT_VERSION                           |"
    echo "======================================================"
    exit 0
}

FILE_CONFIG=/home/$USER/.config/WhatsApp-wine/installed
echo "$FILE_CONFIG"
if [ -f "$FILE_CONFIG" ]; then
    echo "WhatsApp Wine is already installed ($wineConfigPrefix) [Script v$SCRIPT_VERSION]"
    echo "===================================="
    echo "| Start WhatsApp          [S]      |"
    echo "| Kill WhatsApp           [K]      |"
    echo "| Repair                  [R]      |"
    echo "| Uninstall               [U]      |"
    echo "| About This Script       [A]      |"
    echo "===================================="
    read -p "> " ru_answer
    ru_answer=${ru_answer:U}
    [[ $ru_answer =~ [Ss] ]] && WINEPREFIX="/home/$USER/$wineConfigPrefix" wine "/home/$USER/$wineConfigPrefix/drive_c/users/$USER/Application Data/WhatsApp/WhatsApp.exe"
    [[ $ru_answer =~ [Kk] ]] && killserver_whatsapp
    [[ $ru_answer =~ [Rr] ]] && repair_whatsapp
    [[ $ru_answer =~ [Uu] ]] && uninstall_whatsapp
    [[ $ru_answer =~ [Aa] ]] && about_whatsapp
    exit 0
else 
    echo "Loading..."
fi

if wine --version > /dev/null 2>&1 ; then ## Check if Wine is installed
    echo "Wine installed"
else
    echo "============================================================"
    echo "| Make sure that you have installed Wine!                  |"
    echo "| Install it here: https://wiki.winehq.org/Download        |"
    echo "============================================================"
    echo "Wine not installed."
    exit 0
fi
## I should make that automatically installs prerequisites for every distribution
if winetricks --version > /dev/null 2>&1 ; then ## Check if Winetricks is installed
    echo "Winetricks installed"
else
    sudo apt install winetricks -y
    if winetricks --version > /dev/null 2>&1 ; then
        echo "Winetricks installed"
    else
        echo "Winetricks still not installed"
        exit 0
    fi
fi

if 7z > /dev/null 2>&1 ; then ## Check if 7z is installed
    echo "p7zip-rar installed"
else
    sudo apt install p7zip-rar -y
    if 7z > /dev/null 2>&1 ; then
        echo "p7zip-rar installed"
    else
        echo "p7zip-rar still not installed"
        exit 0
    fi
fi
clear
echo -e "\e[5m[ NOTE ]\e[25m"
echo "Make sure that you have at least 10GB free space"
read -p 'Press <enter> to continue'
mkdir -p /home/$USER/.config/WhatsApp-wine
echo "Downloading WhatsApp Web $MACHINE_TYPE"
if [[ ${MACHINE_TYPE} == "x86_64" ]]; then ## Download 64 or 32 bit WhatsApp installer
    wget -O tmp https://web.whatsapp.com/desktop/windows/release/x64/WhatsAppSetup.exe -q --show-progress
else
    wget -O tmp https://web.whatsapp.com/desktop/windows/release/ia32/WhatsAppSetup.exe -q --show-progress
fi
echo "Extracting files..."
7z e tmp -aoa > /dev/null 2>&1 ## Extract all files from the executable that was downloaded earlier
files=( ./*.nupkg ) ## Gets all files named .nupkg (bad idea but i don't really know a better way to get that file with version on filename)
7z x '-i!lib/net45' ${files[0]} -aoa > /dev/null 2>&1 ## Extract only lib/net45 from .nupkg archive
clear
read -p 'Name your Wine prefix (ex: .whatsapp, .whatsapp-wine, etc...): ' winePrefixName
echo $winePrefixName > /home/$USER/.config/WhatsApp-wine/prefix.conf
echo "Creating directory..."
mkdir -p "/home/$USER/$winePrefixName"
mkdir -p "/home/$USER/$winePrefixName/drive_c/users/$USER/Application Data/WhatsApp"
echo "Copying files..."
cp setupIcon.ico "/home/$USER/$winePrefixName/drive_c/users/$USER/Application Data/WhatsApp/app.ico"
cp -r $PWD/lib/net45/* "/home/$USER/$winePrefixName/drive_c/users/$USER/Application Data/WhatsApp"
echo "Creating prefix for $MACHINE_TYPE..."
if [ ${MACHINE_TYPE} == 'x86_64' ]; then ## Create 64 or 32 bit Wine prefix
    WINEPREFIX="/home/$USER/$winePrefixName" WINEARCH=win64 wine stub > /dev/null 2>&1
else
    WINEPREFIX="/home/$USER/$winePrefixName" WINEARCH=win32 wine stub > /dev/null 2>&1
fi
clear
echo -e "\e[5m[ NOTE ]\e[25m"
echo "If you got stuck with"
echo "\"Running /usr/bin/wineserver -w. This will hang until all wine processes in prefix=/home/$USER/$winePrefixName terminate\""
echo "Open another Terminal and paste this:"
echo -e "\e[7mWINEPREFIX=\"/home/$USER/$winePrefixName\" wineserver -k\e[27m"
echo "This process may take a while!"
read -p 'Press <enter> to continue'
clear
echo "Installing dotnet45 and dxvk in $winePrefixName"
WINEPREFIX="/home/$USER/$winePrefixName" winetricks -q nocrashdialog dotnet45 dxvk win10

rm -f /home/$USER/.local/share/applications/wine-whatsapp.desktop
echo "Adding shortcut..."
echo "[Desktop Entry]" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
echo "Type=Application" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
echo "Categories=Network;" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
echo "Name=WhatsApp" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    echo "Exec=env WINEPREFIX=\"/home/$USER/$winePrefixName\" WINEARCH=win64 wine C:\\\\\\\\windows\\\\\\\\command\\\\\\\\start.exe /Unix \"/home/$USER/$winePrefixName/drive_c/users/$USER/Application Data/WhatsApp/WhatsApp.exe\"" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
else
    echo "Exec=env WINEPREFIX=\"/home/$USER/$winePrefixName\" WINEARCH=win32 wine C:\\\\\\\\windows\\\\\\\\command\\\\\\\\start.exe /Unix \"/home/$USER/$winePrefixName/drive_c/users/$USER/Application Data/WhatsApp/WhatsApp.exe\"" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
fi
echo "StartupNotify=true" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
echo "Terminal=false" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
echo "X-KeepTerminal=false" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
echo "Icon=/home/$USER/$winePrefixName/drive_c/users/$USER/Application Data/WhatsApp/app.ico" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
echo "Name[en_US]=WhatsApp" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop
echo "StartupWMClass=WhatsApp.exe" >> /home/$USER/.local/share/applications/wine-whatsapp.desktop

echo "chmod the shortcut..."
chmod +x /home/$USER/.local/share/applications/wine-whatsapp.desktop

echo "Removing useless files..."
rm ${files[0]}
rm background.gif
rm RELEASES
rm Update.exe
rm tmp
rm -r $PWD/lib
rm setupIcon.ico
clear
cat << "EOF"
==================================================================================
| __        ___           _          _                 __        ___             |
| \ \      / / |__   __ _| |_ ___   / \   _ __  _ __   \ \      / (_)_ __   ___  |
|  \ \ /\ / /| '_ \ / _` | __/ __| / _ \ | '_ \| '_ \   \ \ /\ / /| | '_ \ / _ \ |
|   \ V  V / | | | | (_| | |_\__ \/ ___ \| |_) | |_) |   \ V  V / | | | | |  __/ |
|    \_/\_/  |_| |_|\__,_|\__|___/_/   \_\ .__/| .__/     \_/\_/  |_|_| |_|\___| |
|                                        |_|   |_|                               |
==================================================================================
          https://github.com/EnderIce2
EOF
echo "Script version: $SCRIPT_VERSION"
touch /home/$USER/.config/WhatsApp-wine/installed
WHATSAPP_FILE=/home/$USER/$winePrefixName/drive_c/users/$USER/Application\ Data/WhatsApp/WhatsApp.exe
if [ -f "$WHATSAPP_FILE" ]; then ## Check if WhatsApp.exe is there
    read -p "Do you want to run WhatsApp now? [Y/n]: " answer
    answer=${answer:Y}
    [[ $answer =~ [Yy] ]] && WINEPREFIX="/home/$USER/$winePrefixName" wine "/home/$USER/$winePrefixName/drive_c/users/$USER/Application Data/WhatsApp/WhatsApp.exe"
    rm -f /home/$USER/.config/WhatsApp-wine/not_installed
else 
    echo "WhatsApp seems that it's not successfully installed. This may be a bug or something. Try running again this script to fix the problem."
    touch /home/$USER/.config/WhatsApp-wine/not_installed
fi
