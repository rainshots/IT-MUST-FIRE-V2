/// @description Assigns the player faction and prepares its starting view; called by o_game_controller.
function faction_player_assign(_faction)
{
	var _base = faction_base_find(_faction);
	if (!instance_exists(_base))
	{
		return false;
	}

	global.player_faction = _faction;
	player_base = _base;
	faction_match_states = [];
	var _faction_count = array_length(faction_choices);
	for (var _index = 0; _index < _faction_count; ++_index)
	{
		var _choice = faction_choices[_index];
		var _faction_base = faction_base_find(_choice.faction);
		array_push(faction_match_states, {
			faction: _choice.faction,
			name: _choice.name,
			base: _faction_base,
			defeated: !instance_exists(_faction_base),
			defeat_cleanup_done: false
		});
	}
	faction_match_started = true;
	faction_heroes_initialize();

	// Snap both the camera controller and its actual view before the chooser closes.
	if (instance_exists(o_camera_controller))
	{
		var _camera = instance_find(o_camera_controller, 0);
		_camera.camera_center_on_instance(_base);
		camera_set_view_pos(_camera.camera_id,
			round(_camera.x - _camera.half_view_width),
			round(_camera.y - _camera.half_view_height));
	}

	// Reveal immediately and refresh on the next fog tick to prevent a dark opening frame.
	if (instance_exists(o_fog_of_war))
	{
		var _fog = instance_find(o_fog_of_war, 0);
		_fog.fog_visibility_update();
		_fog.update_timer = _fog.update_interval;
	}
	return true;
}
