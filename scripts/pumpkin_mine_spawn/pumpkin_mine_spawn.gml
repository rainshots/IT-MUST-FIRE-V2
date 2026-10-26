/// @description Plants one independent mine ahead of the patch, respecting the shared active-mine limit.
function pumpkin_mine_spawn(_patch)
{
	if (instance_number(o_patch_mine) >= BALANCE_PUMPKIN_MAX_MINES) return noone;
	var _area = pumpkin_mine_area_get(_patch);
	if (is_undefined(_area)) return noone;
	return instance_create_layer(random_range(_area.left, _area.right),
		random_range(_area.top, _area.bottom), "Instances", o_patch_mine);
}
