<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/edit.cfm,v 1.35 2005/09/29 23:29:38 gstewart Exp $
$Author: gstewart $
$Date: 2005/09/29 23:29:38 $
$Name: milestone_3-0-0 $
$Revision: 1.35 $

|| DESCRIPTION || 
$Description: dmHTML Edit Handler $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: url.killplp (optional)$
--->
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfparam name="url.killplp" default="0">

<cfset tempObject = CreateObject("component",application.types.dmhtml.typepath)>
<cfset stObj = tempObject.getData(arguments.objectid)>

<!--- determine where the edit handler has been called from to provide the right return url --->
<cfparam name="url.ref" default="sitetree" type="string">
<cfif url.ref eq "typeadmin"> 
	<!--- typeadmin redirect --->
	<cfset cancelCompleteURL = "#application.url.farcry#/content/dmhtml.cfm">
<cfelseif url.ref eq "closewin"> 
	<!--- close win has no official redirector as it closes open window --->
	<cfset cancelCompleteURL = "#application.url.farcry#/content/dmhtml.cfm">
<cfelse> 
	<!--- site tree redirect --->
	<cfset cancelCompleteURL = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#">
</cfif>

<!--- lock the content item for editing --->
<cfif NOT stobj.locked>
	<cfset setlock(locked="true")>
</cfif>


<widgets:plp
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="/farcry/farcry_core/packages/types/_dmhtml/plpEdit"
	cancelLocation="#cancelCompleteUrl#"
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
	<!--- update label --->
	<cfset stoutput.label = stoutput.title>
	<!--- update timestamp as wizard may have been active for some time --->
	<cfset stoutput.datetimelastupdated = now()>
	
	<!--- remove content item lock --->
	<cfset stoutput.locked=0>
	<!--- update content item --->
	<cfset setData(stProperties=stoutput)>

<!--- 
	FriendlyURL stuff Example Only
	<widgets:setFriendlyURL objectid="#stoutput.objectid#" customFriendlyURL="html/#stoutput.objectid#">
 --->

	<!--- check if object is a underlying draft page --->
	<cfset oAuthentication = request.dmSec.oAuthentication>
	<cfset stuser = oAuthentication.getUserAuthenticationData()>
	<cfif Len(Trim(stOutput.versionId))>
		<cfset objId = stOutput.versionId>
		<cfset auditNote = "Draft object update">
	<cfelse>
		<cfset objId = stOutput.objectId>
		<cfset auditNote = "update">
	</cfif>
	
	<!--- TODO: Please explain? Isn't this audit task being performed in the setdata() GB --->
	<cfset application.factory.oAudit.logActivity(auditType="Update", username=stUser.userlogin, location=cgi.remote_host, note=auditNote,objectid=objID)>

	<!--- clean up and redirect user --->
	<cfif url.ref eq "closewin">
		<cfoutput>
			<script type="text/javascript">
				// refresh parent window
				opener.location.href=opener.location.href;
				// close browser
				window.close();
			</script>
		</cfoutput>
	<cfelse>
		<!--- get parent to update tree --->
		<nj:treeGetRelations typename="#stOutput.typename#" objectId="#objId#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
		<!--- update tree --->
		<nj:updateTree objectId="#parentID#">
		<!--- relocate iframes for tree and edit areas using JS --->
		<cfoutput>
			<script type="text/javascript">
				// if sidebar overtree exists rebuild JS tree
				if(parent['sidebar'].frames['sideTree'])
					parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
				// redirect to cancelcompleteURL
				parent['content'].location.href = "#cancelCompleteURL#";
			</script>
		</cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no">