<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/edit.cfm,v 1.15 2003/07/15 07:04:15 brendan Exp $
$Author: brendan $
$Date: 2003/07/15 07:04:15 $
$Name: b131 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: dmHTML Edit Handler $
$TODO: remove cfoutputs from plp tags and make sure the steps are correctly defined with appropriate cfsettings 20030503 GB $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: url.killplp (optional)$
--->
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="farcry">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfparam name="url.killplp" default="0">

<cfoutput>
<farcry:plp 
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="/farcry/farcry_core/packages/types/_dmhtml/plpEdit"
	cancelLocation="#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.objectid#"
	iTimeout="15"
	stInput="#stObj#"
	bDebug="0"
	bForceNewInstance="#url.killplp#"
	r_stOutput="stOutput"
	storage="file"
	storagedir="#application.fourq.plpstorage#"
	redirection="server"
	r_bPLPIsComplete="bComplete">

	<farcry:plpstep name="start" template="start.cfm">
	<farcry:plpstep name="files" template="files.cfm">
	<farcry:plpstep name="images" template="images.cfm">
	<farcry:plpstep name="teaser" template="teaser.cfm">
	<farcry:plpstep name="body" template="body.cfm">
	<farcry:plpstep name="related" template="related.cfm">
	<farcry:plpstep name="complete" template="complete.cfm" bFinishPLP="true">
</farcry:plp>
</cfoutput>

<cfif isDefined("bComplete") and bComplete>

	<!--- unlock object --->
	<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
		<cfinvokeargument name="stObj" value="#stOutput#"/>
		<cfinvokeargument name="objectid" value="#stOutput.objectid#"/>
		<cfinvokeargument name="typename" value="#stOutput.typename#"/>
	</cfinvoke>
	
	<!--- check if object is a underlying draft page --->
	<cfif len(trim(stOutput.versionId))>
		<cfset objId = stOutput.versionId>
	<cfelse>
		<cfset objId = stOutput.objectId>
	</cfif>
	
	<!--- get parent to update tree --->
	<nj:treeGetRelations 
			typename="#stOutput.typename#"
			objectId="#objId#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
	
	<!--- reload overview page --->
	<cfoutput>
		<script language="JavaScript">
			parent['editFrame'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#objId#';
		</script>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="no">