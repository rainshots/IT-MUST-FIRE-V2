// Toggle temporary audio diagnostics while fixing music playback.
if (keyboard_check_pressed(vk_f10))
{
	music_debug_visible = !music_debug_visible;
}

// Keep ambient alive even if it was stopped by room or audio changes.
music_ambient_start();

// React quickly when day changes to night or night returns to day.
music_phase_update();
music_gain_update();

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
	if (music_reroll_timer > 0)
	{
		music_reroll_timer--;
	}

	if (music_reroll_timer <= 0)
	{
		music_next_roll();
	}

	exit;
}

// Pick another track or silence once the current music finishes.
if (!audio_is_playing(music_handle))
{
	music_next_roll();
}
