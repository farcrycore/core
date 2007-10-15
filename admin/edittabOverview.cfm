<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| DESCRIPTION || 
$DESCRIPTION: Displays summary and options for editing/approving/previewing etc for selected object $
$TODO:
- Remove inline styles
- Remove remote references to YUI files
- basically rewrite.. this is horrible
GB 20071015 $

|| DEVELOPER ||
$DEVELOPER: Mat Bryant (mbryant@daemon.com.au)$
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">

<!--- check permissions --->
<cfset iOverviewTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectOverviewTab")>
<cfset q4 = createObject("component","farcry.core.packages.fourq.fourq")>
<cfset typename = q4.findType(url.objectid)>
<cfset o = createObject("component",application.types['#typename#'].typepath)>
<cfset stObject = o.getData(objectid)>

<!--- <admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1','tab1');" /> --->
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
            "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Edit Tab Overview</title>
	<!-- Source File -->
	<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.3.0/build/reset-fonts-grids/reset-fonts-grids.css">
	
	<style type="text/css">
	body {text-align:left;}
	
	<!--- p {margin:5px 0px 10px 0px;} --->
	/* =DEFINITION LISTS */
	dl {margin: 0 0 1.5em}
	dt {clear:left;font-weight:bold;margin:3px 0}
	dd {margin:3px 0;padding:0}
	dd.thumbnail {float:left;width:100px;margin-right:6px;border: 1px solid ##000;margin-bottom:0}
	dd.thumbnail img {display:block}

	dl.dl-style1 {border-top: 1px solid ##fff;font-size:86%}
	.tab-panes dl.dl-style1 {margin-right:140px}
	dl.dl-style1 dt {float:left;clear:left;width:130px;margin:0;_height:1.5em;min-height:1.5em;border:none;}
	.tab-panes dl.dl-style1 dt {width:28%}
	dl.dl-style1 dd {width: auto;margin: 0;border-bottom: 1px solid ##fff;padding: 1px 0;_height:1.5em;min-height:1.5em}
	.tab-panes dl.dl-style1 dd {margin-left:28%;_margin-left:20%}

	.tab-content {padding:25px;}
	
	.icon {margin: 0 0 10px}

	.webtopOverviewActions {float:right;width:220px;}
	.webtopOverviewActions .farcryButtonWrap-outer {margin-bottom:5px;}
	.webtopOverviewActions .farcryButton {width:200px;}
	
	

	</style>
</head>
<body>
</cfoutput>


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


<cfif iOverviewTab eq 1>
	<skin:view objectid="#url.objectid#" webskin="renderWebtopOverview" />
	<!--- <cfoutput>#o.renderObjectOverview(objectid=URL.objectid)#</cfoutput> --->
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<!--- <admin:footer>	 --->
<cfoutput>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false" />
