<!------------------------------------------------------------------------
fourQ COAPI
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/fourq.cfc,v 1.43 2005/10/04 01:17:44 guy Exp $
$Author: guy $
$Date: 2005/10/04 01:17:44 $
$Name:  $
$Revision: 1.43 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

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
		
		<cfif isDefined("session.dmSec.authentication.userlogin")>
			<cfset userlogin = session.dmSec.authentication.userlogin>
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
		<cfset stProps.title = "">
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
    
    	<cfset var stResult = structNew()>
		<cfset var gateway = "" />
    
    	<cfset fourqInit() />
    
		<cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner)  />
		<cfset stResult = gateway.deployType(variables.tableMetaData,arguments.bDropTable,arguments.bTestRun) />
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
		<cfset var tablename="">
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
		
		<!--- init fourq --->
		<cfset fourqInit() />
		
		
		
		
		
		
		<cfparam name="instance.stobj.typename" default="#tablename#">
		
		<cfif isdefined("instance.bgetdata") AND instance.bgetdata EQ arguments.objectid AND arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs>
			<!--- get local instance cache --->
			<cfset stObj = instance.stobj>
			<cftrace type="information" category="coapi" var="stobj.typename" text="getData() used instance cache.">
		
		
		<!--- Check to see if the object is in the temporary object store --->
		<cfelseif structKeyExists(Session,"TempObjectStore") AND structKeyExists(Session.TempObjectStore,arguments.objectid) AND arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs>
			<!--- get from the temp object stroe --->
			<cfset stObj = Session.TempObjectStore[arguments.objectid] />
			<cftrace type="information" category="coapi" var="stobj.typename" text="getData() used Temporary Object Store (Session.tempObjectStore).">
	
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
				
				
				<cfset stobj.typename = tablename />
				
				
				
					
				<cftimer label="getData: #stobj.typename#">
				
				
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
			
				
				<cftrace type="information" category="coapi" var="stobj.typename" text="getData() used database.">
			
				<!--- Attempt to add the object to the broker --->
				<cfif NOT arguments.bArraysAsStructs AND NOT arguments.bShallow>
					<cfset addedtoBroker = variables.objectBroker.AddToObjectBroker(stobj=stobj,typename=variables.typename)>
	
					<cfif addedToBroker>
						<!--- Successfully added object to the broker --->
						<cftrace type="information" category="coapi" var="arguments.objectid" text="getData() added object to Broker.">
					</cfif>
				</cfif>
				</cftimer>
			</cfif>	

					
			
		</cfif>
		
		<!--- 
		The object has not been found anywhere (Instance, Temporary Object Store, Object Broker, Database)
		We therefore need to return a default object of this typename.
		 --->
		<cfif NOT structKeyExists(stObj,'objectID')>
			<cfset stObj = getDefaultObject(objectID=arguments.objectid)>	
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

	    
	    <cfset fourqInit() />
	    <cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
	    	    
		
		<!--- Make sure that the temporary object store exists in the session scope. --->
		<cfparam name="Session.TempObjectStore" default="#structNew()#" />
		
	    <!--- Make sure we remove the object from the objectBroker if we update something --->
	    <cfif structkeyexists(stProperties, "objectid")>
		    <cfset variables.objectBroker.RemoveFromObjectBroker(lObjectIDs=stProperties.ObjectID,typename=variables.typename)>
	    </cfif>	    

	   	
	   	
	    <!--- need to add this in case the object has been put in the instance cache. --->
	    <cfset structdelete(instance,"bgetdata")>
		
		
		<!--------------------------------------- 
		If the object is to be stored in the session scope only.
		----------------------------------------->		
		<cfif arguments.bSessionOnly>
		
			<!--- Make sure an object id exists. --->
			<cfparam name="stProperties.ObjectID" default="#CreateUUID()#" />				
			
			<!--- Get the default properties for this object --->
			<cfset stDefaultProperties = this.getData(objectid=stProperties.ObjectID,typename=variables.typename) />
		  	
		  	<!--- need to add this in case the object has been put in the instance cache in the getdata above. --->
	    	<cfset structdelete(instance,"bgetdata")>
	    	
			<!--- 
			Append the default properties of this object into the properties that have been passed.
			The overwrite flag is set to false so that the default properties do not overwrite the ones passed in.
			 --->
			<cfset StructAppend(arguments.stProperties,stDefaultProperties,false)>	
						
			<!--- Add object to temporary object store --->
			<cfset Session.TempObjectStore[stProperties.ObjectID] = arguments.stProperties />
			
			<cfset stResult.bSuccess = true />
			<cfset stResult.message = "Object Saved to the Temporary Object Store." />
			<cfset stResult.ObjectID = stProperties.ObjectID />
			
			
			
		<!--------------------------------------- 
		If the object is to be stored in the Database then run the appropriate gateway
		----------------------------------------->	
	   	<cfelse>
		   	
	   		<cfset stResult = gateway.setData(stProperties,variables.tableMetadata) />	   	
	   	 
	    
		   	<!--- Make sure we remove the object from the TempObjectStore if we update something --->
	   		<cfif structKeyExists(session, "TempObjectStore") AND structKeyExists(Session.TempObjectStore,stProperties.ObjectID)>
		   		<cfset structdelete(Session.TempObjectStore, stProperties.ObjectID) />
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
		<cfset var qgetType="">

		<cfquery datasource="#arguments.dsn#" name="qgetType">
		select typename from #arguments.dbowner#refObjects
		where objectID = '#arguments.objectID#'
		</cfquery>
		
		<!--- 
		$ TODO: resolve upstream errors
		<cfif NOT qgetType.recordCount>
			<cfthrow type="fourq" detail="<b>Invalid reference:</b> object #arguments.objectID# is not in refObjects table">
		</cfif> 
		$
		--->

		<cfreturn qgetType.typename>
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
		
		<cfreturn aProps>
		
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
		<cfset var oCoapiAdmin = createObject("component", "farcry.core.packages.coapi.coapiadmin") />
		
		<!--- If we are updating a type that already exists then we need to update only the metadata that has changed. --->
		<cfif structKeyExists(stReturnMetadata, "stProps")>			
		
			<cfloop list="#structKeyList(stNewProps)#" index="i">
					
				<cfif StructKeyExists(stReturnMetadata.stProps,i)>
					<cfloop list="#structKeyList(stNewProps[i])#" index="j">	
												
						<cfif StructKeyExists(stReturnMetadata.stProps[i],j)>
	
							<cfif isStruct(stNewProps[i][j])>
								<cfloop list="#structKeyList(stNewProps[i][j])#" index="k">
									<cfset stReturnMetadata.stProps[i][j][k] = stNewProps[i][j][k]>
								</cfloop> 
							<cfelse>
								<cfset stReturnMetadata.stProps[i][j] = stNewProps[i][j]>
							</cfif>
						<cfelse>
							<cfset stReturnMetadata.stProps[i][j] = stNewProps[i][j]>
						</cfif>
					</cfloop>
				<cfelse>
					<cfset stReturnMetadata.stProps[i] = stNewProps[i]>
				</cfif>
				
			</cfloop>
			
		<cfelse>
			<cfset stReturnMetadata.stProps = stNewProps />
		</cfif>

		<!--- Make sure ALL properties have an ftType, ftLabel,ftStyle and ftClass set. If not explicitly set then use defaults. --->
		<cfloop list="#structKeyList(stReturnMetadata.stProps)#" index="i">
			<cfif structKeyExists(stReturnMetadata.stProps[i].metadata, "type") AND NOT structKeyExists(stReturnMetadata.stProps[i].metadata, "ftType")>
				<cfset stReturnMetadata.stProps[i].metadata.ftType = stReturnMetadata.stProps[i].metadata.Type />
			</cfif>
			<cfif NOT structKeyExists(stReturnMetadata.stProps[i].metadata, "ftLabel")>
				<cfset stReturnMetadata.stProps[i].metadata.ftLabel = stReturnMetadata.stProps[i].metadata.name />
			</cfif>
			<cfif NOT structKeyExists(stReturnMetadata.stProps[i].metadata, "ftStyle")>
				<cfset stReturnMetadata.stProps[i].metadata.ftStyle = "" />
			</cfif>
			<cfif NOT structKeyExists(stReturnMetadata.stProps[i].metadata, "ftClass")>
				<cfset stReturnMetadata.stProps[i].metadata.ftClass = "" />
			</cfif>
			<cfif NOT structKeyExists(stReturnMetadata.stProps[i].metadata, "ftValidation")>
				<cfset stReturnMetadata.stProps[i].metadata.ftValidation = "" />
			</cfif>
		</cfloop>

		

		<!--- This will get the components methods and any methods that are from super cfc's --->
		<cfset stReturnMetadata.stMethods = getMethods()>	
		
		<!--- add any extended component metadata --->
		<cfloop collection="#md#" item="key">
			<cfif key neq "PROPERTIES" AND key neq "EXTENDS" AND key neq "FUNCTIONS" AND key neq "TYPE">
				<cfset stReturnMetadata[key] = md[key] />				
			</cfif>
		</cfloop>
		
		<cfparam name="stReturnMetadata.bObjectBroker" default="false" />
		<cfparam name="stReturnMetadata.lObjectBrokerWebskins" default="" />
		<cfparam name="stReturnMetadata.ObjectBrokerWebskinTimeOut" default="1400" /> <!--- This a value in minutes (ie. 1 day) --->
		
		
		<cfset stReturnMetadata.qWebskins = oCoapiAdmin.getWebskins(componentname) />
		
		<cfif stReturnMetadata.lObjectBrokerWebskins EQ "*">
			<cfset stReturnMetadata.lObjectBrokerWebskins = valueList(stReturnMetadata.qWebskins.methodname) />
		</cfif>
		
		<!---  --->
		<cfset stReturnMetadata.stObjectBrokerWebskins = structNew() />
		
		<cfloop list="#stReturnMetadata.lObjectBrokerWebskins#" index="i">
			
			<!--- This checks to see if the webskin broker timeout is overridden by sending a name:value pair (eg. displayPageStandard:60,displayTeaser:1440) --->
			<cfif listLast(i,":") NEQ listFirst(i,":") AND isNumeric(listLast(i,":")) AND listLast(i,":") GTE 0>
				<cfset stReturnMetadata.stObjectBrokerWebskins[listFirst(i,":")] = structNew() />
				<cfset stReturnMetadata.stObjectBrokerWebskins[listFirst(i,":")].timeout = listLast(i,":")>
			<cfelse>
				<cfset stReturnMetadata.stObjectBrokerWebskins[i] = structNew() />
				<cfset stReturnMetadata.stObjectBrokerWebskins[i].timeout = stReturnMetadata.ObjectBrokerWebskinTimeOut />
			</cfif>
		</cfloop>


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

    	<cfset fourqInit() />
    
		<cfset gateway = getGateway()  />
		<cfset stResult = gateway.createArrayTableData(arguments.tablename,arguments.objectid,arguments.tabledef,arguments.aProps) />
		
		<cfreturn stResult>
		
	
</cffunction>
	
</cfcomponent>
