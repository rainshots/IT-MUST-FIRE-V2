/// @description Keeps room-wide effects above Y-sorted scenery in the current battle room.
function battle_effect_layers_prepare()
{
	var _instances_layer = layer_get_id("Instances");
	if (_instances_layer == -1)
	{
		return;
	}

	// Effects above Instances in the editor must also cover its dynamically sorted objects.
	var _instances_depth = layer_get_depth(_instances_layer);
	var _layers = layer_get_all();
	var _layer_count = array_length(_layers);
	var _effect_layers = [];
	var _back_effect_depth = -infinity;
	for (var _index = 0; _index < _layer_count; ++_index)
	{
		var _layer_id = _layers[_index];
		var _layer_depth = layer_get_depth(_layer_id);
		if (_layer_depth >= _instances_depth)
		{
			continue;
		}

		var _effect = layer_get_fx(_layer_id);
		if (_effect == -1 || fx_get_single_layer(_effect))
		{
			continue;
		}

		array_push(_effect_layers, _layer_id);
		_back_effect_depth = max(_back_effect_depth, _layer_depth);
	}

	var _effect_count = array_length(_effect_layers);
	if (_effect_count == 0)
	{
		return;
	}

	// Shift the whole stack equally, preserving editor order, parameters and enabled state.
	var _front_world_depth = -room_height - BALANCE_BATTLE_EFFECT_DEPTH_MARGIN;
	var _depth_offset = min(0, _front_world_depth - _back_effect_depth);
	if (_depth_offset == 0)
	{
		return;
	}

	for (var _index = 0; _index < _effect_count; ++_index)
	{
		var _layer_id = _effect_layers[_index];
		layer_depth(_layer_id, layer_get_depth(_layer_id) + _depth_offset);
	}
}
