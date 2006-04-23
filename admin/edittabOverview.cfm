<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabOverview.cfm,v 1.34 2004/01/12 07:35:46 paul Exp $
$Author: paul $
$Date: 2004/01/12 07:35:46 $
$Name: milestone_2-2-1 $
$Revision: 1.34 $

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


<admin:header>

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
	 FRAMEBORDER="0" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0">
		<ILAYER NAME="idServer" WIDTH="400" HEIGHT="100" VISIBILITY="Hide" 
		 ID="idServer">
		<P>This page uses a hidden frame and requires either Microsoft 
		Internet Explorer v4.0 (or higher) or Netscape Navigator v4.0 (or 
		higher.)</P>
		</ILAYER>
</IFRAME>


<!--- setup footer --->
<admin:footer>	
