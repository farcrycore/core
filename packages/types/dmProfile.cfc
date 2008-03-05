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
	
    <cffunction name="createProfile" access="PUBLIC" hint="Create new profile object using existing dmSec information. Returns newly created profile as a struct." returntype="struct" output="true">
        <cfargument name="stProperties" type="struct" required="yes" />
		
		<cfset var stProfile=duplicate(arguments.stProperties) />
		<cfset var stResult=structNew() />
		<cfset var stobj=structNew() />

        <!--- if userlogin missing use user name (bwd compatability hack) --->
		<cfif not structkeyexists(stProfile,"username")>
			<cfset stProfile.username = stProfile.userlogin />
		</cfif>
		<cfif not structkeyexists(stProfile, "userdirectory") and find("_",stProfile.username)>
			<cfset stProfile.userdirectory = listlast(stProfile.username,"_") />
		<cfelseif not structkeyexists(stProfile,"userdirectory")>
			<cfset stProfile.userdirectory = "CLIENTUD" />
		</cfif>
		<cfif not structkeyexists(stProfile,"userlogin")>
			<cfset stProfile.userlogin = stProfile.username />
		</cfif>
		
		
		<cfparam name="stProfile.objectID" default="#createUUID()#" />
		<cfparam name="stProfile.label" default="#stProfile.userLogin#" />
		
		<cfif structkeyexists(stProfile,"userlogin") and not refind(stProfile.userDirectory,stProfile.userlogin)>
			<cfset stProfile.userName = stProfile.userLogin & "_" & stProfile.userDirectory />
		<cfelseif structkeyexists(stProfile,"userlogin")>
			<cfset stProfile.userName = stProfile.userLogin />
		</cfif>
		
		<cfparam name="stProfile.emailAddress" default="" />
		<cfparam name="stProfile.bReceiveEmail" default="1" />
		<cfparam name="stProfile.bActive" default="1" />
		
		<cfset stProfile.lastupdatedby = stProfile.userLogin />
		<cfset stProfile.datetimelastupdated = now() />
		<cfset stProfile.createdby = stProfile.userLogin />
		<cfset stProfile.datetimecreated = now() />
		
		<cfparam name="stProfile.locked" default="0" />
		<cfparam name="stProfile.lockedBy" default="" />
		
		<cfset stResult = createData(stProperties=stProfile, User=stProfile.username) />
			
		<cfif stResult.bSuccess>
			<cfreturn getProfile(userName=stProfile.username) />
		<cfelse>
			<cfreturn structnew() />
		</cfif>
    </cffunction>

    <cffunction name="getProfile" access="PUBLIC" hint="Retrieve profile data for given username">
        <cfargument name="userName" type="string" required="yes" hint="The username unique for the user directory.">
        <cfargument name="ud" type="string" required="no" default="clientUD" hint="The user directory to search for the profile.">

		<cfset var stobj = structNew() />
		<cfset var combinedUsername = "#arguments.username#_#arguments.ud#" />
		
		<!--- Use the  --->
		<cfquery name="qProfile" datasource="#application.dsn#">
		SELECT objectID FROM #application.dbowner#dmProfile
		WHERE UPPER(userName) = '#UCase(combinedUsername)#'
		</cfquery>
		
		<cfif not qProfile.recordCount>
			<cfquery name="qProfile" datasource="#application.dsn#">
			SELECT objectID FROM #application.dbowner#dmProfile
			WHERE UPPER(userName) = '#UCase(arguments.userName)#'
			</cfquery>
		</cfif>
		
		<cfif qProfile.recordCount>
		    <cfset stObj = this.getData(qProfile.objectID)>
		    <cfset stObj.bInDB = "true">
		<cfelse>
		    <cfscript>
		    stObj = structNew();
		    stObj.emailAddress = '';
		    stObj.bReceiveEmail = 0;
		    stObj.bActive = 0;
		    stObj.locale = 'en_AU';
		    stObj.bInDB = 'false';
		    stObj.userName = arguments.userName;
		    </cfscript>
		</cfif>

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