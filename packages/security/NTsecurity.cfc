<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/NTsecurity.cfc,v 1.14 2003/09/10 23:27:34 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:27:34 $
$Name: b201 $
$Revision: 1.14 $

|| DESCRIPTION ||
component for NT authentication and authorization

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cfcomponent name="security.NTsecurity" hint="component for NT authentication and authorization">

    <!--- *** USER BASED FUNCTIONS *** --->

    <!--- Authenticates the user and outputs true on success and false on failure --->
    <cffunction name="authenticateUser" access="PUBLIC" returntype="boolean" hint="Authenticate a user against Active Directory">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="password" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />
                
        <cfinclude template="_NTsecurity/authenticateUser.cfm">

        <cfreturn bAuth>
    </cffunction>
        
    <!---  Returns user's groups. Outputs groupnames on success and false on failure --->
    <cffunction name="getUserGroups" access="PUBLIC" returntype="string" hint="Get user groups">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />
                
        <cfinclude template="_NTsecurity/getUserGroups.cfm">

        <cfreturn groups>
    </cffunction>

    <cffunction name="userInDirectory" access="PUBLIC" returntype="boolean" hint="Determine if a user is a member of domain">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfinclude template="_NTsecurity/userInDirectory.cfm">

        <cfreturn bInDir>
    </cffunction>

    <cffunction name="userInGroup" access="PUBLIC" returntype="boolean" hint="Determine if a user is a member of given group in the domain">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="groupName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfinclude template="_NTsecurity/userInGroup.cfm">

        <cfreturn bInGroup>
    </cffunction>

    <cffunction name="getUserFullName" access="PUBLIC" returntype="string" hint="Return full name of user">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfinclude template="_NTsecurity/getUserFullName.cfm">

        <cfreturn fullName>
    </cffunction>

    <cffunction name="getUserDescription" access="PUBLIC" returntype="string" hint="Return user description">
        <cfargument name="userName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfinclude template="_NTsecurity/getUserDescription.cfm">

        <cfreturn desc>
    </cffunction>

    <!--- *** GROUP BASED FUNCTIONS *** --->

    <cffunction name="getDomainGroups" access="PUBLIC" returntype="array" hint="Retrieve all groups for the domain">
        <cfargument name="domain" type="string" required="true" />

        <cfinclude template="_NTsecurity/getDomainGroups.cfm">

        <cfreturn aGroups>
    </cffunction>

    <cffunction name="getGroupUsers" access="PUBLIC" returntype="array" hint="Retrieve array of users in a group">
        <cfargument name="groupName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfinclude template="_NTsecurity/getGroupUsers.cfm">

        <cfreturn aUsers>
    </cffunction>

    <cffunction name="getGroupDescription" access="PUBLIC" returntype="string" hint="Return group notes">
        <cfargument name="groupName" type="string" required="true" />
        <cfargument name="domain" type="string" required="true" />

        <cfinclude template="_NTsecurity/getGroupDescription.cfm">

        <cfreturn desc>
    </cffunction>
</cfcomponent>