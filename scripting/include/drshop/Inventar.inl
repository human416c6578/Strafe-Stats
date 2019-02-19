#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <cstrike>
#include <fakemeta>

#define SkinNR 13
#define SoundNR 17
// GLOBAL
new SkinID[33][SkinNR]
new SoundID[33][SoundNR]
new SkinUsed[33]
new SoundUsed[33]
new IVault
new SkinNames[SkinNR][] =
{
	"Buzz Lightyear",
	"Jill Valentine",
	"Trump",
	"Hitler",
	"Pepsi Man",
	"Alice",
	"Flash",
	"Horse Mask",
	"Sonic",
	"Drunk Santa Klaus",
	"DeadPool",
	"Sub-Zero",
	"Xiah"
}
new SkinNamesID[SkinNR][] =
{
	"buzzlightyear",
	"Jill",
	"Trump",
	"Hitler",
	"Pepsiman",
	"alice",
	"Flash",
	"Horsemask",
	"Sonic",
	"DrunkSanta",
	"deadpool",
	"subzero",
	"xiah"
}
new SoundNames[SoundNR][] =
{
	"Yes",
	"May The Force Be With You",
	"Helloo Babee",
	"The One and Only",
	"YMCA",
	"Filty Animal",
	"Rap God",
	"You shall not pass",
	"Taraf",
	"Electronica #1",
	"Dubstep #1",
	"Every Thing",
	"Let the bodies hit the floor",
	"Beast",
	"Some Day We will Rise",// Nou
	"Rock #1",
	"E V E"
}
new SoundNamesID[SoundNR][] =
{
	"misc/yes.wav",
	"misc/FORCE.WAV",
	"misc/HIBABE.WAV",
	"misc/THEONE.WAV",
	"misc/YMCA.WAV",
	"misc/anger.wav",
	"misc/rapgod.wav",
	"misc/shallnotpass.wav",
	"misc/Taraf.wav",
	"misc/Electronica1.wav",
	"misc/Dubstep1.wav",
	"misc/avril.wav",
	"misc/bodies.wav",
	"misc/beast.wav",
	"misc/rise.wav",
	"misc/rock.wav",
	"misc/eve.wav"
}
new HasModel[33]
new ModelID[33][32]
// Sound/
new HasSound[33]
new HSoundID[33][32]
// USER CMDS
public CmdInventar(id,target)
{
	if(!is_user_connected(target))
	{
		return PLUGIN_HANDLED
	}
	new Name[33],TName[33]
	get_user_name(id,Name,charsmax(Name))
	get_user_name(target,TName,charsmax(TName))
	console_print(id,"===============INVENTAR===============")
	for(new i = 0; i < SkinNR; i++)
	{
		if(SkinID[target][i] == 1)
		{
			console_print(id,"%s",SkinNames[i])
		}
	}
	for(new i = 0; i < SoundNR; i++)
	{
		if(SoundID[target][i] == 1)
		{
			console_print(id,"%s",SoundNames[i])
		}
	}
	console_print(id,"===============INVENTAR===============")
	chat_color(0,"!y[!gINVENTAR!y]!g Jucatorul !team%s !gii inspecteaza inventarul lui !team%s!",Name,TName) 
	client_cmd(id,"toggleconsole")
	return PLUGIN_HANDLED
}
// SKIN
public CmdSetSkin(id)
{
	new Menu = menu_create("LALEAGANE SKIN SELECTOR","SkinMenu")
	for(new i = 0; i < SkinNR; i++)
	{
		if(SkinID[id][i] == 1)
		{
			new txt[128]
			format(txt,charsmax(txt),"%s - IN INVENTAR", SkinNames[i])
			menu_additem(Menu,txt,"",0)
		}
		else
		{
			new txt[128]
			format(txt,charsmax(txt),"%s - NU DETII", SkinNames[i])
			menu_additem(Menu,txt,"",0)
		}
	}
	menu_setprop( Menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, Menu, 0 );
}
public SkinMenu(id, Menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu)
		return PLUGIN_HANDLED;
	}  
	new Name[33]
	get_user_name(id,Name,charsmax(Name))
	if(SkinID[id][item] == 1)
	{
		chat_color(id,"!y[!gSKINS!y]!g Ai ales !team%s !gskinul va fi aplicat!",SkinNames[item])
		cs_reset_user_model(id)
		cs_set_user_model(id,SkinNamesID[item])
		format(ModelID[id],31,SkinNamesID[item])
		HasModel[id] = 1
		chat_color(0,"!y[!gSKINS!y]!g Jucatorul !team%s !ga ales skin-ul !team%s!g!",Name,SkinNames[item])
		SkinUsed[id] = item
		//set_task(1.0,"UpdateStats",id + TASKID8)
	}
	else
	{
		chat_color(id,"!y[!gSKINS!y]!g Nu detii acest skin!")
	}
	log_to_file("DEBUGINVENTAR","%d",item)
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}
// SOUND
public CmdSetSound(id)
{
	new Menu = menu_create("LALEAGANE SOUND SELECTOR","SoundMenu")
	for(new i = 0; i < SoundNR; i++)
	{
		if(SoundID[id][i] == 1)
		{
			new txt[128]
			format(txt,charsmax(txt),"%s - IN INVENTAR", SoundNames[i])
			menu_additem(Menu,txt,"",0)
		}
		else
		{
			new txt[128]
			format(txt,charsmax(txt),"%s - NU DETII", SoundNames[i])
			menu_additem(Menu,txt,"",0)
		}
	}
	menu_setprop( Menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, Menu, 0 );
}
public SoundMenu(id, Menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu)
		return PLUGIN_HANDLED;
	} 
	new Name[33]
	get_user_name(id,Name,charsmax(Name))
	if(SoundID[id][item] == 1)
	{
		chat_color(id,"!y[!gSOUNDS!y]!g Ai ales !team%s !gsunetul va fi aplicat!",SoundNames[item])
		client_cmd( id, "spk ^"%s^"", SoundNamesID[item] );
		HasSound[id] = 1
		format(HSoundID[id],31,"%s",SoundNamesID[item])
		chat_color(0,"!y[!gSOUNDs!y]!g Jucatorul !team%s !ga ales sunetul !team%s!g!",Name,SoundNames[item])
		SoundUsed[id] = item
		//set_task(1.0,"UpdateStats",id + TASKID8)
	}
	log_to_file("DEBUGINVENTAR","%d",item)
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}
public CmdTestSound(id)
{
	new Menu = menu_create("LALEAGANE SOUND TESTER","SoundMenuTest")
	for(new i = 0; i < SoundNR; i++)
	{
		if(SoundID[id][i] == 1)
		{
			new txt[128]
			format(txt,charsmax(txt),"%s - IN INVENTAR", SoundNames[i])
			menu_additem(Menu,txt,"",0)
		}
		else
		{
			new txt[128]
			format(txt,charsmax(txt),"%s - NU DETII", SoundNames[i])
			menu_additem(Menu,txt,"",0)
		}
	}
	menu_setprop( Menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, Menu, 0 );
}
public SoundMenuTest(id, Menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu)
		return PLUGIN_HANDLED;
	}  
	new Name[33]
	get_user_name(id,Name,charsmax(Name))
	chat_color(id,"!y[!gSOUNDS!y]!g Testezi sunteul !team%s!g!",SoundNames[item])
	client_cmd( id, "spk ^"%s^"", SoundNamesID[item] );
	log_to_file("DEBUGINVENTAR","%d",item)
	menu_destroy(Menu)
	return PLUGIN_HANDLED
}
// ADMIN CMDS
public CmdAInventar(id, level, cid)
{
	if(!cmd_access(id, level, cid,0))
	{
		console_print(id, "Nu ai acces la aceasta comanda!")
		return PLUGIN_CONTINUE
	}
	for(new i = 0; i < SkinNR; i++)
	{
		SkinID[id][i] = 1
	}
	for(new i = 0; i < SoundNR; i++)
	{
		SoundID[id][i] = 1
	}
	new Name[33]
	get_user_name(id, Name,charsmax(Name))
	log_to_file("Inventar_Cmd.txt","Jucatorul %s a folosit comanda de debug!",Name)
	return PLUGIN_CONTINUE
}
// SRV CMDS
/*public ReadFileInventar(id)
{
	if(!dir_exists(InventarPath))
	{
		mkdir(InventarPath)
	}
	new Name[33]
	get_user_name(id,Name,charsmax(Name))
	new key[128]
	format(key,127,"%s%s.skin.txt",InventarPath,Name)
	if(!file_exists(key))
	{
		for(new i = 0; i < SkinNR; i++)
		{
			TrieSetString(skinTrie,SkinID[id][i],"0")
		}
	}
	new f = fopen(key,"r")
	new szLine[3]
	new line = 0
	while(!feof(f))
	{
		fgets(f,szLine,2)
		remove_quotes(szLine)
		TrieSetString(skinTrie,SkinID[id][line],szLine)
		line += 1
	}
	format(key,127,"%s%s.sound.txt",InventarPath,Name)
	f = fopen(key,"r")
	line = 0
	while(!feof(f))
	{
		fgets(f,szLine,2)
		remove_quotes(szLine)
		TrieSetString(soundTrie,SoundID[id][line],szLine)
		line += 1
	}
}*/
public LoadInventar(id)
{
	IVault = nvault_open("INVENTARYDB")
	new vaultkey[128], vaultdata[128]
	new Name[33]
	get_user_name(id, Name,charsmax(Name))
	for(new i = 0; i <SkinNR; i++)
	{
		format(vaultkey,127,"^"%sskinid%d^"",Name,i)
		nvault_get(IVault,vaultkey,vaultdata,charsmax(vaultdata))
		SkinID[id][i] = str_to_num(vaultdata)
	}
	for(new i = 0; i < SoundNR; i++)
	{
		format(vaultkey,127,"^"%ssoundid%d^"",Name,i)
		nvault_get(IVault,vaultkey,vaultdata,charsmax(vaultdata))
		SoundID[id][i] = str_to_num(vaultdata)
	}
	format(vaultkey,127,"^"skin%s^"",Name)
	nvault_get(IVault,vaultkey,vaultdata,charsmax(vaultdata))
	if(strcmp(vaultdata,"") == 0)
	{
		// do nothing
	}
	else
	{
		cs_reset_user_model(id)
		cs_set_user_model(id,vaultdata)
		format(ModelID[id],31,vaultdata)
		HasModel[id] = 1
		for(new i = 0; i < SkinNR; i++)
		{
			if(strcmp(vaultdata,SkinNamesID[i]) == 0)
			{
				SkinUsed[id] = i
			}
		}
	}
	format(vaultkey,127,"^"sound%s^"",Name)
	nvault_get(IVault,vaultkey,vaultdata,charsmax(vaultdata))
	if(strcmp(vaultdata,"") == 0)
	{
		// do nothing
	}
	else
	{
		client_cmd( id, "spk ^"%s^"", vaultdata );
		HasSound[id] = 1
		format(HSoundID[id],31,"%s",vaultdata)
		for(new i = 0; i < SkinNR; i++)
		{
			if(strcmp(vaultdata,SoundNamesID[i]) == 0)
			{
				SoundUsed[id] = i
			}
		}
	}
	nvault_close(IVault)
	return PLUGIN_HANDLED
}
public SaveInventar(id)
{
	IVault = nvault_open("INVENTARYDB")
	new vaultkey[128], vaultdata[128]
	new Name[33]
	get_user_name(id, Name,charsmax(Name))
	for(new i = 0; i < SkinNR; i++)
	{
		format(vaultkey,127,"^"%sskinid%d^"",Name,i)
		format(vaultdata,127,"%d",SkinID[id][i])
		nvault_set(IVault,vaultkey,vaultdata)
	}
	for(new i = 0; i < SoundNR; i++)
	{
		format(vaultkey,127,"^"%ssoundid%d^"",Name,i)
		format(vaultdata,127,"%d",SoundID[id][i])
		nvault_set(IVault,vaultkey,vaultdata)
	}
	format(vaultkey,127,"^"skin%s^"",Name)
	format(vaultdata,127,"%s",ModelID[id])
	nvault_set(IVault,vaultkey,vaultdata)
	format(vaultkey,127,"^"sound%s^"",Name)
	format(vaultdata,127,"%s",HSoundID[id])
	nvault_close(IVault)
}