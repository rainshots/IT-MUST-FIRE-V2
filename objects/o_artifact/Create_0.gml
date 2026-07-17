// Artifact stat and visuals are chosen once when the drop appears.
artifact_stat_options = [CULTIST_STAT.BODY, CULTIST_STAT.SPIRIT, CULTIST_STAT.FERVOR];
artifact_stat = artifact_stat_options[irandom(array_length(artifact_stat_options) - 1)];
artifact_target_cultist = noone;
artifact_is_dragged = false;
artifact_is_hovered = false;
artifact_drag_offset_x = 0;
artifact_drag_offset_y = 0;
artifact_pickup_radius = 34;
artifact_target_radius = 44;
artifact_smoke_count = 14;
artifact_smoke_radius = 28;
artifact_hover_label_offset_y = 40;
artifact_hover_label_padding_x = 7;
artifact_hover_label_padding_y = 4;
artifact_highlight_padding = 8;
artifact_highlight_alpha = 0.82;
artifact_shadow_width = 42;
artifact_shadow_height = 16;

// Artifacts should stay above world objects so dropped rewards are always readable.
y_sort_enabled = false;
depth = BALANCE_ARTIFACT_DEPTH;

artifact_stat_name_get = function()
{
	if (artifact_stat == CULTIST_STAT.BODY)
	{
		return "Body";
	}

	if (artifact_stat == CULTIST_STAT.SPIRIT)
	{
		return "Spirit";
	}

	return "Fervor";
};

artifact_stat_color_get = function()
{
	if (artifact_stat == CULTIST_STAT.BODY)
	{
		return COLOR_CULTIST_BODY;
	}

	if (artifact_stat == CULTIST_STAT.SPIRIT)
	{
		return COLOR_CULTIST_SPIRIT;
	}

	return COLOR_CULTIST_FERVOR;
};

artifact_sprite_apply = function()
{
	if (artifact_stat == CULTIST_STAT.BODY)
	{
		sprite_index = s_body_artifact;
	}
	else if (artifact_stat == CULTIST_STAT.SPIRIT)
	{
		sprite_index = s_spirit_artifact;
	}
	else
	{
		sprite_index = s_fervor_artifact;
	}

	image_speed = 0;
};

artifact_cultist_can_receive = function(_cultist)
{
	return instance_exists(_cultist)
		&& variable_instance_exists(_cultist, "cultist_points")
		&& variable_instance_exists(_cultist, "hp")
		&& _cultist.hp > 0;
};

artifact_cultist_find_at_position = function(_world_x, _world_y)
{
	if (!variable_global_exists("archdemons"))
	{
		return noone;
	}

	var _best_cultist = noone;
	var _best_distance = infinity;
	var _cultist_count = array_length(global.archdemons);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.archdemons[_cultist_index];

		if (!artifact_cultist_can_receive(_cultist))
		{
			continue;
		}

		var _is_inside_box = _world_x >= _cultist.bbox_left - artifact_highlight_padding
			&& _world_x <= _cultist.bbox_right + artifact_highlight_padding
			&& _world_y >= _cultist.bbox_top - artifact_highlight_padding
			&& _world_y <= _cultist.bbox_bottom + artifact_highlight_padding;
		var _distance_to_archdemon = point_distance(_world_x, _world_y, _cultist.x, _cultist.y);

		if ((_is_inside_box || _distance_to_archdemon <= artifact_target_radius)
			&& _distance_to_archdemon < _best_distance)
		{
			_best_cultist = _cultist;
			_best_distance = _distance_to_archdemon;
		}
	}

	return _best_cultist;
};

artifact_smoke_create = function()
{
	for (var _smoke_index = 0; _smoke_index < artifact_smoke_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * artifact_smoke_radius;
		var _smoke_x = x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = y + lengthdir_y(_smoke_distance, _smoke_direction);
		var _smoke = instance_create_layer(_smoke_x, _smoke_y, "Instances", o_particle_smoke);

		if (instance_exists(_smoke))
		{
			_smoke.smoke_color = artifact_stat_color_get();
		}
	}
};

artifact_sound_play = function()
{
	var _sounds = [release_worker10, release_worker07];

	if (variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(_sounds);
	}
	else
	{
		audio_play_sound(_sounds[irandom(array_length(_sounds) - 1)], 1, false);
	}
};

artifact_apply_to_archdemon = function(_cultist)
{
	if (!artifact_cultist_can_receive(_cultist))
	{
		return false;
	}

	_cultist.cultist_points[artifact_stat]++;

	if (variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE && _cultist.object_index != o_archdemon)
	{
		var _cultist_hp = _cultist.hp;

		cultist_stats_apply(_cultist);
		_cultist.hp = clamp(_cultist_hp, 0, _cultist.max_hp);
	}
	else if (variable_instance_exists(_cultist, "demon_type") && _cultist.demon_type != DEMON_TYPE.NONE)
	{
		cultist_day_health_apply(_cultist, false);
	}

	if (variable_instance_exists(_cultist, "assigned_building")
		&& instance_exists(_cultist.assigned_building)
		&& variable_instance_exists(_cultist.assigned_building, "recalculate_production_speed_multiplier"))
	{
		_cultist.assigned_building.recalculate_production_speed_multiplier();
	}

	artifact_smoke_create();
	artifact_sound_play();
	instance_destroy();
	return true;
};

artifact_sprite_apply();
