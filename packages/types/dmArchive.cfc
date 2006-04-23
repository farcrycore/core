
<cfcomponent extends="types" displayname="dmArchive handler" hint="archive objects">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="archiveID" type="UUID" hint="ID of archived entry" required="no" default=""> 
<cfproperty name="objectWDDX" type="longchar" hint="WDDX packet that defines the object being archived" required="no" default="">  

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmArchive/edit.cfm">
</cffunction>
	
</cfcomponent>