<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmLink/edit.cfm,v 1.20.2.1 2005/11/29 03:29:29 paul Exp $
$Author: paul $
$Date: 2005/11/29 03:29:29 $
$Name: milestone_3-0-1 $
$Revision: 1.20.2.1 $

|| DESCRIPTION || 
$Description: dmLink Edit Handler $
$TODO: determine the role of nj:treeGetRelations and remove if possible.  Also not sure 
that checking if dmlink has a tree parent is an effective way of determining if we are 
editing from typeadmin or tree, i suspect its not. 20050802 GB $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: url.killplp (optional)$
--->
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="farcry">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfparam name="url.killplp" default="0">
<!--- determine where the edit handler has been called from to provide the right return url --->
<cfparam name="url.ref" default="sitetree" type="string">

<!--- lock the content item for editing --->
<cfif NOT stobj.locked>
	<cfset setlock(locked="true")>
</cfif>

<!--- work out if called from tree or dynamic admin --->
<cfif url.ref EQ "typeadmin"> 
	<cfset cancelPath="#application.url.farcry#/content/dmlink.cfm">	
<cfelse>
	<cfset cancelPath="#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.objectid#">
</cfif> 

<cfoutput>
<farcry:plp 
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="/farcry/farcry_core/packages/types/_dmLink/plpEdit"
	cancelLocation="#cancelPath#"
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
	<cfset stoutput.label = stoutput.title>
	<!--- update timestamp as wizard may have been active for some time --->
	<cfset stoutput.datetimelastupdated = now()>
	
	<cfset stOutput.locked = 0>
	<cfset stOutput.lockedby = ''>
	
	<!--- update content item --->
	<cfset setData(stProperties=stoutput)>
	
	<cfif url.ref EQ "typeadmin"> 
		<!--- return to type admin --->
		<cflocation url="#application.url.farcry#/content/dmlink.cfm" addtoken="no">
	<cfelse>
		<!--- return to dynamic tree listing --->
		<nj:treeGetRelations typename="#stOutput.typename#" objectId="#stOutput.objectid#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
		<!--- update tree --->
		<nj:updateTree objectId="#parentID#">
		<!--- reload overview page --->
		<cfoutput>
			<script type="text/javascript">
				parent['sidebar'].location.href = parent['sidebar'].location.href;
				parent['content'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#stOutput.objectid#';
			</script>
		</cfoutput>
	</cfif> 
</cfif>
<cfsetting enablecfoutputonly="No">
