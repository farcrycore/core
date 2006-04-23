
<cfcomponent extends="types" displayname="dmCSS handler " hint="CSS objects influence the look and feel of the website">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="string" hint="Meaningful reference title for file" required="no" default=""> 
<cfproperty name="filename" type="string" hint="The name of the CSS file to be used" required="no" default="">  
<cfproperty name="description" type="string" hint="A description of the file to be uploaded" required="No" default=""> 

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmCSS/edit.cfm">
</cffunction>
	
</cfcomponent>