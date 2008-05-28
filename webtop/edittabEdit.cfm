<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8" />
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
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$DESCRIPTION: edit object invoker for primarily tree based content; on its way out the door 20050728 GB$
$TODO: get rid of this crack edittabEdit.cfm GB$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<!--- check for content type and objectid--->
<cfparam name="url.objectid" type="uuid" />
<cfparam name="url.typename" type="string" />


<cfif NOT len(url.typename)>
	<cfinvoke 
		component="farcry.core.packages.fourq.fourq"
		method="findType" 
		returnvariable="typename"
		objectid="#url.objectid#" />
	<cfset url.typename=typename />
</cfif>

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="ObjectEditTab">
	<nj:edit objectid="#url.objectid#" typename="#url.typename#" cancelCompleteURL="#application.url.farcry#/edittabOverview.cfm?objectid=#url.objectid#" />
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="false" />