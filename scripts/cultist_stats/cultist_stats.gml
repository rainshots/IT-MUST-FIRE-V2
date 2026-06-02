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
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		_stats.hp = BALANCE_BRUTE_HP;
		_stats.armor = BALANCE_BRUTE_ARMOR;
		_stats.damage = BALANCE_BRUTE_DAMAGE;
		_stats.aoe_radius = BALANCE_BRUTE_AOE_RADIUS;
		_stats.crit_chance = BALANCE_BRUTE_CRIT_CHANCE;
		_stats.attack_speed = BALANCE_BRUTE_ATTACK_SPEED;
		_stats.abilities_cd_spd = BALANCE_BRUTE_ABILITIES_CD_SPD;
		_stats.exp_effectiveness = BALANCE_BRUTE_EXP_EFFECTIVENESS;
		_stats.magic_effectiveness = BALANCE_BRUTE_MAGIC_EFFECTIVENESS;
		_stats.resistance = BALANCE_BRUTE_RESISTANCE;
		_stats.attack_radius = BALANCE_BRUTE_ATTACK_RADIUS;
		_stats.move_speed = BALANCE_BRUTE_MOVE_SPEED;
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

function cultist_day_health_apply(_cultist, _heal_to_full)
{
	if (!instance_exists(_cultist)
		|| !variable_instance_exists(_cultist, "demon_type")
		|| _cultist.demon_type == DEMON_TYPE.NONE
		|| !variable_instance_exists(_cultist, "cultist_points"))
	{
		return;
	}

	var _stats = cultist_calculated_stats_get(_cultist.demon_type, _cultist.cultist_points);
	var _current_hp = _stats.hp;

	if (!_heal_to_full && variable_instance_exists(_cultist, "hp"))
	{
		_current_hp = _cultist.hp;
	}

	_cultist.max_hp = _stats.hp;
	_cultist.hp = clamp(_current_hp, 0, _cultist.max_hp);
}

function cultist_level_exp_required_get(_level)
{
	return BALANCE_CULTIST_LEVEL_EXP_BASE + (max(1, _level) - 1) * BALANCE_CULTIST_LEVEL_EXP_STEP;
}

function cultist_exp_add(_cultist, _exp_amount)
{
	if (!instance_exists(_cultist)
		|| !variable_instance_exists(_cultist, "current_exp")
		|| !variable_instance_exists(_cultist, "current_lvl"))
	{
		return false;
	}

	if (!variable_instance_exists(_cultist, "pending_level_points"))
	{
		_cultist.pending_level_points = 0;
	}

	if (!variable_instance_exists(_cultist, "pending_passive_choices"))
	{
		_cultist.pending_passive_choices = 0;
	}

	if (!variable_instance_exists(_cultist, "pending_active_choices"))
	{
		_cultist.pending_active_choices = 0;
	}

	var _leveled_up = false;
	var _exp_multiplier = 1;

	if (variable_instance_exists(_cultist, "exp_effectiveness"))
	{
		_exp_multiplier = _cultist.exp_effectiveness;
	}
	else if (variable_instance_exists(_cultist, "demon_type")
		&& _cultist.demon_type != DEMON_TYPE.NONE
		&& variable_instance_exists(_cultist, "cultist_points"))
	{
		var _stats = cultist_calculated_stats_get(_cultist.demon_type, _cultist.cultist_points);
		_exp_multiplier = _stats.exp_effectiveness;
	}

	var _gained_exp = _exp_amount * max(0, _exp_multiplier);

	_cultist.current_exp += _gained_exp;

	for (var _levelup_guard = 0; _levelup_guard < 100; ++_levelup_guard)
	{
		var _required_exp = cultist_level_exp_required_get(_cultist.current_lvl);

		if (_cultist.current_exp < _required_exp)
		{
			break;
		}

		_cultist.current_exp -= _required_exp;
		_cultist.current_lvl++;

		if (_cultist.current_lvl == BALANCE_CULTIST_PASSIVE_CHOICE_LEVEL_1
			|| _cultist.current_lvl == BALANCE_CULTIST_PASSIVE_CHOICE_LEVEL_2)
		{
			_cultist.pending_passive_choices++;
		}
		else if (_cultist.current_lvl == BALANCE_CULTIST_ACTIVE_CHOICE_LEVEL)
		{
			_cultist.pending_active_choices++;
		}
		else
		{
			_cultist.pending_level_points++;
		}

		_leveled_up = true;
	}

	return _leveled_up;
}

