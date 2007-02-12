<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2004, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/rules.cfc,v 1.15 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: Abstract Rules Class $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayname="Rules Object" bAbstract="true" extends="farcry.farcry_core.fourq.fourq" hint="Rules is an abstract class that contains">
	<cfproperty name="objectID" type="uuid" required="true" />
	<cfproperty name="label" type="nstring" default="">
	
	
	<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft">	
	<cfimport taglib="/farcry/farcry_core/tags/wizzard/" prefix="wiz">	
	
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfscript>
			var stNewObject = "";
			if(NOT structKeyExists(arguments.stProperties,"objectid"))
				arguments.stProperties.objectid = createUUID();
			stNewObject = super.createData(arguments.stProperties);
			application.factory.oAudit.logActivity(auditType="Create", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=stNewObject.objectid);
		</cfscript>
		<cfreturn stNewObject>
	</cffunction>
	
		
	<cffunction name="delete" access="public" hint="Basic delete method for all objects.">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Deleted">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		
		<cfscript>
			 super.deleteData(arguments.objectid,arguments.dsn);
			 application.factory.oAudit.logActivity(auditType="Delete", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.objectid);
		</cfscript>

	</cffunction>	
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">

		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		
		<cfset var qMetadata = application.rules[stobj.typename].qMetadata >
		
		
		<!--- IF THE ONLY PROPS ARE OBJECTID and LABEL, then let the user know that we have nothing to edit here. --->
		<cfif listLen(structKeyList(application.rules[stobj.typename].stProps)) LTE 2>
			<cfoutput><h3>No Parameters required</h3></cfoutput>
		</cfif>
		<cfif isDefined("url.saved")>
			<cfset request.inhead.scriptaculousEffects = true />
			<cfoutput>
				<h3 id="ruleSaveMessage">Rule has been saved</h3>
				<script type="text/javascript">
				new Effect.Highlight($('ruleSaveMessage'), {startcolor:'##E17000',duration:3})
				</script>
			</cfoutput>
		</cfif>
		
		<cfset onExit = StructNew() />		
		<cfset onExit.Type = "URL" />
		<cfset onExit.Content = "#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#&saved=1" />
		
		
		
		<cfquery dbtype="query" name="qWizzardSteps">
		SELECT ftWizzardStep
		FROM qMetadata
		WHERE ftWizzardStep <> '#stobj.typename#'
		Group By ftWizzardStep
		ORDER BY ftSeq
		</cfquery>
		
		<!------------------------ 
		Work out if we are creating a wizzard or just a simple form.
		If there are multiple wizzard steps then we will be creating a wizzard
		 ------------------------>
		<cfif qWizzardSteps.recordcount GT 1>
			
			<!--- Always save wizzard WDDX data --->
			<wiz:processWizzard>
			
				<!--- Save the Primary Wizzard Object --->
				<wiz:processWizzardObjects typename="#stobj.typename#" PackageType="rules" />	
					
			</wiz:processWizzard>
			
			<wiz:processWizzard action="Save" SaveWizzard="true" Exit="true" /><!--- Save Wizzard Data to Database and remove Wizzard --->
			<wiz:processWizzard action="Cancel" RemoveWizzard="true" Exit="true" /><!--- remove Wizzard --->
			
			
			<wiz:wizzard ReferenceID="#stobj.objectid#">
			
				<cfloop query="qWizzardSteps">
						
					<cfquery dbtype="query" name="qWizzardStep">
					SELECT *
					FROM qMetadata
					WHERE ftWizzardStep = '#qWizzardSteps.ftWizzardStep#'
					ORDER BY ftSeq
					</cfquery>
				
					<wiz:step name="#qWizzardSteps.ftWizzardStep#">
						

						<cfquery dbtype="query" name="qFieldSets">
						SELECT ftWizzardStep, ftFieldset
						FROM qMetadata
						WHERE ftWizzardStep = '#qWizzardSteps.ftWizzardStep#'
						AND ftFieldset <> '#stobj.typename#'
						Group By ftWizzardStep, ftFieldset
						ORDER BY ftSeq
						</cfquery>
											
						<cfloop query="qFieldSets">
						
							<cfquery dbtype="query" name="qFieldset">
							SELECT *
							FROM qMetadata
							WHERE ftFieldset = '#qFieldsets.ftFieldset#'
							ORDER BY ftSeq
							</cfquery>
							
							
							<wiz:object ObjectID="#stObj.ObjectID#" PackageType="rules" lfields="#valuelist(qFieldset.propertyname)#" format="edit" intable="false" legend="#qFieldset.ftFieldset#" />
						</cfloop>
						
						
					</wiz:step>
				
				</cfloop>
				
			</wiz:wizzard>	
				
				
				
				
		<!------------------------ 
		If there is only 1 wizzard step (typename by default) then we will be creating a simple form
		 ------------------------>		 
		<cfelse>
		
			<cfquery dbtype="query" name="qFieldSets">
			SELECT ftWizzardStep, ftFieldset
			FROM qMetadata
			WHERE ftFieldset <> '#stobj.typename#'
			Group By ftWizzardStep, ftFieldset
			ORDER BY ftSeq
			</cfquery>
		
		
			<!---------------------------------------
			ACTION:
			 - default form processing
			---------------------------------------->
			<ft:processForm action="Save" Exit="true">
				<ft:processFormObjects typename="#stobj.typename#" PackageType="rules" />
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
						
						<ft:object ObjectID="#arguments.ObjectID#" PackageType="rules" format="edit" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" inTable=false IncludeFieldSet=1 Legend="#qFieldSets.ftFieldset#" />
					</cfloop>
					
					
				<cfelse>
				
					<!--- default edit handler --->
					<ft:object ObjectID="#arguments.ObjectID#" PackageType="rules" format="edit" lExcludeFields="label" lFields="" inTable=false IncludeFieldSet=1 Legend="#stObj.Label#" />
				</cfif>
				
				
				<cfoutput>
				<div class="fieldwrap">
					<ft:farcryButton value="Save" /> 
					<ft:farcryButton value="Cancel" />
				</div>
				</cfoutput>
		
			</ft:form>
		</cfif>
		
				
	</cffunction> 
	
	<cffunction access="public" name="execute" output="true">
		<cfargument name="label" required="no" type="string" default="">
		<cfoutput><p>#arguments[1]# : No execute method specified</cfoutput>
	</cffunction>  
	
	<cffunction access="public" name="getRules" returntype="query" hint="Returns a two column query (rulename, bCustom) of available rules. Assumes that rule names are rule*.cfc">
		
		<cfset var qRules = queryNew("rulename,bCustom,displayname") />
		<cfset var rule = "" />
		<cfset var displayname = "" />

		<cfloop collection="#application.rules#" item="rule">
			<cfset queryAddRow(qRules, 1) />
			<cfset querySetCell(qRules,"rulename", rule) />
			<cfset querySetCell(qRules,"bCustom", application.rules[rule].bcustomrule) />
			
			<cfif structKeyExists(application.rules[rule],'displayname')>
				<cfset displayname = application.rules[rule].displayname />
			<cfelse>
				<cfset displayname = rule />
			</cfif>
			<cfset querySetCell(qRules,"displayname", displayname) />
		</cfloop>	
		
		<cfquery dbtype="query" name="qRules">
		SELECT * FROM qRules
		ORDER BY displayname
		</cfquery>
		
		<cfreturn qRules />		

	</cffunction>
	
	<cffunction name="setData" access="public" output="false" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array." returntype="struct">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated publishing rule.">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		
		
		<cfset var stReturn=structNew()>
					    
		<cfset stReturn=super.setData(stProperties=arguments.stProperties, dsn=arguments.dsn, bSessionOnly=arguments.bSessionOnly) />
		<!--- log update --->
		<cfif arguments.bAudit>
			<cfset application.factory.oAudit.logActivity(auditType="Update", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.stProperties.objectid,dsn=arguments.dsn)>	
		</cfif>
		<cfreturn stReturn>
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
	
</cfcomponent>