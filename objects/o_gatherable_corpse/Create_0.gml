event_inherited();

// These values are replaced with the source corpse snapshot after creation.
corpse_sprite_index = noone;
corpse_image_index = 0;
corpse_image_xscale = 1;
corpse_image_yscale = 1;
corpse_image_angle = 90;
corpse_image_blend = c_white;
corpse_image_alpha = 1;

on_gather = function()
{
	var _corpse_reward = 1;
    global.resources[RESOURCES.CORPSE] += _corpse_reward;
	//resource_popup_create(x, y - bar_offset_y, RESOURCES.IRON, _iron_reward);
	
	if global.resources[RESOURCES.CORPSE] > 10
	{
		global.resources[RESOURCES.CORPSE] -= 10;
		global.resources[RESOURCES.FLESH]++;
	}
};
