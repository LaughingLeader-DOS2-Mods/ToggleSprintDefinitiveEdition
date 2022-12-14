local function GetSpeedFlag(db, val)
	local status,result = xpcall(function()
		local entry = Osi[db]:Get(nil, nil, val)
		if entry ~= nil then
			return entry[1][2]
		else
			return error("Failed to get DB flag for",val)
		end
	end, debug.traceback)
	if status then
		return result
	else
		Ext.Utils.PrintError("[ToggleSprint] Error getting speed flag:")
		Ext.Utils.PrintError(result)
	end
	return nil
end

---@param e LeaderLibSubscribableEventArgs|ModSettingsLoadedEventArgs
local function OnSettingsLoaded(e)
	-- Delete old settings
	local oldDB = Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalFlag:Get("3cdec0ff-5d98-e859-87cd-c663b7b9fcfe", nil, nil)
	if oldDB ~= nil and #oldDB > 0 then
		Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalFlag:Delete("3cdec0ff-5d98-e859-87cd-c663b7b9fcfe", nil, nil);
		Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalInteger:Delete("3cdec0ff-5d98-e859-87cd-c663b7b9fcfe", nil, nil);
	end

	---@type ModSettings
	local settings = e.Settings

	local clamp = Mods.LeaderLib.GameHelpers.Math.Clamp

	local partySprint = clamp(settings.Global:GetVariable("PartySprintingSpeed", 5), 4, 11)
	local enemySprint = clamp(settings.Global:GetVariable("EnemySprintingSpeed", 5), 4, 11)
	local partyWalk = clamp(settings.Global:GetVariable("PartyWalkingSpeed", 2), 2, 9)
	local enemyWalk = clamp(settings.Global:GetVariable("EnemyWalkingSpeed", 2), 2, 9)

	local flag = GetSpeedFlag("DB_ToggleSprint_SprintingSpeed", partySprint)
	if flag ~= nil then
		Osi.LLSPRINT_SetPartySpeed(flag)
	end
	flag = GetSpeedFlag("DB_ToggleSprint_SprintingSpeed", enemySprint)
	if flag ~= nil then
		Osi.DB_ToggleSprint_EnemySprintingSpeed:Delete(nil)
		Osi.DB_ToggleSprint_EnemySprintingSpeed(flag)
	end
	flag = GetSpeedFlag("DB_ToggleSprint_WalkingSpeed", partyWalk)
	if flag ~= nil then
		Osi.LLSPRINT_SetPartyWalkSpeed(flag)
	end
	flag = GetSpeedFlag("DB_ToggleSprint_WalkingSpeed", enemyWalk)
	if flag ~= nil then
		Osi.DB_ToggleSprint_EnemyWalkingSpeed:Delete(nil)
		Osi.DB_ToggleSprint_EnemyWalkingSpeed(flag)
	end

	---@param self SettingsData
	---@param name string
	---@param data VariableData
	settings.UpdateVariable = function(self, name, data)
		if string.find(name, "SprintingSpeed") then
			local flag = "ToggleSprint_SprintingSpeed_02"
			if name == "PartySprintingSpeed" then
				local flagEntry = Osi.DB_ToggleSprint_PartySprintingSpeed:Get(nil)
				if flagEntry ~= nil then
					flag = flagEntry[1][1]
				end
			elseif name == "EnemySprintingSpeed" then
				local flagEntry = Osi.DB_ToggleSprint_EnemySprintingSpeed:Get(nil)
				if flagEntry ~= nil then
					flag = flagEntry[1][1]
				end
			end
			local speedEntry = Osi.DB_ToggleSprint_SprintingSpeed:Get(nil, flag, nil)
			if speedEntry ~= nil then
				data.Value = speedEntry[1][3]
			end
		elseif string.find(name, "WalkingSpeed") then
			local flag = "ToggleSprint_WalkingSpeed_00"
			if string.find(name, "Party") then
				local flagEntry = Osi.DB_ToggleSprint_PartyWalkingSpeed:Get(nil)
				if flagEntry ~= nil then
					flag = flagEntry[1][1]
				end
			elseif string.find(name, "Enemy") then
				local flagEntry = Osi.DB_ToggleSprint_EnemyWalkingSpeed:Get(nil)
				if flagEntry ~= nil then
					flag = flagEntry[1][1]
				end
			end
			local speedEntry = Osi.DB_ToggleSprint_WalkingSpeed:Get(nil, flag, nil)
			if speedEntry ~= nil then
				data.Value = speedEntry[1][3]
			end
		end
	end
end

if Ext.IsServer() then
	if Mods.LeaderLib ~= nil then
		Mods.LeaderLib.Events.ModSettingsLoaded:Subscribe(OnSettingsLoaded, {MatchArgs={UUID=ModuleUUID}})
	else
		Ext.Events.SessionLoaded:Subscribe(function(e)
			if Mods.LeaderLib ~= nil then
				Mods.LeaderLib.Events.ModSettingsLoaded:Subscribe(OnSettingsLoaded, {MatchArgs={UUID=ModuleUUID}})
			end
		end)
	end
end