/// @description Helper functions for cultist attributes, demon forms, and derived stats.

function cultist_points_roll()
{
	var _total_points = irandom_range(9, 11);
	var _points = array_create(CULTIST_STAT.COUNT, 0);

	for (var _point_index = 0; _point_index < _total_points; ++_point_index)
	{
		var _stat_index = irandom(CULTIST_STAT.COUNT - 1);
		_points[_stat_index]++;
	}

	return _points;
}

function cultist_base_stats_get(_demon_type)
{
	var _stats = {
		hp: 1,
		armor: 100,
		damage: 1,
		magic_damage: 0,
		aoe_radius: 0,
		crit_chance: 0,
		attack_speed: 1,
		abilities_cd_spd: 1,
		exp_effectiveness: 1,
		magic_effectiveness: 1,
		resistance: 1,
		attack_radius: 34,
		move_speed: 1.2
	};

	if (_demon_type == DEMON_TYPE.IMP)
	{
		_stats.hp = BALANCE_IMP_HP;
		_stats.armor = BALANCE_IMP_ARMOR;
		_stats.damage = BALANCE_IMP_DAMAGE;
		_stats.crit_chance = BALANCE_IMP_CRIT_CHANCE;
		_stats.attack_speed = BALANCE_IMP_ATTACK_SPEED;
		_stats.abilities_cd_spd = BALANCE_IMP_ABILITIES_CD_SPD;
		_stats.exp_effectiveness = BALANCE_IMP_EXP_EFFECTIVENESS;
		_stats.magic_effectiveness = BALANCE_IMP_MAGIC_EFFECTIVENESS;
		_stats.resistance = BALANCE_IMP_RESISTANCE;
		_stats.attack_radius = BALANCE_IMP_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_IMP_MOVE_SPEED;
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		_stats.hp = BALANCE_WARLOCK_HP;
		_stats.armor = BALANCE_WARLOCK_ARMOR;
		_stats.damage = 0;
		_stats.magic_damage = BALANCE_WARLOCK_MAGIC_DAMAGE;
		_stats.crit_chance = BALANCE_WARLOCK_CRIT_CHANCE;
		_stats.attack_speed = BALANCE_WARLOCK_ATTACK_SPEED;
		_stats.abilities_cd_spd = BALANCE_WARLOCK_ABILITIES_CD_SPD;
		_stats.exp_effectiveness = BALANCE_WARLOCK_EXP_EFFECTIVENESS;
		_stats.magic_effectiveness = BALANCE_WARLOCK_MAGIC_EFFECTIVENESS;
		_stats.resistance = BALANCE_WARLOCK_RESISTANCE;
		_stats.attack_radius = BALANCE_WARLOCK_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_WARLOCK_MOVE_SPEED;
	}
	else if (_demon_type == DEMON_TYPE.ZOMBIE)
	{
		_stats.hp = BALANCE_ZOMBIE_HP;
		_stats.armor = BALANCE_ZOMBIE_ARMOR;
		_stats.damage = BALANCE_ZOMBIE_DAMAGE;
		_stats.aoe_radius = BALANCE_ZOMBIE_AOE_RADIUS;
		_stats.crit_chance = BALANCE_ZOMBIE_CRIT_CHANCE;
		_stats.attack_speed = BALANCE_ZOMBIE_ATTACK_SPEED;
		_stats.abilities_cd_spd = BALANCE_ZOMBIE_ABILITIES_CD_SPD;
		_stats.exp_effectiveness = BALANCE_ZOMBIE_EXP_EFFECTIVENESS;
		_stats.magic_effectiveness = BALANCE_ZOMBIE_MAGIC_EFFECTIVENESS;
		_stats.resistance = BALANCE_ZOMBIE_RESISTANCE;
		_stats.attack_radius = BALANCE_ZOMBIE_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_ZOMBIE_MOVE_SPEED;
	}

	return _stats;
}

function cultist_stat_get(_base_value, _points, _point_bonus, _coefficient)
{
	return _base_value * (1 + (_points * _point_bonus)) * _coefficient;
}

