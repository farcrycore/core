
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
	
	<cffunction name="deleteContainerRules" hint="deletes all rules that belong to a container">
		<cfargument name="containerid" required="Yes" type="UUID" hint="Objectid of container">
		<cfset var x = 1>
		<cfscript>
			st = getData(objectid=arguments.containerid);
			if(NOT structIsEmpty(st))
			{
				for(x=1;x LTE arrayLen(st.aRules);x=x+1)
				{
					ruletype = findType(objectid=st.aRules[x]);
					if (structKeyExists(application.rules,ruletype))
					{
						o = createObject("component",application.rules[ruletype].rulepath);
						o.deleteData(objectid=st.aRules[x]);
					}	
				}
			}
		</cfscript>
	
	</cffunction>
		
	
	<cffunction name="copyContainers" hint="makes a duplicate of all container data in source object and copies to destination object">
		<cfargument name="srcObjectID" required="Yes" type="UUID" hint="Source object whose container data is to be copied">
		<cfargument name="destObjectID" required="Yes" type="UUID" hint="Destination object whose container data is to be copied">
		<cfargument name="bDeleteDestData" required="No" default="1" type="boolean" hint="Effectively overwrites destination data">
		<cfargument name="bDeleteSrcData" required="No" default="0" type="boolean" hint="Removes source container after copy">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfset var index = 1>
		<cfset var x = 1>
		
		<cfscript>
			
			qSrcCon = getContainersByObject(arguments.srcObjectId);
			qDestCon = getContainersByObject(arguments.destObjectId);
						
			/*dump(qSrcCon,'qsrc');
			dump(qDestCon,'qdest');*/
			
			if(arguments.bDeleteDestData)
			{
				for(index = 1;index LTE qDestCon.recordcount;index=index+1)
				{	
					//delete all rule data from this container
					deleteContainerRules(containerid=qDestCon.containerid[index]);
					//delete the container
					super.deleteData(qDestCon.containerid[index]);
				}
				//delete all refContainerData
				deleteRefContainerData(arguments.destObjectID);
			}	
			
						
			for(index = 1;index LTE qSrcCon.recordcount;index=index+1)
			{	
				st = getData(objectid=qSrcCon.containerid[index]);
				//dump(st,'before');
				//need to copy all rules now.
				aRules = arrayNew(1);
				if(not structIsEmpty(st))
				{
					for(x=1;x LTE arrayLen(st.aRules);x=x+1)
					{
						ruletype = findType(objectid=st.aRules[x]);
						if(structKeyExists(application.rules,ruletype))
						{
						o = createObject("component",application.rules[ruletype].rulepath);
						stRule = o.getData(objectid=st.aRules[x]);
						stRule.objectid = createUUID();
						//create the rule
						o.createData(stProperties=stRule,dsn=arguments.dsn);
						//now create the new array reference to it
						arrayAppend(aRules,stRule.objectid);
						}
					}
					st.aRules = aRules;
					//change the label - containers are currently obtained by label
					st.label = replace(st.label,arguments.srcObjectId,arguments.destObjectId,"ALL");
					st.objectid = createUUID();
					//now we want to create this new container
					createData(stProperties=st,dsn=arguments.dsn);
					//and log a reference to it in refContainers
					createDataRefContainer(objectid=arguments.destObjectid,containerid=st.objectid);
				}
				
			}
			
			if(arguments.bDeleteSrcData)
			{
				for(index = 1;index LTE qSrcCon.recordcount;index=index+1)
				{	
					//delete all rule data from this container
					deleteContainerRules(containerid=qSrcCon.containerid[index]);
					//delete the container
					super.deleteData(qSrcCon.containerid[index]);
				}
				deleteRefContainerData(arguments.srcObjectId);
			}	
			
		</cfscript>
		
		
	</cffunction>
	
	
	<cffunction name="delete" hint="deletes all container data by objectid">
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
				//dump(qObjs,'distinct objects');
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
		<cfset oFourq = createObject("component", "farcry.fourq.fourq")>
		<cfloop from="1" to="#arrayLen(arguments.aRules)#" index="i">
			 <cftry> 
				<cfset rule = oFourq.findType(objectid=arguments.aRules[i])>
				<cfinvoke objectID="#arguments.aRules[i]#" component="#application.rules[rule].rulePath#" method="execute"/>										
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