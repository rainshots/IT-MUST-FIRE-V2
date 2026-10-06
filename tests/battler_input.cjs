// Exercise the production input coordinator with deterministic engine input and camera stubs.
const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const input = {x:0,y:0,left:false,right:false,leftDown:false,rightDown:false,released:false,keys:new Set()};
const BATTLE_PHASE = {PREPARATION:0,BATTLE:1,VICTORY:2,DEFEAT:3};
const FOCUS_WINDOW = {NOONE:0,TARGET_SELECTION:1};
const c = {
  global:{pause:false,focus_window:0,dragged_squad:null,squads:[],gameplay_time_scale:1,day_phase:0,
    cannon_projectile_queue:[1,1,1],cannon_projectile_payload_queue:[null,null,null],cannon_selected_projectile_index:0,
    cannon_projectile_cheat_enabled:false,cannon_target_version:0},
  noone:null,BATTLE_PHASE,FOCUS_WINDOW,DAY_PHASE:{DAY:0,NIGHT:1},
  SQUAD_ORDER:{MOVE:1,MOVE_AND_ATTACK:2},PROJECTILE_TYPE:{DAMAGE:0,CORRUPTION:1,BOMB:7,HEAL:6,CULTIST:4,BUILDING_SHELL:9},
  o_units_parent:'units',o_hud:'hud',o_camera_controller:'camera',r_world_map:'map',
  mb_left:1,mb_right:2,vk_escape:27,vk_space:32,vk_enter:13,room_speed:60,
  BALANCE_BATTLE_ROSTER_LIMIT:6,BALANCE_BATTLE_DEPLOYMENT_LIMIT:4,BALANCE_BATTLE_RESULT_CHECK_SECONDS:.2,
  BALANCE_SQUAD_MARKER_DRAG_TARGET_OFFSET_Y:100,BALANCE_PROJECTILE_HELLCOW_AIM_MIN_DRAG:10,
  BALANCE_PROJECTILE_HELLCOW_CHARGE_DISTANCE:1000,
  is_struct:x=>!!x && typeof x==='object', array_length:x=>x.length, string:String,
  min:Math.min,max:Math.max,floor:Math.floor,clamp:(x,a,b)=>Math.max(a,Math.min(b,x)),ord:x=>x.charCodeAt(0),
  variable_global_exists:key=>Object.hasOwn(c.global,key),variable_instance_exists:(x,k)=>Object.hasOwn(x,k),
  keyboard_check_pressed:k=>input.keys.has(k),keyboard_check:()=>false,
  mouse_check_button_pressed:b=>b===1?input.left:input.right,
  mouse_check_button_released:()=>input.released,mouse_check_button:b=>b===1?input.leftDown:input.rightDown,
  device_mouse_x_to_gui:()=>input.x,device_mouse_y_to_gui:()=>input.y,
  display_get_gui_width:()=>1366,display_get_gui_height:()=>768,
  camera_get_view_x:()=>0,camera_get_view_y:()=>384,camera_get_view_width:()=>4098,camera_get_view_height:()=>2304,
  view_camera:[0],ui_mouse_is_inside_rect:(x,y,a,b,w,h)=>x>=a&&x<=a+w&&y>=b&&y<=b+h,
  battle_preparation_squad_at_world:()=>null,squad_marker_find_at_position:()=>null,
  battle_formation_positions_get:(s,x,y)=>[{x,y}],battle_deployment_is_valid:()=>true,
  squad_combat_guides_update:()=>{},squad_night_markers_update:()=>{},
  battle_result_update:()=>{},room_goto:r=>c.nextRoom=r,
  squad_living_unit_count_get:()=>10,squad_drag_end:()=>{c.global.dragged_squad=null;},
  squad_drag_update:()=>{},squad_drag_begin:s=>{c.global.dragged_squad=s;},
  battle_start:controller=>{controller.battle_phase=BATTLE_PHASE.BATTLE;},
  battle_squad_recall:(controller,s)=>{s.properties.battle_deployed=false;controller.battle_deployed_count--;},
  battle_squad_deploy:(controller,s)=>{s.properties.battle_deployed=true;controller.battle_deployed_count++;return true;},
};
const controller={battle_mode_active:true,battle_phase:0,battle_dragged_squad:null,battle_preview_positions:[],
  battle_deployed_count:0,battle_result_check_seconds:1,battle_elapsed_seconds:0,battle_feedback:'',
  gameplay_time_scale_update(){},night_fast_forward_set(v){this.night_fast_forward_active=v;},
  camera_view_width:1366,camera_view_height:768,hellcow_aim_is_dragging:false,hellcow_aim_drag_distance:0,
  target_selection_projectile_type:1,target_selection_radius:240,
  cannon_projectile_type_can_fire_in_current_phase:()=>true,cannon_is_ready_to_fire:()=>true,
  projectile_target_selection_radius_get:()=>240,cannon_projectile_type_can_stack_in_hud:()=>true,
  cannon_projectile_type_is_reusable:()=>false,taint_compost_target_touches_corruption:()=>true,
  cannon_projectile_display_slots_get:()=>c.global.cannon_projectile_queue.length ?
    [{projectile_type:1,queue_index:0,consume_queue_index:0,count:c.global.cannon_projectile_queue.length}] : []};
