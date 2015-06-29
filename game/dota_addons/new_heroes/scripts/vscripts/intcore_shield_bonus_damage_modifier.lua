intcore_shield_bonus_damage_modifier = class({})

function intcore_shield_bonus_damage_modifier:OnCreated(keys)
	if IsServer() then
		self.absorbed_as_bonus_damage_ratio = keys.absorbed_as_bonus_damage_ratio
		self.bonus_damage = keys.bonus_damage
		if self.absorbed_as_bonus_damage_ratio == nil then
			print("intcore_shield_bonus_damage_modifier created without specifying the bonus_damage key")
			self.absorbed_as_bonus_damage_ratio = 1
		end
		if self.bonus_damage == nil then
			print("intcore_shield_bonus_damage_modifier created without specifying the bonus_damage key")
			self.bonus_damage = 0
		end
	end
end

-- On refresh use the new values. Otherwise we would keep the old bonus damage and ratio.
-- Really just an edge case with Refresher.
function intcore_shield_bonus_damage_modifier:OnRefresh(keys)
	if IsServer() then
		self.absorbed_as_bonus_damage_ratio = keys.absorbed_as_bonus_damage_ratio
		self.bonus_damage = keys.bonus_damage
		if self.absorbed_as_bonus_damage_ratio == nil then
			print("intcore_shield_bonus_damage_modifier created without specifying the bonus_damage key")
			self.absorbed_as_bonus_damage_ratio = 1
		end
		if self.bonus_damage == nil then
			print("intcore_shield_bonus_damage_modifier created without specifying the bonus_damage key")
			self.bonus_damage = 0
		end
	end
end

function intcore_shield_bonus_damage_modifier:IsBuff()
	return true
end

function intcore_shield_bonus_damage_modifier:IsPurgable()
	return false
end

function intcore_shield_bonus_damage_modifier:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf"
end

function intcore_shield_bonus_damage_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function intcore_shield_bonus_damage_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function intcore_shield_bonus_damage_modifier:StatusEffectPriority()
	return 10
end

function intcore_shield_bonus_damage_modifier:GetTexture()
	return "sven_gods_strength"
end

function intcore_shield_bonus_damage_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}
	return funcs
end

function intcore_shield_bonus_damage_modifier:GetModifierBaseAttack_BonusDamage(params)
	return self.bonus_damage * self.absorbed_as_bonus_damage_ratio
end