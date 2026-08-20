// Pause freezes totem lifetime and damage ticks.
if (global.pause)
{
	exit;
}

var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;

life_timer -= _time_scale;

if (life_timer <= 0)
{
	hex_totem_explode();
	instance_destroy();
	exit;
}

// Beam attacks repeatedly hit one or two nearest enemies.
if (beam_timer > 0)
{
	beam_timer -= _time_scale;
}

if (beam_timer <= 0)
{
	hex_totem_beam_fire();
	beam_timer = BALANCE_WARLOCK_HEX_TOTEM_BEAM_RELOAD_TIME * room_speed;
}

if (beam_line_timer > 0)
{
	beam_line_timer -= _time_scale;
}

// Level 3 adds a cursed damage zone around the totem.
if (zone_damage_timer > 0)
{
	zone_damage_timer -= _time_scale;
}

if (zone_damage_timer <= 0)
{
	hex_totem_zone_damage_apply();
	zone_damage_timer = BALANCE_WARLOCK_HEX_TOTEM_ZONE_TICK_TIME * room_speed;
}
