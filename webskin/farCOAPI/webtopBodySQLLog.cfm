<cfsetting enablecfoutputonly="true" requesttimeout="1000" />
<!--- @@displayname: COAPI Overview --->
<!--- @@description: Overview of DB persistent types and any existing conflicts --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.format" default="false" />
<cfparam name="url.clear" default="false" />

<cfif url.clear>
	<cfset application.fc.lib.db.clearLog() />
</cfif>


<skin:htmlHead><cfoutput><style type="text/css">
	##sqllog {}
		.sql { 
			font-family: Consolas, "Andale Mono WT", "Andale Mono", "Lucida Console", "Lucida Sans Typewriter", "DejaVu Sans Mono", "Bitstream Vera Sans Mono", "Liberation Mono", "Nimbus Mono L", Monaco, "Courier New", Courier, monospace;
			padding: 0.4em;
			margin-bottom:10px;
			background-color:##CCCCCC;
			overflow:hidden;
			height: auto;
		}
		.sql.minimized {
			height: 1.5em;
		}
	h1 .options { font-size:65%; font-weight:normal; margin-left:15px; }
</style></cfoutput></skin:htmlHead>
<skin:onReady><cfoutput>
	function selectText(element) {
		var doc = document, range, selection;
		
	    if (doc.body.createTextRange) { //ms
	        range = doc.body.createTextRange();
	        range.moveToElementText(element);
	        range.select();
	    } else if (window.getSelection) { //all others
	        selection = window.getSelection();        
	        range = doc.createRange();
	        range.selectNodeContents(element);
	        selection.removeAllRanges();
	        selection.addRange(range);
	    }
	}
	$j("a.selectall").click(function(){
		selectText($j("##sqllog")[0]);
		return false;
	});
</cfoutput></skin:onReady>

<cfoutput>
	<h1>
		<admin:resource key="webtop.utilities.coapisqllog@title">SQL Log</admin:resource>
		<span class="options">
			<a href="#application.fapi.fixURL(addvalues='clear=1',removevalues='format')#">clear log</a>
			&middot;
			<a href="#application.fapi.fixURL(addvalues='format=#not url.format#',removevalues='clear')#">toggle formatting</a>
			&middot;
			<a href="##selectall" class="selectall">select all</a>
		</span>
	</h1>
	<div id="sqllog">
</cfoutput>

<cftry>
	<cfset aLog = arrayNew(1)>
	<cfset aLog = application.fc.lib.db.getLog(asArray=true) /> --->
	<cfset formatter = createobject("java","org.hibernate.jdbc.util.BasicFormatterImpl").init() />
<cfcatch>
	<cfoutput>
	<div class="alert alert-block alert-error">
		<h4>Log file error!</h4>
		<p><code>#cfcatch.message#</code></p>
		<p>Why not try configuring some SQL tables to log first.</p>
	</div>
	</cfoutput>
</cfcatch>
</cftry>

<cfif url.format>
	<cfset newline = "
" />
	<cfloop from="1" to="#arraylen(aLog)#" index="i">
		<cfoutput><div class="sql">#htmlifyWhitespace(listfirst(aLog[i],newline))##htmlifyWhitespace(application.fc.lib.esapi.encodeForHTML(formatter.format(listrest(aLog[i],newline))))#</div></cfoutput>	
	</cfloop>
<cfelse>
	<cfloop from="1" to="#arraylen(aLog)#" index="i">
		<cfoutput><div class="sql">#htmlifyWhitespace(application.fc.lib.esapi.encodeForHTML(aLog[i]))#</div></cfoutput>	
	</cfloop>
</cfif>

<cfoutput>
	</div>
</cfoutput>

<cffunction name="htmlifyWhitespace">
	<cfargument name="text" />
	
	<cfset var result = arguments.text />
	
	<cfset result = replace(result,chr(10),"<br>","ALL") />
	<cfset result = replace(result,chr(9),"    ","ALL") />
	<cfset result = replace(result," ","&nbsp;","ALL") />
	
	<cfreturn result />
</cffunction>

<cfsetting enablecfoutputonly="false" />