/// @description Returns the object resource used to match a Rite's Mastery progress and HP discount.
/// @param {Struct} event Building Rite or construction Job whose source is still present.
function day_event_mastery_building_object_get(_event)
{
	if (!is_struct(_event))
	{
		return noone;
	}

	// All construction sites share one Mastery, including Cursed Points and Trap Points.
	if (variable_struct_exists(_event, "construction_site"))
	{
		return instance_exists(_event.construction_site) ? o_building_slot : noone;
	}

	// Ordinary Rites keep their existing building-type eligibility, including the Blood Bath exclusion.
	var _source_building = day_event_mastery_source_building_get(_event);
	return instance_exists(_source_building) ? _source_building.object_index : noone;
}
