<cfcomponent displayname="Security Configuration" extends="farcry.core.packages.forms.forms" key="security"
	hint="Security configuration settings for the web application." output="false">

	<!--- Directories and storage --->
	
	<cfproperty name="defaultUserDirectory" type="string" ftType="list" ftListData="listUserDirectories"
		ftSeq="1" ftFieldset="Directories and Storage" ftLabel="Default user directory"
		ftHint="" hint="User directory selected by default when multiple are available">

	<cfproperty name="passwordHashAlgorithm" type="string" default="bcrypt" ftType="list" ftListData="listHashAlgorithms"
		ftSeq="2" ftFieldset="Directories and Storage" ftLabel="Password hashing algorithm"
		ftHint="" hint="Algorithm used to encrypt passwords in the database">

	<!--- Errors and Debugging --->
	
	<cfproperty name="urlDebug" type="string" default="boolean" required="false"
		ftSeq="3" ftFieldset="Errors and Debugging" ftLabel="URL Debug Option"
		ftType="list" ftList="disable:Disabled,updateappkey:Allowed using Updateapp Key,boolean:Allowed using boolean"
		ftHint="Disabled turns off URL debugging, Requires Updateapp Key enables debugging with ?debug=yourupdateappkey, Allowed (default) enables debugging with ?debug=1">

	<!--- Form security --->

	<cfproperty name="bCSRFTokens" type="boolean" ftType="boolean" default="1" 
		ftSeq="5" ftFieldset="Form Security" ftLabel="Enable CSRF Tokens on forms"
		ftHint="Check this box to enable CSRF token generation/validation on all forms by default">

	<!--- Password policy --->
	
	<cfproperty name="passwordMinLength" type="integer" ftType="integer" default="6" ftValidation="required"
		ftSeq="10" ftFieldset="Password Policy" ftLabel="Minimum Password Length"
		ftHint="Set the minimum number of number characters required for a password. Choose 0 for no minimum length.">

	<cfproperty name="bIncludeLetters" type="boolean" ftType="boolean" default="0" 
		ftSeq="11" ftFieldset="Password Policy" ftLabel="Must include alphabetic characters"
		ftHint="">

	<cfproperty name="bIncludeMixedCase" type="boolean" ftType="boolean" default="0" 
		ftSeq="12" ftFieldset="Password Policy" ftLabel="Must include mix of UPPER and lower case letters"
		ftHint="">

	<cfproperty name="bIncludeNumeric" type="boolean" ftType="boolean" default="0" 
		ftSeq="13" ftFieldset="Password Policy" ftLabel="Must include Numeric characters"
		ftHint="">

	<cfproperty name="bIncludeSymbol" type="boolean" ftType="boolean" default="0" 
		ftSeq="14" ftFieldset="Password Policy" ftLabel="Must include Punctuation or Symbol characters"
		ftHint="">

	<cfproperty name="passwordPolicyHint" type="string" ftType="longchar" default="Minimum password length of 6 characters."
		ftSeq="30" ftFieldset="Password Policy" ftLabel="Password Policy Help Text" ftLimit="250"
		ftHint="Provide a short description of the password policy defined above.">

	<!--- Multi-factor authentication (see docs/0014) --->

	<cfproperty name="mfaMode" type="string" default="off"
		ftSeq="40" ftFieldset="Multi-factor Authentication" ftLabel="MFA mode"
		ftType="list" ftList="off:Off,optional:Optional (users may enrol),required:Required for all users"
		ftHint="Applies to the built-in user directory (CLIENTUD). Off disables multi-factor authentication entirely. Optional lets users enrol an authenticator app themselves; Required forces enrolment at next login. The FARCRY_MFA_ENCRYPTKEY environment variable must be set before enabling.">

	<cfproperty name="mfaRequiredRoles" type="string" default=""
		ftSeq="41" ftFieldset="Multi-factor Authentication" ftLabel="Roles requiring MFA"
		ftType="list" ftListData="listMFARoles" ftSelectMultiple="true"
		ftHint="Users holding any of these roles must use MFA even when the mode is Optional. Roles are directory-agnostic, so this applies to every credential-owning user directory. Ignored when the mode is Off or Required.">

	<cfproperty name="mfaIssuer" type="string" default=""
		ftSeq="42" ftFieldset="Multi-factor Authentication" ftLabel="Issuer label"
		ftType="string"
		ftHint="The label shown in users' authenticator apps. Leave blank to use the site title, qualified with the environment label outside production (e.g. 'buy NSW Development').">

	<cfproperty name="mfaChallengeTimeout" type="integer" ftType="integer" default="10"
		ftSeq="43" ftFieldset="Multi-factor Authentication" ftLabel="Challenge timeout (minutes)"
		ftHint="How long a pending second factor challenge remains valid before the user must log in again.">


	<!--- Directories and storage methods --->
	
	<cffunction name="listUserDirectories" access="public" returntype="query" description="Returns the available user directories" output="false">
		<cfset var qUD = querynew("name,value") />
		<cfset var thisud = "" />
		
		<cfset queryaddrow(qUD) />
		<cfset querysetcell(qUD,"value","") />
		<cfset querysetcell(qUD,"name","First Enabled Directory") />
		
		<cfloop list="#application.security.getAllUD()#" index="thisud">
			<cfset queryaddrow(qUD) />
			<cfset querysetcell(qUD,"value",thisud) />
			<cfset querysetcell(qUD,"name",application.security.userdirectories[thisud].title) />
		</cfloop>
		
		<cfreturn qUD />
	</cffunction>

	<cffunction name="listHashAlgorithms" access="public" returntype="query" description="Returns the available password hash algorithms" output="false">
		<cfset var qPwdHash = querynew("name,value") />
		<cfset var aPwdHashes = application.security.cryptlib.getOrderedHashArray() />
		<cfset var pwdHashCount = arrayLen(aPwdHashes) />
		<cfset var i = "" />
		<cfset var oPwdHash = "" />
		
		<cfloop index="i" from="1" to="#pwdHashCount#">
			<cfset oPwdHash = aPwdHashes[i] />
			<cfset queryaddrow(qPwdHash) />
			<cfset querysetcell(qPwdHash,"value",oPwdHash.alias) />
			<cfset querysetcell(qPwdHash,"name",oPwdHash.title) />
		</cfloop>
		
		<cfreturn qPwdHash />
	</cffunction>

	<!--- Multi-factor authentication methods --->

	<cffunction name="listMFARoles" access="public" returntype="query" description="Returns the roles that can be required to use MFA (directory-agnostic; stored by objectid)" output="false">
		<cfset var qRoles = querynew("name,value") />
		<cfset var qFarRole = "" />

		<cfquery datasource="#application.dsn#" name="qFarRole">
			SELECT objectid, title
			FROM #application.dbowner#farRole
			ORDER BY title
		</cfquery>

		<cfloop query="qFarRole">
			<cfset queryaddrow(qRoles) />
			<cfset querysetcell(qRoles, "value", qFarRole.objectid) />
			<cfset querysetcell(qRoles, "name", qFarRole.title) />
		</cfloop>

		<cfreturn qRoles />
	</cffunction>

	<!--- Password policy methods --->
	
	<cffunction name="getPasswordPolicyRegex" returntype="string"
		hint="Returns a regular expression which can be used to test a password for meeting the required password policy">

		<cfset var regex = "^.*">

		<cfif int(application.fapi.getConfig("security","passwordMinLength")) gt 0>
			<cfset regex = regex & "(?=.{#application.fapi.getConfig("security","passwordMinLength")#})">
		</cfif>
		<cfif application.fapi.getConfig("security","bIncludeLetters")>
			<cfset regex = regex & "(?=.*[[:alpha:]])">
		</cfif>
		<cfif application.fapi.getConfig("security","bIncludeMixedCase")>
			<cfset regex = regex & "(?=.*[a-z])(?=.*[A-Z])">
		</cfif>
		<cfif application.fapi.getConfig("security","bIncludeNumeric")>
			<cfset regex = regex & "(?=.*[0-9])">
		</cfif>
		<cfif application.fapi.getConfig("security","bIncludeSymbol")>
			<cfset regex = regex & "(?=.*[^a-zA-Z-0-9])">
		</cfif>

		<cfset regex = regex & ".*$">
		
		<cfreturn regex>
	</cffunction>

</cfcomponent>