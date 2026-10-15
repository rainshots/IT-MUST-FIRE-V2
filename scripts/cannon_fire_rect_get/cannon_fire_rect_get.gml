/// @description Returns the manual fire button centered just above the Shop buttons.
function cannon_fire_rect_get()
{
	var _shop = shop_offer_rect(0);
	var _width = 180 * _shop.scale;
	var _height = 64 * _shop.scale;
	var _gap = BALANCE_FIRE_SHOP_GAP * _shop.scale;
	return {x: (display_get_gui_width() - _width) * 0.5, y: _shop.y - _height - _gap, width: _width, height: _height};
}
