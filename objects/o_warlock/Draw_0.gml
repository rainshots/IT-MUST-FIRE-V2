// Draw Demonic Infusion radius beneath the Warlock visuals when unlocked.
if (warlock_ability_level_get(DEMON_ABILITY.WARLOCK_DEMONIC_INFUSION) > 0)
{
	draw_set_color(COLOR_WARLOCK_DEMONIC_INFUSION);
	draw_set_alpha(BALANCE_WARLOCK_DEMONIC_INFUSION_CIRCLE_ALPHA);
	draw_circle(x, y, demonic_infusion_radius, false);
	draw_set_alpha(BALANCE_WARLOCK_DEMONIC_INFUSION_CIRCLE_OUTLINE_ALPHA);
	draw_circle(x, y, demonic_infusion_radius, true);
}

// Draw short cast lines for Summon Skeletons and Hex Totem.
if (raise_lesser_demon_line_timer > 0)
{
	var _raise_line_progress = raise_lesser_demon_line_timer / max(1, raise_lesser_demon_line_duration);

	draw_set_color(COLOR_WARLOCK_SUMMON_SKELETONS);
	draw_set_alpha(0.9 * _raise_line_progress);
	draw_line_width(x, y, raise_lesser_demon_line_x, raise_lesser_demon_line_y, 2);
}

if (hex_totem_line_timer > 0)
{
	var _totem_line_progress = hex_totem_line_timer / max(1, hex_totem_line_duration);

	draw_set_color(COLOR_WARLOCK_HEX_TOTEM);
	draw_set_alpha(0.85 * _totem_line_progress);
	draw_line_width(x, y, hex_totem_line_x, hex_totem_line_y, 2);
}

// Draw base combat visuals.
event_inherited();

// Draw flying souls and homing skulls above the base unit.
draw_set_color(COLOR_WARLOCK_SOUL_ENGINE);

for (var _soul_index = 0; _soul_index < array_length(soul_engine_souls); ++_soul_index)
{
	var _soul = soul_engine_souls[_soul_index];

	draw_set_alpha(0.85);
	draw_circle(_soul.x, _soul.y, _soul.size, false);
	draw_set_alpha(0.35);
	draw_circle(_soul.x, _soul.y, _soul.size + 5, false);
}

for (var _skull_index = 0; _skull_index < array_length(soul_engine_skulls); ++_skull_index)
{
	var _skull = soul_engine_skulls[_skull_index];

	draw_set_alpha(0.95);
	draw_circle(_skull.x, _skull.y, 8, false);
	draw_set_alpha(0.38);
	draw_circle(_skull.x, _skull.y, BALANCE_WARLOCK_SOUL_ENGINE_SKULL_HIT_RADIUS, true);
}

// Draw familiars and their short attack beams.
for (var _familiar_index = 0; _familiar_index < array_length(familiar_data); ++_familiar_index)
{
	var _familiar = familiar_data[_familiar_index];

	if (_familiar.attack_line_timer > 0)
	{
		var _line_progress = _familiar.attack_line_timer / max(1, 0.15 * room_speed);

		draw_set_color(COLOR_WARLOCK_FAMILIAR);
		draw_set_alpha(0.85 * _line_progress);
		draw_line_width(_familiar.x, _familiar.y, _familiar.attack_line_x, _familiar.attack_line_y, 2);
	}

	if (sprite_exists(familiar_sprite_index))
	{
		draw_set_alpha(0.95);
		draw_sprite_ext(familiar_sprite_index, 0, _familiar.x, _familiar.y, 1, 1, 0, c_white, 0.95);
	}
	else
	{
		draw_set_color(COLOR_WARLOCK_FAMILIAR);
		draw_set_alpha(0.9);
		draw_circle(_familiar.x, _familiar.y, 8, false);
	}
}

draw_set_color(c_white);
draw_set_alpha(1);

// Draw the cultist name above the demon.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_text(x, y - 42, cultist_name);

// Draw Soul Engine charge pips so the player can read skull progress.
if (warlock_ability_level_get(DEMON_ABILITY.WARLOCK_SOUL_ENGINE) > 0)
{
	var _required_souls = warlock_soul_engine_required_souls_get();
	var _pip_radius = 3;
	var _pip_gap = 4;
	var _pip_total_width = (_required_souls * (_pip_radius * 2)) + (max(0, _required_souls - 1) * _pip_gap);
	var _pip_start_x = x - (_pip_total_width * 0.5) + _pip_radius;
	var _pip_y = y - 57;

	for (var _pip_index = 0; _pip_index < _required_souls; ++_pip_index)
	{
		var _pip_x = _pip_start_x + ((_pip_radius * 2 + _pip_gap) * _pip_index);
		var _is_filled = _pip_index < soul_engine_souls_collected;

		draw_set_color(COLOR_WARLOCK_SOUL_ENGINE);
		draw_set_alpha(0.28);
		draw_circle(_pip_x, _pip_y, _pip_radius + 2, false);
		draw_set_alpha(0.9);

		if (_is_filled)
		{
			draw_circle(_pip_x, _pip_y, _pip_radius, false);
		}
		else
		{
			draw_circle(_pip_x, _pip_y, _pip_radius, true);
		}
	}
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
