// Stats Sync:
new g_iMainHudSync;
new g_iStrafeHudSync;

new bool:b_show_stats[33];

new g_iNativeStrafes[33];
new g_iNativeSync[33];

// Show Pre:
new bool:g_userConnected[33];
new bool:firstfall_ground[33];
new bool:g_Jumped[33];
new bool:g_reset[33];
new bool:g_alive[33];
new bool:b_pre_stats[33];
new bool:ladderjump[33];
new bool:notjump[33];

new Float:FallTime[33];
new Float:speed[33];
new Float:prebhopspeed[33];
new Float:preladderspeed[33];
new Float:bhopgainspeed[33];

new ddnum[33];
new bhop_num[33];
new movetype[33];