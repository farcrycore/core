<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Default Friendly URL --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>
<cfif len(stobj.fu)>
	<cfoutput>/#stobj.fu#</cfoutput>
<cfelse>

	<cfset separator = "/" />
	
	<cfif structKeyExists(stObj,'title')>
		<cfset hereText = stObj.title>
	<cfelseif structKeyExists(stObj,'label')>
		<cfset hereText = stObj.label>
	<cfelse>
		<cfset hereText = "">
	</cfif>

	
	<cfset qAncestors = application.factory.oTree.getAncestors(objectid=stobj.objectid) />

	<cfquery dbtype="query" name="qCrumb">
	SELECT * FROM qAncestors
	WHERE nLevel >= 2
	ORDER BY nLevel
	</cfquery>

	
	<!--- output breadcrumb --->
	<cfset iCount = 0>
	
	<cfloop query="qCrumb">
		<cfif iCount LT qCrumb.recordCount><cfoutput>#separator#</cfoutput></cfif>
		<cfoutput>#qCrumb.objectname#</cfoutput>
		<cfset iCount = iCount + 1 />
	</cfloop>
	
		
	<cfoutput>#separator##hereText#</cfoutput>

	
</cfif>
<cfsetting enablecfoutputonly="false" /> 
