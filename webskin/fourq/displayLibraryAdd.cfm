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



<cfset request.fc.inwebtop = true />
<cfset request.fc.bShowTray = false />
<skin:loadJS id="fc-jquery" />


<!------------------ 
START WEBSKIN
 ------------------>
<cfif application.fapi.isLoggedIn()>
	
	<cfparam name="url.property" type="string" />
	<cfparam name="url.filterTypename" type="string" default="" />
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
	<cfset stMetadata = application.fapi.getFormtool(stMetadata.type).prepMetadata(stObject = stobj, stMetadata = stMetadata) />

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
	<cfset stOnExit = structNew() />
	<cfset stOnExit.type = "HTML" />
	<cfset formHiddenInputName = "fc#replace(stobj.objectid,"-","","all")##url.property#">
	<ft:processForm action="Save">
		<ft:processFormObjects typename="#url.filterTypename#">
			<cfset newLibraryObjectID = stproperties.objectid />
		</ft:processFormObjects>
		
		<!------------------------ 
		SETUP THE EXIT PROCESS 
		--------------------------->
		<cfsavecontent variable="stOnExit.content"><cfoutput>
			<script type="text/javascript">
				$j(function() {
					$j.ajax({
						cache: false,
						type: "POST",
			 			url: '#application.fapi.getWebroot()#/index.cfm?ajaxmode=1&type=#stobj.typename#&objectid=#stobj.objectid#&view=displayAjaxUpdateJoin&property=#url.property#',
						data: {addID: '#newLibraryObjectID#'},
						dataType: "html",
						complete: function(data){
							<cfif stMetadata.ftSelectMultiple>
								$j('###formHiddenInputName#', parent.document).val($j('###formHiddenInputName#', parent.document).val() + ',#newLibraryObjectID#');
							<cfelse>
								$j('###formHiddenInputName#', parent.document).val('#newLibraryObjectID#');
							</cfif>
							$fc.closeBootstrapModal();
						}
					});		
				});
			</script>
		</cfoutput></cfsavecontent>
	</ft:processForm>	
	<wiz:processWizard action="Save">
		<wiz:processWizardObjects typename="#url.filterTypename#">
			<cfset newLibraryObjectID = stproperties.objectid />
		</wiz:processWizardObjects>
		
		<!------------------------ 
		SETUP THE EXIT PROCESS 
		--------------------------->
		<cfsavecontent variable="stOnExit.content"><cfoutput>
			<script type="text/javascript">
				$j(function() {
					$j.ajax({
						cache: false,
						type: "POST",
			 			url: '#application.fapi.getWebroot()#/index.cfm?ajaxmode=1&type=#stobj.typename#&objectid=#stobj.objectid#&view=displayAjaxUpdateJoin&property=#url.property#',
						data: {addID: '#newLibraryObjectID#'},
						dataType: "html",
						complete: function(data){
							<cfif stMetadata.ftSelectMultiple>
								$j('###formHiddenInputName#', parent.document).val($j('###formHiddenInputName#', parent.document).val() + ',#newLibraryObjectID#');
							<cfelse>
								$j('###formHiddenInputName#', parent.document).val('#newLibraryObjectID#');
							</cfif>
							$fc.closeBootstrapModal();
						}
					});		
				});
			</script>
		</cfoutput></cfsavecontent>
	</wiz:processWizard>
	 
	<ft:processForm action="Cancel">
		<!------------------------ 
		SETUP THE EXIT PROCESS 
		--------------------------->
		<cfsavecontent variable="stOnExit.content"><cfoutput>
			<script type="text/javascript">
				$fc.closeBootstrapModal();
			</script>
		</cfoutput></cfsavecontent>
	</ft:processForm>
	<wiz:processWizard action="Cancel">
		<!------------------------ 
		SETUP THE EXIT PROCESS 
		--------------------------->
		<cfsavecontent variable="stOnExit.content"><cfoutput>
			<script type="text/javascript">
				$fc.closeBootstrapModal();
			</script>
		</cfoutput></cfsavecontent>
	</wiz:processWizard>
	 
	<cfif not len(newLibraryObjectID)>
		<cfset stNewObject = application.fapi.getNewContentObject(typename="#url.filterTypename#", key="newLibraryObject") />
		<cfset newLibraryObjectID = stNewObject.objectid />
	</cfif>

			
			
	<!------------------------------ 
	CALL THE RELEVENT EDIT PROCESS
	 ------------------------------>
	<cfset oType = application.fapi.getContentType("#url.filterTypename#") />		
	<cfset html = oType.getView(objectID="#newLibraryObjectID#", webskin="libraryAdd", onExitProcess="#stOnExit#", alternateHTML="", bIgnoreSecurity="true") />
	
	<admin:Header Title="Library" />
		<cfif len(html)>
			<cfoutput>#html#</cfoutput>
		<cfelse>
			<cfset html = oType.getView(objectID="#newLibraryObjectID#", webskin="edit", onExitProcess="#stOnExit#", alternateHTML="", bIgnoreSecurity="true") />
			<cfif len(html)>
				<cfoutput>#html#</cfoutput>
			<cfelse>
				<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
				<cfinvoke component="#oType#" method="edit">
					<cfinvokeargument name="objectId" value="#newLibraryObjectID#" />
					<cfinvokeargument name="onExitProcess" value="#stOnExit#" />
				</cfinvoke>
			</cfif>
		</cfif>
	<admin:footer />
	
	<!-------------------------------------------------- 
	RENAME THE DIALOG WINDOW WITH THE CURRENT TYPENAME
	 -------------------------------------------------->	
	<skin:onReady>
	<cfoutput>
	$fc.changeBootstrapModalTitle("Add New #application.fapi.getContentTypeMetadata(url.filterTypename, 'displayName', url.filterTypename)#");
	</cfoutput>
	</skin:onReady>

</cfif>

<cfsetting enablecfoutputonly="false">