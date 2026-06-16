// Toggle temporary audio diagnostics while fixing music playback.
if (global.cheats_enabled && keyboard_check_pressed(vk_f10))
{
	music_debug_visible = !music_debug_visible;
}

music_auto_enabled = global.play_music;

if (!music_auto_enabled)
{
	music_current_stop();

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

// Wait a fixed pause after a track ends before choosing the next one.
if (music_waiting_between_tracks)
{
	music_reroll_timer = max(0, music_reroll_timer - 1);

	if (music_reroll_timer <= 0)
	{
		music_waiting_between_tracks = false;
		music_next_roll();
	}

	exit;
}

// Avoid checking the music handle every frame.
if (music_check_timer > 0)
{
	music_check_timer--;
	exit;
}

music_check_timer = music_check_interval;

// Silence is an intentional music state between possible tracks.
if (music_handle == noone)
{
	music_silence_timer_roll();
	exit;
}

// Pick another track or silence once the current music finishes.
if (!audio_is_playing(music_handle))
{
	music_next_previous_sound = current_music_sound;
	music_current_stop();
	music_silence_timer_roll();
}
