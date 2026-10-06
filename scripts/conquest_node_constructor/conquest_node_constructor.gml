/// @description Creates one capturable building; coordinates use the 1920x1080 battle canvas.
function conquest_node_constructor(_x, _y, _kind, _owner, _garrison, _level = 1) constructor
{
	x = _x;
	y = _y;
	kind = _kind;
	owner = _owner;
	garrison = _garrison;
	level = _level;
	upgrade_remaining = 0;
	shot_timer = 0;
	capture_flash = 0;
	label = ""; // Tactical landmark name drawn above the building.
	route_target = -1; // Persistent destination; ownership loss clears the order.
	route_path = []; // Cached road segments for drawing, retained while a route is blocked.
	route_blocked = false;
	reserve = BALANCE_CONQUEST_ROUTE_RESERVE;
	dispatch_remaining = 0; // Shared cooldown for manual orders and automatic waves.
	under_siege = false; // Recruitment and outgoing orders stop during a siege.
	capture_remaining = BALANCE_CONQUEST_ROAD_CAPTURE_SECONDS;
	siege_owner = CONQUEST_OWNER.NEUTRAL;
}
