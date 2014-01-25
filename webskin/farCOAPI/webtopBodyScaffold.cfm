<cfsetting enablecfoutputonly="true" />

<cffunction name="substitute" access="public" output="false" returntype="string" hint="Substitutes values in a string">
	<cfargument name="string1" type="string" required="true" />
	<cfargument name="values" type="struct" required="true" />
	<cfargument name="brackets" type="string" required="false" default="[,]">
	
	<cfset var key="" />
	
	<cfloop collection="#arguments.values#" item="key">
		<cfset arguments.string1 = replacenocase(arguments.string1,listfirst(arguments.brackets) & key & listlast(arguments.brackets),arguments.values[key],"ALL") />
	</cfloop>
	
	<cfreturn arguments.string1 />
</cffunction>

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<skin:loadJS id="fc-jquery-ui" />
<skin:loadCSS id="jquery-ui" />

<skin:loadCSS><style type="text/css"><cfoutput>
	body {text-align:left;}
		
	<!--- p {margin:5px 0px 10px 0px;} --->
	/* =DEFINITION LISTS */
	dl {margin: 0 0 1.5em}
	dt {clear:left;font-weight:bold;margin:3px 0}
	dd {margin:3px 0;padding:0}
	dd.thumbnail {float:left;width:100px;margin-right:6px;border: 1px solid ##000;margin-bottom:0}
	dd.thumbnail img {display:block}

	dl.dl-style1 {border-top: 1px solid ##fff;font-size:86%}
	.tab-panes dl.dl-style1 {margin-right:140px}
	dl.dl-style1 dt {float:left;clear:left;width:130px;margin:0;_height:1.5em;min-height:1.5em;border:none;}
	.tab-panes dl.dl-style1 dt {width:28%}
	dl.dl-style1 dd {width: auto;margin: 0;border-bottom: 1px solid ##fff;padding: 1px 0;_height:1.5em;min-height:1.5em}
	.tab-panes dl.dl-style1 dd {margin-left:28%;_margin-left:20%}

	.tab-content {padding:25px;}
	
	.icon {margin: 0 0 10px}

	.webtopOverviewActions {float:right;width:220px;}
	.webtopOverviewActions .farcryButtonWrap-outer {margin-bottom:5px;}
	.webtopOverviewActions .farcryButton {width:200px;}
	
	td { padding: 3px; }
</cfoutput></style></skin:loadCSS>

<skin:onReady><script type="text/javascript"><cfoutput>
	$j("##tabs").tabs();
</cfoutput></script></skin:onReady>

<cfset scaffoldresults = "" />
<ft:processForm action="Create">
	<cfsavecontent variable="scaffoldresults">
		<cfinclude template="scaffolds/typeadmin/process.cfm" />
		<cfinclude template="scaffolds/webskins/process.cfm" />
		<cfinclude template="scaffolds/rule/process.cfm" />
		<cfinclude template="scaffolds/permissions/process.cfm" />
	</cfsavecontent>
</ft:processForm>

<ft:form>
	
	<cfoutput>
		<div id="tabs">	
			<ul>
				<cfif len(scaffoldresults)><li><a href="##results">Results</a></li></cfif>
				<li><a href="##administration">Administration</a></li>
				<li><a href="##webskins">Webskins</a></li>
				<li><a href="##rules">Rules</a></li>
				<li><a href="##permissions">Permissions</a></li>
			</ul>
			<div id="results">#scaffoldresults#</div>
			<div id="administration"><cfinclude template="scaffolds/typeadmin/ui.cfm" /></div>
			<div id="webskins"><cfinclude template="scaffolds/webskins/ui.cfm" /></div>
			<div id="rules"><cfinclude template="scaffolds/rule/ui.cfm" /></div>
			<div id="permissions"><cfinclude template="scaffolds/permissions/ui.cfm" /></div>
		</div>
	</cfoutput>
	
	<ft:buttonPanel>
		<ft:button value="Create" />
		<cfif structkeyexists(url,"iframe")>
			<ft:button value="Close" type="button" onclick="$fc.closeBootstrapModal();return false;" />
		</cfif>
	</ft:buttonPanel>

</ft:form>

<cfsetting enablecfoutputonly="false" />