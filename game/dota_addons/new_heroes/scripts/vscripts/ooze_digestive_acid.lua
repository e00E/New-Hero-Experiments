ooze_digestive_acid = class({})
LinkLuaModifier( "ooze_digestive_acid_thinker_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "ooze_digestive_acid_hp_bonus_modifier", LUA_MODIFIER_MOTION_NONE )

function ooze_digestive_acid:GetAOERadius()
	return self:GetSpecialValueFor("initial_aoe")
end

function ooze_digestive_acid:OnSpellStart()
	local modifier_table = {
		duration = self:GetSpecialValueFor("duration"),
		initial_aoe = self:GetSpecialValueFor("initial_aoe"),
		aoe_increase_nonhero = self:GetSpecialValueFor("aoe_increase_nonhero"),
		aoe_increase_hero = self:GetSpecialValueFor("aoe_increase_hero"),
		dps_max_hp_initial_ratio = self:GetSpecialValueFor("dps_max_hp_initial_ratio"),
		dps_max_hp_per_nonhero = self:GetSpecialValueFor("dps_max_hp_per_nonhero"),
		dps_max_hp_per_hero = self:GetSpecialValueFor("dps_max_hp_per_hero")
	}
	CreateModifierThinker( self:GetCaster(), self, "ooze_digestive_acid_thinker_modifier", modifier_table, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )
end

function ooze_digestive_acid:GetIntrinsicModifierName()
	return "ooze_digestive_acid_hp_bonus_modifier"
end