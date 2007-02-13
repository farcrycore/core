<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_versioning/approveEmail_approved_dd.cfm,v 1.11 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: sends email for approved news type objects $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<!--- get object details --->
<q4:contentobjectget objectID="#arguments.objectID#" r_stObject="stObj">

<!--- get dmProfile object --->
<cfset o_profile = createObject("component", application.types.dmProfile.typePath)>
<cfset stProfile = o_profile.getProfile(userName=stObj.lastupdatedby)>
<cfset emailObj = CreateObject("component","#application.packagepath#.farcry.email")>
	
<!--- send email to lastupdater to let them know object is approved --->
<cfif stProfile.emailAddress neq "" and stProfile.bReceiveEmail>

    <cfif isdefined("session.dmProfile.emailAddress") and session.dmProfile.emailAddress neq "">
        <cfset fromEmail = session.dmProfile.emailAddress>
    <cfelse>
        <cfset fromEmail = stProfile.emailAddress>
    </cfif>

	<cfset stEmail = structNew()>
	<cfset stEmail.toAddress = stProfile.emailAddress>
	<cfset stEmail.fromAddress = fromEmail>
	<cfset stEmail.subject = "#application.config.general.sitetitle# - Object Approved">

	<cfsavecontent variable="stEmail.content"><cfoutput>
Hi <cfif len(stProfile.firstName) gt 0>#stProfile.firstName#<cfelse>#stProfile.userName#</cfif>,

Your object "<cfif isDefined("stObj.title") and len(trim(stObj.title))>#stObj.title#<cfelseif isDefined("stObj.label") and len(trim(stObj.label))>#stObj.label#<cfelse>undefined</cfif>" has been approved.

<cfif arguments.comment neq "">
Comments added on status change:
#arguments.comment#
</cfif>
	</cfoutput></cfsavecontent>

	<cfset returnstruct = emailObj.fSend(stEmail)>
</cfif>

<cfsetting enablecfoutputonly="no">