controller.id=controller;
const hud={projectile_slot_at_gui_position:()=>null};
const camera={camera_id:0};
c.instance_exists=x=>x===controller||x===hud||x===camera||x==='hud'||x==='camera';
c.instance_find=type=>type==='hud'?hud:camera;
vm.createContext(c);
for(const name of ['battle_ui_layout_get','battle_shell_slot_at_gui','battle_mouse_world_get','cannon_target_input_update','battle_controller_update']){
  let source=fs.readFileSync(path.join(root,`scripts/${name}/${name}.gml`),'utf8');
  source=source.replace(/\twith \(o_units_parent\)\s*\{\s*depth = -floor\(y\);\s*\}/, '');
  vm.runInContext(source,c,{filename:name});
}
const squad={name:'Skeletons I',properties:{battle_deployed:false}};
c.global.squads=[squad];
function frame(values={}){Object.assign(input,{left:false,right:false,released:false,keys:new Set()},values);c.battle_controller_update(controller);}
frame({x:70,y:700,left:true,leftDown:true});
assert.equal(controller.battle_dragged_squad,squad,'Roster press must pick up squad');
frame({x:275,y:288,leftDown:true});
assert.equal(controller.battle_preview_valid,true,'World drag must show valid preview');
frame({x:275,y:288,leftDown:false,released:true});
assert.equal(controller.battle_deployed_count,1,'Release must deploy exactly once');
assert.equal(controller.battle_dragged_squad,null);
frame({x:70,y:700,right:true});
assert.equal(controller.battle_deployed_count,0,'RMB must recall');
frame({x:765,y:700,left:true});
assert.equal(c.global.focus_window,FOCUS_WINDOW.TARGET_SELECTION,'Shell click must enter aiming');
assert.equal(c.global.cannon_target_version,0,'Toolbar must not fire into the world');
frame({x:400,y:300,left:true});
assert.equal(c.global.cannon_target_version,1,'World click must confirm the target');
assert.equal(c.global.cannon_target_x,1200);
assert.equal(c.global.cannon_target_y,1284);
frame({keys:new Set([49])});
assert.equal(c.global.focus_window,FOCUS_WINDOW.TARGET_SELECTION,'Digit hotkey must enter aiming');
frame({x:1200,y:700,left:true});
assert.equal(controller.battle_phase,BATTLE_PHASE.BATTLE,'Start button must work during aiming');
c.global.focus_window=0;
frame({keys:new Set([32])});
const time=controller.battle_elapsed_seconds;
frame();
assert.equal(controller.battle_elapsed_seconds,time,'Pause must freeze battle clock');
frame({keys:new Set([32])});
assert.equal(controller.battle_elapsed_seconds,time+1/60);
c.room_speed=30;
frame();
assert.equal(controller.battle_elapsed_seconds,time+1/60+1/30,'Clock must use current room speed');
console.log('PASS: roster dragging, recall, shell click/hotkey, GUI exclusion, start while aiming, pause, room-speed changes');
