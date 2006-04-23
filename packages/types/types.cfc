<!--- 
Component Types
Abstract class for contenttypes package.  This class defines default 
handlers and system attributes.
 ---> 
<cfcomponent extends="farcry.fourq.fourq" bAbstract="true" displayname="Base Content Type" hint="Abstract class. Provides default handlers and system attributes for content object types.  This component should never be instantiated directly -- it should only be inherited.">

<!--------------------------------------------------------------------
system attributes
  properties that all content types require in FarCry
--------------------------------------------------------------------->	
<cfproperty name="ObjectID" type="UUID" hint="Primary key." required="yes">
<cfproperty name="label" type="nstring" hint="Object label or title." required="no" default=""> 
<cfproperty name="datetimecreated" type="date" hint="Timestamp for record creation." required="yes" default=""> 
<cfproperty name="createdby" type="nstring" hint="Username for creator." required="yes" default=""> 
<cfproperty name="datetimelastupdated" type="date" hint="Timestamp for record last modified." required="yes" default=""> 
<cfproperty name="lastupdatedby" type="nstring" hint="Username for modifier." required="yes" default="">
<cfproperty name="lockedBy" type="nstring" hint="Username for locker." required="no" default="">
<cfproperty name="locked" type="boolean" hint="Flag for object locking." required="yes" default="0">

<!--------------------------------------------------------------------
default handlers
  handlers that all types require
  these will likely be overloaded in production
--------------------------------------------------------------------->	
	<cffunction name="getDisplay" access="public" output="Yes">
		<cfargument name="objectid" required="yes" type="UUID">
		<cfargument name="template" required="yes" type="string">
		<!--- get the data for this instance --->
		<cfset stObj = getData(arguments.objectID)>		
		<!--- check to see if the displayMethod template exists --->
		<cfif NOT fileExists("#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm")>
		 <cfabort showerror="Error: Template not found [#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm]."> 
		</cfif>
		
		<cftry>
		<cfinclude template="/farcry/#application.applicationname#/#application.path.handler#/#stObj.typename#/#arguments.template#.cfm">
		<cfcatch>
			<cfif isdefined("url.debug")><cfdump var="#cfcatch#"></cfif>
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="display" access="public" returntype="any" output="Yes">
		<cfargument name="objectid" required="yes" type="UUID">
		<cfoutput><p>This is the default output of <strong>types.Display()</strong>:</p></cfoutput>
		<cfset myObject = getData(arguments[1])>
		<cfdump var="#myObject#">
	</cffunction>

	<cffunction name="edit" access="public" output="false" returntype="struct">
		<!--- 
		Properties code not quite running yet... (driver -> Spike)
		GB 20020518
		<cfinclude template="_types/edit.cfm"> 
		--->
		<cfthrow message="This is the default types.edit() handler.  You need to build an edit interface!">
		<cfset stReturn = structNew()>
		<cfreturn stReturn>
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Basic delete method for all objects.">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		
		<!--- get object details --->
		<cfset stObj = getData(arguments.objectid)>
		<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
		<cfinclude template="_types/delete.cfm">
		
	</cffunction>	
</cfcomponent>

