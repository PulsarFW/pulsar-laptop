local config = load(LoadResourceFile(GetCurrentResourceName(), "config/shared.lua"))().lsu.boosting

local wasBoosting = false
local trackerThread = false
local trackerTimer = nil

_boosting = nil

RegisterNetEvent("Characters:Client:Logout")
AddEventHandler("Characters:Client:Logout", function()
    _boosting = nil
    wasBoosting = false
end)

RegisterNetEvent("Characters:Client:Spawn")
AddEventHandler("Characters:Client:Spawn", function()
    Wait(1000)
    plsr.Hud:RegisterStatus("boosting-timer", 0, 100, "timer", "#892020", false, false, {
        hideZero = true,
    })
end)

RegisterNetEvent("Laptop:Client:LSUnderground:Boosting:Start", function(data)
    _boosting = data
    wasBoosting = true
    trackerThread = false

    if _boosting then
        if _boosting.pickUp then
            plsr.Blips:Add(
                "boosting-contract",
                "[Contract]: Target Vehicle",
                _boosting.pickUp,
                523,
                17,
                1.1,
                2,
                false,
                false
            )
    
            ClearGpsPlayerWaypoint()
            SetNewWaypoint(_boosting.pickUp.x, _boosting.pickUp.y)
        end

        plsr.Polyzone.Create:Circle("boosting-dropoff", _boosting.dropOff, 30.0, {})
    end
end)

RegisterNetEvent("Laptop:Client:LSUnderground:Boosting:UpdateState", function(state, data)
    if not _boosting then return; end

    print("Update Boosting State: ", state)

    _boosting.state = state

    if state == 1 then
        plsr.Blips:Remove("boosting-contract")
    elseif state == 2 then

        if data then
            _boosting.trackerDelay = data.trackerDelay
            _boosting.trackerCount = data.trackerCount
        end

        if not trackerThread then
            trackerThread = true
            CreateThread(function()
                while _boosting and _boosting.state == 2 and plsr.State.flags.loggedIn do
                    if NetworkDoesEntityExistWithNetworkId(_boosting.vehicleNet) then
                        local veh = NetToVeh(_boosting.vehicleNet)
                        if veh == GetVehiclePedIsIn(PlayerPedId(), false) then
                            plsr.UISounds.Play:FrontEnd(-1, "5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET")
                        end
                    end
    
                    Wait(7000 + (_boosting.trackerDelay * 1000))
                end
            end)
        end
    elseif state == 3 and _boosting.dropOff then
        plsr.Notification.Persistent:Remove("boosting-trackers")
        plsr.Blips:Add(
            "boosting-contract",
            "[Contract]: Dropoff Location",
            _boosting.dropOff,
            523,
            6,
            1.1,
            2,
            false,
            false
        )

        ClearGpsPlayerWaypoint()
        SetNewWaypoint(_boosting.dropOff.x, _boosting.dropOff.y)
        TriggerEvent("Status:Client:Update", "boosting-timer", 0)
    end
end)

RegisterNetEvent("Laptop:Client:LSUnderground:Boosting:TrackerNotificationUpdate", function(notif)
    plsr.Notification.Persistent:Info("boosting-trackers", notif)
end)

AddEventHandler("Laptop:Client:LSUnderground:Boosting:AttemptExterior", function(veh)
    if _boosting and NetworkDoesEntityExistWithNetworkId(_boosting.vehicleNet) then
        if veh == NetToVeh(_boosting.vehicleNet) then
            plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Boosting:Exterior", {}, function(numPeds, makeDifficult, noAlert)
                if numPeds then
                    --numPeds = 0
                    local availableWeapons = config.weaponsForClass[_boosting.vehicleData?.class or "D"]

                    CreateThread(function()
                        for i = 1, numPeds do
                            local model = config.pedModels[math.random(#config.pedModels)]
                            local spawn = _boosting.pedSpawns[#_boosting.pedSpawns]
    
                            -- Requesting model
                            RequestModel(model)
                            while not HasModelLoaded(model) do
                                Wait(5)
                            end
                            SetModelAsNoLongerNeeded(model)
    
                            local ped = CreatePed(5, model, spawn.x, spawn.y, spawn.z, spawn.w, true, true)
                            while not DoesEntityExist(ped) do
                                Wait(1)
                            end
    
                            plsr.State.Entity(ped).crimePed = true
    
                            local w = plsr.Utils:WeightedRandom(availableWeapons)
                            GiveWeaponToPed(ped, w, 99999, false, true)
                            SetCurrentPedWeapon(ped, w, true)
    
                            SetEntityMaxHealth(ped, makeDifficult and 250 or 150)
                            SetEntityHealth(ped, makeDifficult and 250 or 150)
                            if makeDifficult then
                                SetPedArmour(ped, 150)
                            end
    
                            DecorSetBool(ped, 'ScriptedPed', true)
                            SetEntityAsMissionEntity(ped, 1, 1)
    
                            SetPedRelationshipGroupDefaultHash(ped, `BOBCAT_SECURITY`)
                            SetPedRelationshipGroupHash(ped, `BOBCAT_SECURITY`)
                            SetPedRelationshipGroupHash(ped, `HATES_PLAYER`)
                            SetCanAttackFriendly(ped, false, true)
                            SetPedAsCop(ped)
    
                            TaskTurnPedToFaceEntity(ped, PlayerPedId(), 1.0)
    
                            SetPedCombatMovement(ped, 2)
                            SetPedCombatRange(ped, 0)
                            SetPedCombatAttributes(ped, 46, 1)
                            SetPedCombatAttributes(ped, 292, 1)
                            SetPedCombatAttributes(ped, 5000, 1)
                            SetPedFleeAttributes(ped, 0, 0)
                            SetPedAsEnemy(ped, true)
    
                            SetPedSeeingRange(ped, 100.0)
                            SetPedHearingRange(ped, 100.0)
                            SetPedAlertness(ped, 3)
    
                            TaskCombatHatedTargetsAroundPed(ped, 100.0, 0)
    
                            local _, cur = GetCurrentPedWeapon(ped, true)
                            SetPedInfiniteAmmo(ped, true, cur)
                            SetPedDropsWeaponsWhenDead(ped, false)

                            if i <= (numPeds / 2) then
                                Wait(3000)
                            else
                                Wait(math.random(10, 35) * 1000)
                            end
                        end
                    end)
                end


                local plate = GetVehicleNumberPlateText(veh)
                local isTracked = _boosting.trackerTotal and _boosting.trackerTotal > 0
                local r, g, b = GetVehicleCustomPrimaryColour(veh)

                if not noAlert then
                    TriggerServerEvent('Radar:Server:StolenVehicle', plate)
                    TriggerServerEvent("EmergencyAlerts:Server:DoPredefined", isTracked and "boostingTracked" or "boosting", {
                        icon = "car",
                        details = _boosting.vehicleData.label,
                        vehicleColor = {
                            r = r,
                            g = g,
                            b = b,
                        },
                        vehiclePlate = plate,
                        vehicleClass = _boosting.vehicleData.class,
                    })
                end
            end)
        end
    end
end)

AddEventHandler("Laptop:Client:LSUnderground:Boosting:SuccessIgnition", function(veh)
    if _boosting and NetworkDoesEntityExistWithNetworkId(_boosting.vehicleNet) then
        if veh == NetToVeh(_boosting.vehicleNet) then
            local coords = GetEntityCoords(PlayerPedId())
            local main, cross = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
            plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Boosting:Ignition", {
                location = string.format("%s - %s", GetStreetNameFromHashKey(main), GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z)))
            }, function()
                
            end)
        end
    end
