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
<cfimport taglib="/farcry/core/tags/wizard" prefix="wiz" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />



<cfset request.fc.bShowTray = false />
<skin:loadJS id="jquery" />


<!------------------ 
START WEBSKIN
 ------------------>
<cfif application.fapi.isLoggedIn()>
	
	<cfparam name="url.property" type="string" />
	<cfparam name="url.filterTypename" type="string" default="" />
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
	
	<cfif not len(url.filterTypename)>		
		<cfset url.filterTypename = listFirst(stMetadata.ftJoin) />
	</cfif>
	
	<cfif structKeyExists(form, "filterTypename")>
		<cfset url.filterTypename = form.filterTypename />
	</cfif>
	
	
	
	<!----------------------------------------------------------------------------------------------------------------------------------------------- 
	NEED TO CHECK TO SEE IF WE NEED TO CREATE A NEW CONTENT OBJECT.
	IF THE OBJECT HAS ALREADY BEEN CREATED AND IS NOW BEING SUBMITTED, THEN WE WANT TO CONTINUE TO USE IT.
	THIS SITUATION OCCURS WHEN WE CREATE A NEW OBJECT, BUT THAT OBJECT HAS SUBSEQUENTLY BEEN SAVED TO THE DB BY WAY OF ADDING AN ARRAY OBJECT TO IT.
	 ----------------------------------------------------------------------------------------------------------------------------------------------->	
	<cfset newLibraryObjectID = "" />	
	<ft:processForm>
		<ft:processFormObjects typename="#url.filterTypename#">
			<cfset newLibraryObjectID = stproperties.objectid />
		</ft:processFormObjects>
	</ft:processForm>	
	<wiz:processWizard>
		<wiz:processWizardObjects typename="#url.filterTypename#">
			<cfset newLibraryObjectID = stproperties.objectid />
		</wiz:processWizardObjects>
	</wiz:processWizard>
	 
	<cfif not len(newLibraryObjectID)>
		<cfset stNewObject = application.fapi.getNewContentObject(typename="#url.filterTypename#", key="newLibraryObject") />
		<cfset newLibraryObjectID = stNewObject.objectid />
	</cfif>

	<!------------------------ 
	SETUP THE EXIT PROCESS 
	--------------------------->
	<cfset stOnExit = structNew() />
	<cfset stOnExit.type = "HTML" />
	<cfsavecontent variable="stOnExit.content">
	<cfoutput>
	<script type="text/javascript">
	$j(function() {
		$j.ajax({
			cache: false,
			type: "POST",
 			url: '#application.fapi.getWebroot()#/index.cfm?ajaxmode=1&type=#stobj.typename#&objectid=#stobj.objectid#&view=displayAjaxUpdateJoin&property=#url.property#',
			data: {addID: '#newLibraryObjectID#'},
			dataType: "html",
			complete: function(data){
				parent.$j('###stobj.typename##stobj.objectid##url.property#').dialog('close');
			}
		});		
	});
	</script>
	</cfoutput>
	</cfsavecontent>
			
			
	<!------------------------------ 
	CALL THE RELEVENT EDIT PROCESS
	 ------------------------------>
	<cfset oType = application.fapi.getContentType("#url.filterTypename#") />		
		<cfset html = oType.getView(objectID="#newLibraryObjectID#", webskin="libraryAdd", onExitProcess="#stOnExit#", alternateHTML="", bIgnoreSecurity="true") />
	
	<cfif len(html)>
	    <cfoutput>#html#</cfoutput>
	<cfelse>
		<admin:Header Title="Library">
			<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
		    <cfinvoke component="#oType#" method="edit">
		        <cfinvokeargument name="objectId" value="#newLibraryObjectID#" />
		        <cfinvokeargument name="onExitProcess" value="#stOnExit#" />
		    </cfinvoke>
		<admin:footer>
	</cfif>
	
	<!-------------------------------------------------- 
	RENAME THE DIALOG WINDOW WITH THE CURRENT TYPENAME
	 -------------------------------------------------->	
	<skin:onReady>
	<cfoutput>
	parent.$j('###stobj.typename##stobj.objectid##url.property#').dialog('option', 'title', 'Add New #application.fapi.getContentTypeMetadata(url.filterTypename, 'displayName', url.filterTypename)#');
	</cfoutput>
	</skin:onReady>

</cfif>

<cfsetting enablecfoutputonly="false">