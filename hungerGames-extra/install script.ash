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
curl -o server.properties https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/server.properties
echo "Setting up server icon"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/server-icon.png -o server-icon.png
#install plugins
echo "----------------- Installing Plugins ----------------------------"
echo "Creating plugin folder"
[ ! -d "plugins/" ] &&  mkdir plugins
echo "Installing powerRanks"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/PowerRanks.jar -o plugins/PowerRanks.jar
echo "Creating configuration for PowerRanks"
[ ! -d "plugins/PowerRanks/" ] && mkdir plugins/PowerRanks
[ ! -d "plugins/PowerRanks/Ranks/" ] && mkdir plugins/PowerRanks/Ranks
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/PowerRanks/Ranks/Ranks.yml -o plugins/PowerRanks/Ranks/Ranks.yml
echo "Installing hungerGames"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/HungerGames.jar -o plugins/hungerGames.jar
echo "Creating configuration for hungerGames"
[ ! -d "plugins/hungerGames/" ] &&  mkdir plugins/hungerGames
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/HungerGames/arenas.yml -o plugins/HungerGames/arenas.yml
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/HungerGames/config.yml -o plugins/HungerGames/config.yml
# curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/HungerGames/items.yml -o plugins/HungerGames/items.yml
echo "Installing WorldEdit"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/worldedit.jar -o plugins/wordedit.jar
echo "Installing worldGuard"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/worldguard.jar -o plugins/worldguard.jar
echo "Installing Multiverse-core"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/multiverse-core.jar -o plugins/multiverse-core.jar
echo "Installing EssentialsX"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/EssentialsX.jar -o plugins/EssentialsX.jar
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/plugins/EssentialsXChat.jar -o plugins/EssentialsXChat.jar
echo "Installing antiCheat"
curl -L -s https://github.com/Rammelkast/AntiCheatReloaded/releases/download/1.9.5/AntiCheatReloaded.jar -o plugins/AntiCheatReloaded.jar
echo "Setting Eula"
curl -L -s https://raw.githubusercontent.com/HTX-LAN/Minecraft-public/master/hungerGames-extra/eula.txt -o eula.txt
echo "----------------- Installing map ----------------------------"
echo "Creating directories"
[ -d "world/" ] && rm -r world
[ -d "tmpMapClone/" ] && rm -r tmpMapClone
echo "Downloading required files"
mkdir tmpMapClone/
git clone https://htxlan:HyV8utX37tQEYbTm@github.com/HTX-LAN/Minecraft.git tmpMapClone/
echo "Moving map files"
cp -r tmpMapClone/Hunger-games-extra/HG-world world
echo "Cleaning up"
rm -r tmpMapClone
echo "Map installed successfully"
