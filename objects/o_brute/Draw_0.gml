// Draw Rotten Aura radius beneath the Brute visuals.
if (has_brute_rotten_aura && BALANCE_BRUTE_ROTTEN_AURA_ENABLED)
{
	var _aura_radius = brute_rotten_aura_radius_get();

	draw_set_color(COLOR_BRUTE_ROTTEN_AURA);
	draw_set_alpha(BALANCE_BRUTE_ROTTEN_AURA_CIRCLE_ALPHA);
	draw_circle(x, y, _aura_radius, false);
	draw_set_alpha(BALANCE_BRUTE_ROTTEN_AURA_CIRCLE_OUTLINE_ALPHA);
	draw_circle(x, y, _aura_radius, true);
}

// Draw fading AOE circles from Brute active abilities.
if (grave_slam_circle_timer > 0)
{
	var _slam_progress = grave_slam_circle_timer / max(1, grave_slam_circle_duration);

	draw_set_color(COLOR_BRUTE_GRAVE_SLAM);
	draw_set_alpha(0.34 * _slam_progress);
	draw_circle(grave_slam_circle_x, grave_slam_circle_y, grave_slam_circle_radius, false);
	draw_set_alpha(0.95 * _slam_progress);
	draw_circle(grave_slam_circle_x, grave_slam_circle_y, grave_slam_circle_radius, true);
	draw_set_alpha(0.6 * _slam_progress);
	draw_circle(grave_slam_circle_x, grave_slam_circle_y, grave_slam_circle_radius + 2, true);
	draw_circle(grave_slam_circle_x, grave_slam_circle_y, max(1, grave_slam_circle_radius - 2), true);
}

if (meat_explosion_circle_timer > 0)
{
	var _meat_progress = meat_explosion_circle_timer / max(1, meat_explosion_circle_duration);

	draw_set_color(COLOR_BRUTE_MEAT_EXPLOSION);
	draw_set_alpha(0.18 * _meat_progress);
	draw_circle(meat_explosion_circle_x, meat_explosion_circle_y, meat_explosion_circle_radius, false);
	draw_set_alpha(0.6 * _meat_progress);
	draw_circle(meat_explosion_circle_x, meat_explosion_circle_y, meat_explosion_circle_radius, true);
}

// Draw Butcher Chains pull lines above the ground circles but below the Brute name.
if (hook_line_active)
{
	draw_set_color(COLOR_BRUTE_HOOK_LINE);
	draw_set_alpha(0.9);

	for (var _target_index = 0; _target_index < array_length(hook_targets); ++_target_index)
	{
		var _hook_target = hook_targets[_target_index];

		if (instance_exists(_hook_target))
		{
			draw_line_width(x, y, _hook_target.x, _hook_target.y, 3);
		}
	}
}

draw_set_color(c_white);
draw_set_alpha(1);

// Draw base combat visuals.
event_inherited();

// Draw temporary bone spikes created by upgraded Grave Slam.
if (array_length(grave_slam_spike_visuals) > 0 && sprite_exists(s_spike))
{
	for (var _spike_index = 0; _spike_index < array_length(grave_slam_spike_visuals); ++_spike_index)
	{
		var _spike = grave_slam_spike_visuals[_spike_index];
		var _spike_progress = clamp(_spike.timer / max(1, _spike.duration), 0, 1);

		draw_sprite_ext(
			s_spike,
			0,
			_spike.x,
			_spike.y,
			_spike.scale,
			_spike.scale,
			_spike.angle,
			c_white,
			_spike_progress
		);
	}
}

// Draw the cultist name above the demon.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_text(x, y - 42, cultist_name);

// Draw compact cooldown bars for owned Brute active abilities.
var _cooldown_bar_width = 34;
var _cooldown_bar_height = 3;
var _cooldown_bar_gap = 2;
var _cooldown_bar_x = x - (_cooldown_bar_width * 0.5);
var _cooldown_bar_y = y + 32;
var _cooldown_timers = [];
var _cooldown_maxes = [];
var _cooldown_colors = [];

if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_GRAVE_SLAM))
{
	array_push(_cooldown_timers, grave_slam_timer);
	array_push(_cooldown_maxes, ability_cooldown_time_get(grave_slam_cooldown));
	array_push(_cooldown_colors, COLOR_BRUTE_GRAVE_SLAM);
}
if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_BUTCHER_CHAINS))
{
	array_push(_cooldown_timers, butcher_chains_timer);
	array_push(_cooldown_maxes, ability_cooldown_time_get(butcher_chains_cooldown));
	array_push(_cooldown_colors, COLOR_BRUTE_HOOK_LINE);
}
if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_CORPSE_ARMOR))
{
	array_push(_cooldown_timers, corpse_armor_ability_timer);
	array_push(_cooldown_maxes, ability_cooldown_time_get(corpse_armor_cooldown));
	array_push(_cooldown_colors, COLOR_BRUTE_MEAT_EXPLOSION);
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
