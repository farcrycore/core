<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/getProfile.cfm,v 1.6.4.1 2005/01/13 04:32:33 brendan Exp $
$Author: brendan $
$Date: 2005/01/13 04:32:33 $
$Name: milestone_2-2-1 $
$Revision: 1.6.4.1 $

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
WHERE userName = '#arguments.userName#'
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
    stObj.bInDB = 'false';
    </cfscript>
</cfif>