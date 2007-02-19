<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: application code needed for every page. Checks login status and setus up request scope$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->

<cfscript>
request.dmSec.oAuthorisation = createObject("component","#application.securitypackagepath#.authorisation");
request.dmSec.oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
request.factory.oTree = createObject("component","#application.packagepath#.farcry.tree");
if (isDefined("url.logout") and url.logout eq 1)
	request.dmsec.oAuthentication.logout(bAudit=1);
stLoggedIn = request.dmsec.oAuthentication.getUserAuthenticationData();
request.loggedin = stLoggedin.bLoggedIn;	
</cfscript>


<!-------------------------------------------------------
Run Request Processing
	_serverSpecificRequestScope.cfm
-------------------------------------------------------->
<!--- core request processing --->
<cfinclude template="_requestScope.cfm">

<!--- project and library request processing --->
<cfif application.sysInfo.bServerSpecificRequestScope>
	<cfloop from="1" to="#arraylen(application.sysinfo.aServerSpecificRequestScope)#" index="i">
		<cfinclude template="#application.sysinfo.aServerSpecificRequestScope[i]#" />
	</cfloop>
</cfif>


<!--- This parameter is used by _farcryOnRequestEnd.cfm to determine which javascript libraries to include in the page <head> --->
<cfparam name="Request.inHead" default="#structNew()#">


<!--- IF the project has been set to developer mode, we need to refresh the metadata on each page request. --->
<cfif request.mode.bDeveloper>
	<cfset createObject("component","#application.packagepath#.farcry.alterType").refreshAllCFCAppData() />
</cfif>

<cfsetting enablecfoutputonly="no">