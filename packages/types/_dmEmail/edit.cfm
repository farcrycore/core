<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/edit.cfm,v 1.2 2003/08/28 01:44:34 paul Exp $
$Author: paul $
$Date: 2003/08/28 01:44:34 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmEmail Edit Handler $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out: $
--->
<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="farcry">

<cfparam name="url.killplp" default="0">

<farcry:plp 
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="/farcry/farcry_core/packages/types/_dmEmail/plpEdit"
	cancelLocation="#application.url.farcry#/admin/messageCentre.cfm"
	iTimeout="15"
	stInput="#stObj#"
	bDebug="0"
	bForceNewInstance="#url.killplp#"
	r_stOutput="stOutput"
	storage="file"
	storagedir="#application.path.plpstorage#"
	redirection="server"
	r_bPLPIsComplete="bComplete">

	<farcry:plpstep name="start" template="start.cfm">
	<farcry:plpstep name="advanced options" template="options.cfm">
	<farcry:plpstep name="body" template="body.cfm">
	<farcry:plpstep name="html body" template="htmlbody.cfm">
	<farcry:plpstep name="complete" template="complete.cfm" bFinishPLP="true">
	
</farcry:plp> 

<cfif isDefined("bComplete") and bComplete>
	<!--- unlock object and save object --->
	<cfif structKeyExists(stoutput,'charset') AND not len(stOutput.charset)>
		<cfset stoutput.charset = "UTF-8">
	</cfif>
	<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
		<cfinvokeargument name="stObj" value="#stOutput#"/>
		<cfinvokeargument name="objectid" value="#stOutput.objectid#"/>
		<cfinvokeargument name="typename" value="#stOutput.typename#"/>
	</cfinvoke>
	
	<!--- all done in one window so relocate back to main page --->
	<cflocation url="#application.url.farcry#/admin/messageCentre.cfm" addtoken="no">

</cfif>

<cfsetting enablecfoutputonly="no">
