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
corruption_bar_visible = false;
corruption_check_interval = BALANCE_PLAYER_BUILDING_CORRUPTION_CHECK_INTERVAL;
corruption_check_timer = irandom(corruption_check_interval - 1);

// Ihor income is collected once each morning from active veins in radius.
ihor_morning_income = 0;
ihor_popup_offset_y = 70;

var _full_vein_income_text = string(BALANCE_IHOR_EXTRACTOR_FULL_VEIN_MORNING_IHOR);

tooltip_lines = [
	"Ihor Extractor: collects Ihor each morning",
	"Each active Ihor Vein gives +" + _full_vein_income_text + " Ihor in the morning",
	"Stops working if its ground is cleansed"
];

ihor_extractor_morning_income_get = function()
{
	var _vein_count = instance_number(o_ihor_vein);
	var _morning_income = 0;

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

			_morning_income += (_vein.ihor_remaining > 0)
				? BALANCE_IHOR_EXTRACTOR_FULL_VEIN_MORNING_IHOR
				: BALANCE_IHOR_EXTRACTOR_EMPTY_VEIN_MORNING_IHOR;
		}
	}

	ihor_morning_income = _morning_income;
	return _morning_income;
};

ihor_extractor_morning_income_preview_get = function()
{
	if (!is_captured)
	{
		ihor_morning_income = 0;
		return 0;
	}

	return ihor_extractor_morning_income_get();
};

ihor_extractor_morning_income_collect = function()
{
	if (!is_captured)
	{
		ihor_morning_income = 0;
		return 0;
	}

	ihor_extractor_morning_income_get();

	var _vein_count = instance_number(o_ihor_vein);
	var _collected_ihor = 0;

	for (var _vein_index = 0; _vein_index < _vein_count; ++_vein_index)
	{
		var _vein = instance_find(o_ihor_vein, _vein_index);

		if (!instance_exists(_vein)
			|| !variable_instance_exists(_vein, "assigned_ihor_extractor")
			|| _vein.assigned_ihor_extractor != id
			|| !variable_instance_exists(_vein, "ihor_vein_consume"))
		{
			continue;
		}

		var _vein_income = (_vein.ihor_remaining > 0)
			? BALANCE_IHOR_EXTRACTOR_FULL_VEIN_MORNING_IHOR
			: BALANCE_IHOR_EXTRACTOR_EMPTY_VEIN_MORNING_IHOR;

		if (_vein_income <= 0)
		{
			continue;
		}

		if (_vein.ihor_remaining > 0)
		{
			_collected_ihor += _vein.ihor_vein_consume(_vein_income);
		}
		else
		{
			_collected_ihor += _vein_income;
		}
	}

	if (_collected_ihor > 0)
	{
		global.resources[RESOURCES.IHOR] += _collected_ihor;
		resource_popup_create(x, y - ihor_popup_offset_y, RESOURCES.IHOR, _collected_ihor);
	}

	ihor_extractor_morning_income_get();
	return _collected_ihor;
};
