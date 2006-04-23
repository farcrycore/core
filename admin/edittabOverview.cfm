<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabOverview.cfm,v 1.36 2004/12/22 04:32:36 brendan Exp $
$Author: brendan $
$Date: 2004/12/22 04:32:36 $
$Name: milestone_2-3-2 $
$Revision: 1.36 $

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

<!--- check permissions --->
<cfscript>
	iOverviewTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectOverviewTab");
	oAuthentication = request.dmsec.oAuthentication;
	stUser = oAuthentication.getUserAuthenticationData();
	q4 = createObject("component","farcry.fourq.fourq");
	typename = q4.findType(url.objectid);
	o = createObject("component",application.types['#typename#'].typepath);
</cfscript>


<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iOverviewTab eq 1>
	<cfoutput>
		#o.renderObjectOverview(objectid=URL.objectid)#
	</cfoutput>
<cfelse>
	<admin:permissionError>
</cfif>

<STYLE TYPE="text/css">
	##idServer { 
		position:relative; 
		width: 400px; 
		height: 400px; 
		display:none;
	}
</STYLE>

<IFRAME WIDTH="100" HEIGHT="1" NAME="idServer" ID="idServer" 
	 FRAMEBORDER="0" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0" SRC="null">
		<ILAYER NAME="idServer" WIDTH="400" HEIGHT="100" VISIBILITY="Hide" 
		 ID="idServer">
		<P><cfoutput>#application.adminBundle[session.dmProfile.locale].browserReqBlurb#</cfoutput></P>
		</ILAYER>
</IFRAME>


<!--- setup footer --->
<admin:footer>	
