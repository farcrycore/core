<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/rules/container.cfc,v 1.41.2.1 2006/01/04 07:50:02 paul Exp $
$Author: paul $
$Date: 2006/01/04 07:50:02 $
$Name: milestone_3-0-1 $
$Revision: 1.41.2.1 $

|| DESCRIPTION || 
$Description: Core container management component. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent extends="farcry.core.packages.fourq.fourq" displayname="Container Management" hint="Manages all core functions for container instance management.">
	<cfproperty name="objectID" hint="Container instance primary key." type="uuid" required="true" />
	<cfproperty name="label" hint="Label for the container instance."  type="nstring" default="(unspecified)">
	<cfproperty name="aRules" hint="Array of rule objects to be managed by this container." type="array"> 
	<cfproperty name="bShared" hint="Flags whether or not this container is to be shared amongst various objects and scheduled by publishing rule." type="boolean" default="0">
	<cfproperty name="mirrorID" hint="The UUID of a shared container to be used instead of this container; a mirror container if you like." type="UUID" default="">
	<cfproperty name="displayMethod" hint="The webskin that will encapsulate container content" type="nstring" default=""> 
	
	<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of a container object.">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new container instance.">
		<cfargument name="parentobjectid" type="string" required="No" default="" hint="The objectid of the object that instantiated the container.  Should only be set if the container is unique to that instance.  Will enable clean-up of unused containers when the parent-object is deleted.">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfset var stNewObject = structNew()>
		
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
		<cfargument name="dbowner" required="No" default="#application.dbowner#">
		<cfset var q = ''>
		<cfset var qExists = ''>
		
		<cfset qExists = refContainerDataExists(containerid=arguments.containerid,objectid=arguments.objectid)>
		<cfif NOT qExists.recordCount>
			<cfquery datasource="#arguments.dsn#" name="q">
				INSERT INTO #arguments.dbowner#refContainers
				(objectid,containerID)
				VALUES
				('#arguments.objectid#','#arguments.containerid#')
			</cfquery> 
		</cfif>
	</cffunction>
	
	<cffunction name="deleteRefContainerData" hint="Delete data in refContainers relevant to a particular object">
		<cfargument name="objectid" required="false">
		<cfargument name="containerid" required="false">
		<cfargument name="dsn" required="false" default="#application.dsn#">
		<cfargument name="dbowner" required="No" default="#application.dbowner#">
				
		<cfquery datasource="#arguments.dsn#">
			DELETE 
			FROM #arguments.dbowner#refContainers
			WHERE
			<cfif isDefined("arguments.objectid")>
				OBJECTID = '#arguments.objectid#'
			<cfelse>
				CONTAINERID = '#arguments.containerid#'
			</cfif>
		</cfquery>
	
	</cffunction>
	
	<cffunction name="deleteContainerRules" hint="deletes all rules that belong to a container">
		<cfargument name="containerid" required="Yes" type="UUID" hint="Objectid of container">
		<cfset var x = 1>
		<cfset var st = structNew()>
		<cfset var ruletype = ''>
		<cfset var o = ''>
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
		<cfset var qSrcCon = ''>
		<cfset var qDestCon = ''>
		<cfset var aRules = arrayNew(1)>
		<cfset var stRule = structNew()>
		<cfset var containerData = ''>
		
		<cfscript>
			//Get the containers in the source object
			qSrcCon = getContainersByObject(arguments.srcObjectId);
			//Get the containers in the destination object
			qDestCon = getContainersByObject(arguments.destObjectId);
						
			if(arguments.bDeleteDestData)
			{
				for(index = 1;index LTE qDestCon.recordcount;index=index+1)
				{
					//get the data on the container I might delete
					containerData = super.getData(qDestCon.containerid[index]);
					
					/*
					If I find the objectid of the destination object in the container label
					then I will delete the container because it is a unique container and is only
					used in the destination object. However if the container label does not contain
					the destination object's objectid then is is a global container and therefore
					should not be removed because it *was not copied* to begin with.
					*/
					 
					//First verify that getData() returned a record by checking for the existance of LABEL
					if(structKeyExists(containerData,"label") AND find(qDestCon.objectid[index],containerData.label))
					{		
						//delete all rule data from this container
						deleteContainerRules(containerid=qDestCon.containerid[index]);
						//delete the container
						super.deleteData(qDestCon.containerid[index]);
						//delete the refContainers entry for this container
						deleteRefContainerData(containerid=qDestCon.containerid[index],dsn=arguments.dsn);
					}
				}
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
					qGetContainer = getContainer(dsn=arguments.dsn,label=st.label);
					
					if(NOT qGetContainer.recordCount)
					{
						createData(stProperties=st,dsn=arguments.dsn);
						//and log a reference to it in refContainers
						createDataRefContainer(objectid=arguments.destObjectid,containerid=st.objectid);
					}
				}
				
			}
			
			if(arguments.bDeleteSrcData)
			{
				for(index = 1;index LTE qSrcCon.recordcount;index=index+1)
				{	
					//get the data on the container I might delete
					containerData = super.getData(qSrcCon.containerid[index]);
					/*
					If I find the objectid of the source object in the container label
					then I will delete the container because it *is* a unique container and is only
					used in the source object. However if the container label does not contain
					the source object's objectid then is is a global container and therefore
					should not be removed because it *was not copied* to begin with.
					*/ 
					if(not structIsEmpty(containerData))
					{
						if(find(qSrcCon.objectid[index],containerData.label))
						{		
							//delete all rule data from this container
							deleteContainerRules(containerid=qSrcCon.containerid[index]);
							//delete the container
							super.deleteData(qSrcCon.containerid[index]);
							//delete the RefContainers record for this container
							deleteRefContainerData(containerid=qSrcCon.containerid[index], dsn=arguments.dsn);
						}
					}
				}
			}	
			
		</cfscript>
	</cffunction>
	
	<cffunction name="delete" hint="deletes all container data by objectid" returntype="struct">
		<cfargument name="objectid" required="Yes">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfset var qRefObjects = ''>
		<cfset var qObjs = ''>
		<cfset var index = 1>
		<cfset var stReturn = StructNew()>
		<cfset stReturn.bSuccess = true>
		<cfset stReturn.message = "">

		<!--- container shold only be deleted if not used by --->

		<!--- need to delete [container] [objectid] and associtaed [container_arules] --->
		<cfset super.deleteData(arguments.objectid)>

		<!--- set to remove [mirrorid] if [container] reflected by another --->
		<cfquery name="qUpdate" datasource="#application.dsn#">
		UPDATE	#application.dbowner#container
		SET		mirrorid = ''
		WHERE	mirrorid = '#arguments.objectid#'
		</cfquery>

		<!--- delete container from [refcontainers] for object content types --->
		<cfquery name="qDelete" datasource="#application.dsn#">
		DELETE
		FROM	#application.dbowner#refContainers
		WHERE	containerid = '#arguments.objectid#'
		</cfquery>

		<cfreturn stReturn>
	</cffunction>
	
	<cffunction name="getDisplay" hint="Gets webskins for container content">
		<cfargument name="containerBody" required="true">
		<cfargument name="template" required="true">
		
		<cfset variables.containerBody = arguments.containerBody>
		<cftry>
			<cfinclude template="/farcry/projects/#application.applicationname#/webskin/container/#template#.cfm">
			
			<cfcatch>
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>
		
	</cffunction>			
			
	<cffunction name="getDistinctObjectsByContainer">	
		<cfargument name="lContainerIds" required="Yes" hint="value list (not quoted) of container ids">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfset var q = ''>
		
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
		<cfset var q = ''>
		
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
		<cfargument name="dbowner" required="No" default="#application.dbowner#">
		<cfset var q = ''>
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT *
			FROM #arguments.dbowner#refContainers r
			WHERE objectid = '#arguments.objectid#'
		</cfquery>
		
		<cfreturn q>
	
	</cffunction> 	
	
	<cffunction name="refContainerDataExists" hint="gets refContainer Entries for a given container and object">
		<cfargument name="containerid" required="Yes">
		<cfargument name="objectid" required="Yes">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="dbowner" required="No" default="#application.dbowner#">
		<cfset var q = ''>
		
		<cfquery name="q" datasource="#arguments.dsn#">
			SELECT *
			FROM #arguments.dbowner#refContainers r
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
			<cfcase value="mysql,mysql5">
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
			<cfcase value="postgresql">
				<cftry><cfquery datasource="#arguments.dsn#">
					DROP TABLE #arguments.dbowner#refContainers
				</cfquery><cfcatch></cfcatch></cftry>
				<cfquery datasource="#arguments.dsn#">
					CREATE TABLE #arguments.dbowner#refContainers 
					(objectid VARCHAR (50) NOT NULL, 
					 containerid VARCHAR (50) NOT NULL 
					) 
				</cfquery>	 
			</cfcase>
			<cfdefaultcase>
				<cfquery name="qCreateTables" datasource="#arguments.dsn#">
				if exists (select * from sysobjects where id = object_id(N'#application.dbowner#refContainers') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				drop table #application.dbowner#refContainers
		
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
		<cfset var qGetContainer = ''>
				
			
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

	<cffunction name="getContainerbylabel" access="public" returntype="struct" hint="Retrieve container instance by label lookup and return structure.">
		<cfargument name="label" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		<cfset var qGetContainer="">
		<cfset var stReturn=structNew()>
		<cfquery name="qGetContainer" datasource="#arguments.dsn#">
			SELECT *
			FROM #application.dbowner#container 
			WHERE 
			label = '#arguments.label#'
		</cfquery>
		<cfif qGetContainer.recordcount gt 0>
		<!--- convert query to structure --->
		<cfloop list="#qGetContainer.columnlist#" index="key">
			<cfset stReturn[key]=Evaluate("qGetContainer.#key#")>
		</cfloop>
		</cfif>
		<!--- returns empty structure if no result; like getData() --->
		<cfreturn stReturn>
	</cffunction> 
	
	<cffunction name="populate" access="public" hint="Gets Rule instances and execute them">
		<cfargument name="aRules" type="array" required="true">
		<cfset var i=1>
		<cfset var o="">
		<cfset var rule="">
		
		<cftrace type="warning" text="populating container" var="arguments.arules" />
		
		<cfset request.aInvocations = arrayNew(1)>
		<cfset oFourq = createObject("component", "farcry.core.packages.fourq.fourq")>
		<cfloop from="1" to="#arrayLen(arguments.aRules)#" index="i">
			 <cftry> 
				<cfset rule = oFourq.findType(objectid=arguments.aRules[i])>
				<cfinvoke objectID="#arguments.aRules[i]#" component="#application.rules[rule].rulePath#" method="execute"/>										
			  	<cfcatch type="any">
					<!--- show error if debugging --->
					<cfif isdefined("url.debug")>
						<cfset request.cfdumpinited = false>
						<cfoutput>#cfcatch.message#<br />#cfcatch.detail#</cfoutput>
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
				<cfif structKeyExists(request.aInvocations[i],"preHTML")>
					<cfoutput>#request.aInvocations[i].preHTML#</cfoutput>
				</cfif>

				<cfset request.i = i />
				<cfset html = createObject("component", "#request.aInvocations[i].typename#").getView(objectid=request.aInvocations[i].objectID, template=request.aInvocations[i].method, alternateHTML="[#request.aInvocations[i].method#] does not exist") />	
				<cfoutput>#html#</cfoutput>

				<cfif structKeyExists(request.aInvocations[i],"postHTML")>
					<cfoutput>#request.aInvocations[i].postHTML#</cfoutput>
				</cfif>
			<cfelse>
				<cfoutput>
					#request.aInvocations[i]#
				</cfoutput>	
			</cfif>	
		</cfloop>
	</cffunction>
	
	<cffunction name="getSharedContainers" access="public" hint="Returns a query of containers with bShared true." returntype="query" output="false">
		<cfset var qReturn="">
		<cfquery datasource="#application.dsn#" name="qReturn">
		SELECT * FROM container WHERE bshared = 1
		ORDER BY label
		</cfquery>
		<cfreturn qReturn>
	</cffunction>

	<cffunction name="setReflection" access="public" hint="Updates container mirrorid property after validation." returntype="struct" output="false">
		<cfargument name="objectid" required="true" type="uuid" hint="ObjectID for the container instance being updated.">
		<cfargument name="mirrorid" required="true" type="uuid" hint="ObjectID for the container instance providing the reflection; that is, the shared container.">
		<cfset var stMirror=getData(objectid=arguments.mirrorid)>
		<cfset var stContainer=getData(objectid=arguments.objectid)>
		<cfset stReturn=structNew()>
		
		<!--- // check that mirrorid container is shared --->
		<cfif len(stMirror.bShared) AND NOT stMirror.bShared>
			<cfthrow type="rules.container" message="Container not shared.  Only shared container instances may be mirrored.">
		</cfif>
		<!--- // check that objectid container is not shared --->
		<cfif NOT len(stMirror.bShared) AND stContainer.bShared>
			<cfthrow type="rules.container" message="Container is shared.  Shared container instances may not mirror other containers.">
		</cfif>
		<cfscript>
			stprops.objectid=arguments.objectid;
			stprops.mirrorid=arguments.mirrorid;
			streturn=setdata(stproperties=stprops);
			return(stReturn);
		</cfscript>
	</cffunction>
	
	<cffunction name="deleteReflection" access="public" hint="Deletes mirrorid for a specified container." returntype="struct" output="false">
		<cfargument name="objectid" required="true" type="uuid" hint="ObjectID for the container instance being updated.">
		<cfset var stReturn=structNew()>
		<cfscript>
			stprops.objectid=arguments.objectid;
			stprops.mirrorid="";
			streturn=setdata(stproperties=stprops);
			return(stReturn);
		</cfscript>
	</cffunction>

	<cffunction name="getReflection" access="public" hint="Gets the reflected container. If mirror container doesn't exist, method deletes reference." returntype="struct" output="false">
		<cfargument name="containerid" required="true" type="uuid" hint="ObjectID for the primary container.">
		<cfargument name="mirrorid" required="true" type="uuid" hint="ObjectID for the mirrored container instance to be retrieved.">
		<cfset var stReturn=structNew()>

		<cfscript>
		// get mirrored container
		stReturn=getdata(objectid=arguments.mirrorid);
		// delete if it doesn't exist
		if (structisempty(streturn))
			deletereflection(objectid=containerid);
		return(stReturn);
		</cfscript>
	</cffunction>

</cfcomponent>