component {
	
	public any function init(){
		this.commonKeys = ["CFID","CFToken","URLToken","SessionID"];
		this.varValidator = createObject("java", "java.util.regex.Pattern").compile("^[a-zA-Z_][\w_]*(\.[a-zA-Z_][\w_]*)*$");

		return this;
	}

	public query function getSessions(boolean bCurrent, numeric maxRows=5) hint="Returns information about the currently active sessions" {
		var qSessions = querynew("sessionID,lastAccessed,bCurrent,user", "varchar,date,bit,varchar");
		var sessionID = "";
		var qResult = new Query();
		
		if (not structKeyExists(arguments, "bCurrent") or arguments.bCurrent eq 1){
			queryAddRow(qSessions);
			querySetCell(qSessions, "sessionID", getCurrentSessionID());
			querySetCell(qSessions, "lastAccessed", now());
			querySetCell(qSessions, "bCurrent", 1);
			querySetCell(qSessions, "user", isdefined("session.dmProfile.label") ? session.dmProfile.label : "anonymous");
		}

		if ((not structKeyExists(arguments, "bCurrent") or arguments.bCurrent eq 0) and isdefined("session.sessions")){
			for (sessionID in session.sessions){
				queryAddRow(qSessions);
				querySetCell(qSessions, "sessionID", sessionID);
				querySetCell(qSessions, "lastAccessed", session.sessions[sessionID].lastAccessed);
				querySetCell(qSessions, "bCurrent", 0);
				querySetCell(qSessions, "user", isdefined("session.sessions.#sessionID#.dmProfile.label") ? session.sessions[sessionID].dmProfile.label : "anonymous");
			}
		}

		qResult.setDBType("query");
		qResult.setAttributes(sourceQuery=qSessions);
		qResult.addParam(name="type", value="Admin", cfsqltype="cf_sql_varchar");
		qResult.setMaxRows(arguments.maxRows);
		qResult.setSQL("SELECT * FROM sourceQuery ORDER BY lastAccessed DESC");

		return qResult.execute().getResult();
	}

	public string function switchSession(string sessionID="session_#replace(application.fapi.getUUID(), '-', '_', 'ALL')#", boolean keepOldSession=true) hint="Switches to the specified session scope, creating it if necessary" {
		var currentSession = copyCurrent();
		var key = "";

		param name="session.sessions" default="#{}#";
		param name="session.sessions.#arguments.sessionID#" default="#{ 'fcSessionID'=arguments.sessionID }#";

		// store current session
		if (arguments.keepOldSession){
			session.sessions[currentSession.fcSessionID] = currentSession;
		}

		// switch in new session
		clearCurrent();
		structAppend(session, session.sessions[arguments.sessionID], true);
		structDelete(session.sessions, arguments.sessionID);

		return arguments.sessionID;
	}

	public void function endSession(string sessionID) hint="Removes an existing session scope" {
		var currentSessionID = getCurrentSessionID();
		var lastSessionID = getLastSessionID();
		var key = "";
		
		param name="arguments.sessionID" default="#currentSessionID#";

		if (arguments.sessionID eq currentSessionID and len(lastSessionID)){
			switchSession(sessionID=lastSessionID, keepOldSession=false);
		}
		else if (arguments.sessionID eq currentSessionID){
			clearCurrentSession();
		}
		else if (isDefined("session.sessions.#arguments.sessionID#")){
			structDelete(session.sessions, arguments.sessionID);
		}
	}

	public any function getSession(string sessionID) hint="Retrieves an entire session" {
		var currentSessionID = getCurrentSessionID();
		
		param name="arguments.sessionID" default="#currentSessionID#";

		if (arguments.sessionID eq currentSessionID){
			return session;
		}
		if (isDefined("session.sessions.#arguments.sessionID#")){
			return session.sessions[arguments.sessionID];
		}
		
		throw(message="Requested session does not exist: [#arguments.sessionID#]");
	}

	public any function setSession(string sessionID, struct scope) hint="Updates the session" {
		
	}


	private struct function copyCurrent(){
		var currentSessionID = getCurrentSessionID();
		var currentSession = structcopy(session);
		var key = "";

		for (key in currentSession){
			if (key eq "sessions" or arrayFind(this.commonKeys, key)){
				structDelete(currentSession, key);
			}
		}

		currentSession.lastAccessed = now();

		return currentSession;
	}

	private void function clearCurrent(){
		var key = "";

		for (key in session){
			if (key neq "sessions" and not arrayFind(this.commonKeys, key)){
				structDelete(session, key);
			}
		}
	}

	private string function getCurrentSessionID(){
		if (not structKeyExists(session, "fcSessionID")){
			session.fcSessionID = "session_#replace(application.fapi.getUUID(), '-', '_', 'ALL')#";
		}

		return session.fcSessionID;
	}

	private string function getLastSessionID() hint="Returns the ID for the latest non-current session" {
		var sessionID = "";
		var lastAccessed = "";
		var key = "";

		if (not structKeyExists(session, "sessions")){
			return "";
		}

		for (key in session.sessions){
			if (sessionID eq "" or session.sessions[key].lastAccessed gt lastAccessed){
				sessionID = key;
				lastAccessed = session.sessions[key].lastAccessed;
			}
		}

		return sessionID;
	}

}