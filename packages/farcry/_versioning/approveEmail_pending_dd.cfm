<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/approveEmail_pending_dd.cfm,v 1.20.2.1 2006/02/24 00:33:12 paul Exp $
$Author: paul $
$Date: 2006/02/24 00:33:12 $
$Name: milestone_3-0-1 $
$Revision: 1.20.2.1 $

|| DESCRIPTION || 
$Description: sends email for pending news type object $


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

<cfset emailObj = CreateObject("component","#application.packagepath#.farcry.email")>


<cfloop collection="#stApprovers#" item="user">
    <!--- check user had email profile and is in list of approvers --->
    <cfif stApprovers[user].emailAddress neq "" AND stApprovers[user].bReceiveEmail and stApprovers[user].userName neq session.dmSec.authentication.userLogin AND (arguments.lApprovers eq "all" or listFind(arguments.lApprovers,stApprovers[user].userName))>

	    <cfif isdefined("session.dmProfile.emailAddress") and session.dmProfile.emailAddress neq "">
	        <cfset fromEmail = session.dmProfile.emailAddress>
	    <cfelse>
	        <cfset fromEmail = stApprovers[user].emailAddress>
	    </cfif>
		<cfset stEmail = structNew()>
		<cfset stEmail.toAddress = stApprovers[user].emailAddress>
		<cfset stEmail.fromAddress = fromEmail>
		<cfset stEmail.subject = "#application.config.general.sitetitle# - Object Approval Request">

		<cfsavecontent variable="stEmail.content"><cfoutput>
Hi <cfif len(stApprovers[user].firstName) gt 0>#stApprovers[user].firstName#<cfelse>#stApprovers[user].userName#</cfif>,

The item "<cfif isDefined("stObj.title") and len(trim(stObj.title))>#stObj.title#<cfelseif isDefined("stObj.label") and len(trim(stObj.label))>#stObj.label#<cfelse>undefined</cfif>" <cfif structKeyExists(application.types[stObj.typename],"displayname")>(#application.types[stObj.typename].displayname#)</cfif> is awaiting your approval.

You may approve/decline this object by browsing to farcry and viewing this item in your pending approval list on the farcry overview page.

		<cfif isDefined("arguments.approveURL")>
#urldecode(arguments.approveURL)#&objectID=#arguments.objectID#&status=pending<cfelse>
#application.config.general.adminServer##application.url.farcry#/index.cfm</cfif>

		<cfif arguments.comment neq "">
Comments added on status change:
#arguments.comment#</cfif>
		</cfoutput></cfsavecontent>
		
		<cfset returnstruct = emailObj.fSend(stEmail)>
    </cfif>
</cfloop>

<cfsetting enablecfoutputonly="no">