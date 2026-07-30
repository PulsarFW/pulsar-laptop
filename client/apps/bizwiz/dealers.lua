RegisterNUICallback("PDMGetDealerData", function(data, cb)
	plsr.Callbacks:ServerCallback("Dealerships:GetDealershipData", { dealerId = plsr.State.flags.onDuty }, cb)
end)

RegisterNUICallback("PDMSaveDealerData", function(data, cb)
	plsr.Callbacks:ServerCallback("Dealerships:UpdateDealershipData", {
		dealerId = plsr.State.flags.onDuty,
		updating = data.data,
	}, cb)
end)

RegisterNUICallback("PDMGetStock", function(data, cb)
	plsr.Callbacks:ServerCallback(
		"Dealerships:Sales:FetchData",
		plsr.State.flags.onDuty,
		function(authed, stocks, defaultInterestRate, dealerData)
			if authed then
				cb({
					stock = stocks,
					dealerData = dealerData,
					interest = defaultInterestRate,
				})
			else
				cb(false)
			end
		end
	)
end)

RegisterNUICallback("DealershipStartTestDrive", function(data, cb)
	plsr.Callbacks:ServerCallback("Dealerships:Sales:TestDrive", {
		dealership = plsr.State.flags.onDuty,
		data = {
			vehicle = data.vehicle,
			modelType = data.modelType,
		},
	}, function(success, message)
		cb({
			success = success,
			message = message,
		})
	end)
end)

RegisterNUICallback("PDMRunCredit", function(data, cb)
	plsr.Callbacks:ServerCallback(
		"Dealerships:CheckPersonsCredit",
		{ dealerId = plsr.State.flags.onDuty, SID = data.term },
		cb
	)
end)

RegisterNUICallback("PDMStartSale", function(data, cb)
	plsr.Callbacks:ServerCallback("Dealerships:Sales:StartSale", {
		dealership = plsr.State.flags.onDuty,
		type = data.type,
		data = {
			vehicle = data.vehicle,
			customer = data.SID,
			downPayment = data.downpayment,
			loanWeeks = data.weeks,
		},
	}, function(success, message)
		cb({
			success = success,
			message = message,
		})
	end)
end)

RegisterNUICallback("PDMGetHistory", function(data, cb)
	plsr.Callbacks:ServerCallback("Dealerships:FetchHistory", {
		dealership = plsr.State.flags.onDuty,
		term = data.value,
		category = data.category,
		page = data.page,
	}, function(penis)
		if penis then
			cb(penis)
		else
			cb(false)
		end
	end)
end)

RegisterNUICallback("PDMGetOwner", function(data, cb)
	plsr.Callbacks:ServerCallback(
		"Dealerships:FetchCurrentOwner",
		{ dealerId = plsr.State.flags.onDuty, VIN = data.VIN },
		function(penis)
			if penis then
				cb(penis)
			else
				cb(false)
			end
		end
	)
end)
