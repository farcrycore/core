<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmProfile.cfc,v 1.14 2003/09/10 23:46:11 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:46:11 $
$Name: b201 $
$Revision: 1.14 $

|| DESCRIPTION || 
dmProfile object CFC

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cfcomponent extends="types" displayName="Profiles">

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
	
	<cffunction name="display" access="public" output="true">
		<cfargument name="objectid" required="yes" type="UUID">
		
		<!--- getData for object edit --->
		<cfset stObj = this.getData(arguments.objectid)>
		<cfinclude template="_dmProfile/display.cfm">
	</cffunction>

</cfcomponent>