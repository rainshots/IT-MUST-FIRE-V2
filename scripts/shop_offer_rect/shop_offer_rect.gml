/// @description Returns a bottom-bar purchase cell; index -1 is the Refresh button.
function shop_offer_rect(_i)
{
	var _scale=min(1,display_get_gui_width()/1100,display_get_gui_height()/600);
	var _width=180*_scale;
	var _gap=16*_scale;
	var _refresh=112.5*_scale;
	var _total=_refresh+BALANCE_SHOP_OFFER_COUNT*(_width+_gap);
	var _left=(display_get_gui_width()-_total)*0.5;
	return {x:_i<0 ? _left : _left+_refresh+_gap+_i*(_width+_gap),
		y:display_get_gui_height()-110*_scale,width:_i<0 ? _refresh : _width,height:90*_scale,scale:_scale};
}
