<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmhtml/edit.cfm,v 1.35.2.6 2006/02/10 01:03:43 paul Exp $
$Author: paul $
$Date: 2006/02/10 01:03:43 $
$Name: milestone_3-0-1 $
$Revision: 1.35.2.6 $

|| DESCRIPTION || 
$Description: dmHTML Edit Handler $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: url.killplp (optional)$
--->
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

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
	<cfset setlock(stobj=stobj, locked="true")>
</cfif>

<!--- todo maybe this can be a global function so can be used to clean other content types  --->
<!--- was this only to address tinyMCE issues? GB
removed as its affecting legitimate anchor references 20051209 GB
<cfscript>
function fcleanBody(myString){
	beginHREF = 0;   
	do {    
  		beginHREF = FindNoCase(" href", myString,beginHREF+1);
  		if (not beginHREF) break;
			endHREF = Find(">",myString,beginHREF);
			hrefString = Mid(myString, beginHREF, endHREF - beginHREF);
			if (FindNoCase("##",hrefString)) {
				x = MID(hrefString, Find("##", hrefString,0) ,len(hrefString));
				x = " href=" & """" & x;
				myString = ReplaceNoCase(myString,hrefString,x,"ALL");
			}
	}
	while (beginHREF gt 0); 
	return myString;
}
</cfscript>
 --->

<widgets:plp
	owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
	stepDir="/farcry/core/packages/types/_dmhtml/plpEdit"
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
 	<!--- x = REReplaceNoCase(myString, "(<a href)([[:ascii:]]*?)(\x23)([[:ascii:]]*?)>","<href=""##\4 >" , "ALL"); --->
	<!--- REReplaceNoCase(stoutput.body, "(<a href)([[:ascii:]]*?)(\x23)([[:ascii:]])>","<href=""##\4 >" , "ALL") --->
	<!--- <a[^>]*?href="[^?]*?"[^>]*?> --->

<!--- 
	see function call above, removed for now 20051209 GB
	<cfset stoutput.body = fcleanBody(stoutput.body)>
 --->
	<cfset setlock(locked="0",stObj=stOutput)>
	<!--- remove content item lock --->
	<cfset stoutput.locked=0>
	<cfset stoutput.lockedby=0>
	<!--- update content item --->
	<cfset setData(stProperties=stoutput)>

<!--- 
	FriendlyURL stuff Example Only
	<widgets:setFriendlyURL objectid="#stoutput.objectid#" customFriendlyURL="html/#stoutput.objectid#">
 --->

	<!--- check if object is a underlying draft page --->
	<cfset stuser = application.factory.oAuthentication.getUserAuthenticationData()>
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
				/*if(parent['sidebar'].frames['sideTree'])
					parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
					*/
				// redirect to cancelcompleteURL
	
				parent['content'].location.href = "#cancelCompleteURL#";
			</script>
		</cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no">