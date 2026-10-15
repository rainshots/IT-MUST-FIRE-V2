/// @description Cancels an unpaid purchase or restores a moved building without refund transactions.
function shop_cancel()
{
	if(instance_exists(shop_preview))
	{
		if(shop_cost>0) instance_destroy(shop_preview);
		else { shop_preview.x=cargo_drag_start_x;shop_preview.y=cargo_drag_start_y;shop_preview.is_being_dragged=false; }
	}
	shop_purchase_index = -1;
	shop_preview=noone;shop_open=false;shop_cost=0;global.pause=shop_previous_pause;
}
