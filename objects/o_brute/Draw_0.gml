// Knocked out cultists only draw the shared recovery state.
if (is_knocked_out)
{
	event_inherited();
	exit;
}

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

// Draw the exact normal-attack AOE and mark every unit hit by it.
if (attack_aoe_circle_timer > 0)
{
	var _attack_progress = attack_aoe_circle_timer / max(1, attack_aoe_circle_duration);

	draw_set_color(COLOR_BRUTE_MEAT_EXPLOSION);
	draw_set_alpha(0.14 * _attack_progress);
	draw_circle(attack_aoe_circle_x, attack_aoe_circle_y, attack_aoe_circle_radius, false);
	draw_set_alpha(0.95 * _attack_progress);
	draw_circle(attack_aoe_circle_x, attack_aoe_circle_y, attack_aoe_circle_radius, true);
	draw_set_alpha(0.5 * _attack_progress);
	draw_circle(attack_aoe_circle_x, attack_aoe_circle_y, max(1, attack_aoe_circle_radius - 2), true);

	for (var _hit_index = 0; _hit_index < array_length(attack_aoe_hit_positions); ++_hit_index)
	{
		var _hit_position = attack_aoe_hit_positions[_hit_index];

		draw_set_alpha(0.28 * _attack_progress);
		draw_circle(
			_hit_position.x,
			_hit_position.y,
			BALANCE_BRUTE_ATTACK_AOE_HIT_MARKER_RADIUS,
			false
		);
		draw_set_alpha(_attack_progress);
		draw_circle(
			_hit_position.x,
			_hit_position.y,
			BALANCE_BRUTE_ATTACK_AOE_HIT_MARKER_RADIUS,
			true
		);
	}
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
	draw_set_color(COLOR_COOLDOWN_BRUTE_BUTCHER_CHAINS);

	for (var _chain_index = 0; _chain_index < array_length(hook_chain_visuals); ++_chain_index)
	{
		var _chain = hook_chain_visuals[_chain_index];

		draw_set_alpha(0.35);
		draw_line_width(x, y, _chain.tip_x, _chain.tip_y, 7);
		draw_set_alpha(1);
		draw_line_width(x, y, _chain.tip_x, _chain.tip_y, 3);
	}

	draw_set_alpha(0.9);
	for (var _target_index = 0; _target_index < array_length(hook_targets); ++_target_index)
	{
		var _hook_target = hook_targets[_target_index];

		if (instance_exists(_hook_target))
		{
			draw_set_alpha(0.35);
			draw_line_width(x, y, _hook_target.x, _hook_target.y, 7);
			draw_set_alpha(1);
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

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
