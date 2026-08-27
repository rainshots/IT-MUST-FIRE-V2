// Restore the gameplay camera if this UI is destroyed while Assign Duties is open.
if (global.focus_window == FOCUS_WINDOW.JOBS && instance_exists(o_camera_controller))
{
	var _camera_controller = instance_find(o_camera_controller, 0);

	if (variable_instance_exists(_camera_controller, "camera_jobs_view_close"))
	{
		_camera_controller.camera_jobs_view_close();
	}
}

// The Whip exists only as part of this Jobs interface.
if (instance_exists(jobs_whip))
{
	instance_destroy(jobs_whip);
}

// Runtime fonts belong to this window and must be released with it.
if (font_exists(jobs_title_font))
{
	font_delete(jobs_title_font);
}

if (font_exists(jobs_description_font))
{
	font_delete(jobs_description_font);
}

if (font_exists(jobs_button_font))
{
	font_delete(jobs_button_font);
}

if (font_exists(jobs_hp_font))
{
	font_delete(jobs_hp_font);
}

if (font_exists(jobs_show_font))
{
	font_delete(jobs_show_font);
}

if (font_exists(jobs_action_font))
{
	font_delete(jobs_action_font);
}

if (font_exists(jobs_world_action_font))
{
	font_delete(jobs_world_action_font);
}

if (font_exists(jobs_onboarding_font))
{
	font_delete(jobs_onboarding_font);
}
