// Included inside the VM fixture's road-test phase; _controller and _assert come from that fixture.
var _reset_road = function(_controller)
{
	_controller.tactical_mode = true;
	_controller.phase = BATTLE_PHASE.BATTLE;
	_controller.paused = false;
	_controller.armies = [];
	_controller.shots = [];
	_controller.elapsed_seconds = 0;
	conquest_road_level_prepare(_controller);
	_controller.ai_timer = 10000;
};
var _advance = function(_controller, _seconds)
{
	var _frames = round(_seconds * 60);
	for (var _frame = 0; _frame < _frames; ++_frame) conquest_simulation_update(_controller, 1 / 60);
};
_reset_road(_controller);
_assert(array_length(conquest_path_get(_controller, 0, 4, CONQUEST_OWNER.PLAYER)) == 0, "Road order bypassed neutral junction");
var _path = conquest_path_get(_controller, 0, 2, CONQUEST_OWNER.PLAYER);
_assert(array_length(_path) == 3 && _path[1] == 1, "Road failed to use friendly intermediate outpost");
_controller.nodes[5].owner = CONQUEST_OWNER.PLAYER;
_controller.nodes[6].owner = CONQUEST_OWNER.PLAYER;
_path = conquest_path_get(_controller, 1, 3, CONQUEST_OWNER.PLAYER);
_assert(array_length(_path) == 4 && _path[1] == 5 && _path[2] == 6, "Long flank not traversable");
var _flank_length = conquest_path_length_get(_controller, _path);
_controller.nodes[2].owner = CONQUEST_OWNER.PLAYER;
_path = conquest_path_get(_controller, 1, 3, CONQUEST_OWNER.PLAYER);
_assert(_path[1] == 2 && conquest_path_length_get(_controller, _path) < _flank_length, "Captured shortcut not preferred");
array_push(results, "PASS: friendly road traversal, blocked enemy rear, long flank and shorter captured crossing");

_reset_road(_controller);
_assert(conquest_route_set(_controller, 0, 1, CONQUEST_OWNER.PLAYER), "Supply route rejected");
_assert(!conquest_route_set(_controller, 1, 0, CONQUEST_OWNER.PLAYER), "Supply loop accepted");
conquest_routes_update(_controller, 0);
_assert(_controller.nodes[0].garrison == 15 && _controller.armies[0].count == 35, "Automatic wave did not preserve reserve");
_assert(conquest_order_send(_controller, 0, 1, 1, CONQUEST_OWNER.PLAYER) == 0, "Manual spam bypassed wave cooldown");
_controller.nodes[0].garrison = 30;
conquest_routes_update(_controller, 1);
_assert(array_length(_controller.armies) == 1, "Route bypassed its cooldown");
_controller.paused = true;
conquest_simulation_update(_controller, 10);
_assert(_controller.nodes[0].garrison == 30 && _controller.nodes[0].dispatch_remaining == 6, "Pause advanced a supply route");
_controller.paused = false;
_controller.nodes[0].dispatch_remaining = 0;
conquest_routes_update(_controller, 1);
_assert(array_length(_controller.armies) == 2 && _controller.nodes[0].garrison == 15, "Route did not send a second wave automatically");
array_push(results, "PASS: autonomous repeated waves, home reserves, cycle rejection, cooldown and pause");

_reset_road(_controller);
_assert(conquest_route_set(_controller, 0, 2, CONQUEST_OWNER.PLAYER), "Multi-hop route rejected");
_controller.nodes[1].owner = CONQUEST_OWNER.ENEMY;
conquest_routes_update(_controller, 0);
_assert(_controller.nodes[0].route_blocked && array_length(_controller.armies) == 0, "Cut route leaked a wave");
_controller.nodes[1].owner = CONQUEST_OWNER.PLAYER;
conquest_routes_update(_controller, 1);
_assert(!_controller.nodes[0].route_blocked && array_length(_controller.armies) == 1, "Reopened route did not resume");
_controller.nodes[0].route_target = -1;
_controller.nodes[1].owner = CONQUEST_OWNER.ENEMY;
_controller.nodes[1].garrison = 0;
_advance(_controller, 10);
_assert(_controller.nodes[1].owner == CONQUEST_OWNER.PLAYER && _controller.nodes[2].owner == CONQUEST_OWNER.NEUTRAL,
	"Marching column passed through a captured intermediate building");
_assert(_controller.nodes[1].route_target == -1, "Captured building inherited enemy orders");
array_push(results, "PASS: cut and restored supply lines, interception at changed waypoints, captured-order cleanup");

_reset_road(_controller);
_controller.nodes[1].garrison = 60;
_controller.nodes[2].owner = CONQUEST_OWNER.ENEMY;
_controller.nodes[2].kind = CONQUEST_BUILDING.SETTLEMENT;
_controller.nodes[2].garrison = 60;
conquest_order_send(_controller, 1, 2, 0.5, CONQUEST_OWNER.PLAYER);
conquest_order_send(_controller, 2, 1, 0.5, CONQUEST_OWNER.ENEMY);
_advance(_controller, 4);
_assert(array_length(_controller.armies) == 2 && _controller.armies[0].engaged && _controller.armies[1].engaged, "Opposing columns passed through each other");
_assert(_controller.armies[0].count < 30 && abs(_controller.armies[0].count - _controller.armies[1].count) < 0.001, "Road combat was not simultaneous");
_assert(abs(_controller.armies[0].x - _controller.armies[1].x) < 0.001, "Columns did not stop at their meeting point");
_assert(_controller.nodes[1].owner == CONQUEST_OWNER.PLAYER && _controller.nodes[2].owner == CONQUEST_OWNER.ENEMY, "Road fight captured an endpoint");
array_push(results, "PASS: opposing-column interception, simultaneous casualties and stopped movement");

