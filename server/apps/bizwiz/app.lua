local config = load(LoadResourceFile(GetCurrentResourceName(), "config/server.lua"))()

local bizWizJobs = {}

function CheckBusinessPermissions(source, permission)
    local onDuty = plsr.Jobs.Duty:Get(source)
	if onDuty and onDuty.Id and bizWizJobs[onDuty.Id] then
		if (not permission) or plsr.Jobs.Permissions:HasPermissionInJob(source, onDuty.Id, permission) then
			return onDuty.Id
		end
	end
	return false
end

AddEventHandler('Job:Server:DutyAdd', function(dutyData, source)
	local job = plsr.Jobs.Permissions:HasJob(source, dutyData.Id)
	if job then
		local hasConfig = config.bizwiz.businesses[job.Id]
		local bizWiz = plsr.Jobs.Data:Get(job.Id, "bizWiz")

		if hasConfig then
			bizWiz = hasConfig.type
		end

		if job and bizWiz and config.bizwiz.types[bizWiz] then
			local bizWizLogo = plsr.Jobs.Data:Get(job.Id, "bizWizLogo")

			if not bizWizLogo and hasConfig then
				bizWizLogo = hasConfig.logo
			end

			bizWizJobs[job.Id] = true

			plsr.Laptop:UpdateJobData(source)
			TriggerClientEvent("Laptop:Client:BizWiz:Login", source, bizWizLogo or "https://changeme.com/logo.png", config.bizwiz.types[bizWiz], GetBusinessNotices(job.Id))
		end
	end
end)

AddEventHandler('Job:Server:DutyRemove', function(dutyData, source, SID)
    if bizWizJobs[dutyData.Id] then
		TriggerClientEvent("Laptop:Client:BizWiz:Logout", source)
	end
end)

function GetBusinessNotices(job)
	local notices = {}
	for k, v in ipairs(_businessNotices) do
		if v.job == job then
			table.insert(notices, v)
		end
	end

	return notices
end

AddEventHandler("Laptop:Server:RegisterCallbacks", function()
  plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:EmployeeSearch", function(source, data, cb)
    local job = CheckBusinessPermissions(source)
		if job then
			local like = "%" .. (data.term or "") .. "%"
			plsr.Database:Query(
				"SELECT `sid`, `data` FROM `characters` WHERE `deleted` = 0 AND JSON_CONTAINS(JSON_EXTRACT(`data`, '$.Jobs'), JSON_OBJECT('Id', ?), '$') AND (CONCAT(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.First')), ' ', JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.Last'))) LIKE ? OR `sid` LIKE ?) LIMIT 4",
				{ job, like, like },
				function(success, results)
					if not success then
						cb({})
						return
					end

					local employees = {}
					for k, row in ipairs(results) do
						local ok, v = pcall(json.decode, row.data)
						if ok and type(v) == "table" then
							table.insert(employees, { SID = row.sid, First = v.First, Last = v.Last })
						end
					end
					cb(employees)
				end
			)
		else
			cb(false)
		end
	end)

	plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:GetTwitterProfile", function(source, data, cb)
    local job = CheckBusinessPermissions(source, "JOB_MANAGEMENT")
		if job then
			cb({
				success = true,
				pfp = plsr.Jobs.Data:Get(job, "TwitterAvatar")
			})
		else
			cb(false)
		end
	end)

	plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:SetTwitterProfile", function(source, data, cb)
    local job = CheckBusinessPermissions(source, "JOB_MANAGEMENT")
		if job then
			local success = plsr.Jobs.Data:Set(job, "TwitterAvatar", data.profile)
			if success then
				cb(data.profile)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:SendTweet", function(source, data, cb)
    local job = CheckBusinessPermissions(source, "TABLET_TWEET")
		if job then
			local jobData = plsr.Jobs:Get(job)
			local avatar = plsr.Jobs.Data:Get(job, "TwitterAvatar")
			
			plsr.Phone.Twitter:Post(
				-1, 
				-1, 
				{
					name = jobData.Name,
					picture = avatar,
				},
				data.content,
				data.image,
				false,
				"business"
			)

			cb(true)
		else
			cb(false)
		end
	end)

	plsr.Chat:RegisterAdminCommand("bizwizset", function(source, args, rawCommand)
		local setting = args[2]
		if setting == "false" then
			setting = false
		end

    local res = plsr.Jobs.Data:Set(args[1], "bizWiz", setting)

		if res?.success then
			plsr.Chat.Send.System:Single(source, "Success")
		else
			plsr.Chat.Send.System:Single(source, "Failed")
		end
	end, {
		help = "[Admin] Grant a Business Access to BizWiz App",
		params = {
			{
				name = "Job ID",
				help = "Job ID",
			},
			{
				name = "BizWiz Type",
				help = "e.g. default, mechanic (false to remove)",
			},
		}
	}, 2)

	plsr.Chat:RegisterAdminCommand("bizwizlogo", function(source, args, rawCommand)
		local setting = args[2]
		if setting == "false" then
			setting = false
		end

    local res = plsr.Jobs.Data:Set(args[1], "bizWizLogo", setting)

		if res?.success then
			plsr.Chat.Send.System:Single(source, "Success")
		else
			plsr.Chat.Send.System:Single(source, "Failed")
		end
	end, {
		help = "[Admin] Set BizWiz Logo",
		params = {
			{
				name = "Job ID",
				help = "Job ID",
			},
			{
				name = "BizWiz Logo Link (imgur)",
				help = "(false to remove)",
			},
		}
	}, 2)

	plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:ViewVehicleFleet", function(source, data, cb)
    local job = CheckBusinessPermissions(source, "FLEET_MANAGEMENT")
		if job then
			plsr.Vehicles.Owned:GetAll(nil, 1, job, function(vehicles)
        for k, v in ipairs(vehicles) do
          if v.Storage then
            if v.Storage.Type == 0 then
              v.Storage.Name = plsr.Vehicles.Garages:Impound().name
            elseif v.Storage.Type == 1 then
              v.Storage.Name = plsr.Vehicles.Garages:Get(v.Storage.Id).name
            elseif v.Storage.Type == 2 then
              local prop = plsr.Properties:Get(v.Storage.Id)
              v.Storage.Name = prop?.label
            end
          end
        end

        cb(vehicles)
      end)
		else
			cb(false)
		end
	end)

	plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:TrackFleetVehicle", function(source, data, cb)
    local job = CheckBusinessPermissions(source, "FLEET_MANAGEMENT")
		if job then
			cb(plsr.Vehicles.Owned:Track(data.vehicle))
		else
			cb(false)
		end
	end)
end)