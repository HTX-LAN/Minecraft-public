#!/bin/ash
# Paper Installation Script
#
# Server Files: /mnt/server
apk add --no-cache --update curl jq git

if [ -n "${DL_PATH}" ]; then
    echo -e "using supplied download url"
    DOWNLOAD_URL=`eval echo $(echo ${DL_PATH} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
else
    VER_EXISTS=`curl -s https://papermc.io/api/v1/paper | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | IN($VERSION)' | grep true`
    LATEST_PAPER_VERSION=`curl -s https://papermc.io/api/v1/paper | jq -r '.versions' | jq -r '.[0]'`
    
    if [ "${VER_EXISTS}" == "true" ]; then
        echo -e "Version is valid. Using version ${MINECRAFT_VERSION}"
    else
        echo -e "Using the latest paper version"
        MINECRAFT_VERSION=${LATEST_PAPER_VERSION}
    fi
    
    BUILD_EXISTS=`curl -s https://papermc.io/api/v1/paper/${MINECRAFT_VERSION} | jq -r --arg BUILD ${BUILD_NUMBER} '.builds.all[] | IN($BUILD)' | grep true`
    LATEST_PAPER_BUILD=`curl -s https://papermc.io/api/v1/paper/${MINECRAFT_VERSION} | jq -r '.builds.latest'`
    
    if [ "${BUILD_EXISTS}" == "true" ] || [ ${BUILD_NUMBER} == "latest" ]; then
        echo -e "Build is valid. Using version ${BUILD_NUMBER}"
    else
        echo -e "Using the latest paper build"
        BUILD_NUMBER=${LATEST_PAPER_BUILD}
    fi
    
    echo "Version being downloaded"
    echo -e "MC Version: ${MINECRAFT_VERSION}"
    echo -e "Build: ${BUILD_NUMBER}"
    DOWNLOAD_URL=https://papermc.io/api/v1/paper/${MINECRAFT_VERSION}/${BUILD_NUMBER}/download 
fi

cd /mnt/server

echo -e "running curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}"

if [ -f ${SERVER_JARFILE} ]; then
    mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

echo -e "Downloading MC server.properties"
if [ -f server.properties ]; then
    mv server.properties server.properties.old
fi
curl -o server.properties https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/server.properties

echo "Setting up server icon"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/server-icon.png -o server-icon.png

#install plugins
echo "----------------- Installing Plugins ----------------------------"
echo "Creating plugin folder"
[ ! -d "plugins/" ] &&  mkdir plugins

echo "Installing powerRanks"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/PowerRanks.jar -o plugins/PowerRanks.jar
echo "Creating configuration for PowerRanks"
[ ! -d "plugins/PowerRanks/" ] && mkdir plugins/PowerRanks
[ ! -d "plugins/PowerRanks/Ranks/" ] && mkdir plugins/PowerRanks/Ranks
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/PowerRanks/Ranks/Ranks.yml -o plugins/PowerRanks/Ranks/Ranks.yml

echo "Installing HungerGames"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/HungerGames.jar -o plugins/HungerGames.jar
echo "Creating configuration for HungerGames"
[ ! -d "plugins/HungerGames/" ] &&  mkdir plugins/HungerGames
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/HungerGames/arenas.yml -o plugins/HungerGames/arenas.yml
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/HungerGames/config.yml -o plugins/HungerGames/config.yml
# curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/HungerGames/items.yml -o plugins/HungerGames/items.yml

echo "Installing WorldEdit"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/worldedit.jar -o plugins/wordedit.jar

echo "Installing worldGuard"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/worldguard.jar -o plugins/worldguard.jar

echo "Installing Multiverse-Core"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/multiverse-core.jar -o plugins/multiverse-core.jar
[ ! -d "plugins/Multiverse-Core/" ] &&  mkdir plugins/Multiverse-Core
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/Multiverse-Core/worlds.yml -o plugins/Multiverse-Core/worlds.yml

echo "Installing EssentialsX"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/EssentialsX.jar -o plugins/EssentialsX.jar
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/plugins/EssentialsXChat.jar -o plugins/EssentialsXChat.jar

echo "Installing antiCheat"
curl -L -s https://github.com/Rammelkast/AntiCheatReloaded/releases/download/1.9.5/AntiCheatReloaded.jar -o plugins/AntiCheatReloaded.jar
ProtocolLib_version=4.5.1
curl -L -s https://github.com/dmulloy2/ProtocolLib/releases/download/${ProtocolLib_version}/ProtocolLib.jar -o plugins/ProtocolLib.jar

echo "Setting Eula"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames/eula.txt -o eula.txt

# Installing map
if [ -n "${GITHUBCREDENTIALS}" ]; then
    world=Lan-World-2
    
    echo "----------------- Installing map ----------------------------"
    echo "Creating directories"
    [ -d "Lan-World/" ] && rm -r Lan-World
    [ -d "tmpMapClone/" ] && rm -r tmpMapClone

    echo "Downloading required files from github"
    mkdir tmpMapClone/
    git clone https://htxlan:${GITHUBCREDENTIALS}@github.com/HTX-LAN/Minecraft.git tmpMapClone/

    echo "Moving map files"
    cp -r tmpMapClone/Hunger-games/$world Lan-World
    cp -r tmpMapClone/Hunger-games/$world Lan-World-2

    echo "Cleaning up"
    rm -r tmpMapClone

    echo "Map installed successfully"
else
    echo "----------------- Could not install the map ------------------"
fi