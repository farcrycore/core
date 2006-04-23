<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/approveEmail_draft_dd.cfm,v 1.9 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: sends email for draft news like object $
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

<!--- get dmProfile object --->
<cfscript>
o_profile = createObject("component", "#application.packagepath#.types.dmProfile");
stProfile = o_profile.getProfile(userName=stObj.lastupdatedby);
</cfscript>

<!--- send email to lastupdater to let them know object is sent back to draft --->
<cfif stProfile.emailAddress neq "" AND stProfile.bReceiveEmail>

    <cfif isdefined("session.dmProfile.emailAddress") and session.dmProfile.emailAddress neq "">
        <cfset fromEmail = session.dmProfile.emailAddress>
    <cfelse>
        <cfset fromEmail = stProfile.emailAddress>
    </cfif>

<cfmail to="#stProfile.emailAddress#" from="#fromEmail#" subject="#application.config.general.sitetitle# - Object sent back to Draft">
Hi <cfif len(stProfile.firstName) gt 0>#stProfile.firstName#<cfelse>#stProfile.userName#</cfif>,

Your object "<cfif stObj.title neq "">#stObj.title#<cfelse>undefined</cfif>" has been sent back to draft.

<cfif arguments.comment neq "">
Comments added on status change:
#arguments.comment#
</cfif>

You may edit this page by browsing to the following location:

http://#CGI.HTTP_HOST##application.url.farcry#/index.cfm?section=dynamic&objectID=#arguments.objectID#&status=draft

</cfmail>

</cfif>

<cfsetting enablecfoutputonly="no">