// Initialize shared map object state.
event_inherited();

// Ihor Extractor works only while standing on tainted ground.
is_captured = true;
tower_capture_enabled = false;
sprite_index = s_ihor_extractor;
image_speed = 0;
max_hp = BALANCE_PLAYER_BUILDING_MAX_HP;
hp = max_hp;
effect_radius = BALANCE_IHOR_EXTRACTOR_RADIUS;
corruption_check_interval = BALANCE_PLAYER_BUILDING_CORRUPTION_CHECK_INTERVAL;
corruption_check_timer = irandom(corruption_check_interval - 1);

// Ihor production is driven by active veins in radius.
ihor_production_progress = 0;
ihor_production_time = BALANCE_IHOR_EXTRACTOR_PRODUCTION_TIME * room_speed;
ihor_production_speed = BALANCE_IHOR_EXTRACTOR_BASE_SPEED;
ihor_next_vein_index = 0;
ihor_popup_offset_y = 70;

var _full_vein_speed_text = string(BALANCE_IHOR_EXTRACTOR_FULL_VEIN_SPEED);
var _empty_vein_speed_text = string(BALANCE_IHOR_EXTRACTOR_EMPTY_VEIN_SPEED);

tooltip_lines = [
	"Ihor Extractor: produces Ihor during the day",
	"Each full Ihor Vein adds +" + _full_vein_speed_text + " speed; depleted adds +" + _empty_vein_speed_text,
	"Stops working if its ground is cleansed"
];

ihor_extractor_vein_count_get = function()
{
	var _vein_count = instance_number(o_ihor_vein);
	var _production_speed = BALANCE_IHOR_EXTRACTOR_BASE_SPEED;

	for (var _vein_index = 0; _vein_index < _vein_count; ++_vein_index)
	{
		var _vein = instance_find(o_ihor_vein, _vein_index);

		if (!instance_exists(_vein)
			|| !variable_instance_exists(_vein, "ihor_remaining")
			|| point_distance(x, y, _vein.x, _vein.y) > effect_radius)
		{
			continue;
		}

		if (!variable_instance_exists(_vein, "assigned_ihor_extractor")
			|| !instance_exists(_vein.assigned_ihor_extractor)
			|| _vein.assigned_ihor_extractor == id)
		{
			if (!variable_instance_exists(_vein, "assigned_ihor_extractor")
				|| !instance_exists(_vein.assigned_ihor_extractor))
			{
				_vein.assigned_ihor_extractor = id;
			}

			_production_speed += (_vein.ihor_remaining > 0)
				? BALANCE_IHOR_EXTRACTOR_FULL_VEIN_SPEED
				: BALANCE_IHOR_EXTRACTOR_EMPTY_VEIN_SPEED;
		}
	}

	ihor_production_speed = _production_speed;
	return _production_speed;
};

ihor_extractor_production_speed_get = function()
{
	if (!is_captured)
	{
		return 0;
	}

	return ihor_extractor_vein_count_get();
};

ihor_extractor_consume_active_vein = function()
{
	var _vein_count = instance_number(o_ihor_vein);

	for (var _vein_step = 0; _vein_step < _vein_count; ++_vein_step)
	{
		var _vein_index = (ihor_next_vein_index + _vein_step) mod max(1, _vein_count);
		var _vein = instance_find(o_ihor_vein, _vein_index);

		if (!instance_exists(_vein)
			|| !variable_instance_exists(_vein, "assigned_ihor_extractor")
			|| _vein.assigned_ihor_extractor != id
			|| !variable_instance_exists(_vein, "ihor_vein_consume"))
		{
			continue;
		}

		if (_vein.ihor_vein_consume(1) > 0)
		{
			ihor_next_vein_index = (_vein_index + 1) mod max(1, _vein_count);
			return true;
		}
	}

	return false;
};
