RegisterNetEvent("Laptop:Client:SetData", function(type, data, options)
	plsr.Laptop.Data:Set(type, data)
end)

RegisterNetEvent("Laptop:Client:AddData", function(type, data, id)
	plsr.Laptop.Data:Add(type, data, id)
end)

RegisterNetEvent("Laptop:Client:UpdateData", function(type, id, data)
	plsr.Laptop.Data:Update(type, id, data)
end)

RegisterNetEvent("Laptop:Client:RemoveData", function(type, id)
	plsr.Laptop.Data:Remove(type, id)
end)

RegisterNetEvent("Laptop:Client:ResetData", function()
	plsr.Laptop.Data:Reset()
end)

RegisterNetEvent("Characters:Client:Logout", function()
	SendNUIMessage({ type = "LAPTOP_NOT_VISIBLE" })
	plsr.Laptop.Data:Reset()
	plsr.Laptop.Notification:Reset()
	plsr.Laptop:ResetRoute()
	SendNUIMessage({ type = "CLOSE_ALL_APPS" })
end)
