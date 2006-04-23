<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/createProfile.cfm,v 1.9 2005/10/04 23:57:16 geoff Exp $
$Author: geoff $
$Date: 2005/10/04 23:57:16 $
$Name: milestone_3-0-0 $
$Revision: 1.9 $

|| DESCRIPTION || 
dmProfile create handler

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)
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

stResult = this.createData(stProperties=stProfile, User=stUser.userLogin);

if (stResult.bSuccess) stObj = this.getProfile(userName=stUser.userLogin);
</cfscript>