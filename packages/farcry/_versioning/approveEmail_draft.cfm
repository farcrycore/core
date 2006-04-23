<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/approveEmail_draft.cfm,v 1.15 2004/01/14 21:03:51 brendan Exp $
$Author: brendan $
$Date: 2004/01/14 21:03:51 $
$Name: milestone_2-1-2 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: sends email for draft object $
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

<!--- get navigation parent --->
<nj:treeGetRelations 
	typename="#stObj.typename#"
	objectId="#stObj.objectid#"
	get="parents"
	r_lObjectIds="ParentID"
	bInclusive="1">

<!--- get dmProfile object --->
<cfscript>
o_profile = createObject("component", application.types.dmProfile.typePath);
stProfile = o_profile.getProfile(userName=stObj.lastupdatedby);
</cfscript>

<!--- send email to lastupdater to let them know object is sent back to draft --->
<cfif stProfile.emailAddress neq "" AND stProfile.bReceiveEmail>

    <cfif session.dmProfile.emailAddress neq "">
        <cfset fromEmail = session.dmProfile.emailAddress>
    <cfelse>
        <cfset fromEmail = stProfile.emailAddress>
    </cfif>

<cfmail to="#stProfile.emailAddress#" from="#fromEmail#" subject="#application.config.general.sitetitle# - Page sent back to Draft">
Hi <cfif len(stProfile.firstName) gt 0>#stProfile.firstName#<cfelse>#stProfile.userName#</cfif>,

Your page "<cfif stObj.title neq "">#stObj.title#<cfelse>undefined</cfif>" has been sent back to draft.

<cfif arguments.comment neq "">
Comments added on status change:
#arguments.comment#
</cfif>

You may edit this page by browsing to the following location:

#application.config.general.adminServer##application.url.farcry#/index.cfm?section=site&rootObjectID=#ParentID#

</cfmail>

</cfif>

<cfsetting enablecfoutputonly="no">