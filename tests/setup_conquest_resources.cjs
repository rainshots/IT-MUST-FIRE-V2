// Registers conquest resources without rewriting unrelated GameMaker metadata.
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const read = name => fs.readFileSync(path.join(root, name), 'utf8').replace(/^\uFEFF/, '');
const parse = name => JSON.parse(read(name).replace(/,\s*([}\]])/g, '$1'));
const write = (name, value) => {
  const target = path.join(root, name);
  fs.mkdirSync(path.dirname(target), {recursive:true});
  fs.writeFileSync(target, JSON.stringify(value, null, 2) + '\n');
};
const folder = {name:'conquest', path:'folders/conquest.yy'};
const names = fs.readdirSync(path.join(root, 'scripts')).filter(name => name.startsWith('conquest_')).sort();
const resources = [];
for (const name of names) {
  const resourcePath = `scripts/${name}/${name}.yy`;
  write(resourcePath, {$GMScript:'v1', '%Name':name, isCompatibility:false, isDnD:false,
    name, parent:folder, resourceType:'GMScript', resourceVersion:'2.0'});
  resources.push({name, path:resourcePath});
}
const object = parse('objects/o_world_map/o_world_map.yy');
object.name = object['%Name'] = 'o_conquest';
object.parent = folder;
object.persistent = false;
object.eventList = object.eventList.filter(event => event.eventType !== 7);
write('objects/o_conquest/o_conquest.yy', object);
resources.push({name:object.name, path:'objects/o_conquest/o_conquest.yy'});
const room = parse('rooms/r_world_map/r_world_map.yy');
room.name = room['%Name'] = 'r_conquest';
room.parent = folder;
const layer = room.layers.find(layer => layer.resourceType === 'GMRInstanceLayer');
const instance = structuredClone(layer.instances[0]);
instance.name = instance['%Name'] = 'inst_conquest_controller';
instance.objectId = {name:object.name, path:'objects/o_conquest/o_conquest.yy'};
instance.x = instance.y = 0;
instance.properties = [];
delete instance.creationCodeFile;
layer.instances = [instance];
layer.name = layer['%Name'] = 'instances';
layer.depth = 0;
layer.effectEnabled = false;
layer.effectType = null;
room.layers = [layer];
room.instanceCreationOrder = [{name:instance.name, path:'rooms/r_conquest/r_conquest.yy'}];
room.creationCodeFile = '';
write('rooms/r_conquest/r_conquest.yy', room);
resources.push({name:room.name, path:'rooms/r_conquest/r_conquest.yy'});
const projectPath = path.join(root, 'IT MUST FIRE PROROTYPE V2.yyp');
let project = fs.readFileSync(projectPath, 'utf8');
if (!project.includes('folders/conquest.yy')) {
  project = project.replace('"Folders":[', '"Folders":[\n    {"$GMFolder":"","%Name":"conquest","folderPath":"folders/conquest.yy","name":"conquest","resourceType":"GMFolder","resourceVersion":"2.0",},');
}
const additions = resources.filter(resource => !project.includes(`"name":"${resource.name}"`));
if (additions.length > 0) {
  project = project.replace('"resources":[', '"resources":[\n' + additions.map(id => '    ' + JSON.stringify({id}) + ',').join('\n'));
}
if (!project.includes('"roomId":{"name":"r_conquest"')) {
  project = project.replace('"RoomOrderNodes":[', '"RoomOrderNodes":[\n    {"roomId":{"name":"r_conquest","path":"rooms/r_conquest/r_conquest.yy",},},');
  // Keep the campaign as the first room.
  const entry = '    {"roomId":{"name":"r_world_map","path":"rooms/r_world_map/r_world_map.yy",},},';
  project = project.replace(entry, '').replace('"RoomOrderNodes":[', '"RoomOrderNodes":[\n' + entry);
}
fs.writeFileSync(projectPath, project);
console.log(`Registered ${resources.length} conquest resources.`);
