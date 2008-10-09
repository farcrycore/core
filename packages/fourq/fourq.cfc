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
<!------------------------------------------------------------------------
fourQ COAPI
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/fourq.cfc,v 1.43 2005/10/04 01:17:44 guy Exp $
$Author: guy $
$Date: 2005/10/04 01:17:44 $
$Name:  $
$Revision: 1.43 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Introspects current object invocation and determines appropriate table 
structure etc based on the CFC and its extensions, then uses getMetadta()
to build the four queries 
 - SELECT getData()
 - UPDATE setData()
 - INSERT createData()
 - DELETE deleteData()
 
 External Variables :
 FourQ currently depends on the presence of three external variables. These are :
 
 application.dsn -  The applications datasource.
 application.dbtype - Currently supports either 'ora' (oracle 8i++) or 'odbc' (default).
 application.dbowner - This is of most importance if the application is running on
 an Oracle database and the user specified in the applications datasource is not that of the target schemas.  All table names will be preceeded with this variable.

 For example - If the datasource user connects as 'blogmx' - but the target database is actually fourq - then the application.dbowner
 variable should be "fourq."   This means that all queries will actually look in the fourq users schema as opposed to the blogmx schema.

If the application.dbtype is odbc - you may specify application.dbowner as a blank string : '', or alternatively : "<databasename>.dbo. ".
So in the case of a database called 'fourq' - the correct application.dbowner variable would be "fourq.dbo." 
------------------------------------------------------------------------->

