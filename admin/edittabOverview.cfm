<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabOverview.cfm,v 1.43 2005/10/06 04:59:43 guy Exp $
$Author: guy $
$Date: 2005/10/06 04:59:43 $
$Name: milestone_3-0-1 $
$Revision: 1.43 $

|| DESCRIPTION || 
$DESCRIPTION: Dispalys summary and options for editing/approving/previewing etc for selected object$
$TODO: make more generic for versioning $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$
$DEVELOPER:Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/farcry/" prefix="farcry">

<!--- check permissions --->
<cfset iOverviewTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectOverviewTab")>
<cfset q4 = createObject("component","farcry.fourq.fourq")>
<cfset typename = q4.findType(url.objectid)>
<cfset o = createObject("component",application.types['#typename#'].typepath)>
<cfset stObject = o.getData(objectid)>

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1','tab1');">
<!--- javascript functions for object editing --->
<script type="text/javascript"><cfoutput>
function confirmRestore(navid,draftObjectID)
{
	confirmmsg = "#application.adminBundle[session.dmProfile.locale].confirmRestoreLiveObjToDraft#";
	if(confirm(confirmmsg))
	{
		strURL = "#application.url.farcry#/navajo/restoreDraft.cfm";
		var req = new DataRequestor();
		req.addArg(_GET,"navid",navid);
		req.addArg(_GET,"objectid",draftObjectID);
		req.onload = processReqChange;
		req.onfail = function (status){alert("Sorry and error occured while restoring [" + status + "]")};
		req.getURL(strURL,_RETURN_AS_TEXT);
		return true;
	}
	else
		return false;	
}

function processReqChange(data, obj){
	var tmpmessage = JSON.parse(data);
	message = tmpmessage;
	alert(message);
	// refresh self
	self.window.location = self.window.location;
}
</cfoutput></script>
<cfif iOverviewTab eq 1><cfoutput>
	#o.renderObjectOverview(objectid=URL.objectid)#</cfoutput>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>	
