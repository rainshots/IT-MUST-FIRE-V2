// Initialize shared map object state.
event_inherited();

// Cursed gold mine durability.
max_hp = 100;
hp = max_hp;
max_corruption = 100;
corruption = max_corruption;

// Passive gold income runs only during the day.
day_gold_reward = BALANCE_GOLD_MINE_CURSED_DAY_GOLD_REWARD;
day_reward_interval = BALANCE_GOLD_MINE_CURSED_DAY_REWARD_INTERVAL * room_speed;
day_reward_timer = day_reward_interval;

// Tooltip lines describe projectile reactions for player targeting.
tooltip_lines = [
	"Damage: +3 Gold",
	"Corruption: No effect yet",
	"Summon: No effect yet"
];

give_gold_reward = function(_gold_reward)
{
	global.resources[RESOURCES.GOLD] += _gold_reward;
	resource_popup_create(x, y - bar_offset_y, RESOURCES.GOLD, _gold_reward);
};

on_damage_projectile_hit = function()
{
	var _gold_reward = BALANCE_GOLD_MINE_DAMAGE_GOLD_REWARD;

	give_gold_reward(_gold_reward);
};
