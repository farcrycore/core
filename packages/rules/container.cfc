
<cfcomponent extends="farcry.fourq.fourq">
	<cfproperty name="objectID" hint="Primary Key" type="uuid">
	<cfproperty name="label" hint="Name of the container"  type="nstring">
	<cfproperty name="aRules" hint="Array of UUIDs" type="array"> 
	<cfproperty name="bShared" hint="Flags whether this container is to be shared amoungst various objects and scheduled by publishing rule" type="boolean"> 
	
	<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="parentobjectid" type="string" required="No" default="" hint="The objectid of the object that this container is rendered to">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		
		<cfscript>
			stNewObject = super.createData(arguments.stProperties);
			if (len(arguments.parentObjectid))
				createDataRefContainer(objectid=arguments.parentobjectid,containerid=stNewObject.objectid);
		</cfscript>
		
		<cfreturn stNewObject>
	</cffunction>
	
	<cffunction name="createDataRefContainer" hint="creates an entry into refContainers table">
		<cfargument name="objectid" required="Yes" type="UUID" hint="objectid of object that container belongs to">
		<cfargument name="containerid" required="Yes" type="UUID" default="object id of container">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		
		<cfquery datasource="#application.dsn#" name="q">
			INSERT INTO refContainers
			(objectid,containerID)
			VALUES
			('#arguments.objectid#','#arguments.containerid#')
		</cfquery> 
	</cffunction>
	
	<cffunction name="deleteRefContainerData" hint="Delete data in refContainers relevant to a particular object">
		<cfargument name="objectid" required="Yes">
		<cfargument name="dsn" required="No" default="#application.dsn#">
				
		<cfquery name="q" datasource="#arguments.dsn#">
			DELETE 
			FROM refContainers
			WHERE objectid = '#arguments.objectid#'
		</cfquery>
	
	</cffunction>
	
	<cffunction name="delete">
		<cfargument name="objectid" required="Yes">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		
		<cfscript>
			qRefObjects = getContainersByObject(objectid=arguments.objectid,dsn=arguments.dsn);
			if(qRefObjects.recordCount)
			{
				qObjs = getDistinctObjectsByContainer(lContainerIds=valuelist(qRefObjects.containerid));
				//get rid of refContainers data for this object
				deleteRefContainerData(objectid=arguments.objectid,dsn=arguments.dsn);
				//We only wish to delete container if there are no shared containers 
				if (qObjs.recordCount EQ 1)
				{					
					for(index = 1;index LTE qRefObjects.recordCount;index=index+1)
					{	
						 super.deleteData(qRefObjects.containerID[index]);
					}	
				}	
			}		
		</cfscript>
	</cffunction>
			
	<cffunction name="getDistinctObjectsByContainer">	
		<cfargument name="lContainerIds" required="Yes" hint="value list (not quoted) of container ids">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		
		<cfquery name="q" datasource="#application.dsn#">
			SELECT distinct(objectid) 
			FROM refContainers 
			WHERE containerid IN ('#listChangeDelims(arguments.lContainerIds,"','")#')
		</cfquery>
		
		<cfreturn q>
	</cffunction>	
	
	
	
	<cffunction name="getObjectsByContainer" hint="gets all parent objects that a container may belong to" returntype="query">
		<cfargument name="containerid" required="Yes">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT *
			FROM refContainers r
			WHERE containerid = '#arguments.containerid#'
		</cfquery>
		
		<cfreturn q>
	
	</cffunction> 		
	
	<cffunction name="getContainersByObject" hint="gets all container objects that are attached to a particular object" returntype="query">
		<cfargument name="objectid" required="Yes">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT *
			FROM refContainers r
			WHERE objectid = '#arguments.objectid#'
		</cfquery>
		
		<cfreturn q>
	
	</cffunction> 	
	
	<cffunction name="refContainerDataExists" hint="gets refContainer Entries for a given container and object">
		<cfargument name="containerid" required="Yes">
		<cfargument name="objectid" required="Yes">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT *
			FROM refContainers r
			WHERE objectid = '#arguments.objectid#'
			AND containerid = '#arguments.containerid#'
		</cfquery>
		<cfreturn q>

	</cffunction>
	
	
	
	<cffunction name="deployRefContainers" hint="Create refContainers table">
		<cfargument name="dsn" required="Yes" >
		<cfargument name="dbtype" required="Yes"> 
		<cfargument name="dbowner" required="Yes"> 
		<cfargument name="bDropTables" required="false" default="true">	
		
		<cfswitch expression="#arguments.dbtype#">
			<cfcase value="ora">
				<cftry>
					<cfquery datasource="#arguments.dsn#">
						DROP TABLE #arguments.dbowner#refContainers
					</cfquery>
					<cfcatch></cfcatch>
				</cftry>
				<cfquery datasource="#arguments.dsn#">
					CREATE TABLE #application.dbowner#refContainers(
					OBJECTID VARCHAR2(35) NOT NULL,
					CONTAINERID VARCHAR2(35) NOT NULL
					)
				</cfquery>
				
			</cfcase>
			<cfcase value="mysql">
				<cfquery datasource="#arguments.dsn#">
					DROP TABLE IF EXISTS #arguments.dbowner#refContainers
				</cfquery>
				<cfquery datasource="#arguments.dsn#">
					CREATE TABLE `#arguments.dbowner#refContainers` 
					(`objectid` VARCHAR (35) NOT NULL, 
					 `containerid` VARCHAR (35) NOT NULL 
					) 
				</cfquery>	 
			</cfcase>
			<cfdefaultcase>
				<cfquery name="qCreateTables" datasource="#arguments.dsn#">
				if exists (select * from sysobjects where id = object_id(N'#application.dbowner#refContainers') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				drop table #application.dbowner#refcontainers
		
				-- return recordset to stop CF bombing out?!?
				select count(*) as blah from sysobjects
				</cfquery>
				<cfquery name="qCreateTables" datasource="#arguments.dsn#">
				CREATE TABLE #application.dbowner#refContainers (
					[objectid] [varchar] (35) NOT NULL ,
					[containerid] [varchar] (35) NOT NULL 
				)
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		
	</cffunction>	

	<cffunction name="getContainer" access="public" returntype="query" hint="Retrieve container instance by label lookup.">
		<cfargument name="label" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="objectID" type="uuid" required="false">
				
			
		<cfquery name="qGetContainer" datasource="#arguments.dsn#">
			SELECT *
			FROM #application.dbowner#container 
			WHERE 
			<cfif isDefined("arguments.objectID")>
				objectID = '#objectID#'
			<cfelse>
				label = '#arguments.label#'
			</cfif>
		</cfquery>
		<cfreturn qGetContainer>
	</cffunction> 
	
	<cffunction name="populate" access="public" hint="Gets Rule instances and execute them">
		<cfargument name="aRules" type="array" required="true">
		
		<cfset request.aInvocations = arrayNew(1)>
		<cfloop from="1" to="#arrayLen(arguments.aRules)#" index="i">
			 <cftry> 
				
				<cfinvoke component="farcry.fourq.fourq" returnvariable="rule" method="findType" objectID="#arguments.aRules[i]#">
				
				<!--- Is this a custom rule? or not? --->
				<cfif NOT evaluate("application.rules." & rule & ".bCustomRule")>
					<cfinvoke objectID="#arguments.aRules[i]#" component="#application.packagepath#.rules.#rule#" method="execute"/>
				<cfelse>
					<cfinvoke objectID="#arguments.aRules[i]#" component="#application.custompackagepath#.rules.#rule#" method="execute"/>										
				</cfif>					
			  	<cfcatch type="any">
					<!--- show error if debugging --->
					<cfif isdefined("url.debug")>
						<cfset request.cfdumpinited = false>
						<cfdump var="#cfcatch#">
					</cfif>
					<!--- Output a HTML Comment for debugging purposes --->
					<cfoutput>
						<!-- container failed on ruleID: #arguments.aRules[i]# (#rule#) 
						<br> 
						#cfcatch.Detail#<br>#cfcatch.Message#
					 	-->
					 </cfoutput>
				</cfcatch>
			</cftry>  
		</cfloop>		 
		<cfloop from="1" to="#arrayLen(request.aInvocations)#" index="i">
			<cfif isStruct(request.aInvocations[i])>
				<cfscript>
					o = createObject("component", "#request.aInvocations[i].typename#");
					o.getDisplay(request.aInvocations[i].objectID, request.aInvocations[i].method);	
				</cfscript>
			<cfelse>
				<cfoutput>
					<p>
					#request.aInvocations[i]#
					</p>
				</cfoutput>	
			</cfif>	
		</cfloop>
		
	</cffunction>
	
</cfcomponent>