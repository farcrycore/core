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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
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
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

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

<cfif len(stProfile.firstName)>
	<cfset name = stProfile.firstName />
<cfelse>
	<cfset name = stProfile.userName />
</cfif>
<cfif isDefined("stObj.title") and len(trim(stObj.title))>
	<cfset title = stObj.title />
<cfelseif isDefined("stObj.label") and len(trim(stObj.label))>
	<cfset title = stObj.label />
<cfelse>
	<cfset title = "undefined" />
</cfif>
<cfif isDefined("arguments.approveURL")>
	<cfset link = "#application.fc.lib.esapi.DecodeFromURL(arguments.approveURL)#&objectID=#arguments.objectID#&status=draft" />
<cfelse>
	<cfset link = "#application.config.general.adminServer##application.url.farcry#/index.cfm?section=dynamic&objectID=#arguments.objectID#&status=draft" />
</cfif>
<cfmail to="#stProfile.emailAddress#" from="#fromEmail#" subject="#application.fapi.getResource('workflow.email.senttodraft@subject','{1} - Object sent back to Draft',application.config.general.sitetitle)#"><admin:resource key="workflow.email.senttodraft@html" var1="#name#" var2="#title#" var3="#arguments.comment#" var4="#link#">
Hi {1},

Your object "{2}" has been sent back to draft.

Comments added on status change:
{3}

You may edit this page by browsing to the following location:
{4}

</admin:resource></cfmail>

</cfif>

<cfsetting enablecfoutputonly="no">