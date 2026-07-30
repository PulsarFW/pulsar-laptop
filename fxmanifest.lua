fx_version 'cerulean'
game 'gta5'

name 'Pulsar Laptop'
description 'In-game laptop with business management, LSU, teams, and settings'
author 'Artmines - maintained for Pulsar Framework'
url 'https://pulsarframe.work'
version 'v1.0.0'

version_check 'yes'
github 'https://github.com/PulsarFW/pulsar_laptop'

client_script '@pulsar_core/components/cl_error.lua'
shared_script '@pulsar_core/core/sh_pulsar.lua'
client_script '@pulsar_pwnzor/client/check.lua'

ui_page 'ui/dist/index.html'

files({
	'ui/dist/index.html',
	'ui/dist/assets/*',
	'config/shared.lua',
})

client_scripts({
	'client/*.lua',
	'client/apps/**/*.lua',
})

server_scripts({
	'server/*.lua',
	'server/apps/**/*.lua',
})

lua54 'yes'
