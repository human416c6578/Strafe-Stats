#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cromchat2>
#include <strafe_globals>

#define PLUGIN "Stats"
#define VERSION "1.0"
#define AUTHOR "MrShark45"

#define MAX_STRAFES 33

forward fwPlayerStrafe(id, strafes, sync, strafesSync[], strafeLen, frames, goodFrames, Float:gain, overlaps);

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward( FM_PlayerPreThink, "fwdPreThink", 0 );

	register_clcmd("say /stats", "toggle_stats");
	register_clcmd("say /pre", "toggle_pre");
	register_clcmd("say /showpre", "toggle_pre");
	register_clcmd("say /prestrafe", "toggle_pre");

	g_iMainHudSync = CreateHudSyncObj();
	g_iStrafeHudSync = CreateHudSyncObj();
	
	//Chat prefix
	CC_SetPrefix("&x04[FWO]");
}

public plugin_natives(){
	register_library("strafe_stats");

	register_native("get_user_sync", "native_get_user_sync");

	register_native("get_user_strafes", "native_get_user_strafes");

	register_native("display_stats", "native_display_stats");

	register_native("get_bool_stats", "native_get_bool_stats");
	register_native("toggle_stats", "native_toggle_stats");

	register_native("get_bool_pre", "native_get_bool_pre");
	register_native("toggle_pre", "native_toggle_pre");
}

public native_get_user_sync(NumParams) {
	new id = get_param(1);

	new sync = g_iNativeSync[id];
	g_iNativeSync[id] = 0;
	
	return sync;
}

public native_get_user_strafes(NumParams) {
	new id = get_param(1);
	
	new strafes = g_iNativeStrafes[id];
	g_iNativeStrafes[id] = 0;
	
	return strafes;
}

public native_display_stats(NumParams) {
	
	new id = get_param(1);
	new strafes = get_param(2);
	new sync = get_param(3);

	for(new i = 1; i < 33; i++)
	{
		if(!is_user_connected(i) || is_user_alive(i) || !b_show_stats[i] ) continue;
		
		if( pev(i, pev_iuser2) == id )
		{
			set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, -1);
			ShowSyncHudMsg(i, g_iMainHudSync, "Strafes: %i^nSync: %i%%", strafes, sync);
		}
	}
}

public native_get_bool_stats(NumParams){
	new id = get_param(1);
	return b_show_stats[id];
}

public native_toggle_stats(NumParams){
	new id = get_param(1);
	toggle_stats(id);
}

public native_get_bool_pre(NumParams){
	new id = get_param(1);
	return b_pre_stats[id];
}

public native_toggle_pre(NumParams){
	new id = get_param(1);
	toggle_pre(id);
}

public client_putinserver(id){
	b_show_stats[id] = false; // Set to false so stats are OFF by default when the player joins. The player must enable it manually.
	b_pre_stats[id] = false; // Set to false so Prestrafe is OFF by default (bhop standard). To have it enabled by default (speedrun standard), change to true.
}

public toggle_stats(id){
	b_show_stats[id] = !b_show_stats[id];
	CC_SendMessage(id, "&x01Stats %s", b_show_stats[id] ? "&x06ON" : "&x07OFF");
}

public toggle_pre(id){
	b_pre_stats[id] = !b_pre_stats[id];
	CC_SendMessage(id, "&x01ShowPre %s", b_pre_stats[id] ? "&x06ON" : "&x07OFF");
}

public fwPlayerStrafe(id, strafes, sync, strafesSync[], strafeLen, frames, goodFrames, Float:gain, overlaps){
	if(is_user_bot(id)) return;
	g_iNativeStrafes[id] = strafes;
	g_iNativeSync[id] = sync;

	if(strafes < 1) return;
	
	if(b_show_stats[id]){
		/*
		static szStrafesInfo[32 * MAX_STRAFES], iLen;
		szStrafesInfo = "^0"; iLen = 0;
		for(new i = 0; i < strafeLen && i < MAX_STRAFES; i++)
		{
			iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i^n",
				i + 1, strafesSync[i]);
		}
	
		set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
		ShowSyncHudMsg(id, g_iStrafeHudSync, "%s", szStrafesInfo);

		set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
		ShowSyncHudMsg(id, g_iMainHudSync, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f", strafes, sync, goodFrames, frames, gain);
		client_print(id, print_console, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f^nGain/Strafe: %.2f^nGain/GoodFrames: %.2f", strafes, sync, goodFrames, frames, gain, gain/strafes, gain/goodFrames);
		*/
		
		set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
		ShowSyncHudMsg(id, g_iMainHudSync, "STRAFES: %i / SYNC: %i%%^nGAIN: +%.2f^n", strafes, sync, gain);
		//OLD DESIGN: ShowSyncHudMsg(id, g_iMainHudSync, "Strafes: %i^nSync: %i%^nGain: %.2f", strafes, sync, gain);
	}

	for(new i = 1; i < 33; i++)
	{
		if(!is_user_connected(i) || is_user_alive(i) || !b_show_stats[i] ) continue;
		
		if( pev(i, pev_iuser2) != id ) continue
		
		static szStrafesInfo[32 * MAX_STRAFES], iLen;
		szStrafesInfo = "^0"; iLen = 0;
		for(new j = 0; j < strafeLen && j < MAX_STRAFES; j++)
		{
			iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i^n",
				i + 1, strafesSync[j]);
		}

		set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
		ShowSyncHudMsg(i, g_iStrafeHudSync, "%s", szStrafesInfo);

		set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
		ShowSyncHudMsg(i, g_iMainHudSync, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f", strafes, sync, goodFrames, frames, gain);
		//client_print(i, print_console, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f^nGain/Strafe: %.2f^nGain/GoodFrames: %.2f", strafes, sync, goodFrames, frames, gain, gain/strafes, gain/goodFrames);
	}
}

public fwdPreThink(id) {
	if (!is_user_alive(id))
		return FMRES_IGNORED;

	static button;
	static flags;
	static oldbuttons;
	static Float:velocity[3];
	static Float:speed;

	button = pev(id, pev_button);
	flags = pev(id, pev_flags);
	oldbuttons = pev(id, pev_oldbuttons);
	
	if(button & IN_JUMP && !(oldbuttons & IN_JUMP)) 
	{
		if(flags & FL_ONGROUND) {
			pev(id, pev_velocity, velocity);
			velocity[2] = 0.0;
			speed = vector_length(velocity);

			if (b_pre_stats[id]) {
				set_hudmessage(0, 100, 255, -1.0, 0.700, 0, 0.0, 1.0, 0.1, 0.1, 4);
				ShowSyncHudMsg(id, g_iMainHudSync, "Prestrafe: %.2f", speed);
			}
		}
	}
	return FMRES_IGNORED;
}