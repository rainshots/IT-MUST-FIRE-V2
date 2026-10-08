/// @description Removes a defeated faction's army and ground before victory pauses the simulation; controller context.
function faction_defeat_cleanup(_faction)
{
	// Cancel hero reservations first so squad cleanup also removes fallen heroes.
	for (var _index = 0; _index < array_length(global.squads); ++_index)
	{
		var _squad = global.squads[_index];
		if (_squad.faction != _faction) continue;
		_squad.hero_respawn_enabled = false;
		_squad.hero_respawn_remaining = 0;
		_squad.ai_target = noone;
	}
	for (var _index = 0; _index < array_length(faction_heroes); ++_index)
	{
		if (faction_heroes[_index].faction == _faction) faction_heroes[_index].waiting_to_respawn = false;
	}
	// Defeat deaths leave corpses but do not trigger resurrection or combat retaliation chains.
	var _unit_groups = [o_units_parent, o_archdemon, o_cultist];
	for (var _group = 0; _group < array_length(_unit_groups); ++_group)
	{
		with (_unit_groups[_group])
		{
			if (!variable_instance_exists(id, "faction") || faction != _faction) continue;
			if (variable_instance_exists(id, "hp")) hp = 0;
			if (variable_instance_exists(id, "unit_corpse_snapshot_create")) unit_corpse_snapshot_create();
			instance_destroy();
		}
	}
	if (instance_exists(o_corruption_grid))
	{
		var _grid = instance_find(o_corruption_grid, 0);
		_grid.defeated_factions[_faction] = true;
		_grid.corruption_protection_dirty = true;
		for (var _cx = 0; _cx < _grid.grid_width; ++_cx)
		{
			for (var _cy = 0; _cy < _grid.grid_height; ++_cy)
			{
				if (ds_grid_get(_grid.corruption_faction_grid, _cx, _cy) != _faction) continue;
				ds_grid_set(_grid.corruption_grid, _cx, _cy, 0);
				ds_grid_set(_grid.corruption_faction_grid, _cx, _cy, FACTION.NONE);
			}
		}
	}
	squad_destroyed_remove();
	// Refresh visual caches now, including the final frame of a match.
	if (instance_exists(o_hud))
	{
		var _hud = instance_find(o_hud, 0);
		_hud.minimap_ground_cache_update();
	}
	if (instance_exists(o_fog_of_war))
	{
		var _fog = instance_find(o_fog_of_war, 0);
		_fog.fog_visibility_update();
	}
	if (_faction == global.player_faction)
	{
		faction_summon_selected = -1;
		faction_summon_release_pending = false;
		if (global.focus_window == FOCUS_WINDOW.SUMMON) global.focus_window = FOCUS_WINDOW.NOONE;
	}
}
