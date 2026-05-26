// Initialize shared map object state.
event_inherited();

// Gold mine durability.
max_hp = 100;
hp = max_hp;
max_corruption = 100;
corruption = 0;

// Tooltip lines describe projectile reactions for player targeting.
tooltip_lines = [
	"Damage: +3 Gold",
	"Corruption: Cursed on infected ground",
	"Summon: No effect yet"
];

give_gold_reward = function(_gold_reward)
{
	global.resources[RESOURCES.GOLD] += _gold_reward;
	resource_popup_create(x, y - bar_offset_y, RESOURCES.GOLD, _gold_reward);
};

is_on_corrupted_ground = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _cell_x = clamp(floor(x / _corruption_grid.cell_size), 0, _corruption_grid.grid_width - 1);
	var _cell_y = clamp(floor(y / _corruption_grid.cell_size), 0, _corruption_grid.grid_height - 1);
	var _cell_corruption = ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);

	return _cell_corruption > 0;
};

on_damage_projectile_hit = function()
{
	var _gold_reward = BALANCE_GOLD_MINE_DAMAGE_GOLD_REWARD;

	give_gold_reward(_gold_reward);
};
