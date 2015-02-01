<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent 
	displayName="User Profile" 
	extends="types" 
	hint="Every user in the system has their own profile from staff to community members. You can create new users, edit existing ones or change the group they belong to."
	icon="fa-user">

<!------------------------------
TYPE PROPERTIES
-------------------------------->
	<cfproperty name="userName" type="string" required="yes" default="" 
		ftSeq="1" ftFieldset="Authentication" ftLabel="User ID" 
		ftType="string" 
		bLabel="true"
		hint="The username/login the profile is associated with">

	<cfproperty name="userDirectory" type="string" required="yes" default="" 
		ftSeq="2" ftFieldset="Authentication" ftLabel="User directory" 
		ftType="string"
		hint="The user directory the profile is associated with.">

	<cfproperty name="bActive" type="boolean" required="yes" default="0" 
		ftSeq="3" ftFieldset="Authentication" ftLabel="Active" 
		ftType="boolean"
		hint="Is user active">

	<cfproperty name="firstName" type="string" required="no" default="" 
		ftSeq="4" ftFieldset="Contact details" ftLabel="First Name"
		hint="Profile object first name">

	<cfproperty name="lastName" type="string" required="no" default="" 
		ftSeq="5" ftFieldset="Contact details" ftLabel="Last Name"
		hint="Profile object last name">

	<cfproperty name="emailAddress" type="string" required="no" default="" 
		ftSeq="6" ftFieldset="Contact details" ftLabel="Email Address" 
		ftType="email"
		hint="Profile object email address">

	<cfproperty name="bReceiveEmail" type="boolean" required="yes" default="1" 
		ftSeq="7" ftFieldset="Contact details" ftLabel="Receive Emails" 
		ftType="boolean"
		ftHint="Select this option if you want to receive email notifications from FarCry."
		hint="Does user receive workflow and system email notices.">

	<cfproperty name="phone" type="string" required="no" default="" 
		ftSeq="8" ftFieldset="Contact details" ftLabel="Phone"
		hint="Profile object phone number">

	<cfproperty name="fax" type="string" required="no" default="" 
		ftSeq="9" ftFieldset="Contact details" ftLabel="Fax"
		hint="Profile object fax number">

	<cfproperty name="avatar" type="string" default="" 
		ftSeq="10" ftFieldset="Profile" ftLabel="Profile Image" 
		ftType="image" ftDestination="/images/dmProfile/avatar" 
		ftAutoGenerateType="center" ftImageWidth="80" ftImageHeight="80" 
		ftAllowUpload="true" 
		ftQuality="1.0" ftInterpolation="blackman">

	<cfproperty name="position" type="string" required="no" default="" 
		ftSeq="11" ftFieldset="Organisation" ftLabel="Position"
		hint="Profile object position">

	<cfproperty name="department" type="string" required="no" default="" 
		ftSeq="12" ftFieldset="Organisation" ftLabel="Department"
		hint="Profile object department">

	<cfproperty name="locale" type="string" required="yes" default="en_AU" 
		ftSeq="13" ftFieldset="User settings" ftLabel="Locale" 
		ftType="list" ftDefaultType="evaluate" ftDefault="application.fapi.getConfig('general','locale')" 
		ftListDataTypename="dmProfile" ftListData="getLocales"
		hint="Profile object locale">

	<cfproperty name="overviewHome" type="string" required="no" default="" 
		ftSeq="14" ftFieldset="User settings" ftLabel="Default site tree location" 
		ftType="navigation" ftAlias="root" ftRenderType="dropdown" ftDefaultType="evaluate" ftDefault="application.fapi.getNavID('home')" 
		ftSelectMultiple="false"
		hint="Nav Alias name for this users home node in the overview tree">

	<cfproperty name="notes" type="longchar" required="no" default="" 
		ftSeq="15" ftLabel="" 
		ftType="longchar"
		hint="Additional notes">

	<cfproperty name="wddxPersonalisation" type="longchar" required="no" default="" 
		ftLabel=""
		hint="WDDX packet containing a user's personalisation settings.">

	<cfproperty name="lastLogin" type="datetime"
		hint="The last login date of this user">

