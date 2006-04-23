<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/ruleHandpicked.cfc,v 1.17 2003/09/22 05:24:57 brendan Exp $
$Author: brendan $
$Date: 2003/09/22 05:24:57 $
$Name: b201 $
$Revision: 1.17 $

|| DESCRIPTION || 
$Description: Hand-pick and display individual object instances with a specified displayTeaser* handler. Restricted to those components with metadata bScheduled=true. $

|| DEVELOPER ||
$Developer: Paul Harrison (paul@daemon.com.au) $
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent displayname="Handpicked Rule" extends="rules" hint="Hand-pick and display individual object instances with a specified displayTeaser* handler. Restricted to those components with metadata bScheduled=true." bCustomRule="0">
<cfproperty name="intro" hint="A provision for intro text to any handpicked rule" type="longchar">
<cfproperty name="objectWDDX" type="longchar"  hint="Array of WDDX Packets containing an stParams stucture.stParams has objectID and method specified as well as any other keys for use with the selected method " required="no" default="">

	<cffunction name="cfml2wddx" hint="A wrapper to cfwddx - converts cfml to wddx">
		<cfargument name="stInput">
		<cftry>
			<cfwddx action="cfml2wddx" input="#arguments.stInput#" output="stWDDXOut">
		<cfcatch>
			<cfset stWDDXOut = arrayNew(1)>
		</cfcatch>
		</cftry>		
		<cfreturn stWDDXOut>
	</cffunction>
	
	<cffunction name="wddx2cfml" hint="A wrapper to cfwddx - converts wddx to cfml">
		<cfargument name="stInput">
			<cftry>
				<cfwddx action="wddx2cfml" input="#arguments.stInput#" output="stWDDXOut">
			<cfcatch>
				<cfset stWDDXOut = arrayNew(1)>
			</cfcatch>
			</cftry>
		<cfreturn stWDDXOut>
	</cffunction>

	<cffunction name="cleanUUID">
		<cfargument name="objectID" type="uuid">
		<cfset rObjectID = trim(replace(arguments.objectID,"-","","ALL"))> 
		<cfreturn rObjectID>
	</cffunction>
	
	<cffunction name="dump">
		<cfargument name="var">
		<cfargument name="label" default="dump">
			<cfdump var="#arguments.var#" label="#arguments.label#">
	</cffunction>
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfargument name="cancelLocation" required="no" type="string" default="#application.url.farcry#/navajo/editContainer.cfm?containerid=#url.containerid#">
        <cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="farcry">
		<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
		<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
		
		<cfscript>
			stObj = this.getData(arguments.objectid); 
			stObj.cleanObjectID = cleanUUID(arguments.objectID); //cleanObjectID refers to the rule UUID with the '-' removed so varibles can be named legally
			stObj.existingObjectWDDX = wddx2cfml(stObj.objectWDDX);
			stObjectWDDX = wddx2cfml(stObj.objectWDDX);
			if (isArray(stObjectWDDX)){
				aObjectIDs = arrayNew(1);
				for(index=1; index LTE arrayLen(stObjectWDDX);index=index+1){ 
					arrayAppend(aObjectIDs,stObjectWDDX[index].objectID);
				}		
				stObj.lObjectIDs = arrayToList(aObjectIDs);
			}
			else 
			{
				 stObj.lObjectIDs = '';
			}
		</cfscript>			
		
		<!--- Default Vals --->
		<cfparam name="URL.handpickaction" default="list">
		<cfparam name="URL.killplp" default="0">
		<cfparam name="URL.containerid" default="">
		
		
		<!--- Handpicking an object is a multistep process - sticking it in a PLP --->
		<cfswitch expression="#URL.handpickaction#">
		
		<cfcase value="add">
			
			<farcry:plp 
				owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
				stepDir="/farcry/farcry_core/packages/rules/_ruleHandpicked"
				cancelLocation="#arguments.cancelLocation#"
				iTimeout="15"
				stInput="#stObj#"
				bDebug="0"
				bForceNewInstance="#url.killplp#"
				r_stOutput="stOutput"
				storage="file"
				storagedir="#application.fourq.plpstorage#"
				redirection="server"
				r_bPLPIsComplete="bComplete">
	
				<farcry:plpstep name="Select Object Type" template="selectType.cfm">
				<farcry:plpstep name="Select Objects" template="selectObjects.cfm">
				<farcry:plpstep name="Select Display Methods" template="selectDisplayMethods.cfm">
				<farcry:plpstep name="Complete" template="complete.cfm">
			</farcry:plp>
		</cfcase>
		<cfdefaultcase>
			<farcry:plp 
				owner="list_#session.dmSec.authentication.userlogin#_#stObj.objectID#"
				stepDir="/farcry/farcry_core/packages/rules/_ruleHandpicked"
				cancelLocation="#arguments.cancelLocation#"
				iTimeout="15"
				stInput="#stObj#"
				bDebug="0"
				bForceNewInstance="#url.killplp#"
				r_stOutput="stOutput"
				storage="file"
				storagedir="#application.fourq.plpstorage#"
				redirection="server"
				r_bPLPIsComplete="bListComplete">
				
				<farcry:plpstep name="List" template="listObjects.cfm">
				<farcry:plpstep name="Complete" template="completelist.cfm">
				
			</farcry:plp>
		</cfdefaultcase>
		</cfswitch>
		
		

		<!--- bComplete flags the the user has finished adding new objects - dealt with quite differently to if they are just reordering --->
		<cfif (isDefined("bComplete") and bComplete)>
			
			<cfscript>
				stProperties = Duplicate(stOutput);
				aWDDXObjects = listToArray(stProperties.lObjectIDs);
				//make the packet for each selected object
				existingObjectWDDX = stProperties.existingObjectWDDX;
				//dump(aWDDXObjects,"aWDDXObjects");
				//dump(existingObjectWDDX,"existingObjectWDDX");
				stWDDX = arrayNew(1);  //this will hold the final structures to convert to WDDX	
				//Loop through all the selected objectIDs
				for(index=1;index LTE arrayLen(aWDDXObjects); index=index+1 ){
					//doing a type lookup here - because the PLP gets passed in objectIDs' of potentially multiple typenames.
					//The PLP is designed to deal with one typename only, so we want to preserve these WDDX packets
					thisType = this.findType(aWDDXObjects[index]);
					stWDDX[index] = structNew();
					if(NOT thistype IS stProperties.dmType){
						for(i=1;i LTE arrayLen(existingObjectWDDX);i=i+1){
							if(existingObjectWDDX[i].objectID IS aWDDXObjects[index])
							{
								stWDDX[index] = Duplicate(existingObjectWDDX[i]);
								break;
							}
						}
					}
					else	
					{	
						stWDDX[index].objectID = aWDDXObjects[index];
						if(application.types['#thisType#'].bCustomType)
							thisPackagePath = application.custompackagepath;
						else	
							thisPackagePath = application.packagepath;
						stWDDX[index].typename = thisPackagePath & ".types." & thistype;
						//remember that we had to 'clean' the UUIDS for use in variable names
						cleanUUID =  trim(replace(aWDDXObjects[index],"-","","ALL"));
						stWDDX[index].method = evaluate("stProperties.method_"& cleanUUID & ".displayMethod");					}
				}
				//converts the stWDDX structure of objects to WDDX
				aStTMP = arrayNew(1);
				//first make sure existing order is retained - then whack on new objects to the end
				for (x=1;x LTE arrayLen(existingObjectWDDX);x=x+1)
				{
					for(y=1;y LTE arrayLen(stWDDX);y = y + 1)
					{
						if (stWDDX[y].objectid IS existingObjectWDDX[x].objectid)
						{	//dump(stWDDX[y]);
							arrayAppend(aStTmp,stWDDX[y]);
							break;
						}	
						 
					}	
				}
				//dump(astTmp);
				for (x=arrayLen(stWDDX);x GTE 1 ;x=x-1)
				{   bFound = 0;
					
					for (y=arrayLen(aStTMP);y GTE 1;y=y-1)
					{
						if(stWDDX[x].objectid IS aStTMP[y].objectid)
						{
							bFound = 1;
						break;	
						}
					}
					if (NOT bFound)
						arrayAppend(aStTmp,stWDDX[x]);
				}	
				stWDDX = aStTMP;
				
				//dump(stWddx);
				stProperties.objectWDDX = cfml2WDDX(stWDDX);	
				stProperties.datetimelastupdated = Now();
				stProperties.lastupdatedby = getAuthUser();
			</cfscript>
			<!--- <cfdump var="#stProperties#"> --->
			<!--- Now we update the datastore --->
			<q4:contentobjectdata
			 typename="#application.packagepath#.rules.ruleHandpicked"
			 stProperties="#stProperties#"
			 objectid="#stObj.ObjectID#"> 
			 
			 <div class="FormTitle" align="center">Action Complete - Object Updated 
				<cfform action="#CGI.script_name#?containerID=#URL.containerID#&handpickaction=1ist&killplp=1&ruleid=#stobj.objectid#&typename=rulehandpicked" method="post">
					<input type="submit" class="normalbttnstyle" value="continue">
				</cfform>
			</div>
		</cfif>
		
			
		<cfif (isDefined("bListComplete") AND bListComplete)>
			<cfscript>
				stProperties = Duplicate(stOutput);
				//get rid of any wddx elements that we may have deleted
				aObjectWDDX = wddx2cfml(stProperties.objectWDDX); //this *should* always be an array 	
				aOrderWDDX = listToArray(stProperties.lObjectIds); //this determins the order of the wddx packets
				stWDDX = arrayNew(1); //holds the structures to write to wddx
				if(isArray(aObjectWDDX)){  
					for(i=1;i LTE arrayLen(aOrderWDDX);i=i+1){						
						for(index=arrayLen(aObjectWDDX);index GTE 1;index=index-1){
							if(aObjectWDDX[index].objectID IS aOrderWDDX[i])
							{
								if(NOT listContainsNoCase(stProperties.lObjectIDs,aObjectWDDX[index].objectID))
								{		
									arrayDeleteAt(aObjectWDDX,index);
								}else
								{
									cleanUUID =  trim(replace(aObjectWDDX[index].objectID,"-","","ALL"));
									stWDDX[i] = structNew();
									stWDDX[i].objectID = aObjectWDDX[index].objectID;
									stWDDX[i].typename = aObjectWDDX[index].typename;
									stWDDX[i].method = evaluate("stProperties.method_"& cleanUUID & ".displayMethod");		
								}
								break;
							}
							else
								continue;
						}		
					}	
				}	
				stProperties.objectWDDX = cfml2WDDX(stWDDX);
				stProperties.datetimelastupdated = Now();
				stProperties.lastupdatedby = getAuthUser();
			</cfscript>
			<!--- <cfdump var="#stProperties#"> --->
			<q4:contentobjectdata
			 typename="#application.packagepath#.rules.ruleHandpicked"
			 stProperties="#stProperties#"
			 objectid="#stObj.ObjectID#"> 
			 
			 <div class="FormTitle" align="center" >Action Complete - Object Updated <br>
				<cfform action="#CGI.script_name#?containerID=#URL.containerID#&ruleid=#stobj.objectid#&typename=rulehandpicked" method="post">
					<input type="submit" class="normalbttnstyle" value="continue">
				</cfform>
			</div>
		</cfif>	 
		
	</cffunction> 
	
	
	<cffunction access="public" name="execute" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		
		<cfset stObj = this.getData(arguments.objectid)> 
		<cftry>
		<cfwddx action="wddx2cfml" input="#stObj.objectWDDX#"  output="stObjectWDDX">
		<cfif isArray(stObjectWDDX)>
			<cfif arrayLen(stObjectWDDX) GT 0>
				<cfif len(trim(stObj.intro))>
					<cfset tmp = arrayAppend(request.aInvocations,stObj.intro)>
				</cfif>
				<cfloop from="1" to="#arrayLen(stObjectWDDX)#" index="i">
				<cfscript>
					stInvoke = structNew();
					stInvoke.objectID = stObjectWDDX[i].objectID;
					/* 
					* Dirty hack to fix the problem with full typenames
					* being stored in the database after moving to a
					* single /farcry coldfusion mapping 
					*/
					if (listFirst(stObjectWDDX[i].typename,'.') eq 'farcry_core') {
						stInvoke.typename = 'farcry.'&stObjectWDDX[i].typename;
					}
					else {
						stInvoke.typename = stObjectWDDX[i].typename;
					}
					stInvoke.method = stObjectWDDX[i].method;
					arrayAppend(request.aInvocations,stInvoke);
				</cfscript>
				</cfloop> 
			</cfif>
		</cfif>
		<cfcatch>
			<!-- Empty wddx packet-->
		</cfcatch>
		</cftry>
	</cffunction> 

</cfcomponent>