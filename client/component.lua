_tabletProp = nil

LAPTOP = {
	Open = function(self)
		plsr.Inventory.Close:All()
		plsr.Animations.Emotes:ForceCancel()
		plsr.Interaction:Hide()
		plsr.State.flags.laptopOpen = true
		DisplayRadar(true)
		plsr.Hud:ShiftLocation(true)
		SendNUIMessage({ type = "LAPTOP_VISIBLE" })
		SetNuiFocus(true, true)

		CreateThread(function()
			local playerPed = PlayerPedId()
			LoadAnim("amb@code_human_in_bus_passenger_idles@female@tablet@base")
			LoadModel(`prop_cs_tablet`)

			local _tabletProp = CreateObject(`prop_cs_tablet`, GetEntityCoords(playerPed), 1, 1, 0)
			AttachEntityToEntity(
				_tabletProp,
				playerPed,
				GetPedBoneIndex(playerPed, 60309),
				0.02,
				-0.01,
				-0.03,
				0.0,
				0.0,
				-10.0,
				1,
				0,
				0,
				0,
				2,
				1
			)

			while plsr.State.flags.laptopOpen and _loggedIn do
				if
					not IsEntityPlayingAnim(
						playerPed,
						"amb@code_human_in_bus_passenger_idles@female@tablet@base",
						"base",
						3
					)
				then
					TaskPlayAnim(
						playerPed,
						"amb@code_human_in_bus_passenger_idles@female@tablet@base",
						"base",
						3.0,
						3.0,
						-1,
						49,
						0,
						false,
						false,
						false
					)
				end
				Wait(250)
			end

			StopAnimTask(playerPed, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0)
			DeleteEntity(_tabletProp)
		end)
	end,
	Close = function(self, forced)
		plsr.State.flags.laptopOpen = false
		plsr.Laptop:ResetRoute()

		if forced then
			SendNUIMessage({ type = "LAPTOP_NOT_VISIBLE_FORCED" })
		end

		SendNUIMessage({ type = "ALERTS_RESET" })

		if not IsPedInAnyVehicle(PlayerPedId(), true) then
			DisplayRadar(plsr.State.flags.loggedIn and hasValue(plsr.State.character.States, "GPS"))
		end

		plsr.Hud:ShiftLocation(plsr.State.flags.loggedIn and hasValue(plsr.State.character.States, "GPS"))
		SetNuiFocus(false, false)
		--TriggerEvent("UI:Client:Close", "laptop")
	end,
	IsOpen = function(self)
		return plsr.State.flags.laptopOpen
	end,
	ResetRoute = function(self)
		SendNUIMessage({ type = "CLEAR_HISTORY" })
	end,
	Permissions = {
		Load = function(self, p)
			SendNUIMessage({
				type = "LOAD_PERMS",
				data = p,
			})
		end,
	},
	IsAppUsable = function(self, app)
		if type(app) == "table" then
			return true
		else
			local appdata = LAPTOP_APPS[app]

			if appdata and hasValue(plsr.State.character.LaptopApps.installed, app) then
				if appdata.restricted then
					for k, v in pairs(appdata.restricted) do
						if v then
							if k == "state" then
								if type(v) == "string" then
									if not hasValue(plsr.State.character.States, v) then
										return false
									end
								else
									for j, b in ipairs(v) do
										if not hasValue(plsr.State.character.States, b) then
											return false
										end
									end
								end
							elseif k == "job" then
								if not plsr.Jobs.Permissions:HasJob(v) then
									return false
								end
							elseif k == "laptopPermission" then
								if not plsr.Laptop.Permissions:HasPermission(v.app, v.permission) then
									return false
								end
							elseif k == "reputation" then
								if not plsr.Reputation:HasLevel(v.repuation, appdata.restricted.repuationAmount or 0) then
									return false
								end
							end
						end
					end
					return true
				else
					return true
				end
			end
			return false
		end
	end,
	Data = {
		Set = function(self, key, data)
			SendNUIMessage({ type = "SET_DATA", data = { type = key, data = data } })
		end,
		Add = function(self, type, data, key)
			SendNUIMessage({ type = "ADD_DATA", data = { type = type, data = data, key = key } })
		end,
		Update = function(self, type, id, data)
			SendNUIMessage({ type = "UPDATE_DATA", data = { type = type, id = id, data = data } })
		end,
		Remove = function(self, key, id)
			SendNUIMessage({ type = "REMOVE_DATA", data = { type = key, id = id } })
		end,
		Reset = function(self)
			SendNUIMessage({ type = "RESET_DATA" })
		end,
	},
	Notification = {
		Add = function(self, title, description, time, duration, app, actions, notifData)
			if
				not plsr.State.flags.loggedIn or not hasValue(plsr.State.character.States, "LAPTOP")
			then
				return
			end

			local appUsable = plsr.Laptop:IsAppUsable(app)
			if
				_settings.notifications
				and (type(app) == "table" or (appUsable and not _settings.appNotifications[app]))
				and not plsr.Jail:IsJailed()
			then
				SendNUIMessage({
					type = "NOTIF_ADD",
					data = {
						notification = {
							title = title,
							description = description,
							time = (time - 1000),
							duration = duration,
							app = app,
							action = actions,
							data = notifData,
							show = true,
						},
					},
				})

				plsr.Sounds.Play:One("notification1.ogg", 0.1 * (_settings.volume / 100))
			end
		end,
		AddWithId = function(self, id, title, description, time, duration, app, actions, notifData)
			SendNUIMessage({
				type = "NOTIF_ADD",
				data = {
					notification = {
						_id = id,
						title = title,
						description = description,
						time = (time - 1000),
						duration = duration,
						app = app,
						action = actions,
						data = notifData,
						show = true,
					},
				},
			})

			if not plsr.State.flags.laptopOpen then
				plsr.Sounds.Play:One("notification1.ogg", 0.1 * (_settings.volume / 100))
			end
		end,
		Update = function(self, id, title, description, skipSound)
			SendNUIMessage({
				type = "NOTIF_UPDATE",
				data = {
					id = id,
					title = title,
					description = description,
				},
			})

			if not skipSound and not plsr.State.flags.laptopOpen then
				plsr.Sounds.Play:One("notification1.ogg", 0.1 * (_settings.volume / 100))
			end
		end,
		Remove = function(self, id)
			SendNUIMessage({
				type = "NOTIF_HIDE",
				data = {
					id = id,
				},
			})
		end,
		Reset = function(self)
			SendNUIMessage({ type = "NOTIF_DISMISS_ALL" })
		end,
	},
	Permissions = {
		HasPermission = function(self, app, permission)
			local myPerms = plsr.State.character.LaptopPermissions
			if not app or not permission then
				return false
			else
				return LaptopPermissions[app][permission]
			end
		end,
	},
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Laptop", LAPTOP)
end)

RegisterNetEvent("Laptop:Client:Close", function()
	plsr.Laptop:Close()
end)

RegisterNUICallback("CloseLaptop", function(data, cb)
	cb("OK")
	plsr.Laptop:Close()
end)

RegisterNetEvent(
	"Laptop:Client:Notifications:Add",
	function(title, description, time, duration, app, actions, notifData)
		plsr.Laptop.Notification:Add(title, description, time, duration, app, actions, notifData)
	end
)

RegisterNetEvent(
	"Laptop:Client:Notifications:AddWithId",
	function(id, title, description, time, duration, app, actions, notifData)
		plsr.Laptop.Notification:AddWithId(id, title, description, time, duration, app, actions, notifData)
	end
)

RegisterNetEvent("Laptop:Client:Notifications:Update", function(id, title, description)
	plsr.Laptop.Notification:Update(id, title, description)
end)

RegisterNetEvent("Laptop:Client:Notifications:Remove", function(id)
	plsr.Laptop.Notification:Remove(id)
end)

function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

function LoadModel(hash)
	while not HasModelLoaded(hash) do
		RequestModel(hash)
		Wait(10)
	end
end
