ooze_slime_trail = class({})
LinkLuaModifier( "ooze_slime_trail_emitter_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "ooze_slime_trail_thinker_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "ooze_slime_trail_debuff_modifier", LUA_MODIFIER_MOTION_NONE )


function ooze_slime_trail:OnAbilityPhaseStart()
	-- Check for trail existence here again. Otherwise you can cast teleport outside of cast range
	-- and while the hero is walking to into cast range the trail can disappear but the hero will still
	-- execute the teleport once in cast range.
	if self:CastFilterResultLocation(self:GetCursorPosition()) == UF_SUCCESS then
		return true
	else
		-- TODO: show red cast error message. How?
		return false
	end
end

function ooze_slime_trail:OnSpellStart()
	-- ProjectileManager:ProjectileDodge( self:GetCaster() )
	FindClearSpaceForUnit( self:GetCaster(), self:GetCursorPosition(), true )
end

-- Sadly this does not totally work seemingly because slime trail is MODIFIER_ATTRIBUTE_MULTIPLE .
-- on level up this wont refresh the buff with new values
function ooze_slime_trail:GetIntrinsicModifierName()
	return "ooze_slime_trail_emitter_modifier"
end

function ooze_slime_trail:CastFilterResultLocation( vLocation )
	-- We search for a thinker unit having the correct modifier and caster
	-- the caster is important if there are multiple oozes in the game or if Rubick steals it
	-- TODO: What should happen if the ooze runs out while the ability channels? Continue or cancel?. Currently continue.
	
	-- This check can only be performed server side. We always return true client side or the server side check will not run.
	if IsServer() then
		local result = Entities:FindByClassnameWithin(nil, "npc_dota_thinker", vLocation, self:GetSpecialValueFor("trail_radius"))
		while result ~= nil do
			local modifier = result:FindModifierByName("ooze_slime_trail_thinker_modifier")
			if modifier ~= nil and modifier:GetCaster() == self:GetCaster() then
				return UF_SUCCESS
			end
			result = Entities:FindByClassnameWithin(result, "npc_dota_thinker", vLocation, self:GetSpecialValueFor("trail_radius"))
		end
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function ooze_slime_trail:GetCustomCastErrorLocation( vLocation )
	-- There can only be one cast error so we dont have to do anything else
	return "#dota_hud_error_can_only_be_cast_on_ooze_trail"
end