<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEvent/edit.cfm,v 1.5 2003/09/17 06:55:15 paul Exp $
$Author: paul $
$Date: 2003/09/17 06:55:15 $
$Name: b201 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: dmNews Edit Handler $
$TODO: remove cfoutputs from plp tags and make sure the steps are correctly defined with appropriate cfsettings 20030503 GB $

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
	stepDir="/farcry/farcry_core/packages/types/_dmEvent/plpEdit"
	cancelLocation="#application.url.farcry#/navajo/GenericAdmin.cfm?typename=#stObj.typename#"
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
	<farcry:plpstep name="files" template="files.cfm">
	<farcry:plpstep name="images" template="images.cfm">
	<farcry:plpstep name="teaser" template="teaser.cfm">
	<farcry:plpstep name="body" template="body.cfm">
	<farcry:plpstep name="categories" template="metadata.cfm">
	<farcry:plpstep name="complete" template="complete.cfm" bFinishPLP="true">
</farcry:plp> 


<cfparam name="request.stPLP.currentStep" default="">
<cfif request.stPLP.currentStep IS 'body'>
	<script>
		parent.frames['treeFrame'].location.href='#application.url.farcry#/navajo/overview_frame.cfm?rootobjectid=#application.navid.fileroot#&insertonly=1';
		em = parent.document.getElementById('subTabArea');
		for (var i = 0;i < em.childNodes.length;i++)
		{
			parent.document.getElementById(em.childNodes[i].id).style.display = 'none';	
		}
		parent.document.getElementById('DynamicFileTab').style.display ='inline';
		parent.document.getElementById('DynamicImageTab').style.display ='inline';
	</script>

<cfelse>
	<script>
		parent.frames['treeFrame'].location.href='#application.url.farcry#/dynamic/dynamicMenuFrame.cfm?type=general';
		em = parent.document.getElementById('subTabArea');
		for (var i = 0;i < em.childNodes.length;i++)
		{
			parent.document.getElementById(em.childNodes[i].id).style.display = 'inline';	
		}
		parent.document.getElementById('DynamicFileTab').style.display ='none';
		parent.document.getElementById('DynamicImageTab').style.display ='none';
	</script>

</cfif>

</cfoutput>

<cfif isDefined("bComplete") and bComplete>
	<!--- unlock object and save object --->
	<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
		<cfinvokeargument name="stObj" value="#stOutput#"/>
		<cfinvokeargument name="objectid" value="#stOutput.objectid#"/>
		<cfinvokeargument name="typename" value="#stOutput.typename#"/>
	</cfinvoke>
	
	<!--- all done in one window so relocate back to main page --->
	<cflocation url="#application.url.farcry#/navajo/GenericAdmin.cfm?#CGI.QUERY_STRING#&typename=#stOutput.typename#" addtoken="no">
</cfif>
<cfsetting enablecfoutputonly="No">
