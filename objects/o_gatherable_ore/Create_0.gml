event_inherited();

on_gather = function()
{
	var _iron_reward = 1;
    global.resources[RESOURCES.IRON] += _iron_reward;
	//resource_popup_create(x, y - bar_offset_y, RESOURCES.IRON, _iron_reward);
};
