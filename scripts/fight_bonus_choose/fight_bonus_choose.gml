/// @description Applies exactly one offered bonus and resumes the fight; controller context.
function fight_bonus_choose(_index)
{
	if (!fight_bonus_open || _index < 0 || _index >= array_length(fight_bonus_options)) return false;
	var _bonus = fight_bonus_options[_index];
	var _building = noone;
	switch (_bonus)
	{
		case FIGHT_BONUS.FORGE: _building = o_forge; break;
		case FIGHT_BONUS.FURNACE: _building = o_furnace; break;
		case FIGHT_BONUS.CAULDRON: _building = o_cauldron; break;
	}
	if (_building != noone)
	{
		var _position = fight_bonus_building_position_get(_building);
		if (is_undefined(_position))
		{
			fight_bonus_notice = "No free building space. Choose another bonus.";
			return false;
		}
		instance_create_layer(_position.x, _position.y, "Instances", _building);
	}
	else switch (_bonus)
	{
		case FIGHT_BONUS.SQUAD: global.squad_limit++; break;
		case FIGHT_BONUS.AMMO: cannon_ammo_capacity++; break;
		case FIGHT_BONUS.NECRO: cannon_necro_unlocked = true; break;
		case FIGHT_BONUS.CULTIST:
			instance_create_layer(o_cannon.x, o_cannon.y + BALANCE_DAY_CANNON_REGROUP_OFFSET_Y, "Instances", o_cultist);
			break;
	}
	fight_bonus_open = false;
	fight_bonus_options = [];
	global.pause = false;
	player_pause_active = false;
	return true;
}
