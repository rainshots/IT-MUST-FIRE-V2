// Generates an isolated verification project; never mutates production rooms or objects.
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const read = name => fs.readFileSync(path.join(root, name), 'utf8').replace(/^\uFEFF/, '');
const parse = name => JSON.parse(read(name).replace(/,\s*([}\]])/g, '$1'));
const write = (name, text) => {
  const target = path.join(root, name);
  fs.mkdirSync(path.dirname(target), {recursive:true});
  fs.writeFileSync(target, text);
};
const yy = (name, value) => write(name, JSON.stringify(value, null, 2) + '\n');
const project = parse('IT MUST FIRE PROROTYPE V2.yyp');
const objectPath = 'objects/o_conquest_runtime_test/o_conquest_runtime_test.yy';
const roomPath = 'Build/conquest_fixture/r_world_map/r_world_map.yy';
const object = parse('objects/o_world_map/o_world_map.yy');
object.name = object['%Name'] = 'o_conquest_runtime_test';
object.persistent = true;
object.eventList = object.eventList.filter(event => [0, 3].includes(event.eventType));
yy(objectPath, object);
write('objects/o_conquest_runtime_test/Step_0.gml', read('tests/conquest_runtime.gml'));
project.resources.push({id:{name:object.name, path:objectPath}});
const room = parse('rooms/r_world_map/r_world_map.yy');
const layer = room.layers.find(layer => layer.resourceType === 'GMRInstanceLayer');
const instance = structuredClone(layer.instances[0]);
instance.name = instance['%Name'] = 'inst_conquest_runtime_test';
instance.objectId = {name:object.name, path:objectPath};
layer.instances.push(instance);
room.instanceCreationOrder.push({name:instance.name, path:roomPath});
for (const entry of room.instanceCreationOrder) entry.path = roomPath;
// Returning to the map must not create a second persistent test controller.
write('objects/o_conquest_runtime_test/Create_0.gml',
  '// Persistent test progress across real room transitions.\nif (instance_number(o_conquest_runtime_test) > 1) { instance_destroy(); exit; }\ntest_phase = 0;\ntest_wait_frames = 3;\nresults = [];\n');
yy(roomPath, room);
project.resources.find(resource => resource.id.name === 'r_world_map').id.path = roomPath;
project.RoomOrderNodes.find(entry => entry.roomId.name === 'r_world_map').roomId.path = roomPath;
yy('conquest_runtime_verification.yyp', project);
console.log(path.join(root, 'conquest_runtime_verification.yyp'));
