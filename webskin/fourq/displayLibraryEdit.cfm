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

<cfset request.fc.inwebtop = true />
<cfset request.fc.bShowTray = false />
<skin:loadJS id="fc-jquery" />


<!------------------ 
START WEBSKIN
 ------------------>
<cfif application.fapi.isLoggedIn()>
	
	<cfparam name="url.property" type="string" />
	<cfparam name="url.editID" type="string" />
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
	<cfset stMetadata = application.fapi.getFormtool(stMetadata.type).prepMetadata(stObject = stobj, stMetadata = stMetadata) />

	<cfset stOnExit = structNew() />
	<cfset stOnExit.type = "HTML" />
	<cfsavecontent variable="stOnExit.content">
	<cfoutput>
	<script type="text/javascript">
	$j(function() {
		$fc.closeBootstrapModal();
	});
	</script>
	</cfoutput>
	</cfsavecontent>
			
	<cfset type = application.fapi.findType("#url.editID#") />
	<cfset oType = application.fapi.getContentType(type) />		
	<cfset html = oType.getView(objectID="#url.editID#", webskin="libraryEdit", onExitProcess="#stOnExit#", alternateHTML="", bIgnoreSecurity="true") />
	
	<admin:Header Title="Library" />
		<cfif len(html)>
			<cfoutput>#html#</cfoutput>
		<cfelse>
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
		</cfif>
	<admin:footer />
		
	
	<skin:onReady>
	<cfoutput>
	parent.$j('###stobj.typename##stobj.objectid##url.property#').dialog('option', 'title', 'Edit #application.fapi.getContentTypeMetadata(type, 'displayName', type)#');
	</cfoutput>
	</skin:onReady>
</cfif>

<cfsetting enablecfoutputonly="false">