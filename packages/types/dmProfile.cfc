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
<cfcomponent extends="types" displayName="FarCry User Profile" hint="FarCry User Profile.  Authentication and authorisation handled seperately by associated user directory model.">

	<cfproperty name="userName" type="string" default="" required="yes" hint="The username/login the profile is associated with" ftSeq="1" ftFieldset="Authentication" ftLabel="User ID" ftType="string" bLabel="true" />
    <cfproperty name="userDirectory" type="string" default="" required="yes" hint="The user directory the profile is associated with." ftSeq="2" ftFieldset="Authentication" ftLabel="User directory" ftType="string" />
    <cfproperty name="bActive" type="boolean" default="0" required="yes" hint="Is user active" ftSeq="3" ftFieldset="Authentication" ftLabel="Active" ftType="boolean" />
	
    <cfproperty name="firstName" type="string" default="" required="no" hint="Profile object first name" ftSeq="21" ftFieldset="Contact details" ftLabel="First name" />
    <cfproperty name="lastName" type="string" default="" required="no" hint="Profile object last name" ftSeq="22" ftFieldset="Contact details" ftLabel="Last name" />
    <cfproperty name="emailAddress" type="string" default="" required="no" hint="Profile object email address" ftSeq="23" ftFieldset="Contact details" ftLabel="Email address" />
    <cfproperty name="bReceiveEmail" type="boolean" default="1" required="yes" hint="Does user receive workflow and system email notices" ftSeq="24" ftFieldset="Contact details" ftLabel="Receive emails" ftType="boolean" />
    <cfproperty name="phone" type="string" default="" required="no" hint="Profile object phone number" ftSeq="25" ftFieldset="Contact details" ftLabel="Phone" />
    <cfproperty name="fax" type="string" default="" required="no" hint="Profile object fax number" ftSeq="26" ftFieldset="Contact details" ftLabel="Fax" />
    
	<cfproperty name="position" type="string" default="" required="no" hint="Profile object position" ftSeq="31" ftFieldSet="Organisation" ftLabel="Position" />
    <cfproperty name="department" type="string" default="" required="no" hint="Profile object department" ftSeq="32" ftFieldSet="Organisation" ftLabel="Department" />
	
	<cfproperty name="locale" type="string" default="en_AU" ftdefault="application.config.general.locale" required="yes" hint="Profile object locale" ftDefaultType="evaluate" ftSeq="41" ftFieldSet="User settings" ftType="list" ftListDataTypename="dmProfile" ftListData="getLocales" ftLabel="Locale" />
	<cfproperty name="overviewHome" type="string" default="" required="no" hint="Nav Alias name for this users home node in the overview tree" ftSeq="42" ftFieldSet="User settings" ftType="navigation" ftSelectMultiple="false" ftLabel="Home node" />
	
	<cfproperty name="notes" type="longchar" default="" required="no" hint="Additional notes" ftSeq="51" ftType="lonchar" ftLabel="Notes" />
	
	<cffunction name="getLocales" access="public" output="false" returntype="string" hint="Returns the list of supported locales">
		<cfset var locales = application.i18nUtils.getLocales() />
		<cfset var localeNames = application.i18nUtils.getLocaleNames() />
		<cfset var result = "" />
		<cfset var locale = "" />

		<cfloop list="#application.locales#" index="locale">
			<cfset result = listappend(result,"#locale#:#listgetat(localeNames,listfind(locales,locale))#") />
		</cfloop>
		
		<cfreturn result />
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
		if (not refind(stUser.userDirectory,stUser.userLogin))
			stProfile.userName = stUser.userLogin & "_" & stUser.userDirectory;
		else
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