function cultist_level_reward_type_get(_cultist)
{
	if (instance_exists(_cultist)
		&& variable_instance_exists(_cultist, "pending_passive_choices")
		&& _cultist.pending_passive_choices > 0)
	{
		return CULTIST_LEVEL_REWARD.PASSIVE;
	}

	if (instance_exists(_cultist)
		&& variable_instance_exists(_cultist, "pending_active_choices")
		&& _cultist.pending_active_choices > 0)
	{
		return CULTIST_LEVEL_REWARD.ACTIVE;
	}

	return CULTIST_LEVEL_REWARD.ATTRIBUTE;
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
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		return "Brute";
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
	else if (_demon_type == DEMON_TYPE.BRUTE)
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
		+ "\nXP Gain: " + string(_stats.exp_effectiveness)
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
		return "Passive abilities:"
			+ "\n- Blood Frenzy: kills give stacking speed and crit for " + string(BALANCE_IMP_BLOOD_FRENZY_DURATION) + " sec"
			+ "\n- Hellbleed: critical hits apply Bleed for " + string(BALANCE_IMP_HELLBLEED_DURATION) + " sec"
			+ "\n- Taste of Fear: +" + string((BALANCE_IMP_TASTE_OF_FEAR_DAMAGE_MULTIPLIER - 1) * 100) + "% damage against disabled enemies"
			+ "\nActive abilities:"
			+ "\n- Demon Leap: jumps to the lowest HP enemy and crits"
			+ "\n- Sacrificial Rush: spends HP for speed and crit"
			+ "\n- Bloody Clone: leaves a short-lived copy and jumps away";
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return "Passive abilities:"
			+ "\n- Soul Harvester: attacks apply Soul Mark for " + string(BALANCE_WARLOCK_SOUL_HARVESTER_MARK_TIME) + " sec"
			+ "\n- Curseweaver: every " + string(BALANCE_WARLOCK_CURSEWEAVER_ATTACKS_REQUIRED) + "rd attack curses enemies near the target"
			+ "\n- Demonic Infusion: nearby allies gain +" + string(BALANCE_WARLOCK_DEMONIC_INFUSION_ATTACK_SPEED_BONUS * 100) + "% attack speed"
			+ "\nActive abilities:"
			+ "\n- Raise Lesser Demon: spends nearby meat to summon a Pitling"
			+ "\n- Soul Chain: links enemies and shares damage"
			+ "\n- Hex Totem: creates a temporary curse totem";
	}
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		return "Passive abilities:"
			+ "\n- Corpse Eater: eats nearby meat to heal " + string(BALANCE_BRUTE_CORPSE_EATER_HEAL_MAX_HP_SHARE * 100) + "% HP"
			+ "\n- Rotten Aura: nearby enemies take constant magic damage"
			+ "\n- Cursed Flesh: cursed enemies near Brute drop meat more often"
			+ "\nActive abilities:"
			+ "\n- Grave Slam: AOE damage and stun"
			+ "\n- Meat Hook: pulls the highest HP enemy"
			+ "\n- Devour: executes low HP enemies";
	}

	return "";
}

function cultist_demon_passive_abilities_get(_demon_type)
{
	if (_demon_type == DEMON_TYPE.IMP)
	{
		return [
			DEMON_ABILITY.IMP_FRENZY,
			DEMON_ABILITY.IMP_BLOOD_RAGE,
			DEMON_ABILITY.IMP_CANNON_ECHO
		];
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return [
			DEMON_ABILITY.WARLOCK_SOUL_HARVESTER,
			DEMON_ABILITY.WARLOCK_CURSEWEAVER,
			DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION
		];
	}
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		return [
			DEMON_ABILITY.BRUTE_CORPSE_EATER,
			DEMON_ABILITY.BRUTE_ROTTEN_AURA,
			DEMON_ABILITY.BRUTE_CURSED_FLESH
		];
	}

	return [];
}

