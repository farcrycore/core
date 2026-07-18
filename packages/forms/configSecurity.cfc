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

	<!--- Multi-factor authentication --->

	<cfproperty name="mfaEncryptKey" type="string" default="" required="false"
		ftSeq="39" ftFieldset="Multi-factor Authentication" ftLabel="Encryption key"
		ftType="string"
		ftHint="The AES key that protects stored MFA secrets. Set only via the FARCRY_CONFIG_SECURITY_MFAENCRYPTKEY environment variable; it is shown here as status only and cannot be entered or stored through the webtop.">

	<cfproperty name="mfaMode" type="string" default="off"
		ftSeq="40" ftFieldset="Multi-factor Authentication" ftLabel="MFA mode"
		ftType="list" ftList="off:Off,optional:Optional (users may enrol),required:Required for all users"
		ftHint="Governs multi-factor authentication for any user directory that supports it (the built-in username/password directory does; IdP-backed directories delegate MFA to their provider and ignore this). Off disables it entirely; Optional lets users enrol a second factor themselves; Required forces enrolment at next login. The encryption key (above) must be set before enabling.">

	<cfproperty name="mfaRequiredRoles" type="string" default=""
		ftSeq="41" ftFieldset="Multi-factor Authentication" ftLabel="Roles requiring MFA"
		ftType="list" ftListData="listMFARoles" ftSelectMultiple="true"
		ftHint="Users holding any of these roles must use MFA even when the mode is Optional. Roles are directory-agnostic, so this applies to every credential-owning user directory. Ignored when the mode is Off or Required.">

	<cfproperty name="mfaIssuer" type="string" default=""
		ftSeq="42" ftFieldset="Multi-factor Authentication" ftLabel="Issuer label"
		ftType="string"
		ftHint="The label shown in users' authenticator apps. Leave blank to use the site title, with the environment label appended outside production so staging and development entries stay distinct from production.">

	<cfproperty name="mfaRpId" type="string" default=""
		ftSeq="43" ftFieldset="Multi-factor Authentication" ftLabel="Passkey relying party ID"
		ftType="string"
		ftHint="The domain passkeys are bound to (an effective domain, e.g. example.gov.au). Leave blank to use the request host. Set a shared parent domain to let one passkey work across sub-domains (dev., staging., www.). A passkey enrolled under one value will not verify under another, so changing this invalidates existing passkeys.">

	<cfproperty name="mfaRpName" type="string" default=""
		ftSeq="44" ftFieldset="Multi-factor Authentication" ftLabel="Passkey display name"
		ftType="string"
		ftHint="The site name shown in the browser and operating system passkey prompt. Leave blank to use the issuer label above (the site title).">

	<cfproperty name="mfaOrigin" type="string" default=""
		ftSeq="45" ftFieldset="Multi-factor Authentication" ftLabel="Passkey allowed origin(s)"
		ftType="string"
		ftHint="The https origin(s) passkey ceremonies are accepted from, comma separated (e.g. https://www.example.gov.au). Leave blank to derive https://[request host]. Set this only when the request host is not the browser-facing address (some reverse-proxy setups).">

	<cfproperty name="mfaPasskeyUserVerification" type="string" default="preferred"
		ftSeq="46" ftFieldset="Multi-factor Authentication" ftLabel="Passkey user verification (second factor)"
		ftType="list" ftList="discouraged:Touch only (no PIN or biometric),preferred:Verify when the device offers it (default),required:Always require a PIN or biometric"
		ftHint="How hard a passkey verifies the user when it is a second factor (behind a password). 'Touch only' matches the typical security-key experience: a roaming key like a YubiKey needs only a tap, no PIN, because the password is the other factor. 'Verify when offered' uses the device PIN or biometric if it has one. 'Always require' insists on it. Platform authenticators (Windows Hello, Touch ID, Android) always verify regardless of this setting. This does NOT apply when a passkey is the primary sign-in method (passwordless): user verification is always required there.">

	<cfproperty name="mfaChallengeTimeout" type="integer" ftType="integer" default="10"
		ftSeq="47" ftFieldset="Multi-factor Authentication" ftLabel="Challenge timeout (minutes)"
		ftHint="How long a pending second factor challenge remains valid before the user must log in again.">

	<cfproperty name="mfaEncryptKeyId" type="string" default="1" required="false"
		ftSeq="48" ftFieldset="Multi-factor Authentication" ftLabel="Encryption key id"
		ftType="string"
		ftHint="Identifier stamped into newly sealed MFA secrets so the right key can be found again later. Set via FARCRY_CONFIG_SECURITY_MFAENCRYPTKEYID alongside the key, and bump it (e.g. 1 to 2) each time you rotate the encryption key. Alphanumeric; defaults to 1.">

	<cfproperty name="mfaEncryptKeysOld" type="string" default="" required="false"
		ftSeq="49" ftFieldset="Multi-factor Authentication" ftLabel="Retired encryption keys"
		ftType="string"
		ftHint="Previous encryption keys kept only so secrets sealed under them can still be decrypted during a rotation, given as id:base64key pairs (comma separated). Set only via the FARCRY_CONFIG_SECURITY_MFAENCRYPTKEYSOLD environment variable; it is shown here as a count only and cannot be entered or stored through the webtop. Remove a key here once no stored secret still uses it.">

	<cfproperty name="mfaEmailOTP" type="string" default="off"
		ftSeq="50" ftFieldset="Multi-factor Authentication" ftLabel="Email one-time-code factor"
		ftType="list" ftList="off:Off,soleFactor:On - only as a sole factor,anyFactor:On - allowed with a stronger factor"
		ftHint="Whether users may use a one-time code emailed to them as a second factor. Email is the weakest factor - its security is only as strong as the user's mailbox - so it is off by default and best reserved for users who cannot use an authenticator app or passkey. 'Only as a sole factor' offers email only to a user who has no stronger factor, keeping a strong factor strong. 'Allowed with a stronger factor' is a deliberate downgrade: an attacker who has the password and the mailbox can then bypass a stronger factor by choosing email, so enable it only where that trade-off is acceptable.">

	<cfproperty name="mfaEmailResendSeconds" type="integer" ftType="integer" default="60"
		ftSeq="51" ftFieldset="Multi-factor Authentication" ftLabel="Email code resend interval (seconds)"
		ftHint="Minimum seconds between emailed one-time codes for a single login, to throttle resends. Default 60.">

	<cfproperty name="mfaGraceUntil" type="string" default=""
		ftSeq="52" ftFieldset="Multi-factor Authentication" ftLabel="Enrolment grace period until"
		ftType="string"
		ftHint="Optional date (yyyy-mm-dd). While it is set to a future date, a user who is required to use MFA but has not yet enrolled is prompted to set it up but may skip and continue; on and after the date, enrolment is enforced. Blank enforces enrolment immediately. Applies wherever MFA is mandatory (Required mode, or a role in the list above); already-enrolled users are always challenged regardless.">


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

	<!--- render the encryption key as read-only status only - never an input, never the value - so it stays env-only and out of the DB --->
	<cffunction name="ftEditMfaEncryptKey" access="public" returntype="string" output="false" hint="Render the encryption key field (edit context) as a read-only status">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#" />
		<cfargument name="stMetadata" type="struct" required="false" default="#structNew()#" />
		<cfargument name="fieldname" type="string" required="false" default="" />

		<cfreturn mfaEncryptKeyStatusHTML() />
	</cffunction>

	<cffunction name="ftDisplayMfaEncryptKey" access="public" returntype="string" output="false" hint="Render the encryption key field (display context, e.g. when provided read-only via the environment) as a read-only status">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#" />
		<cfargument name="stMetadata" type="struct" required="false" default="#structNew()#" />
		<cfargument name="fieldname" type="string" required="false" default="" />

		<cfreturn mfaEncryptKeyStatusHTML() />
	</cffunction>

	<cffunction name="mfaEncryptKeyStatusHTML" access="private" returntype="string" output="false" hint="Configured / Not set indicator for the MFA encryption key; never renders the value">
		<cfset var html = "" />
		<cfset var bConfigured = createObject("component", application.factory.oUtils.getPath("security", "mfaCrypto")).init().isKeyConfigured() />

		<cfsavecontent variable="html">
			<cfoutput>
				<cfif bConfigured>
					<span class="label label-success">Configured</span>
					<span class="help-inline">The MFA encryption key is present in the environment.</span>
				<cfelse>
					<span class="label label-important">Not set</span>
					<span class="help-inline">Set <code>FARCRY_CONFIG_SECURITY_MFAENCRYPTKEY</code> to a base64-encoded 128, 192 or 256-bit key. Multi-factor authentication cannot be enabled until this is present.</span>
				</cfif>
			</cfoutput>
		</cfsavecontent>

		<cfreturn html />
	</cffunction>

	<!--- retired keys are secret material too: render count-only status, never an input, never the values --->
	<cffunction name="ftEditMfaEncryptKeysOld" access="public" returntype="string" output="false" hint="Render the retired-keys field (edit context) as a read-only count">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#" />
		<cfargument name="stMetadata" type="struct" required="false" default="#structNew()#" />
		<cfargument name="fieldname" type="string" required="false" default="" />

		<cfreturn mfaEncryptKeysOldStatusHTML() />
	</cffunction>

	<cffunction name="ftDisplayMfaEncryptKeysOld" access="public" returntype="string" output="false" hint="Render the retired-keys field (display context) as a read-only count">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#" />
		<cfargument name="stMetadata" type="struct" required="false" default="#structNew()#" />
		<cfargument name="fieldname" type="string" required="false" default="" />

		<cfreturn mfaEncryptKeysOldStatusHTML() />
	</cffunction>

	<cffunction name="mfaEncryptKeysOldStatusHTML" access="private" returntype="string" output="false" hint="Count-only indicator for retired (old) MFA keys held for a rotation; never renders the values">
		<cfset var html = "" />
		<cfset var raw = application.fapi.getConfig("security", "mfaEncryptKeysOld", "") />
		<cfset var pair = "" />
		<cfset var n = 0 />
		<cfset var label = "" />

		<cfloop list="#raw#" index="pair" delimiters=",">
			<!--- count only structurally valid pairs (non-empty alphanumeric id + non-empty value), matching how getKeySet parses them --->
			<cfif find(":", pair) and len(reReplace(trim(listFirst(pair, ":")), "[^A-Za-z0-9]", "", "all")) and len(trim(listRest(pair, ":")))>
				<cfset n = n + 1 />
			</cfif>
		</cfloop>

		<cfset label = n & " retained " & (n eq 1 ? "key" : "keys") />

		<cfsavecontent variable="html">
			<cfoutput>
				<cfif n gt 0>
					<span class="label label-info">#label#</span>
					<span class="help-inline">Old keys retained so secrets sealed under them can still be decrypted. Stored secrets re-wrap to the current key as users sign in; remove a key here once none still use it.</span>
				<cfelse>
					<span class="label">None</span>
					<span class="help-inline">No retired keys. To rotate, set the new key as <code>FARCRY_CONFIG_SECURITY_MFAENCRYPTKEY</code>, bump <code>FARCRY_CONFIG_SECURITY_MFAENCRYPTKEYID</code>, and list the previous key here as <code>oldid:base64key</code> via <code>FARCRY_CONFIG_SECURITY_MFAENCRYPTKEYSOLD</code>.</span>
				</cfif>
			</cfoutput>
		</cfsavecontent>

		<cfreturn html />
	</cffunction>

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