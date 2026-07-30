local config = load(LoadResourceFile(GetCurrentResourceName(), "config/shared.lua"))().lsu.chopping

local _blips = {}

local _doingActions = false
local _validVeh = nil
local _validBone = nil
local _delay = false

RegisterNetEvent("Characters:Client:Spawn", function(data)
	plsr.Polyzone.Create:Box(
		"chopping_public",
		GlobalState["PublicDropoff"].coords,
		GlobalState["PublicDropoff"].length,
		GlobalState["PublicDropoff"].width,
		GlobalState["PublicDropoff"].options,
		{}
	)
	plsr.Polyzone.Create:Box(
		"chopping_private",
		GlobalState["PrivateDropoff"].coords,
		GlobalState["PrivateDropoff"].length,
		GlobalState["PrivateDropoff"].width,
		GlobalState["PrivateDropoff"].options,
		{}
	)
	plsr.Polyzone.Create:Box(
		"chopping_personal",
		GlobalState["PersonalDropoff"].coords,
		GlobalState["PersonalDropoff"].length,
		GlobalState["PersonalDropoff"].width,
		GlobalState["PersonalDropoff"].options,
		{}
	)

	plsr.Laptop.LSUnderground.Chopping:CreateBlips()
end)

LAPTOP.LSUnderground = LAPTOP.LSUnderground or {}
LAPTOP.LSUnderground.Chopping = {
	CreateBlips = function(self)
		if plsr.Reputation:HasLevel("Salvaging", 7) or hasValue(plsr.State.character.States or {}, "ACCESS_LSUNDERGROUND") then
			_blips.public = plsr.Blips:Add(
				"chopping_public",
				"LSUNDG Public Dropoff",
				GlobalState["PublicDropoff"].coords,
				524,
				35,
				0.4
			)
		else
			plsr.Blips:Remove("chopping_public")
		end

		if plsr.Reputation:HasLevel("Salvaging", 7) and (plsr.Reputation:HasLevel("Chopping", 5) or hasValue(plsr.State.character.States or {}, "ACCESS_LSUNDERGROUND")) then
			_blips.vip = plsr.Blips:Add(
				"chopping_private",
				"LSUNDG Private Dropoff",
				GlobalState["PrivateDropoff"].coords,
				524,
				36,
				0.4
			)
		else
			plsr.Blips:Remove("chopping_private")
		end

		if hasValue(plsr.State.character.States or {}, "ACCESS_LSUNDERGROUND") then
			_blips.private = plsr.Blips:Add(
				"chopping_personal",
				"LSUNDG Personal Dropoff",
				GlobalState["PersonalDropoff"].coords,
				524,
				43,
				0.4
			)
		else
			plsr.Blips:Remove("chopping_personal")
		end
	end,
	AttemptChop = function(self)
		if _validBone ~= nil and _validVeh ~= nil then
			if _validBone?.type == "door" then
				if not IsVehicleDoorDamaged(_validVeh, _validBone?.index) then
					_delay = true
					PedFaceCoord(PlayerPedId(), _validBone?.coords)
					plsr.NetSync:SetVehicleDoorOpen(_validVeh, _validBone?.index, false, true)
					plsr.Progress:ProgressWithTickEvent({
						name = "chopping_action",
						duration = _validBone?.duration,
						label = "Removing Part",
						useWhileDead = true,
						canCancel = true,
						ignoreModifier = true,
						tickrate = 100,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						},
						animation = {
							task = "WORLD_HUMAN_WELDING",
						},
					}, function()
						if _validVeh == nil or _validBone == nil then
							plsr.Progress:Cancel()
						end
					end, function(status)
						if not status then
							plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:ChopPart", {
								vNet = VehToNet(_validVeh),
								index = _validBone?.index,
							}, function(c) end)
						else
							plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:CancelChop")
							plsr.NetSync:SetVehicleDoorShut(_validVeh, _validBone?.index, true)
						end

						SetTimeout(1500, function()
							_delay = false
						end)
					end)
				end
			elseif _validBone?.type == "tire" then
				if not IsVehicleTyreBurst(_validVeh, _validBone?.index) then
					_delay = true
					PedFaceCoord(PlayerPedId(), _validBone?.coords)
					plsr.Progress:ProgressWithTickEvent({
						name = "chopping_action",
						duration = _validBone?.duration,
						label = "Removing Part",
						useWhileDead = true,
						canCancel = true,
						ignoreModifier = true,
						tickrate = 100,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						},
						animation = {
							animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
							anim = "machinic_loop_mechandplayer",
							flags = 1,
						},
					}, function()
						if _validVeh == nil or _validBone == nil then
							plsr.Progress:Cancel()
						end
					end, function(status)
						if not status then
							plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:ChopTire", {
								vNet = VehToNet(_validVeh),
								index = _validBone?.index,
							}, function(r)
								if r then
									SetTyreHealth(_validVeh, _validBone?.index, true, 0)
									SetVehicleTyreBurst(_validVeh, _validBone?.index, true, 1000)
									plsr.NetSync:SetVehicleTyreBurst(_validVeh, _validBone?.index, true, 1000)
								end
							end)
						else
							plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:CancelChop")
						end
						SetTimeout(1500, function()
							_delay = false
						end)
					end)
				end
			elseif _validBone?.type == "body" then
				if DoesEntityExist(_validVeh) then
					_delay = true
					PedFaceCoord(PlayerPedId(), _validBone?.coords)
					plsr.Progress:ProgressWithTickEvent({
						name = "chopping_action",
						duration = _validBone?.duration,
						label = "Scrapping Vehicle",
						useWhileDead = true,
						canCancel = true,
						ignoreModifier = true,
						tickrate = 100,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						},
						animation = {
							animDict = "mini@repair",
							anim = "fixing_a_ped",
							flags = 17,
						},
					}, function()
						if _validVeh == nil or _validBone == nil then
							plsr.Progress:Cancel()
						end
					end, function(status)
						if not status then
							plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:ChopVehicle", {
								vNet = VehToNet(_validVeh),
							}, function(r)
								-- if r then
								-- 	NetSync:DeleteVehicle(_validVeh)
								-- end
							end)
						else
							plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:CancelChop")
						end
						SetTimeout(1500, function()
							_delay = false
						end)
					end)
				end
			end
		end
	end,
}