function cultist_demon_active_abilities_get(_demon_type)
{
	if (_demon_type == DEMON_TYPE.IMP)
	{
		return [
			DEMON_ABILITY.IMP_DEMON_LEAP,
			DEMON_ABILITY.IMP_SACRIFICIAL_RUSH,
			DEMON_ABILITY.IMP_BLOODY_CLONE
		];
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return [
			DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON,
			DEMON_ABILITY.WARLOCK_SOUL_CHAIN,
			DEMON_ABILITY.WARLOCK_HEX_TOTEM
		];
	}
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		return [
			DEMON_ABILITY.BRUTE_GRAVE_SLAM,
			DEMON_ABILITY.BRUTE_MEAT_HOOK,
			DEMON_ABILITY.BRUTE_DEVOUR
		];
	}

	return [];
}

function cultist_active_abilities_ensure(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return;
	}

	if (!variable_instance_exists(_cultist, "active_abilities"))
	{
		_cultist.active_abilities = [];

		if (variable_instance_exists(_cultist, "demon_ability")
			&& _cultist.demon_ability != DEMON_ABILITY.NONE)
		{
			array_push(_cultist.active_abilities, _cultist.demon_ability);
		}
	}
}

function cultist_active_ability_has(_cultist, _ability)
{
	if (!instance_exists(_cultist) || _ability == DEMON_ABILITY.NONE)
	{
		return false;
	}

	cultist_active_abilities_ensure(_cultist);

	for (var _ability_index = 0; _ability_index < array_length(_cultist.active_abilities); ++_ability_index)
	{
		if (_cultist.active_abilities[_ability_index] == _ability)
		{
			return true;
		}
	}

	return false;
}

function cultist_passive_ability_has(_cultist, _ability)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	if (_ability == DEMON_ABILITY.IMP_FRENZY)
	{
		return variable_instance_exists(_cultist, "has_imp_blood_frenzy") && _cultist.has_imp_blood_frenzy;
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOOD_RAGE)
	{
		return variable_instance_exists(_cultist, "has_imp_hellbleed") && _cultist.has_imp_hellbleed;
	}
	else if (_ability == DEMON_ABILITY.IMP_CANNON_ECHO)
	{
		return variable_instance_exists(_cultist, "has_imp_taste_of_fear") && _cultist.has_imp_taste_of_fear;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_EATER)
	{
		return variable_instance_exists(_cultist, "has_brute_corpse_eater") && _cultist.has_brute_corpse_eater;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_ROTTEN_AURA)
	{
		return variable_instance_exists(_cultist, "has_brute_rotten_aura") && _cultist.has_brute_rotten_aura;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CURSED_FLESH)
	{
		return variable_instance_exists(_cultist, "has_brute_cursed_flesh") && _cultist.has_brute_cursed_flesh;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_HARVESTER)
	{
		return variable_instance_exists(_cultist, "has_warlock_soul_harvester") && _cultist.has_warlock_soul_harvester;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_CURSEWEAVER)
	{
		return variable_instance_exists(_cultist, "has_warlock_curseweaver") && _cultist.has_warlock_curseweaver;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION)
	{
		return variable_instance_exists(_cultist, "has_warlock_demonic_infusion") && _cultist.has_warlock_demonic_infusion;
	}

	return false;
}

function cultist_ability_options_roll(_cultist, _is_passive)
{
	if (!instance_exists(_cultist) || !variable_instance_exists(_cultist, "demon_type"))
	{
		return [];
	}

	var _source_abilities = cultist_demon_active_abilities_get(_cultist.demon_type);
	var _available_abilities = [];

	if (_is_passive)
	{
		_source_abilities = cultist_demon_passive_abilities_get(_cultist.demon_type);
	}

	for (var _source_index = 0; _source_index < array_length(_source_abilities); ++_source_index)
	{
		var _ability = _source_abilities[_source_index];
		var _already_owned = cultist_active_ability_has(_cultist, _ability);

		if (_is_passive)
		{
			_already_owned = cultist_passive_ability_has(_cultist, _ability);
		}

		if (!_already_owned)
		{
			array_push(_available_abilities, _ability);
		}
	}

	var _options = [];
	var _option_count = min(2, array_length(_available_abilities));

	for (var _option_index = 0; _option_index < _option_count; ++_option_index)
	{
		var _roll_index = irandom(array_length(_available_abilities) - 1);
		array_push(_options, _available_abilities[_roll_index]);
		array_delete(_available_abilities, _roll_index, 1);
	}

	return _options;
}

