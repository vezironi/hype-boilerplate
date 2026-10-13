fx_version 'cerulean'
game {'gta5'}

author 'vezironi'
description 'Framework-agnostic FiveM resource starter: an ESX / QB / qbx bridge, pluggable modules (banking, inventory, fuel, notify, textui, progressbar, target, vehicle keys), NUI helpers for the bundled Vue + Tailwind interface, locales, shared utilities and automatic SQL installation.'

scriptname 'hype-boilerplate'
version '1.0.0'

dependencies {
    'ox_lib',
}

--- Order matters here:
---   utils.lua  defines Debug, used by everything below it
---   main.lua   defines RESOURCE_NAME / IsResourceRunning and loads the locale
---   frameworks & modules main.lua define the Framework / Modules tables that the
---   per-provider files in client_scripts / server_scripts fill in
shared_scripts {
    '@ox_lib/init.lua',
    'shared/utils.lua',
    'shared/main.lua',
    'frameworks/main.lua',
    'modules/main.lua',
    'config/config.lua',
}

client_scripts {
    'frameworks/*/cl-*.lua',
    'modules/*/cl-*.lua',
    'modules/*/*/cl-*.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'frameworks/*/sv-*.lua',
    'modules/*/sv-*.lua',
    'modules/*/*/sv-*.lua',
    'server/*.lua',
}

escrow_ignore {
    'config/*.lua',
    'shared/*.lua',
    'frameworks/**/*.lua',
    'modules/**/*.lua',
    'server/*.lua',
    'install/*.sql',
    'locales/*.json',
}

files {
    'config/*.lua',
    'shared/*.lua',
    'web/build/*.*',
    'web/build/**/*.*',
    'locales/*.json',
}

ui_page 'web/build/index.html'

lua54 'yes'
use_experimental_fxv2_oal 'yes'
