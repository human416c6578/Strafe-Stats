#if defined _strafe_stats_included
	#endinput
#endif

#define _strafe_stats_included

native get_user_strafes(id);
native get_user_sync(id);
native display_stats(id, strafes, sync);

native get_bool_stats(id);
native toggle_stats(id);

native get_bool_pre(id);
native toggle_pre(id);