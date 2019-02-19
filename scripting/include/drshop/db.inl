#include <amxmodx>
#include <amxmisc>
#include <sqlx>

new Handle:g_SqlTuple
new g_Error[512]

new szHost[32], szUser[32], szPass[32], szDB[32];

public PluginCfg()
{

	SQL_SetAffinity("sqlite");

	get_cvar_string("amx_timer_host", szHost, 31);
	get_cvar_string("amx_timer_user", szUser, 31);
	get_cvar_string("amx_timer_pass", szPass, 31);
	get_cvar_string("amx_timer_db", szDB, 31);

	g_SqlTuple = SQL_MakeDbTuple(szHost,szUser,szPass,szDB);


}

public AddUser(nickname[64]){
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "INSERT OR IGNORE INTO Users (Name) VALUES ('%s');", nickname);
	Execute(Query);
	SQL_FreeHandle(SqlConnection);
}

public GetCredits(nickname[64]){
	new Data[64];
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "SELECT credits FROM `Users` WHERE `Name` = '%s'", nickname);

	// run the query
	if (!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, g_Error, 511)
		//set_fail_state(g_Error)
	}

	// checks to make sure there's more results
	// notice that it starts at the first row, rather than null
	if(SQL_MoreResults(Query))
	{
		format(Data, 63, "%d", SQL_ReadResult(Query, 0))
	}

	// of course, free the handle
	SQL_FreeHandle(Query);

	// and of course, free the connection
	SQL_FreeHandle(SqlConnection);
	
	return Data;
}

public GetTrail(nickname[64]){
	new Data[64];
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "SELECT Trail FROM `Users` WHERE `Name` = '%s'", nickname);

	// run the query
	if (!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, g_Error, 511)
		//set_fail_state(g_Error)
	}

	// checks to make sure there's more results
	// notice that it starts at the first row, rather than null
	if(SQL_MoreResults(Query))
	{
		format(Data, 63, "%d", SQL_ReadResult(Query, 0))
	}

	// of course, free the handle
	SQL_FreeHandle(Query);

	// and of course, free the connection
	SQL_FreeHandle(SqlConnection);
	
	return Data;
}

public GetSpecialKnife(nickname[64]){
	new Data[64];
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "SELECT KnifeSpecial FROM `Users` WHERE `Name` = '%s'", nickname);

	// run the query
	if (!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, g_Error, 511)
		//set_fail_state(g_Error)
	}

	// checks to make sure there's more results
	// notice that it starts at the first row, rather than null
	if(SQL_MoreResults(Query))
	{
		format(Data, 63, "%d", SQL_ReadResult(Query, 0))
	}

	// of course, free the handle
	SQL_FreeHandle(Query);

	// and of course, free the connection
	SQL_FreeHandle(SqlConnection);
	
	return Data;
}

public GetCurrentKnife(nickname[64]){
	new Data[64];
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "SELECT CurrentKnife FROM `Users` WHERE `Name` = '%s'", nickname);
	// run the query
	if (!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, g_Error, 511)
		//set_fail_state(g_Error)
	}

	// checks to make sure there's more results
	// notice that it starts at the first row, rather than null
	if(SQL_MoreResults(Query))
	{
		format(Data, 63, "%d", SQL_ReadResult(Query, 0))
	}

	// of course, free the handle
	SQL_FreeHandle(Query);

	// and of course, free the connection
	SQL_FreeHandle(SqlConnection);
	
	return Data;
}

public SaveCurrentKnife(nickname[64], knife_model[64]){
	new data[64];
	format(data, 63, "%s", knife_model)
	log_amx("Save current knife string : %s / int : %d",data,data)
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "UPDATE Users SET 'CurrentKnife' = '%d' WHERE Name='%s';", data, nickname);
	Execute(Query);
	SQL_FreeHandle(SqlConnection);
}

public SaveCredits(nickname[64], credite[64]){
	new data[64];
	format(data, 63, "%s", credite)
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "UPDATE Users SET 'credits' = '%d' WHERE Name='%s';", data, nickname);
	Execute(Query);
	SQL_FreeHandle(SqlConnection);
}

public SaveTrail(nickname[64]){
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "UPDATE Users SET 'Trail' = '1' WHERE Name='%s';", nickname);
	Execute(Query);
	SQL_FreeHandle(SqlConnection);
}

public SaveKnife(nickname[64]){
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "UPDATE Users SET 'KnifeSpecial' = 1 WHERE Name='%s';", nickname);
	Execute(Query);
	SQL_FreeHandle(SqlConnection);
}

public GivePlayerCredits(nickname[64], crediteOld[64], credite[64]){
	new ErrorCode, Handle:SqlConnection = SQL_Connect(g_SqlTuple, ErrorCode, g_Error, 511)
	if (SqlConnection == Empty_Handle)
		// stop the plugin with an error message
		set_fail_state(g_Error)

	new Handle:Query = SQL_PrepareQuery(SqlConnection, "UPDATE Users SET 'credits' = '%s + %s' WHERE Name='%s';", crediteOld, credite, nickname);
	Execute(Query);
	SQL_FreeHandle(SqlConnection);

}

Execute(Handle:Query){
	// run the query
	if (!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, g_Error, 511)
		//set_fail_state(g_Error)
	}

	// checks to make sure there's more results
	// notice that it starts at the first row, rather than null
	if(SQL_MoreResults(Query))
	{
		//Do Nothing
	}

	// of course, free the handle
	SQL_FreeHandle(Query);

	
	
}


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
