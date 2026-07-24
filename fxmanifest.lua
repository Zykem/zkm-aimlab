fx_version "cerulean"
use_experimental_fxv2_oal "yes"
author "zykem"
repository "https://github.com/Zykem/zkm-aimlab"
version '1.0.0'
game 'gta5'
lua54 'yes'

dependencies {
    'ox_lib',
    'oxmysql',
}

shared_scripts {
    '@ox_lib/init.lua',
    'types.lua'
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

files {
    'client/**/*.lua',
    'config.lua',
    'config/aimlab.lua',
    'web/dist/index.html',
    'web/dist/**/*',
}

-- ui_page 'http://localhost:5173' -- used for Live development
ui_page 'web/dist/index.html'