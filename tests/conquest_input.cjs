// Exercise the production input coordinator with deterministic GameMaker input stubs.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const input = {x:0, y:0, pressed:false, released:false, right:false, shift:false, keys:new Set()};
const c = {
  BATTLE_PHASE:{BATTLE:1,VICTORY:2,DEFEAT:3}, CONQUEST_OWNER:{NEUTRAL:0,PLAYER:1,ENEMY:2},
  BALANCE_CONQUEST_HIT_RADIUS:75, mb_left:1, mb_right:2, vk_space:32, vk_escape:27, vk_shift:16, r_world_map:'map',
  BALANCE_CONQUEST_ROUTE_RESERVE_STEP:5, BALANCE_CONQUEST_ROUTE_RESERVE_MAX:60,
  min:Math.min,max:Math.max,string:String,ord:s=>s.charCodeAt(0),
  clamp:(v,lo,hi)=>Math.min(hi,Math.max(lo,v)),
  array_length:a=>a.length,array_contains:(a,v)=>a.includes(v),array_push:(a,v)=>a.push(v),array_delete:(a,i,n)=>a.splice(i,n),
  instance_exists:instance=>instance === controller,
  point_distance:(a,b,x,y)=>Math.hypot(x-a,y-b),
  point_in_rectangle:(x,y,a,b,r,d)=>x>=a&&x<=r&&y>=b&&y<=d,
  device_mouse_x_to_gui:()=>input.x,device_mouse_y_to_gui:()=>input.y,
  mouse_check_button_pressed:b=>b===1?input.pressed:input.right,
  mouse_check_button_released:()=>input.released,
  keyboard_check_pressed:k=>input.keys.has(k),keyboard_check:()=>input.shift,
  room_goto:r=>{c.nextRoom=r;},room_restart:()=>{c.restarted=true;},
  conquest_order_send:(controller,source,target,fraction,owner)=>{
    c.orders.push({source,target,fraction,owner}); return source===target?0:10;
  },
  conquest_upgrade_start:(controller,index,owner)=>{c.upgrades.push({index,owner});return true;},
  conquest_route_set:(controller,source,target,owner)=>{
    if (source===target) return false;
    controller.nodes[source].route_target=target;
    c.routes.push({source,target,owner}); return true;
  },
  routes:[],
  orders:[],upgrades:[],
};
vm.createContext(c);
for (const name of ['conquest_node_at_position','conquest_route_input_update','conquest_selection_send','conquest_input_update']) {
  vm.runInContext(fs.readFileSync(path.join(root,`scripts/${name}/${name}.gml`),'utf8'),c,{filename:name});
}
const controller = {
  nodes:[{x:240,y:490,owner:1},{x:490,y:280,owner:1},{x:770,y:475,owner:0},{x:1680,y:490,owner:2}],
  selected_nodes:[],hovered_node:-1,pressed_node:-1,pointer_down:false,box_selecting:false,
  send_fraction:.5,phase:1,paused:false,field_top:90,field_bottom:896,
};
function frame(values={}) {
  Object.assign(input,{pressed:false,released:false,right:false,shift:false,keys:new Set()},values);
  c.conquest_input_update(controller);
}
function click(x,y,shift=false) {frame({x,y,pressed:true,shift});frame({x,y,released:true,shift});}
click(240,465);
assert.deepEqual([...controller.selected_nodes],[0]);
frame({x:240,y:465,pressed:true});
frame({x:770,y:450,released:true});
assert.equal(c.orders.length,1,'Drag should dispatch exactly once');
assert.equal(c.orders[0].target,2);
click(490,255,true);
assert.deepEqual([...controller.selected_nodes],[0,1],'Shift should preserve group');
frame({x:1680,y:465,right:true});
assert.equal(c.orders.length,3,'RMB sends every selected building');
frame({keys:new Set([52])});
assert.equal(controller.send_fraction,1);
click(830,980);
assert.equal(controller.send_fraction,.5,'Fraction UI and hotkeys must agree');
const orderCount = c.orders.length;
frame({x:240,y:465,pressed:true});
frame({x:790,y:980,released:true});
assert.equal(c.orders.length,orderCount,'Release over HUD must cancel dispatch');
frame({x:120,y:180,pressed:true});
frame({x:580,y:550,released:true});
assert.deepEqual([...controller.selected_nodes],[0,1],'Box selection should include both allies');
frame({keys:new Set([85])});
assert.equal(c.upgrades.length,0,'Multi-selection must not upgrade a random building');
click(240,465);
frame({keys:new Set([85])});
assert.equal(c.upgrades.length,1);
frame({keys:new Set([32])});
assert.equal(controller.paused,true);
frame({x:770,y:450,right:true});
assert.equal(c.orders.length,orderCount,'Pause must block orders');
frame({keys:new Set([32])});
assert.equal(controller.paused,false);
controller.nodes[0].owner=2;
frame();
assert.equal(controller.selected_nodes.length,0,'Captured sources must leave selection');
frame({keys:new Set([65])});
assert.deepEqual([...controller.selected_nodes],[1],'Select-all must exclude enemy buildings');
click(770,450);
assert.equal(c.orders.at(-1).source,1,'Click target sends current group');
controller.phase=2;
frame({x:770,y:450,right:true});
assert.equal(c.orders.length,orderCount+1,'Finished battle must block orders');
click(800,675);
assert.equal(c.nextRoom,'map');
frame({keys:new Set([82])});
assert.equal(c.restarted,true);
console.log('PASS: selection, drag, group orders, fractions, HUD cancellation, box selection, upgrades, pause, captured sources, results and navigation');

// Tactical default orders establish standing routes; one-wave mode deliberately cancels them.
controller.phase=1; controller.paused=false; controller.tactical_mode=true; controller.auto_orders=true;
controller.nodes[0].owner=1;
for (const node of controller.nodes) Object.assign(node,{reserve:15,route_target:-1,route_path:[],route_blocked:false});
controller.selected_nodes=[0];
click(770,450);
assert.equal(c.routes.length,1,'Default tactical click must establish one route');
assert.equal(controller.nodes[0].route_target,2);
frame({keys:new Set([67])});
assert.equal(controller.nodes[0].reserve,20,'C raises the home reserve');
click(740,980);
assert.equal(controller.nodes[0].reserve,15,'Reserve button matches hotkey');
const savedFraction=controller.send_fraction;
frame({keys:new Set([52])});
assert.equal(controller.send_fraction,savedFraction,'Auto mode must not expose hidden fraction input');
click(1200,980);
assert.equal(controller.auto_orders,false,'Mode button switches to a single wave');
frame({keys:new Set([52])});
assert.equal(controller.send_fraction,1);
frame({x:770,y:450,right:true});
assert.equal(controller.nodes[0].route_target,-1,'Single-wave order cancels source route');
frame({keys:new Set([84])});
assert.equal(controller.auto_orders,true);
click(770,450);
frame({keys:new Set([88])});
assert.equal(controller.nodes[0].route_target,-1,'X stops future automatic waves');
assert.equal(controller.nodes[0].route_path.length,0);
console.log('PASS: tactical route orders, reserve buttons/hotkeys, mode switch, hidden-control isolation and cancellation');
