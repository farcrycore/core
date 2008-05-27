<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_versioning/approveEmail_draft_dd.cfm,v 1.19 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.19 $

|| DESCRIPTION || 
$Description: sends email for draft news like object $


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
<cfscript>
o_profile = createObject("component", application.types.dmProfile.typePath);
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

Your object "<cfif isDefined("stObj.title") and len(trim(stObj.title))>#stObj.title#<cfelseif isDefined("stObj.label") and len(trim(stObj.label))>#stObj.label#<cfelse>undefined</cfif>" has been sent back to draft.

<cfif arguments.comment neq "">
Comments added on status change:
#arguments.comment#
</cfif>

You may edit this page by browsing to the following location:

<cfif isDefined("arguments.approveURL")>
#urldecode(arguments.approveURL)#&objectID=#arguments.objectID#&status=draft
<cfelse>	
#application.config.general.adminServer##application.url.farcry#/index.cfm?section=dynamic&objectID=#arguments.objectID#&status=draft
</cfif>

</cfmail>

</cfif>

<cfsetting enablecfoutputonly="no">