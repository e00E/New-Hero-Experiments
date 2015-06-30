-- We check for proximity to these dummy units in main ability
ooze_slime_trail_thinker_modifier = class({})

function ooze_slime_trail_thinker_modifier:OnCreated(keys)
	if IsServer() then
		self.trail_radius = keys.trail_radius
		-- TODO: make good particle that looks slimy on ground and not like a smoke cloud
		-- self.particle_index = ParticleManager:CreateParticle( "particles/ooze_slime_trail2.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		-- The slime will always be seen by it's own team but only by enemies if it is in vision. For this we need 2 particles.
		-- This way the Ooze will see slime trails of enemies affected by drench. We could change that too, but I like it this way.
		-- TODO: we need to create the particles for all other teams
		local friendly_team = self:GetCaster():GetTeam()
		local enemy_team = nil
		if friendly_team == DOTA_TEAM_GOODGUYS then	enemy_team = DOTA_TEAM_BADGUYS else enemy_team = DOTA_TEAM_GOODGUYS end
		self.particle_index_friendly = ParticleManager:CreateParticleForTeam( "particles/ooze_slime_trail_through_fog.vpcf", PATTACH_ABSORIGIN, self:GetParent(),  friendly_team)
		self.particle_index_enemy = ParticleManager:CreateParticleForTeam( "particles/ooze_slime_trail.vpcf", PATTACH_ABSORIGIN, self:GetParent(),  enemy_team)
	end
end

function ooze_slime_trail_thinker_modifier:OnDestroy()
	if IsServer() then
		-- last bool if true destroys it faster, maybe useful.
		ParticleManager:DestroyParticle( self.particle_index_friendly, true )
		ParticleManager:ReleaseParticleIndex( self.particle_index_friendly )
		ParticleManager:DestroyParticle( self.particle_index_enemy, true )
		ParticleManager:ReleaseParticleIndex( self.particle_index_enemy )
		UTIL_Remove( self:GetParent() )
	end
end

function ooze_slime_trail_thinker_modifier:IsHidden()
	return true
end

function ooze_slime_trail_thinker_modifier:GetAuraRadius()
	return self.trail_radius
end

function ooze_slime_trail_thinker_modifier:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function ooze_slime_trail_thinker_modifier:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function ooze_slime_trail_thinker_modifier:IsAura()
	return true
end

function ooze_slime_trail_thinker_modifier:GetModifierAura()
	return "ooze_slime_trail_debuff_modifier"
end