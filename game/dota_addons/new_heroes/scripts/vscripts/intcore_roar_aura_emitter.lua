intcore_roar_aura_emitter = class({})

function intcore_roar_aura_emitter:OnCreated(keys)
	if IsServer() then
		self.bonus_movespeed_absolute = keys.bonus_movespeed_absolute
		self.bonus_attackspeed = keys.bonus_attackspeed
		self.incoming_damage_reduction_percentage = keys.incoming_damage_reduction_percentage
		self.aura_radius = keys.aura_radius
		self.health_gain_per_hit = keys.health_gain_per_hit
		self.target_type = keys.target_type
		if self.bonus_movespeed_absolute == nil then
			print("intcore_roar_aura_emitter created without specifying the bonus_movespeed_absolute key")
			self.bonus_movespeed_absolute = 0
		end
		if self.bonus_attackspeed == nil then
			print("intcore_roar_aura_emitter created without specifying the bonus_attackspeed key")
			self.bonus_attackspeed = 0
		end
		if self.incoming_damage_reduction_percentage == nil then
			print("intcore_roar_aura_emitter created without specifying the incoming_damage_reduction_percentage key")
			self.incoming_damage_reduction_percentage = 0
		end
		if self.aura_radius == nil then
			print("intcore_roar_aura_emitter created without specifying the aura_radius key")
			self.aura_radius = 0
		end
		if self.health_gain_per_hit == nil then
			print("intcore_roar_aura_emitter created without specifying the health_gain_per_hit key")
			self.health_gain_per_hit = 0
		end
		if self.target_type == nil then
			print("intcore_roar_aura_emitter created without specifying the target_type key")
			self.target_type = 0
		end
	end
end

function intcore_roar_aura_emitter:OnRefresh(keys)
	if IsServer() then
		self:OnCreated(keys)
	end
end

function intcore_roar_aura_emitter:GetAuraRadius()
	return self.aura_radius
end

function intcore_roar_aura_emitter:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function intcore_roar_aura_emitter:GetAuraSearchType()
	return self.target_type
end

function intcore_roar_aura_emitter:IsAura()
	return true
end

function intcore_roar_aura_emitter:GetModifierAura()
	return "intcore_roar_aura_modifier"
end

function intcore_roar_aura_emitter:GetEffectName()
	return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function intcore_roar_aura_emitter:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end