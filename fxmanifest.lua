fx_version 'cerulean'
game 'gta5'

name 'orion-automod'
description 'Orion AutoMod - Automatic chat moderation system'
author 'orion'
version '1.0.6'

dependencies {
    'ox_lib'
}

server_scripts {
    'server/config.lua',
    'server/main.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client/main.lua'
}
