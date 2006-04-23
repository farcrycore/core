<!--- 
dmHTML Type
 ---> 

<cfcomponent extends="types" displayname="Web page object - HTML." hint="Forms the basis of the content framework of the site.  HTML objects include containers and static information." bSchedule="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="aObjectIDs" type="array" hint="Holds objects to be displayed at this particular node.  Can be of mixed types." required="no" default="">
<cfproperty name="aRelatedIDs" type="array" hint="Holds object pointers to related objects.  Can be of mixed types." required="no" default="">
<cfproperty name="aTeaserImageIDs" type="array" hint="Image object pointers for teaser images. Typically one image only." required="no" default="">
<cfproperty name="Title" type="string" hint="Title of object.  *perhaps this should be deprecated for object label*" required="no" default="">
<cfproperty name="Teaser" type="string" hint="Teaser text." required="no" default="">
<cfproperty name="Body" type="longchar" hint="Main body of content." required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render this HTML object with." required="yes" default="display">
<cfproperty name="metaKeywords" type="string" hint="HTML head section metakeywords." required="no" default="">
<cfproperty name="commentlog" type="string" hint="Workflow comment log." required="no" default="">
<cfproperty name="versionID" type="uuid" hint="objectID of live object - used for versioning" required="no" default="">
<!--- 
option properties.. for display
Perhaps this should be a single property with a WDDX packet of attributes?  The only reason for breaking this out into many properties was to make containernames searchable.  Therefore container names are the only option properties that need to be full columns in the database table.  Also having set properties has ramifications for sharing this object type with other deployments.
<
cfproperty name="option_*" type="string" hint="display option." required="no" default=""> 
--->

<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">
<!--- 
need to rethink versioning for farcry
<cfproperty name="version" type="string" hint="Version number." required="yes" default="">
<cfproperty name="versionid" type="string" hint="Object pointer to the versioned object." required="no">
--->
<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmHTML/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmHTML/display.cfm">
</cffunction>

</cfcomponent>

