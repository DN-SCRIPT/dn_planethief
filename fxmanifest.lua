fx_version 'cerulean'

game 'gta5'
author 'DN DEVELOPMENT'
description 'DN Plain Thief'


version '1.0.0'

server_scripts {
    '@es_extended/locale.lua',
	'config.lua',
	'server/main.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fr.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/main.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/fr.lua'
}


shared_script '@es_extended/imports.lua'
