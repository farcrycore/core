<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/security/_user/updatePassword.cfm,v 1.7 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: updates a users password $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get user details --->
<cfscript>
	stUser = application.factory.oAuthentication.getUser(userid="#arguments.userId#",userDirectory="#session.dmsec.authentication.userdirectory#");
</cfscript>
<!--- check if UD has password encryption --->
<cfif structKeyExists(Application.dmSec.UserDirectory[stUser.userDirectory],"bEncrypted") and Application.dmSec.UserDirectory[stUser.userDirectory].bEncrypted>
	<cfset newPassword = hash(arguments.newPassword)>
	<cfset oldPassword = hash(arguments.oldPassword)>
<cfelse>
	<cfset newPassword = arguments.newPassword>
	<cfset oldPassword = arguments.oldPassword>
</cfif>

<!--- check old password is entered correctly --->
<cfif stUser.userPassword eq oldPassword>
	<cfquery name="update" datasource="#arguments.dsn#">
		UPDATE #application.dbowner#dmUser SET
		userPassword=<cfqueryparam value="#newPassword#" cfsqltype="CF_SQL_VARCHAR"  null="No">
		WHERE userId=<cfqueryparam value="#stUser.userId#" cfsqltype="CF_SQL_VARCHAR" null="No">
	</cfquery>
	<cfset bUpdate = true>
<cfelse>
	<cfset bUpdate = false>
</cfif>