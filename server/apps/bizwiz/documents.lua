LAPTOP.BizWiz = LAPTOP.BizWiz or {}

local _documentsTableReady = false
local function ensureDocumentsTable(callback)
	if _documentsTableReady then
		if callback then
			callback()
		end
		return
	end
	plsr.Database:Query(
		"CREATE TABLE IF NOT EXISTS `business_documents` (`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, `job` VARCHAR(191) NOT NULL, `data` JSON NOT NULL, INDEX `idx_job` (`job`))",
		nil,
		function()
			_documentsTableReady = true
			if callback then
				callback()
			end
		end
	)
end

LAPTOP.BizWiz.Documents = {
	Search = function(self, jobId, term)
        if not term then term = '' end
		local p = promise.new()
		local like = "%" .. term .. "%"

		ensureDocumentsTable(function()
			plsr.Database:Query(
				"SELECT `id`, `data` FROM `business_documents` WHERE `job` = ? AND (JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.title')) LIKE ? OR CONCAT(JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.author.First')), ' ', JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.author.Last')), ' ', JSON_UNQUOTE(JSON_EXTRACT(`data`, '$.author.SID'))) LIKE ?)",
				{ jobId, like, like },
				function(success, results)
					if not success then
						p:resolve(false)
						return
					end
					local documents = {}
					for k, row in ipairs(results) do
						local ok, decoded = pcall(json.decode, row.data)
						if ok and type(decoded) == "table" then
							decoded._id = row.id
							table.insert(documents, decoded)
						end
					end
					p:resolve(documents)
				end
			)
		end)
		return Citizen.Await(p)
	end,
	View = function(self, jobId, id)
		local p = promise.new()
		ensureDocumentsTable(function()
			plsr.Database:Single("SELECT `id`, `data` FROM `business_documents` WHERE `job` = ? AND `id` = ?", { jobId, id }, function(success, row)
				if not success or row == nil then
					p:resolve(false)
					return
				end
				local ok, decoded = pcall(json.decode, row.data)
				if ok and type(decoded) == "table" then
					decoded._id = row.id
					p:resolve(decoded)
				else
					p:resolve(false)
				end
			end)
		end)
		return Citizen.Await(p)
	end,
	Create = function(self, jobId, data)
		local p = promise.new()
        data.job = jobId
		ensureDocumentsTable(function()
			plsr.Database:Insert("INSERT INTO `business_documents` (`job`, `data`) VALUES (?, ?)", { jobId, json.encode(data) }, function(success, newId)
				if not success then
					p:resolve(false)
					return
				end
				p:resolve({ _id = newId })
			end)
		end)

		return Citizen.Await(p)
	end,
	Update = function(self, jobId, id, char, report)
		local p = promise.new()
		ensureDocumentsTable(function()
			plsr.Database:Single("SELECT `data` FROM `business_documents` WHERE `id` = ? AND `job` = ?", { id, jobId }, function(success, row)
				if not success or row == nil then
					p:resolve(false)
					return
				end

				local ok, existing = pcall(json.decode, row.data)
				if not ok or type(existing) ~= "table" then
					existing = {}
				end

				for k, v in pairs(report) do
					existing[k] = v
				end

				if not existing.history then
					existing.history = {}
				end
				table.insert(existing.history, {
					Time = (os.time() * 1000),
					Char = char:GetData("SID"),
					Log = string.format("%s Updated Report", char:GetData("First") .. " " .. char:GetData("Last")),
				})

				plsr.Database:Update("UPDATE `business_documents` SET `data` = ? WHERE `id` = ?", { json.encode(existing), id }, function(updateSuccess)
					p:resolve(updateSuccess)
				end)
			end)
		end)
		return Citizen.Await(p)
	end,
    Delete = function(self, jobId, id)
        local p = promise.new()
		ensureDocumentsTable(function()
			plsr.Database:Update("DELETE FROM `business_documents` WHERE `id` = ? AND `job` = ?", { id, jobId }, function(success)
				p:resolve(success)
			end)
		end)
		return Citizen.Await(p)
    end,
}

AddEventHandler("Laptop:Server:RegisterCallbacks", function()
    plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:Document:Search", function(source, data, cb)
        local job = CheckBusinessPermissions(source, 'TABLET_VIEW_DOCUMENT')
		if job then
			cb(plsr.Laptop.BizWiz.Documents:Search(job, data.term))
		else
			cb(false)
		end
    end)

    plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:Document:Create", function(source, data, cb)
        local char = plsr.Fetch:CharacterSource(source)
        local job = CheckBusinessPermissions(source, 'TABLET_CREATE_DOCUMENT')
		if job then
			data.doc.author = {
				SID = char:GetData("SID"),
				First = char:GetData("First"),
				Last = char:GetData("Last"),
			}
			cb(plsr.Laptop.BizWiz.Documents:Create(job, data.doc))
        else
            cb(false)
        end
    end)

    plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:Document:Update", function(source, data, cb)
        local char = plsr.Fetch:CharacterSource(source)
        local job = CheckBusinessPermissions(source, 'TABLET_CREATE_DOCUMENT')
		if char and job then
            data.Report.lastUpdated = {
                Time = (os.time() * 1000),
                SID = char:GetData("SID"),
                First = char:GetData("First"),
                Last = char:GetData("Last"),
            }
			cb(plsr.Laptop.BizWiz.Documents:Update(job, data.id, char, data.Report))
        else
            cb(false)
        end
    end)

    plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:Document:Delete", function(source, data, cb)
        local job = CheckBusinessPermissions(source, 'TABLET_DELETE_DOCUMENT')
		if job then
			cb(plsr.Laptop.BizWiz.Documents:Delete(job, data.id))
        else
            cb(false)
        end
    end)

    plsr.Callbacks:RegisterServerCallback("Laptop:BizWiz:Document:View", function(source, data, cb)
        local job = CheckBusinessPermissions(source, 'TABLET_VIEW_DOCUMENT')
		if job then
			cb(plsr.Laptop.BizWiz.Documents:View(job, data))
        else
			cb(false)
		end
    end)
end)
