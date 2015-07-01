ooze_drench_change_team_modifier = class({})

--[[
there needs to be a custom team defined in addoninfo.txt or after the team change the unit wont be able
to attack or cast spells on anyone
"dota_combine_models 0" needs to be set or the game will crash when hiding wearables sometimes. For example with SendToConsole("dota_combine_models 0").

Problems with current approach:
If multiple heroes are Drenched at the same time they wont be able
to harm eachother.
	This could be fixed by putting them all in different teams but require more custom teams.
The drenched heroes can also injure heroes on their own team. This should not happen.
	To fix this we heal that damage and dont allow attack commands on them. Could make a better solution the intcore_shield way.
Rubick can steal spells from drenched heroes that were originally in his team.
The controlling player and his team lose vision from and of the unit. It cant be selected by the player while in fog.
(The player keeps the fog of the rest of his original team)
	Is fixed with AddFOWViewer and MakeVisibleToTeam.
Changing the model does not really work. The new model does not look right and is missing parts.
	Could probaby be fixed with some model attchments library?!
HideWearables crashes the game randomly even with the convar set. Commented out for that.

TODO:
test the dummy unit move with real hero, has higher targeting priority and damages real hero too approach.
]]


-- Wearable functions copied from https://github.com/Pizzalol/SpellLibrary/blob/SpellLibrary/game/dota_addons/spelllibrary/scripts/vscripts/heroes/hero_terrorblade/metamorphosis.lua
-- Had to change the first if in the while loop. I think thats also wrong on the github link.
-- This crashes sometimes when used during in animation. TODO: stop all animations before, how?
function HideWearables( target )
	local hero = target
	hero.wearableNames = {}
	hero.hiddenWearables = {}
	for k,v in pairs(target:GetChildren()) do
        if v:GetModelName() ~= "" and v:GetClassname() == "dota_item_wearable" then
            local modelName = v:GetModelName()
			print("hiding", modelName)
            if string.find(modelName, "invisiblebox") == nil then
            	table.insert(hero.wearableNames,modelName)
            	v:SetModel("models/development/invisiblebox.vmdl")
            	table.insert(hero.hiddenWearables,v)
            end
        end
    end
end

function ShowWearables( target )
	local hero = target
	for i,v in ipairs(hero.hiddenWearables) do
		for index,modelName in ipairs(hero.wearableNames) do
			if i==index then
				v:SetModel(modelName)
			end
		end
	end
	hero.wearableNames = nil
	hero.hiddenWearables = nil
end

function AttachWearables( hero )
    -- TODO get real equipped items from the ooze hero
	-- This is hardcoded for venomancer
	-- TODO how to implement...
	
	--[[local venomancer_arms = "models/heroes/venomancer/venomancer_arms.vmdl"
	local venomancer_jaws = "models/heroes/venomancer/venomancer_jaw.vmdl"
	local venomancer_shoulder = "models/heroes/venomancer/venomancer_shoulder.vmdl"
	local venomancer_tail = "models/heroes/venomancer/venomancer_tail.vmdl"

    local new_jaws = Entities:CreateByClassname("dota_item_wearable")
    new_jaws:SetModel(venomancer_jaws)
    new_jaws:SetParent(hero:GetRootMoveParent(), "attach_mouth")
    
    --local weapon = Entities:CreateByClassname("dota_item_wearable")
    -- weapon:SetModel(weaponModel)
    -- weapon:SetParent(hero:GetRootMoveParent(), "attach_weapon_l")]]
end

function ooze_drench_change_team_modifier:IsHidden()
	return true
end

function ooze_drench_change_team_modifier:OnCreated(keys)
	if IsServer() then
		local parent = self:GetParent()
		self.old_team = parent:GetTeam()
		-- self.old_model = parent:GetModelName()
		parent:SetTeam(DOTA_TEAM_CUSTOM_1)
		-- HideWearables(parent)
		-- parent:SetOriginalModel(self:GetCaster():GetModelName())
		-- parent:SetModel(self:GetCaster():GetModelName())
		-- AttachWearables(parent)
		
		
		-- TODO: try ManageModelChanges, NotifyWearablesOfModelChange
		
		parent:MakeVisibleToTeam(self.old_team, keys.duration)
		self:OnIntervalThink()
		self:StartIntervalThink(0.03)
	end
end

function ooze_drench_change_team_modifier:OnRefresh()
	if IsServer() then
		local parent = self:GetParent()
		-- parent:SetModel(self:GetCaster():GetModelName())
		-- parent:SetOriginalModel(self:GetCaster():GetModelName())
	end
end

function ooze_drench_change_team_modifier:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		parent:SetTeam(self.old_team)
		-- parent:SetModel(self.old_model)
		-- parent:SetOriginalModel(self.old_model)
		-- ShowWearables(parent)
		
		local particle_index = ParticleManager:CreateParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_steam_nexon_hero_cp_2014.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:ReleaseParticleIndex(particle_index)
	end
end

function ooze_drench_change_team_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_START,
	}
	return funcs
end

function ooze_drench_change_team_modifier:OnTakeDamage(keys)
	-- Change the team back if lethal damage would be dealt. This makes the game correctly think it is a deny.
	if keys.unit == self:GetParent() then
		if keys.damage >= self:GetParent():GetHealth() then
			-- Reset the team before the kills happens and attribute the kill
			-- to the Ooze. If we dont kill it this way it will count as a deny.
			self:GetParent():SetTeam(self.old_team)
			keys.unit:Kill(self:GetAbility(), self:GetCaster())
		end
	elseif keys.attacker == self:GetParent() and keys.unit:GetTeam() == self.old_team then
		keys.unit:Heal(keys.damage, self:GetParent())
	end
end

function ooze_drench_change_team_modifier:OnAttackStart(keys)
	if keys.attacker == self:GetParent() and keys.target:GetTeam() == self.old_team then
		self:GetParent():Stop()
	end
end	

function ooze_drench_change_team_modifier:OnIntervalThink()
	local vision = nil
	if GameRules:IsDaytime() then
		vision = self:GetParent():GetDayTimeVisionRange()
	else
		vision = self:GetParent():GetNightTimeVisionRange()
	end
	AddFOWViewer(self.old_team, self:GetParent():GetOrigin(), vision, 0.03, true)
end