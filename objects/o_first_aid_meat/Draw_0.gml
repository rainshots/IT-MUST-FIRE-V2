// Enchanted shells show their additional rescue or smell radius behind the heal radius.
var _extra_radius = 0;
var _extra_radius_color = c_white;

if (first_aid_meat_enchantment == FIRST_AID_MEAT_ENCHANTMENT.EMERGENCY_PULL)
{
	_extra_radius = pull_radius;
	_extra_radius_color = COLOR_COOLDOWN_BRUTE_BUTCHER_CHAINS;
}
else if (first_aid_meat_enchantment == FIRST_AID_MEAT_ENCHANTMENT.FRESH_MEAT)
{
	_extra_radius = fresh_smell_radius;
	_extra_radius_color = COLOR_STATUS_NEGATIVE_RED;
}

if (_extra_radius > 0)
{
	draw_set_color(_extra_radius_color);
	draw_set_alpha(BALANCE_FIRST_AID_MEAT_EXTRA_RADIUS_FILL_ALPHA);
	draw_circle(x, y, _extra_radius, false);
	draw_set_alpha(BALANCE_FIRST_AID_MEAT_EXTRA_RADIUS_OUTLINE_ALPHA);
	draw_circle(x, y, _extra_radius, true);
}

// Emergency Pull has no healing area, so only its rescue radius is shown.
if (first_aid_meat_enchantment != FIRST_AID_MEAT_ENCHANTMENT.EMERGENCY_PULL)
{
	draw_set_color(COLOR_PROJECTILE_HEAL);
	draw_set_alpha(radius_outline_alpha);
	draw_circle(x, y, heal_radius, true);
}

// Emergency Pull uses the same layered chain treatment as Butcher Chains.
if (instance_exists(pull_target))
{
	var _chain_end_x = pull_chain_is_outbound ? pull_chain_tip_x : pull_target.x;
	var _chain_end_y = pull_chain_is_outbound ? pull_chain_tip_y : pull_target.y;
	draw_set_color(COLOR_COOLDOWN_BRUTE_BUTCHER_CHAINS);
	draw_set_alpha(BALANCE_FIRST_AID_MEAT_PULL_CHAIN_GLOW_ALPHA);
	draw_line_width(x, y, _chain_end_x, _chain_end_y, BALANCE_FIRST_AID_MEAT_PULL_CHAIN_GLOW_WIDTH);
	draw_set_alpha(1);
	draw_line_width(x, y, _chain_end_x, _chain_end_y, BALANCE_FIRST_AID_MEAT_PULL_CHAIN_WIDTH);
}

// Draw the landed meat at full opacity.
draw_set_color(c_white);
draw_set_alpha(1);
draw_self();

// Fresh Meat exposes its remaining durability above the shell.
if (first_aid_meat_enchantment == FIRST_AID_MEAT_ENCHANTMENT.FRESH_MEAT && max_hp > 0)
{
	var _health_progress = clamp(hp / max_hp, 0, 1);
	var _health_bar_left = x - (BALANCE_FIRST_AID_MEAT_HEALTH_BAR_WIDTH * 0.5);
	var _health_bar_top = y - BALANCE_FIRST_AID_MEAT_HEALTH_BAR_OFFSET_Y;

	draw_set_alpha(0.75);
	draw_set_color(c_black);
	draw_rectangle(
		_health_bar_left,
		_health_bar_top,
		_health_bar_left + BALANCE_FIRST_AID_MEAT_HEALTH_BAR_WIDTH,
		_health_bar_top + BALANCE_FIRST_AID_MEAT_HEALTH_BAR_HEIGHT,
		false
	);
	draw_set_alpha(1);
	draw_set_color(c_lime);
	draw_rectangle(
		_health_bar_left,
		_health_bar_top,
		_health_bar_left + (BALANCE_FIRST_AID_MEAT_HEALTH_BAR_WIDTH * _health_progress),
		_health_bar_top + BALANCE_FIRST_AID_MEAT_HEALTH_BAR_HEIGHT,
		false
	);
}

// Restore the project's default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
