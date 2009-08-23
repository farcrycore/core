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

<cfparam name="url.property" type="string" />
	
	<!--- RETRIEVE IT AGAIN...JUST IN CASE THE AJAX CALL WAS RUN HALF WAY THROUGH A PREVIOUS COMMIT. --->
	<cfset stToUpdate = application.fapi.getContentObject(typename="#stobj.typename#",objectid="#stobj.objectid#") />
	

	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stToUpdate.typename#", property="#url.property#") />
	
	<cfset newValue = stToUpdate[url.property] />
		
	<!--- DETERMINE THE SELECTED ITEMS --->
	<cfif stMetadata.type EQ "array">
	
		<cfif structKeyExists(form, "addID")>	
			<cfset arrayAppend(newValue,form.addID) />
		</cfif>
		
		<cfif structKeyExists(form, "detachID")>
			<cfset newValue = application.fapi.arrayRemove(newValue, form.detachID) />
		</cfif>
		
		<cfif structKeyExists(form, "deleteID")>
			<cfset newValue = application.fapi.arrayRemove(newValue, form.deleteID) />
		</cfif>
		
		<cfif structKeyExists(form, "sortIDs")>
			<cfset newValue = listToArray(form.sortIDs) />
		</cfif>
	<cfelse>
	
		<cfif structKeyExists(form, "addID")>	
			<cfset newValue = form.addID />
		</cfif>
		
		<cfif structKeyExists(form, "detachID")>
			<cfset newValue = "" />
		</cfif>
		
		<cfif structKeyExists(form, "deleteID")>
			<cfset newValue = "" />
		</cfif>
		
		<cfif structKeyExists(form, "sortIDs")>
			<cfset newValue = form.sortIDs />
		</cfif>
	</cfif>
	
	<cfif structKeyExists(form, "wizardID") AND len(form.wizardID)>
		<cfset owizard = application.fapi.getContentType("dmWizard") />	
		<cfset stwizard = owizard.Read(wizardID="#form.wizardID#") />
		<cfset stwizard.Data[stToUpdate.objectid][url.property] = newValue />
		<cfset stResult = owizard.Write(objectID="#form.wizardID#", Data="#stwizard.Data#")>
	</cfif>
	
	<cfset stToUpdate[url.property] = newValue />
	
	<cfset stResult = application.fapi.setData(
						stProperties="#stToUpdate#") />
	
	
	<cfif structKeyExists(form, "deleteID")>
		<cfloop list="#form.deleteID#" index="i">
			<cfset deleteType = application.fapi.findType("#i#") />
			<cfset stResult = application.fapi.getContentType(deleteType).delete(objectid="#i#") />
		</cfloop>
	</cfif>
	
	<cfoutput>SUCCESSFUL</cfoutput>
