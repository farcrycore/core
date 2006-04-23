<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/edit.cfm,v 1.23 2004/07/30 01:05:03 brendan Exp $
$Author: brendan $
$Date: 2004/07/30 01:05:03 $
$Name: milestone_2-3-2 $
$Revision: 1.23 $

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
	storagedir="#application.path.plpstorage#"
	redirection="server"
	r_bPLPIsComplete="bComplete">

	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].start#" template="start.cfm">
	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].filesLC#" template="files.cfm">
	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].imagesLC#" template="images.cfm">
	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].teaserLC#" template="teaser.cfm">
	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].bodyLC#" template="body.cfm">
	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].relatedLC#" template="related.cfm">
	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].categoriesLC#" template="metadata.cfm">
	<farcry:plpstep name="#application.adminBundle[session.dmProfile.locale].completeLC#" template="complete.cfm" bFinishPLP="true">
</farcry:plp>
</cfoutput>

<cfif isDefined("bComplete") and bComplete>

	<!--- unlock object --->
	<cfset stoutput.label = stoutput.title>
	<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
		<cfinvokeargument name="stObj" value="#stOutput#"/>
		<cfinvokeargument name="objectid" value="#stOutput.objectid#"/>
		<cfinvokeargument name="typename" value="#stOutput.typename#"/>
	</cfinvoke>
	
	<!--- check if object is a underlying draft page --->
	<cfscript>
		oAuthentication = request.dmSec.oAuthentication;	
		stuser = oAuthentication.getUserAuthenticationData();
		if (len(trim(stOutput.versionId)))
		{
			objId = stOutput.versionId;
			auditNote = 'Draft object update';
			
		}
		else
		{
			objId = stOutput.objectId;
			auditNote = 'update';
		}
		application.factory.oAudit.logActivity(auditType="Update", username=stUser.userlogin, location=cgi.remote_host, note=auditNote,objectid=objID);
	</cfscript>	
	
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