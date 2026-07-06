<cfcomponent displayname="FarCry Diagnostic Logger" output="false"
	hint="FRAMEWORK DIAGNOSTIC logging lane ONLY: 'what is the framework doing' (debug/information/warning/error + structured context, ephemeral observability). NOT exception handling (lib/error.cfc), NOT the audit trail (farcry:logevent / farLog), NOT prescriptive about application logging. Human-readable via cflog today; flips to structured JSON on stdout/stderr via config, with no call-site change.">
<!--- @@Copyright: Daemon Pty Limited 2002-2009, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->

	<cffunction name="init" access="public" returntype="logger" output="false" hint="Constructor. Reads NO config here (project config loads after lib wiring); captures engine capability only.">
		<cfset variables.levelRanks = { "debug"=10, "information"=20, "warning"=30, "error"=40 } />
		<cfset variables.reservedKeys = "ts,level,category,msg,app" />
		<cfset variables.maxFieldLen = 8192 />
		<!--- console writer per engine: lucee has systemOutput (writes the real console stream, bypassing any wrapped System.out); acf has no systemOutput, so use java System.out/System.err there --->
		<cfset variables.hasSystemOutput = structKeyExists(server, "lucee") />
		<cfset variables.javaSystem = "" />
		<cfset variables.hasJavaConsole = false />
		<cfif not variables.hasSystemOutput>
			<cftry>
				<cfset variables.javaSystem = createObject("java", "java.lang.System") />
				<cfset variables.hasJavaConsole = true />
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<cfreturn this />
	</cffunction>

	<!--- PUBLIC API //////////////////////////////////////// --->

	<cffunction name="logEvent" access="public" returntype="void" output="false" hint="Emit one framework diagnostic event. category is the log target/area, level is debug|information|warning|error, stFields is a struct of structured context.">
		<cfargument name="category" type="string" required="true" />
		<cfargument name="level" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="stFields" type="struct" required="false" default="#structNew()#" />

		<cfscript>
			var normLevel = normaliseLevel(arguments.level);
			var event = "";
			var sink = "";
			var format = "";
			var rendered = "";

			// cheap no-op below threshold: a dropped debug call costs only this comparison
			if (levelRank(normLevel) lt levelRank(effectiveLevel())) {
				return;
			}

			event = buildEvent(arguments.category, normLevel, arguments.message, arguments.stFields);
			maskEvent(event);

			sink = lcase(resolveSetting("logSink", "file"));
			format = lcase(resolveSetting("logFormat", "text"));
			rendered = (format eq "json") ? renderJSON(event) : renderText(event);

			// logging must never break a request
			try {
				if (sink eq "stdout") {
					writeStream(event, rendered);
				} else {
					writeCflog(event, rendered);
				}
			} catch (any e) {}
		</cfscript>
	</cffunction>

	<cffunction name="debug" access="public" returntype="void" output="false" hint="Log at debug level.">
		<cfargument name="category" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="stFields" type="struct" required="false" default="#structNew()#" />
		<cfset logEvent(arguments.category, "debug", arguments.message, arguments.stFields) />
	</cffunction>

	<cffunction name="info" access="public" returntype="void" output="false" hint="Log at information level.">
		<cfargument name="category" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="stFields" type="struct" required="false" default="#structNew()#" />
		<cfset logEvent(arguments.category, "information", arguments.message, arguments.stFields) />
	</cffunction>

	<cffunction name="warning" access="public" returntype="void" output="false" hint="Log at warning level.">
		<cfargument name="category" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="stFields" type="struct" required="false" default="#structNew()#" />
		<cfset logEvent(arguments.category, "warning", arguments.message, arguments.stFields) />
	</cffunction>

	<cffunction name="error" access="public" returntype="void" output="false" hint="Log at error level.">
		<cfargument name="category" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="stFields" type="struct" required="false" default="#structNew()#" />
		<cfset logEvent(arguments.category, "error", arguments.message, arguments.stFields) />
	</cffunction>

	<cffunction name="banner" access="public" returntype="void" output="false" hint="Prints the FarCry Core startup splash to stdout. Human-only: text mode (and Lucee) only; suppressed under json (the 'app' started event carries the version instead).">
		<cfscript>
			var coreVer = "";
			var engineStr = "";
			var host = "";
			var appName = structKeyExists(application, "applicationname") ? application.applicationname : "";
			var nl = chr(10);
			var dq = chr(34);
			var sep = "  -  ";
			var art = "";
			var oneliner = "";

			// human courtesy only - json and container logging get the started event instead
			if (lcase(resolveSetting("logFormat", "text")) eq "json") {
				return;
			}
			if (not variables.hasSystemOutput and not variables.hasJavaConsole) {
				return;
			}

			try {
				if (structKeyExists(application, "sysInfo")) {
					if (structKeyExists(application.sysInfo, "version")) { coreVer = application.sysInfo.version.string; }
					if (structKeyExists(application.sysInfo, "engine")) { engineStr = application.sysInfo.engine.string; }
					if (structKeyExists(application.sysInfo, "machineName")) { host = application.sysInfo.machineName; }
				}
			} catch (any e) {}

			art = " ___          ___             ___" & nl
			    & "| __|_ _ _ _ / __|_ _ _  _   / __|___ _ _ ___" & nl
			    & "| _/ _` | '_| (__| '_| || | | (__/ _ \ '_/ -_)" & nl
			    & "|_|\__,_|_|  \___|_|  \_, |  \___\___/_| \___|" & nl
			    & "                      |__/";

			oneliner = " " & (len(coreVer) ? coreVer : "FarCry Core");
			if (len(engineStr)) { oneliner &= " on " & engineStr; }
			if (len(appName)) { oneliner &= sep & "app " & dq & appName & dq; }
			if (len(host)) { oneliner &= " @ " & host; }
			oneliner &= sep & "starting up...";

			try {
				// banner to the console with a trailing newline; lucee via systemOutput, acf via java System.out
				if (variables.hasSystemOutput) {
					systemOutput(nl & art & nl & oneliner, true, false);
				} else {
					variables.javaSystem.out.println(nl & art & nl & oneliner);
				}
			} catch (any e) {}
		</cfscript>
	</cffunction>

	<!--- INTERNALS /////////////////////////////////////////// --->

	<cffunction name="buildEvent" access="private" returntype="struct" output="false" hint="Normalise one event once; defensively copy the caller's fields.">
		<cfargument name="category" type="string" required="true" />
		<cfargument name="level" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="stFields" type="struct" required="true" />
		<cfscript>
			var event = {};
			event["timestamp"] = "";
			try { event["timestamp"] = application.fapi.dateToISO8601(now()); } catch (any e) {}
			event["level"] = arguments.level;
			event["category"] = sanitiseCategory(arguments.category);
			event["message"] = stripNewlines(arguments.message);
			event["app"] = structKeyExists(application, "applicationname") ? application.applicationname : "";
			event["fields"] = duplicate(arguments.stFields);
			return event;
		</cfscript>
	</cffunction>

	<cffunction name="maskEvent" access="private" returntype="void" output="false" hint="Redact sensitive field values and scrub credential URLs, once, before both renderers. Mutates the event.">
		<cfargument name="event" type="struct" required="true" />
		<cfscript>
			var k = "";
			for (k in arguments.event.fields) {
				if (isSensitiveKey(k)) {
					arguments.event.fields[k] = "STRIPPED";
				} else if (isSimpleValue(arguments.event.fields[k]) and not isNumeric(arguments.event.fields[k]) and not isBoolean(arguments.event.fields[k])) {
					// only strings can carry a credential url - leave numerics and booleans typed for json
					arguments.event.fields[k] = scrubCredentials(arguments.event.fields[k]);
				}
			}
			arguments.event.message = scrubCredentials(arguments.event.message);
		</cfscript>
	</cffunction>

	<cffunction name="renderText" access="private" returntype="string" output="false" hint="logfmt: free-text message, then envelope + alpha-sorted field key=value pairs.">
		<cfargument name="event" type="struct" required="true" />
		<cfscript>
			var out = "";
			var keys = "";
			var k = "";
			// request events get a fixed-width pipe-delimited console line instead of logfmt
			if (arguments.event.category eq "request") {
				return "[FC] " & renderRequestLine(arguments.event.fields);
			}
			out = arguments.event.message;
			keys = structKeyArray(arguments.event.fields);
			out &= " " & logfmtPair("ts", arguments.event.timestamp);
			out &= " " & logfmtPair("level", arguments.event.level);
			out &= " " & logfmtPair("category", arguments.event.category);
			out &= " " & logfmtPair("app", arguments.event.app);
			arraySort(keys, "textnocase");
			for (k in keys) {
				out &= " " & logfmtPair(k, arguments.event.fields[k]);
			}
			if (colorEnabled()) {
				out = ansi(out, levelColor(arguments.event.level));
			}
			return "[FC] " & out;
		</cfscript>
	</cffunction>

	<cffunction name="renderRequestLine" access="private" returntype="string" output="false" hint="fixed-width console line for request events - code | time | method | url | other. columns are padded so the url starts at a consistent column.">
		<cfargument name="fields" type="struct" required="true" />
		<cfscript>
			var f = arguments.fields;
			var st = structKeyExists(f, "status") ? toString(f.status) : "---";
			var dms = (structKeyExists(f, "durationMs") and isNumeric(f.durationMs)) ? f.durationMs : -1;
			var isSlow = (dms gte 0) and (dms gt slowRequestThreshold());
			// fast requests read in ms; slow ones (over the threshold) read in seconds
			var dur = (dms lt 0) ? "?ms" : (isSlow ? numberFormat(dms / 1000, "0.0") & "s" : dms & "ms");
			var meth = structKeyExists(f, "method") ? stripNewlines(toString(f.method)) : "";
			var pth = structKeyExists(f, "path") ? stripNewlines(toString(f.path)) : "";
			var useColor = colorEnabled();
			// justify the plain text first, then wrap in colour, so the ansi codes never break the column widths
			var stCol = useColor ? ansi(rJustify(st, 3), statusColor(st)) : rJustify(st, 3);
			var durCol = (useColor and isSlow) ? ansi(rJustify(dur, 6), "31") : rJustify(dur, 6);
			// method left-justified to 6 doubles as the gap before the url - no separating pipe needed
			var methCol = useColor ? ansi(lJustify(meth, 6), methodColor(meth)) : lJustify(meth, 6);
			var line = stCol & " | " & durCol & " | " & methCol & pth;
			var extra = "";
			var k = "";
			var keys = structKeyArray(f);
			// any fields beyond the four known columns become the trailing "other" segment
			arraySort(keys, "textnocase");
			for (k in keys) {
				if (not listFindNoCase("status,durationMs,method,path", k)) {
					extra = listAppend(extra, logfmtPair(k, f[k]), " ");
				}
			}
			if (len(extra)) {
				line &= " | " & extra;
			}
			return line;
		</cfscript>
	</cffunction>

	<cffunction name="renderJSON" access="private" returntype="string" output="false" hint="Flat JSON object, one line. Ordered quoted-key literal + bracket assignment keep keys lowercase on Lucee.">
		<cfargument name="event" type="struct" required="true" />
		<cfscript>
			var out = [ "ts": arguments.event.timestamp, "level": arguments.event.level, "category": arguments.event.category, "msg": arguments.event.message, "app": arguments.event.app ];
			var keys = structKeyArray(arguments.event.fields);
			var k = "";
			var lk = "";
			arraySort(keys, "textnocase");
			for (k in keys) {
				lk = lcase(k);
				// never let a field overwrite an envelope key
				if (listFindNoCase(variables.reservedKeys, lk)) {
					lk = "field_" & lk;
				}
				out[lk] = arguments.event.fields[k];
			}
			return serializeJSON(out);
		</cfscript>
	</cffunction>

	<cffunction name="logfmtPair" access="private" returntype="string" output="false" hint="One logfmt key=value pair; quotes values containing space, =, quote or backslash.">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="value" type="any" required="true" />
		<cfscript>
			var k = lcase(reReplace(arguments.key, "[^A-Za-z0-9_.]", "_", "all"));
			var v = stringifyValue(arguments.value);
			if (v eq "" or reFind('[ ="\\]', v) gt 0) {
				v = dq() & replace(replace(v, "\", "\\", "all"), dq(), "\" & dq(), "all") & dq();
			}
			return k & "=" & v;
		</cfscript>
	</cffunction>

	<cffunction name="stringifyValue" access="private" returntype="string" output="false" hint="Render a field value to a single greppable line; complex values via serializeJSON; soft-cap length.">
		<cfargument name="value" type="any" required="true" />
		<cfscript>
			var s = "";
			if (isSimpleValue(arguments.value)) {
				s = toString(arguments.value);
			} else {
				s = serializeJSON(arguments.value);
			}
			s = stripNewlines(s);
			if (len(s) gt variables.maxFieldLen) {
				s = left(s, variables.maxFieldLen) & "...[truncated " & (len(s) - variables.maxFieldLen) & " chars]";
			}
			return s;
		</cfscript>
	</cffunction>

	<cffunction name="writeCflog" access="private" returntype="void" output="false" hint="File sink: one file per category, app name as a field (application='true').">
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="line" type="string" required="true" />
		<cfset var cflogType = (arguments.event.level eq "debug") ? "information" : arguments.event.level />
		<cflog file="#arguments.event.category#" application="true" type="#cflogType#" text="#arguments.line#" />
	</cffunction>

	<cffunction name="writeStream" access="private" returntype="void" output="false" hint="stdout/stderr sink: lucee via systemOutput (writes the real console stream, errors to stderr); acf has no systemOutput, so java System.out/System.err. Falls back to a cflog file if neither is available.">
		<cfargument name="event" type="struct" required="true" />
		<cfargument name="line" type="string" required="true" />
		<cftry>
			<cfif variables.hasSystemOutput>
				<!--- lucee: systemOutput(obj, addNewLine, doErrorStream) - newline per event, errors to stderr --->
				<cfset systemOutput(arguments.line, true, (arguments.event.level eq "error")) />
			<cfelseif variables.hasJavaConsole>
				<!--- acf: no systemOutput; java System.out/System.err keeps the stdout/stderr split --->
				<cfif arguments.event.level eq "error">
					<cfset variables.javaSystem.err.println(arguments.line) />
				<cfelse>
					<cfset variables.javaSystem.out.println(arguments.line) />
				</cfif>
			<cfelse>
				<cfset writeCflog(arguments.event, arguments.line) />
			</cfif>
			<cfcatch type="any">
				<cfset writeCflog(arguments.event, arguments.line) />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="effectiveLevel" access="private" returntype="string" output="false" hint="The current global minimum level.">
		<cfreturn normaliseLevel(resolveSetting("logLevel", "information")) />
	</cffunction>

	<cffunction name="normaliseLevel" access="private" returntype="string" output="false" hint="Lowercase + alias (info->information, warn->warning); unknown->information.">
		<cfargument name="level" type="string" required="true" />
		<cfscript>
			var l = lcase(trim(arguments.level));
			if (l eq "info") { return "information"; }
			if (l eq "warn") { return "warning"; }
			if (structKeyExists(variables.levelRanks, l)) { return l; }
			return "information";
		</cfscript>
	</cffunction>

	<cffunction name="levelRank" access="private" returntype="numeric" output="false">
		<cfargument name="level" type="string" required="true" />
		<cfscript>
			var l = lcase(trim(arguments.level));
			return structKeyExists(variables.levelRanks, l) ? variables.levelRanks[l] : 20;
		</cfscript>
	</cffunction>

	<cffunction name="resolveSetting" access="private" returntype="string" output="false" hint="live logger setting via getConfig - read each call so admin and env changes apply without an app reload. never throws; falls back to the default during the bootstrap window before config loads.">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="default" type="string" required="true" />
		<cfscript>
			var val = arguments.default;
			try {
				if (structKeyExists(application, "fapi")) {
					val = application.fapi.getConfig("logger", arguments.name, arguments.default);
				}
			} catch (any e) {
				val = arguments.default;
			}
			if (not len(trim(val))) {
				val = arguments.default;
			}
			return val;
		</cfscript>
	</cffunction>

	<cffunction name="isSensitiveKey" access="private" returntype="boolean" output="false" hint="True if a field key name looks like a secret.">
		<cfargument name="key" type="string" required="true" />
		<cfreturn reFindNoCase("(secret|sessiontoken|accesskey|password|authorization|token)", arguments.key) gt 0 />
	</cffunction>

	<cffunction name="scrubCredentials" access="private" returntype="string" output="false" hint="Strip inline s3://key:secret@ / ftp://user:pass@ credentials before logging.">
		<cfargument name="text" type="string" required="true" />
		<cfreturn reReplaceNoCase(arguments.text, "(s3|ftp)://[^:@/\s]+:[^@/\s]+@", "\1://STRIPPED:STRIPPED@", "all") />
	</cffunction>

	<cffunction name="sanitiseCategory" access="private" returntype="string" output="false" hint="Lowercase + safe charset; the category is used as a log filename.">
		<cfargument name="category" type="string" required="true" />
		<cfreturn lcase(reReplace(arguments.category, "[^A-Za-z0-9_]", "_", "all")) />
	</cffunction>

	<cffunction name="stripNewlines" access="private" returntype="string" output="false" hint="Collapse CR/LF so one event stays one line.">
		<cfargument name="text" type="string" required="true" />
		<cfreturn reReplace(arguments.text, "[#chr(13)##chr(10)#]+", " ", "all") />
	</cffunction>

	<cffunction name="dq" access="private" returntype="string" output="false" hint="A literal double-quote.">
		<cfreturn chr(34) />
	</cffunction>

	<!--- ansi colour helpers - opt-in via bLogColor, and only on the stdout sink so escape codes never land in a cflog file --->

	<cffunction name="colorEnabled" access="private" returntype="boolean" output="false" hint="true when bLogColor is on and the sink is stdout.">
		<cfset var v = resolveSetting("bLogColor", "false") />
		<cfreturn (isBoolean(v) and v) and (lcase(resolveSetting("logSink", "file")) eq "stdout") />
	</cffunction>

	<cffunction name="ansi" access="private" returntype="string" output="false" hint="wrap text in an ansi colour code; an empty code returns the text unchanged.">
		<cfargument name="text" type="string" required="true" />
		<cfargument name="code" type="string" required="true" />
		<cfif not len(arguments.code)>
			<cfreturn arguments.text />
		</cfif>
		<cfreturn chr(27) & "[" & arguments.code & "m" & arguments.text & chr(27) & "[0m" />
	</cffunction>

	<cffunction name="statusColor" access="private" returntype="string" output="false" hint="ansi code by http status class - 2xx green, 3xx cyan, 4xx yellow, 5xx red.">
		<cfargument name="status" type="string" required="true" />
		<cfset var c = left(trim(arguments.status), 1) />
		<cfif c eq "2"><cfreturn "32" /></cfif>
		<cfif c eq "3"><cfreturn "36" /></cfif>
		<cfif c eq "4"><cfreturn "33" /></cfif>
		<cfif c eq "5"><cfreturn "31" /></cfif>
		<cfreturn "" />
	</cffunction>

	<cffunction name="methodColor" access="private" returntype="string" output="false" hint="ansi code by http method, following gin's scheme.">
		<cfargument name="method" type="string" required="true" />
		<cfswitch expression="#ucase(trim(arguments.method))#">
			<cfcase value="GET"><cfreturn "34" /></cfcase>
			<cfcase value="POST"><cfreturn "36" /></cfcase>
			<cfcase value="PUT"><cfreturn "33" /></cfcase>
			<cfcase value="DELETE"><cfreturn "31" /></cfcase>
			<cfcase value="PATCH"><cfreturn "32" /></cfcase>
			<cfcase value="HEAD"><cfreturn "35" /></cfcase>
			<cfdefaultcase><cfreturn "37" /></cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="levelColor" access="private" returntype="string" output="false" hint="ansi code by level - error red, warning yellow, otherwise none.">
		<cfargument name="level" type="string" required="true" />
		<cfif arguments.level eq "error"><cfreturn "31" /></cfif>
		<cfif arguments.level eq "warning"><cfreturn "33" /></cfif>
		<cfreturn "" />
	</cffunction>

	<cffunction name="slowRequestThreshold" access="private" returntype="numeric" output="false" hint="ms above which a request is flagged slow - shown in seconds and coloured red. set via logger.slowRequestMs, default 5000.">
		<cfset var v = resolveSetting("slowRequestMs", "5000") />
		<cfreturn (isNumeric(v) and v gt 0) ? v : 5000 />
	</cffunction>

</cfcomponent>
