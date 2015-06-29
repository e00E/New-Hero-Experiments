-- Generated from template

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function on_start_bots(keys)
	SendToConsole("dota_bot_set_difficulty 4")
	GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
	SendToConsole("dota_bot_populate")
	-- at difficulty 4 (should be unfair) bots gain 1600 gold on creep spawn. I dont know why.
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	-- SendToConsole("dota_combine_models 0") -- needed for HideWearables
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CAddonTemplateGameMode:InitGameMode()
	Convars:RegisterCommand("start_bots", on_start_bots, "Makes bots pick and control their heroes.", 0)
	-- GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

-- Evaluate the state of the game
--[[function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end]]