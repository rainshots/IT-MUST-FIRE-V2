// Draw current music track label in the bottom-right corner.
var _track_name = "none";

if (current_music_name != "")
{
	_track_name = current_music_name;
}

var _track_text = "Now playing: " + _track_name;
var _track_padding_x = 12;
var _track_padding_y = 8;
var _track_margin = 18;
var _track_width = string_width(_track_text) + (_track_padding_x * 2);
var _track_height = string_height(_track_text) + (_track_padding_y * 2);
var _gui_width = display_get_gui_width();
var _gui_height = display_get_gui_height();
var _track_x = _gui_width - _track_margin - _track_width;
var _track_y = _gui_height - _track_margin - _track_height;

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(0.72);
draw_set_color(c_black);
draw_rectangle(_track_x, _track_y, _track_x + _track_width, _track_y + _track_height, false);

draw_set_alpha(1);
draw_set_color(c_white);
draw_text(_track_x + _track_padding_x, _track_y + _track_padding_y, _track_text);

// Temporary audio diagnostics while music playback is being verified.
if (!music_debug_visible)
{
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

var _debug_x = 18;
var _debug_y = 120;
var _line_height = 18;
var _ambient_playing = audio_is_playing(ambient_sound);
var _ambient_handle_playing = false;
var _music_playing = false;

if (ambient_handle != noone)
{
	_ambient_handle_playing = audio_is_playing(ambient_handle);
}

if (music_handle != noone)
{
	_music_playing = audio_is_playing(music_handle);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(0.82);
draw_set_color(c_black);
draw_rectangle(_debug_x - 8, _debug_y - 8, _debug_x + 430, _debug_y + 150, false);

draw_set_alpha(1);
draw_set_color(c_white);
draw_text(_debug_x, _debug_y, "Music debug (F10)");
draw_text(_debug_x, _debug_y + (_line_height * 1), "ambient sound: " + string(ambient_sound));
draw_text(_debug_x, _debug_y + (_line_height * 2), "ambient handle: " + string(ambient_handle));
draw_text(_debug_x, _debug_y + (_line_height * 3), "ambient sound playing: " + string(_ambient_playing));
draw_text(_debug_x, _debug_y + (_line_height * 4), "ambient handle playing: " + string(_ambient_handle_playing));
draw_text(_debug_x, _debug_y + (_line_height * 5), "music handle: " + string(music_handle));
draw_text(_debug_x, _debug_y + (_line_height * 6), "music playing: " + string(_music_playing));
draw_text(_debug_x, _debug_y + (_line_height * 7), "play attempts: " + string(music_debug_play_attempts));
draw_text(_debug_x, _debug_y + (_line_height * 8), "music gain: " + string(music_current_gain));
draw_text(_debug_x, _debug_y + (_line_height * 9), "music target gain: " + string(music_target_gain));
draw_text(_debug_x, _debug_y + (_line_height * 10), "audio unlocked: " + string(music_audio_unlocked));
draw_text(_debug_x, _debug_y + (_line_height * 11), "F10 toggles this panel");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
