_openCd = false -- Prevents spamm open/close
_settings = {}
_loggedIn = false

local _ignoreEvents = {
	"Health",
	"HP",
	"Armor",
	"Status",
	"Damage",
	"Wardrobe",
	"Animations",
	"Ped",
}

CreateThread(function()
	plsr.State.flags.laptopOpen = false

	plsr.Keybinds:Add("laptop_open", "", "keyboard", "Laptop - Open", function()
		OpenLaptop()
	end)

	RegisterBoostingCallbacks()
end)

function OpenLaptop()
	if
		_loggedIn
		and not plsr.Hud:IsDisabled()
		and not plsr.Jail:IsJailed()
		and hasValue(plsr.State.character.States, "LAPTOP")
		and not plsr.State.flags.laptopOpen
	then
		plsr.Laptop:Open()
	end
end

RegisterNetEvent("Laptop:Client:Open", OpenLaptop)

AddEventHandler("Inventory:Client:ItemsLoaded", function()
	plsr.Laptop.Data:Set("items", plsr.Inventory.Items:GetData())
end)

AddEventHandler("Characters:Client:Updated", function(key)
	if hasValue(_ignoreEvents, key) then
		return
	end
	_settings = plsr.State.character.LaptopSettings
	plsr.Laptop.Data:Set("player", plsr.State:Get('character'))

	if
		key == "States"
		and plsr.State.flags.laptopOpen
		and (not hasValue(plsr.State.character.States, "LAPTOP"))
	then
		plsr.Laptop:Close(true)
	end
end)

AddEventHandler("Ped:Client:Died", function()
	plsr.Laptop:Close(true)
end)

RegisterNetEvent("Job:Client:DutyChanged", function(state)
	plsr.Laptop.Data:Set("onDuty", state)
end)

RegisterNetEvent("UI:Client:Reset", function(manual)
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "UI_RESET",
		data = {},
	})

	if manual then
		TriggerServerEvent("Laptop:Server:UIReset")
		if plsr.State.flags.laptopOpen then
			plsr.Laptop:Close()
		end
	end
end)

AddEventHandler("UI:Client:Close", function(context)
	if context ~= "laptop" then
		plsr.Laptop:Close()
	end
end)

AddEventHandler("Ped:Client:Died", function()
	if plsr.State.flags.laptopOpen then
		plsr.Laptop:Close()
	end
end)

RegisterNetEvent("Laptop:Client:SetApps", function(apps)
	LAPTOP_APPS = apps
	SendNUIMessage({
		type = "SET_APPS",
		data = apps,
	})
end)

AddEventHandler("Characters:Client:Spawn", function()
	_loggedIn = true

	CreateThread(function()
		while _loggedIn do
			SendNUIMessage({
				type = "SET_TIME",
				data = GlobalState["Sync:Time"],
			})
			Wait(15000)
		end
	end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
	_loggedIn = false
end)

function hasValue(tbl, value)
	for k, v in ipairs(tbl or {}) do
		if v == value or (type(v) == "table" and hasValue(v, value)) then
			return true
		end
	end
	return false
end

RegisterNUICallback("AcceptPopup", function(data, cb)
	cb("OK")
	if data.data ~= nil and data.data.server then
		TriggerServerEvent(data.event, data.data)
	else
		TriggerEvent(data.event, data.data)
	end
end)

RegisterNUICallback("CancelPopup", function(data, cb)
	cb("OK")
	if data.data ~= nil and data.data.server then
		TriggerServerEvent(data.event, data.data)
	else
		TriggerEvent(data.event, data.data)
	end
end)

RegisterNUICallback("CDExpired", function(data, cb)
	cb("OK")
	_openCd = false
end)
