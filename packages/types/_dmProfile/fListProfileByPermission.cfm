<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmProfile/fListProfileByPermission.cfm,v 1.2.2.1 2006/02/17 06:54:39 paul Exp $
$Author: paul $
$Date: 2006/02/17 06:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.2.2.1 $

|| DESCRIPTION || 
dmProfile get data handler

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cfset stLocal.authorisationObj = CreateObject("component","#Application.packagepath#.security.authorisation")>

<cfset stLocal.returnstruct = stLocal.authorisationObj.fListUsersByPermssion(arguments.permissionName,arguments.permissionID)>
<cfset stLocal.lObjectID = stLocal.returnstruct.lObjectIDs>

<cfquery name="stLocal.qList" datasource="#application.dsn#">
SELECT p.userName, p.ObjectID, p.firstName, p.lastName 
FROM #application.dbowner#dmProfile p, #application.dbowner#dmUser u
WHERE p.userName = u.userLogin
	AND p.bActive = 1
	AND u.userId IN (#stLocal.lObjectID#)
ORDER BY p.lastName, p.firstName
</cfquery>

<cfset stReturn.queryObject = stLocal.qList>
