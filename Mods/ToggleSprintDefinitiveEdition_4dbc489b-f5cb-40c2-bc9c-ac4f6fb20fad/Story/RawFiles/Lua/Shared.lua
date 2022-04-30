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
		Ext.PrintError("[ToggleSprint] Error getting speed flag:")
		Ext.PrintError(result)
	end
	return nil
end

local function OnSettingsLoaded()
	-- Delete old settings
	local oldDB = Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalFlag:Get("3cdec0ff-5d98-e859-87cd-c663b7b9fcfe", nil, nil)
	if oldDB ~= nil and #oldDB > 0 then
		Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalFlag:Delete("3cdec0ff-5d98-e859-87cd-c663b7b9fcfe", nil, nil);
		Osi.DB_LeaderLib_ModApi_GlobalSettings_Register_GlobalInteger:Delete("3cdec0ff-5d98-e859-87cd-c663b7b9fcfe", nil, nil);
	end

	---@type ModSettings
	local settings = Mods.LeaderLib.SettingsManager.GetMod(ModuleUUID, false)

	local partySprint = math.min(11, math.max((settings.Global.Variables.PartySprintingSpeed.Value or 5), 2))
	local enemySprint = math.min(11, math.max((settings.Global.Variables.EnemySprintingSpeed.Value or 5), 2))
	local partyWalk = (settings.Global.Variables.PartyWalkingSpeed.Value or 2)
	local enemyWalk = (settings.Global.Variables.EnemyWalkingSpeed.Value or 2)

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
end

Ext.RegisterListener("SessionLoaded", function()
	if Mods.LeaderLib ~= nil then
		---@type ModSettings
		local settings = Mods.LeaderLib.SettingsManager.GetMod(ModuleUUID, false)
		if settings then
			---@param self SettingsData
			---@param name string
			---@param data VariableData
			-- settings.OnVariableSet = function(self, uuid, name, data)

			-- end
		
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
			if Ext.IsServer() then
				OnSettingsLoaded()
			end
		end

		if Ext.IsServer() then
			Mods.LeaderLib.RegisterListener("ModSettingsLoaded", OnSettingsLoaded)
		end
	end
end)