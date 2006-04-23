<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmXMLExport/edit.cfm,v 1.9 2005/09/02 05:11:44 guy Exp $
$Author: guy $
$Date: 2005/09/02 05:11:44 $
$Name: milestone_3-0-0 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: dmXMLExport Edit Handler $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: url.killplp (optional)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

<!--- local variables --->
<cfparam name="url.killplp" default="0">

<!--- lock the content item for editing --->
<cfif NOT stobj.locked>
	<cfset setlock(locked="true")>
</cfif>

<widgets:plp 
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="/farcry/farcry_core/packages/types/_dmXMLExport/plpEdit"
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

	<widgets:plpstep name="#application.adminBundle[session.dmProfile.locale].start#" template="start.cfm">
	<widgets:plpstep name="#application.adminBundle[session.dmProfile.locale].categoriesLC#" template="categories.cfm">
	<widgets:plpstep name="#application.adminBundle[session.dmProfile.locale].completeLC#" template="complete.cfm" bFinishPLP="true">
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
