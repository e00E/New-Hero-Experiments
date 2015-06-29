intcore_roar_aura_modifier = class({})

function intcore_roar_aura_modifier:OnCreated(keys)
	if keys.isProvidedByAura then
		self.bonus_movespeed_absolute = self:GetAbility():GetSpecialValueFor("bonus_movespeed_absolute")
		self.bonus_attackspeed = self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
		self.incoming_damage_reduction_percentage = self:GetAbility():GetSpecialValueFor("incoming_damage_reduction_percentage")
		if IsServer() then self.health_gain_per_hit = self:GetAbility():GetCaster():FindAbilityByName("intcore_give_health"):GetSpecialValueFor("health_gain_per_hit") end
	else
		self.bonus_movespeed_absolute = keys.bonus_movespeed_absolute
		self.bonus_attackspeed = keys.bonus_attackspeed
		self.incoming_damage_reduction_percentage = keys.incoming_damage_reduction_percentage
		self.aura_radius = keys.aura_radius
		self.health_gain_per_hit = keys.health_gain_per_hit
	end
	if IsServer() then
		if self.bonus_movespeed_absolute == nil then
			print("intcore_roar_aura_modifier created without specifying the bonus_movespeed_absolute key")
			self.bonus_movespeed_absolute = 0
		end
		if self.bonus_attackspeed == nil then
			print("intcore_roar_aura_modifier created without specifying the bonus_attackspeed key")
			self.bonus_attackspeed = 0
		end
		if self.incoming_damage_reduction_percentage == nil then
			print("intcore_roar_aura_modifier created without specifying the incoming_damage_reduction_percentage key")
			self.incoming_damage_reduction_percentage = 0
		end
		if self.health_gain_per_hit == nil then
			print("intcore_roar_aura_modifier created without specifying the health_gain_per_hit key")
			self.health_gain_per_hit = 0
		end
		modifier_table = {
			duration = -1,
			health_gain_per_hit = self.health_gain_per_hit
		}
		self.remove_give_health = false
		if not self:GetParent():HasModifier("intcore_give_health_modifier") then
			self.remove_give_health = true
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "intcore_give_health_modifier", modifier_table)
		end
	end
end

function intcore_roar_aura_modifier:OnRefresh(keys)
	if IsServer() then
		self:OnDestroy()
		self:OnCreated(keys)
	end
end

function intcore_roar_aura_modifier:OnDestroy()
	if IsServer() then
		if self.remove_give_health then
			self:GetParent():RemoveModifierByNameAndCaster("intcore_give_health_modifier", self:GetCaster())
		end
	end
end

function intcore_roar_aura_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function intcore_roar_aura_modifier:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attackspeed
end

function intcore_roar_aura_modifier:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_movespeed_absolute
end

function intcore_roar_aura_modifier:GetModifierIncomingDamage_Percentage()
	return self.incoming_damage_reduction_percentage
end

function intcore_roar_aura_modifier:GetTexture()
	return "beastmaster_primal_roar"
end

function intcore_roar_aura_modifier:GetEffectName()
	return "particles/items2_fx/tranquil_boots_healing_core.vpcf"
end

function intcore_roar_aura_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end