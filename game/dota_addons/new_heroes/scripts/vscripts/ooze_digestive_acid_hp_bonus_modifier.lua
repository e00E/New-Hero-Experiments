ooze_digestive_acid_hp_bonus_modifier = class({})

-- The anti spell move detection is a bit wacko:
-- We test that each frame the unit did not move further than the maximum movespeed it should have
-- according to the ability. If the unit does move more, we teleport it back to where it was one frame earlier.

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