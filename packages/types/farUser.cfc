<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
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
<!--- @@Developer: Blair Mackenzie (blair@daemon.com.au) --->
<cfcomponent 
	extends="types" displayname="FarCry User" output="false" 
	hint="User model for the FarCry User Directory."
	fuAlias="user" bSystem="true" ud="CLIENTUD">

	<cfproperty name="userid" type="string" default="" 
		ftSeq="1" ftFieldset="User" ftLabel="User ID" 
		ftType="string" 
		bLabel="true" ftValidation="required" ftIndex="true"
		hint="The unique id for this user. Used for logging in">

	<cfproperty name="password" type="string" default="" 
		ftSeq="2" ftFieldset="User" ftLabel="Password" 
		ftType="password" ftRenderType="confirmpassword" 
		ftShowLabel="false" ftValidation="required" ftValidateOldMethod="ftCheckOldPassword" ftValidateNewMethod="ftCheckPasswordPolicy">

	<cfproperty name="userstatus" type="string" default="active" 
		ftSeq="3" ftFieldset="User" ftLabel="User status" 
		ftType="list" 
		ftList="active:Active,inactive:Inactive,pending:Pending"
		hint="The status of this user; active, inactive, pending.">

	<cfproperty name="aGroups" type="array" default="" 
		ftSeq="4" ftFieldset="User" ftLabel="Groups" 
		ftType="array" ftJoin="farGroup" ftLibraryDataSQLOrderBy="title ASC"
		hint="The groups this member is a member of">

	<cfproperty name="lGroups" type="longchar" default="" 
		ftLabel="" 
		ftType="arrayList" ftJoin="farGroup" 
		ftArrayField="aGroups"
		hint="The groups this member is a member of (list generated automatically)">

	<cfproperty name="failedLogins" type="longchar" default="[]" 
		ftDefault="[]"
		hint="Log of failed logins">

	<cfproperty name="forgotPasswordHash" type="string" default=""
		hint="A hash stored temporarily to reset user password">
	
	<cffunction name="getByUserID" access="public" output="false" returntype="struct" hint="Returns the data struct for the specified user id">
		<cfargument name="userid" type="string" required="true" hint="The user id" />
		
		<cfset var stResult = structnew() />
		<cfset var qUser = "" />
		
		<cfquery datasource="#application.dsn#" name="qUser">
			select	objectid
			from	#application.dbowner#farUser
			where	lower(userid)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.userid)#" />
		</cfquery>
		
		<cfif qUser.recordcount>
			<cfset stResult = getData(qUser.objectid) />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="addGroup" access="public" output="false" returntype="void" hint="Adds this user to a group">
		<cfargument name="user" type="string" required="true" hint="The user to add" />
		<cfargument name="group" type="string" required="true" hint="The group to add to" />
		
		<cfset var stUser = structnew() />
		<cfset var stGroup = structnew() />
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		<cfset var i = 0 />
		
		<!--- Get the user by objectid or userid --->
		<cfif isvalid("uuid",arguments.user)>
			<cfset stUser = getData(arguments.user) />
		<cfelse>
			<cfset stUser = getByUserID(arguments.user) />
		</cfif>
	
		<cfif not isvalid("uuid",arguments.group)>
			<cfset arguments.group = oGroup.getID(arguments.group) />
		</cfif>
		
		<!--- Check to see if they are already a member of the group --->
		<cfparam name="stUser.aGroups" default="#arraynew(1)#" />
		<cfloop from="1" to="#arraylen(stUser.aGroups)#" index="i">
			<cfif stUser.aGroups[i] eq arguments.group>
				<cfset arguments.group = "" />
			</cfif>
		</cfloop>
		
		<cfif len(arguments.group)>
			<cfset arrayappend(stUser.aGroups,arguments.group) />
			<cfset setData(stProperties=stUser) />
		</cfif>
	</cffunction>

	<cffunction name="removeGroup" access="public" output="false" returntype="void" hint="Removes this user from a group">
		<cfargument name="user" type="string" required="true" hint="The user to add" />
		<cfargument name="group" type="string" required="true" hint="The group to add to" />
		
		<cfset var stUser = structnew() />
		<cfset var i = 0 />
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		
		<!--- Get the user by objectid or userid --->
		<cfif isvalid("uuid",arguments.user)>
			<cfset stUser = getData(arguments.user) />
		<cfelse>
			<cfset stUser = getByUserID(arguments.user) />
		</cfif>
		
		<cfif not isvalid("uuid",arguments.group)>
			<cfset arguments.group = oGroup.getID(arguments.group) />
		</cfif>
		
		<!--- Check to see if they are a member of the group --->
		<cfparam name="stUser.aGroups" default="#arraynew(1)#" />
		<cfloop from="#arraylen(stUser.aGroups)#" to="1" index="i" step="-1">
			<cfif stUser.aGroups[i] eq arguments.group>
				<cfset arraydeleteat(stUser.aGroups,i) />
			</cfif>
		</cfloop>
		
		<cfset setData(stProperties=stUser) />
	</cffunction>

	<cffunction name="setData" access="public" output="true" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	
		
		<cfset var stUser = getData(objectid=arguments.stProperties.objectid) />
		<cfset var oProfile = createObject("component", application.stcoapi["dmProfile"].packagePath) />
		<cfset var stUsersProfile = structNew() />
		<cfset var oUD = application.security.userdirectories[application.stCOAPI.farUser.ud] /> 
		
		<cfif structKeyExists(arguments.stProperties,"password") and stUser.password neq arguments.stProperties.password and getmetadata(application.security.cryptlib.findHash(arguments.stProperties.password)).alias eq getmetadata(application.security.cryptlib.getHashComponent('none')).alias>
			<cfset arguments.stProperties.password = application.security.cryptlib.encodePassword(password=arguments.stProperties.password,hashName=oUD.getOutputHashName()) />
		</cfif>
		
		<!--- Clear security cache --->
		<cfset application.security.initCache() />
		
		<cfreturn super.setData(arguments.stProperties,arguments.user,arguments.auditNote,arguments.bAudit,arguments.dsn,arguments.bSessionOnly,arguments.bAfterSave) />
	</cffunction>
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		
		<cfset var oUD = application.security.userdirectories[application.stCOAPI.farUser.ud] /> 
		
		<cfif structKeyExists(arguments.stProperties,"password") and getmetadata(application.security.cryptlib.findHash(arguments.stProperties.password)).alias eq getmetadata(application.security.cryptlib.getHashComponent('none')).alias>
			<cfset arguments.stProperties.password = application.security.cryptlib.encodePassword(password=arguments.stProperties.password,hashName=oUD.getOutputHashName()) />
		</cfif>
		
		<cfreturn super.createData(arguments.stProperties,arguments.user,arguments.auditNote,arguments.dsn) />
	</cffunction>
	
	<cffunction name="ftValidateUserID" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>	
		<cfset var qDuplicate = queryNew("blah")>		
		<cfset stResult = createObject("component", application.formtools["field"].packagePath).passed(value=stFieldPost.Value) />
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->	
		<cfquery datasource="#application.dsn#" name="qDuplicate">
		SELECT objectid from farUser
		WHERE upper(userid) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(stFieldPost.Value)#" />
		</cfquery>
		
		<cfif qDuplicate.RecordCount>
			<!--- DUPLICATE USER --->
			<cfset stResult = createObject("component", application.formtools["field"].packagePath).failed(value="#arguments.stFieldPost.value#", message="The userid you have selected is already taken.") />
		</cfif>
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

	<cffunction name="ftCheckOldPassword" access="public" output="false" returntype="struct" hint="Validate the previous value of the password">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var oClientUD = application.security.userdirectories.CLIENTUD />
		<cfset var oField = createObject("component", application.formtools["field"].packagePath) />
		<cfset var st = getData(objectid=arguments.objectid) />
		<cfset var stResult = "" />
		
		<cfif oClientUD.bEncrypted>
			<!--- Password hash check --->
			<cfif application.security.cryptlib.passwordMatchesHash(password=arguments.stFieldPost.value,hashedPassword=st.password)>
				<cfset stResult = oField.passed(value=arguments.stFieldPost.value) />
			<cfelse>
				<cfset stResult = oField.failed(value="", message="The current password you entered was incorrect") />
			</cfif>
		<cfelse>
			<!--- Case-sensitive string compare --->
			<cfif not Compare(arguments.stFieldPost.value,st.password)>
				<cfset stResult = oField.passed(value=arguments.stFieldPost.value) />
			<cfelse>
				<cfset stResult = oField.failed(value="", message="The current password you entered was incorrect") />
			</cfif>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="ftCheckPasswordPolicy" access="public" output="true" returntype="struct" hint="Validate the new value of the password">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var st = getData(objectid=arguments.objectid) />
		<cfset var stResult = "" />
		<cfset var oField = createObject("component", application.formtools["field"].packagePath) />
		<cfset var oSecurityConfig = "">
		<cfset var regex = "">
		<cfset var passwordStrengthHint = "">
		<cfparam name="arguments.stMetadata.ftPasswordStrengthHelp" default="">


		<!--- get the password policy regex/help from the component metadata, else the security config --->
		<cfif structKeyExists(arguments.stMetadata, "ftPasswordStrengthRegex") AND len(arguments.stMetadata.ftPasswordStrengthRegex)>
			<cfset regex = arguments.stMetadata.ftPasswordStrengthRegex>
			<cfset passwordStrengthHint = arguments.stMetadata.ftPasswordStrengthHelp>
		<cfelseif application.fapi.getConfig("security","passwordMinLength",0) gt 0>
			<cfset oSecurityConfig = application.fapi.getContentType(typename="configSecurity")>
			<cfset regex = oSecurityConfig.getPasswordPolicyRegex()>
			<cfset passwordStrengthHint = application.fapi.getConfig("security","passwordPolicyHint")>
		</cfif>
		
		<!--- check password strength if we have a password policy regex --->
		<cfif len(regex) AND NOT REFind(regex,arguments.stFieldPost.value)>
			<cfset stResult = oField.failed(value=arguments.stFieldPost.value, message="Your new password does not meet the minimum required password strength. #passwordStrengthHint#") />
		<cfelse>
			<cfset stResult = oField.passed(value=arguments.stFieldPost.value) />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="addLoginFailure" access="public" output="false" returntype="numeric" hint="Adds information about a login failure to a user record">
		<cfargument name="objectID" type="uuid" required="false" />
		<cfargument name="userID" type="string" required="false" />
		<cfargument name="reason" type="string" required="true" />

		<cfset var stObject = "" />
		<cfset var aFailures = arraynew(1) />
		<cfset var stFailure = structnew() />
		<cfset var dateTolerance = DateAdd("n",0-application.fapi.getConfig("general","loginAttemptsTimeOut"),Now()) />
		
		<cfif structkeyexists(arguments,"objectID")>
			<cfset stObject = getData(arguments.objectID) />
		<cfelse>
			<cfset stObject = getByUserID(arguments.userID) />
		</cfif>

		<cfif not structisempty(stObject)>
	        <cfif isJSON(stObject.failedLogins)>
		        <cfset aFailures = deserializeJSON(stObject.failedLogins) />
	        </cfif>

			<!--- remove redundant failures --->
			<cfloop condition="arraylen(aFailures) and aFailures[1].timestamp lt dateTolerance or arraylen(aFailures) gt application.fapi.getConfig('general','loginAttemptsAllowed')">
				<cfset arraydeleteat(aFailures,1) />
			</cfloop>

			<!--- add new failure --->
			<cfset stFailure["timestamp"] = now() />
			<cfset stFailure["reason"] = arguments.reason />
			<cfset arrayappend(aFailures,stFailure) />

			<cfset stObject.failedLogins = serializeJSON(aFailures) />
			<cfset setData(stProperties=stObject) />
		</cfif>

		<cfreturn arraylen(aFailures) />
	</cffunction>

	<cffunction name="resetLoginFailures" access="public" output="false" returntype="void" hint="Resets the login failures recorded">
		<cfargument name="objectID" type="uuid" required="true" />

		<cfset var stObject = "" />

		<cfif structkeyexists(arguments,"objectID")>
			<cfset stObject = getData(arguments.objectID) />
		<cfelse>
			<cfset stObject = getByUserID(arguments.userID) />
		</cfif>

		<cfif not structisempty(stObject)>
			<cfset stObject.loginFailures = "[]" />

			<cfset setData(stProperties=stObject) />
		</cfif>
	</cffunction>

</cfcomponent>