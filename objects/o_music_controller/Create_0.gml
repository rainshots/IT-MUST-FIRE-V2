// Ambient sound loops underneath every phase.
ambient_sound = ambient01;
ambient_handle = noone;
ambient_priority = 100;
ambient_gain = 0.45;
ambient_is_paused = false;

// Day music rotates between imported day tracks.
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

// Night music is empty until night tracks are imported.
night_music_tracks = [];
night_music_track_names = [];

// Music may intentionally rest between tracks.
music_handle = noone;
current_music_sound = noone;
current_music_name = "none";
current_day_phase = noone;
music_priority = 100;
music_day_gain = 1;
music_night_gain = 0.28;
music_current_gain = music_day_gain;
music_target_gain = music_day_gain;
music_fade_time = 4 * room_speed;
music_silence_chance = 0.35;
music_reroll_timer = 0;
music_silence_time_min = 6 * room_speed;
music_silence_time_max = 18 * room_speed;
music_check_timer = 0;
music_check_interval = room_speed;
music_debug_visible = false;
music_debug_play_attempts = 0;
music_auto_enabled = true;
music_audio_unlocked = false;

music_sound_can_play = function(_sound)
{
	return is_real(_sound) && _sound >= 0;
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

music_current_stop = function()
{
	if (music_handle != noone)
	{
		audio_stop_sound(music_handle);
	}

	music_handle = noone;
	current_music_sound = noone;
	current_music_name = "none";
};

music_phase_tracks_get = function()
{
	if (variable_global_exists("day_phase") && global.day_phase == DAY_PHASE.NIGHT)
	{
		return night_music_tracks;
	}

	return day_music_tracks;
};

music_phase_track_names_get = function()
{
	if (variable_global_exists("day_phase") && global.day_phase == DAY_PHASE.NIGHT)
	{
		return night_music_track_names;
	}

	return day_music_track_names;
};

music_silence_timer_roll = function()
{
	music_reroll_timer = irandom_range(music_silence_time_min, music_silence_time_max);
};

music_track_start = function(_track, _track_name)
{
	current_music_sound = _track;
	current_music_name = _track_name;
	music_debug_play_attempts++;
	music_handle = audio_play_sound(current_music_sound, music_priority, false);
	music_current_gain = music_target_gain;
	audio_sound_gain(music_handle, music_current_gain, 0);
};

music_target_gain_update = function()
{
	music_target_gain = music_day_gain;

	if (variable_global_exists("day_phase") && global.day_phase == DAY_PHASE.NIGHT)
	{
		music_target_gain = music_night_gain;
	}
};

music_gain_update = function()
{
	if (music_handle == noone)
	{
		return;
	}

	var _fade_step = 1 / max(1, music_fade_time);

	if (music_current_gain < music_target_gain)
	{
		music_current_gain = min(music_current_gain + _fade_step, music_target_gain);
	}
	else if (music_current_gain > music_target_gain)
	{
		music_current_gain = max(music_current_gain - _fade_step, music_target_gain);
	}

	audio_sound_gain(music_handle, music_current_gain, 0);
};

music_next_roll = function()
{
	var _can_choose_silence = current_music_sound != noone;

	music_current_stop();

	var _phase_tracks = music_phase_tracks_get();
	var _phase_track_names = music_phase_track_names_get();
	var _track_count = array_length(_phase_tracks);

	if (_track_count <= 0 || (_can_choose_silence && random(1) < music_silence_chance))
	{
		music_silence_timer_roll();
		return;
	}

	var _valid_tracks = [];
	var _valid_track_names = [];

	for (var _track_index = 0; _track_index < _track_count; ++_track_index)
	{
		var _track = _phase_tracks[_track_index];

		if (music_sound_can_play(_track))
		{
			array_push(_valid_tracks, _track);

			if (_track_index < array_length(_phase_track_names))
			{
				array_push(_valid_track_names, _phase_track_names[_track_index]);
			}
			else
			{
				array_push(_valid_track_names, "unknown track");
			}
		}
	}

	var _valid_track_count = array_length(_valid_tracks);

	if (_valid_track_count <= 0)
	{
		music_silence_timer_roll();
		return;
	}

	var _chosen_track_index = irandom(_valid_track_count - 1);
	music_track_start(_valid_tracks[_chosen_track_index], _valid_track_names[_chosen_track_index]);
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
	if (music_audio_unlocked)
	{
		return;
	}

	music_audio_unlocked = true;
	music_debug_play_attempts++;
	ambient_handle = audio_play_sound(ambient01, 100, true);
	audio_sound_gain(ambient_handle, ambient_gain, 0);

	// Start the first music track immediately with the room phase volume.
	current_day_phase = DAY_PHASE.DAY;

	if (variable_global_exists("day_phase"))
	{
		current_day_phase = global.day_phase;
	}

	music_target_gain_update();

	var _start_tracks = music_phase_tracks_get();
	var _start_track_names = music_phase_track_names_get();

	if (array_length(_start_tracks) > 0)
	{
		var _start_track_name = "unknown track";

		if (array_length(_start_track_names) > 0)
		{
			_start_track_name = _start_track_names[0];
		}

		music_track_start(_start_tracks[0], _start_track_name);
	}
	else
	{
		music_silence_timer_roll();
	}
};

// Start audio immediately so setup screens are not silent.
music_start_initial();
