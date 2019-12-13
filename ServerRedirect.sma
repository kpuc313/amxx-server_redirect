/*****************************************************************
*                            MADE BY
*
*   K   K   RRRRR    U     U     CCCCC    3333333      1   3333333
*   K  K    R    R   U     U    C     C         3     11         3
*   K K     R    R   U     U    C               3    1 1         3
*   KK      RRRRR    U     U    C           33333   1  1     33333
*   K K     R        U     U    C               3      1         3
*   K  K    R        U     U    C     C         3      1         3
*   K   K   R         UUUUU U    CCCCC    3333333      1   3333333
*
******************************************************************
*                       AMX MOD X Script                         *
*     You can modify the code, but DO NOT modify the author!     *
*****************************************************************/

#include <amxmodx>

#define TAG "SR"
#define MAX_STRING_LEN 256
#define MAX_LINES 64

new pcv_announce_hud, pcv_announce_time
new g_SayText, g_MsgSync

new server_name[MAX_LINES][MAX_STRING_LEN]
new server_ip[MAX_LINES][MAX_STRING_LEN]

public plugin_init() {
	register_plugin("Server Redirect", "1.0", "rapara13")
	
	register_clcmd("say /server" ,"cmdMenu")
	
	pcv_announce_hud = register_cvar("sr_announce_hud","1")
	pcv_announce_time = register_cvar("sr_announce_time","90")

	load_settings("addons/amxmodx/configs/ServersList.ini")
	
	set_task(get_pcvar_float(pcv_announce_time),"ShowHud",0,"",0,"b") 
	
	g_SayText = get_user_msgid("SayText")
	g_MsgSync = CreateHudSyncObj()
}

load_settings(szFilename[]) {
	if (file_exists(szFilename)) {
		new num = 0
		new szText[MAX_STRING_LEN], setname[MAX_STRING_LEN], setip[MAX_STRING_LEN]
		new a, pos = 0
		while (num < MAX_LINES && read_file(szFilename, pos++, szText, sizeof(szText), a)) {         
			if (szText[0] == ';' || szText[0] == '#')
				continue
			if (parse(szText,setname,sizeof(setname),setip,sizeof(setip)) < 2)
				continue

			copy(server_name[num], MAX_STRING_LEN - 1, setname) 
			copy(server_ip[num], MAX_STRING_LEN - 1, setip)
			num++
		}
	} else {
		log_amx("[%s] ERROR: File configs/ServersList.ini doesn't exist!", TAG)
	}
	return 1
}

public ShowHud(id) {
	if(!get_pcvar_num(pcv_announce_hud))
		return
	
	set_hudmessage(30, 144, 255, -1.0, 0.02, 2, 6.0, 12.0, 0.1, 0.2, -1)
	ShowSyncHudMsg(id, g_MsgSync, "Say /server to switch between servers")
}

public cmdMenu(id) {
	new menu = menu_create("Choose Server:", "cmdMenu2")
	new data[6]
	for (new i = 0; i <= (MAX_LINES-1); i++) {
		if(server_name[i][0]){
			format(data, charsmax(data), "%d", i)
			menu_additem(menu, server_name[i], data)
		}
	}
	
	menu_display(id, menu, 0)
}

public cmdMenu2(id, menu, item) {
	if(item == MENU_EXIT ) 
	{ 
		menu_destroy(menu) 
		return PLUGIN_HANDLED 
	} 
	new data[6], iName[64], name[32]
	new access, callback

	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
	get_user_name(id, name, 32)

	new key = str_to_num(data)
	
	for (new i = 0; i <= (MAX_LINES-1); i++) {
		if(server_name[i][0]){
			if(key == i)
			{
				client_cmd(id, "connect %s", server_ip[i])
				colormsg(0, "\g[%s] \t%s\y has been redirected to \g%s", TAG, name, server_name[i])
			}
		}
	}
	
	return PLUGIN_HANDLED
}

stock colormsg(const id, const string[], {Float, Sql, Resul,_}:...) {
	new msg[191], players[32], count = 1;
	vformat(msg, sizeof msg - 1, string, 3);
	
	replace_all(msg,190,"\g","^4");
	replace_all(msg,190,"\y","^1");
	replace_all(msg,190,"\t","^3");
	
	if(id)
		players[0] = id;
	else
		get_players(players,count,"ch");
	
	for (new i = 0 ; i < count ; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_SayText,_, players[i]);
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}		
	}
}