var _road_outcomes = [];
for (var _packets = 1; _packets <= 2; ++_packets)
{
	_reset_road(_controller);
	_controller.nodes[1].garrison = 100;
	_controller.nodes[2].owner = CONQUEST_OWNER.ENEMY;
	_controller.nodes[2].garrison = 100;
	for (var _index = 0; _index < _packets; ++_index)
	{
		_controller.nodes[1].dispatch_remaining = 0;
		var _troops = 40 / _packets;
		conquest_order_send(_controller, 1, 2, (_troops + 0.000001) / floor(_controller.nodes[1].garrison), CONQUEST_OWNER.PLAYER);
	}
	conquest_order_send(_controller, 2, 1, 0.3, CONQUEST_OWNER.ENEMY);
	var _count = array_length(_controller.armies);
	for (var _index = 0; _index < _count; ++_index) _controller.armies[_index].progress = 0.5;
	conquest_road_armies_update(_controller, 0);
	conquest_road_clashes_update(_controller, 0.25);
	var _totals = [0, 0, 0];
	for (var _index = 0; _index < _count; ++_index)
	{
		var _army = _controller.armies[_index];
		_totals[_army.owner] += _army.count;
	}
	array_push(_road_outcomes, _totals);
}
_assert(abs(_road_outcomes[0][1] - _road_outcomes[1][1]) < 0.001
	&& abs(_road_outcomes[0][2] - _road_outcomes[1][2]) < 0.001, "Packet splitting changed road damage");
array_push(results, "PASS: road combat damage independent of packet count");

_reset_road(_controller);
_controller.nodes[5].owner = CONQUEST_OWNER.PLAYER;
_controller.nodes[5].garrison = 30;
_controller.nodes[6].garrison = 0;
conquest_order_send(_controller, 5, 6, 0.5, CONQUEST_OWNER.PLAYER);
_controller.armies[0].progress = 1;
conquest_road_sieges_update(_controller, 1);
_assert(_controller.nodes[6].owner == CONQUEST_OWNER.NEUTRAL && _controller.nodes[6].under_siege, "Empty building captured instantly");
conquest_road_sieges_update(_controller, 1);
_assert(_controller.nodes[6].owner == CONQUEST_OWNER.NEUTRAL, "Capture countdown ended early");
conquest_road_sieges_update(_controller, 1);
_assert(_controller.nodes[6].owner == CONQUEST_OWNER.PLAYER && _controller.nodes[6].garrison == 15, "Uncontested capture failed or lost attackers");
array_push(results, "PASS: sustained capture countdown and troop conservation at a captured building");

// The same total attacking force must do the same damage whether sent as one or two columns.
var _outcomes = [];
for (var _packets = 1; _packets <= 2; ++_packets)
{
	_reset_road(_controller);
	_controller.nodes[1].garrison = 100;
	for (var _index = 0; _index < _packets; ++_index)
	{
		_controller.nodes[1].dispatch_remaining = 0;
		var _troops = 40 / _packets;
		conquest_order_send(_controller, 1, 2, (_troops + 0.000001) / floor(_controller.nodes[1].garrison), CONQUEST_OWNER.PLAYER);
		_controller.armies[_index].progress = 1;
	}
	conquest_road_sieges_update(_controller, 0.25);
	var _remaining = 0;
	var _count = array_length(_controller.armies);
	for (var _index = 0; _index < _count; ++_index) _remaining += _controller.armies[_index].count;
	array_push(_outcomes, [_controller.nodes[2].garrison, _remaining]);
}
_assert(abs(_outcomes[0][0] - _outcomes[1][0]) < 0.001 && abs(_outcomes[0][1] - _outcomes[1][1]) < 0.001, "Splitting packets changed siege damage");
array_push(results, "PASS: siege damage independent of click / packet count");

// Two standing orders should capture the centre without any repeated input, against the real AI.
_reset_road(_controller);
_controller.ai_timer = BALANCE_CONQUEST_ROAD_AI_OPENING_SECONDS;
conquest_route_set(_controller, 0, 1, CONQUEST_OWNER.PLAYER);
conquest_route_set(_controller, 1, 2, CONQUEST_OWNER.PLAYER);
_advance(_controller, 45);
_assert(_controller.nodes[2].owner == CONQUEST_OWNER.PLAYER, "Two-order opening failed to establish a foothold against AI");
_assert(_controller.phase == BATTLE_PHASE.BATTLE, "Opening plan unexpectedly ended the whole mission");
array_push(results, "PASS: 45-second opening against real AI with only two standing orders");

// Finish with a real drawn encounter showing both supply arrows and a contested siege.
_reset_road(_controller);
_controller.nodes[1].garrison = 50;
_controller.nodes[3].garrison = 40;
conquest_route_set(_controller, 0, 1, CONQUEST_OWNER.PLAYER);
conquest_route_set(_controller, 1, 2, CONQUEST_OWNER.PLAYER);
conquest_order_send(_controller, 3, 2, 0.75, CONQUEST_OWNER.ENEMY);
_advance(_controller, 7);