function cultist_passive_ability_unlock(_cultist, _ability)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	if (_ability == DEMON_ABILITY.IMP_FRENZY)
	{
		_cultist.has_imp_blood_frenzy = true;
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOOD_RAGE)
	{
		_cultist.has_imp_hellbleed = true;
	}
	else if (_ability == DEMON_ABILITY.IMP_CANNON_ECHO)
	{
		_cultist.has_imp_taste_of_fear = true;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_EATER)
	{
		_cultist.has_brute_corpse_eater = true;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_ROTTEN_AURA)
	{
		_cultist.has_brute_rotten_aura = true;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CURSED_FLESH)
	{
		_cultist.has_brute_cursed_flesh = true;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_HARVESTER)
	{
		_cultist.has_warlock_soul_harvester = true;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_CURSEWEAVER)
	{
		_cultist.has_warlock_curseweaver = true;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION)
	{
		_cultist.has_warlock_demonic_infusion = true;
	}
	else
	{
		return false;
	}

	return true;
}

function cultist_active_ability_unlock(_cultist, _ability)
{
	if (!instance_exists(_cultist)
		|| _ability == DEMON_ABILITY.NONE
		|| cultist_active_ability_has(_cultist, _ability))
	{
		return false;
	}

	array_push(_cultist.active_abilities, _ability);

	if (variable_instance_exists(_cultist, "demon_ability") && _cultist.demon_ability == DEMON_ABILITY.NONE)
	{
		_cultist.demon_ability = _ability;
	}

	return true;
}

function cultist_demon_owned_abilities_text_get(_demon_type, _active_ability)
{
	var _active_name = cultist_ability_name_get(_active_ability);
	var _active_description = cultist_ability_description_get(_active_ability);

	if (_active_ability == DEMON_ABILITY.NONE)
	{
		_active_name = "None";
		_active_description = "No active ability selected.";
	}

	return "Passive abilities:"
		+ "\n- None"
		+ "\nActive ability:"
		+ "\n- " + _active_name + ": " + _active_description;
}

function cultist_owned_abilities_text_get(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return "";
	}

	var _passive_text = "Passive abilities:";
	var _active_text = "Active abilities:";
	var _has_passive = false;
	var _has_active = false;
	var _passive_abilities = cultist_demon_passive_abilities_get(_cultist.demon_type);

	cultist_active_abilities_ensure(_cultist);

	for (var _passive_index = 0; _passive_index < array_length(_passive_abilities); ++_passive_index)
	{
		var _passive_ability = _passive_abilities[_passive_index];

		if (cultist_passive_ability_has(_cultist, _passive_ability))
		{
			_passive_text += "\n- " + cultist_ability_name_get(_passive_ability) + ": " + cultist_ability_description_get(_passive_ability);
			_has_passive = true;
		}
	}

	if (!_has_passive)
	{
		_passive_text += "\n- None";
	}

	for (var _active_index = 0; _active_index < array_length(_cultist.active_abilities); ++_active_index)
	{
		var _active_ability = _cultist.active_abilities[_active_index];

		_active_text += "\n- " + cultist_ability_name_get(_active_ability) + ": " + cultist_ability_description_get(_active_ability);
		_has_active = true;
	}

	if (!_has_active)
	{
		_active_text += "\n- None";
	}

	return _passive_text + "\n" + _active_text;
}

function cultist_starting_ability_get(_cultist, _demon_type)
{
	if (instance_exists(_cultist)
		&& variable_instance_exists(_cultist, "cultist_starting_abilities")
		&& _demon_type >= 0
		&& _demon_type < array_length(_cultist.cultist_starting_abilities))
	{
		return _cultist.cultist_starting_abilities[_demon_type];
	}

	return cultist_ability_roll(_demon_type);
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
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		return o_brute;
	}

	return noone;
}

