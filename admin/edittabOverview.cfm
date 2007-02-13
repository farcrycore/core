<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$DESCRIPTION: Dispalys summary and options for editing/approving/previewing etc for selected object$
$TODO: make more generic for versioning $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$
$DEVELOPER:Paul Harrison (harrisonp@cbs.curtin.edu.au)$
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">

<!--- check permissions --->
<cfset iOverviewTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectOverviewTab")>
<cfset q4 = createObject("component","farcry.core.packages.fourq.fourq")>
<cfset typename = q4.findType(url.objectid)>
<cfset o = createObject("component",application.types['#typename#'].typepath)>
<cfset stObject = o.getData(objectid)>

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1','tab1');" />

<!--- javascript functions for object editing --->
<cfsavecontent variable="jshead">
<cfoutput>
<script type="text/javascript">
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
</script>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#jshead#" />


<cfif iOverviewTab eq 1><cfoutput>
	#o.renderObjectOverview(objectid=URL.objectid)#</cfoutput>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>	
<cfsetting enablecfoutputonly="false" />
