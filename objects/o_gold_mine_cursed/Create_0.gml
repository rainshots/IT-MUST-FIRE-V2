// Initialize shared map object state.
event_inherited();

// Cursed iron mine durability.
max_hp = 100;
hp = max_hp;
max_corruption = 100;
corruption = max_corruption;

// Passive iron income runs only during the day.
day_iron_reward = BALANCE_GOLD_MINE_CURSED_DAY_IRON_REWARD;
day_reward_interval = BALANCE_GOLD_MINE_CURSED_DAY_REWARD_INTERVAL * room_speed;
day_reward_timer = day_reward_interval;

// Tooltip lines describe projectile reactions for player targeting.
tooltip_lines = [
	"Damage: +3 Iron",
	"Corruption: No effect yet",
	"Summon: No effect yet"
];

give_iron_reward = function(_iron_reward)
{
	global.resources[RESOURCES.IRON] += _iron_reward;
	resource_popup_create(x, y - bar_offset_y, RESOURCES.IRON, _iron_reward);
};

on_damage_projectile_hit = function()
{
	var _iron_reward = BALANCE_GOLD_MINE_DAMAGE_IRON_REWARD;

	give_iron_reward(_iron_reward);
};
