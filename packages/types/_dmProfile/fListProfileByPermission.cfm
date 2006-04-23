<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/fListProfileByPermission.cfm,v 1.2 2005/10/25 06:54:47 guy Exp $
$Author: guy $
$Date: 2005/10/25 06:54:47 $
$Name: milestone_3-0-0 $
$Revision: 1.2 $

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
SELECT	p.username, p.objectID, p.firstname, p.lastName
FROM 	#application.dbowner#dmProfile p, #application.dbowner#dmUser u
WHERE 	p.username = u.userlogin
		AND p.bActive = 1
		AND u.userid IN (#stLocal.lObjectID#)
ORDER BY p.lastName, p.firstname
</cfquery>

<cfset stReturn.queryObject = stLocal.qList>