<cfsetting enablecfoutputonly="Yes">
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
$Header: /cvs/farcry/core/packages/types/_dmXMLExport/edit.cfm,v 1.9 2005/09/02 05:11:44 guy Exp $
$Author: guy $
$Date: 2005/09/02 05:11:44 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: dmXMLExport Edit Handler $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: url.killplp (optional)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets">

<!--- local variables --->
<cfparam name="url.killplp" default="0">

<!--- lock the content item for editing --->
<cfif NOT stobj.locked>
	<cfset setlock(locked="true")>
</cfif>

<widgets:plp 
	owner="#application.security.getCurrentUserID()#_#stObj.objectID#"
	stepDir="/farcry/core/packages/types/_dmXMLExport/plpEdit"
	cancelLocation="#application.url.farcry#/content/xmlFeedList.cfm"
	iTimeout="15"
	stInput="#stObj#"
	bDebug="0"
	bForceNewInstance="#url.killplp#"
	r_stOutput="stOutput"
	storage="file"
	storagedir="#application.path.plpstorage#"
	redirection="server"
	r_bPLPIsComplete="bComplete">

	<widgets:plpstep name="#application.rb.getResource("start")#" template="start.cfm">
	<widgets:plpstep name="#application.rb.getResource("categoriesLC")#" template="categories.cfm">
	<widgets:plpstep name="#application.rb.getResource("completeLC")#" template="complete.cfm" bFinishPLP="true">
</widgets:plp> 

<cfif isDefined("bComplete") and bComplete>
	<cfset stoutput.label = stoutput.title>
	<!--- update timestamp as wizard may have been active for some time --->
	<cfset stoutput.datetimelastupdated = now()>
	<!--- remove content item lock --->
	<cfset setlock(locked="false")>
	<!--- update content item --->
	<cfset setData(stProperties=stoutput)>
	
	<!--- all done in one window so relocate back to main page --->
	<cflocation url="#application.url.farcry#/content/xmlFeedList.cfm" addtoken="no">
</cfif>
<cfsetting enablecfoutputonly="No">