function cultist_calculated_stats_get(_demon_type, _points)
{
	var _base_stats = cultist_base_stats_get(_demon_type);
	var _body = _points[CULTIST_STAT.BODY];
	var _spirit = _points[CULTIST_STAT.SPIRIT];
	var _fervor = _points[CULTIST_STAT.FERVOR];

	return {
		hp: cultist_stat_get(_base_stats.hp, _body, 0.05, 1),
		armor: min(cultist_stat_get(_base_stats.armor, _body, 0.05, 1), 190),
		damage: cultist_stat_get(_base_stats.damage, _body, 0.05, 1),
		magic_damage: cultist_stat_get(_base_stats.magic_damage, _spirit, 0.05, 1),
		aoe_radius: _base_stats.aoe_radius,
		crit_chance: clamp(cultist_stat_get(_base_stats.crit_chance, _fervor, 0.05, 1), 0, 1),
		attack_speed: cultist_stat_get(_base_stats.attack_speed, _fervor, 0.07, 1),
		abilities_cd_spd: cultist_stat_get(_base_stats.abilities_cd_spd, _fervor, 0.07, 1),
		exp_effectiveness: cultist_stat_get(_base_stats.exp_effectiveness, _spirit, 0.07, 1),
		magic_effectiveness: cultist_stat_get(_base_stats.magic_effectiveness, _spirit, 0.07, 1),
		resistance: cultist_stat_get(_base_stats.resistance, _spirit, 0.07, 1)
	};
}

function cultist_demon_name_get(_demon_type)
{
	if (_demon_type == DEMON_TYPE.IMP)
	{
		return "Imp";
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return "Warlock";
	}
	else if (_demon_type == DEMON_TYPE.ZOMBIE)
	{
		return "Zombie";
	}

	return "None";
}

function cultist_demon_description_get(_demon_type)
{
	if (_demon_type == DEMON_TYPE.IMP)
	{
		return "Fast melee fighter.";
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return "Ranged caster with magic orbs.";
	}
	else if (_demon_type == DEMON_TYPE.ZOMBIE)
	{
		return "Slow tank with area attacks.";
	}

	return "";
}

function cultist_demon_stats_text_get(_demon_type)
{
	var _stats = cultist_base_stats_get(_demon_type);
	var _damage_text = "\nPhysical damage: " + string(_stats.damage);

	if (_stats.magic_damage > 0)
	{
		_damage_text = "\nMagic damage: " + string(_stats.magic_damage);
	}

	var _text = "HP: " + string(_stats.hp)
		+ "\nArmor: " + string_format(_stats.armor - 100, 0, 1) + "%"
		+ _damage_text
		+ "\nCrit chance: " + string_format(_stats.crit_chance * 100, 0, 1) + "%"
		+ "\nAttack speed: " + string(_stats.attack_speed)
		+ "\nAbility Recharge: " + string(_stats.abilities_cd_spd)
		+ "\nExp: " + string(_stats.exp_effectiveness)
		+ "\nMagic power: " + string(_stats.magic_effectiveness)
		+ "\nResistance: " + string(_stats.resistance);

	if (_stats.aoe_radius > 0)
	{
		_text += "\nAoe radius: " + string(_stats.aoe_radius);
	}

	return _text;
}

function cultist_demon_abilities_text_get(_demon_type)
{
	if (_demon_type == DEMON_TYPE.IMP)
	{
		return "Random ability:"
			+ "\n- Frenzy: x2 attack speed for " + string(BALANCE_ABILITY_IMP_FRENZY_DURATION) + " sec every " + string(BALANCE_ABILITY_IMP_FRENZY_COOLDOWN) + " sec"
			+ "\n- Blood Rage: x" + string(BALANCE_ABILITY_IMP_BLOOD_RAGE_DAMAGE_MULTIPLIER) + " damage below " + string(BALANCE_ABILITY_IMP_BLOOD_RAGE_HP_THRESHOLD * 100) + "% HP"
			+ "\n- Cannon Echo: +100% base attack speed after cannon fire";
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return "Random ability:"
			+ "\n- Curse: -30% enemy armor for " + string(BALANCE_ABILITY_WARLOCK_CURSE_DURATION) + " sec every " + string(BALANCE_ABILITY_WARLOCK_CURSE_COOLDOWN) + " sec"
			+ "\n- Summon Skeleton: 1 temporary skeleton every " + string(BALANCE_ABILITY_WARLOCK_SUMMON_SKELETON_COOLDOWN) + " sec";
	}
	else if (_demon_type == DEMON_TYPE.ZOMBIE)
	{
		return "Random ability:"
			+ "\n- Poison Aura: nearby enemies take magic damage"
			+ "\n- Mega Strike: next hit x" + string(BALANCE_ABILITY_ZOMBIE_MEGA_STRIKE_DAMAGE_MULTIPLIER) + " damage and x" + string(BALANCE_ABILITY_ZOMBIE_MEGA_STRIKE_AOE_MULTIPLIER) + " AOE every " + string(BALANCE_ABILITY_ZOMBIE_MEGA_STRIKE_COOLDOWN) + " sec";
	}

	return "";
}

