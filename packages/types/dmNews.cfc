<!--- 
dmNews Type
 ---> 

<cfcomponent extends="types" displayname="News Object" hint="Dynamic news data">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="aObjectIds" type="array" hint="Mixed type children objects that sit underneath this object" required="no" default="">
<cfproperty name="publishDate" type="date" hint="The date that a news object is sent live and appears on the public website" required="no" default="">
<cfproperty name="expiryDate" type="date" hint="The date that a news object is removed from the web site" required="no" default="">
<cfproperty name="Title" type="string" hint="Title of object.  *perhaps this should be deprecated for object label*" required="no" default="">
<cfproperty name="Teaser" type="string" hint="Teaser text." required="no" default="">
<cfproperty name="Body" type="longchar" hint="Main body of content." required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render." required="yes" default="display">
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">
<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmNews/edit.cfm">
</cffunction>

</cfcomponent>

