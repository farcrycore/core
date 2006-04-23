<cfcomponent extends="types" displayname="Facts" hint="A fact snippet that belongs to a fact collection." bSchedule="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="nstring" hint="Meaningful reference title" required="no" default=""> 
<cfproperty name="link" type="string" hint="Link to a page internal or external" required="no" default=""> 
<cfproperty name="body" type="longchar" hint="Content of the fact" required="No" default=""> 
<cfproperty name="image" type="string" hint="Optional image to be shown" required="no" default=""> 
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render." required="yes" default="display">

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmFacts/edit.cfm">
</cffunction>
	
</cfcomponent>