function cultist_demon_object_get(_demon_type)
{
	if (_demon_type == DEMON_TYPE.IMP)
	{
		return o_imp;
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return o_warlock;
	}
	else if (_demon_type == DEMON_TYPE.ZOMBIE)
	{
		return o_zombie;
	}

	return noone;
}

function cultist_ability_roll(_demon_type)
{
	if (_demon_type == DEMON_TYPE.IMP)
	{
		var _imp_abilities = [
			DEMON_ABILITY.IMP_FRENZY,
			DEMON_ABILITY.IMP_BLOOD_RAGE,
			DEMON_ABILITY.IMP_CANNON_ECHO
		];

		return _imp_abilities[irandom(array_length(_imp_abilities) - 1)];
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		var _warlock_abilities = [
			DEMON_ABILITY.WARLOCK_CURSE,
			DEMON_ABILITY.WARLOCK_SUMMON_SKELETON
		];

		return _warlock_abilities[irandom(array_length(_warlock_abilities) - 1)];
	}
	else if (_demon_type == DEMON_TYPE.ZOMBIE)
	{
		var _zombie_abilities = [
			DEMON_ABILITY.ZOMBIE_POISON_AURA,
			DEMON_ABILITY.ZOMBIE_MEGA_STRIKE
		];

		return _zombie_abilities[irandom(array_length(_zombie_abilities) - 1)];
	}

	return DEMON_ABILITY.NONE;
}

function cultist_ability_name_get(_ability)
{
	if (_ability == DEMON_ABILITY.IMP_FRENZY)
	{
		return "Frenzy";
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOOD_RAGE)
	{
		return "Blood Rage";
	}
	else if (_ability == DEMON_ABILITY.IMP_CANNON_ECHO)
	{
		return "Cannon Echo";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_CURSE)
	{
		return "Curse";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SUMMON_SKELETON)
	{
		return "Summon Skeleton";
	}
	else if (_ability == DEMON_ABILITY.ZOMBIE_POISON_AURA)
	{
		return "Poison Aura";
	}
	else if (_ability == DEMON_ABILITY.ZOMBIE_MEGA_STRIKE)
	{
		return "Mega Strike";
	}

	return "No Ability";
}

