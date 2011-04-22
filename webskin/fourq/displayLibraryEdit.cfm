<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: library summary --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- @@cacheStatus:-1 --->

<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset request.fc.bShowTray = false />
<skin:loadJS id="jquery" />


<!------------------ 
START WEBSKIN
 ------------------>
<cfif application.fapi.isLoggedIn()>
	
	<cfparam name="url.property" type="string" />
	<cfparam name="url.editID" type="string" />
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
		
	<cfset stOnExit = structNew() />
	<cfset stOnExit.type = "HTML" />
	<cfsavecontent variable="stOnExit.content">
	<cfoutput>
	<script type="text/javascript">
	$j(function() {
		parent.$j('###stobj.typename##stobj.objectid##url.property#').dialog('close');	
	});
	</script>
	</cfoutput>
	</cfsavecontent>
			
	<cfset type = application.fapi.findType("#url.editID#") />
	<cfset oType = application.fapi.getContentType(type) />		
	<cfset html = oType.getView(objectID="#url.editID#", webskin="libraryEdit", onExitProcess="#stOnExit#", alternateHTML="", bIgnoreSecurity="true") />
	
	<cfif len(html)>
		<cfoutput>#html#</cfoutput>
	<cfelse>
		<admin:Header Title="Library" />
			<cfset html = oType.getView(objectID="#url.editID#", webskin="edit", onExitProcess="#stOnExit#", alternateHTML="", bIgnoreSecurity="true") />
			<cfif len(html)>
				<cfoutput>#html#</cfoutput>
			<cfelse>
				<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
				<cfinvoke component="#oType#" method="edit">
					<cfinvokeargument name="objectId" value="#url.editID#" />
					<cfinvokeargument name="onExitProcess" value="#stOnExit#" />
				</cfinvoke>
			</cfif>
		<admin:footer />
	</cfif>
		
	
	<skin:onReady>
	<cfoutput>
	parent.$j('###stobj.typename##stobj.objectid##url.property#').dialog('option', 'title', 'Edit #application.fapi.getContentTypeMetadata(type, 'displayName', type)#');
	</cfoutput>
	</skin:onReady>
</cfif>

<cfsetting enablecfoutputonly="false">