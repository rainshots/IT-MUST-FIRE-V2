// Select projectile color by type.
var _projectile_color = COLOR_PROJECTILE_DAMAGE;

if (projectile_type == PROJECTILE_TYPE.CORRUPTION)
{
	_projectile_color = COLOR_PROJECTILE_CORRUPTION;
}
else if (projectile_type == PROJECTILE_TYPE.SUMMON)
{
	_projectile_color = COLOR_PROJECTILE_SUMMON;
}
else if (projectile_type == PROJECTILE_TYPE.RALLY)
{
	_projectile_color = COLOR_PROJECTILE_RALLY;
}
else if (projectile_type == PROJECTILE_TYPE.CULTIST)
{
	_projectile_color = COLOR_PROJECTILE_CULTIST;
}
else if (projectile_type == PROJECTILE_TYPE.FEAST)
{
	_projectile_color = COLOR_PROJECTILE_CORRUPTION;
}
else if (projectile_type == PROJECTILE_TYPE.HEAL)
{
	_projectile_color = COLOR_PROJECTILE_HEAL;
}
else if (projectile_type == PROJECTILE_TYPE.BOMB)
{
	_projectile_color = COLOR_PROJECTILE_BOMB;
}
else if (projectile_type == PROJECTILE_TYPE.SKELETONS)
{
	_projectile_color = COLOR_PROJECTILE_SKELETONS;
}
else if (projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
{
	_projectile_color = COLOR_PROJECTILE_BUILDING_SHELL;
}
else if (projectile_type == PROJECTILE_TYPE.CLEANSE)
{
	_projectile_color = COLOR_PROJECTILE_CLEANSE;
}
else if (projectile_type == PROJECTILE_TYPE.ARTILLERY)
{
	_projectile_color = COLOR_PROJECTILE_BOMB;
}

// Draw a round projectile.
var _draw_radius = projectile_radius * projectile_visual_scale;

draw_set_color(_projectile_color);
draw_circle(x, y, _draw_radius, false);

// Restore default draw state.
draw_set_color(c_white);
