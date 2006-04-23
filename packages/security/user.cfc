<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/user.cfc,v 1.4 2004/07/15 01:58:59 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:58:59 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: user cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="User Functions" hint="Functions dealing with FarCry Users">
	<cffunction name="updatePassword" access="public" returntype="boolean" hint="Updates a user's password">
		<cfargument name="userId" type="string" required="true">
		<cfargument name="oldPassword" type="string" required="true">
		<cfargument name="newPassword" type="string" required="true">
		<cfargument name="newPassword2" type="string" required="true">
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		
		<cfinclude template="_user/updatePassword.cfm">
		
		<cfreturn bUpdate>
	</cffunction>
</cfcomponent>