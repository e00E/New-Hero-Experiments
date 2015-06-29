ooze_drench = class({})
-- LinkLuaModifier( "ooze_slime_trail_emitter_enemy_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "ooze_drench_change_team_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "ooze_slime_trail_emitter_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "ooze_slime_trail_thinker_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "ooze_slime_trail_debuff_modifier", LUA_MODIFIER_MOTION_NONE )

function ooze_drench:OnSpellStart()
	local vPos = nil
	if self:GetCursorTarget() then
		vPos = self:GetCursorTarget():GetOrigin()
	else
		vPos = self:GetCursorPosition()
	end
	local vDirection = vPos - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()
	local projectile_table = {
		Ability = self,
		Source = self:GetCaster(),
		EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		vVelocity = vDirection * self:GetSpecialValueFor("projectile_speed"),
		fDistance = self:GetSpecialValueFor("projectile_distance"),
		fStartRadius = self:GetSpecialValueFor("projectile_width"), --divide by 2?
		fEndRadius = self:GetSpecialValueFor("projectile_width"), --divide by 2?
		bHasFrontalCone = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		bProvidesVision = false,
	}
	ProjectileManager:CreateLinearProjectile(projectile_table)
end

function ooze_drench:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil then
		-- Use the current level of slime trail.
		-- This has the effect that Rubick's Drench will not make the targets leave trails.
		local slime_trail = self:GetCaster():GetAbilityByIndex(0)
		if slime_trail:GetLevel() >= 1 then
			local modifier_table = {
				duration = self:GetSpecialValueFor("slime_duration"),
				trail_duration = slime_trail:GetSpecialValueFor("trail_duration"),
				trail_radius = slime_trail:GetSpecialValueFor("trail_radius")
			}
			hTarget:AddNewModifier(self:GetCaster(), self, "ooze_slime_trail_emitter_modifier", modifier_table)
			-- TODO: this is currently bugged if two  oozes are in the game and one uses drench on the other or Rubick uses Drench on an Ooze and Rubick's Drench inflicts slime trail.
			-- There needs to be FindModifierByNameAndCaster or FindAllModifiers see http://dev.dota2.com/showthread.php?t=171916
			hTarget:FindModifierByName("ooze_slime_trail_emitter_modifier").slime_trail_emitter_override_owner = self:GetCaster()
		end
		local modifier_table = {
			duration = self:GetSpecialValueFor("slime_duration"),
		}
		hTarget:AddNewModifier(self:GetCaster(), self, "ooze_drench_change_team_modifier", modifier_table)
		
		local particle_index = ParticleManager:CreateParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_steam_nexon_hero_cp_2014.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
		ParticleManager:ReleaseParticleIndex(particle_index)
		local particle_index = ParticleManager:CreateParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_steam_nexon_hero_cp_2014.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:ReleaseParticleIndex(particle_index)
	end
	return false
end