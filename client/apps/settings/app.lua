RegisterNUICallback("UpdateSetting", function(data, cb)
	cb("OK")
	_settings[data.type] = data.val
	plsr.Callbacks:ServerCallback("Laptop:Settings:Update", data)
end)