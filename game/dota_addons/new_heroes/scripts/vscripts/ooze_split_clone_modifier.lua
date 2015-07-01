ooze_split_clone_modifier = class({})

function ooze_split_clone_modifier:IsHidden()
	return true
end

function ooze_split_clone_modifier:IsPurgable()
	return false
end

function ooze_split_clone_modifier:IsPurgeException()
	return false
end

function ooze_split_clone_modifier:OnDestroy()
	print("destroy ooze split modifier")
end

function ooze_split_clone_modifier:OnCreated(keys)
	self.heal_amount = keys.heal_amount
	if IsServer() then
		self.time_to_death = keys.time_to_death
		local parent = self:GetParent()
		local str = parent:GetStrength()
		parent:ModifyStrength(-str * (1 - keys.stat_ratio)) 
		local int = parent:GetBaseIntellect()
		parent:ModifyIntellect(-int * (1 - keys.stat_ratio)) 
		local agi = parent:GetBaseAgility()
		parent:ModifyAgility(-agi * (1 - keys.stat_ratio)) 
		parent:SetHasInventory(false)
		
		self:OnIntervalThink()
		self:StartIntervalThink(1)
	end
end

function ooze_split_clone_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_START
	}
	return funcs
end

function ooze_split_clone_modifier:CheckState()
	local state = {
	[MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
	[MODIFIER_STATE_MUTED] = true, -- so it cant use items
	}
	return state
end

function ooze_split_clone_modifier:OnIntervalThink()
	local parent = self:GetParent()
	local player = parent:GetPlayerOwner()
	-- SendOverheadEventMessage(player, OVERHEAD_ALERT_MANA_ADD, parent, self.time_to_death, player)
	self.time_to_death = self.time_to_death - 1
end

function ooze_split_clone_modifier:OnTakeDamage(keys)
	-- Remove the unit if it dies so it does not count as a kill and no gold, bounty, respawn happens.
	parent = self:GetParent()
	if keys.unit == parent then
		if keys.damage >= parent:GetHealth() then
			UTIL_Remove(parent)
		end
	end
end

function ooze_split_clone_modifier:OnAttackLanded(keys)
	-- Absorb behaviour
	caster = self:GetCaster()
	parent = self:GetParent()
	if keys.target == parent and keys.attacker == caster then
		caster:Heal(self.heal_amount, caster)
		UTIL_Remove(parent)
	end
end

function ooze_split_clone_modifier:OnAttackStart(keys)
	-- Dont allow other team members to attack it
	caster = self:GetCaster()
	parent = self:GetParent()
	if keys.target == parent and keys.attacker:GetTeam() == parent:GetTeam() and keys.attacker ~= caster then
		keys.attacker:Stop()
	end
end