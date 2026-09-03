// Initialize the landed Doom Bell as a temporary destructible player structure.
event_inherited();

max_hp = BALANCE_DOOM_BELL_MAX_HP;
hp = max_hp;
building_constructed_by_shell = true;
corruption_bar_visible = false;
bar_width = BALANCE_DOOM_BELL_HEALTH_BAR_WIDTH;
bar_height = BALANCE_DOOM_BELL_HEALTH_BAR_HEIGHT;
bar_offset_y = BALANCE_DOOM_BELL_HEALTH_BAR_OFFSET_Y;
image_xscale = BALANCE_DOOM_BELL_GROUND_SCALE;
image_yscale = image_xscale;
image_speed = 0;
depth = -floor(y);

doom_bell_enchantment = DOOM_BELL_ENCHANTMENT.NONE;
effect_radius = BALANCE_PROJECTILE_DOOM_BELL_RADIUS;
effect_duration = 0;
effect_timer = 0;
effect_is_active = false;
silence_scan_interval = max(1, BALANCE_DOOM_BELL_SILENCE_SCAN_INTERVAL * room_speed);
silence_scan_timer = 0;
stasis_targets = [];
silence_targets = [];

doom_bell_stasis_release = function()
{
	var _target_count = array_length(stasis_targets);

	for (var _target_index = 0; _target_index < _target_count; ++_target_index)
	{
		var _target = stasis_targets[_target_index];

		if (instance_exists(_target)
			&& variable_instance_exists(_target, "doom_bell_stasis_source_remove"))
		{
			_target.doom_bell_stasis_source_remove(id);
		}
	}

	stasis_targets = [];
};

doom_bell_silence_release = function()
{
	var _target_count = array_length(silence_targets);

	for (var _target_index = 0; _target_index < _target_count; ++_target_index)
	{
		var _target = silence_targets[_target_index];

		if (instance_exists(_target)
			&& variable_instance_exists(_target, "doom_bell_silence_source_remove"))
		{
			_target.doom_bell_silence_source_remove(id);
		}
	}

	silence_targets = [];
};

doom_bell_effect_release = function()
{
	doom_bell_stasis_release();
	doom_bell_silence_release();
	effect_is_active = false;
};

doom_bell_funeral_pause_apply = function()
{
	var _unit_count = instance_number(o_units_parent);
	var _radius_squared = effect_radius * effect_radius;

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = instance_find(o_units_parent, _unit_index);

		if (!instance_exists(_unit)
			|| _unit.hp <= 0
			|| _unit.unit_faction != UNIT_FACTION.ENEMY
			|| !variable_instance_exists(_unit, "doom_bell_stasis_source_add"))
		{
			continue;
		}

		var _distance_x = _unit.x - x;
		var _distance_y = _unit.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

		if (_distance_squared <= _radius_squared
			&& _unit.doom_bell_stasis_source_add(id))
		{
			array_push(stasis_targets, _unit);
		}
	}
};

doom_bell_dead_silence_refresh = function()
{
	doom_bell_silence_release();

	var _unit_count = instance_number(o_units_parent);
	var _radius_squared = effect_radius * effect_radius;

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = instance_find(o_units_parent, _unit_index);

		if (!instance_exists(_unit)
			|| _unit.hp <= 0
			|| _unit.attack_radius <= BALANCE_DOOM_BELL_RANGED_ATTACK_RADIUS_MINIMUM
			|| !variable_instance_exists(_unit, "doom_bell_silence_source_add"))
		{
			continue;
		}

		var _distance_x = _unit.x - x;
		var _distance_y = _unit.y - y;
		var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

		if (_distance_squared <= _radius_squared
			&& _unit.doom_bell_silence_source_add(id))
		{
			array_push(silence_targets, _unit);
		}
	}
};

doom_bell_activate = function(_enchantment, _impact_radius)
{
	doom_bell_enchantment = _enchantment;
	effect_radius = _impact_radius;

	if (doom_bell_enchantment == DOOM_BELL_ENCHANTMENT.FUNERAL_PAUSE)
	{
		effect_duration = BALANCE_DOOM_BELL_FUNERAL_PAUSE_DURATION * room_speed;
		tooltip_lines = [
			"Funeral Pause",
			"Stasis: " + string(BALANCE_DOOM_BELL_FUNERAL_PAUSE_DURATION) + " seconds",
			"HP: " + string(max_hp),
			"LMB - destroy"
		];
		doom_bell_funeral_pause_apply();
	}
	else if (doom_bell_enchantment == DOOM_BELL_ENCHANTMENT.DEAD_SILENCE)
	{
		effect_radius = BALANCE_DOOM_BELL_DEAD_SILENCE_RADIUS;
		effect_duration = BALANCE_DOOM_BELL_DEAD_SILENCE_DURATION * room_speed;
		tooltip_lines = [
			"Dead Silence",
			"Silences ranged units within " + string(effect_radius),
			"HP: " + string(max_hp),
			"LMB - destroy"
		];
		doom_bell_dead_silence_refresh();
	}
	else
	{
		return false;
	}

	effect_timer = effect_duration;
	effect_is_active = true;
	return true;
};

doom_bell_destroy = function()
{
	if (!effect_is_active)
	{
		return false;
	}

	doom_bell_effect_release();
	player_building_destroy_effect_create();
	instance_destroy();
	return true;
};
