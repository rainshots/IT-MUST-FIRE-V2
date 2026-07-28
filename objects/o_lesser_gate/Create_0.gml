// Temporary Ritual Circle portal releases one random friendly creature per interval.
spawn_interval = BALANCE_RITUAL_LESSER_GATE_SPAWN_INTERVAL * room_speed;
spawn_timer = spawn_interval;
spawn_radius = 70;
spawn_unit_objects = [
	o_skeleton,
	o_skeleton_bonelet,
	o_skeleton_warrior,
	o_skeleton_archer,
	o_skeleton_mage,
	o_skeleton_healer,
	o_zombie,
	o_mawling,
	o_demon_wizard,
	o_pitling,
	o_succubus,
	o_balgor
];
y_sort_enabled = true;
image_speed = 0;
image_xscale = 0.65;
image_yscale = 0.65;
