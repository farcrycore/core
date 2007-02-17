<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/types.cfc,v 1.68.2.17 2006/04/19 13:53:09 geoff Exp $
$Author: geoff $
$Date: 2006/04/19 13:53:09 $
$Name:  $
$Revision: 1.68.2.17 $

|| DESCRIPTION || 
$Description: Component Types Abstract class for contenttypes package.  
This class defines default handlers and system attributes.$

|| DEVELOPER ||
$Developer: Geoff Bowers (geoff@daemon.com.au) $
--->

<cfcomponent extends="farcry.core.packages.fourq.fourq" bAbstract="true" displayname="Base Content Type" hint="Abstract class. Provides default handlers and system attributes for content object types.  This component should never be instantiated directly -- it should only be inherited.">

<!--------------------------------------------------------------------
system attributes
  properties that all content types require in FarCry
--------------------------------------------------------------------->	
<cfproperty name="ObjectID" type="UUID" hint="Primary key." required="yes">
<cfproperty name="label" displayname="Label" type="nstring" hint="Object label or title." required="no" default=""> 
<cfproperty name="datetimecreated" displayname="Datetime created" type="date" hint="Timestamp for record creation." required="yes" default="" ftType="datetime" ftLabel="Created"> 
<cfproperty name="createdby" displayname="Created by" type="nstring" hint="Username for creator." required="yes" default="">
<!--- bowden --->
<cfproperty name="ownedby" displayname="Owned by" type="nstring" hint="Username for owner." required="No" default="">
<cfproperty name="datetimelastupdated" displayname="Datetime lastupdated" type="date" hint="Timestamp for record last modified." required="yes" default="" ftType="datetime" ftLabel="Last Updated"> 
<cfproperty name="lastupdatedby" displayname="Last updated by" type="nstring" hint="Username for modifier." required="yes" default="">
<cfproperty name="lockedBy" displayname="Locked by" type="nstring" hint="Username for locker." required="no" default="">
<cfproperty name="locked" displayname="Locked" type="boolean" hint="Flag for object locking." required="yes" default="0">

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

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
		<cfargument name="OnExit" required="no" type="any" default="">
		
		<cfset var stObj = StructNew() />
		
		<cfif isDefined("arguments.stobject")>
			<cfset stobj=arguments.stobject />
		<cfelse>
			<!--- If the objectid has not been sent, we need to create a default object. --->
			<cfparam name="arguments.objectid" default="#CreateUUID()#" type="uuid">
			<!--- get the data for this instance --->
			<cfset stObj = getData(objectid=arguments.objectID,dsn=arguments.dsn)>		
		</cfif>

		<cfif NOT structIsEmpty(stObj)>
			<cfif NOT fileExists("#ExpandPath(getWebskinPath(typename=stObj.typename, template=arguments.template))#")>
				<cfthrow type="Application" detail="Error: Template not found [#ExpandPath(displayTemplatePath(typename=stObj.typename, template=arguments.template))#]." />
			</cfif>
			<cfinclude template="#getWebskinPath(typename=stObj.typename, template=arguments.template)#">
		</cfif>
	</cffunction>
	
	<cffunction name="getView" access="public" output="true" returntype="string" hint="Returns the HTML of a view from the webskin content type folder.">
		<cfargument name="objectid" required="no" type="UUID" hint="ObjectID of the object that is to be rendered by the webskin view." />
		<cfargument name="template" required="yes" type="string" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
		<cfargument name="stparam" required="false" type="struct" default="#structNew()#" hint="Structure of parameters to be passed into the display handler." />
		<cfargument name="stobject" required="no" type="struct" hint="Property structure to render in view.  Overrides any property structure mapped to arguments.objectid. Useful if you want to render a view with a modified content item.">
		<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
		<cfargument name="OnExit" required="no" type="any" default="">
		<cfargument name="alternateHTML" required="no" type="string" hint="If the webskin template does not exist, if this argument is sent in, its value will be passed back as the result.">
		
		<cfset var stResult = structNew() />
		<cfset var stObj = StructNew() />
		<cfset var WebskinPath = "" />
		<cfset var webskinHTML = "" />
		<cfset var oObjectBroker = createObject("component", "farcry.core.packages.fourq.objectBroker").init() />
		
		
		
		
		<cfif listLast(arguments.template,".") EQ "cfm">
			<cfset arguments.template = ReplaceNoCase(arguments.template,".cfm", "", "all") />
		</cfif>
		
		
		
		<cfif isDefined("arguments.stobject")>
			<cfset stobj=arguments.stobject />
			<cfset instance.stobj = stObj />
		<cfelse>
			<!--- If the objectid has not been sent, we need to create a default object. --->
			<cfparam name="arguments.objectid" default="#CreateUUID()#" type="uuid">
			<!--- get the data for this instance --->
			<cfset stObj = getData(objectid=arguments.objectID,dsn=arguments.dsn)>		
		</cfif>
		
		
		<cftimer label="getView (#stObj.typename#:#arguments.template#:#stobj.objectid#)">
			
		<cfif NOT structIsEmpty(stObj)>		
		
			<!--- Check to see if the webskin is in the object broker --->
			<cfset webskinHTML = oObjectBroker.getWebskin(objectid=stobj.objectid, typename=stobj.typename, template=arguments.template) />		

			<cfif not len(webskinHTML)>
				<cfset webskinPath = getWebskinPath(typename=stObj.typename, template=arguments.template) />
						
				<cfif len(webskinPath)>
	
					<cfsavecontent variable="webskinHTML">
						<cfinclude template="#WebskinPath#">
					</cfsavecontent>
					
					<!--- Add the webskin to the object broker if required --->
					<cfset oObjectBroker.addWebskin(objectid=stobj.objectid, typename=stobj.typename, template=arguments.template, html=webskinHTML) />		
					
				<cfelseif structKeyExists(arguments, "alternateHTML")>
					<cfset webskinHTML = arguments.alternateHTML />
				<cfelse>
					<cfthrow type="Application" detail="Error: Template not found [/webskin/#stObj.typename#/#arguments.template#.cfm] and no alternate html provided." />
				</cfif>	
			</cfif>		
		<cfelse>
			<cfthrow type="Application" detail="Error: When trying to render [/webskin/#stObj.typename#/#arguments.template#.cfm] the object was not created correctly." />	
		</cfif>
		
		</cftimer>
		
		<cfreturn webskinHTML />
	</cffunction>
		
		
	<cffunction name="getWebskinPath" returntype="string" access="public" output="false" hint="This tag is depricated, you should be calling farcry.core.packages.coapi.coapiadmin.getWebskinpath()">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		
		<cfset var webskinPath = createObject("component", "farcry.core.packages.coapi.coapiadmin").getWebskinpath(typename=arguments.typename,template=arguments.template) />
		<cfreturn webskinPath>
		
			
		<!--- <cfset var webskinPath = "" />
	
		<cfif fileExists(ExpandPath("/farcry/#application.applicationname#/webskin/#arguments.typename#/#arguments.template#.cfm"))>
			
			<cfset webskinPath = "/farcry/#application.applicationname#/webskin/#arguments.typename#/#arguments.template#.cfm" />
			
		<cfelseif structKeyExists(application, "plugins") and listLen(application.plugins)>

			<cfloop list="#application.plugins#" index="library">
				
				<cfif fileExists(ExpandPath("/farcry/plugins/#library#/webskin/#arguments.typename#/#arguments.template#.cfm"))>
				
					<cfset webskinPath = "/farcry/plugins/#library#/webskin/#arguments.typename#/#arguments.template#.cfm" />
				</cfif>	
				
			</cfloop>
			
		</cfif>
		
		<!--- If it hasnt been found yet, check in core. --->
		<cfif not len(webskinPath) AND fileExists(ExpandPath("/farcry/core/webskin/#arguments.typename#/#arguments.template#.cfm"))>
			
			<cfset webskinPath = "/farcry/core/webskin/#arguments.typename#/#arguments.template#.cfm" />
			
		</cfif>
		
		<cfreturn webskinPath> --->
		
	</cffunction>
	
	<cffunction name="getWebskins" returntype="query" access="public" output="false" hint="Returns a query of all available webskins. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" default="#gettablename()#" hint="Typename of instance." />
		<cfargument name="prefix" type="string" required="false" default="" hint="Prefix to filter template results." />
		
		<cfset var qWebskins = application.stcoapi[arguments.typename].qWebskins />
		<cfset var qResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode,displayname","varchar,varchar,integer,varchar,date,varchar,varchar,varchar") />
		
		<cfif len(arguments.prefix)>
			<cfquery dbtype="query" name="qResult">
			SELECT * FROM qWebskins
			WHERE lower(qWebskins.name) LIKE '#lCase(arguments.prefix)#%'
			</cfquery>
		</cfif>
		
		<cfreturn qResult />
		<!--- <cfset var qResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode,displayname,methodname") />
		<cfset var qLibResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qCoreResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qDupe=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var webskinPath = ExpandPath("/farcry/#application.applicationname#/webskin/#arguments.typename#") />
		<cfset var library="" />
		<cfset var col="" />
		<cfset var WebskinDisplayName = "" />

		<!--- check project webskins --->
		<cfif directoryExists(webskinPath)>
			<cfdirectory action="list" directory="#webskinPath#" name="qResult" recurse="true" sort="asc" />
			
			<cfquery name="qResult" dbtype="query">
				SELECT *, name as displayname
				FROM qResult
				WHERE lower(qResult.name) LIKE '#lCase(arguments.prefix)#%'
				AND lower(qResult.name) LIKE '%.cfm'
			</cfquery>
			
		</cfif>

		<!--- check library webskins --->
		<cfif structKeyExists(application, "plugins") and Len(application.plugins)>

			<cfloop list="#application.plugins#" index="library">
				<cfset webskinpath=ExpandPath("/farcry/plugins/#library#/webskin/#arguments.typename#") />
				
				<cfif directoryExists(webskinpath)>
					<cfdirectory action="list" directory="#webskinPath#" name="qLibResult" sort="asc" />

					<cfquery name="qLibResult" dbtype="query">
						SELECT *
						FROM qLibResult
						WHERE lower(qLibResult.name) LIKE '#lCase(arguments.prefix)#%'
						AND lower(qLibResult.name) LIKE '%.cfm'
					</cfquery>
					
					<cfloop query="qLibResult">
						<cfquery dbtype="query" name="qDupe">
						SELECT *
						FROM qResult
						WHERE name = '#qLibResult.name#'
						</cfquery>
						
						<cfif NOT qDupe.Recordcount>
							<cfset queryaddrow(qresult,1) />
							<cfloop list="#qlibresult.columnlist#" index="col">
								<cfset querysetcell(qresult, col, qlibresult[col][qLibResult.currentrow]) />
							</cfloop>
						</cfif>
						
					</cfloop>
				</cfif>	
				
			</cfloop>
			
		</cfif>
		
		
		<!--- CHECK CORE WEBSKINS --->		
		<cfset webskinpath=ExpandPath("/farcry/core/webskin/#arguments.typename#") />
		
		<cfif directoryExists(webskinpath)>
			<cfdirectory action="list" directory="#webskinPath#" name="qCoreResult" sort="asc" />

			<cfquery name="qCoreResult" dbtype="query">
				SELECT *
				FROM qCoreResult
				WHERE lower(qCoreResult.name) LIKE '#lCase(arguments.prefix)#%'
				AND lower(qCoreResult.name) LIKE '%.cfm'
			</cfquery>
			
			<cfloop query="qCoreResult">
				<cfquery dbtype="query" name="qDupe">
				SELECT *
				FROM qResult
				WHERE name = '#qCoreResult.name#'
				</cfquery>
				
				<cfif NOT qDupe.Recordcount>
					<cfset queryaddrow(qresult,1) />
					<cfloop list="#qCoreResult.columnlist#" index="col">
						<cfset querysetcell(qresult, col, qCoreResult[col][qCoreResult.currentRow]) />
					</cfloop>
				</cfif>
				
			</cfloop>
		</cfif>	
		
		<!--- ORDER AND SET DISPLAYNAME FOR COMBINED WEBSKIN RESULTS --->		
 		<cfquery dbtype="query" name="qResult">
		SELECT *,   name as methodname
		FROM qResult
		ORDER BY name
		</cfquery>
		
		<cfoutput query="qResult">
			
			<!--- Strip the .cfm from the filename --->
			<cfset querysetcell(qresult, 'methodname', ReplaceNoCase(qResult.name, '.cfm', '','ALL'), qResult.currentRow) />	
			
			<!--- See if the DisplayName is defined in the webskin and if so, replace displayName field in the query. --->
			<cfset WebskinDisplayName = getWebskinDisplayname(typename="#arguments.typename#", template="#ReplaceNoCase(qResult.name, '.cfm', '','ALL')#") />
			<cfif len(WebskinDisplayName)>
				<cfset querysetcell(qresult, 'displayname', WebskinDisplayName, qResult.currentRow) />			
			</cfif>
			<cfset querysetcell(qresult,'methodname',listfirst(qResult.methodName[qResult.currentRow],"."),qResult.currentRow)>
		</cfoutput>

		
		<!--- resort the query now that we finally have all the information we need so that display templates are order by displayname --->
		<cfquery name="qResult" dbtype="query">
		SELECT * FROM qResult
		ORDER BY DisplayName
		</cfquery>
		
		<cfreturn qresult /> --->
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
		<cfreturn "/farcry/projects/#application.applicationname#/#application.path.handler#/#arguments.typename#/#arguments.template#.cfm" />
	</cffunction>

	<cffunction name="display" access="public" returntype="any" output="Yes">
		<cfargument name="objectid" required="yes" type="UUID">
		
		
		<!---<cfset var myObject = getData(arguments[1])>
		<cfoutput><p>This is the default output of <strong>types.Display()</strong>:</p></cfoutput>
		<cfdump var="#myObject#"> --->
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var HTML = "" />
		<cfset var qMetadata = queryNew("objectID") />
		

			
		
		<cfset qMetadata = application.types[stobj.typename].qMetadata >
		
		<ft:form>
		<cfquery dbtype="query" name="qFieldSets">
		SELECT ftwizardStep, ftFieldset
		FROM qMetadata
		WHERE ftFieldset <> '#stobj.typename#'
		Group By ftwizardStep, ftFieldset
		ORDER BY ftSeq
		</cfquery>
		
		<cfif qFieldSets.recordcount GTE 1>
			
			<cfloop query="qFieldSets">
				<cfquery dbtype="query" name="qFieldset">
				SELECT *
				FROM qMetadata
				WHERE ftFieldset = '#qFieldsets.ftFieldset#'
				ORDER BY ftSeq
				</cfquery>
				
				<ft:object ObjectID="#arguments.ObjectID#" format="display" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" inTable=false IncludeFieldSet=1 Legend="#qFieldSets.ftFieldset#" />
			</cfloop>
			
			
		<cfelse>
		
			<!--- default edit handler --->
			<ft:object ObjectID="#arguments.ObjectID#" format="display" lExcludeFields="label" lFields="" inTable=false IncludeFieldSet=1 Legend="#stObj.Label#" />
		</cfif>
		</ft:form>		
	
				
	</cffunction>
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		
		<cfscript>
			var stNewObject = "";
			if(NOT structKeyExists(arguments.stProperties,"objectid"))
				arguments.stProperties.objectid = createUUID();
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
			application.factory.oAudit.logActivity(auditType="Create", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=stNewObject.objectid);
		</cfscript>
		
		<cfreturn stNewObject>
	</cffunction>
	
	<cffunction name="setData" access="public" output="true" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		
		<cfset var stResult = StructNew()>
		<cfset var stresult_friendly = StructNew()>
		
		<!--- If no user has been defined we need to manually set it here. --->
		<cfif not len(arguments.User)>
			
			<!--- If a user has logged in then use them --->
			<cfif isDefined("session.dmSec.authentication.userlogin")>
				<cfset arguments.User = session.dmSec.authentication.userlogin>
				
			<!--- 
			No user is logged in so use anonymous user. 
			Security may be inserted here in the future to search for a permission set value.
			 --->
			<cfelse>
				<cfset arguments.User = "anonymous" />
			</cfif>
		</cfif>
		
		<cfscript>
			// TODO should prepopulate with values set in cfproperty
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
				
		<cfset stresult = super.setData(stProperties=arguments.stProperties, dsn=arguments.dsn, bSessionOnly=arguments.bSessionOnly) />

		<!--- set friendly url for content item,if applicable 
		TODO: sort out FU allocation.. have moved this to status approval step for now.. so introducing a catch all for non-status based content types. --->
		<cfif NOT structkeyexists(arguments.stproperties, "status")>
			<cfif Application.config.plugins.FU AND (NOT StructKeyExists(application.types[arguments.stProperties.typename].stprops,"status")) AND StructKeyExists(application.types[arguments.stProperties.typename],"bFriendly") AND application.types[arguments.stProperties.typename].bFriendly AND NOT ListFindNoCase(application.config.fusettings.lExcludeObjectIDs,arguments.stProperties.objectid)>
				<cfif StructKeyExists(arguments.stProperties,"label") AND Trim(arguments.stProperties.label) NEQ "" AND arguments.stProperties.label NEQ "incomplete">
					<cfset stresult_friendly = setFriendlyURL(arguments.stProperties.objectid)>
				</cfif>
			</cfif>
		</cfif>

		<!--- log update --->
		<cfif arguments.bAudit>
			<cfset application.factory.oAudit.logActivity(auditType="Update", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.stProperties.objectid,dsn=arguments.dsn)>	
		</cfif>
		<cfreturn stresult>
	</cffunction>
	
	<cffunction name="setLock" access="public" output="true" hint="Lock a content item to prevent simultaneous editing." returntype="void">
		<cfargument name="locked" type="boolean" required="true" hint="Turn the lock on or off.">
		<cfargument name="lockedby" type="string" required="false" hint="Name of the user locking the object." default="">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		<cfargument name="stobj" required="No" default="#StructNew()#"> 
		
		<!--- Determine who the record is being locked/unlocked by --->		
		<cfif not len(arguments.lockedBy)>
			<cfif isDefined("session.dmSec.authentication.userlogin") AND isDefined("session.dmSec.authentication.userDirectory")>
				<cfset arguments.lockedBy = "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#" />
			<cfelse>
				<cfset arguments.lockedBy = "anonymous" />
			</cfif>
		</cfif>
		
		
		<!--- if the properties struct not passed in grab the instance --->
		<cfif StructIsEmpty(arguments.stObj)>
			<!--- Default Objects should not be locked as this will create a record in the database. --->
			<cfif structKeyExists(instance, "stobj") AND (NOT structKeyExists(instance.stobj, "bDefaultObject") OR NOT instance.stobj.bDefaultObject)>
				<cfset instance.stobj.locked=arguments.locked>
				<cfif arguments.locked>
					<cfset instance.stobj.lockedby=arguments.lockedby>
				<cfelse>
					<cfset instance.stobj.lockedby="">
				</cfif>
				<!--- call fourq.setdata() (ie super) to bypass prepop of sys attributes by types.setdata() --->
				<cfset setdata(instance.stobj, arguments.lockedby, 0)>
			</cfif>
		<cfelseif NOT structKeyExists(arguments.stobj, "bDefaultObject") or NOT arguments.stobj.bDefaultObject >
			<cfset arguments.stobj.locked = arguments.locked>
			<cfif arguments.locked>
				<cfset arguments.stobj.lockedby=arguments.lockedby>
			<cfelse>
				<cfset arguments.stobj.lockedby="">
			</cfif>
			<!--- call fourq.setdata() (ie super) to bypass prepop of sys attributes by types.setdata() --->
			<cfset setdata(arguments.stobj, arguments.lockedby, 0)>
		</cfif>

	
		<!--- log event --->
		<cfif arguments.bAudit and isDefined("instance.stobj.objectid")>
			<cfset application.factory.oAudit.logActivity(auditType="Lock", username=arguments.lockedby, location=cgi.remote_host, note="Locked: #yesnoformat(arguments.locked)#",objectid=instance.stobj.objectid,dsn=arguments.dsn)>
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
			<cfset oType.setlock(stObj=stObj,locked="false",lockedby=#session.dmSec.authentication.userlogin#)>
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
			
			<ft:farcryButton value="Save" />
			<ft:farcryButton value="Cancel" />	
		</ft:form>
		
		<!--- <cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz" >
		
		<wiz:wizard
			ReferenceID="#arguments.objectID#"
			ReturnLocation="wizard.cfm"
			Timeout="15"
			r_stwizard="stwizard">
		
			
			<wiz:step name="start" lFields="Title" />
			<wiz:step name="media" lFields="aObjectIDs,aRelatedIDs" />
			<wiz:step name="detail">
				<ft:object ObjectID="#stwizard.PrimaryObjectID#" lFields="Body" InTable=0 />
			</wiz:step>
			
			
		</wiz:wizard> --->
		
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
				<cfif structKeyExists(ftFieldMetadata,"ftEditMethod")>
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
					
				<cfif structKeyExists(ftFieldMetadata,"ftDisplayMethod")>
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
		
		
		<!--- 
			This will set the default Label value. It first looks form the bLabel associated metadata.
			Otherwise it will look for title, then name and then anything with the substring Name.
		 --->
		<cfset var NewLabel = "" />
		
		<cfparam name="stProperties.label" default="">
		
		
		<cfloop list="#StructKeyList(arguments.stFields)#" index="field">
			<cfif structKeyExists(arguments.stProperties,field) AND isDefined("arguments.stFields.#field#.Metadata.bLabel") AND arguments.stFields[field].Metadata.bLabel>
				<cfset NewLabel = "#NewLabel# #arguments.stProperties[field]#">
			</cfif>
		</cfloop>

		<cfif not len(NewLabel)>
			<cfif structKeyExists(arguments.stProperties,"Title")>
				<cfset NewLabel = "#arguments.stProperties.title#">
			<cfelseif structKeyExists(arguments.stProperties,"Name")>
				<cfset NewLabel = "#arguments.stProperties.name#">
			<cfelse>
				<cfloop list="#StructKeyList(arguments.stProperties)#" index="field">
					<cfif FindNoCase("Name",field) AND field NEQ "typename">
						<cfset NewLabel = "#NewLabel# #arguments.stProperties[field]#">
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfif len(trim(NewLabel))>
			<cfset stProperties.label = trim(NewLabel) />
		<cfelse>
			<cfset stProperties.label = stProperties.label />
		</cfif>
		
		
		<cfset stProperties.datetimelastupdated = now() />
		
		<cfreturn stProperties>
	</cffunction>
	
	<cffunction name="AfterSave" access="public" output="true" returntype="struct" hint="Called from ProcessFormObjects and run after the object has been saved.">
		<cfargument name="stProperties" required="yes" type="struct" hint="A structure containing the contents of the properties that were saved to the object.">
<!--- 
		<cfset var searchData = structNew() />
		
		
		TODO: Add ability to reindex object if required based on verity metadata info in the component. 
		This would be nice if it used the new Event Queue ;)
		
		<cfif structKeyExists(application, "searchCollection")>
			<cfset searchData = structNew() />
			<cfset searchData.CollectionName = application.searchCollection.Name />
			<cfset searchData.CollectionPath = "C:/CFusionMX7/verity/collections/" />
			<cfset searchData.Typename = stProperties.typename />
			<cfset searchData.stProps = application.types[stProperties.typename].stprops />
			<cfset searchData.stObject = arguments.stProperties />
			<cfset status = SendGatewayMessage("FarcrySearchIndexing", searchData) />
		</cfif>
		--->
		<cfreturn stProperties />
	</cffunction>
	
	<cffunction name="Edit" access="public" output="true" returntype="void" hint="Default edit handler.">
		<cfargument name="ObjectID" required="yes" type="string" default="" />
		<cfargument name="onExit" required="no" type="any" default="Refresh" />
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var qMetadata = application.types[stobj.typename].qMetadata />
		
		<!-------------------------------------------------- 
		WIZARD:
		- build default formtool wizard
		--------------------------------------------------->		
		<cfquery dbtype="query" name="qwizardSteps">
		SELECT ftwizardStep
		FROM qMetadata
		WHERE ftwizardStep <> '#stobj.typename#'
		Group By ftwizardStep
		ORDER BY ftSeq
		</cfquery>
		
		<!------------------------ 
		Work out if we are creating a wizard or just a simple form.
		If there are multiple wizard steps then we will be creating a wizard
		 ------------------------>
		<cfif qwizardSteps.recordcount GT 1>
			
			<!--- Always save wizard WDDX data --->
			<wiz:processwizard excludeAction="Cancel">
			
				<!--- Save the Primary wizard Object --->
				<wiz:processwizardObjects typename="#stobj.typename#" />	
					
			</wiz:processwizard>
			
			<wiz:processwizard action="Save" Savewizard="true" Exit="true" /><!--- Save wizard Data to Database and remove wizard --->
			<wiz:processwizard action="Cancel" Removewizard="true" Exit="true" /><!--- remove wizard --->
			
			
			<wiz:wizard ReferenceID="#stobj.objectid#">
			
				<cfloop query="qwizardSteps">
						
					<cfquery dbtype="query" name="qwizardStep">
					SELECT *
					FROM qMetadata
					WHERE ftwizardStep = '#qwizardSteps.ftwizardStep#'
					ORDER BY ftSeq
					</cfquery>
				
					<wiz:step name="#qwizardSteps.ftwizardStep#">
						

						<cfquery dbtype="query" name="qFieldSets">
						SELECT ftwizardStep, ftFieldset
						FROM qMetadata
						WHERE ftwizardStep = '#qwizardSteps.ftwizardStep#'
						AND ftFieldset <> '#stobj.typename#'
						Group By ftwizardStep, ftFieldset
						ORDER BY ftSeq
						</cfquery>
						
						<cfif qFieldSets.recordCount>
											
							<cfloop query="qFieldSets">
							
								<cfquery dbtype="query" name="qFieldset">
								SELECT *
								FROM qMetadata
								WHERE ftFieldset = '#qFieldsets.ftFieldset#'
								ORDER BY ftSeq
								</cfquery>
								
								<wiz:object ObjectID="#stObj.ObjectID#" lfields="#valuelist(qFieldset.propertyname)#" format="edit" intable="false" legend="#qFieldset.ftFieldset#" helptitle="#qFieldset.fthelptitle#" helpsection="#qFieldset.fthelpsection#" />
							</cfloop>
						<cfelse>
							
							<wiz:object ObjectID="#stObj.ObjectID#" lfields="#valuelist(qwizardStep.propertyname)#" format="edit" intable="false" />
						
						</cfif>
						
						
					</wiz:step>
				
				</cfloop>
				
			</wiz:wizard>	
				
				
				
				
		<!------------------------ 
		If there is only 1 wizard step (typename by default) then we will be creating a simple form
		 ------------------------>		 
		<cfelse>
		
			<cfquery dbtype="query" name="qFieldSets">
			SELECT ftwizardStep, ftFieldset
			FROM qMetadata
			WHERE ftFieldset <> '#stobj.typename#'
			Group By ftwizardStep, ftFieldset
			ORDER BY ftSeq
			</cfquery>
		
		
			<!---------------------------------------
			ACTION:
			 - default form processing
			---------------------------------------->
			<ft:processForm action="Save" Exit="true">
				<ft:processFormObjects typename="#stobj.typename#" />
			</ft:processForm>
			
			<ft:processForm action="Cancel" Exit="true" />
			
			
			
			<ft:form>
		
				<cfif qFieldSets.recordcount GT 1>
					
					<cfloop query="qFieldSets">
						<cfquery dbtype="query" name="qFieldset">
						SELECT *
						FROM qMetadata
						WHERE ftFieldset = '#qFieldsets.ftFieldset#'
						ORDER BY ftSeq
						</cfquery>
						
						<ft:object ObjectID="#arguments.ObjectID#" format="edit" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" inTable="false" IncludeFieldSet="true" Legend="#qFieldSets.ftFieldset#" helptitle="#qFieldset.fthelptitle#" helpsection="#qFieldset.fthelpsection#" />
					</cfloop>
					
					
				<cfelse>
				
					<!--- All Fields: default edit handler --->
					<ft:object ObjectID="#arguments.ObjectID#" format="edit" lExcludeFields="label" lFields="" IncludeFieldSet=1 Legend="#stObj.Label#" />
					
				</cfif>
				
				
				<cfoutput>
				<div class="fieldwrap">
					<ft:farcryButton value="Save" /> 
					<ft:farcryButton value="Cancel" validate="false" />
				</div>
				</cfoutput>
		
			</ft:form>
		</cfif>


	</cffunction>
	
	
	<cffunction name="delete" access="public" hint="Basic delete method for all objects. Deletes content item and removes Verity entries." returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
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

		<!--- write audit trail --->
		<cfif not len(arguments.auditNote)>
			<cfset arguments.auditNote = "#stObj.label# (#stObj.typename#) deleted.">
		</cfif>
		<cfset application.factory.oAudit.logActivity(auditType="Delete", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.objectid)>	

		<cfset stReturn.bSuccess = true>
		<cfset stReturn.message = "#stObj.label# (#stObj.typename#) deleted.">
		<cfreturn stReturn>
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
		
	<cffunction name="fDisplayObjectOverview" returntype="string" output="true">
		<cfargument name="stObject" required="true" type="struct">
		<cfargument name="stPermissions" required="true" type="struct">
	
		<cfset stObject = arguments.stObject>
		<cfset stPermissions = arguments.stPermissions>
		<cfset displayContent = "">
		<cfinclude template="_types/_fDisplayObjectOverview.cfm">
		<cfreturn displayContent>
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
			<cfset stlocal.lObjectids = ListQualify(ArrayToList(instance.stobj.aObjectIDs),"'")>
			<cfset stlocal.lTypeNames = "dmImage,dmFile">
			<cfloop index="stlocal.iTypeName" list="#stlocal.lTypeNames#">
				<cfquery name="stLocal.qUpdateStatus" datasource="#application.dsn#">
				UPDATE	#application.dbowner##stlocal.iTypeName#
				SET		status = '#stproperties.status#'
				WHERE	objectid IN (#preservesinglequotes(stlocal.lObjectids)#)
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
		
		<!--- make sure objectid is not specifically excluded from FU --->
		<cfset bExclude = 0>
		<cfif ListFindNoCase(application.config.fusettings.lExcludeObjectIDs,fuoid)>
			<cfset bExclude = 1>
		</cfif>
		
		<!--- make sure content type requires friendly url --->
		<cfif NOT StructKeyExists(application.types[stObj.typename],"bFriendly") OR NOT application.types[stObj.typename].bFriendly>
			<cfset bExclude = 1>
		</cfif> 
		
		<!--- set friendly url --->
		<cfif NOT bExclude>
			<cfset objTypes = CreateObject("component","#application.types[stObj.typename].typepath#")>
			<cfset stresult_friendly = objTypes.setFriendlyURL(objectid=fuoid)>
		</cfif>

 		<cfreturn stResult>
	</cffunction>

	<cffunction name="setFriendlyURL" access="public" returntype="struct" hint="Default setfriendlyurl() method for content items." output="false">
		<cfargument name="objectid" required="false" default="#instance.stobj.objectid#" type="uuid" hint="Content item objectid.">
		<cfset var stReturn = StructNew()>
		<cfset var stobj = getdata(arguments.objectid)>
		<cfset var stFriendlyURL = StructNew()>
		<cfset var objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
		<cfset var objNavigation = CreateObject("component","#Application.packagepath#.types.dmNavigation")>
		<cfset var qNavigation=querynew("parentid")>
		
		<!--- default return structure --->
		<cfset stReturn.bSuccess = 1>
		<cfset stReturn.message = "Set friendly URL for #arguments.objectid#.">

		<!--- default stFriendlyURL structure --->
		<cfset stFriendlyURL.objectid = stobj.objectid>
		<cfset stFriendlyURL.friendlyURL = "">
		<cfset stFriendlyURL.querystring = "">
		
		<!--- This determines the friendly url by where it sits in the navigation node  --->
		<cfset qNavigation = objNavigation.getParent(stobj.objectid)>
		
		<!--- if its got a tree parent, build from navigation folders --->
		<!--- TODO: this might be better done by checking for bUseInTree="true" 
					or remove it entirely.. ie let tree content have its own fu as well as folder fu
					or set up tree content to have like page1.cfm style suffixs
					PLUS need collision detection so don't overwrite another tree based content item fro utility nav
					PLUS need to exclude trash branch (perhaps just from total rebuild?
					GB 20060117 --->
		<cfif qNavigation.recordcount>
			<cfset stFriendlyURL.friendlyURL = objFU.createFUAlias(qNavigation.parentid)>
		
		<!--- otherwise, generate friendly url based on content type --->
		<cfelse> 
			<cfif StructkeyExists(application.types[stobj.typename],"displayName")>
				<cfset stFriendlyURL.friendlyURL = "/#application.types[stobj.typename].displayName#">
			<cfelse>
				<cfset stFriendlyURL.friendlyURL = "/#ListLast(application.types[stobj.typename].name,'.')#">
			</cfif>
		</cfif>
		
		<!--- set friendly url in database --->
		<cfset stFriendlyURL.friendlyURL = stFriendlyURL.friendlyURL & "/#stobj.label#">
		<cfset objFU.setFU(stFriendlyURL.objectid, stFriendlyURL.friendlyURL, stFriendlyURL.querystring)>
		
		<cflog application="true" file="futrace" text="types.setFriendlyURL: #stFriendlyURL.friendlyURL#" />
 		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="fRebuildFriendlyURLs" access="public" returntype="struct" hint="rebuilds friendly urls for a particular type" output="true">
		<!--- TODO: this is the wrong place for this method! try fu.cfc maybe? GB 20060117 --->
		<cfargument name="typeName" required="true" type="string">
		
		<cfset var stLocal = structnew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">

		<cfquery name="stLocal.qList" datasource="#application.dsn#">
		SELECT	objectid, label
		FROM	#application.dbowner##arguments.typeName#
		WHERE	label != '(incomplete)'
		</cfquery>

		<!--- clean out any friendly url for objects that have been deleted --->
		<cfquery name="stLocal.qDelete" datasource="#application.dsn#">
		DELETE
		FROM	#application.dbowner#reffriendlyURL
		WHERE	refobjectid NOT IN (SELECT objectid FROM #application.dbowner#refObjects)
		</cfquery>

		<!--- delete old friendly url for this type --->
		<cfquery name="stLocal.qDelete" datasource="#application.dsn#">
		DELETE
		FROM	#application.dbowner#reffriendlyURL
		WHERE	refobjectid IN (SELECT objectid FROM #application.dbowner##arguments.typeName#)
		</cfquery>
		
		<cfset stLocal.iCounterUnsuccess = 0>
		<cftry>
			<cfloop query="stLocal.qList">
				<cfset stlocal.stInstance = getData(objectid=stLocal.qList.objectid,bShallow=true)>
				<cfset setFriendlyURL(stlocal.stInstance.objectid)>
			</cfloop>
			<cfcatch>
				<cfset stLocal.iCounterUnsuccess = stLocal.iCounterUnsuccess + 1>
			</cfcatch>
		</cftry>
		<cfset stLocal.iCounterSuccess = stLocal.qList.recordcount - stLocal.iCounterUnsuccess>
		<cfset stLocal.returnstruct.message = "#stLocal.iCounterSuccess# #arguments.typeName# rebuilt successfully.<br />">
 		<cfreturn stLocal.returnstruct>
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
	
</cfcomponent>
