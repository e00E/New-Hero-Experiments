ooze_slime_trail_emitter_modifier = class({})

-- This modifier uses the slime_trail_emitter_override_owner attribute on itsself to determine who the slime trail belongs to
-- because it can affect a unit but belong to a different unit. Other methods applying this modifier can then FindModifierByName and set the attribute.
-- The owner is the unit that can teleport to the trail and whose team is not affected by the slow.
-- If not set the owner is the parent of the modifier.
-- If set the owner is the unit this is set to.

function ooze_slime_trail_emitter_modifier:get_parent_position()
	return self:GetParent():GetOrigin()
end

function ooze_slime_trail_emitter_modifier:IsHidden()
	return true
end

function ooze_slime_trail_emitter_modifier:IsPurgable()
	return false
end

function ooze_slime_trail_emitter_modifier:IsPurgeException()
	return false
end

function ooze_slime_trail_emitter_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function ooze_slime_trail_emitter_modifier:OnCreated(keys)
	if IsServer() then
		self.duration = keys.duration
		if keys.trail_duration == nil then
			self.trail_duration = self:GetAbility():GetSpecialValueFor("trail_duration")
			self.trail_duration_intrinsic = true -- Have to make these because of the getintrinsic bug mentioned in ooze_slime_trail.lua
		else
			self.trail_duration = keys.trail_duration
			self.trail_duration_intrinsic = false
		end
		if keys.trail_radius == nil then
			self.trail_radius = self:GetAbility():GetSpecialValueFor("trail_radius")
			self.trail_radius_intrinsic = true
		else
			self.trail_radius = keys.trail_radius
			self.trail_radius_intrinsic = false
		end
		self:OnIntervalThink()
		self:StartIntervalThink(0.3)
	end
end

function ooze_slime_trail_emitter_modifier:OnRefresh(keys)
	if IsServer() then
		self:OnCreated(keys)
	end
end

function ooze_slime_trail_emitter_modifier:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local duration = nil
		local radius = nil
		if self.trail_duration_intrinsic then duration = ability:GetSpecialValueFor("trail_duration") else duration = self.trail_duration end
		if self.trail_radius_intrinsic then radius = ability:GetSpecialValueFor("trail_radius") else radius = self.trail_radius end
		if parent:IsAlive() and (not parent:PassivesDisabled()) and (not parent:IsIllusion()) then
			modifier_table = {
				duration = self.trail_duration,
				trail_radius = self.trail_radius,
			}
			-- TODO: try leaving the trail BEHIND the unit and not right on it, so you couldnt slow units in front of you
			-- Could be where the unit was x frames ago, in which case there would be a slime form delay, might be fine.
			-- Could be physically behind in which you might be able to abuse it by spinning fast.
			if self.slime_trail_emitter_override_owner == nil then
				CreateModifierThinker( parent, ability, "ooze_slime_trail_thinker_modifier", modifier_table, self:get_parent_position(), parent:GetTeamNumber(), false )
			else
				CreateModifierThinker( self.slime_trail_emitter_override_owner, ability, "ooze_slime_trail_thinker_modifier", modifier_table, self:get_parent_position(), self.slime_trail_emitter_override_owner:GetTeamNumber(), false )
			end
			-- DebugDrawCircle(self:get_parent_position(), Vector(0, 255, 0), 0, self.trail_radius, false, self.trail_duration)
		end
	end
end

function ooze_slime_trail_emitter_modifier:OnDestroy(keys)
	if IsServer() then
	end
end