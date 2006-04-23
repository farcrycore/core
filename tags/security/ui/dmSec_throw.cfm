<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSec_throw.cfm,v 1.2 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
Gets a dmSec error and throws it.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> errorCode: What is the error.
-> language: What language do you want it in?
-> lExtra: Extra information to put into error.

|| HISTORY ||
$Log: dmSec_throw.cfm,v $
Revision 1.2  2004/07/15 02:03:27  brendan
i18n updates

Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.5  2002/10/24 03:20:03  pete
added new exception

Revision 1.4  2002/10/21 04:55:38  pete
removed references to userEmail as info now kept in dmProfile

Revision 1.3  2002/10/15 09:04:29  pete
added InsufficientAccess exception

Revision 1.2  2002/10/09 04:57:11  brendan
added login error codes

Revision 1.1.1.1  2002/08/22 07:18:02  geoff
no message

Revision 1.2  2001/11/29 11:12:53  aaron
no message

Revision 1.1  2001/11/15 11:09:56  matson
no message

Revision 1.2  2001/09/26 22:09:53  matson
no message

Revision 1.1  2001/09/20 17:34:57  matson
first import


|| END FUSEDOC ||
--->
<!--- populate the errors --->
<!--- this should be in the database in the end --->

<cfparam name="attributes.errorCode">
<cfparam name="request.language" default="English">
<cfparam name="attributes.language" default="#request.language#">
<cfparam name="attributes.lExtra" default="">

<cfset errorCode=attributes.errorCode>

<cfscript>
dmSec_FieldTooLong = "|1| is too long.  Maximum length for |1| is |2| characters.";
dmSec_FieldTooShort = "|1| is too short.  Minimum length for |1| is |2| characters.";

dmSec_UDNotDaemonType = "The operation you are trying to perform cannot be done on non Daemon user directory types.";

dmSec_LoginUserDisabled = "This user account has been disabled";
dmSec_LoginPasswordIncorrect = "Your password is incorrect.";
dmSec_LoginUserNotFound = "User not found";
dmSec_LoginInsufficientAccess = "User not member of admin groups";
dmSec_LoginADSIFailed = "User not found or password is incorrect.";

dmSec_UserGetMultipleUsers = "User '|1|' exists in multiple directories, please specify a user directory.";
dmSec_UserGetUnableToFind = "Unable to find user '|1|' in UserDirectory '|2|'.";
dmSec_CreateUserNotUnique = "The user login name '|1|' is already taken in UserDirectory '|2|'.";

dmSec_CreateNotUnique = "You are attempting to create a |1| with name '|2|', but it already exists in |3|";
dmSec_GroupGetTooMany = "GroupGet returned more than one group when only one was expected.  The group id or name is |1|";
dmSec_GroupGetUnableToFind = "GroupGet found no groups using the search criteria.  The group id or name is |1|";

dmSec_Parameters ="|1|";
dmSec_Results = "|1|";
</cfscript>

<!--- <cfset errorReturn="<span style='color:red;'>Error: #attributes.errorCode#: </span> "> --->
<cfset errorReturn="">


<!--- get the errortext for a specific language --->
<cfif IsDefined(errorCode&"_"&attributes.language)>
	<cfset errorReturn=errorReturn&Evaluate(errorCode&"_"&attributes.language)>
	
<!--- revert to English as default language --->
<cfelseif IsDefined(errorCode)>
	<cfset errorReturn=errorReturn&Evaluate(errorCode)>
	
<!--- final fallback --->
<cfelse>
	<cfset errorReturn=errorReturn&"Unknown error - "&attributes.lExtra>
</cfif>

<!--- Insert any extra information about the error ( delimited by '|' )--->
<cfset cnt=1>
<cfloop index="i" list="#attributes.lExtra#" delimiters="|">
	<cfset errorReturn=replace(errorReturn,"|"&cnt&"|",i,"all")>
	<cfset cnt=cnt+1>
</cfloop>

<!--- throw the final error --->
<cfif not isDefined("request.dmSec.throw.CollectErrors") or request.dmSec.throw.CollectErrors eq 0>
	<cfthrow message="#errorReturn#" type="dmSec" errorcode="#attributes.errorCode#">
<cfelse>
	<cfset request.dmSec.throw.errorCollection=request.dmSec.throw.errorCollection&errorReturn&"<Br>">
</cfif>

<cfsetting enablecfoutputonly="No">
