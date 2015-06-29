intcore_shield = class({})
LinkLuaModifier( "intcore_shield_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "intcore_shield_bonus_damage_modifier", LUA_MODIFIER_MOTION_NONE )

function intcore_shield:OnSpellStart()
	if IsServer() then
		local target = self:GetCaster()
		local modifier_keys = {
			duration = self:GetSpecialValueFor("shield_duration"),
			absorbed_as_bonus_damage_ratio = self:GetSpecialValueFor("absorbed_as_bonus_damage_ratio"),
			bonus_damage_duration = self:GetSpecialValueFor("bonus_damage_duration"),
		}
		target:AddNewModifier(self:GetCaster(), self, "intcore_shield_modifier", modifier_keys )
	end
end