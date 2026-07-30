local _ran = false
local config = load(LoadResourceFile(GetCurrentResourceName(), "config/server.lua"))()

function Startup()
	if _ran then
		return
	end
	_ran = true
	LAPTOP_APPS = {}
	for k, v in ipairs(config.appCatalog) do
		LAPTOP_APPS[v.name] = v
	end
end
