<!--- 
<cfparam name="url.libraryType" type="string" /><!--- Can be Array or UUID. If UUID, only 1 value can be stored. --->
<cfparam name="url.PrimaryObjectID" type="UUID" />
<cfparam name="url.PrimaryTypename" type="string" />
<cfparam name="url.PrimaryFieldName" type="string" />
<cfparam name="url.PrimaryFormFieldName" type="string" />
<cfparam name="url.DataObjectID" type="string" /><!--- this could be a UUID to be added or a list of UUID's if we are re-sorting --->
<cfparam name="url.DataTypename" type="string" />
<cfparam name="url.wizardID" type="string" default="" />
<cfparam name="url.Action" type="string" default="Add" />
<cfparam name="url.ftLibrarySelectedWebskin" type="string" default="selected" />
<cfparam name="url.ftLibrarySelectedWebskinListClass" type="string" default="selected" />
<cfparam name="url.ftLibrarySelectedWebskinListStyle" type="string" default="" />
<cfparam name="url.packageType" type="string" default="types" />
 --->


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


	<!--- RETRIEVE IT AGAIN...JUST IN CASE THE AJAX CALL WAS RUN HALF WAY THROUGH A PREVIOUS COMMIT. --->
	<cfset stToUpdate = application.fapi.getContentObject(typename="#stobj.typename#",objectid="#stobj.objectid#") />
	


	<cfparam name="url.property" type="string" />
	
	<cfset stFilter = application.fapi.getContentObject(objectid="#stToUpdate.filterID#", typename="farFilter") />
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stFilter.filterTypename#", property="#stToUpdate.property#") />

	<!--- CONVERT FROM WDDX --->
	<cfif isWDDX(stToUpdate[url.property])>
		<cfwddx	action="wddx2cfml" 
					input="#stToUpdate[url.property]#" 
					output="stProps" />	
	<cfelse>
		<cfset stProps = structNew() />
	</cfif>
	
	
	<!--- DETERMINE THE SELECTED ITEMS --->
	<cfif stMetadata.type EQ "array">
		<cfparam name="stProps.relatedto" default="#arrayNew(1)#" />
		<cfif structKeyExists(form, "addID")>	
			<cfset arrayAppend(stProps.relatedTo,form.addID) />
		</cfif>
		
		<cfif structKeyExists(form, "detachID")>
			<cfset stProps.relatedTo = application.fapi.arrayRemove(stProps.relatedTo, form.detachID) />
		</cfif>
		
		<cfif structKeyExists(form, "deleteID")>
			<cfset stProps.relatedTo = application.fapi.arrayRemove(stProps.relatedTo, form.deleteID) />
		</cfif>
		
		<cfif structKeyExists(form, "sortIDs")>
			<cfset stProps.relatedTo = listToArray(form.sortIDs) />
		</cfif>
	<cfelse>
		<cfparam name="stProps.relatedto" default="" />
		<cfif structKeyExists(form, "addID")>	
			<cfset stProps.relatedTo = form.addID />
		</cfif>
		
		<cfif structKeyExists(form, "detachID")>
			<cfset stProps.relatedTo = "" />
		</cfif>
		
		<cfif structKeyExists(form, "deleteID")>
			<cfset stProps.relatedTo = "" />
		</cfif>
		
		<cfif structKeyExists(form, "sortIDs")>
			<cfset stProps.relatedTo = form.sortIDs />
		</cfif>
	</cfif>
	
	<!--- CONVERT BACK TO WDDX & SAVE --->
	<cfwddx action="cfml2wddx" input="#stProps#" output="newValue" />
	
	<cfset stToUpdate[url.property] = newValue />
	
	<cfset stResult = application.fapi.setData(
						stProperties="#stToUpdate#") />
	

	
	<cfoutput>SUCCESSFUL</cfoutput>
