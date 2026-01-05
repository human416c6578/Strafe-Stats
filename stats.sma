#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cromchat2>
#include <strafe_globals>
#include <strafe_menu>

#define PLUGIN "Stats"
#define VERSION "1.0"
#define AUTHOR "MrShark45 & ftl~"

#define MAX_STRAFES 33

forward fwPlayerStrafe(id, strafes, sync, strafesSync[], strafeLen, frames, goodFrames, Float:gain, overlaps);

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward( FM_PlayerPreThink, "fwdPreThink", 0 );

	register_clcmd("say /stats", "StatsMenu");
	register_clcmd("say /statsmenu", "SettingsMenu");

	register_clcmd("say /pre", "toggle_pre");
	register_clcmd("say /showpre", "toggle_pre");
	register_clcmd("say /prestrafe", "toggle_pre");

	g_iMainHudSync = CreateHudSyncObj();
	g_iStrafeHudSync = CreateHudSyncObj();
	
	//Chat prefix
	//CC_SetPrefix("&x04[FWO]");
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
		if(!is_user_connected(i) || is_user_alive(i) || !g_bShowStats[i] ) continue;
		
		if( pev(i, pev_iuser2) == id )
		{
			set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, -1);
			ShowSyncHudMsg(i, g_iMainHudSync, "Strafes: %i^nSync: %i%%", strafes, sync);
		}
	}
}

public native_get_bool_stats(NumParams){
	new id = get_param(1);
	return g_bShowStats[id];
}

public native_toggle_stats(NumParams){
	new id = get_param(1);
	toggle_stats(id);
}

public native_get_bool_pre(NumParams){
	new id = get_param(1);
	return g_bShowPre[id];
}

public native_toggle_pre(NumParams){
	new id = get_param(1);
	toggle_pre(id);
}

public client_putinserver(id){ 
	g_bShowStats[id] = false; // Set to false so stats are OFF by default when the player joins. The player must enable it manually.
	g_bShowPre[id] = false; // Set to false so Prestrafe is OFF by default (bhop standard). To have it enabled by default (speedrun standard), change to true.
	g_bShowStrafes[id] = true;
	g_bShowSync[id] = true;
	g_bShowGain[id] = true;
	g_bShowStrafeList[id] = true;
	g_bShowFrames[id] = true;
	g_bShowConsole[id] = true;
}

public toggle_stats(id){
	g_bShowStats[id] = !g_bShowStats[id];
	//CC_SendMessage(id, "&x01Stats %s", g_bShowStats[id] ? "&x06ON" : "&x07OFF");
}

public toggle_pre(id){
	g_bShowPre[id] = !g_bShowPre[id];
	//CC_SendMessage(id, "&x01ShowPre %s", g_bShowPre[id] ? "&x06ON" : "&x07OFF");
}

public fwPlayerStrafe(id, strafes, sync, strafesSync[], strafeLen, frames, goodFrames, Float:gain, overlaps){
	if(is_user_bot(id)) return;
	g_iNativeStrafes[id] = strafes;
	g_iNativeSync[id] = sync;

	if(strafes < 1) return;

	// List of all players who will receive the HUD: player + spectators    
	new Array:targets = ArrayCreate();
	
	if (g_bShowStats[id])
		ArrayPushCell(targets, id);

	// Add all spectators
	for (new i = 1; i < 33; i++)
	{
		if (!is_user_connected(i) || is_user_alive(i) || !g_bShowStats[i]) continue;
		
		if (pev(i, pev_iuser2) == id)
			ArrayPushCell(targets, i);
	}

	// Process all targets uniquely
	for (new t = 0; t < ArraySize(targets); t++)
	{
		new target = ArrayGetCell(targets, t);

		// Side list
		if(g_bShowStrafeList[target])
		{
			static szStrafesInfo[32 * MAX_STRAFES], iLen;
			szStrafesInfo[0] = 0; iLen = 0;
			for(new j = 0; j < strafeLen && j < MAX_STRAFES; j++)
				iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i^n", j + 1, strafesSync[j]);
			
			set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
			ShowSyncHudMsg(target, g_iStrafeHudSync, "%s", szStrafesInfo);
		}

		// Customized center stats for each target
		static szMain[256]; szMain[0] = 0;
		
		if(g_bShowStrafes[target] && g_bShowSync[target] && g_bShowGain[target] && g_bShowFrames[target]){
			// Original format when everything is ON
			formatex(szMain, charsmax(szMain), "Strafes: %i / Sync: %i%%^nFrames: %d/%d^nGain: %.2f", strafes, sync, goodFrames, frames, gain);
		}
		else{
			// Customized by removing what's OFF
			new parts = 0;
			
			if(g_bShowStrafes[target]){
				parts++;
				formatex(szMain, charsmax(szMain), "Strafes: %i", strafes);
			}
			
			if(g_bShowSync[target])
			{
				if(parts) add(szMain, charsmax(szMain), " / ");
				add(szMain, charsmax(szMain), "Sync: ");
				format(szMain, charsmax(szMain), "%s%i%%", szMain, sync);
				parts++;
			}
			
			if(g_bShowFrames[target])
			{
				if(parts) add(szMain, charsmax(szMain), "^n");
				format(szMain, charsmax(szMain), "%sFrames: %d/%d", szMain, goodFrames, frames);
				parts++;
			}
			
			if(g_bShowGain[target])
			{
				if(parts) add(szMain, charsmax(szMain), "^n");
				format(szMain, charsmax(szMain), "%sGain: %.2f", szMain, gain);
			}
		}

		if(szMain[0]){
			set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
			ShowSyncHudMsg(target, g_iMainHudSync, "%s", szMain);
		}

		// Console info
		if (g_bShowConsole[target])
		{
			client_print(target, print_console, "--- Strafe #%i - Sync: %i%% ---", strafes, sync);
			client_print(target, print_console, "Strafes: %i^nSync: %i%%^nFrames: %d/%d^nGain: %.2f^nGain/Strafe: %.2f^nGain/GoodFrames: %.2f", strafes, sync, goodFrames, frames, gain, gain/strafes, gain/goodFrames);
			client_print(target, print_console, "----------------------------");
		}
	}

	ArrayDestroy(targets);
}

public fwdPreThink(id) {
	if (!is_user_alive(id)) return FMRES_IGNORED;

	static button, flags, oldbuttons;
	static Float:velocity[3], Float:speed;

	button = pev(id, pev_button);
	flags = pev(id, pev_flags);
	oldbuttons = pev(id, pev_oldbuttons);
	
	if(button & IN_JUMP && !(oldbuttons & IN_JUMP))
	{
		if(flags & FL_ONGROUND) {
			pev(id, pev_velocity, velocity);
			velocity[2] = 0.0;
			speed = vector_length(velocity);

			new Array:targets = ArrayCreate();
			
			if (g_bShowPre[id])
				ArrayPushCell(targets, id);

			// Add all spectators
			for (new i = 1; i < 33; i++)
			{
				if (!is_user_connected(i) || is_user_alive(i) || !g_bShowPre[i]) continue;
				
				if (pev(i, pev_iuser2) == id)
					ArrayPushCell(targets, i);
			}

			for (new t = 0; t < ArraySize(targets); t++)
			{
				new target = ArrayGetCell(targets, t);
				
				set_hudmessage(0, 100, 255, -1.0, 0.700, 0, 0.0, 1.0, 0.1, 0.1, 4);
				ShowSyncHudMsg(target, g_iMainHudSync, "Prestrafe: %.2f", speed);
			}

			ArrayDestroy(targets);
		}
	}
	return FMRES_IGNORED;
}