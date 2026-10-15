/// @description Removes every assigned cultist before relocation or merging.
function building_workers_release(_building)
{
	var _workers = _building.worker_cultists;
	for(var _i=0;_i<array_length(_workers);++_i) if(instance_exists(_workers[_i])) worker_release(_workers[_i]);
}
