ooze_digestive_acid_hp_bonus_modifier = class({})

function ooze_digestive_acid_hp_bonus_modifier:OnCreated(keys)
	self.hp_per_stack = keys.hp_per_stack
	if self.hp_per_stack == nil then
		self.hp_per_stack = self:GetAbility():GetSpecialValueFor("hp_bonus_per_unit")
	end
end

function ooze_digestive_acid_hp_bonus_modifier:OnRefresh(keys)
	if IsServer() then
		self:OnCreated(keys)
	end
end

function ooze_digestive_acid_hp_bonus_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS
	}
	return funcs
end

function ooze_digestive_acid_hp_bonus_modifier:GetModifierHealthBonus()
	if self:GetParent():PassivesDisabled() then
		return 0
	else
		return self:GetStackCount() * self.hp_per_stack
	end
end