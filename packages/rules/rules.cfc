<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
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
<!--- @@Description: Rules Abstract Class --->

<cfcomponent 
	extends="farcry.core.packages.fourq.fourq" bAbstract="true"
	displayname="Publishing Rules" 
	hint="Extend this abstract class to enable a publishing rule."
	icon="fa-wrench">

	<cfproperty name="objectID" type="uuid" required="true">
	<cfproperty name="label" type="string" default="">
	<cfproperty name="datetimelastupdated" displayname="Datetime Lastupdated" type="date" hint="Timestamp for record last modified." required="no" default="" ftType="datetime" ftLabel="Last Updated"> 

	<!--- import tag libraries --->
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">	
	<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz">	
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">	
	<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
		
	
	<cffunction name="getWebskins" returntype="query" access="public" output="false" hint="Returns a query of all available webskins. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" default="#getTypename()#" hint="Typename of instance." />
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
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		
		<cfset var stNewObject = "" />
		
		<cfif not len(arguments.user)>
			<cfif isDefined("session.security.userID")>
				<cfset arguments.user = session.security.userID />
			<cfelse>
				<cfset arguments.user = 'anonymous' />			
			</cfif>
		</cfif>
		
		<cfif not structKeyExists(arguments.stProperties,"objectid")>
			<cfset arguments.stProperties.objectid = application.fc.utils.createJavaUUID() />
		</cfif>
		
		<cfset stNewObject = super.createData(arguments.stProperties) />
		<farcry:logevent objectid="#arguments.stProperties.objectid#" type="rules" event="create" notes="#arguments.auditNote#" />
		
		<cfreturn stNewObject />
	</cffunction>
	
		
	<cffunction name="delete" access="public" hint="Basic delete method for all objects.">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#application.security.getCurrentUserID()#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Deleted">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		
		<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
		
		<cfset super.deleteData(arguments.objectid,arguments.dsn) />
		<farcry:logevent objectid="#arguments.objectid#" type="rule" event="delete" notes="#arguments.auditNote#" />
	</cffunction>	
	
	<cffunction name="getRuleContainerID" access="public" output="false">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">

		<cfset var q = "" />
		<cfset var containerID = "" />
		
		<cfquery datasource="#application.dsn#" name="q">
		select parentID from container_aRules
		WHERE data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectID#" />
		</cfquery>
		
		<cfif q.recordcount>
			<cfset containerID = q.parentID />
		</cfif>
		
		<cfreturn containerID />
	</cffunction>	
	
	<cffunction name="update" access="public" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">

		
		<cfset var stObj = getData(objectid=arguments.objectid) />		
		<cfset var qMetadata = application.rules[stobj.typename].qMetadata >		
		<cfset var updateHTML = "" />		
		<cfset var onExitProcess = StructNew() />	
		<cfset var lWizardSteps = "" />
		<cfset var iWizardStep = "" />
		<cfset var lFieldSets = "" />
		<cfset var iFieldSet = "" />
		<cfset var containerID = "" />

		<cfset var qwizardSteps = queryNew("") />
		<cfset var qwizardStep = queryNew("") />
		<cfset var qFieldSets = queryNew("") />
		<cfset var qFieldset = queryNew("") />

		<cfif structKeyExists(url, "originalID")>
			<cfset containerID = url.originalID />
		<cfelse>
			<cfset containerID = getRuleContainerID(arguments.objectID) />		
		</cfif>
		
		<cfset containerID = replace(containerID,'-','','ALL') />
		
		<cfset onExitProcess.Type = "HTML" />
		<cfsavecontent variable="onExitProcess.content">
			<cfoutput>
				<script type="text/javascript">
					$fc.closeBootstrapModal();
				</script>
			</cfoutput>
		</cfsavecontent>
		
		<cfset updateHTML = getView(stobject="#stobj#", template="update", alternateHTML="", onExitProcess="#onExitProcess#") />
		
		<cfif len(updateHTML)>
			<cfoutput>#updateHTML#</cfoutput>
		<cfelse>
			<!--- IF THE ONLY PROPS ARE OBJECTID and LABEL, then let the user know that we have nothing to edit here. --->
			<cfif listLen(structKeyList(application.rules[stobj.typename].stProps)) LTE 2>
				<cfoutput><h3>No Parameters required</h3></cfoutput>
			</cfif>

			<cfquery dbtype="query" name="qwizardSteps">
			SELECT ftwizardStep
			FROM qMetadata
			WHERE ftwizardStep <> '#stobj.typename#'
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
				<wiz:processwizard>
				
					<!--- Save the Primary wizard Object --->
					<wiz:processwizardObjects typename="#stobj.typename#" PackageType="rules" />	
						
				</wiz:processwizard>
				
				<wiz:processwizard action="Save" Savewizard="true" Exit="true"><!--- Save wizard Data to Database and remove wizard --->
					<skin:bubble title="Rule Saved" bAutoHide="true" tags="rule,updated,info">
						<cfoutput>The changes you have made to this rule have been saved.</cfoutput>
					</skin:bubble>
				</wiz:processwizard>
				<wiz:processwizard action="Cancel" Removewizard="true" Exit="true"><!--- remove wizard --->
					<skin:bubble title="Changes Cancelled" bAutoHide="true" tags="rule,canceled,info">
						<cfoutput>The changes you made to the rule were cancelled.</cfoutput>
					</skin:bubble>
				</wiz:processwizard>
				
				
				<wiz:wizard ReferenceID="#stobj.objectid#">
				
					<cfloop list="#lWizardSteps#" index="iWizardStep">
							
						<cfquery dbtype="query" name="qwizardStep">
						SELECT *
						FROM qMetadata
						WHERE ftwizardStep = '#iWizardStep#'
						ORDER BY ftSeq
						</cfquery>
					
						<wiz:step name="#iWizardStep#">
							
	
							<cfquery dbtype="query" name="qFieldSets">
							SELECT ftFieldset
							FROM qMetadata
							WHERE ftwizardStep = '#iWizardStep#'
							AND ftFieldset <> '#stobj.typename#'				
							ORDER BY ftSeq
							</cfquery>
							<cfset lFieldSets = "" />
							<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
								<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
							</cfoutput>
							
							
							<cfif listlen(lFieldSets)>
												
								<cfloop list="#lFieldSets#" index="iFieldSet">
							
									<cfquery dbtype="query" name="qFieldset">
									SELECT *
									FROM qMetadata
									WHERE ftwizardStep = '#iWizardStep#' and ftFieldset = '#iFieldSet#'
									ORDER BY ftSeq
									</cfquery>
									
									
									<wiz:object ObjectID="#stObj.ObjectID#" PackageType="rules" lfields="#valuelist(qFieldset.propertyname)#" format="edit" intable="false" legend="#iFieldSet#" />
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
				SELECT ftFieldset
				FROM qMetadata
				WHERE ftFieldset <> '#stobj.typename#'
				ORDER BY ftseq
				</cfquery>
				
				<cfset lFieldSets = "" />
				<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
					<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
				</cfoutput>
			
			
				<!---------------------------------------
				ACTION:
				 - default form processing
				---------------------------------------->
				<ft:processForm action="Save" Exit="true">
					
					<ft:processFormObjects typename="#stobj.typename#" PackageType="rules" />

					<skin:bubble title="Rule Saved" bAutoHide="true" tags="rule,updated,info">
						<cfoutput>The changes you have made to this rule have been saved.</cfoutput>
					</skin:bubble>
					
				</ft:processForm>
				
				<ft:processForm action="Cancel" Exit="true">				
					<skin:bubble title="Changes Cancelled" bAutoHide="true" tags="rule,canceled,info">
						<cfoutput>The changes you made to the rule were cancelled.</cfoutput>
					</skin:bubble>
				</ft:processForm>
				
				
				
				<ft:form>
			
					<cfif listLen(lFieldSets)>
						
						<cfloop list="#lFieldSets#" index="iFieldset">
							
							<cfquery dbtype="query" name="qFieldset">
							SELECT *
							FROM qMetadata
							WHERE ftFieldset = '#iFieldset#'
							ORDER BY ftSeq
							</cfquery>
							
							<ft:object ObjectID="#arguments.ObjectID#" PackageType="rules" format="edit" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" IncludeFieldSet="true" Legend="#iFieldset#" />
						</cfloop>
						
						
					<cfelse>
					
						<!--- default edit handler --->
						<ft:object ObjectID="#arguments.ObjectID#" PackageType="rules" format="edit" lExcludeFields="label" lFields="" IncludeFieldSet="false" />
					</cfif>
					
					<ft:buttonPanel>
						<ft:button value="Save" /> 
						<ft:button value="Cancel" validate="false" />
					</ft:buttonPanel>
					
				</ft:form>
			</cfif>
		
			
		</cfif>
				
	</cffunction> 
	

	<cffunction name="setLock" access="public" output="true" hint="Lock a content item to prevent simultaneous editing." returntype="void">
		<cfargument name="locked" type="boolean" required="true" hint="Turn the lock on or off.">
		<cfargument name="lockedby" type="string" required="false" hint="Name of the user locking the object." default="">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
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
		
		<!--- if the properties struct not passed in grab the instance --->
		<cfif StructIsEmpty(stObject) AND structKeyExists(instance, "stobj")>
			<cfset stObject = instance.stobj />
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
			<cfset setdata(stProperties="#stObject#", user="#arguments.lockedby#", bAudit="#arguments.bAudit#", dsn="#arguments.dsn#", bAfterSave="false", bSessionOnly="#bSessionOnly#")>

		</cfif>

		<!--- log event --->
		<cfif arguments.bAudit and isDefined("instance.stobj.objectid")>
			<farcry:logevent object="#stObject.objectid#" type="types" event="lock" notes="Locked: #yesnoformat(arguments.locked)#" />
		</cfif>
	</cffunction>
		
	
	<cffunction name="execute" access="public" output="true">
		<cfargument name="label" required="no" type="string" default="">
		<cfoutput><!-- #arguments[1]# : RULE IS EMPTY --></cfoutput>
	</cffunction>  
	
	<cffunction name="getRules" access="public" returntype="query" hint="Returns a query of rules for container management.">
		<cfargument name="lRules" type="string" required="false" default="" hint="Specific list of rules to use." />
		<cfargument name="lExcludedRules" type="string" required="false" default="" hint="List of rules to exclude." />
		
		<cfset var qRules = queryNew("rulename, bCustom, displayname, hint, icon") />
		<cfset var rule = "" />
		<cfset var displayname = "" />

		<cfloop collection="#application.rules#" item="rule">
			<cfif (not len(arguments.lRules) or refindnocase("(^|,)#rule#($|,)",arguments.lRules)) and not refindnocase("(^|,)#rule#($|,)",arguments.lExcludedRules)>
				<cfset queryAddRow(qRules, 1) />
				<cfset querySetCell(qRules,"rulename", rule) />
				<cfset querySetCell(qRules,"bCustom", application.rules[rule].bcustomrule) />
				
				<cfif structKeyExists(application.rules[rule],'displayname')>
					<cfset displayname = application.rules[rule].displayname />
				<cfelse>
					<cfset displayname = rule />
				</cfif>
				<cfset querySetCell(qRules,"displayname", displayname) />
				<cfset querySetCell(qRules,"hint", application.fapi.getContentTypeMetadata(rule, "hint", "(No description provided.)")) />
				<cfset querySetCell(qRules,"icon", application.fapi.getContentTypeMetadata(rule, "icon", "fa-wrench")) />
			</cfif>
		</cfloop>	
		
		<cfquery dbtype="query" name="qRules">
		SELECT * FROM qRules
		ORDER BY displayname
		</cfquery>
		
		<cfreturn qRules />		

	</cffunction>
	
	<cffunction name="setData" access="public" output="false" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array." returntype="struct">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#application.security.getCurrentUserID()#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated publishing rule.">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	


		<cfset var stReturn=structNew()>
		<cfset var qHostContent = "" />
		<cfset var stAfterSave = structNew()>

		<cfif NOT structKeyExists(arguments.stProperties, "datetimelastupdated")>
			<cfset arguments.stProperties.datetimelastupdated = createODBCDateTime(now()) />
		</cfif>

		<cfset stReturn=super.setData(stProperties=arguments.stProperties, dsn=arguments.dsn, bSessionOnly=arguments.bSessionOnly) />

		<!--- ONLY RUN THROUGH IF SAVING TO DB --->
		<cfif not arguments.bSessionOnly AND arguments.bAfterSave>
			
			<!--- Flush current page (only possible if originalID is available) --->
			<cfif isdefined("url.originalID")>
				<cfquery datasource="#application.dsn#" name="qHostContent">
					SELECT 	o.objectid,o.typename
					FROM 	refContainers c
							inner join
							refObjects o
							on c.objectid=o.objectid
					WHERE 	c.containerid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#url.originalID#" />
				</cfquery>
				<cfloop query="qHostContent">
					<cfset application.fc.lib.objectbroker.RemoveFromObjectBroker(lObjectIDs=qHostContent.objectid,typename=qHostContent.typename) />
				</cfloop>
			</cfif>
			
	   	 	<cfset stAfterSave = afterSave(argumentCollection=arguments) />
	   	 				
		</cfif>

		
		<!--- log update --->
		<cfif not arguments.bSessionOnly AND arguments.bAudit>
			<farcry:logevent object="#arguments.stProperties.objectid#" type="rules" event="update" notes="#arguments.auditNote#" />
		</cfif>
		
		<cfreturn stReturn />
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
		<cfset var field = "" />

		<cfparam name="arguments.stProperties.label" default="">
		
		
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
			<cfset arguments.stProperties.label = trim(NewLabel) />
		<cfelse>
			<cfset arguments.stProperties.label = arguments.stProperties.label />
		</cfif>
		
		
		<cfset arguments.stProperties.datetimelastupdated = now() />
		
		<cfreturn arguments.stProperties>
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
		
			
</cfcomponent>