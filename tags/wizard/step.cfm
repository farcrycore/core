<!--- 
|| LEGAL ||
$Copyright: Daemon 2002-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid -- $
--->

<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz" >
<cfimport taglib="/farcry/core/tags/security/" prefix="se" >

<cfset stBaseTag = GetBaseTagData("cf_wizard")>
<cfset stwizard = stBaseTag.stwizard>


<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.Name" default="" >
	<cfparam name="attributes.lFields" default="" >
	<cfparam name="attributes.legend" default="" >
	<cfparam name="attributes.autoGetFields" default="0" >
	<cfparam name="attributes.RequiredPermissions" default="" ><!--- If the user sends through a list of permissions for this step, only users with correct permissions will be granted access. --->

	<cfif attributes.lFields eq "" and attributes.autoGetFields>
		<cfset baseType = stwizard.data[stwizard.primaryObjectID].TYPENAME>
		<cfset myQ = application.stcoapi["#baseType#"].qMetadata>
		<cfquery dbtype="query" name="qFields">
			select * from myQ
			where FTWIZARDSTEP = '#attributes.Name#'
			order by ftseq
		</cfquery>
		<cfset attributes.lFields=valueList(qFields.PROPERTYNAME)>
	</cfif>
	
	<cfif len(attributes.RequiredPermissions)>
		<cfset permitted = 1>
		
		<cfloop list="#attributes.RequiredPermissions#" index="i">
			<cfif NOT application.security.checkPermission(permission=i) EQ 1>
				<cfset permitted = 0>
			</cfif>
		</cfloop>	
	
		<cfif permitted NEQ "1">
			<cfexit>
		</cfif>
	</cfif>
	
	<!--- Need to add this step to the list of steps in the wizard --->
	<cfset stwizard.Steps = ListAppend(stwizard.Steps,attributes.Name) />
	
	<!--- Default the output HTML --->
	<cfparam name="stwizard.StepHTML" default="">

	<!--- If the current step is not this step, then exit from this step --->
	
	<cfif stwizard.CurrentStep NEQ ListLen(stwizard.Steps)>
		<cfexit method="exittag">
	</cfif>

	<cfif len(attributes.lFields)>
		<cfsavecontent variable="stwizard.StepHTML">
			<cfif isDefined("qFields")>
				<cfquery dbtype="query" name="qFieldSets">
				SELECT ftwizardStep, ftFieldset
				FROM qFields
				WHERE ftFieldset <> '#baseType#'
				Group By ftwizardStep, ftFieldset
				ORDER BY ftSeq
				</cfquery>
				
				<cfif qFieldSets.recordCount>
									
					<cfloop query="qFieldSets">
					
						<cfquery dbtype="query" name="qFieldset">
						SELECT *
						FROM qFields
						WHERE ftFieldset = '#qFieldsets.ftFieldset#'
						ORDER BY ftSeq
						</cfquery>
						
						<wiz:object ObjectID="#stwizard.PrimaryObjectID#" lfields="#valuelist(qFieldset.propertyname)#" format="edit" intable="false" legend="#qFieldset.ftFieldset#" helptitle="#qFieldset.fthelptitle#" helpsection="#qFieldset.fthelpsection#" />
					</cfloop>
				<cfelse>
					
					<wiz:object ObjectID="#stwizard.PrimaryObjectID#" lfields="#valuelist(qwizardStep.propertyname)#" format="edit" intable="false" />
				
				</cfif>
		
			<cfelse>
				<wiz:object legend="#attributes.legend#" ObjectID="#stwizard.PrimaryObjectID#"  typename="#stwizard.Data[stwizard.PrimaryObjectID].typename#" lFields="#attributes.lFields#" InTable=0 />
			</cfif>

		</cfsavecontent>
	</cfif>	
	
</cfif>

<cfif thistag.executionMode eq "End">
	<cfset stwizard.StepHTML = stwizard.StepHTML & thistag.GeneratedContent>
	<cfset thistag.GeneratedContent = "">
	
</cfif>