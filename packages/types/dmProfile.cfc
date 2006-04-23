<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmProfile.cfc,v 1.20 2005/07/29 07:30:36 guy Exp $
$Author: guy $
$Date: 2005/07/29 07:30:36 $
$Name: milestone_3-0-0 $
$Revision: 1.20 $

|| DESCRIPTION || 
dmProfile object CFC

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cfcomponent extends="types" displayName="Profiles" hint="FarCry User Profile.  Authentication and authorisation handled seperately by associated user directory model.">

    <!--- required properties --->	
    <cfproperty name="userName" type="nstring" hint="The username/userlogin the profile is associated with." required="yes">
    <cfproperty name="userDirectory" type="nstring" hint="The user directory the profile is associated with." required="yes">
    <cfproperty name="bReceiveEmail" type="boolean" hint="Does user receive workflow and system email notices" required="yes" default="1">
    <cfproperty name="bActive" type="boolean" hint="Is user active" required="yes" default="0">
    <!--- optional properties --->
    <cfproperty name="firstName" type="nstring" hint="Profile object first name" required="no">
    <cfproperty name="lastName" type="nstring" hint="Profile object last name" required="no">
    <cfproperty name="emailAddress" type="nstring" hint="Profile object email address" required="no" default="">
    <cfproperty name="phone" type="nstring" hint="Profile object phone number" required="no">
    <cfproperty name="fax" type="nstring" hint="Profile object fax number" required="no">
    <cfproperty name="position" type="nstring" hint="Profile object position" required="no">
    <cfproperty name="department" type="nstring" hint="Profile object department" required="no">
	<cfproperty name="notes" type="longchar" hint="Additional notes" required="no">
	<cfproperty name="locale" type="string" hint="Profile object locale" required="yes" default="en_AU">
	<cfproperty name="overviewHome" type="string" hint="Nav Alias name for this users home node in the overview tree" required="no">
		
    <!--- object methods --->
    <cffunction name="edit" access="PUBLIC" hint="dmProifle edit handler">
    	<cfargument name="objectID" type="UUID" required="yes">
	
        <cfscript>
        // getData for object edit
        stObj = this.getData(arguments.objectID);
        </cfscript>

	    <cfinclude template="_dmProfile/edit.cfm">
    </cffunction>

    <cffunction name="createProfile" access="PUBLIC" hint="Create new profile object using existing dmSec information">
        <cfargument name="stProperties" type="struct" required="yes">

        <cfinclude template="_dmProfile/createProfile.cfm">

        <cfreturn stObj>
    </cffunction>

    <cffunction name="getProfile" access="PUBLIC" hint="Retrieve profile data for given username">
        <cfargument name="userName" type="string" required="yes">

        <cfinclude template="_dmProfile/getProfile.cfm">

        <cfreturn stObj>
    </cffunction>
	
<!--- 	
TODO: permanently remove this method if appropriate; 20050523GB  
	<cffunction name="display" access="public" output="true">
		<cfargument name="objectid" required="yes" type="UUID">
		
		<!--- getData for object edit --->
		<cfset stObj = this.getData(arguments.objectid)>
		<cfinclude template="_dmProfile/display.cfm">
	</cffunction>
 --->	
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