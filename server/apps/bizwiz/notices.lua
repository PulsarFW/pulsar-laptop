local _noticesTableReady = false
function EnsureNoticesTable(callback)
	if _noticesTableReady then
		if callback then
			callback()
		end
		return
	end
	plsr.Database:Query(
		"CREATE TABLE IF NOT EXISTS `business_notices` (`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, `job` VARCHAR(191) NOT NULL, `data` JSON NOT NULL, INDEX `idx_job` (`job`))",
		nil,
		function()
			_noticesTableReady = true
			if callback then
				callback()
			end
		end
	)
end

AddEventHandler("Laptop:Server:RegisterCallbacks", function()
	EnsureNoticesTable(function()
		plsr.Database:Query("SELECT `id`, `data` FROM `business_notices`", nil, function(success, results)
			if not success then
				return
			end

			local notices = {}
			for k, row in ipairs(results) do
				local ok, decoded = pcall(json.decode, row.data)
				if ok and type(decoded) == "table" then
					decoded._id = row.id
					table.insert(notices, decoded)
				end
			end

			plsr.Logger:Trace("Laptop", "[BizWiz] Loaded ^2" .. #notices .. "^7 Business Notices", { console = true })
			_businessNotices = notices
		end)
	end)

	plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:Notice:Create", function(source, data, cb)
		local job = CheckBusinessPermissions(source, "TABLET_CREATE_NOTICE")
		if job then
			cb(plsr.Laptop.BizWiz.Notices:Create(source, job, data.doc))
		else
			cb(false)
		end
	end)

	plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:Notice:Delete", function(source, data, cb)
		local job = CheckBusinessPermissions(source, "TABLET_DELETE_NOTICE")
		if job then
			cb(plsr.Laptop.BizWiz.Notices:Delete(job, data.id))
		else
			cb(false)
		end
	end)
end)

LAPTOP.BizWiz = LAPTOP.BizWiz or {}
LAPTOP.BizWiz.Notices = {
	Create = function(self, source, job, data)
		local char = plsr.Fetch:CharacterSource(source)
		if char then
			local p = promise.new()

			data.job = job
			data.author = {
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
			}

			EnsureNoticesTable(function()
				plsr.Database:Insert("INSERT INTO `business_notices` (`job`, `data`) VALUES (?, ?)", { job, json.encode(data) }, function(success, newId)
					if not success then
						p:resolve(false)
						return
					end

					data._id = newId
					table.insert(_businessNotices, data)

					local jobDutyData = plsr.Jobs.Duty:GetDutyData(job)
					if jobDutyData and jobDutyData.DutyPlayers then
						for k, v in ipairs(jobDutyData.DutyPlayers) do
							TriggerClientEvent("Laptop:Client:AddData", v, "businessNotices", data)
						end
					end

					p:resolve(newId)
				end)
			end)
			return Citizen.Await(p)
		end
		return false
	end,
	Delete = function(self, job, id)
		local p = promise.new()
		EnsureNoticesTable(function()
			plsr.Database:Update("DELETE FROM `business_notices` WHERE `id` = ? AND `job` = ?", { id, job }, function(success)
				if not success then
					p:resolve(false)
					return
				end

				for k, v in ipairs(_businessNotices) do
					if v._id == id then
						table.remove(_businessNotices, k)
						break
					end
				end

				local jobDutyData = plsr.Jobs.Duty:GetDutyData(job)
				if jobDutyData and jobDutyData.DutyPlayers then
					for k, v in ipairs(jobDutyData.DutyPlayers) do
						TriggerClientEvent("Laptop:Client:RemoveData", v, "businessNotices", id)
					end
				end

				p:resolve(true)
			end)
		end)
		return Citizen.Await(p)
	end,
}
