<!--- 
dmFlash Type
 ---> 

<cfcomponent extends="types" displayname="Flash" hint="Forms the basis of the content framework of the site.  Displays a flash movie in the page." bSchedule="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="Title" type="nstring" hint="Title of object.  *perhaps this should be deprecated for object label*" required="no" default="">
<cfproperty name="Teaser" type="longchar" hint="Teaser text." required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render this HTML object with." required="yes" default="display">
<cfproperty name="metaKeywords" type="nstring" hint="HTML head section metakeywords." required="no" default="">
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default="">
<cfproperty name="status" type="string" hint="Status of movie - draft,pending or approved" required="No" default="">
<cfproperty name="flashVersion" type="string" hint="version of flash player required" required="No" default="6,0,0,0">
<cfproperty name="flashParams" type="string" hint="paremeters to be passed to flash movie" required="No" default="">
<cfproperty name="flashHeight" type="numeric" hint="height of flash movie in pixels" required="No" default="">
<cfproperty name="flashWidth" type="numeric" hint="width of flash movie in pixels" required="No" default="">
<cfproperty name="flashMovie" type="string" hint="The name of the flash movie" required="No" default=""> 
<cfproperty name="flashQuality" type="string" hint="The quality of the flash movie" required="no" default="high"> 
<cfproperty name="flashAlign" type="string" hint="The alignment of the flash movie" required="no" default="center"> 
<cfproperty name="flashBgcolor" type="string" hint="The background colour of the flash movie" required="no" default="##FFFFFF"> 
<cfproperty name="flashLoop" type="boolean" hint="Whether or not to loop over flash movie" required="yes" default="0"> 
<cfproperty name="flashPlay" type="boolean" hint="Play flash movie straight away?" required="yes" default="1"> 
<cfproperty name="flashMenu" type="boolean" hint="Display options menu in flash movie" required="yes" default="0"> 


<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmFlash/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmFlash/display.cfm">
</cffunction>

<cffunction name="delete" access="public" hint="Specific delete method for dmFlash. Removes physical files from ther server.">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	
	<!--- get object details --->
	<cfset stObj = getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmFlash/delete.cfm">
</cffunction>

</cfcomponent>