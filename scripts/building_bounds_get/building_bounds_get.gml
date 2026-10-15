/// @description Returns the full placement footprint, including sprite-less Warehouses.
function building_bounds_get(_b, _x, _y)
{
	if (_b.placement_size > 0)
	{
		var _half = _b.placement_size * 0.5;
		return {left: _x - _half, right: _x + _half, top: _y - _half, bottom: _y + _half};
	}
	if (_b.sprite_index == -1) return {left:_x-100,top:_y-100,right:_x+100,bottom:_y+100};
	var _s = _b.sprite_index;
	var _l = _x-sprite_get_xoffset(_s)*_b.image_xscale;
	var _t = _y-sprite_get_yoffset(_s)*_b.image_yscale;
	return {left:_l,top:_t,right:_l+sprite_get_width(_s)*_b.image_xscale,bottom:_t+sprite_get_height(_s)*_b.image_yscale};
}
