#include <amxmodx>
#include <engine>
#include <fakemeta>

#define PLUGIN "Stats"
#define VERSION "1.0"
#define AUTHOR "MrShark45"

#define MAX_STRAFES 33

forward fwPlayerStrafe(id, strafes, sync, strafesSync[], strafeLen, frames, goodFrames, Float:gain, overlaps);

new g_iMainHudSync;
new g_iStrafeHudSync;

new bool:b_show_stats[33];

new g_iNativeStrafes[33];
new g_iNativeSync[33];

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /stats", "toggle_stats");

	g_iMainHudSync = CreateHudSyncObj();
	g_iStrafeHudSync = CreateHudSyncObj();
}

public plugin_natives(){
	register_library("strafe_stats");

	register_native("get_user_sync", "native_get_user_sync");

	register_native("get_user_strafes", "native_get_user_strafes");

	register_native("display_stats", "native_display_stats");

	register_native("get_bool_stats", "native_get_bool_stats");
	register_native("toggle_stats", "native_toggle_stats");
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

public client_putinserver(id){
	b_show_stats[id] = false;
}


public toggle_stats(id){
	b_show_stats[id] = !b_show_stats[id];
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
		ShowSyncHudMsg(id, g_iMainHudSync, "Strafes: %i^nSync: %i%^nGain: %.2f", strafes, sync, gain);
		
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

