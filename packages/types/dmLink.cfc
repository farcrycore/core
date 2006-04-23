
<cfcomponent extends="types" displayname="Links" hint="A way of linking to external pages" bSchedule="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="nstring" hint="Meaningful reference title for link" required="no" default=""> 
<cfproperty name="teaser" type="longchar" hint="A brief description of the link" required="no" default="">  
<cfproperty name="link" type="string" hint="Url of link" required="no" default=""> 
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default=""> 
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">


<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmLink/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmLink/display.cfm">
</cffunction>

</cfcomponent>