/// @description Cancels unpaid destination selection and consumes the closing input; controller context.
function faction_summon_cancel()
{
	faction_summon_selected = -1;
	faction_summon_release_pending = true;
	global.focus_window = FOCUS_WINDOW.SUMMON;
}
