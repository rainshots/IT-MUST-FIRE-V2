// The bell can be clicked even while ordinary gameplay is paused.
var _click_is_available = effect_is_active
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& map_object_is_hovered()
	&& mouse_check_button_pressed(mb_left);

if (_click_is_available)
{
	doom_bell_destroy();
	exit;
}

// Pause freezes both the lifetime and the dynamic silence zone.
if (global.pause || !effect_is_active)
{
	exit;
}

var _gameplay_time_scale = variable_global_exists("gameplay_time_scale")
	? global.gameplay_time_scale
	: 1;

effect_timer = max(0, effect_timer - _gameplay_time_scale);

if (effect_timer <= 0)
{
	doom_bell_destroy();
	exit;
}

if (doom_bell_enchantment == DOOM_BELL_ENCHANTMENT.DEAD_SILENCE)
{
	silence_scan_timer -= _gameplay_time_scale;

	if (silence_scan_timer <= 0)
	{
		silence_scan_timer = silence_scan_interval;
		doom_bell_dead_silence_refresh();
	}
}
