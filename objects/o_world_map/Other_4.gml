// Child settings and Room Editor overrides are ready before rebuilding the graph.
if (room != r_world_map) exit;
display_set_gui_size(gui_width, gui_height);
hovered_level = noone;
hovered_squad = noone;
pinned_level = noone;
pinned_squad = noone;
info_level = noone;
info_squad = noone;
info_scroll = 0;
info_scroll_max = 0;
world_map_levels_build(id);
world_map_corruption_prepare(id);

// Keep the legacy type order without duplicating squad data.
roster_cards = [];
var _squad_count = array_length(squads);
for (var _type = SQUAD_TYPE.ARCHDEMON; _type < SQUAD_TYPE.COUNT; ++_type)
{
	for (var _index = 0; _index < _squad_count; ++_index)
	{
		var _squad = squads[_index];
		if (_squad.squad_type == _type) array_push(roster_cards, _squad);
	}
}
