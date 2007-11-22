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
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs" />

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Scaffold</title>
	<!-- Source File -->
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.3.0/build/reset-fonts-grids/reset-fonts-grids.css">
	
	<style type="text/css">
		body {text-align:left;}
		<cfif structkeyexists(url,"iframe")>
			body { background:transparent url(#application.url.farcry#/admin/js/ext/resources/images/default/layout/gradient-bg.gif) repeat scroll 0%; }
		</cfif>
		
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
	</style>
</head>
<body>

</cfoutput>

<ft:form action="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#">
	
	<extjs:tab title="Type administration">
		<ft:processForm action="Create">
			
			<extjs:tabPanel title="Results">
				<cfinclude template="scaffolds/typeadmin/process.cfm" />
				<cfinclude template="scaffolds/webskins/process.cfm" />
				<cfinclude template="scaffolds/rule/process.cfm" />
				<cfinclude template="scaffolds/permissions/process.cfm" />
			</extjs:tabPanel>
		
		</ft:processForm>
		<extjs:tabPanel title="Administration">
			<cfinclude template="scaffolds/typeadmin/ui.cfm" />
		</extjs:tabPanel>
		<extjs:tabPanel title="Webskins">
			<cfinclude template="scaffolds/webskins/ui.cfm" />
		</extjs:tabPanel>
		<extjs:tabPanel title="Rules">
			<cfinclude template="scaffolds/rule/ui.cfm" />
		</extjs:tabPanel>
		<extjs:tabPanel title="Permissions">
			<cfinclude template="scaffolds/permissions/ui.cfm" />
		</extjs:tabPanel>
	</extjs:tab>
	
	
	
	<ft:farcryButtonPanel>
		<ft:farcryButton value="Create" />
		<cfif structkeyexists(url,"iframe")>
			<ft:farcryButton value="Close" onclick="parent.closeDialog();return false;" />
		</cfif>
	</ft:farcryButtonPanel>

</ft:form>

<cfoutput>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false" />