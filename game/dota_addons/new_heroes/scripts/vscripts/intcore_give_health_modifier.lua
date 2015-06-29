intcore_give_health_modifier = class({})

function intcore_give_health_modifier:IsHidden()
	return true
end

function intcore_give_health_modifier:GetTexture()
	return "omniknight_purification"
end

function intcore_give_health_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function intcore_give_health_modifier:OnCreated(keys)
	if IsServer() then
		if keys.health_gain_per_hit == nil then 
			self.health_gain_per_hit = self:GetAbility():GetSpecialValueFor("health_gain_per_hit")
		else
			self.health_gain_per_hit = keys.health_gain_per_hit
		end
	end
end

function intcore_give_health_modifier:OnRefresh(keys)
	if IsServer() then
		self:OnCreated(keys)
	end
end

function intcore_give_health_modifier:OnAttackLanded(keys)
	local attacker = self:GetParent()
	if keys.attacker == attacker and keys.damage_type == DAMAGE_TYPE_PHYSICAL and (not attacker:PassivesDisabled()) and attacker:GetTeam() ~= keys.target:GetTeam() then
		if attacker:GetHealth() < attacker:GetMaxHealth() then
			attacker:Heal(self.health_gain_per_hit, attacker)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, self.health_gain_per_hit, attacker) -- see https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Panorama/Javascript/API#DOTA_OVERHEAD_ALERT
			local particle_index = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker )
			ParticleManager:ReleaseParticleIndex(particle_index)
		end
	end
end