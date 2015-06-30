-- check for proximity to these dummy units in main ability
ooze_digestive_acid_thinker_modifier = class({})

function ooze_digestive_acid_thinker_modifier:OnCreated(keys)
	if IsServer() then
		self.initial_aoe = keys.initial_aoe
		self.aoe_increase_nonhero = keys.aoe_increase_nonhero
		self.aoe_increase_hero = keys.aoe_increase_hero

		self.dps_max_hp_initial_ratio = keys.dps_max_hp_initial_ratio
		self.dps_max_hp_per_nonhero = keys.dps_max_hp_per_nonhero
		self.dps_max_hp_per_hero = keys.dps_max_hp_per_hero

		self.num_nonhero_died = 0
		self.num_hero_died = 0
		
		self.interval_time = 0.3
		self:StartIntervalThink(self.interval_time)
		
		local particle_index = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(particle_index)
	end
end

function ooze_digestive_acid_thinker_modifier:get_aoe()
	return self.initial_aoe + self.num_nonhero_died * self.aoe_increase_nonhero + self.num_hero_died * self.aoe_increase_hero
end

function ooze_digestive_acid_thinker_modifier:get_dps()
	return self:GetCaster():GetMaxHealth() * (self.dps_max_hp_initial_ratio + self.num_nonhero_died * self.dps_max_hp_per_nonhero + self.num_hero_died * self.dps_max_hp_per_hero)
end

function ooze_digestive_acid_thinker_modifier:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

function ooze_digestive_acid_thinker_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function ooze_digestive_acid_thinker_modifier:OnDeath(keys)
	local function vec_distance(vec1,vec2)
		return math.sqrt(math.pow(vec2.x-vec1.x,2)+math.pow(vec2.y-vec1.y,2))
	end
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local recalc_stats = false
	if vec_distance(keys.unit:GetOrigin(), parent:GetOrigin()) <= self:get_aoe() then
		if keys.unit:IsConsideredHero() then
			self.num_hero_died = self.num_hero_died + 1
		else
			self.num_nonhero_died = self.num_nonhero_died + 1
		end
		if keys.unit:GetTeam() ~= parent:GetTeam() then
			caster:FindModifierByName("ooze_digestive_acid_hp_bonus_modifier"):IncrementStackCount()
			recalc_stats = true
		end
	end
	if recalc_stats then caster:CalculateStatBonus() end
end

function ooze_digestive_acid_thinker_modifier:OnIntervalThink()
	local parent = self:GetParent()
	local position = parent:GetOrigin()
	local friendly_team = parent:GetTeam()
	local enemy_team = nil
	DebugDrawCircle(position, Vector(0, 255, 0), 0, self:get_aoe(), false, self.interval_time)
	local damage = self:get_dps() * self.interval_time
	if friendly_team == DOTA_TEAM_GOODGUYS then	enemy_team = DOTA_TEAM_BADGUYS else enemy_team = DOTA_TEAM_GOODGUYS end
	for k,v in pairs(FindUnitsInRadius(friendly_team, position, nil, self:get_aoe(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, FIND_ANY_ORDER, false)) do
		local damageTable = {
			victim = v,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		}
		ApplyDamage(damageTable)
	end
	-- TODO: how to get a particle that appropriately shows the changing radius?
	local particle_index = ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green_smoke03.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:ReleaseParticleIndex(particle_index)
end