<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Session Status --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!---
	Read-only view of how sessions are configured and where they are stored, plus a live
	persistence check and an optional store round-trip test. Everything comes from
	getApplicationSettings() and framework internals - no application-specific env vars. Built to
	make session mis-config obvious, especially external session storage with clustering off,
	which relies on sticky load balancing and reaps CSRF tokens from memory after ~5 minutes. No
	secrets are shown, and the page changes nothing beyond a short-lived probe key during the
	explicit store test. Rows for direct application settings are labelled by their CFML key.
--->

<skin:loadJS id="farcry-form" />

<cfscript>
	// getApplicationSettings() also carries datasource credentials, so we only read the
	// session-relevant keys by name - never dump it wholesale.
	stApp = getApplicationSettings();

	sStorage  = structkeyexists(stApp, "sessionstorage") ? stApp.sessionstorage : "memory";
	bCluster  = structkeyexists(stApp, "sessioncluster") ? stApp.sessioncluster : false;
	bExternal = (lcase(sStorage) neq "memory");
	stCookie  = structkeyexists(stApp, "sessioncookie") ? stApp.sessioncookie : {};

	// format a CFML timespan (fractional days) as "Nh Mm"
	fmtSpan = function(span) {
		var mins = round(arguments.span * 24 * 60);
		var h = int(mins / 60);
		var m = mins mod 60;
		if (h and m) { return h & "h " & m & "m"; }
		if (h) { return h & "h"; }
		return m & "m";
	};
	sessTimeoutDisp = structkeyexists(stApp, "sessiontimeout") ? fmtSpan(stApp.sessiontimeout) : "?";
	appTimeoutDisp  = structkeyexists(stApp, "applicationtimeout") ? fmtSpan(stApp.applicationtimeout) : "?";

	// resolved cache connection backing the session store (from application settings, not env)
	storeClass = ""; storeServers = ""; storeFormat = "";
	if (bExternal and structkeyexists(stApp, "cache") and isStruct(stApp.cache)
			and structkeyexists(stApp.cache, "connections") and structkeyexists(stApp.cache.connections, sStorage)
			and isStruct(stApp.cache.connections[sStorage])) {
		conn = stApp.cache.connections[sStorage];
		storeClass = structkeyexists(conn, "class") ? conn.class : "";
		if (structkeyexists(conn, "custom") and isStruct(conn.custom)) {
			storeServers = structkeyexists(conn.custom, "servers") ? conn.custom.servers : "";
			storeFormat  = structkeyexists(conn.custom, "storage_format") ? conn.custom.storage_format : "";
		}
	}
	// mask the host but keep the port - the endpoint is internal and not a credential, but there's no need to print the exact host into a screenshot
	storeServersMasked = "";
	for (srv in listToArray(storeServers)) {
		storeServersMasked = listAppend(storeServersMasked, find(":", srv) ? "***:" & listLast(srv, ":") : "***");
	}

	// sessioncluster decision chain + engine (engine-agnostic; the 5.3.8 threshold below only
	// applies to Lucee, which is what the framework keys the decision off)
	frameworkDecision = structkeyexists(server, "farcrySessionCluster") ? server.farcrySessionCluster : "(unset)";
	// core's own override; read via System.getenv (server.system is Lucee-only) so this page also runs on ACF
	envOverride = "";
	try { envOverride = createObject("java", "java.lang.System").getenv("FARCRY_OVERRIDE_SESSIONCLUSTER") ?: ""; } catch (any e) {}
	// engine name only - not the exact version (avoid handing an attacker a precise CVE target)
	if (structkeyexists(server, "lucee")) {
		engineName = "Lucee";
	} else if (structkeyexists(server, "coldfusion")) {
		engineName = structkeyexists(server.coldfusion, "productname") ? server.coldfusion.productname : "ColdFusion";
	} else {
		engineName = "unknown";
	}
	luceeVer = structkeyexists(server, "lucee") ? (server.lucee.version ?: "") : "";
	vp = listToArray(luceeVer, ".");
	verNum = (arraylen(vp) ge 3) ? (val(vp[1]) * 1000000 + val(vp[2]) * 1000 + val(vp[3])) : 0;
	bLucee538 = (len(luceeVer) and verNum ge (5 * 1000000 + 3 * 1000 + 8));

	// current request / client
	cfidVal = ""; try { cfidVal = session.cfid; } catch (any e) {}
	// never show the raw session id (hijack vector); a short one-way hash still lets you eyeball "same session across reloads"
	cfidFingerprint = len(cfidVal) ? lcase(left(hash(cfidVal, "SHA-256"), 12)) : "";
	bCSRF = application.fapi.getConfig("security", "bCSRFTokens", "(unset)");
	fwdProto = "";
	try { reqHeaders = getHTTPRequestData().headers; fwdProto = structkeyexists(reqHeaders, "X-Forwarded-Proto") ? reqHeaders["X-Forwarded-Proto"] : ""; } catch (any e) {}

	// live persistence counter - top-level session writes so they flush to the store
	if (not structkeyexists(session, "__sessionStatusHits")) { session.__sessionStatusHits = 0; session.__sessionStatusFirstSeen = now(); }
	session.__sessionStatusHits = session.__sessionStatusHits + 1;
	hits = session.__sessionStatusHits;
	firstSeen = session.__sessionStatusFirstSeen;
	ageSecs = dateDiff("s", firstSeen, now());

	// optional store round-trip test (Test button posts selectedObjectID=__store__)
	testTarget = structkeyexists(form, "selectedObjectID") ? form.selectedObjectID : "";
	storeTested = false; storeOK = false; storeMsg = "";
	if (testTarget eq "__store__") {
		storeTested = true;
		if (not bExternal) {
			storeOK = true; storeMsg = "Sessions are in-memory - there is no external store to reach.";
		} else {
			try {
				probeId = "__sessionstatus_probe_" & createUUID();
				cachePut(id = probeId, value = "ok", timeSpan = createTimeSpan(0, 0, 1, 0), cacheName = sStorage);
				got = cacheGet(id = probeId, cacheName = sStorage);
				try { cacheRemove(ids = probeId, throwOnError = false, cacheName = sStorage); } catch (any eRm) {}
				storeOK = (isSimpleValue(got) and got eq "ok");
				storeMsg = storeOK ? ("Wrote and read back a probe key via cache '" & sStorage & "'.") : "Probe key did not read back - the store may be unreachable.";
			} catch (any e) {
				storeOK = false; storeMsg = e.type & ": " & e.message;
			}
		}
	}

	// consistency checks - the disconnect detector
	aChecks = arraynew(1);
	if (bExternal and not bCluster) {
		arrayappend(aChecks, { "level" = "warn", "text" = "External session storage (" & sStorage & ") with sessioncluster OFF. Sessions are cached per-node, so this relies on sticky load balancing - a request routed to another node will not find the session. Lucee also reaps CSRF tokens from memory after ~5 minutes in this mode." });
	} else if (bExternal and bCluster) {
		arrayappend(aChecks, { "level" = "ok", "text" = "External session storage (" & sStorage & ") with sessioncluster ON. Sessions are read from the store each request, so they are node-independent and CSRF tokens persist." });
	} else if (not bExternal and bCluster) {
		arrayappend(aChecks, { "level" = "note", "text" = "sessioncluster is ON but storage is in-memory - clustering is inert for in-memory sessions." });
	} else {
		arrayappend(aChecks, { "level" = "note", "text" = "In-memory, single-node sessions (sessioncluster OFF, storage memory)." });
	}
	if (len(envOverride)) {
		arrayappend(aChecks, { "level" = "note", "text" = "FARCRY_OVERRIDE_SESSIONCLUSTER is set to '" & envOverride & "' - the framework's version-based decision is being overridden. Intended for firefighting only." });
	}
	if (structkeyexists(stCookie, "secure") and stCookie.secure and not (len(fwdProto) and lcase(fwdProto) eq "https")) {
		arrayappend(aChecks, { "level" = "note", "text" = "The session cookie is Secure (HTTPS-only) but this request was not seen as HTTPS (no X-Forwarded-Proto: https). Behind a TLS-terminating proxy that is expected; over plain HTTP the browser will not return the session cookie." });
	}
	if (bExternal and len(luceeVer) and not bLucee538) {
		arrayappend(aChecks, { "level" = "note", "text" = "This engine is below Lucee 5.3.8 - the CSRF-token-persistence behaviour that pairs with sessioncluster differs below that version." });
	}

	// render helpers
	stCheckClass = { "ok" = "text-success", "warn" = "text-danger", "note" = "text-muted" };
	stCheckIcon  = { "ok" = "fa-check-circle", "warn" = "fa-exclamation-triangle", "note" = "fa-info-circle" };
	yn = function(v) { return encodeForHTML((isBoolean(arguments.v) and arguments.v) ? "yes" : ((isBoolean(arguments.v) and not arguments.v) ? "no" : arguments.v)); };
