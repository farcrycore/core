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

<cfimport taglib="/farcry/farcry_core/tags/wizzard/" prefix="wiz" >
<cfimport taglib="/farcry/farcry_core/tags/security/" prefix="se" >

<cfset stBaseTag = GetBaseTagData("cf_wizzard")>
<cfset stWizzard = stBaseTag.stWizzard>


<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.Name" default="" >
	<cfparam name="attributes.lFields" default="" >
	<cfparam name="attributes.legend" default="" >
	<cfparam name="attributes.RequiredPermissions" default="" ><!--- If the user sends through a list of permissions for this step, only users with correct permissions will be granted access. --->
	
	<cfif len(attributes.RequiredPermissions)>
		<cfset permitted = 1>
		
		<cfloop list="#attributes.RequiredPermissions#" index="i">
			<cfif NOT request.dmsec.oAuthorisation.checkPermission(permissionName="#i#",reference="policyGroup") EQ 1>
				<cfset permitted = 0>
			</cfif>
		</cfloop>	
	
		<cfif permitted NEQ "1">
			<cfexit>
		</cfif>
	</cfif>
	
	<!--- Need to add this step to the list of steps in the Wizzard --->
	<cfset stWizzard.Steps = ListAppend(stWizzard.Steps,attributes.Name) />
	
	<!--- Default the output HTML --->
	<cfparam name="stWizzard.StepHTML" default="">

	<!--- If the current step is not this step, then exit from this step --->
	
	<cfif stWizzard.CurrentStep NEQ ListLen(stWizzard.Steps)>
		<cfexit method="exittag">
	</cfif>

	<cfif len(attributes.lFields)>
		<cfsavecontent variable="stWizzard.StepHTML">
			<wiz:object legend="#attributes.legend#" ObjectID="#stWizzard.PrimaryObjectID#"  typename="#stWizzard.Data[stWizzard.PrimaryObjectID].typename#" lFields="#attributes.lFields#" InTable=0 />
		</cfsavecontent>
	</cfif>	
	
</cfif>

<cfif thistag.executionMode eq "End">
	<cfset stWizzard.StepHTML = stWizzard.StepHTML & thistag.GeneratedContent>
	<cfset thistag.GeneratedContent = "">
	
</cfif>