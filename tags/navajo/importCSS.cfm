<!--- 
importCSS
tag for importing all CSS stylesheet objects for an object based on 
its navigation node 
--->
<cfsetting enablecfoutputonly="yes">
<!--- get style sheets --->
<cfif IsDefined("request.navid")>
<cfscript>
// get navigation elements to root
o = createObject("component", "fourq.utils.tree.tree");
qAncestors = o.getAncestors(objectid=request.navid);
// loop through and determine which ones have CSS objects
</cfscript>

<cfquery datasource="#application.dsn#" name="qCSS">
SELECT dmCSS.objectid, dmCSS.filename
FROM dmCSS, dmNavigation_aObjectIDs
WHERE 
	dmCSS.objectid = dmNavigation_aObjectIDs.data
	AND dmNavigation_aObjectIDs.objectid IN (#quotedValueList(qAncestors.objectid)#)
</cfquery>
</cfif>

<cfoutput><script type="text/javascript"> </script>
	<style type="text/css" media="all"></cfoutput>

<cfoutput query="qCSS">
		@import "css/#filename#";
</cfoutput>

<cfoutput>	</style></cfoutput>

<cfsetting enablecfoutputonly="no">
