intcore_improve_autoattack_lua = class({})
LinkLuaModifier( "intcore_improve_autoattack_modifier", LUA_MODIFIER_MOTION_NONE )

function intcore_improve_autoattack_lua:OnUpgrade()
	if IsServer() then
		if self:GetToggleState() then
			self:GetCaster():RemoveModifierByName("intcore_improve_autoattack_modifier")
			self:ApplyAutoattackModifier()
		end
	end
end

function intcore_improve_autoattack_lua:OnToggle()
	if IsServer() then
		if self:GetToggleState() then
			self:ApplyAutoattackModifier()
			self:GetCaster():GiveMana(self:GetManaCost(-1)) -- Regain mana lost on toggle
		else
			self:GetCaster():RemoveModifierByName("intcore_improve_autoattack_modifier")
		end
	end
end

function intcore_improve_autoattack_lua:ApplyAutoattackModifier()
	modifier_table = {
		duration = -1,
		damage_as_pure_ratio = self:GetSpecialValueFor("damage_as_pure_ratio"),
		mana_cost = self:GetManaCost(-1)
	}
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "intcore_improve_autoattack_modifier", modifier_table )
end