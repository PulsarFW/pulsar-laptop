function RegisterChatCommands()
    plsr.Chat:RegisterAdminCommand("boostingevent", function(source, args, rawCommand)
        if _boostingEvent then
            _boostingEvent = false
            plsr.Chat.Send.System:Single(source, "Boosting Event Disabled")
        else
            _boostingEvent = true
            plsr.Chat.Send.System:Single(source, "Boosting Event Enabled")
        end
	end, {
		help = "[Admin] Toggle Boosting Event Mode",
	}, 0)

    plsr.Chat:RegisterAdminCommand("boostingevent2", function(source, args, rawCommand)
        local char = plsr.Fetch:SID(tonumber(args[1]))
        if char then
            local profiles = char:GetData("Profiles")
            if profiles?.redline then
                plsr.Chat.Send.System:Single(source, string.format("%s %s (%s) - Alias %s", char:GetData("First"), char:GetData("Last"), char:GetData("SID"), profiles.redline.name))
            end
        end
	end, {
		help = "[Admin] Get Racing Alias",
        params = {
			{
				name = "SID",
				help = "SID",
			},
		}
	}, 1)
end
