FAdmin = FAdmin or {}

FAdmin.PlayerActions = FAdmin.PlayerActions or {}
FAdmin.StartHooks = FAdmin.StartHooks or {}

/*

Utilities!

*/
function FAdmin.FindPlayer(info)
	if not info then return nil end
	local pls = player.GetAll()
	local found = {}

	if string.lower(info) == "*" or string.lower(info) == "<all>" then return pls end

	local InfoPlayers = {}
	for A in string.gmatch(info..";", "([a-zA-Z0-9:_.]*)[;(,%s)%c]") do
		if A ~= "" then table.insert(InfoPlayers, A) end
	end

	for _, PlayerInfo in pairs(InfoPlayers) do
		-- Playerinfo is always to be treated as UserID when it's a number
		-- otherwise people with numbers in their names could get confused with UserID's of other players
		if tonumber(PlayerInfo) then
			if IsValid(Player(PlayerInfo)) and not found[Player(PlayerInfo)] then
				found[Player(PlayerInfo)] = true
			end
			continue
		end

		for k, v in pairs(pls) do
			-- Find by Steam ID
			if (PlayerInfo == v:SteamID() or v:SteamID() == "UNKNOWN") and not found[v]  then
				found[v] = true
			end

			-- Find by Partial Nick
			if string.find(string.lower(v:Name()), string.lower(tostring(PlayerInfo)), 1, true) ~= nil and not found[v]  then
				found[v] = true
			end

			if v.SteamName and string.find(string.lower(v:SteamName()), string.lower(tostring(PlayerInfo)), 1, true) ~= nil and not found[v]  then
				found[v] = true
			end
		end
	end

	local players = {}
	local empty = true
	for k, v in pairs(found or {}) do
		empty = false
		table.insert(players, k)
	end
	return not empty and players or nil
end

function FAdmin.SteamToProfile(ply) -- Thanks decodaman
	return "http://steamcommunity.com/profiles/" .. (ply:SteamID64() or "BOT")
end

hook.Add("CanTool", "EntityCanTool", function(ply, trace, mode)
	if trace.Entity.CanTool and not FPP then
		return trace.Entity:CanTool(ply, trace, mode)
	end
end)

hook.Add("PhysgunPickup", "EntityPhysgunPickup", function(ply, ent)
	if ent.PhysgunPickup and not FPP then --FPP has this function too
		return ent:PhysgunPickup(ply)
	end
end)

hook.Add("OnPhysgunFreeze", "EntityPhysgunFreeze", function(weapon, physobj, ent, ply, ...)
	if ent.OnPhysgunFreeze and not FPP then
		return ent:OnPhysgunFreeze(weapon, physobj, ent, ply, ...)
	end
end)

/*
	FAdmin global settings
*/
FAdmin.GlobalSetting = FAdmin.GlobalSetting or {}


FindMetaTable("Player").FAdmin_GetGlobal = function(self, setting)
	return self.GlobalSetting and self.GlobalSetting[setting]
end

/*Dependency solver:
	Many plugins are dependant of one another.
	To prevent plugins calling functions from other plugins that haven't been opened yet
	there will be a hook that is called when all plugins are loaded.
	This way there will be no hassle with which plugin loads first, which one next etc.
*/
timer.Simple(0, function()
	for k,v in pairs(FAdmin.StartHooks) do if type(k) ~= "string" then FAdmin.StartHooks[k] = nil end end
	for k,v in SortedPairs(FAdmin.StartHooks) do
		v()
	end
end)

hook.Add("InitPostEntity", "FAdmin_DarkRP_privs", function()
	if not FAdmin or not FAdmin.StartHooks then return end
	FAdmin.Access.AddPrivilege("rp_commands", 2)
	FAdmin.Access.AddPrivilege("rp_doorManipulation", 3)
	FAdmin.Access.AddPrivilege("rp_tool", 2)
	FAdmin.Access.AddPrivilege("rp_phys", 2)
	FAdmin.Access.AddPrivilege("rp_prop", 2)
	FAdmin.Access.AddPrivilege("rp_viewlog", 2)
	for k,v in pairs(RPExtraTeams) do
		if v.vote then
			FAdmin.Access.AddPrivilege("rp_"..v.command, (v.admin or 0) + 2) -- Add privileges for the teams that are voted for
		end
	end
end)
