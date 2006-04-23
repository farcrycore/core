<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/getProfile.cfm,v 1.5 2003/02/10 04:00:25 geoff Exp $
$Author: geoff $
$Date: 2003/02/10 04:00:25 $
$Name: b131 $
$Revision: 1.5 $

|| DESCRIPTION || 
dmProfile get data handler

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: getProfile.cfm,v $
Revision 1.5  2003/02/10 04:00:25  geoff
Updates to inlcude application.dbowner vars in <cfquery>

Revision 1.4  2002/10/23 07:02:55  pete
no message

Revision 1.3  2002/10/23 06:30:40  pete
no message

Revision 1.2  2002/10/23 05:53:01  pete
no message

Revision 1.1  2002/10/18 06:55:59  pete
first working version


|| END FUSEDOC ||
--->

<cfquery name="qProfile" datasource="#application.dsn#">
SELECT objectID FROM #application.dbowner#dmProfile
WHERE userName = '#stArgs.userName#'
</cfquery>

<cfif qProfile.recordCount eq 1>
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