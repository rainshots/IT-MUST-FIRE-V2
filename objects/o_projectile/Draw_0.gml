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

// Draw a round projectile.
draw_set_color(_projectile_color);
draw_circle(x, y, projectile_radius, false);

// Restore default draw state.
draw_set_color(c_white);
