<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmEmail/edit.cfm,v 1.8 2005/09/02 05:11:44 guy Exp $
$Author: guy $
$Date: 2005/09/02 05:11:44 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: dmEmail Edit Handler $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out: $
--->
<cfsetting enablecfoutputonly="yes">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">
<!--- <cfimport taglib="/farcry/core/tags/farcry" prefix="farcry"> --->

<cfparam name="url.killplp" default="0">

<widgets:plp 
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="/farcry/core/packages/types/_dmEmail/plpEdit"
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

	<widgets:plpstep name="#application.rb.getResource("start")#" template="start.cfm">
	<widgets:plpstep name="#application.rb.getResource("advancedOptions")#" template="options.cfm">
	<widgets:plpstep name="#application.rb.getResource("bodyLC")#" template="body.cfm">
	<widgets:plpstep name="#application.rb.getResource("htmlBody")#" template="htmlbody.cfm">
	<widgets:plpstep name="#application.rb.getResource("completeLC")#" template="complete.cfm" bFinishPLP="true">
	
</widgets:plp> 

<cfif isDefined("bComplete") and bComplete>
	<!--- unlock object and save object --->
	<cfif structKeyExists(stoutput,'charset') AND not len(stOutput.charset)>
		<cfset stoutput.charset = "UTF-8">
	</cfif>
	<cfset stoutput.label = stoutput.title>
	<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
		<cfinvokeargument name="stObj" value="#stOutput#"/>
		<cfinvokeargument name="objectid" value="#stOutput.objectid#"/>
		<cfinvokeargument name="typename" value="#stOutput.typename#"/>
	</cfinvoke>
	
	<!--- all done in one window so relocate back to main page --->
	<cflocation url="#application.url.farcry#/admin/messageCentre.cfm" addtoken="no">

</cfif>

<cfsetting enablecfoutputonly="no">
