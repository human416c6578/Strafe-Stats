#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <nvault>
#include <fun>
#include <fakemeta>

public display_knife(id) {
	if (is_user_alive(id) == 0){
		console_print(id, "")
		client_print(id, print_chat, "")
		return PLUGIN_CONTINUE
	}
	else 
		console_print(id, "")
	client_print(id, print_chat, "")
	
	new menuBody[512]
	add(menuBody, 511, "\r[DR.LALEAGANE.RO] - Knife Menu!\w^n^n")
	add(menuBody, 511, "1. Machete \y(Big Damage/Decreased speed)\w^n")
	add(menuBody, 511, "2. Speed knife \y(Increased speed)\w^n")
	add(menuBody, 511, "3. Gravity knife \y(Low gravity)\w^n")
	add(menuBody, 511, "4. Normal knife \y(Regenerating life)\w^n")
	add(menuBody, 511, "5. Special knife \y(Speed+Gravity[SHOP])\w^n")
	add(menuBody, 511, "6. VIP knife \y(Super Speed+Gravity+Big Damage[Admin+])\w^n^n")
	add(menuBody, 511, "0. Exit^n")
	
	new keys = ( 1<<0 | 1<<1 | 1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<9 )
	show_menu(id, keys, menuBody, -1, "Knife Mod")
	
	return PLUGIN_HANDLED
}
public knifemenu(id, key) {
	if(get_user_flags(id) & ADMIN_LEVEL_H){
		switch(key) 
		{
			case 0: SetKnife(id , 0)
			case 1: SetKnife(id , 1)
			case 2: SetKnife(id , 2)
			case 3: SetKnife(id , 3)
			case 4: SetKnife(id , 4)
			case 5: SetKnife(id , 5)
			default: return PLUGIN_HANDLED
		}
	}
	else
	if(is_user_admin(id))
	{
		switch(key) 
		{
			case 0: SetKnife(id , 0)
			case 1: SetKnife(id , 1)
			case 2: SetKnife(id , 2)
			case 3: SetKnife(id , 3)
			case 4: SetKnife(id , 4)
			default: return PLUGIN_HANDLED
		}
	}
	else
	if(allowKnife[id] >= 1)
	{
		switch(key) 
		{
			case 0: SetKnife(id , 0)
			case 1: SetKnife(id , 1)
			case 2: SetKnife(id , 2)
			case 3: SetKnife(id , 3)
			case 4: SetKnife(id , 4)
			default: return PLUGIN_HANDLED
		}
	}
	else
	{
		switch(key) 
		{
			case 0: SetKnife(id , 0)
			case 1: SetKnife(id , 1)
			case 2: SetKnife(id , 2)
			case 3: SetKnife(id , 3)
			
			default: return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}
public SetKnife(id , Knife) {
	knife_model[id] = Knife
	new Clip, Ammo, Weapon = get_user_weapon(id, Clip, Ammo) 
	if ( Weapon != CSW_KNIFE )
		return PLUGIN_HANDLED
	
	new vModel[56],pModel[56]
	
	switch(Knife)
	{
		case 0: {
			format(vModel,55,"models/knife-mod/v_machete.mdl")
			format(pModel,55,"models/knife-mod/p_machete.mdl")
		}
		case 1: {
			format(vModel,55,"models/knife-mod/v_pocket.mdl")
			format(pModel,55,"models/knife-mod/p_pocket.mdl")
		}
		case 2: {
			format(vModel,55,"models/knife-mod/v_butcher.mdl")
			format(pModel,55,"models/knife-mod/p_butcher.mdl")
		}
		case 3: {
			format(vModel,55,"models/v_knife.mdl")
			format(pModel,55,"models/p_knife.mdl")	
		}
		case 4: {
			format(vModel,55,"models/knife-mod/v_knifeadminV2.mdl")
		} 
		case 5: {
			format(vModel,55,"models/knife-mod/v_super.mdl")
			format(pModel,55,"models/knife-mod/p_super.mdl")
		}
	}
	
	entity_set_string(id, EV_SZ_viewmodel, vModel)
	entity_set_string(id, EV_SZ_weaponmodel, pModel)
	
	return PLUGIN_HANDLED;  
}
public event_damage(id) {
	
	new victim_id = id;
	if( !is_user_connected( victim_id ) ) return PLUGIN_CONTINUE
	new dmg_take = read_data( 2 );
	new dmgtype = read_data( 3 );
	new Float:multiplier = get_pcvar_float(CVAR_DAMAGE);
	new Float:damage = dmg_take * multiplier;
	new health = get_user_health( victim_id );
	
	new iWeapID, attacker_id = get_user_attacker( victim_id, iWeapID );
	
	if( !is_user_connected( attacker_id ) || !is_user_alive( victim_id ) ) {
		return PLUGIN_HANDLED
	}
	
	if( iWeapID == CSW_KNIFE && knife_model[attacker_id] == 0 ) {
		
		if( floatround(damage) >= health ) {
			if( victim_id == attacker_id ) {
				return PLUGIN_CONTINUE
				}else{
				log_kill( attacker_id, victim_id, "knife", 0 );
			}
			
			return PLUGIN_CONTINUE
			}else {
			if( victim_id == attacker_id ) return PLUGIN_CONTINUE
			
			fakedamage( victim_id, "weapon_knife", damage, dmgtype );
		}
		
	}
	else if(iWeapID == CSW_KNIFE && knife_model[attacker_id] == 5 && get_user_flags(id) == ADMIN_LEVEL_H)
	{
		if( floatround(damage) >= health ) {
			if( victim_id == attacker_id ) {
				return PLUGIN_CONTINUE
				}else{
				log_kill( attacker_id, victim_id, "knife", 0 );
			}
			
			return PLUGIN_CONTINUE
			}else {
			if( victim_id == attacker_id ) return PLUGIN_CONTINUE
			
			fakedamage( victim_id, "weapon_knife", damage, dmgtype );
		}
	}
	return PLUGIN_CONTINUE
}

public EventCurWeapon(id)
{
	new Weapon = read_data(2)
	if(Weapon == CSW_KNIFE)
	{
		SetKnife(id, knife_model[id]) 
		if(knife_model[id] == 0)
		{
			set_user_gravity(id , 1.0)
			set_user_maxspeed(id, 170.0)
		}
		else if(knife_model[id] == 1)
		{
			set_user_gravity(id , 1.0)
			set_user_maxspeed(id, 320.0)
		}
		else if(knife_model[id] == 2)
		{
			set_user_gravity(id , 0.5)
			set_user_maxspeed(id, 250.0)
		}
		else if(knife_model[id] == 3)
		{
			set_user_gravity(id , 1.0)
			set_user_maxspeed(id, 250.0)
			set_task(TASK_INTERVAL , "task_healing",id,_,_,"b")
		}
		else if(knife_model[id] == 4)
		{
			set_user_gravity(id , 0.45)	
			set_user_maxspeed(id, 390.0)
		}
		else if(knife_model[id] == 5)
		{
			set_user_gravity(id , 0.5)
			if(get_user_flags(id) == ADMIN_LEVEL_H)
			{
				set_user_maxspeed(id, 650.0)
			}
			else
			{
				set_user_maxspeed(id, 390.0)
			}
		}
	}
	else
	{
		set_user_gravity(id , 1.0)
		if(get_user_flags(id) == ADMIN_LEVEL_H)
		{
			set_user_maxspeed(id, 450.0)
		}
		else
		{
			set_user_maxspeed(id, 250.0)
		}
	}
	return PLUGIN_HANDLED
}
public task_healing(id) {  
	new addhealth = get_pcvar_num(CVAR_HEALTH_ADD)  
	if (!addhealth)
		return  

	new maxhealth = get_pcvar_num(CVAR_HEALTH_MAX)  
	if (maxhealth > MAX_HEALTH) { 
		set_pcvar_num(CVAR_HEALTH_MAX, MAX_HEALTH)  
		maxhealth = MAX_HEALTH 
	}  
	new health = get_user_health(id)   

	if (is_user_alive(id) && (health < maxhealth)) { 
		set_user_health(id, health + addhealth)
		set_hudmessage(0, 255, 0, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.1, 4)
		show_hudmessage(id,"<< !!HEAL IN PROGRESS!! >>")
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(0)
		write_byte(200)
		write_byte(0)
		write_byte(75)
		message_end()
	}

	else {
		if (is_user_alive(id) && (health > maxhealth))
			remove_task(id)
		
	}
}  

public kmodmsg() { 
	chat_color(0,"!y[!gDR!y]!g Type !team/knife !gto change your !teamknife !gskin")
}  