function cultist_ability_description_get(_ability)
{
	if (_ability == DEMON_ABILITY.IMP_FRENZY)
	{
		return "Doubles attack speed for " + string(BALANCE_ABILITY_IMP_FRENZY_DURATION) + " seconds.";
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOOD_RAGE)
	{
		return "Deals x" + string(BALANCE_ABILITY_IMP_BLOOD_RAGE_DAMAGE_MULTIPLIER) + " damage below " + string(BALANCE_ABILITY_IMP_BLOOD_RAGE_HP_THRESHOLD * 100) + "% HP.";
	}
	else if (_ability == DEMON_ABILITY.IMP_CANNON_ECHO)
	{
		return "Gains attack speed after cannon fire for " + string(BALANCE_ABILITY_IMP_CANNON_ECHO_DURATION) + " seconds.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_CURSE)
	{
		return "Reduces enemy armor in radius for " + string(BALANCE_ABILITY_WARLOCK_CURSE_DURATION) + " seconds.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SUMMON_SKELETON)
	{
		return "Summons a temporary skeleton for " + string(BALANCE_ABILITY_WARLOCK_SKELETON_LIFE_TIME) + " seconds.";
	}
	else if (_ability == DEMON_ABILITY.ZOMBIE_POISON_AURA)
	{
		return "Periodically damages enemies around the zombie.";
	}
	else if (_ability == DEMON_ABILITY.ZOMBIE_MEGA_STRIKE)
	{
		return "Next attack deals x" + string(BALANCE_ABILITY_ZOMBIE_MEGA_STRIKE_DAMAGE_MULTIPLIER) + " damage with x" + string(BALANCE_ABILITY_ZOMBIE_MEGA_STRIKE_AOE_MULTIPLIER) + " AOE.";
	}

	return "";
}

function cultist_ability_cooldown_get(_ability)
{
	if (_ability == DEMON_ABILITY.IMP_FRENZY || _ability == DEMON_ABILITY.ZOMBIE_MEGA_STRIKE)
	{
		if (_ability == DEMON_ABILITY.IMP_FRENZY)
		{
			return BALANCE_ABILITY_IMP_FRENZY_COOLDOWN;
		}

		return BALANCE_ABILITY_ZOMBIE_MEGA_STRIKE_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_CURSE)
	{
		return BALANCE_ABILITY_WARLOCK_CURSE_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SUMMON_SKELETON)
	{
		return BALANCE_ABILITY_WARLOCK_SUMMON_SKELETON_COOLDOWN;
	}

	return 0;
}

function cultist_stats_apply(_unit)
{
	var _points = _unit.cultist_points;
	var _base_stats = cultist_base_stats_get(_unit.demon_type);
	var _body = _points[CULTIST_STAT.BODY];
	var _spirit = _points[CULTIST_STAT.SPIRIT];
	var _fervor = _points[CULTIST_STAT.FERVOR];

	_unit.base_hp = _base_stats.hp;
	_unit.base_armor = _base_stats.armor;
	_unit.base_damage = _base_stats.damage;
	_unit.base_magic_damage = _base_stats.magic_damage;
	_unit.base_aoe_radius = _base_stats.aoe_radius;
	_unit.base_crit_chance = _base_stats.crit_chance;
	_unit.base_attack_speed = _base_stats.attack_speed;
	_unit.base_abilities_cd_spd = _base_stats.abilities_cd_spd;
	_unit.base_exp_effectiveness = _base_stats.exp_effectiveness;
	_unit.base_magic_effectiveness = _base_stats.magic_effectiveness;
	_unit.base_resistance = _base_stats.resistance;

	_unit.hp_coefficient = 1;
	_unit.armor_coefficient = 1;
	_unit.damage_coefficient = 1;
	_unit.magic_damage_coefficient = 1;
	_unit.crit_chance_coefficient = 1;
	_unit.attack_speed_coefficient = 1;
	_unit.abilities_cd_spd_coefficient = 1;
	_unit.exp_effectiveness_coefficient = 1;
	_unit.magic_effectiveness_coefficient = 1;
	_unit.resistance_coefficient = 1;

	_unit.max_hp = cultist_stat_get(_unit.base_hp, _body, 0.05, _unit.hp_coefficient);
	_unit.hp = _unit.max_hp;
	_unit.armor = min(cultist_stat_get(_unit.base_armor, _body, 0.05, _unit.armor_coefficient), 190);
	_unit.damage = cultist_stat_get(_unit.base_damage, _body, 0.05, _unit.damage_coefficient);
	_unit.magic_damage = cultist_stat_get(_unit.base_magic_damage, _spirit, 0.05, _unit.magic_damage_coefficient);
	_unit.crit_chance = clamp(cultist_stat_get(_unit.base_crit_chance, _fervor, 0.05, _unit.crit_chance_coefficient), 0, 1);
	_unit.attack_speed = cultist_stat_get(_unit.base_attack_speed, _fervor, 0.07, _unit.attack_speed_coefficient);
	_unit.abilities_cd_spd = cultist_stat_get(_unit.base_abilities_cd_spd, _fervor, 0.07, _unit.abilities_cd_spd_coefficient);
	_unit.exp_effectiveness = cultist_stat_get(_unit.base_exp_effectiveness, _spirit, 0.07, _unit.exp_effectiveness_coefficient);
	_unit.magic_effectiveness = cultist_stat_get(_unit.base_magic_effectiveness, _spirit, 0.07, _unit.magic_effectiveness_coefficient);
	_unit.resistance = cultist_stat_get(_unit.base_resistance, _spirit, 0.07, _unit.resistance_coefficient);
	_unit.aoe_radius = _unit.base_aoe_radius;
	_unit.reload_time = max(room_speed / max(_unit.attack_speed, 0.1), 1);
	_unit.attack_radius = _base_stats.attack_radius;
	_unit.move_speed = _base_stats.move_speed;
}
