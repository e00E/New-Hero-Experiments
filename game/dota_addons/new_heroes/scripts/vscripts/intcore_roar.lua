intcore_roar = class({})
LinkLuaModifier("intcore_roar_aura_emitter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("intcore_roar_aura_modifier", LUA_MODIFIER_MOTION_NONE)

function intcore_roar:OnSpellStart()
	local target_type
	if self:GetCaster():HasScepter() then
		target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_MECHANICAL
	else
		target_type = DOTA_UNIT_TARGET_HERO
	end
	-- Use the current level of intcore_give_health. If the caster does not have it the health gain will be 0.
	local give_health_ability = self:GetCaster():FindAbilityByName("intcore_give_health")
	local health_gain_per_hit = 0
	if give_health_abilitiy ~= nil then health_gain_per_hit = give_health_ability:GetSpecialValueFor("health_gain_per_hit") end
	local modifier_table = {
		duration = self:GetSpecialValueFor("duration"),
		bonus_movespeed_absolute = self:GetSpecialValueFor("bonus_movespeed_absolute"),
		bonus_attackspeed = self:GetSpecialValueFor("bonus_attackspeed"),
		incoming_damage_reduction_percentage = self:GetSpecialValueFor("incoming_damage_reduction_percentage"),
		aura_radius = self:GetSpecialValueFor("aura_radius"),
		health_gain_per_hit = health_gain_per_hit,
		target_type = target_type
	}
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "intcore_roar_aura_emitter", modifier_table)
end

function intcore_roar:GetCooldown(Level)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "cooldown_scepter" )
	end
	return self.BaseClass.GetCooldown( self, Level )
end