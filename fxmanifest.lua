fx_version 'cerulean'
game 'gta5'

author 'Az-Store'
description 'Firma Bil'
version '1.0.0'

dependencies {
    'ox_lib',
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
