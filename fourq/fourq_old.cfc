<!------------------------------------------------------------------------
fourQ COAPI
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/farcry_core/fourq/fourq_old.cfc,v 1.1 2005/05/24 03:54:27 geoff Exp $
$Author: geoff $
$Date: 2005/05/24 03:54:27 $
$Name:  $
$Revision: 1.1 $

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


<!---
$review: Spike - 
Should we add a bGetReferences variable that will allow you to tell fourq whether or not to go getting all the array and reference properties.
That way, you can reduce the overhead to get deeply referenced objects if you only want the label.
$
--->
<!--- constructor --->
<cfset instance=structnew()>

	<cffunction name="getData" access="public" output="false" returntype="struct" hint="Get data for a specific objectid and return as a structure, including array properties and typename.">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="bShallow" type="boolean" required="false" default="false" hint="Setting to true filters all longchar property types from record.">
		
		<cfset var stobj=structnew()>
		<cfset var tablename="">
		<cfset var aprops="">
		<cfset var sqlSelect="">
		<cfset var i=0>
		<cfset var qgetData="">
		<cfset var key="">
		<cfset var qArrayData="">
		
		<cfif isdefined("instance.bgetdata") and instance.bgetdata eq arguments.objectid>
			<!--- get local instance cache --->
			<cfset stObj = instance.stobj>
			<cftrace type="information" category="coapi" var="stobj.typename" text="getData() used instance cache.">
		<cfelse>
			<!--- build a local instance cache --->
			<cfinclude template="_fourq/getData.cfm">
			<cfset instance.stobj = stobj>
			<cfset instance.bgetData = arguments.objectid>
			<cftrace type="information" category="coapi" var="stobj.typename" text="getData() used database.">
		</cfif>
		
		<cfreturn stObj>
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
		<cfoutput>
			select typename from #arguments.dbowner#refObjects
		where objectID = '#arguments.objectID#'
		</cfoutput>
		
		<!--- 
		$ TODO: resolve upstream errors
		<cfif NOT qgetType.recordCount>
			<cfthrow type="fourq" detail="<b>Invalid reference:</b> object #arguments.objectID# is not in refObjects table">
		</cfif> 
		$
		--->

		<cfreturn qgetType.typename>
	</cffunction>

	<cffunction name="setData" access="public" output="false" returntype="struct" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">

		<cfset var setDataResult = structNew()>		
		<cfset var tablename="">
		<cfset var aprops="">
		<cfset var qSetData="">
		<cfset var i=0>
		<cfset var j=0>
		<cfset var propertyname="">
		<cfset var propertyvalue="">
		<cfset var qDeleteArray="">
		<cfset var qAddArrayData="">

		<!--- set defaults for status --->
		<cfset setDataResult.bSuccess = true>
		<cfset setDataResult.message = "Object updated successfully">
		<!--- reset instance cache -- set in getData() --->
		<cfset instance.bgetData = 0>

		<cfinclude template="_fourq/setData.cfm">
		
		<cfreturn setDataResult>
	</cffunction>

	<cffunction name="createData" access="public" output="false" returntype="struct" hint="Create an object including array properties.  Pass in a structure of property values; arrays should be passed as an array. The objectID can be ommitted and one will be created, passed in as an argument or passed in as a key of stProperties argument.">
		<cfargument name="stProperties" type="struct" required="true">
		<cfargument name="objectid" type="UUID" required="false" default="#createUUID()#">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">

		<cfset var createDataResult = structNew()>
		<cfset var tablename="">
		<cfset var aProps="">
		<cfset var sqlcol = "">
		<cfset var sqlval = "">
		<cfset var i=0>
		<cfset var j=0>
		<cfset var propertyname="">
		<cfset var propertyvalue="">
		<cfset var qrefdata="">
		<cfset var primarykey="">
				
		<!--- allow objectid to be passed in stProperties --->
		<cfif IsDefined("arguments.stProperties.objectid")>
			<cfset arguments.objectid=arguments.stProperties.objectid>
		</cfif>

		<!--- set defaults for status --->
		<cfset createDataResult.bSuccess = true>
		<cfset createDataResult.message = "Object created successfully">

		<cfinclude template="_fourq/createData.cfm">
		<cfset createDataResult.objectid = primarykey>
		
		<cfreturn createDataResult>
	</cffunction>

	<cffunction name="deleteData" access="public" output="false" returntype="struct" hint="Delete the specified objectid and corresponding data, including array properties and refObjects.">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<!--- set status here... if something goes wrong expect a thrown error --->
		<cfset var stResult = structNew()>
		<cfset stResult.bSuccess = true>
		<cfset stResult.message = "Object deleted successfully">
		
		<cfinclude template="_fourq/deleteData.cfm">
		
		
		<cfreturn stResult>
	</cffunction>
	
 	<cffunction name="deployType" access="public" returntype="struct" output="false">
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
        <cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">

		<cfset stResult = structNew()>
		<cfinclude template="_fourq/deployType.cfm">
		
		<cfreturn stResult>
	</cffunction>

 	<cffunction name="deployRefObjects" access="public" returntype="struct" output="false">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset stResult = structNew()>
		<cfinclude template="_fourq/deployrefObjects.cfm">
		
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
		
		<cfset stTmp = structNew()>
		
		<cfinclude template="_fourq/deployArrayTable.cfm">
		
		<cfreturn stTmp>
	</cffunction>

	<cffunction name="getTablename" access="public" returntype="string" output="false">
		<!--- 
		$ TODO:
		We need some way of defining an abstract class.
		Currently, posting a babstract="true" attribute into the <cfcomponent>
		will block any reference
		20020517 GB
		
		Move calls to MD to persistent scope GB
		$
		 --->
		<!--- prevent abstract classes from being deployed --->
		<cfset var md=getMetaData(this)>
		<cfset var tablename = ListLast(md.name, ".")>
		
		<cfif IsDefined("md.bAbstract") AND md.bAbstract>
			<cfthrow message="Error: you cannot reference abstract classes with the FourQ persistence layer." type="fourq">
		</cfif>
		
		<cfreturn tablename>
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
		
		<!--- build props for object type. Note that its possible that a component doesn't have any properties PH--->
		<cfif structKeyExists(md,"properties")>
			<cfloop from=1 to="#arraylen(md.properties)#" index="prop">
				<cfset thisprop = md.properties[prop]>
				<cfset ArrayAppend(aProps, md.properties[prop])>
				<cfset lPropsProcessed = ListAppend(lPropsProcessed, thisprop.name)>
			</cfloop>
		</cfif>
			
		<!--- build non-overloaded props from abstract class for this package --->
		<!--- 
		$ TODO:
		should be recursive and go as deep as it needs. it is conceivable that 
		developers will want to build sub-classes of their content types
		20020518 GB
		getPropsAsStruct() model should probably be used instead.  Only problem
		is that q functions expect to see array of properties at the moment.
		20020823 GB
		Should now go as deep as required.
		20031021 PH
		$
		 --->
		
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
		
		<cfscript>
		for ( i=1; i lte ArrayLen(aAncestors); i=i+1 ) {
			curAncestor = aAncestors[i] ;
			
			if ( StructKeyExists( curAncestor, 'properties' ) )
				for ( j=1; j lte ArrayLen( curAncestor.properties ); j=j+1 ) {
					curProperty = StructNew() ;
					curProperty.metadata = curAncestor.properties[j] ;
					curProperty.origin = curAncestor.name ;
					stProperties[curProperty.metadata.name] = curProperty ;
				}
		
		}
		</cfscript>
		<cfreturn stProperties>
	</cffunction>

	<cffunction name="initMetaData" access="public" hint="Extract all component metadata in a flat format for loading into a shared scope." output="false">
		<cfargument name="scope" type="string" required="Yes">
		<cfset var stMetaData = structNew()>
		<cfset var md = getMetaData(this)>
		
		<cfscript>
			stMetaData.stProps = this.getPropsAsStruct();
			stMetaData.stMethods = this.getMethods();
			componentname = this.getTablename();
			"#scope#.#componentname#" = stMetaData;
		</cfscript>
		
		<!--- add any extended component metadata --->
		<cfloop collection="#md#" item="key">
			<cfif key neq "PROPERTIES" AND key neq "EXTENDS" AND key neq "FUNCTIONS" AND key neq "TYPE">
				<cfset "#scope#.#componentname#.#key#" = md[key]>
			</cfif>
		</cfloop>

	</cffunction> 
	
	<!--- 
	Created: 08/May/2003
	Added the getMultiple() because I found myself constantly using cfquery 
	in my FarCry app to get around it's absence.
	developer: spike (spike@spike.org.uk)--->
		
	<cffunction name="getMultiple" access="public" hint="Get multpile objects of a particular type" ouput="false" returntype="struct">
		<cfargument name="dsn" type="string" required="yes" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="lObjectIDs" type="string" required="false" default="" hint="Restrict resultset to a comma delimited list of objectids.">
		<cfargument name="OrderBy" type="string" required="false" default="" hint="Comma delimited list of properties to order by. Known issue: method returns a struct which randomises sort order :(">
		<cfargument name="SortOrder" type="string" required="false" default="asc" hint="asc or desc options.">
		<cfargument name="conditions" type="struct" required="false" default="#structNew()#" hint="Query filter; pass in structure keyed by property and with a value equal to the desired filter.">
		<cfargument name="whereclause" type="string" required="false">
		
		<cfset var tn = getTableName()>
		<cfset var stProps = getPropsAsStruct()>
		
		<cfsavecontent variable="sql">
		<cfoutput>
			SELECT *
			FROM #arguments.dbowner##tn#
			<cfif isDefined('arguments.whereclause')>
				#preservesinglequotes(whereclause)#
			<cfelse>
				WHERE 0=0
				
				<cfloop collection="#arguments.conditions#" item="prop">
					<cfswitch expression="#stProps[prop].metadata.type#">
						<cfcase value="numeric,date,boolean">
							AND #prop# = #arguments.conditions[prop]#
						</cfcase>
						<cfdefaultcase>
							AND #prop# = '#arguments.conditions[prop]#'
						</cfdefaultcase>
					</cfswitch>
				</cfloop>
				
				<cfif len(arguments.lObjectIDs)>
					AND objectid IN (#listQualify(arguments.lObjectIDs,"'")#)
				</cfif>
				
			</cfif>
			<cfif len(arguments.OrderBy)>
				ORDER BY #arguments.OrderBy# #arguments.SortOrder#
			</cfif>
		</cfoutput>
		</cfsavecontent>
		<cftry>
		<cfquery datasource="#arguments.dsn#" name="qMultipleObjects">
			#preservesinglequotes(sql)#
		</cfquery>
			<cfcatch>
				<cfset request.fourqGetMultipleErrorContext = cfcatch>
				<cfthrow type="fourq.getMultiple" message="Query error occurred in fourq.cfc getMultiple()" detail="<p>This is a dynamically generated query which can be the mother or all things to debug. Try looking at the stack trace and the sequence of templates parsed to figure out where the function was called from.</p> <p>SQL for the failed query:<br><pre>#reReplaceNoCase(sql,'[#chr(20)##chr(9)#]','','all')#</pre></p> <p>The original cfcatch scope was put into request.fourqGetMultipleErrorContext.</p>">
			</cfcatch>
		</cftry>
		<cfset stObjects = StructNew()>
		
		<cfloop query="qMultipleObjects">
			<cfset stObjects[qMultipleObjects.objectid] = structNew()>
			<cfloop collection="#stProps#" item="prop">
				<!--- check for array tables --->
				<cfif stProps[prop].metadata.Type eq 'array'>
					<cfset key = prop>

					<!--- getdata for array properties --->
					<cfquery datasource="#arguments.dsn#" name="qArrayData">
						select * from #arguments.dbowner##tn#_#key#
						where objectid = '#qMultipleObjects.objectid#'
						order by seq
					</cfquery>
				
					<cfset SetVariable("#key#", ArrayNew(1))>
				
					<cfloop query="qArrayData">
						<cfset ArrayAppend(Evaluate(key), qArrayData.data)>
					</cfloop>
				
					<cfset SetVariable("stObjects[qMultipleObjects.objectid]['#UCase(key)#']", Evaluate(key))>
				<cfelse>
					<cfset stObjects[qMultipleObjects.objectid][prop] = qMultipleObjects[prop][qMultipleObjects.currentRow]>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stObjects>
		
	</cffunction>
	
	<!--- 
	Created: 08/May/2003 
	Added the setMultiple() because it seemed to make sense when adding getMultiple()
	The use of setMultiple() is not encouraged.
	developer: spike (spike@spike.org.uk)--->
	
	<cffunction name="setMultiple" access="public" hint="Set a single property for multpile objects of a particular type" ouput="false" returntype="boolean">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="dbowner" type="string" required="yes">
		<cfargument name="prop" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfargument name="whereclause" type="string" required="false" default="WHERE 0=1">
		
		<cfset var tn = this.getTableName()>
		<cfset var stProps = this.getPropsAsStruct()>
		<cfif stProps[arguments.prop].metadata.type neq 'array'>
			<cfsavecontent variable="sql">
				<cfoutput>
					UPDATE #arguments.dbowner##tn#
					SET #arguments.prop# = #arguments.value#
					#preservesinglequotes(arguments.whereclause)#
				</cfoutput>
			</cfsavecontent>
			<cftry>
				<cfquery datasource="#arguments.dsn#" name="qSetMultipleObjects">
					#preserveSingleQuotes(sql)#
				</cfquery>
			
				<cfcatch>
					<cfset request.fourqSetMultipleErrorContext = cfcatch>
					<cfthrow type="fourq.setMultiple" message="Query error occurred in fourq.cfc setMultiple()" detail="<p>This is a dynamically generated query which can be the mother or all things to debug. Try looking at the stack trace and the sequence of templates parsed to figure out where the function was called from.</p> <p>SQL for the failed query:<br><pre>#reReplaceNoCase(sql,'[#chr(20)##chr(9)#]','','all')#</pre></p> <p>The original cfcatch scope was put into request.fourqSetMultipleErrorContext.</p>">
				</cfcatch>
			</cftry>
		<cfelse>
			<cfabort showerror="Sorry, can't use setMultiple to update array properties. use setData() instead">
		</cfif>
		<cfreturn true>
	</cffunction>
	
</cfcomponent>
