<cfcomponent displayname="Logging" hint="Diagnostic logging settings that control how much framework activity is logged and where it is written." extends="forms" output="false" key="logger">

	<cfproperty name="logLevel" type="string" default="information"
		ftSeq="1" ftFieldset="Diagnostic Logging" ftLabel="Minimum log level"
		ftType="list" ftList="trace:Trace,debug:Debug,information:Information,warning:Warning,error:Error" ftDefault="information"
		ftHint="Events below this level are dropped (a cheap no-op). 'information' shows lifecycle and integration events; 'debug' is verbose; 'trace' is the most verbose (adds timing spans and hot-path detail)." />

	<cfproperty name="logSink" type="string" default="file"
		ftSeq="2" ftFieldset="Diagnostic Logging" ftLabel="Output sink"
		ftType="list" ftList="file:Log file (one per category),stdout:Standard out / err (containers)" ftDefault="file"
		ftHint="'file' writes a cflog file named by category. 'stdout' emits to the console / stderr so docker logs and CloudWatch can see it (works on both Lucee and ACF; falls back to a file only if the console handle is unavailable)." />

	<cfproperty name="logFormat" type="string" default="text"
		ftSeq="3" ftFieldset="Diagnostic Logging" ftLabel="Output format"
		ftType="list" ftList="text:Human (logfmt),json:Structured JSON (one object per line)" ftDefault="text"
		ftHint="'text' is human-readable and greppable. 'json' is one structured object per line for log processors. The startup banner only prints under 'text'." />

	<cfproperty name="bLogRequests" type="boolean" default="false"
		ftSeq="4" ftFieldset="Diagnostic Logging" ftLabel="Log each request"
		ftType="boolean"
		ftHint="When on, emits one diagnostic line per request (method, path, status, duration). Off by default (the highest-volume seam) - useful in local dev and as a lightweight container access log." />

	<cfproperty name="bLogColor" type="boolean" default="false"
		ftSeq="5" ftFieldset="Diagnostic Logging" ftLabel="Colour-code the console"
		ftType="boolean"
		ftHint="When on, colours request status and method (and highlights warning/error lines) with ANSI codes for terminal viewing. Only applies to the standard out / err sink; leave off when logs are written to files or shipped to CloudWatch, where the codes would show as raw characters." />

	<cfproperty name="slowRequestMs" type="numeric" default="5000"
		ftSeq="6" ftFieldset="Diagnostic Logging" ftLabel="Slow request threshold (ms)"
		ftType="integer"
		ftHint="Requests slower than this are shown in seconds and coloured red in the request log. Default 5000 (5 seconds)." />

</cfcomponent>
