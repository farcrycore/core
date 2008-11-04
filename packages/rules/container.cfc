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
<!---
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
<cfcomponent extends="farcry.core.packages.fourq.fourq" displayname="Container Management" hint="Manages all core functions for container instance management." bObjectBroker="true">
	<cfproperty name="objectID" hint="Container instance primary key." type="uuid" required="true" />
	<cfproperty name="label" hint="Label for the container instance."  type="nstring" default="(unspecified)">
	<cfproperty name="aRules" hint="Array of rule objects to be managed by this container." type="array"> 
	<cfproperty name="bShared" hint="Flags whether or not this container is to be shared amongst various objects and scheduled by publishing rule." type="boolean" default="0">
	<cfproperty name="mirrorID" hint="The UUID of a shared container to be used instead of this container; a mirror container if you like." type="UUID" default="">
	<cfproperty name="displayMethod" hint="The webskin that will encapsulate container content" type="nstring" default=""> 
	
	<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">
	
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
		</cfscript>	
				
		<cfif qSrcCon.recordcount>
			<cfloop from="1" to="#qSrcCon.recordcount#" index="index">
				<cfset st = getData(objectid=qSrcCon.containerid[index]) />
				<!--- //dump(st,'before'); --->
				<!--- //need to copy all rules now. --->
				<cfset aRules = arrayNew(1) />
				<cfif (not structIsEmpty(st))>
				
					<cfloop from="1" to="#arrayLen(st.aRules)#" index="x">
						<cfset ruletype = findType(objectid=st.aRules[x]) />
						<cfif (structKeyExists(application.rules,ruletype))>
						
							<cfset o = createObject("component",application.rules[ruletype].rulepath) />
							<cfset stRule = application.coapi.coapiUtilities.createCopy(objectid=st.aRules[x]) />							
							<!--- //create the rule --->
							<cfset o.createData(stProperties=stRule,dsn=arguments.dsn) />
							<!--- //now create the new array reference to it --->
							<cfset arrayAppend(aRules,stRule.objectid) />
						</cfif>
					</cfloop>
					<cfset st.aRules = aRules />
					<!--- //change the label - containers are currently obtained by label --->
					<cfset st.label = replace(st.label,arguments.srcObjectId,arguments.destObjectId,"ALL") />
					<cfset st.objectid = createUUID() />
					<!--- //now we want to create this new container --->
					<cfset qGetContainer = getContainer(dsn=arguments.dsn,label=st.label) />
					
					<cfif (NOT qGetContainer.recordCount)>
						<cfset createData(stProperties=st,dsn=arguments.dsn) />
						<!--- //and log a reference to it in refContainers --->
						<cfset createDataRefContainer(objectid=arguments.destObjectid,containerid=st.objectid) />
					</cfif>
				</cfif>
			</cfloop> 
		</cfif>

			
			
		<cfscript>	
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
			<cfinclude template="#application.coapi.coapiadmin.getWebskinPath(typename='container',template=template)#" />
			
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
			
			<!--- TODO: this should be in gateway or something --->
			<cfcase value="HSQLDB">
				<cfquery datasource="#arguments.dsn#">
					DROP TABLE refContainers IF EXISTS
				</cfquery>
				<cfquery datasource="#arguments.dsn#">
					CREATE TABLE refContainers (
						objectid VARCHAR(50) NOT NULL, 
						containerid VARCHAR(50) NOT NULL 
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
		<cfset var ruleHTML="" />
		<cfset var aProps = arraynew(1) />
		<cfset var stProps = structnew() />
		<cfset var prop = "" />
		<cfset var ruleError = "" />
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
		
		<cftrace type="warning" text="populating container" var="arguments.arules" />
		
		<cfset request.aInvocations = arrayNew(1)>
		<cfset oFourq = createObject("component", "farcry.core.packages.fourq.fourq")>
		<cfloop from="1" to="#arrayLen(arguments.aRules)#" index="i">
			 <cftry> 
				<cfset rule = oFourq.findType(objectid=arguments.aRules[i])>
				
				<cfset oRule = createObject("component", application.stcoapi[rule].packagepath) />

				<cfif request.mode.design and request.mode.showcontainers gt 0>
					<!--- request.thiscontainer is set up in the container tag and corresponds to the page container, not the shared container --->
					<skin:view objectid="#arguments.aRules[i]#" webskin="displayAdminToolbar" index="#i#" r_html="ruleHTML" arraylen="#arraylen(arguments.aRules)#" container="#request.thiscontainer#" />
					
					<cfset arrayappend(request.aInvocations, ruleHTML) />
				</cfif>
				
				<cfset ruleHTML = oRule.getView(objectid=arguments.aRules[i], template="execute", alternateHTML="") />
				<cfif len(trim(ruleHTML))>
					<cfset arrayappend(request.aInvocations, ruleHTML) />
				<cfelse>
					<cfset oRule.execute(objectid=arguments.aRules[i]) />
				</cfif>
							
			  	<cfcatch type="any">

					<!--- show error if debugging --->
					<cfif isdefined("url.debug") and url.debug EQ 1>
						<cfset request.cfdumpinited = false>
						
						<extjs:bubble title="Error with rule '#application.stcoapi[rule].displayName#'" bAutoHide="false">
							<cfoutput>#cfcatch.message#<br />#cfcatch.detail#</cfoutput>
						</extjs:bubble>							
						
						<cfsavecontent variable="ruleError">
							<cfdump var="#cfcatch#" expand="false" label="#cfcatch.message#">
						</cfsavecontent>
						<cfset arrayappend(request.aInvocations, "#ruleError#") />
						
				  	<cfelseif request.mode.design and request.mode.showcontainers gt 0>
						<extjs:bubble title="Error with rule '#application.stcoapi[rule].displayName#'" bAutoHide="true">
							<cfoutput>#cfcatch.message#<br />#cfcatch.detail#</cfoutput>
						</extjs:bubble>
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

	<cffunction name="getView" access="public" output="true" returntype="string" hint="Returns the HTML of a view from the webskin content type folder.">
		<cfargument name="objectid" required="no" type="UUID" hint="ObjectID of the object that is to be rendered by the webskin view." />
		<cfargument name="template" required="yes" type="string" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
		<cfargument name="stparam" required="false" type="struct" default="#structNew()#" hint="Structure of parameters to be passed into the display handler." />
		<cfargument name="stobject" required="no" type="struct" hint="Property structure to render in view.  Overrides any property structure mapped to arguments.objectid. Useful if you want to render a view with a modified content item.">
		<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
		<cfargument name="OnExit" required="no" type="any" default="">
		<cfargument name="alternateHTML" required="no" type="string" hint="If the webskin template does not exist, if this argument is sent in, its value will be passed back as the result.">
		<cfargument name="hashKey" required="no" default="" type="string" hint="Pass in a key to be used to hash the objectBroker webskin cache">
		
		<cfset var stResult = structNew() />
		<cfset var stObj = StructNew() />
		<cfset var WebskinPath = "" />
		<cfset var webskinHTML = "" />
		<cfset var stCurrentView = structNew() />
		<cfset var bTypeWebskin = false />
		<cfset var stArgs = structnew() />

		<!--- make sure that .cfm isn't passed to this method in the template argument --->
		<cfif listLast(arguments.template,".") EQ "cfm">
			<cfset arguments.template = ReplaceNoCase(arguments.template,".cfm", "", "all") />
		</cfif>
		

		<cfif isDefined("arguments.stobject")>
			<cfset stobj=arguments.stobject />
			<cfset instance.stobj = stObj />
		<cfelse>
			<cfif not structKeyExists(arguments, "objectid") or not len(arguments.objectid)>
				<!--- If the objectid has not been sent, we need to create a default object. --->
				<cfset arguments.objectid = createUUID() />
				
				<cfset bTypeWebskin = true />
			</cfif>		
			
			<!--- get the data for this instance --->
			<cfset stObj = getData(objectid=arguments.objectID,dsn=arguments.dsn)>
			
		</cfif>

		<!--- Check permissions on this webskin --->
		<cfif arguments.template eq "deniedaccess" or not application.security.checkPermission(type=stObj.typename,webskin=arguments.template)>
			<cfsavecontent variable="webskinHTML"><cfinclude template="#getWebskinPath(stObj.typename,'deniedaccess')#" /></cfsavecontent>
			<cfreturn webskinHTML />
		</cfif>
			
		<cfif NOT structIsEmpty(stObj)>	
		
			<!--- Check to see if the webskin is in the object broker --->
			<cfif bTypeWebskin>
				<cfset webskinHTML = application.coapi.objectBroker.getWebskin(typename=stobj.typename, template=arguments.template, hashKey="#arguments.hashKey#") />		
			<cfelse>
				<cfset webskinHTML = application.coapi.objectBroker.getWebskin(objectid=stobj.objectid, typename=stobj.typename, template=arguments.template, hashKey="#arguments.hashKey#") />		
			</cfif>

			<cftimer label="getView: #stobj.typename# (#arguments.template#)">
			<cfif not len(webskinHTML)>
				<cfset webskinPath = application.coapi.coapiadmin.getWebskinPath(typename=stObj.typename, template=arguments.template) />
						
				<cfif len(webskinPath)>
					
					<!--- Setup the current request.aAncestorWebskins in case this does not yet exist --->
					<cfif not structKeyExists(request, "aAncestorWebskins")>
						<cfset request.aAncestorWebskins = arrayNew(1) />
					</cfif>	
					<!--- Add the current view to the array --->
					<cfif not bTypeWebskin>
						<cfset stCurrentView.objectid = stobj.objectid />
					</cfif>
					<cfset stCurrentView.typename = stobj.typename />
					<cfset stCurrentView.template = arguments.template />
					<cfset stCurrentView.hashKey = arguments.hashKey />
					<cfset stCurrentView.timeout = application.coapi.coapiadmin.getWebskinTimeOut(typename=stObj.typename, template=arguments.template) />
					<cfset stCurrentView.hashURL = application.coapi.coapiadmin.getWebskinHashURL(typename=stObj.typename, template=arguments.template) />
					<cfset stCurrentView.okToCache = 1 />
					<cfset stCurrentView.inHead = structNew() />
					<cfset stCurrentView.inHead.stCustom = structNew() />
					<cfset stCurrentView.inHead.aCustomIDs = arrayNew(1) />
					<cfset stCurrentView.inHead.stOnReady = structNew() />
					<cfset stCurrentView.inHead.aOnReadyIDs = arrayNew(1) />
					<cfset arrayAppend(request.aAncestorWebskins, stCurrentView) />					
					
					<!--- Include the View --->
					<cfsavecontent variable="webskinHTML">
						<cfinclude template="#WebskinPath#">
					</cfsavecontent>
										
					<!--- If the current view (Last Item In the array) is still OkToCache --->
					<cfif request.aAncestorWebskins[arrayLen(request.aAncestorWebskins)].okToCache>
						<!--- Add the webskin to the object broker if required --->
						<cfif bTypeWebskin>
							<cfset bAdded = application.coapi.objectBroker.addWebskin(typename=stobj.typename, template=arguments.template, html=webskinHTML, stCurrentView=stCurrentView) />	
						<cfelse>
							<cfset bAdded = application.coapi.objectBroker.addWebskin(objectid=stobj.objectid, typename=stobj.typename, template=arguments.template, html=webskinHTML, stCurrentView=stCurrentView) />	
						</cfif>
					</cfif>
					
					<cfif arrayLen(request.aAncestorWebskins)>
						
						<cfset oWebskinAncestor = createObject("component", application.stcoapi.dmWebskinAncestor.packagePath) />						
						
						<!--- 
						Loop through ancestors to determine whether to add to dmWebskinAncestor Table
						Only webskins that are cached are added to the table.
						 --->
						<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">
							
							<!--- Add the ancestor records so we know where this webskin is located throughout the site. --->
							<cfif bTypeWebskin or not structkeyexists(request.aAncestorWebskins[i],"objectid") or stobj.objectid NEQ request.aAncestorWebskins[i].objectID>
								
								<cfif listFindNoCase(application.stcoapi[request.aAncestorWebskins[i].typename].lObjectBrokerWebskins, request.aAncestorWebskins[i].template)>
									<cfif application.stcoapi[request.aAncestorWebskins[i].typename].stObjectBrokerWebskins[request.aAncestorWebskins[i].template].timeout NEQ 0>
										
										<cfset stArgs = structnew() />
										<cfif bTypeWebskin>
											<cfset stArgs.webskinTypename = stObj.typename />
											<cfset stArgs.webskintemplate = arguments.template />
										<cfelse>
											<cfset stArgs.webskinObjectID = stobj.objectid />
										</cfif>
										<cfif structkeyexists(request.aAncestorWebskins[i],"objectid")>
											<cfset stArgs.ancestorID = request.aAncestorWebskins[i].objectID />
										<cfelse>
											<cfset stArgs.ancestorTypename = request.aAncestorWebskins[i].typename />
										</cfif>
										<cfset stArgs.ancestorTemplate = request.aAncestorWebskins[i].template />
										<cfset bAncestorExists = oWebskinAncestor.checkAncestorExists(argumentCollection=stArgs) />
											
										<cfif not bAncestorExists>
											<cfset stProperties = structNew() />
											<cfif bTypeWebskin>
												<cfset stProperties.webskinObjectID = "" />
											<cfelse>
												<cfset stProperties.webskinObjectID = stobj.objectid />
											</cfif>
											<cfset stProperties.webskinTypename = stobj.typename />
											<cfset stProperties.webskinTemplate = arguments.template />
											<cfif structkeyexists(request.aAncestorWebskins[i],"objectid")>
												<cfset stProperties.ancestorID = request.aAncestorWebskins[i].objectID />
											</cfif>
											<cfset stProperties.ancestorTypename = request.aAncestorWebskins[i].typename />
											<cfset stProperties.ancestorTemplate = request.aAncestorWebskins[i].template />
											
											<cfset stResult = oWebskinAncestor.createData(stProperties=stProperties) />
										</cfif>
									</cfif>
								</cfif>
							</cfif>
							
							<!--- If this webskin is to never cache, make sure all ancestors also never cache --->
							<cfif stCurrentView.timeout EQ 0>
								<cfset request.aAncestorWebskins[i].okToCache = 0 />
							</cfif>
							
							<!--- If the timeout of this webskin is less than its parents, reset the parents timeout so timeout propogates upwards --->
							<cfif stCurrentView.timeout LT request.aAncestorWebskins[i].timeout>
								<cfset request.aAncestorWebskins[i].timeout = stCurrentView.timeout />
							</cfif>
							
							<!--- If this webskin is to have its url hashed, make sure all ancestors also have their webskins hashed --->
							<cfif stCurrentView.hashURL>
								<cfset request.aAncestorWebskins[i].hashURL = true />
							</cfif>
							<!--- If this webskin is to add a hashKey, make sure all ancestors also have the hashKey added --->
							<cfif len(stCurrentView.hashKey)>
								<cfset request.aAncestorWebskins[i].hashKey = "#request.aAncestorWebskins[i].hashKey##stCurrentView.hashKey#" />
							</cfif>
						</cfloop>
					</cfif>
					
					<!--- Remove the current view (last item in the array) from the Ancestor Webskins array --->
					<cfset ArrayDeleteAt(request.aAncestorWebskins, arrayLen(request.aAncestorWebskins)) />
					
				<cfelseif structKeyExists(arguments, "alternateHTML")>
					<cfset webskinHTML = arguments.alternateHTML />
				<cfelse>
					<cfthrow type="Application" detail="Error: Template not found [/webskin/#stObj.typename#/#arguments.template#.cfm] and no alternate html provided." />
				</cfif>	
			</cfif>		
			</cftimer>
		<cfelse>
			<cfthrow type="Application" detail="Error: When trying to render [/webskin/#stObj.typename#/#arguments.template#.cfm] the object was not created correctly." />	
		</cfif>
		<cfreturn webskinHTML />
	</cffunction>
	
</cfcomponent>