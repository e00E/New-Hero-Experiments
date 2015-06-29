intcore_shield_modifier = class({})
intcore_shield_modifier.use_damage_before_reductions = true

function intcore_shield_modifier:OnCreated(keys)
	if IsServer() then
		self.creation_time = Time()
		self.duration = keys.duration
		self.bonus_damage_duration = keys.bonus_damage_duration
		self.absorbed_as_bonus_damage_ratio = keys.absorbed_as_bonus_damage_ratio
		if self.bonus_damage_duration == nil then
			print("intcore_shield_modifier created without specifying the bonus_damage_duration key")
			self.bonus_damage_duration = 1
		end
		self.shield_damage_absorbed = 0
	end
end

function intcore_shield_modifier:OnRefresh(keys)
	if IsServer() then
		-- Act like shield ran out
		local target = self:GetParent()
		local modifier_keys = {
			duration = self.bonus_damage_duration,
			absorbed_as_bonus_damage_ratio = self.absorbed_as_bonus_damage_ratio,
			bonus_damage = self.shield_damage_absorbed
		}
		target:AddNewModifier(target, self:GetAbility(), "intcore_shield_bonus_damage_modifier", modifier_keys)
		-- Create new shield
		self:OnCreated(keys)
	end
end

function intcore_shield_modifier:OnDestroy()
	if IsServer() then
		-- Check if the duration ran out or it was purged.
		-- In the latter case we dont want to apply the bonus damage.
		-- This is not 100% exact because we just measure the time that elapsed since buff creation and check if it matches the duration.
		local destroy_time = Time()
		local real_duration = destroy_time - self.creation_time
		if math.abs(real_duration - self.duration) < 0.067 then  -- From my tests if the buff is let run out the delta will be at most 0.066
			-- Duration ran out
			local target = self:GetParent()
			local modifier_keys = {
				duration = self.bonus_damage_duration,
				absorbed_as_bonus_damage_ratio = self.absorbed_as_bonus_damage_ratio,
				bonus_damage = self.shield_damage_absorbed
			}
			local particle_index = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_feathers_mace/abaddon_aphotic_shield_explosion_ref.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:ReleaseParticleIndex(particle_index)
			target:AddNewModifier(target, self:GetAbility(), "intcore_shield_bonus_damage_modifier", modifier_keys)
		end
	end
end

function intcore_shield_modifier:IsBuff()
	return true
end

function intcore_shield_modifier:IsPurgable()
	return true
end

function intcore_shield_modifier:GetEffectName()
	return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf"
end

function intcore_shield_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function intcore_shield_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	if self == nil or self.use_damage_before_reductions then --It appears self is nil when this is called. In that case just default to using the modifiers.
		table.insert(funcs, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL)
		table.insert(funcs, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL)
		table.insert(funcs, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE)
	end
	return funcs
end

function intcore_shield_modifier:GetAbsoluteNoDamageMagical(keys)
	if self.use_damage_before_reductions then
		return 1
	else
		return 0
	end
end

function intcore_shield_modifier:GetAbsoluteNoDamagePhysical(keys)
	if self.use_damage_before_reductions then
		return 1
	else
		return 0
	end
end

function intcore_shield_modifier:GetAbsoluteNoDamagePure(keys)
	if self.use_damage_before_reductions then
		return 1
	else
		return 0
	end
end

function intcore_shield_modifier:OnTakeDamage(keys)
	if keys.unit == self:GetParent() then
		local damage = 0
		if self.use_damage_before_reductions then
			damage = keys.original_damage
		else 
			damage = keys.damage
		end
		self.shield_damage_absorbed = self.shield_damage_absorbed + damage
		if not self.use_damage_before_reductions then
			local target = keys.unit
			target:Heal(damage, target)
		end
	end
end