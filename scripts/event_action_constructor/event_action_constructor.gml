/// @description Creates one reusable action executed as part of a day event.
/// @param {String} _action_type Stable action identifier used by UI and save data.
/// @param {Function} _execute_callback Callback receiving the event and assigned cultists.
/// @param {Struct} _data Action-specific configuration.
function event_action_constructor(_action_type, _execute_callback, _data = {}) constructor
{
	action_type = _action_type;
	data = _data;
	execute_callback = _execute_callback;

	execute = function(_event, _assigned_cultists)
	{
		if (!is_callable(execute_callback))
		{
			return false;
		}

		return execute_callback(_event, _assigned_cultists, data);
	};
}
