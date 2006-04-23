<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmXMLExport/edit.cfm,v 1.6 2004/07/26 07:48:40 phastings Exp $
$Author: phastings $
$Date: 2004/07/26 07:48:40 $
$Name: milestone_2-3-2 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: dmXMLExport Edit Handler $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: url.killplp (optional)$
--->
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="farcry">
<cfparam name="url.killplp" default="0">

<cfoutput>
<farcry:plp 
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="/farcry/farcry_core/packages/types/_dmXMLExport/plpEdit"
	cancelLocation="#application.url.farcry#/dynamic/xmlFeedList.cfm"
	iTimeout="15"
	stInput="#stObj#"
	bDebug="0"
	bForceNewInstance="#url.killplp#"
	r_stOutput="stOutput"
	storage="file"
	storagedir="#application.path.plpstorage#"
	redirection="server"
	r_bPLPIsComplete="bComplete">

	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].start#" template="start.cfm">
	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].categoriesLC#" template="categories.cfm">
	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].completeLC#" template="complete.cfm" bFinishPLP="true">
</farcry:plp> 
</cfoutput>

<cfif isDefined("bComplete") and bComplete>

	<!--- unlock object and save object --->
	<cfset stoutput.label = stoutput.title>
	<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
		<cfinvokeargument name="stObj" value="#stOutput#"/>
		<cfinvokeargument name="objectid" value="#stOutput.objectid#"/>
		<cfinvokeargument name="typename" value="#stOutput.typename#"/>
	</cfinvoke>
	
	<!--- all done in one window so relocate back to main page --->
	<cflocation url="#application.url.farcry#/dynamic/xmlFeedList.cfm" addtoken="no">
</cfif>
<cfsetting enablecfoutputonly="No">
