// Ambient sound loops underneath every phase.
if (!variable_global_exists("play_music"))
{
	global.play_music = BALANCE_PLAY_MUSIC;
}

if (!variable_global_exists("cheats_enabled"))
{
	global.cheats_enabled = BALANCE_CHEATS_ENABLED;
}

ambient_sound = ambient01;
ambient_handle = noone;
ambient_priority = 100;
ambient_gain = 0.45;
ambient_is_paused = false;

// Day music keeps playing while its volume follows the day phase.
day_music_tracks = [
	A_Circle_of_Faun___Mountain_Realm,
	An_Invite_for_the_Northern_Tribes___Mountain_Realm,
	Leaving_Sanctuary___Mountain_Realm,
	SpotiDownloader_com___The_Endless_Game_of_Time___Erang
];
day_music_track_names = [
	"A Circle of Faun - Mountain Realm",
	"An Invite for the Northern Tribes - Mountain Realm",
	"Leaving Sanctuary - Mountain Realm",
	"The Endless Game of Time - Erang"
];

// Night music keeps playing while its volume follows the night phase.
night_music_tracks = [
	Alpha_Omega___Monasterium_Imperium,
	Berserk_OST_Sign_1___Guts,
	BERSERK__Forces____Susumu_Hirasawa,
	Disposal_Unit___Milky_Way_Sweep,
	UltraChurch__ULTRAKILL___Original_Game_Soundtrack____Keygen_Church
];
night_music_track_names = [
	"Alpha Omega - Monasterium Imperium",
	"Berserk OST Sign 1 - Guts",
	"BERSERK Forces - Susumu Hirasawa",
	"Disposal Unit - Milky Way Sweep",
	"UltraChurch - ULTRAKILL Original Game Soundtrack - Keygen Church"
];

// Shared music settings.
current_day_phase = noone;
music_priority = 100;
music_day_gain = 1;
music_night_gain = 0.28;
music_muted_gain = 0;
music_fade_time = 4 * room_speed;
music_track_gap_time = BALANCE_MUSIC_TRACK_GAP_TIME;
music_check_timer = 0;
music_check_interval = room_speed;
music_debug_visible = false;
music_debug_play_attempts = 0;
music_auto_enabled = global.play_music;
music_audio_unlocked = false;

// Compatibility values for the compact now-playing label.
music_handle = noone;
current_music_sound = noone;
current_music_name = "none";
music_current_gain = music_day_gain;
music_target_gain = music_day_gain;

// Day channel state.
day_music_handle = noone;
day_current_music_sound = noone;
day_current_music_name = "none";
day_music_next_previous_sound = noone;
day_music_current_gain = music_day_gain;
day_music_target_gain = music_day_gain;
day_music_reroll_timer = 0;
day_music_waiting_between_tracks = false;

// Night channel state.
night_music_handle = noone;
night_current_music_sound = noone;
night_current_music_name = "none";
night_music_next_previous_sound = noone;
night_music_current_gain = music_muted_gain;
night_music_target_gain = music_muted_gain;
night_music_reroll_timer = 0;
night_music_waiting_between_tracks = false;

music_sound_can_play = function(_sound)
{
	return audio_exists(_sound);
};

music_ambient_start = function()
{
	if (!music_auto_enabled)
	{
		return;
	}

	if (!music_sound_can_play(ambient_sound))
	{
		return;
	}

	if (ambient_handle == noone || !audio_is_playing(ambient_handle))
	{
		music_debug_play_attempts++;
		ambient_handle = audio_play_sound(ambient_sound, ambient_priority, true);
		audio_sound_gain(ambient_handle, ambient_gain, 0);
	}
};

music_day_stop = function()
{
	if (day_music_handle != noone)
	{
		audio_stop_sound(day_music_handle);
	}

	day_music_handle = noone;
	day_current_music_sound = noone;
	day_current_music_name = "none";
};

music_night_stop = function()
{
	if (night_music_handle != noone)
	{
		audio_stop_sound(night_music_handle);
	}

	night_music_handle = noone;
	night_current_music_sound = noone;
	night_current_music_name = "none";
};

music_current_stop = function()
{
	music_day_stop();
	music_night_stop();

	music_handle = noone;
	current_music_sound = noone;
	current_music_name = "none";
};

music_track_name_get = function(_track_names, _track_index)
{
	if (_track_index < array_length(_track_names))
	{
		return _track_names[_track_index];
	}

	return "unknown track";
};

music_next_track_index_get = function(_tracks, _previous_music_sound)
{
	var _track_count = array_length(_tracks);

	if (_track_count <= 0)
	{
		return -1;
	}

	var _chosen_track_index = 0;

	for (var _track_index = 0; _track_index < _track_count; ++_track_index)
	{
		if (_tracks[_track_index] == _previous_music_sound)
		{
			_chosen_track_index = (_track_index + 1) mod _track_count;
			break;
		}
	}

	return _chosen_track_index;
};

music_day_silence_timer_roll = function()
{
	day_music_reroll_timer = music_track_gap_time * room_speed;
	day_music_waiting_between_tracks = true;
};

music_night_silence_timer_roll = function()
{
	night_music_reroll_timer = 0;
	night_music_waiting_between_tracks = false;
	music_night_next_roll();
};