function DoChoppingThings(veh)
	local bones = GetValidBones(veh, config.vehBones)

	CreateThread(function()
		while plsr.State.flags.chopping ~= nil and DoesEntityExist(NetToVeh(plsr.State.flags.chopping)) do
			Wait(100)
		end
		plsr.State.flags.chopping = nil
	end)

	CreateThread(function()
		while plsr.State.flags.inChopZone ~= nil and plsr.State.flags.chopping ~= nil do
			bones = GetValidBones(veh, config.vehBones)
			Wait(100)
		end
	end)

	CreateThread(function()
		local keyBind = plsr.Keybinds:GetKey("primary_action")
		local chopMessage = string.format("Press ~w~~r~[%s]~w~ to Chop Vehicle Part", keyBind)
		local chopMessage = string.format("Press ~w~~r~[%s]~w~ to Scrap Vehicle", keyBind)

		while plsr.State.flags.loggedIn and not plsr.State.flags.isDead and plsr.State.flags.inChopZone ~= nil and plsr.State.flags.chopping ~= nil do
			local bone, coords, distance = GetClosestBone(veh, bones)

			if not IsPedInAnyVehicle(PlayerPedId()) and distance and distance <= 30.0 then
				local inDistance, text = false, nil

				if bone.type ~= "body" and distance <= bone.distance then
					inDistance, text = true, chopMessage
				elseif bone.type == "body" and distance <= 18.0 then
					inDistance, text = true, chopMessage
				end

				if inDistance then
					if not plsr.State.flags.doingAction and not _delay then
						Draw3DText(coords.x, coords.y, coords.z, text)
					end
					_validBone = {
						label = bone.label,
						index = bone.index,
						duration = bone.duration,
						type = bone.type,
						coords = coords,
						distance = distance,
					}
					_validVeh = veh
					Wait(1)
				else
					_validBone = nil
					if not _delay then
						_validVeh = nil
					end
					Wait(10)
				end
			else
				_validBone = nil
				if not _delay then
					_validVeh = nil
				end
				Wait(250)
			end
		end

		_validBone = nil
		_validVeh = nil
	end)
end

function GetValidBones(entity, list)
	local bones = {}

	for _, bone in ipairs(list) do
		local bId = GetEntityBoneIndexByName(entity, bone.name)
		if bId ~= -1 then
			if
				bone.type == "door" and not IsVehicleDoorDamaged(entity, bone.index)
				or bone.type == "tire" and not IsVehicleTyreBurst(entity, bone.index, 1)
			then
				bone.id = bId
				table.insert(bones, bone)
			end
		end
	end

	return bones
