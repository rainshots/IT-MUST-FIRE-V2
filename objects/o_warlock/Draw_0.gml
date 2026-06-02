// Draw Demonic Infusion radius beneath the Warlock visuals when unlocked.
if (has_warlock_demonic_infusion)
{
	draw_set_color(COLOR_WARLOCK_DEMONIC_INFUSION);
	draw_set_alpha(BALANCE_WARLOCK_DEMONIC_INFUSION_CIRCLE_ALPHA);
	draw_circle(x, y, demonic_infusion_radius, false);
	draw_set_alpha(BALANCE_WARLOCK_DEMONIC_INFUSION_CIRCLE_OUTLINE_ALPHA);
	draw_circle(x, y, demonic_infusion_radius, true);
}

// Draw the fading Curseweaver burst circle.
if (curseweaver_circle_timer > 0)
{
	var _curseweaver_progress = curseweaver_circle_timer / max(1, curseweaver_circle_duration);

	draw_set_color(COLOR_WARLOCK_CURSEWEAVER);
	draw_set_alpha(0.18 * _curseweaver_progress);
	draw_circle(curseweaver_circle_x, curseweaver_circle_y, curseweaver_circle_radius, false);
	draw_set_alpha(0.58 * _curseweaver_progress);
	draw_circle(curseweaver_circle_x, curseweaver_circle_y, curseweaver_circle_radius, true);
}

// Draw short cast lines for Raise Lesser Demon and Hex Totem.
if (raise_lesser_demon_line_timer > 0)
{
	var _raise_line_progress = raise_lesser_demon_line_timer / max(1, raise_lesser_demon_line_duration);

	draw_set_color(COLOR_WARLOCK_RAISE_LESSER_DEMON);
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

// Draw active Soul Chain links between living linked enemies.
draw_set_color(COLOR_WARLOCK_SOUL_CHAIN);
draw_set_alpha(0.8);

for (var _chain_index = 0; _chain_index < array_length(soul_chain_groups); ++_chain_index)
{
	var _chain = soul_chain_groups[_chain_index];
	var _members = _chain.members;
	var _previous_member = noone;

	for (var _member_index = 0; _member_index < array_length(_members); ++_member_index)
	{
		var _member = _members[_member_index];

		if (!target_can_be_attacked(_member)
			|| !variable_instance_exists(_member, "soul_chain_id")
			|| _member.soul_chain_id != _chain.chain_id)
		{
			continue;
		}

		if (instance_exists(_previous_member))
		{
			var _chain_line_offset_y = -20;
			draw_line_width(
				_previous_member.x,
				_previous_member.y + _chain_line_offset_y,
				_member.x,
				_member.y + _chain_line_offset_y,
				2
			);
		}

		_previous_member = _member;
	}
}

draw_set_color(c_white);
draw_set_alpha(1);

// Draw base combat visuals.
event_inherited();

// Draw the cultist name above the demon.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_text(x, y - 42, cultist_name);

// Draw compact cooldown bar for the owned Warlock active ability.
var _cooldown_bar_width = 34;
var _cooldown_bar_height = 3;
var _cooldown_bar_gap = 2;
var _cooldown_bar_x = x - (_cooldown_bar_width * 0.5);
var _cooldown_bar_y = y + 32;
var _cooldown_timers = [];
var _cooldown_maxes = [];
var _cooldown_colors = [];

if (cultist_active_ability_has(id, DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON))
{
	array_push(_cooldown_timers, raise_lesser_demon_timer);
	array_push(_cooldown_maxes, ability_cooldown_time_get(raise_lesser_demon_cooldown));
	array_push(_cooldown_colors, COLOR_WARLOCK_RAISE_LESSER_DEMON);
}
if (cultist_active_ability_has(id, DEMON_ABILITY.WARLOCK_SOUL_CHAIN))
{
	array_push(_cooldown_timers, soul_chain_cooldown_timer);
	array_push(_cooldown_maxes, ability_cooldown_time_get(soul_chain_cooldown));
	array_push(_cooldown_colors, COLOR_WARLOCK_SOUL_CHAIN);
}
if (cultist_active_ability_has(id, DEMON_ABILITY.WARLOCK_HEX_TOTEM))
{
	array_push(_cooldown_timers, hex_totem_timer);
	array_push(_cooldown_maxes, ability_cooldown_time_get(hex_totem_cooldown));
	array_push(_cooldown_colors, COLOR_WARLOCK_HEX_TOTEM);
}

for (var _bar_index = 0; _bar_index < array_length(_cooldown_timers); ++_bar_index)
{
	var _bar_y = _cooldown_bar_y + ((_cooldown_bar_height + _cooldown_bar_gap) * _bar_index);
	var _progress = 1 - clamp(_cooldown_timers[_bar_index] / max(1, _cooldown_maxes[_bar_index]), 0, 1);

	draw_set_alpha(0.75);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_cooldown_bar_x, _bar_y, _cooldown_bar_x + _cooldown_bar_width, _bar_y + _cooldown_bar_height, false);

	draw_set_alpha(1);
	draw_set_color(_cooldown_colors[_bar_index]);
	draw_rectangle(_cooldown_bar_x, _bar_y, _cooldown_bar_x + (_cooldown_bar_width * _progress), _bar_y + _cooldown_bar_height, false);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
