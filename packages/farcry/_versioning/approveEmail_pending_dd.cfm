<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/approveEmail_pending_dd.cfm,v 1.17 2004/01/15 07:11:50 paul Exp $
$Author: paul $
$Date: 2004/01/15 07:11:50 $
$Name: milestone_2-1-2 $
$Revision: 1.17 $

|| DESCRIPTION || 
$Description: sends email for pending news type object $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<!--- get object details --->
<q4:contentobjectget objectID="#arguments.objectID#" r_stObject="stObj">

<!--- get list of approvers for this object --->
<cfinvoke component="#application.packagepath#.farcry.workflow" method="getNewsApprovers" returnvariable="stApprovers">
	<cfinvokeargument name="objectID" value="#arguments.objectID#" />
</cfinvoke>

<cfloop collection="#stApprovers#" item="user">
    <!--- check user had email profile and is in list of approvers --->
    <cfif stApprovers[user].emailAddress neq "" AND stApprovers[user].bReceiveEmail and stApprovers[user].userName neq session.dmSec.authentication.userLogin AND (arguments.lApprovers eq "all" or listFind(arguments.lApprovers,stApprovers[user].userName))>

    <cfif isdefined("session.dmProfile.emailAddress") and session.dmProfile.emailAddress neq "">
        <cfset fromEmail = session.dmProfile.emailAddress>
    <cfelse>
        <cfset fromEmail = stApprovers[user].emailAddress>
    </cfif>

<!--- send email alerting them to object is waiting approval  --->
<cfmail to="#stApprovers[user].emailAddress#" from="#fromEmail#" subject="#application.config.general.sitetitle# - Object Approval Request">
Hi <cfif len(stApprovers[user].firstName) gt 0>#stApprovers[user].firstName#<cfelse>#stApprovers[user].userName#</cfif>,

Object "<cfif stObj.title neq "">#stObj.title#<cfelse>undefined</cfif>" is awaiting your approval.

You may approve/decline this object by browsing to the following location:

<cfif isDefined("arguments.approveURL")>

#urldecode(arguments.approveURL)#&objectID=#arguments.objectID#&status=pending

<cfelse>	
#application.config.general.adminServer##application.url.farcry#/index.cfm?section=dynamic&objectID=#arguments.objectID#&status=pending
</cfif>

<cfif arguments.comment neq "">
Comments added on status change:
#arguments.comment#
</cfif>

</cfmail>

    </cfif>
</cfloop>

<cfsetting enablecfoutputonly="no">