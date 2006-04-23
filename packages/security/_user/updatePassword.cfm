<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_user/updatePassword.cfm,v 1.5 2004/06/02 12:03:52 brendan Exp $
$Author: brendan $
$Date: 2004/06/02 12:03:52 $
$Name: milestone_2-2-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: updates a users password $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get user details --->
<cfscript>
	stUser = request.dmsec.oAuthentication.getUser(userlogin="#session.dmsec.authentication.userlogin#",userDirectory="#session.dmsec.authentication.userdirectory#");
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
		WHERE userId=<cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR" null="No">
	</cfquery>
	<cfset bUpdate = true>
<cfelse>
	<cfset bUpdate = false>
</cfif>