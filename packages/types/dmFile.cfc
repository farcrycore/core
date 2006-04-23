
<cfcomponent extends="types" displayname="dmFile handler " hint="File objects">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="string" hint="Meaningful reference title for file" required="no" default=""> 
<cfproperty name="filename" type="string" hint="The name of the file to be uploaded" required="no" default="">  
<cfproperty name="filepath" type="string" hint="The location of the file on the webserver" required="no" default="">  
<cfproperty name="description" type="string" hint="A description of the file to be uploaded" required="No" default=""> 
<cfproperty name="status" type="string" hint="Status of file - draft or approved" required="No" default=""> 

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmFile/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmFile/display.cfm">
</cffunction>
	
</cfcomponent>