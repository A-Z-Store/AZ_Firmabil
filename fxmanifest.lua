fx_version 'cerulean'
game 'gta5'

author 'Agger'
description 'Firma Bil'
version '1.0.0'

dependencies {
    'ox_lib',
    'ox_target',
    'PolyZone'
}


shared_scripts {
    '@ox_lib/init.lua',  
    'config.lua'
}


client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/client.lua',
    'client/vehicle.lua'
}


server_script 'server/server.lua'


lua54 'yes'