<cfcomponent displayname="FourQ COAPI" bAbstract="true">

	<!--- constructor --->
	<cfset instance=structnew()>


	<cffunction name="fourqInit" access="public" returntype="fourq" output="false" hint="Initializes the component instance data">
		<cfif not structKeyExists(variables,'dbFactory')>
			<cfset variables.dbFactory = createObject('component','DBGatewayFactory').init() />
			<cfset variables.gateways = structNew() />
			<cfset variables.tableMetadata = createobject('component','farcry.core.packages.fourq.TableMetadata').init() />
			<cfset tableMetadata.parseMetadata(getMetadata(this)) />	
			
			<cfset variables.objectBroker = createObject("component", "farcry.core.packages.fourq.objectBroker").init() />
			
			<cfset variables.typename = variables.tableMetadata.getTableName() />
		
		</cfif>
		

		<cfreturn this />
	</cffunction>
  
  	<cffunction name="getDefaultObject" access="public" output="true" returntype="struct">
		<cfargument name="ObjectID" required="false" type="UUID">
		<cfargument name="typename" required="yes" type="string" default="#getTablename()#">	
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	   	<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var stDefaultProperties = structNew() />
		<cfset var qRefDataDupe = queryNew("blah") />
		<cfset var qRefData = queryNew("blah") />
		<cfset var qObjectDupe = queryNew("blah") />
		<cfset var userlogin = "" />
		<cfset var dmProfileID = "" />
		<cfset var stProps = structNew() />
		<cfset var PrimaryPackage = "" />
		<cfset var PrimaryPackagePath = "" />
		<cfset var propertie = "" />
		
		
		
		<cfif application.security.isLoggedIn()>
			<cfset userlogin = application.security.getCurrentUserID()>
		<cfelse>
			<cfset userlogin = "Unknown">
		</cfif>
		<cfif isDefined("session.dmProfile.objectid")>
			<cfset dmProfileID = session.dmProfile.objectid>
		<cfelse>
			<cfset dmProfileID = "">
		</cfif>
		
		<cfset stProps=structNew()>
		<cfif isDefined("arguments.ObjectID") and len(arguments.ObjectID)>
			<cfset stProps.objectid = arguments.ObjectID>
		<cfelse>
			<cfset stProps.objectid = CreateUUID()>
		</cfif>
		
		<cfset stProps.typename = arguments.typename>
		
		<cfset stProps.label = "(incomplete)">
		<cfset stProps.lastupdatedby = userlogin>
		<cfset stProps.datetimelastupdated = Now()>
		<cfset stProps.createdby = userlogin>
		<cfset stProps.datetimecreated = Now()>
		<cfset stProps.ownedby = dmProfileID>
		
		
		<cfif structKeyExists(application.types, arguments.typename)>
			<cfset PrimaryPackage = application.types[arguments.typename] />
			<cfset PrimaryPackagePath = application.types[arguments.typename].typepath />
		<cfelseif structKeyExists(application.rules, arguments.typename)>
			<cfset PrimaryPackage = application.rules[arguments.typename] />
			<cfset PrimaryPackagePath = application.rules[arguments.typename].rulepath />
		<cfelse>
			<!--- ie component is not a content type but still extends fourq.. eg. container.cfc --->
			<cfreturn structNew() />
		</cfif>
		
			
		
		<cfset stDefaultProperties = PrimaryPackage.stProps>
		

		<!--- loop through the default content type properties --->
		<cfloop collection="#stDefaultProperties#" item="propertie">
			<!--- check if date type, and set default to the default assigned OR to now() --->
			
			<cfif NOT StructKeyExists(stProps, propertie)>
						
				<cfparam name="stDefaultProperties[propertie].metadata.Default" default="">
				<cfparam name="stDefaultProperties[propertie].metadata.ftDefaultType" default="value">
				<cfparam name="stDefaultProperties[propertie].metadata.ftDefault" default="#stDefaultProperties[propertie].metadata.Default#">
				
						
				
				<cfif stDefaultProperties[propertie].metadata.type eq "array"> 
					<!--- set to the default if it is not already defined above --->
					<cfset stProps[propertie] = arrayNew(1)>
				<cfelse>
					
					<cfswitch expression="#stDefaultProperties[propertie].metadata.ftDefaultType#">
						<cfcase value="Evaluate">
							<cfset stProps[propertie] = Evaluate(stDefaultProperties[propertie].metadata.ftDefault)>
						</cfcase>
						<cfcase value="Expression">
							<cfset stProps[propertie] = Evaluate(DE(stDefaultProperties[propertie].metadata.ftDefault))>
						</cfcase>
						<cfdefaultcase>
							<cfset stProps[propertie] = stDefaultProperties[propertie].metadata.ftDefault>
						</cfdefaultcase>
					</cfswitch>
					
				</cfif>
				
				
			</cfif>
		</cfloop>
				


		<cfquery datasource="#arguments.dsn#" name="qRefDataDupe">
		SELECT ObjectID FROM #arguments.dbowner#refObjects
		WHERE ObjectID = <cfqueryparam value="#stProps.objectid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfif NOT qRefDataDupe.RecordCount>			
		<!--- If note in refObjects we have no problem --->
			
			<!--- create lookup ref for default type --->
			<cfquery datasource="#arguments.dsn#" name="qRefData">
				INSERT INTO #arguments.dbowner#refObjects (
					objectID, 
					typename
				)
				VALUES (
					<cfqueryparam value="#stProps.objectid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#stProps.typename#" cfsqltype="CF_SQL_VARCHAR">
				)
			</cfquery>
		
		 
		<cfelse>
			<!--- 
				If its already in Ref Objects we have to work out if it was created during a previous Default Object Call
				We do this by seeing if the objectID exists in the actual type table. If it does, then it means it was a real objectID and we have a problem.
			--->
			<cfquery datasource="#arguments.dsn#" name="qObjectDupe">
			SELECT ObjectID FROM #arguments.dbowner##stProps.typename#
			WHERE ObjectID = <cfqueryparam value="#stProps.objectid#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			
			<cfif qObjectDupe.RecordCount>
				<cfabort showerror="Error Executing Database Query. Duplicate ObjectID #stProps.objectid#" />
			</cfif>
		
		</cfif>
		
		<cfreturn stProps>
	</cffunction>
	
	
	<cffunction name="getGateway" access="private" output="false" returntype="farcry.core.packages.fourq.gateway.DBGateway" hint="Gets the gateway for the given db connection parameters">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		
		<cfif not structKeyExists(variables.gateways,arguments.dsn)>
			<cfset variables.gateways[arguments.dsn] = variables.dbFactory.getGateway(arguments.dsn,arguments.dbowner,arguments.dbtype) />
		</cfif>
		
		<cfreturn variables.gateways[arguments.dsn] />
	</cffunction>
	

	
	<!---
	 ************************************************************
	 *                                                          *
	 *                DEPLOYMENT METHODS                        *
	 *                                                          *
	 ************************************************************
	 --->
 
 
 	<cffunction name="deployType" access="public" returntype="struct" output="false">
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
    	<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="bDeployCoapiRecord" type="boolean" required="false" default="true">
    
    	<cfset var stResult = structNew()>
		<cfset var gateway = "" />
		<cfset var stClass = "" />
    
    	<cfset fourqInit() />
    
		<cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner)  />
		<cfset stResult = gateway.deployType(variables.tableMetaData,arguments.bDropTable,arguments.bTestRun) />
		
		<cfif stResult.bSuccess AND bDeployCoapiRecord>
			<!--- MAKE SURE THAT THE farCOAPI record exists for this type. --->
			<cfset stClass = createObject("component", application.stcoapi.farCoapi.packagepath).getCoapiObject(name="#variables.typename#") />
		</cfif>
		
		<cfreturn stResult>
	</cffunction>
	
	

 	<cffunction name="deployRefObjects" access="public" returntype="struct" output="false">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var stResult = structNew()>
		<cfset var gateway = "" />
     
	    <cfset fourqInit() />
	    
	    <cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner)  />
		
		<cfset stResult = gateway.deployRefObjects(arguments.bDropTable) />
		
		<cfreturn stResult>
	</cffunction>

 	<cffunction name="deployArrayTable" access="public" returntype="struct" output="false">
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">
		<cfargument name="parent" type="string" required="true">
		<cfargument name="property" type="string" required="true">
		<cfargument name="datatype" type="string" required="false" default="String">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var stResult = structNew()>
		<cfset var gateway = "" />
	    <cfset var fields = "" />
		<cfset var md = structNew() />
	
	    <cfset fourqInit() />
	    
	    <cfset md = getMetaData()>
	    
	    <cfset fields = variables.tableMetaData.getTableDefinition() />
	    
	    <cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
		
		<cfset stResult = gateway.deployArrayTable(fields[arguments.property].fields,variables.tableMetaData.getTablename()&"_"&arguments.property,arguments.bDropTable,arguments.bTestRun) />
		
		<cfreturn stResult>
	</cffunction>


	<!---
	 ************************************************************
	 *                                                          *
	 *                     CRUD METHODS                         *
	 *                                                          *
	 ************************************************************
	 --->
 
	<cffunction name="createData" access="public" output="true" returntype="struct" hint="Create an object including array properties.  Pass in a structure of property values; arrays should be passed as an array. The objectID can be ommitted and one will be created, passed in as an argument or passed in as a key of stProperties argument.">
		<cfargument name="stProperties" type="struct" required="true">
		<cfargument name="objectid" type="UUID" required="false" default="#createUUID()#">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">

    	<cfset var gateway = "" />
		<cfset var stReturn = StructNew()>
    	<cfset fourqInit() />
    	<cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
		<cfset stReturn = gateway.createData(stProperties,objectid,variables.tableMetadata)>
		<cfif NOT stReturn.bSuccess>
			<cflog text="#stReturn.message# #stReturn.detail# [SQL: #stReturn.sql#]" file="coapi" type="error" application="yes">
		</cfif>
    	<cfreturn  stReturn />
	</cffunction>


	<cffunction name="getData" access="public" output="true" returntype="struct" hint="Get data for a specific objectid and return as a structure, including array properties and typename.">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="bShallow" type="boolean" required="false" default="false" hint="Setting to true filters all longchar property types from record.">
		<cfargument name="bFullArrayProps" type="boolean" required="false" default="true" hint="Setting to true returns array properties as an array of structs instead of an array of strings IF IT IS AN EXTENDED ARRAY.">
		<cfargument name="bUseInstanceCache" type="boolean" required="false" default="true" hint="setting to use instance cache if one exists">
		<cfargument name="bArraysAsStructs" type="boolean" required="false" default="false" hint="Setting to true returns array properties as an array of structs instead of an array of strings.">
		
		<cfset var stobj=structnew()>
		<cfset var aprops="">
		<cfset var sqlSelect="">
		<cfset var i=0>
		<cfset var qgetData="">
		<cfset var key="">
		<cfset var qArrayData="">
		<cfset var aTmp=arraynew(1)>
		<cfset var stArrayProp=structnew()>
		<cfset var col=0>
		<cfset var j=0>
		<cfset var stPackage = structNew() />
		<cfset var fieldname = "" />
		<cfset var stobjDisplay = structNew() />
		<cfset var oType = "" />
		<cfset var addedtoBroker = "" />
		<cfset var tempObjectStore = structNew() />
		
		<cfset instance = structNew() />
		
		<!--- init fourq --->
		<cfset fourqInit() />	
		
		
		<!---------------------------------------------------------------
		Create a reference to the tempObjectStore in the session.
		This is done so that if the session doesn't exist yet (in the case of application.cfc applicationStart), we can trap the error and continue on our merry way.
		 --------------------------------------------------------------->
		<cftry>
			<cfif structKeyExists(session, "TempObjectStore")>
				<cfset tempObjectStore = Session.TempObjectStore />
			</cfif>
			<cfcatch type="any">
				<!--- ignore the error and assume it just doesnt exist yet.  --->
			</cfcatch>
		</cftry>
		
		
		<cfif isdefined("instance.bgetdata") AND instance.bgetdata EQ arguments.objectid AND arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs>
			<!--- get local instance cache --->
			<cfset stObj = instance.stobj>

		<!--- Check to see if the object is in the temporary object store --->
		<cfelseif arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs AND structKeyExists(tempObjectStore,arguments.objectid)>
			<!--- get from the temp object stroe --->
			<cfset stObj = tempObjectStore[arguments.objectid] />

		<cfelse>
			<cfif arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs>
				<!--- Attempt to get the object from the ObjectBroker --->
				<!--- getFromObjectBroker returns an empty struct if the object is not in the broker --->
				<cfset stobj = variables.objectBroker.getFromObjectBroker(ObjectID=arguments.objectid,typename=variables.typename)>
			</cfif>

			<cfif structisEmpty(stObj)>
				
				<!--- Didn't find the object in the objectBroker --->
				<!--- build a local instance cache --->
				<cfinclude template="_fourq/getData.cfm">	
				
				
				<!--- MJB TODO: This piece of code needs to be added somewhere to allow the access to any field that has been run through the relevent display function of its formtool cfc  --->
				<!--- 
				<cfset stobjDisplay = structNew() />
				<cfif structKeyExists(application.stcoapi, stobj.typename)>
					
					<cfif structKeyExists(application.stcoapi[stobj.typename], "stMethods") AND structKeyExists(application.stcoapi[stobj.typename].stMethods, "getField")>						
						<cfloop list="#structKeyList(stobj)#" index="fieldname">
							<cfif NOT listFindNoCase("ftDisplayFields,typename",fieldname)>
								
								<cfset oType = createObject("component", application.stcoapi[stobj.typename].packagePath) />
								<cfset stobjDisplay[fieldname] = oType.getField(stobject=stobj, fieldname=fieldname) />
							</cfif>
						</cfloop>
					<cfelse>
						<cfloop list="#structKeyList(stobj)#" index="fieldname">
							<cfif NOT listFindNoCase("ftDisplayFields,typename",fieldname)>
								<cfset stobjDisplay[fieldname] = stobj[fieldname] />
							</cfif>
						</cfloop>		
					</cfif>	
					
								
				</cfif> --->
			
				
				<!--- <cftrace type="information" category="coapi" var="stobj.typename" text="getData() used database."> --->
			
				<!--- Attempt to add the object to the broker --->
				<cfif NOT arguments.bArraysAsStructs AND NOT arguments.bShallow>
					<cfset addedtoBroker = variables.objectBroker.AddToObjectBroker(stobj=stobj,typename=variables.typename)>
	
					
					<!--- <cfif addedToBroker> --->
						<!--- Successfully added object to the broker --->
						<!--- <cftrace type="information" category="coapi" var="arguments.objectid" text="getData() added object to Broker.">
					</cfif>
					 --->
				</cfif>
			</cfif>	

		</cfif>
		
		<!--- 
		The object has not been found anywhere (Instance, Temporary Object Store, Object Broker, Database)
		We therefore need to return a default object of this typename.
		 --->
		<cfif NOT structKeyExists(stObj,'objectID')>
			<cfset stObj = getDefaultObject(argumentCollection=arguments)>	
			<cfset stObj.bDefaultObject = true />
		</cfif>
		

		<cfif NOT structisempty(stobj)>
			<cfset instance.stobj = stobj>
			<cfset instance.stobj.typename = variables.typename>
			<cfset instance.bgetData = arguments.objectid>
		</cfif>	

		<cfreturn stObj>
	</cffunction>

	

	<cffunction name="setData" access="public" output="false" returntype="struct" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
		<cfargument name="bSessionOnly" type="string" required="false" default="false">
		
	    <cfset var stResult = StructNew() />
	    <cfset var gateway = "" />
	    <cfset var stDefaultProperties = "" />

	    
	    <cfset fourqInit() />
	    <cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
	    	    
		
		<!--- Make sure that the temporary object store exists in the session scope. --->
		<cfparam name="Session.TempObjectStore" default="#structNew()#" />

		
		<!--------------------------------------- 
		If the object is to be stored in the session scope only.
		----------------------------------------->		
		<cfif arguments.bSessionOnly>
		
			<!--- Make sure an object id exists. --->
			<cfparam name="stProperties.ObjectID" default="#CreateUUID()#" />				
			
			<!--- Get the default properties for this object --->
			<cfset stDefaultProperties = this.getData(objectid=arguments.stProperties.ObjectID,typename=variables.typename) />
		  	
		  	<!--- need to add this in case the object has been put in the instance cache in the getdata above. --->
	   	 	<cfset structdelete(instance,"bgetdata")>
	    	
			<!--- 
			Append the default properties of this object into the properties that have been passed.
			The overwrite flag is set to false so that the default properties do not overwrite the ones passed in.
			 --->
			<cfset StructAppend(arguments.stProperties,stDefaultProperties,false)>	
						
			<!--- Add object to temporary object store --->
			<cfset Session.TempObjectStore[arguments.stProperties.ObjectID] = arguments.stProperties />
			
			<cfset stResult.bSuccess = true />
			<cfset stResult.message = "Object Saved to the Temporary Object Store." />
			<cfset stResult.ObjectID = arguments.stProperties.ObjectID />
			
			
			
		<!--------------------------------------- 
		If the object is to be stored in the Database then run the appropriate gateway
		----------------------------------------->	
	   	<cfelse>			<!--- Make sure we remove the object from the objectBroker if we update something --->
		    <cfif structkeyexists(stProperties, "objectid")>
			    <cfset variables.objectBroker.RemoveFromObjectBroker(lObjectIDs=arguments.stProperties.ObjectID,typename=variables.typename)>
		    </cfif>	    	   	
		   	
		    <!--- need to add this in case the object has been put in the instance cache. --->
		    <cfset structdelete(instance,"bgetdata")>	
	   	
	   		
	   		<cfset stResult = gateway.setData(stProperties=arguments.stProperties,metadata=variables.tableMetadata,dsn=arguments.dsn) />	   	
	   	 
	    
		   	<!--- Make sure we remove the object from the TempObjectStore if we update something --->
	   		<cfif structKeyExists(session, "TempObjectStore") AND structKeyExists(Session.TempObjectStore,arguments.stProperties.ObjectID)>
		   		<cfset structdelete(Session.TempObjectStore, arguments.stProperties.ObjectID) />
		   	</cfif>
		   		   	 
	   	</cfif>		   	
	   	
		<cfreturn stResult />
		
	</cffunction>
		
	<cffunction name="deleteData" access="public" output="false" returntype="struct" hint="Delete the specified objectid and corresponding data, including array properties and refObjects.">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<!--- set status here... if something goes wrong expect a thrown error --->
		<cfset var stResult = structNew()>
		<cfset var stobj = structNew() />
		
		<cfset stResult.bSuccess = true>
		<cfset stResult.message = "Object deleted successfully">
		
		<cfset stobj = getData(objectid=arguments.objectid)>
		
			
	   	<!--- Make sure we remove the object from the TempObjectStore if we update something --->
	   	<cfif structKeyExists(session, "TempObjectStore") AND structKeyExists(Session.TempObjectStore,arguments.ObjectID)>	
	   		<cfset structdelete(Session.TempObjectStore, arguments.ObjectID) />
	   	</cfif>
	   				
	    <!--- Make sure we remove the object from the objectBroker if we update something --->
	    <cfset variables.objectBroker.RemoveFromObjectBroker(lObjectIDs=arguments.ObjectID,typename=variables.typename)>
	    
		<cfinclude template="_fourq/deleteData.cfm">
		
		
		<cfreturn stResult>
	</cffunction>
	
	
	
	
	<!---
	 ************************************************************
	 *                                                          *
	 *             NON CRUD DB ACCESS METHODS                   *
	 *                                                          *
	 ************************************************************
	 --->
	
	
		
	<cffunction name="getMultiple" access="public" hint="Get multpile objects of a particular type" ouput="false" returntype="struct">
		<cfargument name="dsn" type="string" required="yes" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="lObjectIDs" type="string" required="false" default="" hint="Restrict resultset to a comma delimited list of objectids.">
		<cfargument name="OrderBy" type="string" required="false" default="" hint="Comma delimited list of properties to order by. Known issue: method returns a struct which randomises sort order :(">
		<cfargument name="SortOrder" type="string" required="false" default="asc" hint="asc or desc options.">
		<cfargument name="conditions" type="struct" required="false" default="#structNew()#" hint="Query filter; pass in structure keyed by property and with a value equal to the desired filter.">
		<cfargument name="whereclause" type="string" required="false" default="">
		
		<cfset var tn = getTableName()>
		<cfset var stProps = getPropsAsStruct()>
		<cfset var gateway = "" />
		<cfset fourqInit() />
		
  	  	<cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
		<cftrace inline="false" type="warning" text="The use of getMultiple is not encouraged. This method will probably be deprecated in future revisions of farcry. It is recommended to use getMultipleByQuery instead">
		<cfreturn gateway.getMultiple(tn,stProps,arguments.lObjectIDs,arguments.orderBy,arguments.sortOrder,arguments.conditions,arguments.whereClause) />
		
	</cffunction>
	
	<cffunction name="getMultipleByQuery" access="public" hint="Get multpile records of a paticular type" ouput="false" returntype="query">
		<cfargument name="dsn" type="string" required="yes" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="lObjectIDs" type="string" required="false" default="" hint="Restrict resultset to a comma delimited list of objectids.">
		<cfargument name="OrderBy" type="string" required="false" default="" hint="Comma delimited list of properties to order by. Known issue: method returns a struct which randomises sort order :(">
		<cfargument name="SortOrder" type="string" required="false" default="asc" hint="asc or desc options.">
		<cfargument name="conditions" type="struct" required="false" default="#structNew()#" hint="Query filter; pass in structure keyed by property and with a value equal to the desired filter.">
		<cfargument name="whereclause" type="string" required="false" default="">
		<cfargument name ="maxRows" required="false" type="numeric" default="-1">
		
		<cfset var tn = getTableName()>
		<cfset var stProps = getPropsAsStruct()>
		<cfset var gateway = "" />
		<cfset fourqInit() />
		
    	<cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
		
		<cfreturn gateway.getMultipleByQuery(tn,stProps,arguments.lObjectIDs,arguments.orderBy,arguments.sortOrder,arguments.conditions,arguments.whereClause,arguments.maxRows) />
		
	</cffunction>
	

	
	<cffunction name="findType" access="public" output="false" returntype="string" hint="Determine the typename for an objectID.">
		<cfargument name="objectid"  required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var qFindType="">
		<cfset var result = "" />
		
		<cfquery datasource="#arguments.dsn#" name="qFindType">
		select typename from #arguments.dbowner#refObjects
		where objectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectID#" />
		</cfquery>
		
		<cfif qFindType.recordCount>
			<cfset result = qFindType.typename />
		<cfelse>		
			<cfif structKeyExists(Session, "TempObjectStore") 
				AND structKeyExists(Session.TempObjectStore, "#arguments.objectid#")
				AND structKeyExists(Session.TempObjectStore["#arguments.objectid#"], "typename")>
				
				<cfset result = Session.TempObjectStore["#arguments.objectid#"].typename />
			</cfif>
		</cfif>
		
		<!--- 
		$ TODO: resolve upstream errors
		<cfif NOT qgetType.recordCount>
			<cfthrow type="fourq" detail="<b>Invalid reference:</b> object #arguments.objectID# is not in refObjects table">
		</cfif> 
		$
		--->

		<cfreturn result />
	</cffunction>
	
	
	<cffunction name="setMultiple" access="public" hint="Set a single property for multpile objects of a particular type" ouput="false" returntype="boolean">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="dbowner" type="string" required="yes">
		<cfargument name="prop" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfargument name="whereclause" type="string" required="false" default="WHERE 0=1">
		
		<cfset var tn = this.getTableName()>
		<cfset var stProps = this.getPropsAsStruct()>
		<cfset var gateway = "" />
		
		<cftrace inline="false" type="warning" text="The use of setMultiple is not encouraged. This method will probably be deprecated in future revisions of farcry.">
		
		<cfset fourqInit() />
		<cfset gateway = getGateway(arguments.dsn,application.dbtype,applicaiton.dbowner) />
		
		<cfset gateway.setMultiple(tn,stProps,arguments.prop,arguments.value,arguments.whereClause) />
		
		<cfreturn true>
	</cffunction>
	
	
	
	
	<!---
	 ************************************************************
	 *                                                          *
	 *                  METADATA METHODS                        *
	 *                                                          *
	 ************************************************************
	 --->
	
	

	<cffunction name="getTablename" access="public" returntype="string" output="false">
		
		<cfset fourqInit() />
    
		<cfreturn variables.tableMetadata.getTableName() />
		
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="array" output="false">
		<!--- 
		we need to get an array of all the properties for this instance 
		*including* inherited properties that have not been overloaded
		20020518 GB
		 --->
		 <cfset var stExtends = structNew()>		 
		<cfset var md=getMetaData(this)>
		<!--- container for processed propertynames --->
		<cfset var lPropsProcessed = "">
		<cfset var aProps = ArrayNew(1)>
		<cfset var prop = "">
		<cfset var thisprop = "">
		
		<cftrace inline="false" type="warning" text="The getProperties() method in fourq is deprecated. Use variables.tableMetadata.getTableDefinition() instead.">
		
		<!--- build props for object type. Note that its possible that a component doesn't have any properties PH--->
		<cfif structKeyExists(md,"properties")>
			<cfloop from=1 to="#arraylen(md.properties)#" index="prop">
				<cfset thisprop = md.properties[prop]>
				<cfset ArrayAppend(aProps, md.properties[prop])>
				<cfset lPropsProcessed = ListAppend(lPropsProcessed, thisprop.name)>
			</cfloop>
		</cfif>
			
		<cfscript>
			finished = false;
			if(isStruct(md.extends))
				stExtends = md.extends;
			else
				stExtends = structNew();	
			while(NOT finished)
			{								
				if (structKeyExists(stExtends,'properties'))
				{					
					for (prop = 1;prop LTE arraylen(stExtends.properties);prop=prop+1)
					{
						thisprop = stExtends.properties[prop];
						// check for overloading 
						if (NOT ListFindNoCase(lPropsProcessed, thisprop.name))
						{
							  ArrayAppend(aProps, stExtends.properties[prop]);
							  ListAppend(lPropsProcessed, thisprop.name);
						}
						
					}
					
				}
				if (structKeyExists(stExtends,'extends') AND NOT structIsEmpty(stExtends.extends))
				{			
					
					stExtends = stExtends.extends;
				}
				else
				{
					finished=true;
				}	
			}
		</cfscript>
		
		<cfreturn aProps />
	</cffunction>
	
	<!--- private functions --->
	<cffunction name="getAncestors" hint="Get all the extended components as an array of isolated component metadata." returntype="array" access="private" output="false">
		<cfargument name="md" required="Yes" type="struct">
			<cfset var aAncestors = arrayNew(1)>
			<cfscript>	
				if (structKeyExists(md, 'extends'))
					aAncestors = getAncestors(md.extends);
				arrayAppend(aAncestors, md);
			</cfscript>
		<cfreturn aAncestors>
	</cffunction>

	<cffunction name="getMethods" access="public" hint="Get a structure of all methods, including extended, for this component" returntype="struct" output="false">
		<cfset var aAncestors = getAncestors(getMetaData(this))>
		<cfset var methods = StructNew()>
		<cfset var curAncestor = "">
		<cfset var curMethod = "">
		
		<cfscript>
		for ( i=1; i lte ArrayLen(aAncestors); i=i+1 ) {
			curAncestor = aAncestors[i] ;
			
			if ( StructKeyExists( curAncestor, 'functions' ) )
				for ( j=1; j lte ArrayLen( curAncestor.functions ); j=j+1 ) {
					curMethod = StructNew() ;
					curMethod.metadata = curAncestor.functions[j] ;
					curMethod.Origin = curAncestor.name ;
					if ( i eq ArrayLen(aAncestors)
					// don't exclude any method 1)from this
						or not StructKeyExists( curMethod.metadata, 'access' )
					// 2)that does not have 'access' attribute
						or curMethod.metadata.access neq 'private' ) {
					// 3)that does not have access='private'
						methods[curmethod.metadata.name] = curMethod ;
					}
				}
		
		}
		</cfscript>
		<cfreturn methods>
	</cffunction>
	
	<cffunction name="getPropsAsStruct" returntype="struct" hint="Get all extended properties and return as a flattened structure." access="public" output="false">
		<cfset var aAncestors = getAncestors(getMetaData(this))>
		<cfset var stProperties = StructNew()>
		<cfset var curAncestor = "">
		<cfset var curProperty = "">
		<cfset var i = "">
		<cfset var j = "">
		
		<cfloop index="i" from="1" to="#ArrayLen(aAncestors)#">
			<cfset curAncestor = aAncestors[i]>
			<cfif StructKeyExists(curAncestor,"properties")>
				<cfloop index="j" from="1" to="#ArrayLen(curAncestor.properties)#">
					<cfset curProperty = StructNew()>

					<!--- make sure all metadata has a default and required --->
					<cfif NOT StructKeyExists(curAncestor.properties[j],"required")>
						<cfset curAncestor.properties[j].required = "no">
					</cfif>
					
					<cfif NOT StructKeyExists(curAncestor.properties[j],"default")>
						<cfset curAncestor.properties[j].default = "">
					</cfif>
				
					<cfset curProperty.metadata = curAncestor.properties[j]>
					<cfset curProperty.origin = curAncestor.name>
					<cfset stProperties[curProperty.metadata.name] = curProperty>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn stProperties>
	</cffunction>
	
	<cffunction name="mergeWebskins" access="private" hint="Merge webskin result queries, skipping duplicates. Non destructive." output="false" returntype="query">
		<cfargument name="query1" type="query" required="true" />
		<cfargument name="query2" type="query" required="true" />
		
		<cfset var qDupe = "" />
		<cfset var qResult = duplicate(arguments.query1)>

		<cfloop query="arguments.query2">

			<!--- Check to see if query1 already contains this webskin --->
			<cfquery dbtype="query" name="qDupe">
				SELECT	*
				FROM	qResult
				WHERE	name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.query2.name[currentrow]#" />
			</cfquery>
			
			<!--- If it doesn't, add it --->
			<cfif NOT qDupe.Recordcount>
				<cfset queryaddrow(qResult,1) />
				<cfloop list="#arguments.query2.columnlist#" index="col">
					<cfset querysetcell(qResult, col, arguments.query2[col][currentrow]) />
				</cfloop>
			</cfif>
			
		</cfloop>
		
		<cfreturn qResult>
	</cffunction>
	
	<cffunction name="paramMetaData" access="private" hint="Set up default values for missing meta data attributes. Non destructive." output="false" returntype="struct">
		<cfargument name="stProps" type="struct" required="true" />
		<cfargument name="lAttributes" type="string" required="true" />
		<cfargument name="default" type="string" />
		
		<cfset var stResult = duplicate(arguments.stProps)>
		
		<cfloop collection="#stResult#" item="prop">
			<cfloop list="#arguments.lAttributes#" index="att">
				<cfif not structkeyexists(stResult[prop].metadata,att)>
					<cfif structkeyexists(arguments,"default")>
						<cfset stResult[prop].metadata[att] = arguments.default />
					<cfelseif prop eq "ftType">
						<cfset stResult[prop].metadata[att] = stResult[prop].metadata.type />
					<cfelseif prop eq "ftLabel">
						<cfset stResult[prop].metadata[att] = stResult[prop].metadata.name />
					<cfelse>
						<cfset stResult[prop].metadata[att] = "" />
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="initMetaData" access="public" hint="Extract all component metadata in a flat format for loading into a shared scope." output="true" returntype="struct">
		<cfargument name="stMetaData" type="struct" required="false" default="#structNew()#" hint="Structure to which this cfc's parameters are appended" />
	
		<cfset var stReturnMetadata = arguments.stMetaData />
		<cfset var stNewProps = getPropsAsStruct() />
		<cfset var md = getMetaData(this) />		
		<cfset var componentname = getTablename() />
		<cfset var key="" />
		<cfset var i=0 />
		<cfset var j=0 />
		<cfset var k=0 />		
		<cfset var filteredWebskins = "" />
		<cfset var filterWebskinName = "" />
		<cfset var filterWebskinTimeout = "" />
		<cfset var col = "">
		<cfset var ixFilter = "">
		<cfset var qDupe = queryNew("blah") />
		<cfset var qFilter = queryNew("blah") />
		<cfset var qExtendedWebskin = queryNew("blah") />
		<cfset var extendedWebskinName = "">
		<cfset var aFilteredWebskins = arrayNew(1) />
		<cfset var stFilterDetails = structNew() />
		
		<!--- If we are updating a type that already exists then we need to update only the metadata that has changed. --->
		<cfparam name="stReturnMetadata.stProps" default="#structnew()#" />
		<cfset stReturnMetadata.stProps = application.factory.oUtils.structMerge(stReturnMetadata.stProps,stNewProps) />

		<!--- Make sure ALL properties have an ftType, ftLabel,ftStyle and ftClass set. If not explicitly set then use defaults. --->
		<cfset stReturnMetadata.stProps = paramMetaData(stReturnMetadata.stProps,"ftType,ftLabel,ftStyle,ftClass,ftValidation") />

		<!--- This will get the components methods and any methods that are from super cfc's --->
		<cfset stReturnMetadata.stMethods = getMethods()>	
		
		<!--- add any extended component metadata --->
		<cfloop collection="#md#" item="key">
			<cfif key neq "PROPERTIES" AND key neq "EXTENDS" AND key neq "FUNCTIONS" AND key neq "TYPE">
				<cfset stReturnMetadata[key] = md[key] />				
			</cfif>
		</cfloop>
		
		<!--- Param component metadata --->
		<cfparam name="stReturnMetadata.displayname" default="#listlast(stReturnMetadata.name,'.')#" />
		
		<!--- This sets up the array which will contain the name of all types this type extends --->
		<cfset stReturnMetadata.aExtends = application.coapi.coapiadmin.getExtendedTypeArray(packagePath=md.name)>
		
		<!--- Set up default attributes --->
		<cfparam name="stReturnMetadata.bAutoSetLabel" default="true" />
		<cfparam name="stReturnMetadata.bObjectBroker" default="false" />
		<cfparam name="stReturnMetadata.lObjectBrokerWebskins" default="" />
		<cfparam name="stReturnMetadata.ObjectBrokerWebskinTimeOut" default="1400" /> <!--- This a value in minutes (ie. 1 day) --->
 		<cfparam name="stReturnMetadata.excludeWebskins" default="" /> <!--- This enables projects to exclude webskins that may be contained in plugins. ---> 

		<!--- Get webkins: webskins for this type, then webskins for extends types --->
		<cfset stReturnMetadata.qWebskins = application.coapi.coapiAdmin.getWebskins(typename="#componentname#", bForceRefresh="true", excludeWebskins="#stReturnMetadata.excludeWebskins#") />

		<cfloop list="#arrayToList(stReturnMetadata.aExtends)#" index="i">
			<cfset stReturnMetaData.qWebskins = mergeWebskins(stReturnMetaData.qWebskins, application.coapi.coapiAdmin.getWebskins(typename=i, bForceRefresh="true", excludeWebskins="#stReturnMetadata.excludeWebskins#")) />
		</cfloop>

		<!--- 
		NEED TO LOOP THROUGH ALL THE WEBSKINS AND CHECK EACH ONE FOR WILDCARDS.
		IF WILD CARDS EXIST, FIND ALL WEBSKINS THAT MATCH AND ADD THEM TO THE LIST
		 --->
		<cfset aFilteredWebskins = arrayNew(1) />
		
		<cfloop list="#stReturnMetadata.lObjectBrokerWebskins#" index="ixFilter">
		
			<cfset filterWebskinName = replaceNoCase(listFirst(ixFilter,":"),"*", "%", "all") />
			<cfif listLast(ixFilter,":") NEQ listFirst(ixFilter,":") AND isNumeric(listLast(ixFilter,":")) AND listLast(ixFilter,":") GTE 0>
				<cfset filterWebskinTimeout = listLast(ixFilter,":")>
			<cfelse>
				<cfset filterWebskinTimeout = stReturnMetadata.ObjectBrokerWebskinTimeOut />
			</cfif>
			
			<cfquery dbtype="query" name="qFilter" result="res">
			SELECT * 
			FROM stReturnMetadata.qWebskins
			<cfif FindNoCase("%", filterWebskinName)>
				WHERE methodname like '#filterWebskinName#'
			<cfelse>
				WHERE methodname = '#filterWebskinName#'			
			</cfif>
			</cfquery>
			
			<cfloop query="qFilter">
				
				<cfset stFilterDetails = structNew() />
				<cfset stFilterDetails.methodname = qFilter.methodname />
				<cfset stFilterDetails.WebskinTimeout = filterWebskinTimeout />
				<cfset arrayAppend(aFilteredWebskins, stFilterDetails) />

			</cfloop>
		</cfloop>
	
		<!--- NOW THAT WE HAVE ALL THE WEBSKINS TO BE CACHED, ADD THE DETAILS TO stObjectBrokerWebskins --->
		<cfset stReturnMetadata.stObjectBrokerWebskins = structNew() />
		
		<!--- Initialize lObjectBrokerWebskins because we are going to re-add them without any timeout values in the list --->
		<cfset stReturnMetadata.lObjectBrokerWebskins = "" />
		
		<cfif arrayLen(aFilteredWebskins)>
			<cfloop from="1" to="#arrayLen(aFilteredWebskins)#" index="i">
			
				<cfif not structKeyExists(stReturnMetadata.stObjectBrokerWebskins, aFilteredWebskins[i].methodname)>
					<cfset stReturnMetadata.stObjectBrokerWebskins[aFilteredWebskins[i].methodname] = structNew() />
					<cfset stReturnMetadata.stObjectBrokerWebskins[aFilteredWebskins[i].methodname].timeout = aFilteredWebskins[i].webskinTimeout>
					<cfset stReturnMetadata.stObjectBrokerWebskins[aFilteredWebskins[i].methodname].hashURL = application.coapi.coapiadmin.getWebskinHashURL(typename="#componentname#", template="#aFilteredWebskins[i].methodname#") />
					<cfset stReturnMetadata.stObjectBrokerWebskins[aFilteredWebskins[i].methodname].displayName = application.coapi.coapiadmin.getWebskinDisplayname(typename="#componentname#", template="#aFilteredWebskins[i].methodname#") />
					<cfset stReturnMetadata.stObjectBrokerWebskins[aFilteredWebskins[i].methodname].author = application.coapi.coapiadmin.getWebskinAuthor(typename="#componentname#", template="#aFilteredWebskins[i].methodname#") />
					<cfset stReturnMetadata.stObjectBrokerWebskins[aFilteredWebskins[i].methodname].description = application.coapi.coapiadmin.getWebskinDescription(typename="#componentname#", template="#aFilteredWebskins[i].methodname#") />
					<cfset stReturnMetadata.lObjectBrokerWebskins = listAppend(stReturnMetadata.lObjectBrokerWebskins, aFilteredWebskins[i].methodname)>
				</cfif>
			</cfloop>
		</cfif>

		<cfif stReturnMetadata.bObjectBroker>
			<cfparam name="stReturnMetadata.ObjectBrokerMaxObjects" default="#application.ObjectBrokerMaxObjectsDefault#" />
		<cfelse>
			<cfset stReturnMetadata.ObjectBrokerMaxObjects = 0 />
		</cfif>		
		
		<cfreturn stReturnMetadata />
		
	</cffunction> 
	
	<cffunction name="createArrayTableData" access="public" returntype="array" output="true" hint="Inserts the array table data for the given property data and returns the Array Table data as a list of objectids">
	    <cfargument name="tableName" type="string" required="true" />
	    <cfargument name="objectid" type="uuid" required="true" />
	    <cfargument name="tabledef" type="struct" required="true" />
	    <cfargument name="aProps" type="array" required="true" />
	
		<cfset var gateway =  "" />
		<cfset var stResult =  structNew() />
		
    	<cfset fourqInit() />
    
		<cfset gateway = getGateway()  />
		<cfset stResult = gateway.createArrayTableData(arguments.tablename,arguments.objectid,arguments.tabledef,arguments.aProps) />
		
		<cfreturn stResult>
	</cffunction>

	<cffunction name="getI18Property" access="public" output="false" returntype="string" hint="Provides access to I18 values for properties">
		<cfargument name="property" type="string" required="true" hint="The property being queried" default="" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />

		<cfset var meta = "" />
		<cfset var prop = arguments.value />

		<cfset fourqInit() />

		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfif len(application.stCOAPI[variables.typename].stProps[arguments.property].metadata["ftLabel"])>
					<cfreturn application.rb.getResource("coapi.#variables.typename#.properties.#arguments.property#@#arguments.value#",application.stCOAPI[variables.typename].stProps[arguments.property].metadata["ftLabel"]) />
				<cfelse>
					<cfreturn application.rb.getResource("coapi.#variables.typename#.properties.#arguments.property#@#arguments.value#",application.stCOAPI[variables.typename].stProps[arguments.property].metadata["name"]) />
				</cfif>
			</cfcase>
		</cfswitch>
		
		<cfreturn application.rb.getResource("coapi.#variables.typename#.properties.#arguments.property#@#arguments.value#","") />
	</cffunction>

	<cffunction name="getI18Step" access="public" output="false" returntype="string" hint="Provides access to I18 values for labels etc">
		<cfargument name="step" type="numeric" required="true" hint="The step being queried" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />
		
		<cfset var qSteps = "" />
		<cfset var prop = arguments.value />

		<cfset fourqInit() />

		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfset prop = "ftWizardStep" />
			</cfcase>
		</cfswitch>
		
		<cfquery dbtype="query" name="qSteps">
			select		ftWizardStep
			from		application.stCOAPI.#variables.typename#.qMetadata
			where		ftWizardStep <> '#variables.typename#'
			group by 	ftWizardStep
			order by	ftSeq
		</cfquery>
		
		<cfreturn application.rb.getResource("coapi.#variables.typename#.steps.#arguments.step#@#arguments.value#",qSteps[prop][arguments.step]) />
	</cffunction>

	<cffunction name="getI18Fieldset" access="public" output="false" returntype="string" hint="Provides access to I18 values for labels etc">
		<cfargument name="step" type="numeric" required="false" hint="The step being queried" default="0" />
		<cfargument name="fieldset" type="numeric" required="true" hint="The fieldset being queried" default="0" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />
		
		<cfset var qSteps = "" />
		<cfset var qFieldsets = "" />
		<cfset var prop = arguments.value />

		<cfset fourqInit() />

		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfset prop = "ftFieldset" />
			</cfcase>
			<cfcase value="helptitle">
				<cfset prop = "fthelptitle" />
			</cfcase>
			<cfcase value="helpsection">
				<cfset prop = "fthelpsection" />
			</cfcase>
		</cfswitch>
		
		<cfif arguments.step>
			<cfquery dbtype="query" name="qSteps">
				select		ftWizardStep
				from		application.stCOAPI.#variables.typename#.qMetadata
				where		ftWizardStep <> '#variables.typename#'
				group by 	ftWizardStep
				order by	ftSeq
			</cfquery>
		</cfif>
		
		<cfquery dbtype="query" name="qFieldsets">
			select		ftFieldset, ftHelpTitle, ftHelpSection
			from		application.stCOAPI.#variables.typename#.qMetadata
			<cfif arguments.step>
				where		ftWizardStep = '#qSteps.ftWizardStep[arguments.step]#'
			</cfif>
			group by	ftFieldSet, ftHelpTitle, ftHelpSection
			order by	ftSeq
		</cfquery>
		
		<cfif arguments.step>
			<cfreturn application.rb.getResource("coapi.#variables.typename#.steps.#arguments.step#.fieldsets.#arguments.fieldset#@#arguments.value#",qFieldsets[prop][arguments.fieldset]) />
		<cfelse>
			<cfreturn application.rb.getResource("coapi.#variables.typename#.fieldsets.#arguments.fieldset#@#arguments.value#",qFieldsets[prop][arguments.fieldset]) />
		</cfif>
	</cffunction>
	
</cfcomponent>