end)

function BoostingTrackerCooldown()
    trackerTimer = GetGameTimer() + 30000

    CreateThread(function()
        while _boosting and trackerTimer > GetGameTimer() do

            local time = math.floor((trackerTimer - GetGameTimer()) / 1000)
            local percent = math.floor((time / 30) * 100)

            TriggerEvent("Status:Client:Update", "boosting-timer", percent)
            Wait(500)
        end

        TriggerEvent("Status:Client:Update", "boosting-timer", 0)
    end)
end

function RegisterBoostingCallbacks()
    plsr.Callbacks:RegisterClientCallback("Laptop:LSUnderground:Boosting:TrackerHacker", function(data, cb)
        local hackData = config.trackerHacks[_boosting?.vehicleData?.class or "B"]
        if not hackData then
            hackData = config.trackerHacks.B
        end

        
        if _boosting and (not trackerTimer or GetGameTimer() >= trackerTimer) and hackData and NetworkDoesEntityExistWithNetworkId(_boosting.vehicleNet) then
            local veh = NetToVeh(_boosting.vehicleNet)

            if GetEntitySpeed(veh) >= 15.0 and GetPedInVehicleSeat(veh, 0) == PlayerPedId() then
                plsr.Minigame.Play:Pattern(
                    3,
                    hackData.duration,
                    hackData.rows,
                    math.random(hackData.lengthMin, hackData.lengthMax),
                    hackData.charSize,
                    plsr.Utils:WeightedRandom(hackData.charSet), {
                    onSuccess = function()
                        BoostingTrackerCooldown()
                        cb(true, true)
                    end,
                    onFail = function()
                        BoostingTrackerCooldown()
                        cb(true, false)
                    end,
                }, {
                    useWhileDead = false,
                    vehicle = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                    animation = {
                        animDict = "veh@break_in@0h@p_m_one@",
                        anim = "low_force_entry_ds",
                        flags = 16,
                    },
                })
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end

local inZone = false
AddEventHandler("Polyzone:Enter", function(id)
    if id == "boosting-dropoff" then
        inZone = true
    end
end)

AddEventHandler("Polyzone:Exit", function(id)
    if id == "boosting-dropoff" and inZone then
        inZone = false
        if _boosting and _boosting.state == 4 then
            plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Boosting:LeftArea", {})
        end
    end
end)

AddEventHandler("Vehicles:Client:ExitVehicle", function(veh)
    if not _boosting then return; end

    if 
        _boosting.state == 3 
        and inZone 
        and NetworkDoesEntityExistWithNetworkId(_boosting.vehicleNet) 
        and veh == NetToVeh(_boosting.vehicleNet)
        and not CheckPDInZone(_boosting.dropOff, 60.0)
    then
        plsr.Callbacks:ServerCallback("Laptop:LSUnderground:Boosting:DropOff", {})
    end
end)

function CleanUpBoosting()
    if _boosting then
        _boosting = nil

        plsr.Polyzone:Remove("boosting-dropoff")
        plsr.Blips:Remove("boosting-contract")

        TriggerEvent("Status:Client:Update", "boosting-timer", 0)
        plsr.Notification.Persistent:Remove("boosting-trackers")
    end
end

RegisterNetEvent("Laptop:Client:LSUnderground:Boosting:End", function(cancelled)
    CleanUpBoosting()
end)

RegisterNetEvent("Laptop:Client:Teams:Set", function(teamData)
    if not teamData and wasBoosting then
        plsr.Laptop.Notification:Remove("BOOSTING_CONTRACT")

        CleanUpBoosting()
    end
end)