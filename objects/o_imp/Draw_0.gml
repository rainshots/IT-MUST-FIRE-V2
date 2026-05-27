// Draw base combat visuals.
event_inherited();

// Draw a pulsing aura while Frenzy is active.
if (demon_ability == DEMON_ABILITY.IMP_FRENZY && ability_active_timer > 0)
{
	var _pulse = (sin(current_time * 0.02) + 1) * 0.5;
	var _aura_radius = BALANCE_IMP_FRENZY_AURA_RADIUS + (_pulse * BALANCE_IMP_FRENZY_AURA_PULSE_AMOUNT);

	draw_set_alpha(0.25 + (_pulse * 0.25));
	draw_set_color(COLOR_IMP_FRENZY_AURA);
	draw_circle(x, y, _aura_radius, false);
	draw_set_alpha(0.85);
	draw_circle(x, y, _aura_radius, true);
}

// Draw a red aura while Blood Rage is active.
if (demon_ability == DEMON_ABILITY.IMP_BLOOD_RAGE && hp < max_hp * BALANCE_ABILITY_IMP_BLOOD_RAGE_HP_THRESHOLD)
{
	var _blood_pulse = (sin(current_time * 0.028) + 1) * 0.5;
	var _blood_aura_radius = BALANCE_IMP_BLOOD_RAGE_AURA_RADIUS + (_blood_pulse * BALANCE_IMP_BLOOD_RAGE_AURA_PULSE_AMOUNT);

	draw_set_alpha(0.22 + (_blood_pulse * 0.3));
	draw_set_color(COLOR_IMP_BLOOD_RAGE_AURA);
	draw_circle(x, y, _blood_aura_radius, false);
	draw_set_alpha(0.9);
	draw_circle(x, y, _blood_aura_radius, true);
}

// Draw the cultist name above the demon.
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_text(x, y - 42, cultist_name);

// Draw active ability cooldown below the health bar.
if (ability_cooldown > 0)
{
	var _bar_width = 34;
	var _bar_height = 3;
	var _bar_x = x - (_bar_width * 0.5);
	var _bar_y = y + 32;
	var _progress = 1 - clamp(ability_timer / max(ability_cooldown, 1), 0, 1);

	draw_set_alpha(0.75);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_ABILITY_BAR);
	draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * _progress), _bar_y + _bar_height, false);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
