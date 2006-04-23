<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/createProfile.cfm,v 1.5 2002/11/18 01:14:16 pete Exp $
$Author: pete $
$Date: 2002/11/18 01:14:16 $
$Name: b131 $
$Revision: 1.5 $

|| DESCRIPTION || 
dmProfile create handler

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: createProfile.cfm,v $
Revision 1.5  2002/11/18 01:14:16  pete
no message

Revision 1.4  2002/10/21 06:29:03  pete
added bReceiveEmail property

Revision 1.3  2002/10/21 05:21:39  pete
no message

Revision 1.2  2002/10/21 02:44:39  pete
added bActive property value of 1 for new profiles...

Revision 1.1  2002/10/18 07:29:43  pete
first working version


|| END FUSEDOC ||
--->

<cfscript>
stUser = stArgs.stProperties;

stProfile = structNew();
stProfile.objectID = createUUID();
stProfile.label = stUser.userLogin;
stProfile.userName = stUser.userLogin;
stProfile.userDirectory = stUser.userDirectory;
stProfile.emailAddress = '';
stProfile.bReceiveEmail = 1;
stProfile.bActive = 1;
stProfile.lastupdatedby = stUser.userLogin;
stProfile.datetimelastupdated = now();
stProfile.createdby = stUser.userLogin;
stProfile.datetimecreated = now();
stProfile.locked = 0;
stProfile.lockedBy = "";

stResult = this.createData(stProperties=stProfile);

if (stResult.bSuccess) stObj = this.getProfile(userName=stUser.userLogin);
</cfscript>