/// @description Recognizes battle copies and any custom room assigned to the attacked map point.
function battle_room_is_battle(_room)
{
	switch (_room)
	{
		case Battle_room:
		case r_battle_02:
		case r_battle_03:
		case r_battle_04:
		case r_battle_05:
		case r_battle_06:
		case r_battle_07:
		case r_battle_08:
		case r_battle_09:
		case r_battle_10:
		case r_battle_11:
			return true;
	}
	var _map = instance_find(o_world_map, 0);
	return instance_exists(_map) && _map.active_battle_room == _room;
}
