/// @description Owns bottom-bar purchasing and placement input, and right-click building relocation.
function shop_input_update()
{
	if(fight_state!=FIGHT_STATE.ACTIVE || !instance_exists(o_camera_controller)) return false;
	var _mx=device_mouse_x_to_gui(0);var _my=device_mouse_y_to_gui(0);
	var _camera=o_camera_controller.camera_id;
	var _x=camera_get_view_x(_camera)+_mx*camera_get_view_width(_camera)/display_get_gui_width();
	var _y=camera_get_view_y(_camera)+_my*camera_get_view_height(_camera)/display_get_gui_height();
	if(instance_exists(shop_preview))
	{
		if(keyboard_check_pressed(vk_escape) || (!shop_wait_release && mouse_check_button_pressed(mb_right))) { shop_cancel();return true; }
		if(instance_exists(shop_preview)) { var _snap = building_grid_snap(shop_preview, _x, _y); shop_preview.x=_snap.x;shop_preview.y=_snap.y; }
		if(shop_wait_release)
		{
			if(!mouse_check_button(mb_left) && !mouse_check_button(mb_right)) shop_wait_release=false;
			return true;
		}
		// Bottom-bar clicks never place a preview into the world behind the UI.
		var _bar=shop_offer_rect(-1);
		if (mouse_check_button_pressed(mb_left))
		{
			if (_my >= _bar.y) shop_sell();
			else shop_place(_x, _y);
		}
		return true;
	}
	if(cannon_aiming || instance_exists(cargo_dragged) || instance_exists(worker_dragged) || global.focus_window!=FOCUS_WINDOW.NOONE) return false;
	for(var _i=-1;_i<array_length(shop_options);++_i)
	{
		var _button=shop_offer_rect(_i);
		if(point_in_rectangle(_mx,_my,_button.x,_button.y,_button.x+_button.width,_button.y+_button.height))
		{
			if(mouse_check_button_pressed(mb_left))
			{
				if(_i<0) shop_refresh(); else shop_select(_i);
			}
			// Own the UI area so clicks cannot manipulate buildings underneath.
			return mouse_check_button(mb_left) || mouse_check_button(mb_right);
		}
	}
	if(!global.pause && mouse_check_button_pressed(mb_right))
	{
		var _building=noone;
		with(o_worker_building_parent)
		{
			if (!building_can_move) continue;
			var _r=building_bounds_get(id,x,y);
			if(point_in_rectangle(_x,_y,_r.left,_r.top,_r.right,_r.bottom)) _building=id;
		}
		if(instance_exists(_building))
		{
			building_smoke_create(_building);
			building_workers_release(_building);
			cargo_drag_start_x=_building.x;cargo_drag_start_y=_building.y;
			shop_purchase_index = -1;
			shop_preview=_building;shop_cost=0;_building.is_being_dragged=true;
			shop_previous_pause=global.pause;global.pause=true;shop_wait_release=true;
			return true;
		}
	}
	return false;
}
