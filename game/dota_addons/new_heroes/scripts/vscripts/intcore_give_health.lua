intcore_give_health = class({})
LinkLuaModifier("intcore_give_health_modifier", LUA_MODIFIER_MOTION_NONE)

function intcore_give_health:GetIntrinsicModifierName()
	return "intcore_give_health_modifier"
end