<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent extends="farcry.core.packages.fourq.fourq" bAbstract="true" displayname="Base Content Type" hint="Abstract class. Provides default handlers and system attributes for content object types.  This component should never be instantiated directly -- it should only be inherited.">

<!--------------------------------------------------------------------
system attributes
  properties that all content types require in FarCry
--------------------------------------------------------------------->	
<cfproperty name="ObjectID" type="UUID" hint="Primary key." required="yes">
<cfproperty name="label" displayname="Label" type="nstring" hint="Object label or title." required="no" default="" ftLabel="Label"> 
<cfproperty name="datetimecreated" displayname="Datetime created" type="date" hint="Timestamp for record creation." required="yes" default="" ftType="datetime" ftLabel="Created"> 
<cfproperty name="createdby" displayname="Created by" type="nstring" hint="Username for creator." required="yes" default="" ftLabel="Created By">
<!--- bowden --->
<cfproperty name="ownedby" displayname="Owned by" type="nstring" hint="Username for owner." required="No" default="" ftLabel="Owned By" ftType="list" ftRenderType="dropdown" ftListData="getOwners">
<cfproperty name="datetimelastupdated" displayname="Datetime lastupdated" type="date" hint="Timestamp for record last modified." required="yes" default="" ftType="datetime" ftLabel="Last Updated" ftShowTime="true" ftTimeMask="long"> 
<cfproperty name="lastupdatedby" displayname="Last updated by" type="nstring" hint="Username for modifier." required="yes" default="" ftLabel="Last Updated By">
<cfproperty name="lockedBy" displayname="Locked by" type="nstring" hint="Username for locker." required="no" default="">
<cfproperty name="locked" displayname="Locked" type="boolean" hint="Flag for object locking." required="yes" default="0">

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--------------------------------------------------------------------
default handlers
  handlers that all types require
  these will likely be overloaded in production
