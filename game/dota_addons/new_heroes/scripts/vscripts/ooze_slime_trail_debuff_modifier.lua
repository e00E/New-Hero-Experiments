ooze_slime_trail_debuff_modifier = class({})

-- The anti spell move detection is a bit wacko:
-- We test that each frame the unit did not move further than the maximum movespeed it should have
-- according to the ability. If the unit does move more, we teleport it back to where it was one frame earlier.

function ooze_slime_trail_debuff_modifier:OnCreated(keys)
	if keys.isProvidedByAura then
		-- TODO: When using Split the clone whose slime trail triggered this debuff can already be dead
		-- in this case GetAbility will return nil.
		local ability = self:GetAbility()
		if ability ~= nil then
			self.move_speed_fixed = ability:GetSpecialValueFor("slime_trail_enemy_movespeed")
		else
			self.move_speed_fixed = 200
		end
	else
		self.move_speed_fixed = keys.move_speed_fixed
	end
	if IsServer() then
		self.old_position = self:GetParent():GetOrigin()
		self:StartIntervalThink(0.03)
	end
end

function ooze_slime_trail_debuff_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
	return funcs
end

function ooze_slime_trail_debuff_modifier:GetModifierMoveSpeed_Absolute()
	return self.move_speed_fixed
end

function ooze_slime_trail_debuff_modifier:OnIntervalThink()
	if IsServer() then
		local function vec_distance(vec1,vec2)
			return math.sqrt(math.pow(vec2.x-vec1.x,2)+math.pow(vec2.y-vec1.y,2))
		end
		local parent = self:GetParent()
		local new_position = parent:GetOrigin()
		-- Times 2 here so we have some headroom. Without it normal movevement gets detected as too fast
		if vec_distance(new_position, self.old_position) > self.move_speed_fixed * 0.03 * 2 then
			local particle_index = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_magnet_arclightning.vpcf", PATTACH_ABSORIGIN, parent)
			ParticleManager:SetParticleControl(particle_index, 1, self.old_position)
			ParticleManager:ReleaseParticleIndex(particle_index)
			FindClearSpaceForUnit(parent, self.old_position, true)
			self.old_position = parent:GetOrigin()
		else
			self.old_position = new_position
		end
	end
end

function ooze_slime_trail_debuff_modifier:GetTexture()
	return "venomancer_poison_sting"
end

function ooze_slime_trail_debuff_modifier:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end

function ooze_slime_trail_debuff_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end