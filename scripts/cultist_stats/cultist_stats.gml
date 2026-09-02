/// @description Helper functions for cultist attributes, demon forms, and derived stats.

function cultist_points_roll()
{
	var _total_points = BALANCE_CULTIST_STARTING_ATTRIBUTE_POINTS;
	var _points = array_create(CULTIST_STAT.COUNT, 0);
	var _weak_stat_index = irandom(CULTIST_STAT.COUNT - 1);
	var _weak_stat_points = irandom_range(0, 2);
	var _remaining_points = _total_points - _weak_stat_points;

	// Make one attribute noticeably weaker so every cultist has a clearer shape.
	_points[_weak_stat_index] = _weak_stat_points;

	for (var _point_index = 0; _point_index < _remaining_points; ++_point_index)
	{
		var _stat_index = irandom(CULTIST_STAT.COUNT - 1);

		if (_stat_index == _weak_stat_index)
		{
			_stat_index = (_weak_stat_index + 1 + irandom(1)) mod CULTIST_STAT.COUNT;
		}

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
		crit_damage: BALANCE_CULTIST_CRIT_DAMAGE_BASE,
		attack_speed: 1,
		abilities_cd_spd: 1,
		exp_effectiveness: 1,
		magic_effectiveness: 1,
		resistance: 100,
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
		hp: cultist_stat_get(_base_stats.hp, _body, BALANCE_CULTIST_BODY_STAT_BONUS, 1),
		armor: min(cultist_stat_get(_base_stats.armor, _body, BALANCE_CULTIST_BODY_STAT_BONUS, 1), 190),
		magic_resistance: min(cultist_stat_get(_base_stats.resistance, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, 1), 190),
		damage: cultist_stat_get(_base_stats.damage, _body, BALANCE_CULTIST_BODY_STAT_BONUS, 1),
		magic_damage: cultist_stat_get(_base_stats.magic_damage, _spirit, BALANCE_CULTIST_MAGIC_DAMAGE_STAT_BONUS, 1),
		aoe_radius: _base_stats.aoe_radius,
		crit_chance: clamp(cultist_stat_get(_base_stats.crit_chance, _fervor, BALANCE_CULTIST_CRIT_CHANCE_STAT_BONUS, 1), 0, 1),
		crit_damage: _base_stats.crit_damage + (_body * BALANCE_CULTIST_CRIT_DAMAGE_PER_BODY),
		attack_speed: cultist_stat_get(_base_stats.attack_speed, _fervor, BALANCE_CULTIST_FERVOR_STAT_BONUS, 1),
		abilities_cd_spd: cultist_stat_get(_base_stats.abilities_cd_spd, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, 1),
		exp_effectiveness: cultist_stat_get(_base_stats.exp_effectiveness, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, 1),
		magic_effectiveness: cultist_stat_get(_base_stats.magic_effectiveness, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, 1),
		resistance: cultist_stat_get(_base_stats.resistance, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, 1),
		move_speed: cultist_stat_get(_base_stats.move_speed, _fervor, BALANCE_CULTIST_FERVOR_STAT_BONUS, 1)
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

function cultist_demon_level_scale_get(_level)
{
	var _level_bonus_count = max(0, _level - 1);
	var _level_scale = 1 + (_level_bonus_count * BALANCE_CULTIST_DEMON_LEVEL_SCALE_BONUS);

	return min(_level_scale, BALANCE_CULTIST_DEMON_LEVEL_SCALE_MAX);
}

function cultist_demon_scale_apply(_demon)
{
	if (!instance_exists(_demon)
		|| _demon.object_index == o_archdemon
		|| !variable_instance_exists(_demon, "demon_type")
		|| _demon.demon_type == DEMON_TYPE.NONE
		|| !variable_instance_exists(_demon, "current_lvl"))
	{
		return;
	}

	if (!variable_instance_exists(_demon, "demon_base_image_xscale"))
	{
		_demon.demon_base_image_xscale = abs(_demon.image_xscale);
		_demon.demon_base_image_yscale = abs(_demon.image_yscale);
	}

	var _level_scale = cultist_demon_level_scale_get(_demon.current_lvl);
	var _x_direction = sign(_demon.image_xscale);
	var _y_direction = sign(_demon.image_yscale);

	if (_x_direction == 0)
	{
		_x_direction = 1;
	}

	if (_y_direction == 0)
	{
		_y_direction = 1;
	}

	_demon.image_xscale = _x_direction * _demon.demon_base_image_xscale * _level_scale;
	_demon.image_yscale = _y_direction * _demon.demon_base_image_yscale * _level_scale;
}

function cultist_level_add(_cultist)
{
	if (!instance_exists(_cultist)
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

	if (!variable_instance_exists(_cultist, "pending_ability_upgrade_choices"))
	{
		_cultist.pending_ability_upgrade_choices = 0;
	}

	// Apply every reward associated with gaining exactly one level.
	_cultist.current_lvl++;
	cultist_demon_scale_apply(_cultist);
	_cultist.pending_level_points += BALANCE_CULTIST_ATTRIBUTE_POINTS_PER_LEVEL;

	if (_cultist.current_lvl == BALANCE_CULTIST_PASSIVE_CHOICE_LEVEL_1
		|| _cultist.current_lvl == BALANCE_CULTIST_PASSIVE_CHOICE_LEVEL_2)
	{
		_cultist.pending_passive_choices++;
	}
	else if (_cultist.current_lvl == BALANCE_CULTIST_ACTIVE_CHOICE_LEVEL)
	{
		_cultist.pending_active_choices++;
	}
	else if (_cultist.current_lvl >= 4 && array_length(cultist_ability_upgrade_options_roll(_cultist)) > 0)
	{
		_cultist.pending_ability_upgrade_choices++;
	}

	return true;
}

function cultist_exp_add(_cultist, _exp_amount, _apply_effectiveness = true)
{
	if (!instance_exists(_cultist)
		|| !variable_instance_exists(_cultist, "current_exp")
		|| !variable_instance_exists(_cultist, "current_lvl"))
	{
		return false;
	}

	var _leveled_up = false;
	var _exp_multiplier = 1;

	if (_apply_effectiveness && variable_instance_exists(_cultist, "exp_effectiveness"))
	{
		_exp_multiplier = _cultist.exp_effectiveness;
	}
	else if (_apply_effectiveness
		&& variable_instance_exists(_cultist, "demon_type")
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

		if (!cultist_level_add(_cultist))
		{
			break;
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

	if (instance_exists(_cultist)
		&& variable_instance_exists(_cultist, "pending_ability_upgrade_choices")
		&& _cultist.pending_ability_upgrade_choices > 0)
	{
		if (array_length(cultist_ability_upgrade_options_roll(_cultist)) > 0)
		{
			return CULTIST_LEVEL_REWARD.ABILITY_UPGRADE;
		}

		_cultist.pending_ability_upgrade_choices = 0;
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
		return "Fast melee fighter. A versatile soldier, most effective against archers and catapults.";
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return "Ranged caster. Very effective against ranged enemies (archers and mages) and knights. Very weak without melee support.";
	}
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		return "Slow tank with area attacks. Effective against clusters of enemies. Very weak against magic damage.";
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
		+ "\nCrit damage: x" + string_format(_stats.crit_damage, 0, 2)
		+ "\nCrit chance: " + string_format(_stats.crit_chance * 100, 0, 1) + "%"
		+ "\nAttack speed: " + string(_stats.attack_speed)
		+ "\nMove speed: " + string(_stats.move_speed)
		+ "\nAbility Recharge: " + string(_stats.abilities_cd_spd)
		+ "\nXP Gain: " + string(_stats.exp_effectiveness)
		+ "\nMagic power: " + string(_stats.magic_effectiveness)
		+ "\nMagic resistance: " + string_format(min(_stats.resistance - 100, 90), 0, 1) + "%";

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
			+ "\n- Blood Blades: rotating blood knives damage enemies they pass through"
			+ "\n- Frenzy Echo: repeated attacks create phantom Imp strikes"
			+ "\n- Blood Hunger: kills grant short attack speed bursts"
			+ "\nActive abilities:"
			+ "\n- Demon Leap: jumps to the farthest enemy 3 times and crits"
			+ "\n- Bloody Clone: creates temporary Imp copies"
			+ "\n- Crimson Guillotine: crashes down onto the highest HP enemy";
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return "Passive abilities:"
			+ "\n- Demonic Infusion: heals nearby allies and later speeds their attacks"
			+ "\n- Soul Engine: gathers nearby enemy souls and fires homing skulls"
			+ "\n- Familiar: summons demonic familiars that attack nearby enemies"
			+ "\nActive abilities:"
			+ "\n- Summon Skeletons: creates temporary skeletons near Warlock"
			+ "\n- Soul Chain: links enemies and shares damage"
			+ "\n- Hex Totem: creates a temporary beam totem";
	}
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		return "Passive abilities:"
			+ "\n- Corpse Eater: eats nearby corpses to heal " + string(BALANCE_BRUTE_CORPSE_EATER_HEAL_MAX_HP_SHARE * 100) + "% HP"
			+ "\n- Rotten Aura: nearby enemies take constant magic damage"
			+ "\nActive abilities:"
			+ "\n- Grave Slam: AOE damage and stun"
			+ "\n- Butcher Chains: pulls the farthest enemies"
			+ "\n- Corpse Armor: covers Brute in bones and meat";
	}

	return "";
}

function cultist_demon_passive_abilities_get(_demon_type)
{
	if (_demon_type == DEMON_TYPE.IMP)
	{
		return [
			DEMON_ABILITY.IMP_BLOOD_BLADES,
			DEMON_ABILITY.IMP_FRENZY_ECHO,
			DEMON_ABILITY.IMP_BLOOD_HUNGER
		];
	}
	else if (_demon_type == DEMON_TYPE.WARLOCK)
	{
		return [
			DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION,
			DEMON_ABILITY.WARLOCK_SOUL_ENGINE,
			DEMON_ABILITY.WARLOCK_FAMILIAR
		];
	}
	else if (_demon_type == DEMON_TYPE.BRUTE)
	{
		return [
			DEMON_ABILITY.BRUTE_CORPSE_EATER,
			DEMON_ABILITY.BRUTE_ROTTEN_AURA
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
			DEMON_ABILITY.IMP_BLOODY_CLONE,
			DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE
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
			DEMON_ABILITY.BRUTE_BUTCHER_CHAINS,
			DEMON_ABILITY.BRUTE_CORPSE_ARMOR
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

function cultist_ability_levels_ensure(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return;
	}

	if (!variable_instance_exists(_cultist, "ability_levels"))
	{
		_cultist.ability_levels = array_create(DEMON_ABILITY.COUNT, 0);
	}
	else if (array_length(_cultist.ability_levels) < DEMON_ABILITY.COUNT)
	{
		var _old_levels = _cultist.ability_levels;
		_cultist.ability_levels = array_create(DEMON_ABILITY.COUNT, 0);

		for (var _ability_index = 0; _ability_index < array_length(_old_levels); ++_ability_index)
		{
			_cultist.ability_levels[_ability_index] = _old_levels[_ability_index];
		}
	}
}

function cultist_ability_level_get(_cultist, _ability)
{
	if (!instance_exists(_cultist)
		|| _ability <= DEMON_ABILITY.NONE
		|| _ability >= DEMON_ABILITY.COUNT)
	{
		return 0;
	}

	cultist_ability_levels_ensure(_cultist);

	return _cultist.ability_levels[_ability];
}

function cultist_ability_level_set(_cultist, _ability, _level)
{
	if (!instance_exists(_cultist)
		|| _ability <= DEMON_ABILITY.NONE
		|| _ability >= DEMON_ABILITY.COUNT)
	{
		return false;
	}

	cultist_ability_levels_ensure(_cultist);
	_cultist.ability_levels[_ability] = clamp(_level, 0, 4);

	return true;
}

function cultist_ability_level_add(_cultist, _ability)
{
	var _current_level = cultist_ability_level_get(_cultist, _ability);

	if (_current_level >= 4)
	{
		return false;
	}

	return cultist_ability_level_set(_cultist, _ability, _current_level + 1);
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
			if (cultist_ability_level_get(_cultist, _ability) <= 0)
			{
				cultist_ability_level_set(_cultist, _ability, 1);
			}

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

	if (_ability == DEMON_ABILITY.IMP_BLOOD_BLADES
		|| _ability == DEMON_ABILITY.IMP_FRENZY_ECHO
		|| _ability == DEMON_ABILITY.IMP_BLOOD_HUNGER)
	{
		return cultist_ability_level_get(_cultist, _ability) > 0;
	}

	if (_ability == DEMON_ABILITY.BRUTE_CORPSE_EATER)
	{
		return variable_instance_exists(_cultist, "has_brute_corpse_eater") && _cultist.has_brute_corpse_eater;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_ROTTEN_AURA)
	{
		return variable_instance_exists(_cultist, "has_brute_rotten_aura") && _cultist.has_brute_rotten_aura;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_BLOOD_ANVIL)
	{
		return cultist_ability_level_get(_cultist, _ability) > 0;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION
		|| _ability == DEMON_ABILITY.WARLOCK_SOUL_ENGINE
		|| _ability == DEMON_ABILITY.WARLOCK_FAMILIAR)
	{
		return cultist_ability_level_get(_cultist, _ability) > 0;
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

function cultist_ability_upgrade_options_roll(_cultist)
{
	if (!instance_exists(_cultist) || !variable_instance_exists(_cultist, "demon_type"))
	{
		return [];
	}

	var _upgrade_candidates = [];
	var _passive_abilities = cultist_demon_passive_abilities_get(_cultist.demon_type);
	var _active_abilities = cultist_demon_active_abilities_get(_cultist.demon_type);

	cultist_active_abilities_ensure(_cultist);

	for (var _passive_index = 0; _passive_index < array_length(_passive_abilities); ++_passive_index)
	{
		var _passive_ability = _passive_abilities[_passive_index];

		if (cultist_passive_ability_has(_cultist, _passive_ability)
			&& cultist_ability_level_get(_cultist, _passive_ability) < 4)
		{
			array_push(_upgrade_candidates, _passive_ability);
		}
	}

	for (var _active_index = 0; _active_index < array_length(_cultist.active_abilities); ++_active_index)
	{
		var _active_ability = _cultist.active_abilities[_active_index];

		if (_active_ability != DEMON_ABILITY.NONE
			&& cultist_ability_level_get(_cultist, _active_ability) < 4)
		{
			array_push(_upgrade_candidates, _active_ability);
		}
	}

	var _options = [];
	var _option_count = min(2, array_length(_upgrade_candidates));

	for (var _option_index = 0; _option_index < _option_count; ++_option_index)
	{
		var _roll_index = irandom(array_length(_upgrade_candidates) - 1);
		array_push(_options, _upgrade_candidates[_roll_index]);
		array_delete(_upgrade_candidates, _roll_index, 1);
	}

	return _options;
}

function cultist_passive_ability_unlock(_cultist, _ability)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	if (_ability == DEMON_ABILITY.IMP_BLOOD_BLADES
		|| _ability == DEMON_ABILITY.IMP_FRENZY_ECHO
		|| _ability == DEMON_ABILITY.IMP_BLOOD_HUNGER)
	{
		return cultist_ability_level_add(_cultist, _ability);
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_EATER)
	{
		_cultist.has_brute_corpse_eater = true;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_ROTTEN_AURA)
	{
		_cultist.has_brute_rotten_aura = true;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_BLOOD_ANVIL)
	{
		_cultist.has_brute_blood_anvil = true;
		return cultist_ability_level_add(_cultist, _ability);
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION
		|| _ability == DEMON_ABILITY.WARLOCK_SOUL_ENGINE
		|| _ability == DEMON_ABILITY.WARLOCK_FAMILIAR)
	{
		return cultist_ability_level_add(_cultist, _ability);
	}
	else
	{
		return false;
	}

	if (cultist_ability_level_get(_cultist, _ability) <= 0)
	{
		cultist_ability_level_set(_cultist, _ability, 1);
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

	cultist_active_abilities_ensure(_cultist);
	array_push(_cultist.active_abilities, _ability);
	cultist_ability_level_add(_cultist, _ability);

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

	var _active_abilities = cultist_demon_active_abilities_get(_demon_type);

	if (array_length(_active_abilities) <= 0)
	{
		return DEMON_ABILITY.NONE;
	}

	return _active_abilities[0];
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
			DEMON_ABILITY.IMP_BLOODY_CLONE,
			DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE
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
			DEMON_ABILITY.BRUTE_BUTCHER_CHAINS,
			DEMON_ABILITY.BRUTE_CORPSE_ARMOR
		];

		return _brute_abilities[irandom(array_length(_brute_abilities) - 1)];
	}

	return DEMON_ABILITY.NONE;
}

function cultist_ability_name_get(_ability)
{
	if (_ability == DEMON_ABILITY.IMP_BLOOD_BLADES)
	{
		return "Blood Blades";
	}
	else if (_ability == DEMON_ABILITY.IMP_FRENZY_ECHO)
	{
		return "Frenzy Echo";
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOOD_HUNGER)
	{
		return "Blood Hunger";
	}
	else if (_ability == DEMON_ABILITY.IMP_DEMON_LEAP)
	{
		return "Demon Leap";
	}
	else if (_ability == DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE)
	{
		return "Crimson Guillotine";
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
	else if (_ability == DEMON_ABILITY.BRUTE_BLOOD_ANVIL)
	{
		return "Blood Anvil";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_GRAVE_SLAM)
	{
		return "Grave Slam";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_BUTCHER_CHAINS)
	{
		return "Butcher Chains";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_ARMOR)
	{
		return "Corpse Armor";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_ENGINE)
	{
		return "Soul Engine";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_FAMILIAR)
	{
		return "Familiar";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION)
	{
		return "Demonic Infusion";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON)
	{
		return "Summon Skeletons";
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
	if (_ability == DEMON_ABILITY.IMP_BLOOD_BLADES)
	{
		return "Three rotating blood knives damage enemies they pass through.";
	}
	else if (_ability == DEMON_ABILITY.IMP_FRENZY_ECHO)
	{
		return "Every fourth attack creates a phantom Imp strike.";
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOOD_HUNGER)
	{
		return "Kills give a short attack speed burst.";
	}
	else if (_ability == DEMON_ABILITY.IMP_DEMON_LEAP)
	{
		return "Jumps 3 times to the farthest enemy within 300px, critically strikes each target, then jumps back.";
	}
	else if (_ability == DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE)
	{
		return "Crashes onto the highest HP enemy, splashing nearby enemies with AOE damage and knockback.";
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOODY_CLONE)
	{
		return "Creates a temporary Imp copy that attacks enemies.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_EATER)
	{
		return "Eats nearby non-skeleton corpses to restore health.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_ROTTEN_AURA)
	{
		return "Nearby enemies take constant magic damage.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_BLOOD_ANVIL)
	{
		return "Nearby demon active abilities recharge Brute active abilities.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_GRAVE_SLAM)
	{
		return "Damages and stuns enemies around the Brute.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_BUTCHER_CHAINS)
	{
		return "Pulls the farthest enemies, damaging and stunning them.";
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_ARMOR)
	{
		return "Covers Brute in bones and meat, increasing armor for a short time.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_ENGINE)
	{
		return "Nearby enemy deaths send souls to Warlock. Three souls fire a homing skull.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_FAMILIAR)
	{
		return "Summons a demonic familiar that flies nearby and attacks enemies.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION)
	{
		return "Heals nearby allies once per second.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON)
	{
		return "Consumes corpses to create temporary skeletons.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_CHAIN)
	{
		return "Links enemies so part of damage spreads through the chain.";
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_HEX_TOTEM)
	{
		return "Places a temporary totem that attacks enemies with purple beams.";
	}

	return "";
}

function cultist_ability_upgrade_description_get(_ability, _target_level)
{
	if (_target_level <= 1)
	{
		return cultist_ability_description_get(_ability);
	}

	if (_ability == DEMON_ABILITY.IMP_BLOOD_BLADES)
	{
		if (_target_level == 2)
		{
			return "Blades increase from 3 to 6 and rotate on a larger radius.";
		}
		else if (_target_level == 3)
		{
			return "On hit, a blade launches 2 smaller blood blades into nearby enemies.";
		}
		else if (_target_level == 4)
		{
			return "On kill, blades spin 50% faster for 2 seconds.";
		}
	}
	else if (_ability == DEMON_ABILITY.IMP_FRENZY_ECHO)
	{
		if (_target_level == 2)
		{
			return "Phantom strikes trigger every 3 attacks instead of every 4.";
		}
		else if (_target_level == 3)
		{
			return "Phantom strikes hit a small sector instead of a single target.";
		}
		else if (_target_level == 4)
		{
			return "After a kill, Imp enters Frenzy for 3 seconds: every attack creates a phantom strike.";
		}
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOOD_HUNGER)
	{
		if (_target_level == 2)
		{
			return "Attack speed bonus stacks up to 3 times. More stacks create more red smoke.";
		}
		else if (_target_level == 3)
		{
			return "At maximum Blood Hunger stacks, kills dash Imp to a nearby new target.";
		}
		else if (_target_level == 4)
		{
			return "At maximum stacks, kills create a small blood explosion around the target.";
		}
	}
	else if (_ability == DEMON_ABILITY.IMP_DEMON_LEAP)
	{
		if (_target_level == 2)
		{
			return "Imp makes 5 chained leaps instead of 3 before jumping back.";
		}
		else if (_target_level == 3)
		{
			return "Each leap leaves a blood pool that damages enemies standing in it.";
		}
		else if (_target_level == 4)
		{
			return "Imp makes up to 7 chained leaps before jumping back.";
		}
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOODY_CLONE)
	{
		if (_target_level == 2)
		{
			return "Clone lifetime increases to 6 seconds and clone damage becomes 100% of Imp damage.";
		}
		else if (_target_level == 3)
		{
			return "When the clone dies, it explodes in blood, damaging enemies in a 100px radius.";
		}
		else if (_target_level == 4)
		{
			return "Imp creates 2 clones instead of 1.";
		}
	}
	else if (_ability == DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE)
	{
		if (_target_level == 2)
		{
			return "AOE enemies are stunned after Crimson Guillotine damage.";
		}
		else if (_target_level == 3)
		{
			return "AOE radius and AOE damage are doubled.";
		}
		else if (_target_level == 4)
		{
			return "If any enemy dies from Crimson Guillotine, Imp instantly repeats it once.";
		}
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_EATER)
	{
		if (_target_level == 2)
		{
			return "Healing increases from 4% to 6% of max HP.";
		}
		else if (_target_level == 3)
		{
			return "Cooldown becomes 3 seconds instead of 5 seconds.";
		}
		else if (_target_level == 4)
		{
			return "When Brute eats a corpse, allied demons within 200px heal 3% max HP.";
		}
	}
	else if (_ability == DEMON_ABILITY.BRUTE_ROTTEN_AURA)
	{
		if (_target_level == 2)
		{
			return "Aura radius increases from 150px to 220px.";
		}
		else if (_target_level == 3)
		{
			return "Enemies inside the aura gain Fear: 20% slower movement and attacks.";
		}
		else if (_target_level == 4)
		{
			return "Enemies inside the aura take 50% more critical hit damage.";
		}
	}
	else if (_ability == DEMON_ABILITY.BRUTE_BLOOD_ANVIL)
	{
		if (_target_level == 2)
		{
			return "Nearby demon active abilities recharge Brute active abilities by 8% instead of 5%.";
		}
		else if (_target_level == 3)
		{
			return "Trigger radius increases from 250px to 400px.";
		}
		else if (_target_level == 4)
		{
			return "Other demons within 400px also recharge active abilities by 5%.";
		}
	}
	else if (_ability == DEMON_ABILITY.BRUTE_GRAVE_SLAM)
	{
		if (_target_level == 2)
		{
			return "AOE radius is multiplied by 1.5.";
		}
		else if (_target_level == 3)
		{
			return "Bone spikes deal 50% additional damage in the slam area.";
		}
		else if (_target_level == 4)
		{
			return "Enemies killed by Grave Slam explode, dealing 50% Brute damage in AOE.";
		}
	}
	else if (_ability == DEMON_ABILITY.BRUTE_BUTCHER_CHAINS)
	{
		if (_target_level == 2)
		{
			return "Hook range increases from 600px to 900px.";
		}
		else if (_target_level == 3)
		{
			return "Target count increases from 4 to 6.";
		}
		else if (_target_level == 4)
		{
			return "If the first hook wave kills an enemy, Brute releases a second wave.";
		}
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_ARMOR)
	{
		if (_target_level == 2)
		{
			return "Shield duration increases by 3 seconds.";
		}
		else if (_target_level == 3)
		{
			return "Melee attackers take damage while Brute has the shield.";
		}
		else if (_target_level == 4)
		{
			return "Allied demons within 250px also gain a 5 second, +20 armor shield.";
		}
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION)
	{
		if (_target_level == 2)
		{
			return "Aura radius increases from 250px to 500px.";
		}
		else if (_target_level == 3)
		{
			return "Allied units in the aura recharge attacks 15% faster.";
		}
		else if (_target_level == 4)
		{
			return "Healing becomes 1% max HP per second and attack recharge bonus becomes 20%.";
		}
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_ENGINE)
	{
		if (_target_level == 2)
		{
			return "Soul Engine fires after 2 collected souls instead of 3.";
		}
		else if (_target_level == 3)
		{
			return "Homing skulls explode on hit, dealing AOE magic damage.";
		}
		else if (_target_level == 4)
		{
			return "Soul Engine fires after each collected soul.";
		}
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_FAMILIAR)
	{
		if (_target_level == 2)
		{
			return "Warlock gains a second familiar.";
		}
		else if (_target_level == 3)
		{
			return "Familiar damage increases by 50%.";
		}
		else if (_target_level == 4)
		{
			return "Warlock gains a third familiar.";
		}
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON)
	{
		if (_target_level == 2)
		{
			return "Summons 4 skeletons instead of 2.";
		}
		else if (_target_level == 3)
		{
			return "Skeletons explode on death, dealing AOE damage.";
		}
		else if (_target_level == 4)
		{
			return "Skeletons have a 25% chance to create another skeleton on death.";
		}
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_CHAIN)
	{
		if (_target_level == 2)
		{
			return "Soul Chain can link up to 6 enemies.";
		}
		else if (_target_level == 3)
		{
			return "When a chained enemy dies, the other chained enemies are stunned for 3 seconds.";
		}
		else if (_target_level == 4)
		{
			return "When a chained enemy dies, the other chained enemies take Warlock magic damage.";
		}
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_HEX_TOTEM)
	{
		if (_target_level == 2)
		{
			return "Totem beams hit 2 enemies per shot.";
		}
		else if (_target_level == 3)
		{
			return "Totem gains a 300px cursed zone that deals periodic magic damage.";
		}
		else if (_target_level == 4)
		{
			return "When the totem disappears, it explodes in a visible 200px area.";
		}
	}

	return "Improves " + cultist_ability_name_get(_ability) + " to level " + string(_target_level) + ".";
}

function cultist_ability_cooldown_get(_ability)
{
	if (_ability == DEMON_ABILITY.IMP_DEMON_LEAP)
	{
		return BALANCE_IMP_DEMON_LEAP_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.IMP_BLOODY_CLONE)
	{
		return BALANCE_IMP_BLOODY_CLONE_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE)
	{
		return BALANCE_IMP_CRIMSON_GUILLOTINE_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON)
	{
		return BALANCE_WARLOCK_RAISE_LESSER_DEMON_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_SOUL_CHAIN)
	{
		return BALANCE_WARLOCK_SOUL_CHAIN_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.WARLOCK_HEX_TOTEM)
	{
		return BALANCE_WARLOCK_HEX_TOTEM_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_GRAVE_SLAM)
	{
		return BALANCE_BRUTE_GRAVE_SLAM_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_BUTCHER_CHAINS)
	{
		return BALANCE_BRUTE_BUTCHER_CHAINS_COOLDOWN;
	}
	else if (_ability == DEMON_ABILITY.BRUTE_CORPSE_ARMOR)
	{
		return BALANCE_BRUTE_CORPSE_ARMOR_COOLDOWN;
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
	_unit.base_crit_damage = _base_stats.crit_damage;
	_unit.base_attack_speed = _base_stats.attack_speed;
	_unit.base_abilities_cd_spd = _base_stats.abilities_cd_spd;
	_unit.base_exp_effectiveness = _base_stats.exp_effectiveness;
	_unit.base_magic_effectiveness = _base_stats.magic_effectiveness;
	_unit.base_resistance = _base_stats.resistance;
	_unit.base_move_speed = _base_stats.move_speed;

	_unit.hp_coefficient = 1;
	_unit.armor_coefficient = 1;
	_unit.damage_coefficient = 1;
	_unit.magic_damage_coefficient = 1;
	_unit.crit_chance_coefficient = 1;
	_unit.crit_damage_coefficient = 1;
	_unit.attack_speed_coefficient = 1;
	_unit.abilities_cd_spd_coefficient = 1;
	_unit.exp_effectiveness_coefficient = 1;
	_unit.magic_effectiveness_coefficient = 1;
	_unit.resistance_coefficient = 1;
	_unit.move_speed_coefficient = 1;

	_unit.max_hp = cultist_stat_get(_unit.base_hp, _body, BALANCE_CULTIST_BODY_STAT_BONUS, _unit.hp_coefficient);
	_unit.hp = _unit.max_hp;
	_unit.armor = min(cultist_stat_get(_unit.base_armor, _body, BALANCE_CULTIST_BODY_STAT_BONUS, _unit.armor_coefficient), 190);
	_unit.magic_resistance = min(cultist_stat_get(_unit.base_resistance, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, _unit.resistance_coefficient), 190);
	_unit.damage = cultist_stat_get(_unit.base_damage, _body, BALANCE_CULTIST_BODY_STAT_BONUS, _unit.damage_coefficient);
	_unit.magic_damage = cultist_stat_get(_unit.base_magic_damage, _spirit, BALANCE_CULTIST_MAGIC_DAMAGE_STAT_BONUS, _unit.magic_damage_coefficient);
	_unit.crit_chance = clamp(cultist_stat_get(_unit.base_crit_chance, _fervor, BALANCE_CULTIST_CRIT_CHANCE_STAT_BONUS, _unit.crit_chance_coefficient), 0, 1);
	_unit.crit_damage = (_unit.base_crit_damage + (_body * BALANCE_CULTIST_CRIT_DAMAGE_PER_BODY)) * _unit.crit_damage_coefficient;
	_unit.attack_speed = cultist_stat_get(_unit.base_attack_speed, _fervor, BALANCE_CULTIST_FERVOR_STAT_BONUS, _unit.attack_speed_coefficient);
	_unit.abilities_cd_spd = cultist_stat_get(_unit.base_abilities_cd_spd, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, _unit.abilities_cd_spd_coefficient);
	_unit.exp_effectiveness = cultist_stat_get(_unit.base_exp_effectiveness, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, _unit.exp_effectiveness_coefficient);
	_unit.magic_effectiveness = cultist_stat_get(_unit.base_magic_effectiveness, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, _unit.magic_effectiveness_coefficient);
	_unit.resistance = cultist_stat_get(_unit.base_resistance, _spirit, BALANCE_CULTIST_SPIRIT_STAT_BONUS, _unit.resistance_coefficient);
	_unit.aoe_radius = _unit.base_aoe_radius;
	_unit.reload_time = max(room_speed / max(_unit.attack_speed, 0.1), 1);
	_unit.attack_radius = _base_stats.attack_radius;
	_unit.move_speed = cultist_stat_get(_unit.base_move_speed, _fervor, BALANCE_CULTIST_FERVOR_STAT_BONUS, _unit.move_speed_coefficient);

	// Reapply squad Relics after this full stat rebuild replaces their modified values.
	squad_relic_applied_multipliers_reset(_unit);

	if (variable_instance_exists(_unit, "squad") && is_struct(_unit.squad))
	{
		squad_relic_bonuses_apply(_unit.squad, _unit);
	}
}
