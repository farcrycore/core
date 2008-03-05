<cfsetting enablecfoutputonly="yes">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<!--- deleteObjects.cfm

Description : 

Deletes single/multiple objects of a particular type. 
Intended for use with daemon dynamic data.

 --->

<cfparam name="attributes.lObjectIDs" default=""> <!--- The list of objects to be deleted - required--->
<cfparam name="attributes.typename" default=""> <!--- the type of object to be deleted - required --->
<cfparam name="attributes.rMsg" default="msg"> <!--- The message returned to the caller - optional --->


<cfif len(attributes.lObjectIDs) eq 0>
	<cfset "caller.#attributes.rMsg#" = "#application.rb.getResource("noObjSelectedForDeletion")#">
	<cfexit>
</cfif>

<!--- Now loop through the list and delete object --->
<cfloop list="#attributes.lObjectIDs#" index="i">
	<q4:contentobjectget objectID="#i#" r_stobject="stObj">
	<cfset errorFlag = false>
	<!--- delete actual file --->
	<cfswitch expression="#attributes.typename#">
		<cfcase value="dmFile">
			<cftry>
				<cffile action="delete" file="#application.path.defaultFilePath#/#stObj.filename#">
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfcase>
		<cfcase value="dmImage">
			<cftry>
				<cffile action="delete" file="#application.path.defaultImagePath#/#stObj.filename#">
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfcase>
	</cfswitch>
	<q4:contentobjectdelete objectID="#i#">
	<cfset "caller.#attributes.rMsg#" = "#application.rb.formatRBString("objectsDeleted",listLen(attributes.lObjectIds))#"> 
</cfloop>




