// Initialize shared map object state.
event_inherited();

// Shrine objective state is updated by corruption projectiles and infected ground.
is_corrupted = false;
shrine_normal_sprite = s_shrine_normal;
shrine_cursed_sprite = s_shrine_cursed;
corruption_radius = BALANCE_SHRINE_CORRUPTION_RADIUS;
max_hp = 10000;
hp = max_hp;
image_speed = 0;
sprite_index = shrine_normal_sprite;
image_index = 0;

// Shrine tooltip describes the run objective.
tooltip_lines = [
	"Goal: taint " + string(BALANCE_SHRINE_OBJECTIVE_REQUIRED) + " of " + string(BALANCE_SHRINE_OBJECTIVE_TOTAL) + " shrines",
	"Taint: taints this shrine",
	"Tainted: spreads Taint in a 450px radius"
];

shrine_corrupt = function()
{
	if (is_corrupted)
	{
		return;
	}

	is_corrupted = true;
	corruption = max_corruption;

	sprite_index = shrine_cursed_sprite;
	image_index = 0;
	image_speed = 0;

	corrupt_circle(x, y, corruption_radius, 1);
};

on_projectile_hit = function(_projectile_type)
{
	if (_projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		shrine_corrupt();
	}
};
