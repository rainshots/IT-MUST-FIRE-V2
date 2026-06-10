// Stop sounds owned by this controller when the room is cleaned up.
if (ambient_handle != noone)
{
	audio_stop_sound(ambient_handle);
	ambient_handle = noone;
}

music_current_stop();
