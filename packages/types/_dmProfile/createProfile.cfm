<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/createProfile.cfm,v 1.6 2003/09/10 23:46:11 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:46:11 $
$Name: b201 $
$Revision: 1.6 $

|| DESCRIPTION || 
dmProfile create handler

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cfscript>
stUser = arguments.stProperties;

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