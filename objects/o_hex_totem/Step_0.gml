// Pause freezes totem lifetime and damage ticks.
if (global.pause)
{
	exit;
}

life_timer--;

if (life_timer <= 0)
{
	hex_totem_explode();
	instance_destroy();
	exit;
}

// Beam attacks repeatedly hit one or two nearest enemies.
if (beam_timer > 0)
{
	beam_timer--;
}

if (beam_timer <= 0)
{
	hex_totem_beam_fire();
	beam_timer = BALANCE_WARLOCK_HEX_TOTEM_BEAM_TIME * room_speed;
}

if (beam_line_timer > 0)
{
	beam_line_timer--;
}

// Level 3 adds a cursed damage zone around the totem.
if (zone_damage_timer > 0)
{
	zone_damage_timer--;
}

if (zone_damage_timer <= 0)
{
	hex_totem_zone_damage_apply();
	zone_damage_timer = BALANCE_WARLOCK_DEMONIC_INFUSION_TICK_TIME * room_speed;
}
