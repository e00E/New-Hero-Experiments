intcore_improve_autoattack_modifier = class({})
intcore_improve_autoattack_modifier.just_base_damage = true

function intcore_improve_autoattack_modifier:OnCreated(keys)
	if IsServer() then
		self.damage_as_pure_ratio = keys.damage_as_pure_ratio
		self.mana_cost = keys.mana_cost
		if self.damage_as_pure_ratio == nil then
			print("intcore_autoattack_modifier created without specifying the base_damage_as_pure_ratio key")
			self.damage_as_pure_ratio = 1
		end
		if self.mana_cost == nil then
			print("intcore_autoattack_modifier created without specifying the base_damage_as_pure_ratio key")
			self.mana_cost = 20
		end
	end
end

function intcore_improve_autoattack_modifier:OnRefresh(keys)
	if IsServer() then
		self.damage_as_pure_ratio = keys.damage_as_pure_ratio
		self.mana_cost = keys.mana_cost
		if self.damage_as_pure_ratio == nil then
			print("intcore_autoattack_modifier created without specifying the base_damage_as_pure_ratio key")
			self.damage_as_pure_ratio = 1
		end
		if self.mana_cost == nil then
			print("intcore_autoattack_modifier created without specifying the base_damage_as_pure_ratio key")
			self.mana_cost = 20
		end
	end
end

function intcore_improve_autoattack_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function intcore_improve_autoattack_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
	return state
end

function is_valid_target(target)
	-- return (not target:IsAncient()) and (not target:IsBuilding()) and (not target:IsMagicImmune()) and (not target:IsMechanical())
	return (not target:IsBuilding())
end

function intcore_improve_autoattack_modifier:OnAttackLanded(keys)
	local attacker = self:GetParent()
	-- TODO: we check for enough mana here because we cant be an orb yet
	if keys.attacker == attacker and keys.damage_type == DAMAGE_TYPE_PHYSICAL and attacker:GetMana() >= self.mana_cost and attacker:GetTeam() ~= keys.target:GetTeam() and is_valid_target(keys.target) then
		local target = keys.target
		local damage = keys.damage
		local original_damage = keys.original_damage
		local armor = target:GetPhysicalArmorValue()
		local armor_multiplier = 1 - (0.06 * armor) / (1 + 0.06 * math.abs(armor))
		-- TODO change once bug is fixed
		local original_damage = damage
		local modified_damage = original_damage * armor_multiplier
		local base_damage = attacker:GetAttackDamage()

		local function get_pure_damage()
			if self.just_base_damage then return base_damage * self.damage_as_pure_ratio else return original_damage * self.damage_as_pure_ratio end
		end
		local function get_mitigiated_damage()
			if self.just_base_damage then return base_damage * self.damage_as_pure_ratio * armor_multiplier else return modified_damage * self.damage_as_pure_ratio end
		end
		local damageTable = {
			victim = target,
			attacker = attacker,
			damage = get_pure_damage(),
			damage_type = DAMAGE_TYPE_PURE
		}
		ApplyDamage(damageTable)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damageTable.damage, attacker) -- see https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Panorama/Javascript/API#DOTA_OVERHEAD_ALERT
		-- TODO: find better way to mitigate the original damage than heal.
		-- Currently it would be influenced by AA ultimate or Oracle ultimate.
		local damage_to_heal = get_mitigiated_damage()
		if damage_to_heal > 0 then
			target:Heal(damage_to_heal, attacker)
		end
		local particle_index = ParticleManager:CreateParticle( "particles/econ/events/ti4/blink_dagger_start_ti4.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:ReleaseParticleIndex(particle_index)
	end
end

function intcore_improve_autoattack_modifier:OnAttack(keys)
	attacker = self:GetParent()
	if keys.attacker == attacker and attacker:GetTeam() ~= keys.target:GetTeam() and is_valid_target(keys.target) then
		if attacker:GetMana() > self.mana_cost then
			attacker:SpendMana(self.mana_cost, self:GetAbility())
		end
	end
end