<!------------------------------
OBJECT METHODS
-------------------------------->
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
		
		
		<cfparam name="stProfile.objectID" default="#application.fc.utils.createJavaUUID()#" />
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

	<cffunction name="getProfileID" access="public" returntype="string" hint="Returns the objectid of a profile for a given username. Returns empty string if username not found">
		<cfargument name="userName" type="string" required="yes" hint="The username unique for the user directory." />
		<cfargument name="ud" type="string" required="no" default="clientUD" hint="The user directory to search for the profile." />
		
		<cfset var combinedUsername = "#arguments.username#_#arguments.ud#" />
		<cfset var profileID = "" />
		<cfset var qProfile	= '' />
		
		<!--- Use the  --->
		<cfquery name="qProfile" datasource="#application.dsn#">
			SELECT objectID 
			FROM #application.dbowner#dmProfile
			WHERE UPPER(userName) = '#UCase(combinedUsername)#'
		</cfquery>
		
		<cfif not qProfile.recordCount>
			<cfquery name="qProfile" datasource="#application.dsn#">
				SELECT objectID 
				FROM #application.dbowner#dmProfile
				WHERE UPPER(userName) = '#UCase(arguments.userName)#'
			</cfquery>
		</cfif>
		
		<cfif qProfile.recordCount>
			<cfset profileID = qProfile.objectID />
		</cfif>
		
		<cfreturn profileID />
	</cffunction>

	<cffunction name="getProfile" access="PUBLIC" hint="Retrieve profile data for given username">
		<cfargument name="userName" type="string" required="yes" hint="The username unique for the user directory." />
		<cfargument name="ud" type="string" required="no" default="clientUD" hint="The user directory to search for the profile." />
		
		<cfset var stobj = structNew() />
		<cfset var profileID = getProfileID(arguments.username, arguments.ud) />
		
		<cfif len(profileID)>
			<cfset stObj = this.getData(profileID) />
			<cfset stObj.bInDB = "true" />
		<cfelse>
			<!--- GET A DEFAULT OBJECT --->
			<cfset stObj = this.getData(application.fapi.getUUID()) />
			
			<!--- Force in the correct values --->
			<cfscript>
				stObj.bActive = 0;
				stObj.bInDB = 'false';
				stObj.userName = arguments.userName;
				stObj.userDirectory = arguments.ud;
			</cfscript>
		</cfif>
		
		<cfreturn stObj />
	</cffunction>
	
	<cffunction name="fListProfileByPermission" hint="returns a query of users" access="public" output="false" returntype="struct">
		<cfargument name="permissionName" required="false" default="" type="string">
		<cfargument name="permissionID" required="false" default="" type="string" hint="Deprecated">
				
		<cfset var stLocal = StructNew()>
		<cfset var stReturn = StructNew()>
		<cfset var lProfiles = "" />
		
		<!--- Get profiles --->
		<cfif len(arguments.permissionID)>
			<cfset arguments.permissionName = arguments.permissionid />
		</cfif>
		<cfset lProfiles = application.security.factory.role.getAuthenticatedProfiles(roles=application.security.factory.role.getRolesWithPermission(permission=arguments.permissionname)) />
		
		<cfset stReturn.bSuccess = true>
		<cfset stReturn.message = "">

		<cfif len(lProfiles)>
			<cfquery datasource="#application.dsn#" name="stReturn.queryObject">
				select		*
				from	 	#application.dbowner#dmProfile
				where		objectid in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lProfiles#" />)
			</cfquery>
		<cfelse>
			<cfset stReturn.bSuccess = false />
		</cfif>

		<cfreturn stReturn>
	</cffunction>

	<cffunction name="delete" access="public" hint="Basic delete method for all objects. Deletes content item and removes Verity entries." returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var oUser = createobject("component",application.stCOAPI.farUser.packagepath) />
		<cfset var stUser = oUser.getByUserID(application.factory.oUtils.listSlice(stObj.userName,1,-2,"_")) />
		<cfset var stReturn = structNew() />
		
		<cfif stobj.username EQ "farcry_CLIENTUD">
			<!--- DO NOT ALLOW FARCRY USER TO BE DELETED. IT SHOULD ONLY BE PERMITTED TO BE FLAGGED AS INACTIVE --->
			<cfset stReturn.bSuccess = false>
			<cfset stReturn.message = "The user farcry is protected by the system and can only be de-activated.">
			
			<cfreturn stReturn />
		<cfelse>
		
			<cfif listlast(stObj.username,"_") eq "CLIENTUD" and not structisempty(stUser)>
				<cfset oUser.delete(objectid=stUser.objectid,user=arguments.user,auditNote=arguments.auditNote) />
			</cfif>
			
			<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,auditNote=arguments.auditNote) />
		</cfif>
	</cffunction>

	
 	<cffunction name="autoSetLabel" access="public" output="false" returntype="string" hint="Automagically sets the label">
		<cfargument name="stProperties" required="true" type="struct">

		<!--- 
			This will set the default Label value. It first looks form the bLabel associated metadata.
			Otherwise it will look for title, then name and then anything with the substring Name.
		 --->
		<cfset var newLabel = "" />
	
		<cfif len(arguments.stProperties.firstname) OR len(arguments.stProperties.lastname)>
			<cfset newLabel = "#arguments.stProperties.firstname# #arguments.stProperties.lastname#" />
		<cfelseif len(arguments.stProperties.emailAddress)>
			<cfset newLabel = arguments.stProperties.emailAddress />
		<cfelse>
			<cfset newLabel = arguments.stProperties.userName />
		</cfif>

		<cfreturn trim(newLabel) />
	</cffunction>		
</cfcomponent>