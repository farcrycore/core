<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/approveEmail_pending.cfm,v 1.21 2005/10/06 01:43:18 daniela Exp $
$Author: daniela $
$Date: 2005/10/06 01:43:18 $
$Name: milestone_3-0-1 $
$Revision: 1.21 $

|| DESCRIPTION || 
$Description: sends email for pending object $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/farcry_core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<!--- get object details --->
<q4:contentobjectget objectID="#arguments.objectID#" r_stObject="stObj">

<!--- check if underlying draft --->
<cfif IsDefined("stObj.versionID") and stObj.versionID neq "">
	<cfquery datasource="#application.dsn#" name="qHasDraft">
	SELECT objectID,status 
	FROM #application.dbowner##stObj.typename# 
	WHERE objectid = '#stObj.versionID#' 
	</cfquery>
	<cfset child = qHasDraft.objectid>
<cfelse>
	<cfset child = stobj.objectid>
</cfif>

<!--- get navigation parent --->
<nj:treeGetRelations 
	typename="#stObj.typename#"
	objectId="#child#"
	get="parents"
	r_lObjectIds="ParentID"
	bInclusive="1">
			
<!--- get list of approvers for this object --->
<cfinvoke component="#application.packagepath#.farcry.workflow" method="getObjectApprovers" returnvariable="stApprovers">
	<cfinvokeargument name="objectID" value="#arguments.objectID#"/>
</cfinvoke>

<cfset emailObj = CreateObject("component","#application.packagepath#.farcry.email")>
<cfloop collection="#stApprovers#" item="item">
	<!--- check user had email profile and is in list of approvers --->
	<cfif stApprovers[item].emailAddress neq "" AND stApprovers[item].bReceiveEmail and stApprovers[item].userName neq session.dmSec.authentication.userLogin AND (arguments.lApprovers eq "all" or listFind(arguments.lApprovers,stApprovers[item].userName))>
	    <cfif session.dmProfile.emailAddress neq "">
	        <cfset fromEmail = session.dmProfile.emailAddress>
	    <cfelse>
	        <cfset fromEmail = stApprovers[item].emailAddress>
	    </cfif>
	
		<cfset stEmail = structNew()>
		<cfset stEmail.toAddress = stApprovers[item].emailAddress>
		<cfset stEmail.fromAddress = fromEmail>
		<cfset stEmail.subject = "#application.config.general.sitetitle# - Page Approval Request">
	
		<cfsavecontent variable="stEmail.content"><cfoutput>
Hi <cfif len(stApprovers[item].firstName) gt 0>#stApprovers[item].firstName#<cfelse>#stApprovers[item].userName#</cfif>,

Page "<cfif isDefined("stObj.title") and len(trim(stObj.title))>#stObj.title#<cfelseif isDefined("stObj.label") and len(trim(stObj.label))>#stObj.label#<cfelse>undefined</cfif>" is awaiting your approval

You may approve/decline this page by browsing to the following location:

#application.config.general.adminServer##application.url.farcry#/index.cfm?sec=site&rootObjectID=#ParentID#

	<cfif arguments.comment neq "">
Comments added on status change:
#arguments.comment#
	</cfif>
		</cfoutput></cfsavecontent>

		<!--- send email alerting them to object is waiting approval  --->
		<cfset returnstruct = emailObj.fSend(stEmail)>
  </cfif>
</cfloop>

<cfsetting enablecfoutputonly="no">