end

function GetClosestBone(entity, list)
	local playerCoords, bone, coords, distance = GetEntityCoords(PlayerPedId())

	for _, element in pairs(list) do
		local boneCoords = GetWorldPositionOfEntityBone(entity, element.id or element)
		local boneDistance = #(playerCoords - boneCoords)

		if not coords then
			bone, coords, distance = element, boneCoords, boneDistance
		elseif distance > boneDistance then
			bone, coords, distance = element, boneCoords, boneDistance
		end
	end

	if not bone then
		bone = {
			id = GetEntityBoneIndexByName(entity, "bodyshell"),
			type = "body",
			name = "bodyshell",
			duration = 20000,
		}
		coords = GetEntityCoords(entity)
		distance = #(coords - playerCoords)
	end

	return bone, coords, distance
end

RegisterNetEvent("Ped:Client:Died", function()
	if plsr.State.flags.chopping ~= nil then
		plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:CancelChop")
		plsr.State.flags.chopping = nil
		_validBone = nil
		_validVeh = nil
	end
end)

RegisterNetEvent('Laptop:Client:LSUnderground:Chopping:CancelCurrent', function()
	if plsr.State.flags.inChopZone ~= nil and plsr.State.flags.chopping ~= nil then
		if _delay then
			plsr.Notification:Error("Choplist Has Refreshed")
			plsr.Progress:Cancel()
		end
		plsr.State.flags.chopping = nil
		_validBone = nil
		_validVeh = nil
	end
end)

AddEventHandler("Characters:Client:Updated", function(key)
	if key == "Reputations" or key == "States" then
		plsr.Laptop.LSUnderground.Chopping:CreateBlips()
	end
end)

function TableLength(tbl)
	local cnt = 0
	for k, v in pairs(tbl) do
		cnt += 1
	end
	return cnt
end

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if
		(id == "chopping_public" and plsr.Reputation:HasLevel("Salvaging", 7))
		or (id == "chopping_private" and plsr.State.flags.loggedIn and (
			plsr.Reputation:HasLevel("Chopping", 5) or
			hasValue(plsr.State.character.States, "ACCESS_LSUNDERGROUND")
		))
		or (id == "chopping_personal"
			and hasValue(plsr.State.character.States, "ACCESS_LSUNDERGROUND")
			and (
				plsr.State.character.ChopLists ~= nil
				and TableLength(plsr.State.character.ChopLists) > 0
			)
		)
	then
		plsr.State.flags.inChopZone = id
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if id == "chopping_public" or id == "chopping_private" or id == "chopping_personal" then
		if plsr.State.flags.chopping ~= nil then
			plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:CancelChop")
		end
		if plsr.State.flags.inChopZone ~= nil then
			plsr.State.flags.inChopZone = nil
		end
		if plsr.State.flags.chopping ~= nil then
			plsr.State.flags.chopping = nil
		end
	end
end)

AddEventHandler("Keybinds:Client:KeyUp:primary_action", function()
	if
		plsr.State.flags.inChopZone ~= nil
		and not plsr.State.flags.isDead
		and plsr.State.flags.chopping
		and _validBone ~= nil
		and not plsr.State.flags.doingAction
		and not _delay
	then
		_doingActions = true
		plsr.Laptop.LSUnderground.Chopping:AttemptChop()
		_doingActions = false
	end
end)

AddEventHandler("Laptop:Client:LSUnderground:Chopping:Pickup", function()
	plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:Pickup")
end)

AddEventHandler("Laptop:Client:LSUnderground:Chopping:GetPublicList", function()
	plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:GetPublicList")
end)

AddEventHandler("Laptop:Client:LSUnderground:Chopping:StartChop", function(entity, data)
	if
		not plsr.State.flags.isDead
		and plsr.State.flags.inChopZone ~= nil
		and not plsr.State.flags.chopping
	then
		local vNet = VehToNet(entity.entity)
		plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Chopping:CheckVehicle", { vNet = vNet }, function(res)
			if res then
				while not NetworkHasControlOfEntity(entity.entity) do
					NetworkRequestControlOfEntity(entity.entity)
					Wait(1)
				end
				plsr.State.flags.chopping = vNet
				DoChoppingThings(entity.entity)
			else
				plsr.State.flags.chopping = nil
			end
		end)
	end
end)
