// Handle damage sources that modify HP directly.
if (!global.pause && hp <= 0) house_death_process();

if (!global.pause && hp > 0) house_guards_spawn();
