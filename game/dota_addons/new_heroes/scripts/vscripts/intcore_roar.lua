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
	local modifier_table = {
		duration = self:GetSpecialValueFor("duration"),
		bonus_movespeed_absolute = self:GetSpecialValueFor("bonus_movespeed_absolute"),
		bonus_attackspeed = self:GetSpecialValueFor("bonus_attackspeed"),
		incoming_damage_reduction_percentage = self:GetSpecialValueFor("incoming_damage_reduction_percentage"),
		aura_radius = self:GetSpecialValueFor("aura_radius"),
		-- Use the current level of intcore_give_health. The caster must HAVE the ability but it does not have to be skilled.
		health_gain_per_hit = self:GetCaster():FindAbilityByName("intcore_give_health"):GetSpecialValueFor("health_gain_per_hit"),
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