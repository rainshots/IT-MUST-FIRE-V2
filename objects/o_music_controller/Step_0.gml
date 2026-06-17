// Toggle temporary audio diagnostics while fixing music playback.
if (global.cheats_enabled && keyboard_check_pressed(vk_f10))
{
	music_debug_visible = !music_debug_visible;
}

music_auto_enabled = global.play_music;

if (!music_auto_enabled)
{
	music_current_stop();
	day_music_waiting_between_tracks = false;
	night_music_waiting_between_tracks = false;

	if (ambient_handle != noone)
	{
		audio_stop_sound(ambient_handle);
		ambient_handle = noone;
	}

	exit;
}

// Keep ambient alive even if it was stopped by room or audio changes.
music_ambient_start();

// React quickly when day changes to night or night returns to day.
music_phase_update();
music_gain_update();

// Wait a fixed pause after a day track ends before choosing the next one.
if (day_music_waiting_between_tracks)
{
	day_music_reroll_timer = max(0, day_music_reroll_timer - 1);

	if (day_music_reroll_timer <= 0)
	{
		day_music_waiting_between_tracks = false;
		music_day_next_roll();
	}
}

// Avoid checking music handles every frame.
if (music_check_timer > 0)
{
	music_check_timer--;
	exit;
}

music_check_timer = music_check_interval;

// Silence is an intentional day music state between possible tracks.
if (day_music_handle == noone)
{
	if (array_length(day_music_tracks) > 0 && !day_music_waiting_between_tracks)
	{
		music_day_silence_timer_roll();
	}
}
else if (!audio_is_playing(day_music_handle))
{
	day_music_next_previous_sound = day_current_music_sound;
	music_day_stop();
	music_day_silence_timer_roll();
}

// Night music should continue without an intentional pause between tracks.
if (night_music_handle == noone)
{
	if (array_length(night_music_tracks) > 0)
	{
		music_night_silence_timer_roll();
	}
}
else if (!audio_is_playing(night_music_handle))
{
	night_music_next_previous_sound = night_current_music_sound;
	music_night_stop();
	music_night_silence_timer_roll();
}