--------------------------------------------------------------------->	


	<cffunction name="getDisplay" access="public" output="yes" returntype="void" hint="Renders a view from the webskin content type folder.">
		<cfargument name="objectid" required="no" type="UUID" hint="ObjectID of the object that is to be rendered by the webskin view." />
		<cfargument name="template" required="yes" type="string" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
		<cfargument name="stparam" required="false" type="struct" hint="Structure of parameters to be passed into the display handler." />
		<cfargument name="stobject" required="no" type="struct" hint="Property structure to render in view.  Overrides any property structure mapped to arguments.objectid. Useful if you want to render a view with a modified content item.">
		<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
		<cfargument name="onExitProcess" required="no" type="any" default="">
		
		<cfset var stObj = StructNew() />
		
		<cfif isDefined("arguments.stobject")>
			<cfset stobj=arguments.stobject />
		<cfelse>
			<!--- If the objectid has not been sent, we need to create a default object. --->
			<cfparam name="arguments.objectid" default="#application.fc.utils.createJavaUUID()#" type="uuid">
			<!--- get the data for this instance --->
			<cfset stObj = getData(objectid=arguments.objectID,dsn=arguments.dsn)>		
		</cfif>

		<cfif NOT structIsEmpty(stObj)>
			<cfif NOT fileExists("#ExpandPath(getWebskinPath(typename=stObj.typename, template=arguments.template))#")>
				<cfthrow type="Application" detail="Error: Template not found [#ExpandPath(getWebskinPath(typename=stObj.typename, template=arguments.template))#]." />
			</cfif>
			<cfinclude template="#getWebskinPath(typename=stObj.typename, template=arguments.template)#">
		</cfif>
	</cffunction>
		
	<cffunction name="getWebskinPath" returntype="string" access="public" output="false" hint="This tag is depricated, you should be calling farcry.core.packages.coapi.coapiadmin.getWebskinpath()">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		
		<cfset var webskinPath = application.coapi.coapiadmin.getWebskinpath(typename=arguments.typename,template=arguments.template) />
		<cfreturn webskinPath>
	</cffunction>
	
	<cffunction name="getWebskins" returntype="query" access="public" output="false" hint="Returns a query of all available webskins. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" default="#gettablename()#" hint="Typename of instance." />
		<cfargument name="prefix" type="string" required="false" default="" hint="Prefix to filter template results." />
		
		<cfset var qWebskins = application.stcoapi[arguments.typename].qWebskins />
		
		<cfif len(arguments.prefix)>
			<cfquery dbtype="query" name="qWebskins">
			SELECT * FROM qWebskins
			WHERE lower(qWebskins.name) LIKE '#lCase(arguments.prefix)#%'
			</cfquery>
		</cfif>
		
		<cfreturn qWebskins />

	</cffunction>

	<cffunction name="getWebskinDisplayname" returntype="string" access="public" output="false" hint="">
		<cfargument name="typename" type="string" required="false" />
		<cfargument name="template" type="string" required="false" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "" />
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [getWebskinDisplayname] You must pass in a path or both the typename and template" />	
			</cfif>
		</cfif>
		
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="template">
		
			<cfset pos = findNoCase('@@displayname:', template)>
			<cfif pos GT 0>
				<cfset pos = pos + 14>
				<cfset count = findNoCase('--->', template, pos)-pos>
				<cfset result = listLast(mid(template,  pos, count), ":")>
			</cfif>	
		</cfif>
		
		<cfreturn result />
	</cffunction>

	
	<cffunction name="displayTemplatePath" returntype="string" access="private" output="no" hint="Returns a template path for a webskin view.">
		<cfargument name="typename" type="string" required="yes" />
		<cfargument name="template" type="string" required="yes" />
		<cfreturn "/farcry/projects/#application.projectDirectoryName#/#application.path.handler#/#arguments.typename#/#arguments.template#.cfm" />
	</cffunction>

	<cffunction name="display" access="public" returntype="any" output="Yes">
		<cfargument name="objectid" required="yes" type="UUID">

		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var HTML = "" />
		<cfset var qMetadata = queryNew("objectID") />
		<cfset var lFieldSets = "" />
		<cfset var iFieldset = "" />
		
		<farcry:deprecated message="types.display() should no longer be used. For the default view of an object, create a displayPageStandard webskin." />

		<cfset qMetadata = application.types[stobj.typename].qMetadata >
		
		<ft:form>

		<cfquery dbtype="query" name="qFieldSets">
		SELECT ftFieldset
		FROM qMetadata
		WHERE ftFieldset <> '#stobj.typename#'
		ORDER BY ftseq
		</cfquery>
		
		<cfset lFieldSets = "" />
		<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
			<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
		</cfoutput>
		
		<cfif listLen(lFieldSets)>
						
			<cfloop list="#lFieldSets#" index="iFieldset">

				<cfquery dbtype="query" name="qFieldset">
				SELECT *
				FROM qMetadata
				WHERE ftFieldset = '#iFieldset#'
				ORDER BY ftSeq
				</cfquery>
				
				<ft:object ObjectID="#arguments.ObjectID#" format="display" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" inTable=false IncludeFieldSet=1 Legend="#iFieldset#" />
			</cfloop>
			
			
		<cfelse>
		
			<!--- default edit handler --->
			<ft:object ObjectID="#arguments.ObjectID#" format="display" lExcludeFields="label" lFields="" inTable=false IncludeFieldSet=1 Legend="#stObj.Label#" />
		</cfif>
		</ft:form>		
	
				
	</cffunction>
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bAudit" type="boolean" default="true" required="false" hint="Set to false to disable logging" />
		
		<cfset var stNewObject = "" />
		
		<!--- 
		MJB: This may or may not be cancer. Need to investigate
		It is required though just incase the variables.typename has not yet been set.
		 --->
		<cfset fourqInit() />
		
		
		<cfif not len(arguments.user)>
			<cfif isDefined("session.security.userID")>
				<cfset arguments.user = session.security.userID />
			<cfelse>
				<cfset arguments.user = 'anonymous' />			
			</cfif>
		</cfif>
		
		<cfscript>			
			if(NOT structKeyExists(arguments.stProperties,"objectid"))
				arguments.stProperties.objectid = application.fc.utils.createJavaUUID();
			if(NOT structKeyExists(arguments.stProperties,"datetimecreated"))
				arguments.stProperties.datetimecreated = createODBCDateTime(now());	
			if(NOT structKeyExists(arguments.stProperties,"datetimelastupdated"))
				arguments.stProperties.datetimelastupdated = createODBCDateTime(now());		
			if(NOT structKeyExists(arguments.stProperties,"locked"))
				arguments.stProperties.locked = 0;			
			if(NOT structKeyExists(arguments.stProperties,"lockedby"))
				arguments.stProperties.lockedby = '';
			if(NOT structKeyExists(arguments.stProperties,"createdby"))
				arguments.stProperties.createdby = arguments.user;		
			if(NOT structKeyExists(arguments.stProperties,"lastupdatedby"))
				arguments.stProperties.lastupdatedby = arguments.user;	
				
			stNewObject = super.createData(arguments.stProperties,arguments.stProperties.objectid,arguments.dsn);
			
		</cfscript>
		
		<!--- needs to be isDefined because application.stcoapi may not exist yet --->
		<cfif arguments.bAudit and (not isDefined("application.stcoapi.#variables.typename#.bAudit") or application.stcoapi[variables.typename].bAudit)>
			<farcry:logevent object="#stNewObject.objectid#" type="types" event="create" notes="#arguments.auditNote#" />
		</cfif>
				
		<cfreturn stNewObject>
	</cffunction>
	
	<cffunction name="setData" access="public" output="true" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	
		<cfargument name="bSetDefaultCoreProperties" type="boolean" required="false" default="true" hint="This allows the developer to skip defaulting the core properties if they dont exist.">	
		<cfargument name="previousStatus" type="string" required="false" />
		
		<cfset var stResult = StructNew()>
		<cfset var stresult_friendly = StructNew()>
		<cfset var stObj = structnew() />
		<cfset var fnStatusChange = "" />
		
		<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
		
		<!--- If no user has been defined we need to manually set it here. --->
		<cfif not len(arguments.User)>
			
			<!--- If a user has logged in then use them --->
			<cfif application.security.isLoggedIn()>
				<cfset arguments.User = application.security.getCurrentUserID()>
				
			<!--- 
			No user is logged in so use anonymous user. 
			Security may be inserted here in the future to search for a permission set value.
			 --->
			<cfelse>
				<cfset arguments.User = "anonymous" />
			</cfif>
		</cfif>
		
		<cfif arguments.bSetDefaultCoreProperties>
			<cfscript>
				//fill in the gaps in case user has forgotten any core properties
				if(NOT structKeyExists(arguments.stProperties,"datetimelastupdated"))
					arguments.stProperties.datetimelastupdated = createODBCDateTime(now());		
				if(NOT structKeyExists(arguments.stProperties,"locked"))
					arguments.stProperties.locked = 0;			
				if(NOT structKeyExists(arguments.stProperties,"lockedby"))
					arguments.stProperties.lockedby = '';
				if(NOT structKeyExists(arguments.stProperties,"lastupdatedby"))
					arguments.stProperties.lastupdatedby = arguments.user;		
				if(NOT structKeyExists(arguments.stProperties,"typename"))			
					arguments.stProperties.typename = findType(objectid=arguments.stProperties.objectid);
					
			</cfscript>	
		</cfif>
		
		<cfif not structKeyExists(arguments.stProperties, "typename") OR not len(arguments.stProperties.typename)>
			<cfset arguments.stProperties.typename = getTablename() />
		</cfif>			
		
		<cfif structkeyexists(arguments.stProperties,"status") and len(arguments.stProperties.status)>
			<cfset stObj = getData(objectid=arguments.stProperties.objectid) />
			<cfif not structkeyexists(arguments,"previousStatus") or not len(arguments.previousStatus)>
				<cfset arguments.previousStatus = stObj.status />
			</cfif>
			<cfif arguments.stProperties.status neq arguments.previousStatus>
				<cfset structappend(stObj,arguments.stProperties,true) />
				
				<cfif structkeyexists(this,"on#arguments.stProperties.status#")>
					<cfinvoke component="#this#" method="on#arguments.stProperties.status#">
						<cfinvokeargument name="typename" value="#arguments.stProperties.typename#" />
						<cfinvokeargument name="stProperties" value="#stObj#" />
						<cfinvokeargument name="previousStatus" value="#arguments.previousStatus#" />
					</cfinvoke>
				<cfelse>
					<cfinvoke component="#this#" method="onStatusChange">
						<cfinvokeargument name="typename" value="#arguments.stProperties.typename#" />
						<cfinvokeargument name="stProperties" value="#stObj#" />
						<cfinvokeargument name="newstatus" value="#stObj.status#" />
						<cfinvokeargument name="previousStatus" value="#arguments.previousStatus#" />
					</cfinvoke>
				</cfif>
			</cfif>
		</cfif>
			
		<cfset stresult = super.setData(stProperties=arguments.stProperties, dsn=arguments.dsn, bSessionOnly=arguments.bSessionOnly) />
		
		<!--- ONLY RUN THROUGH IF SAVING TO DB --->
		<cfif not arguments.bSessionOnly AND arguments.bAfterSave>
			
	   	 	<cfset stAfterSave = afterSave(argumentCollection=arguments) />
	   	 	
	   	 			
			<!--- set friendly url for content item. --->
			<!--- TODO: Checking for application.fc so that it is ignored on Install. This needs to be more eloquent --->	
			<cfif isDefined("application.fc.factory.farFU")>
				<cfset stresult_friendly = application.fc.factory.farFU.setSystemFU(objectID="#arguments.stProperties.objectid#", typename="#arguments.stProperties.typename#") />
			</cfif>
			
		</cfif>

		
		<!--- log update --->
		<cfif not arguments.bSessionOnly AND arguments.bAudit>
			<farcry:logevent object="#arguments.stProperties.objectid#" type="types" event="update" notes="#arguments.auditNote#" />
		</cfif>
		
		<cfreturn stresult>
	</cffunction>
	
	

	
	<cffunction name="onStatusChange" access="public" output="false" returntype="void" hint="Called from setData when an object's status is changed">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="stProperties" type="struct" required="true" hint="The object" />
		<cfargument name="newStatus" type="string" required="true" hint="The new status of the object" />
		<cfargument name="previousStatus" type="string" required="true" hint="The previous status of the object" />
		
		<cfset var thisprop = "" />
		<cfset var oFactory = "" />
		<cfset var stMetadata = "" />
		
		<cfloop collection="#application.stCOAPI[arguments.typename].stProps#" item="thisprop">
			<cfif isdefined("application.stCOAPI.#arguments.typename#.stProps.#thisprop#.metadata.ftType") and len(application.stCOAPI[arguments.typename].stProps[thisprop].metadata.ftType)>
				<cfset stMetadata = application.stCOAPI[arguments.typename].stProps[thisprop].metadata />
				<cfset oFactory = application.formtools[stMetadata.ftType].oFactory />
				<cfif structkeyexists(oFactory,"on#arguments.newStatus#")>
					<cfinvoke component="#oFactory#" method="on#arguments.newStatus#">
						<cfinvokeargument name="typename" value="#arguments.typename#" />
						<cfinvokeargument name="stObject" value="#arguments.stProperties#" />
						<cfinvokeargument name="stMetadata" value="#stMetadata#" />
						<cfinvokeargument name="previousStatus" value="#arguments.previousstatus#" />
					</cfinvoke>
				<cfelseif structkeyexists(oFactory,"onStatusChange")>
					<cfinvoke component="#this#" method="onStatusChange">
						<cfinvokeargument name="typename" value="#arguments.typename#" />
						<cfinvokeargument name="stObject" value="#arguments.stProperties#" />
						<cfinvokeargument name="stMetadata" value="#stMetadata#" />
						<cfinvokeargument name="newstatus" value="#arguments.newStatus#" />
						<cfinvokeargument name="previousStatus" value="#arguments.previousStatus#" />
					</cfinvoke>
				</cfif>
			</cfif>
		</cfloop>
		
	</cffunction>
	
	
	<cffunction name="setLock" access="public" output="true" hint="Lock a content item to prevent simultaneous editing." returntype="void">
		<cfargument name="locked" type="boolean" required="true" hint="Turn the lock on or off.">
		<cfargument name="lockedby" type="string" required="false" hint="Name of the user locking the object." default="">
		<cfargument name="bAudit" type="boolean" required="No" default="0" hint="Pass in 1 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		<cfargument name="stobj" required="No" default="#StructNew()#"> 
		<cfargument name="objectid" required="No" default=""><!--- objectid of the object to be locked/unlocked ---> 
		
		<cfset var stCurrentObject = structNew() />
		<cfset var stObject = duplicate(arguments.stobj) /><!--- Duplicating so that we are not referencing the passed object --->
		<cfset var bSessionOnly = false />
		
		<!--- Determine who the record is being locked/unlocked by --->		
		<cfif not len(arguments.lockedBy)>
			<cfif application.security.isLoggedIn()>
				<cfset arguments.lockedBy = application.security.getCurrentUserID() />
			<cfelse>
				<cfset arguments.lockedBy = "anonymous" />
			</cfif>
		</cfif>
		
		<cfif len(arguments.objectid)>
			<cfset stObject = getData(objectid="#arguments.objectid#") />
		</cfif>
		
		<cfif not StructIsEmpty(stObject)>
			<!--- We need to get the object from memory to see if it is a default object. If so, we are only saving to the session. --->
			<cfset stCurrentObject = getData(stObject.objectid) />

			<cfif structKeyExists(stCurrentObject, "bDefaultObject") AND stCurrentObject.bDefaultObject>
				<cfset bSessionOnly = true />
			</cfif>
			<cfset stObject.locked = arguments.locked>
			<cfif arguments.locked>
				<cfset stObject.lockedby=arguments.lockedby>
			<cfelse>
				<cfset stObject.lockedby="">
			</cfif>
			
			
			<!--- call fourq.setdata() (ie super) to bypass prepop of sys attributes by types.setdata() --->
			<cfset setdata(stProperties="#stObject#", user="#arguments.lockedby#", bAudit="#arguments.bAudit#", dsn="#arguments.dsn#", bAfterSave="false", bSetDefaultCoreProperties="false", bSessionOnly="#bSessionOnly#")>

		</cfif>
	</cffunction>
	
	<cffunction name="editDeprecated" access="public" output="true" returntype="void">
		<cfargument name="ObjectID" required="true" type="UUID">
		<cfargument name="lFields" required="false" type="string" default="">
		<cfargument name="cancelCompleteURL" required="false" type="string" default="">
		
		<cfset var stObj=getData(arguments.objectid)>
		<cfset var oType = createObject("component",application.types['#stObj.typename#'].typepath)>

	
		<cfparam name="url.ref" default="">

		<ft:processForm action="Save" >
			
			<ft:processFormObjects objectid="#arguments.ObjectID#" />
			
			<cfoutput><h3>Object updated!</h3></cfoutput>
			
		</ft:processForm>
		
		<ft:processForm action="cancel" >
			<cfset oType.setlock(stObj=stObj,locked="false",lockedby=#application.security.getCurrentUserID()#)>
			<cfoutput><h3>Object Not Saved!</h3></cfoutput>
		</ft:processForm>
		
		<ft:processForm action="save,cancel" exit="true">
		</ft:processForm>

		<!--- <ft:processForm >
			<!--- get parent to update tree --->
			<cfset stObj=getData(arguments.objectid)>
			<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
			<!--- update tree --->
			<nj:updateTree objectId="#parentID#">
			<cfswitch expression="#url.ref#">
			<cfcase value="overview">
				<cfoutput>
				<script language="javascript" type="text/javascript">
				location.href = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#";
				</script>
				</cfoutput>
			</cfcase>
			</cfswitch>

			<cfabort>
		</ft:processForm> --->

					
		<cfset stObj=getData(arguments.objectid)>	
		<ft:form>
			<cfoutput><h3>#stObj.label#</h3></cfoutput>
		
			<ft:object objectID="#arguments.objectID#" lfields="#arguments.lFields#" inTable=0 />
			
			<ft:button value="Save" />
			<ft:button value="Cancel" />	
		</ft:form>

		
	</cffunction>
	
		
	
	<cffunction name="getField" access="public" output="false" returntype="any">
		<cfargument name="objectid" type="uuiD" required="false" hint="objectid of the object to be retrieved." />
		<cfargument name="stobject" type="struct" required="false" hint="structure of the object that has already been retrieved and passed through" />
		<cfargument name="fieldname" type="string" required="true" hint="the name of the field" />
		<cfargument name="format" type="string" required="false" default="display" hint="Can be either Edit or Display." />
		<cfargument name="lock" type="boolean" required="false" default="true" hint="When format EQ edit and this is set to true, the object is locked by the </ft:form>" />
		<cfargument name="stPropMetadata" type="struct" required="false" default="#structNew()#" hint="Any metadata that the developer wishes to append/override" />
		<cfargument name="value" type="any" required="false" hint="The developer can force the value to be used by the formtool type" />
		<cfargument name="default" type="any" required="false" hint="The developer can force the value to be used by the formtool type" />
		<cfargument name="defaultOnEmpty" type="string" required="false" default="" hint="The developer can force the value to be used by the formtool type if the result is an empty string" />
		
		<cfset var prefix = "" />
		<cfset var ftFieldMetadata = structNew() />
		<cfset var packagePath = "" />
		<cfset var stPackage = structNew() />
		<cfset var oType = "" />
		<cfset var resultHTML = "" />
		
		
		
		<cfif structKeyExists(arguments, "stobject") and structKeyExists(arguments.stobject, "objectid")>
			<!--- arguments.stobject is the correct object to use --->
		<cfelse>
			<cfset arguments.stobject = getData(objectid=arguments.objectid) />		
		</cfif>
		
		
		<cfif structKeyExists(application.types, arguments.stobject.typename)>
			<cfset stPackage = application.types[arguments.stobject.typename] />
			<cfset packagePath = application.types[arguments.stobject.typename].typepath />
		<cfelse>
			<cfset stPackage = application.rules[arguments.stobject.typename] />
			<cfset packagePath = application.rules[arguments.stobject.typename].rulepath />
		</cfif>
		<cfset oType = createObject("component", packagePath) />
				
		
		<!--- CHECK TO SEE IF OBJECTED HAS ALREADY BEEN RENDERED. IF SO, USE SAME PREFIX --->
		<cfif not isDefined("Request.farcryForm.stObjects")>
			<!--- If the call to this tag is not made within the confines of a <ft:form> tag, then we need to create a temp one and then delete it at the end of the tag. --->
			<cfset Request.farcryForm.stObjects = StructNew()>	
		</cfif>
		
		<cfloop list="#StructKeyList(Request.farcryForm.stObjects)#" index="key">
			<cfif structKeyExists(request.farcryForm.stObjects,'#key#') 
				AND structKeyExists(request.farcryForm.stObjects[key],'farcryformobjectinfo')
				AND structKeyExists(request.farcryForm.stObjects[key].farcryformobjectinfo,'ObjectID')
				AND request.farcryForm.stObjects[key].farcryformobjectinfo.ObjectID EQ arguments.stobject.ObjectID>
					<cfset prefix = key>
			</cfif>				
		</cfloop>

		<cfparam  name="prefix" default="#ReplaceNoCase(arguments.stobject.ObjectID,'-', '', 'all')#">			
		<cfset Request.farcryForm.stObjects[prefix] = StructNew()>
	
		<cfset Request.farcryForm.stObjects[prefix].farcryformobjectinfo.ObjectID = arguments.stobject.ObjectID>				
		<cfset Request.farcryForm.stObjects[prefix].farcryformobjectinfo.typename = arguments.stobject.typename>		
		<cfif arguments.lock AND arguments.format EQ "Edit">
			<cfset Request.farcryForm.stObjects[prefix].farcryformobjectinfo.lock = true />
		</cfif>
		
		
		
		<cfset Request.farcryForm.stObjects[prefix]['MetaData'][arguments.fieldname] = Duplicate(stPackage.stprops[arguments.fieldname].MetaData)>		

		
		<!--- If we have been sent stPropValues for this field then we need to set it to this value  --->
		<cfif structKeyExists(arguments, "value")>
			<cfset Request.farcryForm.stObjects[prefix]['MetaData'][arguments.fieldname].value = arguments.value>
		<cfelse>
			<cfset Request.farcryForm.stObjects[prefix]['MetaData'][arguments.fieldname].value = arguments.stobject[arguments.fieldname]>				
		</cfif>
		
		<cfset Request.farcryForm.stObjects[prefix]['MetaData'][arguments.fieldname].formFieldName = "#prefix##arguments.fieldname#">
		
				
		<!--- SETUP THE METADATA FOR THE FIELD --->		
		<cfset ftFieldMetadata = request.farcryForm.stObjects[prefix].MetaData[arguments.fieldname]>
		
		<!--- If we have been sent stPropMetadata for this field then we need to append it to the default metatdata setup in the type.cfc  --->
		<cfif structKeyExists(arguments.stPropMetadata,ftFieldMetadata.Name)>
			<cfset StructAppend(ftFieldMetadata, arguments.stPropMetadata[ftFieldMetadata.Name])>
		</cfif>
	
		<!--- CHECK TO ENSURE THE FORMTOOL TYPE EXISTS. OTHERWISE USE THE DEFAULT [FIELD] --->
		<cfif NOT StructKeyExists(application.formtools,ftFieldMetadata.ftType)>
			<cfif StructKeyExists(application.formtools,ftFieldMetadata.Type)>
				<cfset ftFieldMetadata.ftType = ftFieldMetadata.Type>
			<cfelse>
				<cfset ftFieldMetadata.ftType = "Field">
			</cfif>
		</cfif>		
		
		<cfif NOT StructKeyExists(application.formtools,ftFieldMetadata.ftType)>
			<cfif StructKeyExists(application.formtools,ftFieldMetadata.Type)>
				<cfset ftFieldMetadata.ftType = ftFieldMetadata.Type>
			<cfelse>
				<cfset ftFieldMetadata.ftType = "Field">
			</cfif>
		</cfif>

		
		<!--- CHECK TO ENSURE THE FORMTOOL TYPE EXISTS. OTHERWISE USE THE DEFAULT [FIELD] --->
		<cfif NOT StructKeyExists(application.formtools,ftFieldMetadata.ftType)>
			<cfif StructKeyExists(application.formtools,ftFieldMetadata.Type)>
				<cfset ftFieldMetadata.ftType = ftFieldMetadata.Type>
			<cfelse>
				<cfset ftFieldMetadata.ftType = "Field">
			</cfif>
		</cfif>		
				
		<cfif structKeyExists(arguments, "defaultValue")>
			<cfset ftFieldMetadata.default = arguments.defaultValue />
		</cfif>						
		
		<cfset oFieldType = application.formtools[ftFieldMetadata.ftType].oFactory.init() />

		<!--- Need to determine which method to run on the field --->		
		<cfif structKeyExists(ftFieldMetadata, "ftDisplayOnly") AND ftFieldMetadata.ftDisplayOnly OR ftFieldMetadata.ftType EQ "arrayList">
			<cfset FieldMethod = "display" />
		<cfelseif structKeyExists(ftFieldMetadata,"Method")><!--- Have we been requested to run a specific method on the field. This can enable the user to run a display method inside an edit form for instance --->
			<cfset FieldMethod = ftFieldMetadata.method>
		<cfelse>
			<cfif arguments.Format EQ "Edit">
				<cfif len(ftFieldMetadata.ftEditMethod)>
					<cfset FieldMethod = ftFieldMetadata.ftEditMethod>
					
					<!--- Check to see if this method exists in the current oType CFC. if so. Change oFieldType the Current oType --->
					<cfif structKeyExists(oType,ftFieldMetadata.ftEditMethod)>
						<cfset oFieldType = oType>
					</cfif>
				<cfelse>
					<cfif structKeyExists(oType,"ftEdit#ftFieldMetadata.Name#")>
						<cfset FieldMethod = "ftEdit#ftFieldMetadata.Name#">						
						<cfset oFieldType = oType>
					<cfelse>
						<cfset FieldMethod = "Edit">
					</cfif>
					
				</cfif>
			<cfelse>
					
				<cfif len(ftFieldMetadata.ftDisplayMethod)>
					<cfset FieldMethod = ftFieldMetadata.ftDisplayMethod>
					<!--- Check to see if this method exists in the current oType CFC. if so. Change oFieldType the Current oType --->
					
					<cfif structKeyExists(oType,ftFieldMetadata.ftDisplayMethod)>
						<cfset oFieldType = oType>
					</cfif>
				<cfelse>
					<cfif structKeyExists(oType,"ftDisplay#ftFieldMetadata.Name#")>
						<cfset FieldMethod = "ftDisplay#ftFieldMetadata.Name#">						
						<cfset oFieldType = oType>
					<cfelse>
						<cfset FieldMethod = "display">
					</cfif>
					
				</cfif>
			</cfif>
		</cfif>	

			
		<cfinvoke component="#oFieldType#" method="#FieldMethod#" returnvariable="resultHTML">
			<cfinvokeargument name="typename" value="#arguments.stobject.typename#">
			<cfinvokeargument name="stObject" value="#arguments.stobject#">
			<cfinvokeargument name="stMetadata" value="#ftFieldMetadata#">
			<cfinvokeargument name="fieldname" value="#prefix##ftFieldMetadata.Name#">
			<cfinvokeargument name="stPackage" value="#application.types[arguments.stobject.typename]#">
		</cfinvoke>
		
		<!--- <cfif len(trim(resultHTML))>
			<cfoutput>#trim(resultHTML)#</cfoutput>
		<cfelse>
			<cfoutput>#arguments.defaultOnEmpty#</cfoutput>
		</cfif>
		 --->
		<cfreturn trim(resultHTML) />
		
	</cffunction>
	
	<cffunction name="AddNew" access="public" output="true" returntype="void">
		<cfargument name="typename" required="true" type="string">
		<cfargument name="lFields" required="false" type="string" default="">
		
		<ft:object typename="#arguments.typename#" lfields="#arguments.lFields#" inTable=0 />

	</cffunction>
	
	<cffunction name="BeforeSave" access="public" output="false" returntype="struct">
		<cfargument name="stProperties" required="true" type="struct">
		<cfargument name="stFields" required="true" type="struct">
		<cfargument name="stFormPost" required="false" type="struct">		

		<cfset var newLabel = autoSetLabel(stProperties=arguments.stProperties) />
		
		
		<cfif len(trim(newLabel))>
			<cfset arguments.stProperties.label = newLabel />
		</cfif>
		
		
		<cfset stProperties.datetimelastupdated = now() />
		
		<cfreturn stProperties>
	</cffunction>
	
	
	
 	<cffunction name="autoSetLabel" access="public" output="false" returntype="string" hint="Automagically sets the label">
		<cfargument name="stProperties" required="true" type="struct">

		<!--- 
			This will set the default Label value. It first looks form the bLabel associated metadata.
			Otherwise it will look for title, then name and then anything with the substring Name.
		 --->
		<cfset var newLabel = "" />
		
		<cfif structKeyExists(arguments.stProperties, "typename") AND application.stcoapi[arguments.stProperties.typename].bAutoSetLabel>
			<cfloop list="#StructKeyList(application.stcoapi[arguments.stProperties.typename].stProps)#" index="field">
				<cfif structKeyExists(arguments.stProperties,field) AND isDefined("application.stcoapi.#arguments.stProperties.typename#.stProps.#field#.Metadata.bLabel") AND application.stcoapi[arguments.stProperties.typename].stProps[field].Metadata.bLabel>
					<cfset newLabel = "#newLabel# #arguments.stProperties[field]#">
				</cfif>
			</cfloop>
	
			<cfif not len(newLabel)>
				<cfif structKeyExists(arguments.stProperties,"Title")>
					<cfset newLabel = "#arguments.stProperties.title#">
				<cfelseif structKeyExists(arguments.stProperties,"Name")>
					<cfset newLabel = "#arguments.stProperties.name#">
				<cfelse>
					<cfloop list="#StructKeyList(arguments.stProperties)#" index="field">
						<cfif FindNoCase("Name",field) AND field NEQ "typename">
							<cfset newLabel = "#newLabel# #arguments.stProperties[field]#">
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
			
		</cfif>
		
		<cfreturn trim(newLabel) />
	</cffunction>
	
	<cffunction name="Edit" access="public" output="true" returntype="void" hint="Default edit handler.">
		<cfargument name="ObjectID" required="yes" type="string" default="" />
		<cfargument name="onExitProcess" required="no" type="any" default="Refresh" />
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var qMetadata = application.types[stobj.typename].qMetadata />
		<cfset var lWizardSteps = "" />
		<cfset var iWizardStep = "" />
		<cfset var lFieldSets = "" />
		<cfset var iFieldSet = "" />
		
		<!--- 
			Always locking at the beginning of an edit 
			Forms need to be manually unlocked. Wizards will unlock automatically.
		--->
		<cfset setLock(stObj=stObj,locked=true) />
			
		<cfif structkeyexists(url,"iframe")>
			<cfset onExitProcess = structNew() />
			<cfset onExitProcess.Type = "HTML" />
			<cfsavecontent variable="onExitProcess.content">
				<cfoutput>
					<script type="text/javascript">
						<!--- parent.location.reload(); --->
						parent.location = parent.location;
						parent.closeDialog();		
					</script>
				</cfoutput>
			</cfsavecontent>
		</cfif>
		
		<!-------------------------------------------------- 
		WIZARD:
		- build default formtool wizard
		--------------------------------------------------->		
		<cfquery dbtype="query" name="qwizardSteps">
		SELECT ftwizardStep
		FROM qMetadata
		WHERE lower(ftwizardStep) <> '#lcase(stobj.typename)#'
		ORDER BY ftSeq
		</cfquery>
		
		<cfset lWizardSteps = "" />
		<cfoutput query="qWizardSteps" group="ftWizardStep" groupcasesensitive="false">
			<cfif NOT listFindNoCase(lWizardSteps,qWizardSteps.ftWizardStep)>
				<cfset lWizardSteps = listAppend(lWizardSteps,qWizardSteps.ftWizardStep) />
			</cfif>
		</cfoutput>
		
		<!------------------------ 
		Work out if we are creating a wizard or just a simple form.
		If there are multiple wizard steps then we will be creating a wizard
		 ------------------------>
		<cfif listLen(lWizardSteps) GT 1>
			
			<!--- Always save wizard WDDX data --->
			<wiz:processwizard excludeAction="Cancel">
			
				<!--- Save the Primary wizard Object --->
				<wiz:processwizardObjects typename="#stobj.typename#" />	
					
			</wiz:processwizard>
			
			<wiz:processwizard action="Save" Savewizard="true" Exit="true" /><!--- Save wizard Data to Database and remove wizard --->
			<wiz:processwizard action="Cancel" Removewizard="true" Exit="true" /><!--- remove wizard --->
			
			
			<wiz:wizard ReferenceID="#stobj.objectid#">
			
				<cfloop list="#lWizardSteps#" index="iWizardStep">
						
					<cfquery dbtype="query" name="qwizardStep">
					SELECT *
					FROM qMetadata
					WHERE lower(ftwizardStep) = '#lcase(iWizardStep)#'
					ORDER BY ftSeq
					</cfquery>
				
					<wiz:step name="#iWizardStep#">
						

						<cfquery dbtype="query" name="qFieldSets">
						SELECT ftFieldset
						FROM qMetadata
						WHERE lower(ftwizardStep) = '#lcase(iWizardStep)#'
						AND lower(ftFieldset) <> '#lcase(stobj.typename)#'				
						ORDER BY ftSeq
						</cfquery>
						<cfset lFieldSets = "" />
						<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
							<cfif NOT listFindNoCase(lFieldSets,qFieldSets.ftFieldset)>
								<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
							</cfif>
						</cfoutput>
						
						
						<cfif listlen(lFieldSets)>
											
							<cfloop list="#lFieldSets#" index="iFieldSet">
							
								<cfquery dbtype="query" name="qFieldset">
								SELECT *
								FROM qMetadata
								WHERE lower(ftwizardStep) = '#lcase(iWizardStep)#' 
								and lower(ftFieldset) = '#lcase(iFieldSet)#'
								ORDER BY ftSeq
								</cfquery>
								
								<wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="#valuelist(qFieldset.propertyname)#" format="edit" intable="false" legend="#iFieldSet#" helptitle="#qFieldset.fthelptitle#" helpsection="#qFieldset.fthelpsection#" />
							</cfloop>
							
						<cfelse>
							
							<wiz:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" lfields="#valuelist(qwizardStep.propertyname)#" format="edit" intable="false" />
						
						</cfif>
						
						
					</wiz:step>
				
				</cfloop>
				
			</wiz:wizard>	
				
				
				
				
		<!------------------------ 
		If there is only 1 wizard step (typename by default) then we will be creating a simple form
		 ------------------------>		 
		<cfelse>
		
			<cfquery dbtype="query" name="qFieldSets">
			SELECT ftFieldset
			FROM qMetadata
			WHERE lower(ftFieldset) <> '#lcase(stobj.typename)#'
			ORDER BY ftseq
			</cfquery>
			
			<cfset lFieldSets = "" />
			<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
				<cfif NOT listFindNoCase(lFieldSets,qFieldSets.ftFieldset)>
					<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
				</cfif>
			</cfoutput>
		
			<!--- PERFORM SERVER SIDE VALIDATION --->
			<!--- <ft:serverSideValidation /> --->
		
			<!---------------------------------------
			ACTION:
			 - default form processing
			---------------------------------------->
			<ft:processForm action="Save" Exit="true">
				<ft:processFormObjects typename="#stobj.typename#" />
				<cfset setLock(objectid=stObj.objectid,locked=false) />
			</ft:processForm>

			<ft:processForm action="Cancel" Exit="true" >
				<cfset setLock(objectid=stObj.objectid,locked=false) />
			</ft:processForm>
			
			
			
			<ft:form bFocusFirstField="true">
				
					
				<cfoutput><h1><skin:icon icon="#application.stCOAPI[stobj.typename].icon#" default="farcrycore" size="32" />#stobj.label#</h1></cfoutput>
				
				<cfif listLen(lFieldSets)>
					
					<cfloop list="#lFieldSets#" index="iFieldset">
						
						<cfquery dbtype="query" name="qFieldset">
						SELECT *
						FROM qMetadata
						WHERE lower(ftFieldset) = '#lcase(iFieldset)#'
						ORDER BY ftSeq
						</cfquery>
						
						<ft:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" format="edit" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" inTable="false" IncludeFieldSet="true" Legend="#iFieldset#" helptitle="#qFieldset.fthelptitle#" helpsection="#qFieldset.fthelpsection#" />
					</cfloop>
					
					
				<cfelse>
				
					<!--- All Fields: default edit handler --->
					<ft:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" format="edit" lExcludeFields="label" lFields="" IncludeFieldSet="false" />
					
				</cfif>
				
				<ft:buttonPanel>
					<ft:button value="Save" color="orange" /> 
					<ft:button value="Cancel" validate="false" />
				</ft:buttonPanel>
				
			</ft:form>
		</cfif>


	</cffunction>
	
	<cffunction name="copy" access="public" output="true" returntype="void" hint="Default edit handler.">
		<cfargument name="ObjectID" required="yes" type="string" default="" />
		<cfargument name="onExitProcess" required="no" type="any" default="Refresh" />
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var duplicateID = "" />
		<cfset var qMetadata = application.stCOAPI[stobj.typename].qMetadata />
		<cfset var lWizardSteps = "" />
		<cfset var iWizardStep = "" />
		<cfset var lFieldSets = "" />
		<cfset var iFieldSet = "" />
		<cfset var thisjoin = "" />
		<cfset var stSearch = structnew() />
		<cfset var qRelated = "" />
		<cfset var qAllRelated = querynew("objectid,typename,objectlabel,typenamelabel") />
		<cfset var stCount = structnew() />
		
		<cfparam name="url.editURL" />
		
		<!--- Get list of related content --->
		<cfloop from="1" to="#arraylen(application.stCOAPI[stObj.typename].aJoins)#" index="thisjoin">
			<cfif application.stCOAPI[stObj.typename].aJoins[thisjoin].direction eq "from" and application.stCOAPI[stObj.typename].aJoins[thisjoin].type eq "uuid">
				<cfset stSearch = structnew() />
				<cfset stSearch.typename = application.stCOAPI[stObj.typename].aJoins[thisjoin].coapiType />
				<cfset stSearch.lProperties = "objectid,label" />
				<cfset stSearch["#application.stCOAPI[stObj.typename].aJoins[thisjoin].property#_eq"] = arguments.objectid />
				<cfset qRelated = application.fapi.getContentObjects(argumentCollection=stSearch) />
				<cfset stCount[qRelated.typename] = qRelated.recordcount />
				<cfloop query="qRelated">
					<cfset queryaddrow(qAllRelated) />
					<cfset querysetcell(qAllRelated,"objectid",qRelated.objectid) />
					<cfset querysetcell(qAllRelated,"objectlabel",qRelated.label) />
					<cfset querysetcell(qAllRelated,"typename",qRelated.typename) />
					<cfif structkeyexists(application.stCOAPI[qRelated.typename],"displayname")>
						<cfset querysetcell(qAllRelated,"typenamelabel",application.stCOAPI[qRelated.typename].displayname) />
					<cfelse>
						<cfset querysetcell(qAllRelated,"typenamelabel",qRelated.typename) />
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfif qAllRelated.recordcount>
			
			<ft:processForm action="Save" Exit="true">
				<cfif len(form.copyrelated)>
					<cfquery dbtype="query" name="qAllRelated">
						select objectid,typename from qAllRelated where typename in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#form.copyrelated#" />)
					</cfquery>
					<cfset duplicateID = duplicateObject(objectid=stObj.objectid,qRelated=qAllRelated) />
					
					<skin:bubble title="Object Copied" message="'#stObj.label#' and #qAllRelated.recordcount# related item/s have been copied" />
				<cfelse>
					<cfset duplicateID = duplicateObject(objectid=stObj.objectid) />
					
					<skin:bubble title="Object Copied" message="'#stObj.label#' and no related items have been copied" />
				</cfif>
				<skin:location href="#application.fapi.fixURL(url=url.editURL,addvalues='objectid=#duplicateID#')#" />
			</ft:processForm>
			
			<cfif structkeyexists(url,"iframe")>
				<cfset onExitProcess = structNew() />
				<cfset onExitProcess.Type = "HTML" />
				<cfsavecontent variable="onExitProcess.content">
					<cfoutput>
						<script type="text/javascript">
							<!--- parent.location.reload(); --->
							parent.location = parent.location;
							parent.closeDialog();		
						</script>
					</cfoutput>
				</cfsavecontent>
			</cfif>
			<ft:processForm action="Cancel" Exit="true" />
			
			
			<cfquery dbtype="query" name="qAllRelated">select * from qAllRelated order by typenamelabel,objectlabel</cfquery>
			
			<ft:form bFocusFirstField="true">
				
				<cfoutput><h1><skin:icon icon="#application.stCOAPI[stobj.typename].icon#" default="farcrycore" size="32" />#stobj.label#</h1></cfoutput>
				
				<cfoutput>
					<div>
						<fieldset class="fieldset">
							<h2 class="legend">Associated Content</h2>
							<div class="helpsection">This object is referred to by other content. Please indicate below which of this content should also be copied.</p></div>
				</cfoutput>
			
				<cfoutput query="qAllRelated" group="typenamelabel">
					<ft:field label="#qAllRelated.typenamelabel#" bMultifield="true">
						<input type="checkbox" name="copyrelated" id="copyrelated" value="#qAllRelated.typename#" class="checkboxInput" checked />
						<input type="hidden" name="copyrelated" value="" />
						<a href="###qAllRelated.typename#_showhide" onclick="$j('###qAllRelated.typename#_showhide').toggle();return false;">#stCount[qAllRelated.typename]# item/s</a>
						<div id="#qAllRelated.typename#_showhide" style="display:none;"><cfoutput>#qAllRelated.objectlabel#<br></cfoutput></div>
					</ft:field>
				</cfoutput>
				
				<cfoutput>
						</fieldset>
					</div>
				</cfoutput>
				
				<ft:buttonPanel>
					<ft:button value="Save" color="orange" /> 
					<ft:button value="Cancel" validate="false" />
				</ft:buttonPanel>
				
			</ft:form>
			
		<cfelse>
			
			<cfset duplicateID = duplicateObject(objectid=stObj.objectid) />
			<skin:bubble title="Object Copied" message="'#stObj.label#' has been copied" />
			<skin:location href="#application.fapi.fixURL(url=url.editURL,addvalues='objectid=#duplicateID#')#" />
			
		</cfif>

	</cffunction>
	
	<cffunction name="duplicateObject" access="public" hint="Underlying functionality for 'copy' action - a primary object and a recordset containing related content is passed in, which are duplicated and the new id's returned">
		<cfargument name="objectid" type="uuid" required="true" hint="Primary object" />
		<cfargument name="qRelated" type="query" required="false" default="#querynew('objectid,typename')#" hint="Related content to be duplcated also" />
		
		<cfset var stDuplicate = structnew() />
		<cfset var user = "anonymous" />
		<cfset var parentID = "" />
		<cfset var oNav = application.fapi.getContentType(typename="dmNavigation") />
		<cfset var stNav = structnew() />
		<cfset var thisprop = "" />
		<cfset var stLocation = structnew() />
		<cfset var oCon = application.fapi.getContentType("container") />
		<cfset var stObj = getData(arguments.objectid) />
		<cfset var newid = application.fapi.getUUID() />
		
		<cfif application.security.isLoggedIn()>
			<cfset arguments.User = application.security.getCurrentUserID()>
		</cfif>
			
		<cfquery dbtype="query" name="arguments.qRelated">
			select objectid, typename, '' as newid from arguments.qRelated
		</cfquery>
		
		<cfset queryaddrow(arguments.qRelated) />
		<cfset querysetcell(arguments.qRelated,"objectid",arguments.objectid) />
		<cfset querysetcell(arguments.qRelated,"typename",getTableName()) />
		
		<cfloop query="arguments.qRelated">
			<!--- Copy the object itself --->
			<cfset stDuplicate = application.fapi.getContentObject(typename=arguments.qRelated.typename,objectid=arguments.qRelated.objectid) />
			
			<!--- Update UUIDs --->
			<cfif stDuplicate.objectid neq arguments.objectid>
				<cfset stDuplicate.objectid = application.fapi.getUUID() />
				
				<cfloop from="1" to="#arraylen(application.stCOAPI[stObj.typename].aJoins)#" index="thisjoin">
					<cfif application.stCOAPI[stObj.typename].aJoins[thisjoin].coapitype eq stDuplicate.typename and application.stCOAPI[stObj.typename].aJoins[thisjoin].direction eq "from" and application.stCOAPI[stObj.typename].aJoins[thisjoin].type eq "uuid">
						<cfset stDuplicate[application.stCOAPI[stObj.typename].aJoins[thisjoin].property] = newID />
					</cfif>
				</cfloop>
			<cfelse>
				<cfset stDuplicate.objectid = newid />
			</cfif>
			
			<!--- Update system properties --->
			<cfset stDuplicate.createdby = user />
			<cfset stDuplicate.datetimecreated = now() />
			<cfset stDuplicate.ownedby = user />
			<cfset stDuplicate.datetimelastupdated = now() />
			<cfset stDuplicate.lastupdatedby = user />
			<cfif structkeyexists(stDuplicate,"status")>
				<cfset stDuplicate.status = "draft" />
			</cfif>
			
			<!--- Make copies of any attached files / images --->
			<cfloop collection="#application.stCOAPI[arguments.qRelated.typename].stProps#" item="thisprop">
				<cfif structkeyexists(application.stCOAPI[arguments.qRelated.typename].stProps[thisprop].metadata,"ftType") and structkeyexists(application.formtools[application.stCOAPI[arguments.qRelated.typename].stProps[thisprop].metadata.ftType].oFactory,"duplicateFile")>
					<cfset stDuplicate[thisprop] = application.formtools[application.stCOAPI[arguments.qRelated.typename].stProps[thisprop].metadata.ftType].oFactory.duplicateFile(stDuplicate,application.stCOAPI[arguments.qRelated.typename].stProps[thisprop].metadata) />
				</cfif>
			</cfloop>
			
			<cfset application.fapi.setData(stProperties=stDuplicate) />
			
			<!--- Copy containers --->
			<cfset oCon.copyContainers(arguments.qRelated.objectid,stDuplicate.objectid) />
			
			<!--- Put the copy into the next place in the tree --->
			<cfif arguments.qRelated.typename eq "dmNavigation">
				<cfset parentID = application.factory.oTree.getParentID(objectid=arguments.qRelated.objectid) />
				<cfset application.factory.oTree.setChild(parentID=parentID,objectid=stDuplicate.objectid,objectname=stDuplicate.label,typename=arguments.qRelated.typename,pos=1000) />
			<cfelseif structkeyexists(application.stCOAPI[arguments.qRelated.typename],"bUseInTree") and application.stCOAPI[arguments.qRelated.typename].bUseInTree>
				<cfset parentID = oNav.getParent(objectid=arguments.qRelated.objectid).parentid[1] />
				<cfset stNav = oNav.getData(objectid=parentID) />
				<cfset arrayappend(stNav.aObjectIDs,stDuplicate.objectid) />
				<cfset oNav.setData(stProperties=stNav) />
			</cfif>
			
			<!--- Update the query with the new id --->
			<cfset querysetcell(arguments.qRelated,"newid",stDuplicate.objectid,arguments.qRelated.currentrow) />
			
			<!--- Log copy --->
			<farcry:logevent object="#arguments.qRelated.objectid#" type="types" event="copy" notes="Copied to [#stDuplicate.objectid#] as part of [#arguments.objectid#]" />
		</cfloop>
		
		<cfreturn arguments.qRelated.newid[arguments.qRelated.recordcount] />
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Basic delete method for all objects. Deletes content item and removes Verity entries." returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<!--- get the data for this instance --->
		<cfset var stObj = getData(arguments.objectID)>
		<cfset var lTypesWithContainers = "">
		<cfset var oCon = "">
		<cfset var i = "">
		<cfset var objType = "">
		<cfset var oType = "">
		<cfset var oConfig = "">
		<cfset var stCollections = "">
		<cfset var collectionName = "">
		<cfset var stlocal = StructNew()>
		<cfset var stReturn = StructNew()>
		
		<cfif not len(arguments.user)>
			<cfif application.security.isLoggedIn()>
				<cfset arguments.user = application.security.getCurrentUserID() />
			<cfelse>
				<cfset arguments.user = 'anonymous' />
			</cfif>
		</cfif>
		
		<cfif structisempty(stobj)>
			<cfset stReturn.bSuccess = false>
			<cfset stReturn.message = "Content item (#arguments.objectid#) does not exsit.">
			<cfreturn stReturn>
		</cfif>
		
		<!--- done first cause need to remove associtaion to library object --->
		<cfinclude template="_types/delete.cfm">

		<!--- check if need to archive object --->
		<cfif application.config.general.bDoArchive EQ "true">
			<cfset stLocal.archiveObject = createobject("component",application.types.dmArchive.typepath)>
			<cfset stLocal.returnVar = stLocal.archiveObject.fArchiveObject(stObj)>
		</cfif>
		
		<cfset onDelete(typename=stObj.typename,stObject=stObj) />

		<!--- write audit trail --->
		<cfif not len(arguments.auditNote)>
			<cfset arguments.auditNote = "#stObj.label# (#stObj.typename#) deleted.">
		</cfif>
		<farcry:logevent object="#arguments.objectid#" type="types" event="delete" notes="#arguments.auditNote#" />
		
		<cfset stReturn.bSuccess = true>
		<cfset stReturn.message = "#stObj.label# (#stObj.typename#) deleted.">
		<cfreturn stReturn>
	</cffunction>
	
	<cffunction name="onDelete" returntype="void" access="public" output="false" hint="Is called after the object has been removed from the database">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		
		<cfset var thisprop = "" />
		<cfset var oFactory = "" />
		<cfset var stMetadata = "" />
		
		<cfloop collection="#application.stCOAPI[arguments.typename].stProps#" item="thisprop">
			<cfif isdefined("application.stCOAPI.#arguments.typename#.stProps.#thisprop#.metadata.ftType") and len(application.stCOAPI[arguments.typename].stProps[thisprop].metadata.ftType)>
				<cfset stMetadata = application.stCOAPI[arguments.typename].stProps[thisprop].metadata />
				<cfset oFactory = application.formtools[stMetadata.ftType].oFactory />
				<cfif structkeyexists(oFactory,"onDelete")>
					<cfinvoke component="#oFactory#" method="onDelete">
						<cfinvokeargument name="typename" value="#arguments.typename#" />
						<cfinvokeargument name="stObject" value="#arguments.stObject#" />
						<cfinvokeargument name="stMetadata" value="#stMetadata#" />
					</cfinvoke>
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="onSecurityChange" returntype="void" access="public" output="false" hint="Performs any updates necessary for a security change">
		<cfargument name="changetype" type="string" required="true" hint="type | object" />
		<cfargument name="objectid" type="uuid" required="false" hint="Object being changed" />
		<cfargument name="typename" type="string" required="false" hint="Type of object being changed" />
		<cfargument name="stObject" type="struct" required="false" hint="Object being changed" />
		<cfargument name="farRoleID" type="uuid" required="true" hint="The objectid of the role" />
		<cfargument name="farPermissionID" type="uuid" required="true" hint="The objectid of the permission" />
		<cfargument name="oldRight" type="numeric" required="true" hint="The old status" />
		<cfargument name="newRight" type="numeric" required="true" hint="The new status" />
		
		<cfset var thisprop = "" />
		<cfset var oFactory = "" />
		<cfset var stMetadata = "" />
		
		<cfif not structkeyexists(arguments,"stObject")>
			<cfset arguments.stObject = getData(objectid=arguments.objectid) />
		</cfif>
		
		<cfloop collection="#application.stCOAPI[arguments.typename].stProps#" item="thisprop">
			<cfif isdefined("application.stCOAPI.#arguments.typename#.stProps.#thisprop#.metadata.ftType") and len(application.stCOAPI[arguments.typename].stProps[thisprop].metadata.ftType)>
				<cfset arguments.stMetadata = application.stCOAPI[arguments.typename].stProps[thisprop].metadata />
				<cfset oFactory = application.formtools[arguments.stMetadata.ftType].oFactory />
				<cfif structkeyexists(oFactory,"onDelete")>
					<cfset oFactory.onSecurityChange(argumentCollection=arguments) />
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="renderObjectOverview" access="public" hint="Renders entire object overiew" output="true">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
			
		<!--- get object details --->
		<cfset var stObj = getData(arguments.objectid)>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.html = "">		
		<cfinclude template="_types/renderObjectOverview.cfm">
		<cfreturn stLocal.html>

	</cffunction>
	
	<cffunction name="archiveObject" access="public" returntype="struct" hint="Archives any farcry object">
		<!--- TODO: move out of this abstract class to proposed version abstract class 20050802 GB --->
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="typename" type="string" required="false">

		<cfset var stLocal = StructNew()> <!--- local struct to hold all local values --->			
		<cfset var stObj = getData(arguments.objectID)>
 		<!--- <cfset var stResult = application.factory.oVersioning.archiveObject(objectid=arguments.objectid,typename=arguments.typename)> --->

		<cfset stLocal.objArchive = CreateObject("component","#application.packagepath#.types.dmArchive")>
		<cfset stLocal.returnStruct = stLocal.objArchive.fArchiveObject(stObj)>

		<cfreturn stLocal.returnStruct>
	</cffunction>
	
	<cffunction name="archiveRollback" access="public" returntype="struct" hint="Sends a archived object live and archives current version">
		<!--- TODO: move out of this abstract class to proposed version abstract class 20050802 GB --->
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="archiveID"  type="uuid" required="true" hint="the archived object to be sent back live">
		<cfargument name="typename" type="string" default="" required="false">
		
 		<cfset var stResult = application.factory.oVersioning.rollbackArchive(objectid=arguments.objectid,typename=arguments.typename,archiveID=arguments.archiveID)>
		
		<cfreturn stResult>
	</cffunction>

	<!--- // STATUS: default status changing methods --->
	<cffunction name="statustodraft" access="public" returntype="struct" hint="Sends object to draft state." output="false">
	<!--- 	
	// TODO: 
		update comment log if its here
		notify owner of status change if owner didn't change
		check audit is firing from setdata()
		Versioning (via versions.cfc)
			- delete underlying draft if it exists
	 --->		
		<cfset var stresult=structnew()>
		<cfset var stproperties=structNew()>
		<cfset stproperties.objectid=instance.stobj.objectid>
		<cfset stproperties.status="draft">
		<cfset setData(stproperties=stproperties)>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to draft.">
		<cfreturn stResult>
	</cffunction>

	<cffunction name="statustopending" access="public" returntype="struct" hint="Sends object to pending state." output="false">
	<!--- 	
	// TODO: 
		update comment log if its here
		notify owner of status change if owner didn't change
		notify approvers
	 --->		
		<cfset var stresult=structnew()>
		<cfset var stproperties=structNew()>
		<cfset stproperties.objectid=instance.stobj.objectid>
		<cfset stproperties.status="pending">
		<cfset setData(stproperties=stproperties)>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to pending.">
		<cfreturn stResult>
	</cffunction>

	<cffunction name="statustoapproved" access="public" returntype="struct" hint="Sends object to approved state." output="false">
	<!--- 	
	// TODO: 
		update comment log if its here
		notify owner of status change if owner didn't change
		Versioning (via versions.cfc)
			- archive current live
			- set friendly url as required
	 --->		
		<cfset var stresult = structnew()>
		<cfset var stproperties = structNew()>
		<cfset var stobj = getdata(objectid=instance.stobj.objectid)>
		<cfset var stlocal = structnew()>
		<cfset stproperties.objectid = instance.stobj.objectid>
		<cfset stproperties.status = "approved">
		<cfset setData(stproperties=stproperties)>
		<cfset stresult.bsuccess = true>
		<cfset stresult.message = "Content status changed to approved.">
		<!--- also approve all associated images/files (aobjectids) --->
		<cfif StructKeyExists(application.types[instance.stobj.typename].stprops,"aObjectIDs") AND ArrayLen(instance.stobj.aObjectIDs)>
			<cfset stlocal.lTypeNames = "dmImage,dmFile">
			<cfloop index="stlocal.iTypeName" list="#stlocal.lTypeNames#">
				<cfquery name="stLocal.qUpdateStatus" datasource="#application.dsn#">
				UPDATE	#application.dbowner##stlocal.iTypeName#
				SET		status = '#stproperties.status#'
				WHERE	objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#ArrayToList(instance.stobj.aObjectIDs)#" />)
				</cfquery>				
			</cfloop>
		</cfif>
		
		<!--- 
		// Set Friendly URL 
		 - TODO: this is going to cause issues if the approval process fails or is not confirmed GB20060123
		--->
		<!--- versioned objects use parent live object for fu --->
		<cfif StructKeyExists(stObj,"versionid") AND len(stobj.versionid)>
			<cfset fuoid=stobj.versionid>
		<!--- use objectid if no versionid --->
		<cfelse>
			<cfset fuoid=stobj.objectid>
		</cfif>
		

		<!--- set friendly url --->
		<cfif StructKeyExists(application.stcoapi[stObj.typename],"bFriendly") AND application.stcoapi[stObj.typename].bFriendly>
			<cfset stresult_friendly = application.fc.factory.farFU.setSystemFU(objectid=fuoid)>
		</cfif>

 		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="getArrayFieldAsQuery" access="public" output="true" returntype="query">
		
		<cfargument name="ObjectID" required="no" type="string" default="" hint="This is the PK for which we are getting the linked FK's. If the ObjectID passed is empty, the we are creating a new object and it will therefore not have an objectID">
		<cfargument name="Fieldname" required="yes" type="string">
		<cfargument name="typename" required="yes" type="string" default="">
		<cfargument name="ftJoin" required="yes" type="string" /><!--- This is a list of typenames as defined in the metadata of the property --->
		
		<cfset var q = queryNew("parentid,data,seq,typename") />
		
		<cfif NOT len(arguments.typename)>
			<cfset arguments.typename  = findType(objectID="#arguments.ObjectID#")>
		</cfif>
		
		<cfquery datasource="#application.dsn#" name="q">
		SELECT *
		FROM #arguments.typename#_#arguments.Fieldname#
		WHERE #arguments.typename#_#arguments.Fieldname#.parentID = '#arguments.ObjectID#'
		ORDER BY #arguments.typename#_#arguments.Fieldname#.seq ASC
		</cfquery>		
	
		<cfreturn q />
			
	</cffunction>
		
		

		
	<cffunction name="AddArrayObject" access="public" output="true" returntype="any" hint="This is the Edit Method that is used in the Library">
		<cfargument name="typename" required="yes" type="string">
		
		<ft:form>
			<ft:object typename="#arguments.typename#" format="edit" inTable=0 />
		</ft:form>

	</cffunction>
		
	<cffunction name="PickArrayObject" access="public" output="true" returntype="any" hint="This is the Edit Method that is used in the Library">
		<cfargument name="ObjectID" required="yes" type="UUID">
		
		<ft:object objectID="#arguments.ObjectID#" lFields="label" format="display" />

	</cffunction>
		
	<cffunction name="SelectedArrayObject" access="public" output="true" returntype="any" hint="This is the Edit Method that is used in the Library">
		<cfargument name="ObjectID" required="yes" type="UUID">
		
		<ft:object objectID="#arguments.ObjectID#" lFields="label" format="display" />
	
	</cffunction>
			
	<cffunction name="getLibraryData" access="public" output="false" returntype="query" hint="Return a query of all content instances for generic library interface.">
		<cfset var qLibraryList=queryNew("ObjectID,Label") />
		<cfquery datasource="#application.dsn#" name="qLibraryList">
		SELECT *
		FROM #getTablename()#
		ORDER BY label
		</cfquery>
		<cfreturn qLibraryList />
	</cffunction>
	
	<cffunction name="getOwners" access="public" output="false" returntype="string">
	
		<cfset var errormessage = "" />
		<cfset var name = "" />
		<cfset var q = queryNew("value,name") />
		<cfset var lResult =  "" />
		
		<cfset objProfile = CreateObject("component",application.types.dmprofile.packagepath)>
		<cfset returnstruct = objProfile.fListProfileByPermission("Admin")>
		<cfif returnstruct.bSuccess>
			<cfset q = returnstruct.queryObject>
	
			<cfloop query="q">
				<cfif Trim(q.lastName) EQ "" AND Trim(q.firstName) EQ "">
					<cfset name = application.fapi.listSlice(q.username,1,-2,"_") />
				<cfelse>
					<cfset name = "#q.firstName# #q.lastName#" />
				</cfif>
				<cfset lResult = listAppend(lResult, HTMLEditFormat("#q.objectid#:#name#")) />
			</cfloop>
		
		</cfif>
		
		<cfreturn lResult />
	
	
	</cffunction>

	<cffunction name="showFarcryDate" access="public" output="false" returntype="boolean" hint="Returns boolean as to whether to show the date based on how farcry stores dates. ie, 2050 or +200 years.">
		<cfargument name="date" required="true" hint="The date to check" />
		
		<cfreturn application.fapi.showFarcryDate(arguments.date)>
	
	</cffunction>



	<cffunction name="getLibrarySearchResults" access="public" output="false" returntype="query" hint="Returns a query containing all the objectids for the type matching the library filter criteria.">
		<cfargument name="criteria" required="true" type="string" hint="The criteria to search" />
		
		<cfset var qSearchResults = "" />
		
		<cfset fourqInit() />
		
		<cfif lcase(application.dbtype) EQ "mssql"> <!--- Dodgy MS SQL only code --->
			<cfquery datasource="#application.dsn#" name="qSearchResults">
				SELECT objectID as [key] , label FROM #application.dbowner#[#variables.typename#]	
				WHERE label like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.criteria#%">
				Order by label
			</cfquery>
		<cfelse> <!--- Dirty hack to get this query working for MySQL and possibly Postgres --->
			<cfquery datasource="#application.dsn#" name="qSearchResults">
				SELECT objectID as "key" , label FROM #application.dbowner##variables.typename#
				WHERE lower(label) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.criteria#%">
				Order by label
			</cfquery>
		</cfif>
		
		<cfreturn qSearchResults>
	
	</cffunction>

	
	<cffunction name="getFileLocation" access="public" output="false" returntype="struct" hint="Returns information used to access the file: type (stream | redirect), path (file system path | absolute URL), filename, mime type">
		<cfargument name="objectid" type="string" required="false" default="" hint="Object to retrieve" />
		<cfargument name="typename" type="string" required="false" default="" hint="Type of the object to retrieve" />
		<!--- OR --->
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		
		<cfargument name="fieldname" type="string" required="false" hint="Property metadata" />
		
		
		<cfset var i = "" />
		
		<!--- Get the object if not passed in --->
		<cfif not structkeyexists(arguments,"stObject")>
			<cfset arguments.stObject = getData(objectid=arguments.objectid,typename=arguments.typename) />
		</cfif>
		
		<!--- Determine which property to use if not passed in --->
		<cfif not structkeyexists(arguments,"fieldname")>
			<!--- Name of the file field has not been sent. We need to loop though the type to determine which field contains the file path --->
			<cfloop list="#structKeyList(application.types[arguments.stObject.typename].stprops)#" index="i">
				<cfif application.fapi.getPropertyMetadata(arguments.stObject.typename,i,"ftType","") EQ "file">
					<cfset arguments.stMetadata = application.types[arguments.stObject.typename].stprops[i].metadata />
					<cfbreak />
				</cfif>
			</cfloop>
			
			<!--- Throw an error if the field couldn't be determined --->
			<cfif not structkeyexists(arguments,"stMetadata")>
				<cfset stResult = structnew() />
				<cfset stResult.message = "Fieldname for the file reference could not be determined" />
				<cfreturn stResult />
			</cfif>
		<cfelse>
			<cfset arguments.stMetadata = application.stCOAPI[arguments.stObject.typename].stProps[arguments.fieldname].metadata />
		</cfif>
		
		<cfreturn application.formtools.file.oFactory.getFileLocation(argumentcollection=arguments) />
	</cffunction>
	
</cfcomponent>