function cultist_ability_roll(_demon_type)
{
	if (_demon_type == DEMON_TYPE.IMP)
	{
		var _imp_abilities = [
			DEMON_ABILITY.IMP_DEMON_LEAP,
			DEMON_ABILITY.IMP_SACRIFICIAL_RUSH,
			DEMON_ABILITY.IMP_BLOODY_CLONE
		];

		return _imp_abilities[irandom(array_length(_imp_abilities) - 1)];
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		var _warlock_abilities = [
			DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON,
			DEMON_ABILITY.WARLOCK_SOUL_CHAIN,
			DEMON_ABILITY.WARLOCK_HEX_TOTEM
		];

		return _warlock_abilities[irandom(array_length(_warlock_abilities) - 1)];
	}
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		var _brute_abilities = [
			DEMON_ABILITY.BRUTE_GRAVE_SLAM,
			DEMON_ABILITY.BRUTE_MEAT_HOOK,
			DEMON_ABILITY.BRUTE_DEVOUR
		];

		return _brute_abilities[irandom(array_length(_brute_abilities) - 1)];
	}

	return DEMON_ABILITY.NONE;
}

function cultist_ability_name_get(_ability)
{
	if (_ability == DEMON_ABILITY.IMP_FRENZY)
	{
		return "Blood Frenzy";
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOOD_RAGE)
	{
		return "Hellbleed";
	}
	else if (_ability == DEMON_ABILITY.IMP_CANNON_ECHO)
	{
		return "Taste of Fear";
	}
	else if (_ability == DEMON_ABILITY.IMP_DEMON_LEAP)
	{
		return "Demon Leap";
	}
	else if (_ability == DEMON_ABILITY.IMP_SACRIFICIAL_RUSH)
	{
		return "Sacrificial Rush";
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOODY_CLONE)
	{
		return "Bloody Clone";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_EATER)
	{
		return "Corpse Eater";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_ROTTEN_AURA)
	{
		return "Rotten Aura";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CURSED_FLESH)
	{
		return "Cursed Flesh";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_GRAVE_SLAM)
	{
		return "Grave Slam";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_MEAT_HOOK)
	{
		return "Meat Hook";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_DEVOUR)
	{
		return "Devour";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_HARVESTER)
	{
		return "Soul Harvester";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_CURSEWEAVER)
	{
		return "Curseweaver";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION)
	{
		return "Demonic Infusion";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON)
	{
		return "Raise Lesser Demon";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_CHAIN)
	{
		return "Soul Chain";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_HEX_TOTEM)
	{
		return "Hex Totem";
	}

	return "No Ability";
}

function cultist_ability_description_get(_ability)
{
	if (_ability == DEMON_ABILITY.IMP_FRENZY)
	{
		return "Kills give stacking attack speed, move speed, and crit chance.";
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOOD_RAGE)
	{
		return "Critical hits apply Bleed.";
	}
	else if (_ability == DEMON_ABILITY.IMP_CANNON_ECHO)
	{
		return "Deals more damage to enemies with negative status effects.";
	}
	else if (_ability == DEMON_ABILITY.IMP_DEMON_LEAP)
	{
		return "Jumps to the lowest HP enemy and lands a critical hit.";
	}
	else if (_ability == DEMON_ABILITY.IMP_SACRIFICIAL_RUSH)
	{
		return "Spends HP for attack speed and crit chance, then heals on kills.";
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOODY_CLONE)
	{
		return "Leaves a short-lived copy and jumps to the farthest enemy.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_EATER)
	{
		return "Eats nearby meat to restore health.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_ROTTEN_AURA)
	{
		return "Nearby enemies take constant magic damage.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CURSED_FLESH)
	{
		return "Cursed enemies near Brute drop meat more often.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_GRAVE_SLAM)
	{
		return "Damages and stuns enemies around the Brute.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_MEAT_HOOK)
	{
		return "Pulls the highest HP enemy and forces it to attack the Brute.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_DEVOUR)
	{
		return "Executes a nearby low HP enemy and creates meat.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_HARVESTER)
	{
		return "Attacks apply Soul Mark.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_CURSEWEAVER)
	{
		return "Every third attack curses enemies near the target.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION)
	{
		return "Nearby allies gain attack speed.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON)
	{
		return "Consumes nearby meat to summon a Pitling.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_CHAIN)
	{
		return "Links enemies so part of damage spreads through the chain.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_HEX_TOTEM)
	{
		return "Places a temporary totem that repeatedly applies Curse.";
	}

	return "";
}

function cultist_ability_cooldown_get(_ability)
{
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
