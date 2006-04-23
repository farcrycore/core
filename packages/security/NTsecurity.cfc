<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/NTsecurity.cfc,v 1.13 2002/10/22 01:01:35 pete Exp $
$Author: pete $
$Date: 2002/10/22 01:01:35 $
$Name: b131 $
$Revision: 1.13 $

|| DESCRIPTION ||
component for NT authentication and authorization

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: NTsecurity.cfc,v $
Revision 1.13  2002/10/22 01:01:35  pete
added getGroupUsers function

Revision 1.12  2002/10/17 04:23:03  pete
no message

Revision 1.11  2002/10/17 04:15:28  pete
added getUserFullName method

Revision 1.10  2002/10/15 08:57:34  pete
added getUserDescription() method.

Revision 1.9  2002/10/15 08:48:34  pete
added getGroupDescription() method

Revision 1.8  2002/10/15 08:12:15  pete
no message

Revision 1.7  2002/10/15 08:08:03  pete
no message

Revision 1.6  2002/10/15 03:59:10  pete
no message

Revision 1.5  2002/10/15 03:43:09  pete
no message

Revision 1.4  2002/10/15 03:41:55  pete
added userInDirectory anmd userInGroup methods

Revision 1.3  2002/10/15 02:21:40  pete
removed password attributes from getUserGroups() since its not needed

Revision 1.2  2002/10/15 02:02:28  pete
syntax error fix

Revision 1.1  2002/10/15 01:55:46  pete
first working version

|| END FUSEDOC ||
--->

<cfcomponent name="security.NTsecurity">

    <!--- *** USER BASED FUNCTIONS *** --->

    <!--- Authenticates the user and outputs true on success and false on failure --->
    <cffunction name="authenticateUser" access="PUBLIC" returntype="boolean" hint="Authenticate a user against Active Directory">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="password" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />
                
        <cfset stArgs = arguments>
        <cfinclude template="_NTsecurity/authenticateUser.cfm">

        <cfreturn bAuth>
    </cffunction>
        
    <!---  Returns user's groups. Outputs groupnames on success and false on failure --->
    <cffunction name="getUserGroups" access="PUBLIC" returntype="string" hint="Get user groups">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />
                
        <cfset stArgs = arguments>
        <cfinclude template="_NTsecurity/getUserGroups.cfm">

        <cfreturn groups>
    </cffunction>

    <cffunction name="userInDirectory" access="PUBLIC" returntype="boolean" hint="Determine if a user is a member of domain">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfset stArgs = arguments>
        <cfinclude template="_NTsecurity/userInDirectory.cfm">

        <cfreturn bInDir>
    </cffunction>

    <cffunction name="userInGroup" access="PUBLIC" returntype="boolean" hint="Determine if a user is a member of given group in the domain">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="groupName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfset stArgs = arguments>
        <cfinclude template="_NTsecurity/userInGroup.cfm">

        <cfreturn bInGroup>
    </cffunction>

    <cffunction name="getUserFullName" access="PUBLIC" returntype="string" hint="Return full name of user">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfset stArgs = arguments>
        <cfinclude template="_NTsecurity/getUserFullName.cfm">

        <cfreturn fullName>
    </cffunction>

    <cffunction name="getUserDescription" access="PUBLIC" returntype="string" hint="Return user description">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfset stArgs = arguments>
        <cfinclude template="_NTsecurity/getUserDescription.cfm">

        <cfreturn desc>
    </cffunction>

    <!--- *** GROUP BASED FUNCTIONS *** --->

    <cffunction name="getDomainGroups" access="PUBLIC" returntype="array" hint="Retrieve all groups for the domain">
        <cfargument name="domain" type="string" required="true" />

        <cfset stArgs = arguments>
        <cfinclude template="_NTsecurity/getDomainGroups.cfm">

        <cfreturn aGroups>
    </cffunction>

    <cffunction name="getGroupUsers" access="PUBLIC" returntype="array" hint="Retrieve array of users in a group">
        <cfargument name="groupName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfset stArgs = arguments>
        <cfinclude template="_NTsecurity/getGroupUsers.cfm">

        <cfreturn aUsers>
    </cffunction>

    <cffunction name="getGroupDescription" access="PUBLIC" returntype="string" hint="Return group notes">
        <cfargument name="groupName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfset stArgs = arguments>
        <cfinclude template="_NTsecurity/getGroupDescription.cfm">

        <cfreturn desc>
    </cffunction>
</cfcomponent>