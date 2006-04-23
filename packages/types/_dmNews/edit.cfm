<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/edit.cfm,v 1.36 2005/10/29 12:21:36 geoff Exp $
$Author: geoff $
$Date: 2005/10/29 12:21:36 $
$Name: milestone_3-0-1 $
$Revision: 1.36 $

|| DESCRIPTION || 
$Description: dmNews Edit Handler $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: url.killplp (optional)$
--->
<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">
<cfparam name="url.killplp" default="0">

<!--- What is this?  Is it the CFMX6.1 compatability hack?? If you know pls comment accordingly. GB20051029 --->
<cfset tempObject = CreateObject("component",application.types.dmnews.typepath)>
<cfset stObj = tempObject.getData(arguments.objectid)>

<!--- determine where the edit handler has been called from to provide the right return url --->
<cfset cancelCompleteURL="#application.url.farcry#/content/dmnews.cfm">

<!--- lock the content item for editing --->
<cfif NOT stobj.locked>
	<cfset setlock(locked="true")>
</cfif>

<widgets:plp 
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="/farcry/farcry_core/packages/types/_dmNews/plpEdit"
	cancelLocation="#cancelCompleteURL#"
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
	<widgets:plpstep name="#application.adminBundle[session.dmProfile.locale].bodyLC#" template="body.cfm">
	<widgets:plpstep name="#application.adminBundle[session.dmProfile.locale].relatedLC#" template="related.cfm">
	<widgets:plpstep name="#application.adminBundle[session.dmProfile.locale].categoriesLC#" template="categories.cfm">
	<widgets:plpstep name="#application.adminBundle[session.dmProfile.locale].completeLC#" template="complete.cfm" bFinishPLP="true">
</widgets:plp> 

<cfif isDefined("bComplete") and bComplete>
	<cfset stoutput.label = stoutput.title>
	<!--- update timestamp as wizard may have been active for some time --->
	<cfset stoutput.datetimelastupdated = now()>
	<!--- remove content item lock --->
	<cfset setlock(locked="false",stObj=stoutput)>
	<!--- update content item --->
	<cfset setData(stProperties=stoutput)>
	<!--- all done in one window so relocate back to main page --->
	<cflocation url="#cancelcompleteURL#" addtoken="no">
</cfif>
<cfsetting enablecfoutputonly="No">
