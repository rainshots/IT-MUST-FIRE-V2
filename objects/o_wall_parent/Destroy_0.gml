// Defeated walls play their animation at the collider center before disappearing.
if (hp <= 0 && wall_destroy_effect_object != noone)
{
	var _effect_x = (bbox_left + bbox_right) * 0.5;
	var _effect_y = (bbox_top + bbox_bottom) * 0.5;
	// Use the shared effect layer because the wall may no longer belong to a layer.
	instance_create_layer(_effect_x, _effect_y, "Instances", wall_destroy_effect_object);
}

// Removing a wall opens its cells on the shared navigation grid.
wall_navigation_mark_dirty();
