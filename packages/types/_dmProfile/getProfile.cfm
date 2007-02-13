<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmProfile/getProfile.cfm,v 1.10 2005/08/15 06:03:00 guy Exp $
$Author: guy $
$Date: 2005/08/15 06:03:00 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
dmProfile get data handler

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cfquery name="qProfile" datasource="#application.dsn#">
SELECT objectID FROM #application.dbowner#dmProfile
WHERE UPPER(userName) = '#UCase(arguments.userName)#'
</cfquery>

<cfif qProfile.recordCount>
    <cfset stObj = this.getData(qProfile.objectID)>
    <cfset stObj.bInDB = "true">
<cfelse>
    <cfscript>
    stObj = structNew();
    stObj.emailAddress = '';
    stObj.bReceiveEmail = 0;
    stObj.bActive = 0;
    stObj.locale = 'en_AU';
    stObj.bInDB = 'false';
    stObj.userName = arguments.userName;
    </cfscript>
</cfif>