music_day_track_start = function(_track_index)
{
	day_music_waiting_between_tracks = false;
	day_music_next_previous_sound = noone;
	day_music_reroll_timer = 0;
	day_current_music_sound = day_music_tracks[_track_index];
	day_current_music_name = music_track_name_get(day_music_track_names, _track_index);
	music_debug_play_attempts++;
	day_music_handle = audio_play_sound(day_current_music_sound, music_priority, false);
	audio_sound_gain(day_music_handle, day_music_current_gain, 0);
};

music_night_track_start = function(_track_index)
{
	night_music_waiting_between_tracks = false;
	night_music_next_previous_sound = noone;
	night_music_reroll_timer = 0;
	night_current_music_sound = night_music_tracks[_track_index];
	night_current_music_name = music_track_name_get(night_music_track_names, _track_index);
	music_debug_play_attempts++;
	night_music_handle = audio_play_sound(night_current_music_sound, music_priority, false);
	audio_sound_gain(night_music_handle, night_music_current_gain, 0);
};

music_day_next_roll = function()
{
	var _previous_music_sound = day_current_music_sound;

	if (_previous_music_sound == noone && day_music_next_previous_sound != noone)
	{
		_previous_music_sound = day_music_next_previous_sound;
	}

	var _chosen_track_index = music_next_track_index_get(day_music_tracks, _previous_music_sound);

	if (_chosen_track_index < 0)
	{
		music_day_stop();
		return;
	}

	music_day_stop();
	music_day_track_start(_chosen_track_index);
};

music_night_next_roll = function()
{
	var _previous_music_sound = night_current_music_sound;

	if (_previous_music_sound == noone && night_music_next_previous_sound != noone)
	{
		_previous_music_sound = night_music_next_previous_sound;
	}

	var _chosen_track_index = music_next_track_index_get(night_music_tracks, _previous_music_sound);

	if (_chosen_track_index < 0)
	{
		music_night_stop();
		return;
	}

	music_night_stop();
	music_night_track_start(_chosen_track_index);
};

music_target_gain_update = function()
{
	day_music_target_gain = music_day_gain;
	night_music_target_gain = music_muted_gain;

	if (variable_global_exists("day_phase") && global.day_phase == DAY_PHASE.NIGHT)
	{
		day_music_target_gain = music_muted_gain;
		night_music_target_gain = music_night_gain;
	}
};

music_active_track_state_update = function()
{
	var _night_is_louder = night_music_current_gain > day_music_current_gain;

	if (_night_is_louder)
	{
		music_handle = night_music_handle;
		current_music_sound = night_current_music_sound;
		current_music_name = night_current_music_name;
		music_current_gain = night_music_current_gain;
		music_target_gain = night_music_target_gain;
	}
	else
	{
		music_handle = day_music_handle;
		current_music_sound = day_current_music_sound;
		current_music_name = day_current_music_name;
		music_current_gain = day_music_current_gain;
		music_target_gain = day_music_target_gain;
	}
};

music_gain_update = function()
{
	var _fade_step = 1 / max(1, music_fade_time);

	if (day_music_current_gain < day_music_target_gain)
	{
		day_music_current_gain = min(day_music_current_gain + _fade_step, day_music_target_gain);
	}
	else if (day_music_current_gain > day_music_target_gain)
	{
		day_music_current_gain = max(day_music_current_gain - _fade_step, day_music_target_gain);
	}

	if (night_music_current_gain < night_music_target_gain)
	{
		night_music_current_gain = min(night_music_current_gain + _fade_step, night_music_target_gain);
	}
	else if (night_music_current_gain > night_music_target_gain)
	{
		night_music_current_gain = max(night_music_current_gain - _fade_step, night_music_target_gain);
	}

	if (day_music_handle != noone)
	{
		audio_sound_gain(day_music_handle, day_music_current_gain, 0);
	}

	if (night_music_handle != noone)
	{
		audio_sound_gain(night_music_handle, night_music_current_gain, 0);
	}

	music_active_track_state_update();
};

music_phase_update = function()
{
	if (!music_auto_enabled)
	{
		return;
	}

	var _new_day_phase = DAY_PHASE.DAY;

	if (variable_global_exists("day_phase"))
	{
		_new_day_phase = global.day_phase;
	}

	if (current_day_phase != _new_day_phase)
	{
		current_day_phase = _new_day_phase;
		music_target_gain_update();
	}
};

music_start_initial = function()
{
	if (music_audio_unlocked || !music_auto_enabled)
	{
		return;
	}

	music_audio_unlocked = true;
	music_ambient_start();

	// Start both music layers immediately so crossfades do not restart tracks.
	current_day_phase = DAY_PHASE.DAY;

	if (variable_global_exists("day_phase"))
	{
		current_day_phase = global.day_phase;
	}

	music_target_gain_update();
	day_music_current_gain = day_music_target_gain;
	night_music_current_gain = night_music_target_gain;

	if (array_length(day_music_tracks) > 0)
	{
		music_day_track_start(0);
	}
	else
	{
		music_day_silence_timer_roll();
	}

	if (array_length(night_music_tracks) > 0)
	{
		music_night_track_start(0);
	}
	else
	{
		music_night_silence_timer_roll();
	}

	music_active_track_state_update();
};

// Start audio immediately so setup screens are not silent.
music_start_initial();
