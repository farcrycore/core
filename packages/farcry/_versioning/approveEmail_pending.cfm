<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/approveEmail_pending.cfm,v 1.17 2004/01/14 21:03:51 brendan Exp $
$Author: brendan $
$Date: 2004/01/14 21:03:51 $
$Name: milestone_2-1-2 $
$Revision: 1.17 $

|| DESCRIPTION || 
$Description: sends email for pending object $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
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

<cfloop collection="#stApprovers#" item="item">
<!--- check user had email profile and is in list of approvers --->
<cfif stApprovers[item].emailAddress neq "" AND stApprovers[item].bReceiveEmail and stApprovers[item].userName neq session.dmSec.authentication.userLogin AND (arguments.lApprovers eq "all" or listFind(arguments.lApprovers,stApprovers[item].userName))>
    <cfif session.dmProfile.emailAddress neq "">
        <cfset fromEmail = session.dmProfile.emailAddress>
    <cfelse>
        <cfset fromEmail = stApprovers[item].emailAddress>
    </cfif>

<!--- send email alerting them to object is waiting approval  --->
<cfmail to="#stApprovers[item].emailAddress#" from="#fromEmail#" subject="#application.config.general.sitetitle# - Page Approval Request">
Hi <cfif len(stApprovers[item].firstName) gt 0>#stApprovers[item].firstName#<cfelse>#stApprovers[item].userName#</cfif>,

Page "<cfif stObj.title neq "">#stObj.title#<cfelse>undefined</cfif>" is awaiting your approval.

You may approve/decline this page by browsing to the following location:

#application.config.general.adminServer##application.url.farcry#/index.cfm?section=site&rootObjectID=#ParentID#

<cfif arguments.comment neq "">
Comments added on status change:
#arguments.comment#
</cfif>

</cfmail>

   </cfif>
</cfloop>

<cfsetting enablecfoutputonly="no">