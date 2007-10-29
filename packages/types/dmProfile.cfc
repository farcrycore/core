<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/dmProfile.cfc,v 1.20.2.1 2006/01/09 09:34:59 geoff Exp $
$Author: geoff $
$Date: 2006/01/09 09:34:59 $
$Name: milestone_3-0-1 $
$Revision: 1.20.2.1 $

|| DESCRIPTION || 
$Description: Generic member/user profile object $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent extends="types" displayName="Profiles" hint="FarCry User Profile.  Authentication and authorisation handled seperately by associated user directory model.">

    <!--- required properties --->	
    <cfproperty name="userName" type="nstring" hint="The username/userlogin the profile is associated with." required="yes" ftLabel="Username">
    <cfproperty name="userDirectory" type="nstring" hint="The user directory the profile is associated with." required="yes" ftLabel="User Directory">
    <cfproperty name="bReceiveEmail" type="boolean" hint="Does user receive workflow and system email notices" required="yes" default="1" ftLabel="Receive Email">
    <cfproperty name="bActive" type="boolean" hint="Is user active" required="yes" default="0" ftLabel="Active">
    <!--- optional properties --->
    <cfproperty name="firstName" type="nstring" hint="Profile object first name" required="no" ftLabel="First Name">
    <cfproperty name="lastName" type="nstring" hint="Profile object last name" required="no" ftLabel="Last Name">
    <cfproperty name="emailAddress" type="nstring" hint="Profile object email address" required="no" default="" ftLabel="Email Address">
    <cfproperty name="phone" type="nstring" hint="Profile object phone number" required="no" ftLabel="Phone Number">
    <cfproperty name="fax" type="nstring" hint="Profile object fax number" required="no" ftLabel="Fax Number">
    <cfproperty name="position" type="nstring" hint="Profile object position" required="no" ftLabel="Position">
    <cfproperty name="department" type="nstring" hint="Profile object department" required="no" ftLabel="Department">
	<cfproperty name="notes" type="longchar" hint="Additional notes" required="no" ftLabel="Notes">
	<cfproperty name="locale" type="string" hint="Profile object locale" required="yes" default="en_AU" ftLabel="Locale">
	<cfproperty name="overviewHome" type="string" hint="Nav Alias name for this users home node in the overview tree" required="no" ftLabel="Home Nav Alias">
		
    <!--- object methods --->
    <cffunction name="edit" access="PUBLIC" hint="dmProifle edit handler">
    	<cfargument name="objectID" type="UUID" required="yes">
	
        <cfscript>
        // getData for object edit
        stObj = this.getData(arguments.objectID);
        </cfscript>

	    <cfinclude template="_dmProfile/edit.cfm" />
    </cffunction>

    <cffunction name="createProfile" access="PUBLIC" hint="Create new profile object using existing dmSec information. Returns newly created profile as a struct." returntype="struct" output="false">
        <cfargument name="stProperties" type="struct" required="yes" />
		<cfset var stuser=arguments.stProperties>
		<cfset var stProfile=structNew()>
		<cfset var stResult=structNew()>
		<cfset var stobj=structNew()>

        <cfscript>
		// if userlogin missing use user name (bwd compatability hack)
		if (NOT structkeyexists(stuser, "userlogin") OR NOT structkeyexists(stuser, "userdirectory")) {
			stuser.userLogin=stuser.username;
			stuser.userdirectory="CLIENTUD";
		}
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
		
		stResult = createData(stProperties=stProfile, User=stUser.userLogin);
		
		if (stResult.bSuccess) 
			stObj = getProfile(userName=stUser.userLogin);
		</cfscript>

        <cfreturn stObj />
    </cffunction>

    <cffunction name="getProfile" access="PUBLIC" hint="Retrieve profile data for given username">
        <cfargument name="userName" type="string" required="yes">

        <cfinclude template="_dmProfile/getProfile.cfm">

        <cfreturn stObj>
    </cffunction>
	
	<cffunction name="displaySummary" access="public" output="false" returntype="string">
		<cfargument name="objectid" required="yes" type="UUID">
		
		<!--- getData for object edit --->
		<cfset stObj = this.getData(arguments.objectid)>
		<cfinclude template="_dmProfile/displaySummary.cfm">
		<cfreturn profilehtml>
	</cffunction>

	<cffunction name="fListProfileByPermission" hint="returns a query of users" access="public" output="false" returntype="struct">
		<cfargument name="permissionName" required="false" default="" type="string">
		<cfargument name="permissionID" required="false" default="0" type="numeric">
				
		<cfset var stLocal = StructNew()>
		<cfset var stReturn = StructNew()>

		<cfset stReturn.bSuccess = true>
		<cfset stReturn.message = "">
		<cftry>
			
			<cfinclude template="_dmProfile/fListProfileByPermission.cfm">

			<cfcatch>
				<cfset stReturn.bSuccess = false>
				<cfset stReturn.message = cfcatch.message>						
			</cfcatch>
		</cftry>

		<cfreturn stReturn>
	</cffunction>
</cfcomponent>