</cfscript>

<cfoutput>
<style type="text/css">
	.sess-panel { margin:0 0 1.3em; }
	.sess-head { display:flex; align-items:center; gap:0.8em; margin:1.5em 0 0.4em; padding:0 0 0.35em; border-bottom:1px solid ##e5e5e5; }
	.sess-head h2 { color:##337ab7; font-size:1.3em; font-weight:500; margin:0; border:0; }
	.sess-verdict { margin:0.2em 0 0.6em; }
	.sess-check { display:flex; align-items:baseline; gap:0.5em; margin:0.35em 0; }
	.sess-check i { flex:0 0 auto; }
	table.sess-props { margin-bottom:0.6em; }
	table.sess-props > tbody > tr:first-child > td { border-top:0; }
	table.sess-props td.sess-key { width:300px; white-space:nowrap; }
	table.sess-props td.sess-key.sub { font-weight:normal; padding-left:1.8em; }
</style>
<h1>Session Status</h1>
<p>How sessions are configured, where they are stored, and whether they are actually persisting on this node right now.</p>
</cfoutput>

<ft:form>

<cfoutput>
	<!--- live persistence: the quickest way to spot "sessions aren't sticking" --->
	<div class="sess-panel">
		<div class="sess-head"><h2>Live session</h2></div>
		<p class="sess-verdict">
			<cfif hits gt 1>
				<span class="text-success"><i class="fa fa-check-circle"></i> <strong>Persisting</strong></span>
				&middot; this session has served <strong>#hits#</strong> requests to this page over #ageSecs#s.
			<cfelse>
				<span class="text-muted"><i class="fa fa-info-circle"></i> <strong>First view</strong></span>
				&middot; <strong>reload this page</strong>: if this count rises and the fingerprint below stays the same, sessions are persisting; if it stays at 1 and the fingerprint changes each reload, they are not.
			</cfif>
		</p>
		<table class="table table-striped table-condensed sess-props">
			<tbody>
				<tr><td class="sess-key"><strong>session fingerprint</strong></td><td><cfif len(cfidFingerprint)>#encodeForHTML(cfidFingerprint)# <span class="text-muted">(hash of cfid)</span><cfelse><span class="text-muted">(not available)</span></cfif></td></tr>
				<tr><td class="sess-key"><strong>requests to this page</strong></td><td>#hits#</td></tr>
				<tr><td class="sess-key"><strong>session first seen</strong></td><td>#dateformat(firstSeen,"yyyy-mm-dd")# #timeformat(firstSeen,"HH:mm:ss")# (#ageSecs#s ago)</td></tr>
			</tbody>
		</table>
	</div>

	<!--- consistency checks --->
	<div class="sess-panel">
		<div class="sess-head"><h2>Consistency checks</h2></div>
		<cfloop array="#aChecks#" index="chk">
			<p class="sess-check #stCheckClass[chk.level]#"><i class="fa #stCheckIcon[chk.level]#"></i> #encodeForHTML(chk.text)#</p>
		</cfloop>
	</div>

	<!--- storage + the sessioncluster decision chain --->
	<div class="sess-panel">
		<div class="sess-head">
			<h2>Session storage &amp; clustering</h2>
			<ft:button value="Test store" text="Test the session store round-trips" selectedObjectID="__store__" validate="false" />
		</div>
		<cfif storeTested>
			<p title="#encodeForHTMLAttribute(storeMsg)#">
				<cfif storeOK><span class="text-success"><strong>Store OK</strong></span><cfelse><span class="text-danger"><strong>Store test failed</strong></span></cfif>
				&middot; #encodeForHTML(storeMsg)#
			</p>
		</cfif>
		<table class="table table-striped table-condensed sess-props">
			<tbody>
				<tr><td class="sess-key"><strong>sessionstorage</strong></td><td><strong>#encodeForHTML(sStorage)#</strong> <cfif bExternal><span class="label label-info">external</span><cfelse><span class="label label-default">in-JVM (per node)</span></cfif></td></tr>
				<cfif bExternal>
					<tr><td class="sess-key sub">class</td><td><cfif len(storeClass)>#encodeForHTML(storeClass)#<cfelse><span class="text-muted">(not resolvable from application settings)</span></cfif></td></tr>
					<cfif len(storeServers)><tr><td class="sess-key sub">servers</td><td>#encodeForHTML(storeServersMasked)#</td></tr></cfif>
					<cfif len(storeFormat)><tr><td class="sess-key sub">storage_format</td><td>#encodeForHTML(storeFormat)#</td></tr></cfif>
				</cfif>
				<tr><td class="sess-key"><strong>sessioncluster</strong> <span class="text-muted">(effective)</span></td><td><strong>#yn(bCluster)#</strong></td></tr>
				<tr><td class="sess-key sub"><code>server.farcrySessionCluster</code></td><td>#yn(frameworkDecision)#</td></tr>
				<tr><td class="sess-key sub"><code>FARCRY_OVERRIDE_SESSIONCLUSTER</code></td><td><cfif len(envOverride)>#encodeForHTML(envOverride)# <span class="label label-warning">override active</span><cfelse><span class="text-muted">(not set)</span></cfif></td></tr>
				<tr><td class="sess-key sub">engine</td><td>#encodeForHTML(engineName)#<cfif len(luceeVer)> <span class="text-muted">(&ge; 5.3.8: #yn(bLucee538)#)</span></cfif></td></tr>
			</tbody>
		</table>
	</div>

	<!--- CSRF: a Core feature (friendly label), kept out of the CFML application-setting keys below --->
	<div class="sess-panel">
		<div class="sess-head"><h2>CSRF protection</h2></div>
		<table class="table table-striped table-condensed sess-props">
			<tbody>
				<tr><td class="sess-key"><strong>CSRF tokens enabled</strong></td><td>#yn(bCSRF)# <span class="text-muted">(<code>bCSRFTokens</code>)</span></td></tr>
			</tbody>
		</table>
	</div>

	<!--- CFML application settings, labelled by key --->
	<div class="sess-panel">
		<div class="sess-head"><h2>Application settings</h2></div>
		<table class="table table-striped table-condensed sess-props">
			<tbody>
				<tr><td class="sess-key"><strong>name</strong></td><td>#encodeForHTML(structkeyexists(stApp,"name") ? stApp.name : "")#</td></tr>
				<tr><td class="sess-key"><strong>sessionmanagement</strong></td><td>#yn(structkeyexists(stApp,"sessionmanagement") ? stApp.sessionmanagement : "")#</td></tr>
				<tr><td class="sess-key"><strong>sessiontimeout</strong></td><td>#encodeForHTML(sessTimeoutDisp)#</td></tr>
				<tr><td class="sess-key"><strong>applicationtimeout</strong></td><td>#encodeForHTML(appTimeoutDisp)#</td></tr>
				<tr><td class="sess-key"><strong>clientmanagement</strong></td><td>#yn(structkeyexists(stApp,"clientmanagement") ? stApp.clientmanagement : "")#</td></tr>
				<tr><td class="sess-key"><strong>clientstorage</strong></td><td>#encodeForHTML(structkeyexists(stApp,"clientstorage") ? stApp.clientstorage : "")#</td></tr>
				<tr><td class="sess-key"><strong>loginstorage</strong></td><td>#encodeForHTML(structkeyexists(stApp,"loginstorage") ? stApp.loginstorage : "")#</td></tr>
				<tr><td class="sess-key"><strong>setclientcookies</strong></td><td>#yn(structkeyexists(stApp,"setclientcookies") ? stApp.setclientcookies : "")#</td></tr>
				<tr><td class="sess-key"><strong>setdomaincookies</strong></td><td>#yn(structkeyexists(stApp,"setdomaincookies") ? stApp.setdomaincookies : "")#</td></tr>
				<tr><td class="sess-key"><strong>sessioncookie.secure</strong></td><td>#yn(structkeyexists(stCookie,"secure") ? stCookie.secure : "")#</td></tr>
				<tr><td class="sess-key"><strong>sessioncookie.httponly</strong></td><td>#yn(structkeyexists(stCookie,"httponly") ? stCookie.httponly : "")#</td></tr>
				<tr><td class="sess-key"><strong>sessioncookie.samesite</strong></td><td>#encodeForHTML(structkeyexists(stCookie,"samesite") ? stCookie.samesite : "")#</td></tr>
				<tr><td class="sess-key"><strong>sessioncookie.domain</strong></td><td><cfif structkeyexists(stCookie,"domain") and len(stCookie.domain)>#encodeForHTML(stCookie.domain)#<cfelse><span class="text-muted">(host-only)</span></cfif></td></tr>
			</tbody>
		</table>
	</div>

	<!--- this request / client --->
	<div class="sess-panel">
		<div class="sess-head"><h2>This request</h2></div>
		<table class="table table-striped table-condensed sess-props">
			<tbody>
				<tr><td class="sess-key"><strong>X-Forwarded-Proto</strong></td><td><cfif len(fwdProto)>#encodeForHTML(fwdProto)#<cfelse><span class="text-muted">(none)</span></cfif></td></tr>
				<tr><td class="sess-key"><strong>cgi.https</strong></td><td>#encodeForHTML(cgi.https ?: "")#</td></tr>
				<tr><td class="sess-key"><strong>cgi.http_user_agent</strong></td><td>#encodeForHTML(cgi.http_user_agent ?: "")#</td></tr>
				<tr><td class="sess-key"><strong>cgi.remote_addr</strong></td><td>#encodeForHTML(cgi.remote_addr ?: "")#</td></tr>
			</tbody>
		</table>
	</div>
</cfoutput>

</ft:form>

<cfsetting enablecfoutputonly="false">
