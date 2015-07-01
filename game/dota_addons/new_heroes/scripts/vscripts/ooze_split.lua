ooze_split = class({})
LinkLuaModifier( "ooze_split_clone_modifier", LUA_MODIFIER_MOTION_NONE )

-- most of it from http://moddota.com/forums/discussion/62/illusion-ability-example by Noya
function make_copy(target)
	copy = CreateUnitByName(target:GetUnitName(), target:GetOrigin(), true, target, nil, target:GetTeam())
	copy:SetPlayerID(target:GetPlayerID())
	copy:SetControllableByPlayer(target:GetPlayerID(), true)

	local casterLevel = target:GetLevel()
	for i=1,target:GetLevel()-1 do
		copy:HeroLevelUp(false)
	end

	copy:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = target:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = copy:FindAbilityByName(abilityName)
			if illusionAbility ~= nil then -- Corner cases where a parent ability does not exist on the child. TODO: copy all parent abilities
				if illusionAbility:GetLevel() ~= abilityLevel then illusionAbility:SetLevel(abilityLevel) end
				illusionAbility:SetActivated(false)
			end
		end
	end

	for itemSlot=0,5 do
		local item = target:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, copy, copy)
			copy:AddItem(newItem)
		end
	end
	
	return copy
end

function ooze_split:OnSpellStart()
	local caster = self:GetCaster()
	local damageTable = {
		victim = caster,
		attacker = caster,
		damage = caster:GetMaxHealth() * self:GetSpecialValueFor("max_health_cost_ratio"),
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
	local duration = self:GetSpecialValueFor("copy_duration")
	local stat_ratio = self:GetSpecialValueFor("stat_ratio")
	copy = make_copy(caster)
	slime_trail = copy:FindModifierByName("ooze_slime_trail_emitter_modifier")
	if slime_trail ~= nil then slime_trail.slime_trail_emitter_override_owner = self:GetCaster() end-- So the main hero can teleport to it
	copy:AddNewModifier(caster, self, "ooze_split_clone_modifier", {duration = -1, heal_amount = damageTable.damage, time_to_death = duration, stat_ratio = stat_ratio})
	copy:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
	
	local particle_index = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_ward_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, copy)
	ParticleManager:ReleaseParticleIndex(particle_index)
end

function ooze_split:has_enough_health_to_cast()
	local caster = self:GetCaster()
	local health_ratio = self:GetSpecialValueFor("max_health_cost_ratio")
	return caster:GetHealth() > caster:GetMaxHealth() * health_ratio
end
function ooze_split:OnAbilityPhaseStart()
	-- TODO show red error message
	return self:has_enough_health_to_cast()
end

function ooze_split:CastFilterResult()
	if IsServer() then
		if self:has_enough_health_to_cast() then return UF_SUCCESS else return UF_FAIL_CUSTOM end
	else
		return UF_SUCCESS
	end
end

function ooze_split:GetCustomCastError()
	-- There can only be one cast error so we dont have to do anything else
	return "#dota_hud_error_not_enough_health_to_cast"
end