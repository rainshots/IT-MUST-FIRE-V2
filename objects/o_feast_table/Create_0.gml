event_inherited();
worker_max=1;
worker_uses_speed_multiplier=false;
image_speed=0;
image_xscale=min(1,180/max(sprite_get_width(sprite_index),sprite_get_height(sprite_index)));
image_yscale=image_xscale;
worker_work_update=function(_seconds) { building_production_update(_seconds); };
building_label="Feast Table";
production_kind=0;heal_rate=BALANCE_KITCHEN_HEAL_PER_SECOND*1.5;
