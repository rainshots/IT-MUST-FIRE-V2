// Pause freezes neutral hut workers with the rest of gameplay.
if (global.pause)
{
	exit;
}

if (!instance_exists(owner_hut))
{
	instance_destroy();
	exit;
}

home_x = owner_hut.x + home_offset_x;
home_y = owner_hut.y + home_offset_y;

if (!owner_hut.is_captured || global.day_phase == DAY_PHASE.NIGHT || !instance_exists(o_cannon))
{
	if (instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "cannon_corpse_worker_drop"))
		{
			_game_controller.cannon_corpse_worker_drop(id);
		}
	}

	orc_move_towards(home_x, home_y);
	exit;
}

// Daytime captured huts let neutral orcs haul only corpses near the hut.
corpse_search_center_x = owner_hut.x;
corpse_search_center_y = owner_hut.y;
corpse_search_radius = owner_hut.effect_radius;

if (!instance_exists(o_game_controller))
{
	orc_move_towards(home_x, home_y);
	exit;
}

var _game_controller = instance_find(o_game_controller, 0);
var _cannon = instance_find(o_cannon, 0);

if (!variable_instance_exists(_game_controller, "cannon_worker_carried_corpses_sync")
	|| !variable_instance_exists(_game_controller, "cannon_worker_carried_corpse_count_get")
	|| !variable_instance_exists(_game_controller, "cannon_worker_carried_corpse_add")
	|| !variable_instance_exists(_game_controller, "corpse_get_by_id")
	|| !variable_instance_exists(_game_controller, "corpse_nearest_reserve")
	|| !variable_instance_exists(_game_controller, "corpse_reserved_take")
	|| !variable_instance_exists(_game_controller, "corpse_reservation_clear")
	|| !variable_instance_exists(_game_controller, "cannon_satiety_add"))
{
	orc_move_towards(home_x, home_y);
	exit;
}

_game_controller.cannon_worker_carried_corpses_sync(id);
var _carried_corpse_count = _game_controller.cannon_worker_carried_corpse_count_get(id);

if (_carried_corpse_count > 0)
{
	var _deliver_distance = point_distance(x, y, _cannon.x, _cannon.y);

	if (_deliver_distance <= BALANCE_CANNON_CORPSE_DELIVER_RADIUS)
	{
		_game_controller.cannon_satiety_add(BALANCE_CANNON_SATIETY_PER_CORPSE * _carried_corpse_count);
		carried_corpses = [];
		carried_corpse = noone;
		reserved_corpse_id = noone;
		orc_move_towards(home_x, home_y);
		exit;
	}

	orc_move_towards(_cannon.x, _cannon.y);
	exit;
}

var _reserved_corpse = noone;

if (reserved_corpse_id != noone)
{
	_reserved_corpse = _game_controller.corpse_get_by_id(reserved_corpse_id);
}

if (!is_struct(_reserved_corpse))
{
	_game_controller.corpse_reservation_clear(reserved_corpse_id, id);
	_reserved_corpse = _game_controller.corpse_nearest_reserve(x, y, id);

	if (is_struct(_reserved_corpse) && variable_struct_exists(_reserved_corpse, "corpse_id"))
	{
		reserved_corpse_id = _reserved_corpse.corpse_id;
	}
	else
	{
		reserved_corpse_id = noone;
	}
}

if (!is_struct(_reserved_corpse))
{
	orc_move_towards(home_x, home_y);
	exit;
}

var _pickup_distance = point_distance(x, y, _reserved_corpse.x, _reserved_corpse.y);

if (_pickup_distance <= BALANCE_CANNON_CORPSE_PICKUP_RADIUS)
{
	var _taken_corpse = _game_controller.corpse_reserved_take(reserved_corpse_id, id);
	reserved_corpse_id = noone;

	if (is_struct(_taken_corpse))
	{
		_game_controller.cannon_worker_carried_corpse_add(id, _taken_corpse);
	}

	exit;
}

orc_move_towards(_reserved_corpse.x, _reserved_corpse.y);
