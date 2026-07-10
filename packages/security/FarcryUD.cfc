<cfcomponent displayname="FarCry User Directory" hint="Provides the interface for the FarCry user directory" extends="UserDirectory" output="false"
			key="CLIENTUD" bEncrypted="true" standardHash="none">
	
	<cffunction name="init" access="public" output="true" returntype="any" hint="Does initialisation of user directory">

		<cfset super.init() />

		<cfif not structKeyExists(this,"standardHash")>
			<cfset this.standardHash = application.security.cryptlib.getDefaultHashName() />
		</cfif>

		<cfset variables.oMFACrypto = createObject("component", application.factory.oUtils.getPath("security", "mfaCrypto")).init() />

		<cfreturn this />
	</cffunction>

	<cffunction name="getOutputHashName" access="public" returntype="string" output="false" hint="Return the name of the hash used to encoded passwords">

		<cfif application.security.cryptlib.isHashAlgorithmSupported(application.fapi.getConfig("security","passwordHashAlgorithm","na"))>
			<cfreturn application.fapi.getConfig("security","passwordHashAlgorithm") />
		<cfelse>
			<cfreturn this.standardHash />
		</cfif>
	</cffunction>
	
	<cffunction name="passwordIsStale" access="public" output="false" returntype="boolean" hint="Returns true if the password needs to be hashed">
		<cfargument name="hashedPassword" type="string" required="true" hint="Hashed password" />
		<cfargument name="password" type="string" required="true" hint="Source password" />
		
		<cfset var hashName = getOutputHashName() />

		<cfreturn application.security.cryptlib.hashedPasswordIsStale(hashedPassword=arguments.hashedPassword,password=arguments.password,hashname=hashName) />
	</cffunction>

	<cffunction name="queryUserPassword" access="private" output="false" returntype="query" hint="Return a query of farUser rows that match the provided credentials">
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfset var qUser = "" />
		<cfset var authenticatedObjectId = "" />
		<cfset var hashName = getOutputHashName() />
		
		<!--- Find the user --->
		<cfquery datasource="#application.dsn#" name="qUser">
			select	objectid,userid,password,userstatus,failedLogins
			from	#application.dbowner#farUser
			where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.username)#" />
		</cfquery>
		
		<!--- Try to match the entered password against the users in the DB --->
		<cfloop query="qUser">
			<cfif application.security.cryptlib.passwordMatchesHash(password=arguments.password,hashedPassword=qUser.password)>
				<cfset authenticatedObjectId = qUser.objectid />
				<cfbreak />
			</cfif>
		</cfloop>
		
		<cfif Len(authenticatedObjectId)>
			<!--- Return the row with the password match --->
			<cfquery dbtype="query" name="qUser">
				select *
				from qUser
				where objectid = '#authenticatedObjectId#'
			</cfquery>

			<!--- Does the hashed password need to be updated? --->
			<cfif passwordIsStale(hashedPassword=qUser.password,password=arguments.password)>
				<cfquery datasource="#application.dsn#">
					update	#application.dbowner#farUser
					set		password=<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.security.cryptlib.encodePassword(password=arguments.password,hashname=hashName)#" />
					where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#authenticatedObjectId#" />
				</cfquery>
			</cfif>
		<cfelse>
			<!--- Delete all rows from the query --->
			<cfquery dbtype="query" name="qUser">
				select *
				from qUser
				where 0 = 1
			</cfquery>
		</cfif>
		
		<cfreturn qUser />
	</cffunction>
	

	<cffunction name="getUserAccountStatus" access="private" output="false" returntype="struct" hint="Return a struct representing the status of the user account">
		<cfargument name="username" type="string" required="true">
		<cfargument name="qUser" required="false">
		
		<cfset var stResult = structNew()>
		<cfset var qUserRecord = "">
		<cfset var failedLogins = arraynew(1)>
		<cfset var i = 0>
		<cfset var failureCount = 0>

		<cfset var dateTolerance = DateAdd("n","-#application.fapi.getConfig("general","loginAttemptsTimeOut")#",Now())>

		<cfset stResult["objectid"] = "">
		<cfset stResult["userid"] = trim(arguments.username)>
		<cfset stResult["userstatus"] = "active">
		<cfset stResult["locked"] = false>

		<!--- look up the user by userid if arguments.qUser is empty --->
		<cfif isQuery(arguments.qUser) AND arguments.qUser.recordcount gt 0>
			<cfset qUserRecord = arguments.qUser>
		<cfelse>
			<cfquery datasource="#application.dsn#" name="qUserRecord">
				SELECT objectid, userid, userstatus, failedLogins
				FROM #application.dbowner#farUser
				WHERE userid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.username)#">
			</cfquery>
		</cfif>

		<cfif qUserRecord.recordcount>
			<cfset stResult["objectid"] = qUserRecord.objectid>
			<cfset stResult["userid"] = qUserRecord.userid>
			<cfset stResult["userstatus"] = qUserRecord.userstatus>

			<!--- count failed logins --->
			<cfif isJSON(qUserRecord.failedLogins)>
				<cfset failedLogins = deserializeJSON(qUserRecord.failedLogins)>
			</cfif>
			<cfloop from="1" to="#arraylen(failedLogins)#" index="i">
				<cfif failedLogins[i].timestamp gte dateTolerance>
					<cfset failureCount = failureCount + 1>
				</cfif>
			</cfloop>

			<cfif failureCount gte application.fapi.getConfig("general","loginAttemptsAllowed")>
				<cfset stResult["locked"] = true>
			</cfif>
		</cfif>

		<cfreturn stResult>
	</cffunction>


	<!--- ====================
	  UD Interface functions
	===================== --->
	<cffunction name="getLoginForm" access="public" output="false" returntype="string" hint="Returns the form component to use for login">
		
		<cfreturn "farLogin" />
	</cffunction>
	
	<cffunction name="authenticate" access="public" output="false" returntype="struct" hint="Attempts to process a user. Runs every time the login form is loaded.">
		<cfset var stResult = structnew() />
		<cfset var stProperties = structnew() />
		<cfset var qUser = "" />
		<cfset var stUserAccountStatus = structnew() />

		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

		<!--- For backward compatability, check for userlogin and password in form. This should be removed once we're willing to not support pre 4.1 login templates --->
		<cfif structkeyexists(form,"userlogin") and structkeyexists(form,"password")>
			<cfset qUser = queryUserPassword(form.userlogin,form.password) />
			<cfset stResult.userid = trim(form.userlogin) />
		<cfelse>
			<ft:processform>
				<ft:processformObjects typename="#getLoginForm()#">
					<cfset qUser = queryUserPassword(stProperties.username,stProperties.password) />
					<cfset stResult.userid = trim(stProperties.username) />
					<!--- discard form object from session --->
					<ft:break>
				</ft:processformObjects>
			</ft:processform>
		</cfif>

		<!--- If (somehow) a login was submitted, process the result --->
		<cfif structKeyExists(stResult, "userid") AND len(stResult.userid)>
			
			<!--- Return struct --->
			<cfset stResult.authenticated = false />
			<cfset stResult.message = "" />
			<cfset stResult.UD = "CLIENTUD" />

			<cfset stUserAccountStatus = getUserAccountStatus(stResult.userid, qUser)>
			
			<!--- Set the result --->
			<cfif stUserAccountStatus.locked>
				<!--- User is locked out due to high number of failed logins recently --->
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "Your account has been locked due to a high number of failed logins. It will be unlocked automatically in #application.fapi.getConfig("general","loginAttemptsTimeOut")# minutes." />
				<cfset application.fapi.getContentType("farUser").addLoginFailure(objectid=stUserAccountStatus.objectid,reason="Locked account due to failed logins") />
					<cfset stResult.reason = "accountLocked" />
			<cfelseif stUserAccountStatus.userstatus neq "active">
				<!--- User's account is disabled --->
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "Your account is disabled" />
					<cfset stResult.reason = "accountDisabled" />
			<cfelseif qUser.recordcount and qUser.userstatus eq "active">
				<!--- User successfully logged in --->
				<cfset stResult.authenticated = true />

				<cfif qUser.failedLogins neq "[]">
					<cfset application.fapi.getContentType("farUser").resetLoginFailures(objectid=qUser.objectid) />
				</cfif>
			<cfelse>
				<!--- User login or password is incorrect --->
				<cfset stResult.authenticated = false />
				<cfset stResult.message = "The username or password was incorrect">
				<cfset application.fapi.getContentType("farUser").addLoginFailure(userid=stResult.userid,reason="Incorrect password") />
					<cfset stResult.reason = "badCredentials" />
			</cfif>
		
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getUserGroups" access="public" output="false" returntype="array" hint="Returns the groups that the specified user is a member of">
		<cfargument name="UserID" type="string" required="true" hint="The user being queried" />
		
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select	g.title
			from	
						#application.dbowner#farUser u
						inner join
						#application.dbowner#farUser_aGroups ug
						on u.objectid=ug.parentid
					
					inner join
					#application.dbowner#farGroup g
					on ug.data=g.objectid
			where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#" />
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title) />
		</cfloop>
		
		<cfreturn aGroups />
	</cffunction>
	
	<cffunction name="getAllGroups" access="public" output="false" returntype="array" hint="Returns all the groups that this user directory supports">
		<cfset var qGroups = "" />
		<cfset var aGroups = arraynew(1) />
		
		<cfquery datasource="#application.dsn#" name="qGroups">
			select		*
			from		#application.dbowner#farGroup
			order by	title
		</cfquery>
		
		<cfloop query="qGroups">
			<cfset arrayappend(aGroups,title) />
		</cfloop>

		<cfreturn aGroups />
	</cffunction>

	<cffunction name="getGroupUsers" access="public" output="false" returntype="array" hint="Returns all the users in a specified group">
		<cfargument name="group" type="string" required="true" hint="The group to query" />
		
		<cfset var qUsers = "" />
		
		<cfquery datasource="#application.dsn#" name="qUsers">
			select	userid
			from	(
						#application.dbowner#farUser u
						inner join
						#application.dbowner#farUser_aGroups ug
						on u.objectid=ug.parentid
					)
					inner join
					#application.dbowner#farGroup g
					on ug.data=g.objectid
			where	g.title=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group#" />
					and u.userstatus=<cfqueryparam cfsqltype="cf_sql_varchar" value="active" />
		</cfquery>
		
		<cfreturn listtoarray(valuelist(qUsers.userid)) />
	</cffunction>
	
	<!--- =============================
	  MFA contract + engine (see docs/0014)
	============================== --->

	<cffunction name="providesMFA" access="public" output="false" returntype="boolean" hint="CLIENTUD can perform second factor verification">

		<cfreturn true />
	</cffunction>

	<cffunction name="requiresMFA" access="public" output="false" returntype="boolean" hint="True when this user must complete a second factor step before login">
		<cfargument name="userid" type="string" required="true" />

		<cfset var mode = getMFAMode() />
		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var lRequiredRoles = application.fapi.getConfig("security", "mfaRequiredRoles", "") />
		<cfset var lUserRoles = "" />
		<cfset var roleID = "" />

		<cfif mode eq "off" or not len(userKey)>
			<cfreturn false />
		</cfif>

		<cfif mode eq "required">
			<cfreturn true />
		</cfif>

		<!--- optional mode: challenge the already-enrolled, and anyone holding a required role --->
		<cfif getFactorType().hasActiveAuthFactor(userKey=userKey, userDirectory=this.key)>
			<cfreturn true />
		</cfif>

		<cfif len(lRequiredRoles)>
			<cfset lUserRoles = getUserRoleIDs(arguments.userid) />
			<cfloop list="#lRequiredRoles#" index="roleID">
				<cfif listFindNoCase(lUserRoles, roleID)>
					<cfreturn true />
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn false />
	</cffunction>

	<cffunction name="getMFAForm" access="public" output="false" returntype="string" hint="Challenge form when enrolled, enrolment wizard when not (or while the post-enrolment recovery codes are still being shown)">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stContext = getEnrolContext() />

		<!--- keep the enrolment view up while the just-issued recovery codes are displayed --->
		<cfif structKeyExists(stContext, "bRecoveryShown") and stContext.bRecoveryShown>
			<cfreturn "farMFAEnrol" />
		</cfif>

		<cfif getFactorType().hasActiveAuthFactor(userKey=getUserKey(arguments.userid), userDirectory=this.key)>
			<cfreturn "farMFAChallenge" />
		</cfif>

		<cfreturn "farMFAEnrol" />
	</cffunction>

	<cffunction name="issueMFAChallenge" access="public" output="false" returntype="struct" hint="TOTP has nothing to push; returns an empty context">
		<cfargument name="userid" type="string" required="true" />

		<cfreturn structnew() />
	</cffunction>

	<cffunction name="verifyMFA" access="public" output="false" returntype="struct" hint="Processes the interstitial post: challenge code, recovery code, enrolment confirmation or the post-enrolment acknowledgment">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = { verified = false, reason = "noSubmission", message = "", method = "" } />
		<cfset var stProperties = structnew() />
		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var stContext = getEnrolContext() />
		<cfset var stEnrol = structnew() />

		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

		<cfif not len(userKey)>
			<cfset stResult.reason = "userNotFound" />
			<cfset stResult.message = "Unable to verify your login. Please log in again." />
			<cfreturn stResult />
		</cfif>

		<!--- display sub-step: the factor is active and we are showing the one-time recovery codes.
		      Driven by persisted context (not transient POST data) so a refresh re-shows the codes
		      with the ack button rather than stranding the user. Only the ack advances; a re-POST of
		      the confirm form is ignored here (no duplicate enrolment, no burnt attempt). --->
		<cfif structKeyExists(stContext, "bRecoveryShown") and stContext.bRecoveryShown>
			<ft:processform action="mfaRecoveryAck">
				<cfset structDelete(stContext, "bRecoveryShown") />
				<cfset structDelete(stContext, "aRecoveryCodes") />
				<cfset stResult.verified = true />
				<cfset stResult.reason = "" />
				<cfset stResult.method = "totp" />
			</ft:processform>

			<cfif not stResult.verified>
				<!--- still on the display step: re-surface the codes from persisted state --->
				<cfset stResult.reason = "recoveryCodes" />
				<cfset stResult.bShowRecovery = true />
				<cfset stResult.aRecoveryCodes = stContext.aRecoveryCodes />
			</cfif>

			<cfreturn stResult />
		</cfif>

		<!--- challenge: an authenticator code or a recovery code --->
		<ft:processform>
			<ft:processformObjects typename="farMFAChallenge" r_stProperties="stProperties">
				<cfset stResult = verifyChallengeCode(userid=arguments.userid, userKey=userKey, code=trim(stProperties.code)) />
				<ft:break>
			</ft:processformObjects>
		</ft:processform>

		<!--- enrolment confirmation: prove one valid code before the factor activates --->
		<ft:processform>
			<ft:processformObjects typename="farMFAEnrol" r_stProperties="stProperties">
				<cfset stEnrol = confirmTOTPEnrolment(userid=arguments.userid, code=trim(stProperties.code)) />
				<cfif stEnrol.bSuccess>
					<!--- persist the codes so the display step survives a refresh; cleared on ack or login --->
					<cfset stContext.bRecoveryShown = true />
					<cfset stContext.aRecoveryCodes = stEnrol.aRecoveryCodes />
					<cfset stResult.reason = "recoveryCodes" />
					<cfset stResult.bShowRecovery = true />
					<cfset stResult.aRecoveryCodes = stEnrol.aRecoveryCodes />
				<cfelse>
					<cfset stResult.reason = stEnrol.reason />
					<cfset stResult.message = stEnrol.message />
					<cfset stResult.method = "totp" />
				</cfif>
				<ft:break>
			</ft:processformObjects>
		</ft:processform>

		<cfreturn stResult />
	</cffunction>


	<!--- MFA engine: called by the contract methods above and by self-service / admin webskins --->

	<cffunction name="startTOTPEnrolment" access="public" output="false" returntype="struct" hint="Creates (or returns the in-progress) enrolment candidate and its provisioning URI">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = { bSuccess = true, message = "" } />
		<cfset var stContext = getEnrolContext() />

		<cfif not variables.oMFACrypto.isKeyConfigured()>
			<cfset application.security.logSecurityEvent(event="mfaUnavailable", level="error", message="mfa enrolment attempted without an encryption key configured", userid="#arguments.userid#_#this.key#") />
			<cfset stResult.bSuccess = false />
			<cfset stResult.message = "Multi-factor authentication is not fully configured on this site (missing encryption key). Please contact your administrator." />
			<cfreturn stResult />
		</cfif>

		<!--- keep the same candidate across re-renders so a refresh does not change the QR mid-scan --->
		<cfif not structKeyExists(stContext, "enrolSecret")>
			<cfset stContext.enrolSecret = variables.oMFACrypto.generateTOTPSecret() />
		</cfif>

		<cfset stResult.secret = stContext.enrolSecret />
		<cfset stResult.otpauthURI = variables.oMFACrypto.otpauthURI(issuer=getIssuer(), account=arguments.userid, secretB32=stContext.enrolSecret) />

		<cfreturn stResult />
	</cffunction>

	<cffunction name="confirmTOTPEnrolment" access="public" output="false" returntype="struct" hint="Verifies the confirmation code, activates the factor and issues recovery codes">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="code" type="string" required="true" />

		<cfset var stResult = { bSuccess = false, reason = "", message = "", aRecoveryCodes = arraynew(1) } />
		<cfset var stContext = getEnrolContext() />
		<cfset var stVerify = structnew() />
		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var sealed = "" />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfif not len(userKey) or not structKeyExists(stContext, "enrolSecret")>
			<cfset stResult.reason = "noCandidate" />
			<cfset stResult.message = "Your enrolment session has expired. Please start again." />
			<cfreturn stResult />
		</cfif>

		<cfset stVerify = variables.oMFACrypto.verifyTOTP(secretB32=stContext.enrolSecret, code=arguments.code) />

		<cfif not stVerify.verified>
			<!--- an enrolment typo does not feed the shared password lockout (the code derives from a secret we just showed the user; there is no credential to brute force here). The session-level attempts cap in security.cfc still applies. --->
			<cfset stResult.reason = "badCode" />
			<cfset stResult.message = "That code didn't match. Check the code in your authenticator app and try again." />
			<cfreturn stResult />
		</cfif>

		<cftry>
			<cfset sealed = variables.oMFACrypto.encryptSecret(stContext.enrolSecret) />
			<cfcatch>
				<cfset application.security.logSecurityEvent(event="mfaUnavailable", level="error", message="mfa secret encryption failed", userid="#arguments.userid#_#this.key#") />
				<cfset stResult.reason = "mfaUnavailable" />
				<cfset stResult.message = "Multi-factor authentication is not fully configured on this site. Please contact your administrator." />
				<cfreturn stResult />
			</cfcatch>
		</cftry>

		<!--- idempotent: a re-enrolment replaces the existing authenticator rather than stacking a second (dead) totp row --->
		<cfset getFactorType().removeFactors(userKey=userKey, userDirectory=this.key, factorType="totp") />
		<cfset getFactorType().createFactor(userKey=userKey, userDirectory=this.key, factorType="totp", stPayload={ secret = sealed, lastStep = stVerify.step }, label="Authenticator app") />
		<cfset stResult.aRecoveryCodes = issueRecoveryCodes(userKey=userKey) />
		<cfset structDelete(stContext, "enrolSecret") />

		<cfset application.fapi.getContentType("farUser").resetLoginFailures(objectid=userKey) />

		<cfset application.security.logSecurityEvent(event="mfaEnrolled", message="second factor enrolled", userid="#arguments.userid#_#this.key#", stFields={ method = "totp" }) />
		<farcry:logevent type="security" event="mfaEnrolled" userid="#arguments.userid#_#this.key#" notes="totp" />

		<cfset stResult.bSuccess = true />

		<cfreturn stResult />
	</cffunction>

	<cffunction name="regenerateRecoveryCodes" access="public" output="false" returntype="struct" hint="Replaces the user's recovery codes; returns the new set for one-time display">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = { bSuccess = false, aRecoveryCodes = arraynew(1) } />
		<cfset var userKey = getUserKey(arguments.userid) />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfif len(userKey)>
			<cfset stResult.aRecoveryCodes = issueRecoveryCodes(userKey=userKey) />
			<cfset stResult.bSuccess = true />

			<cfset application.security.logSecurityEvent(event="mfaEnrolled", message="recovery codes regenerated", userid="#arguments.userid#_#this.key#", stFields={ method = "recoveryCodes" }) />
			<farcry:logevent type="security" event="mfaEnrolled" userid="#arguments.userid#_#this.key#" notes="recoveryCodes" />
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="resetMFA" access="public" output="false" returntype="numeric" hint="Removes all of a user's factors (admin reset or self-service disable); returns the number removed">
		<cfargument name="userKey" type="string" required="true" hint="The farUser objectid" />
		<cfargument name="by" type="string" required="false" default="admin" hint="self / admin" />

		<cfset var count = 0 />
		<cfset var stUser = application.fapi.getContentType("farUser").getData(objectid=arguments.userKey) />
		<cfset var eventUserid = structKeyExists(stUser, "userid") ? "#stUser.userid#_#this.key#" : arguments.userKey />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfset count = getFactorType().removeFactors(userKey=arguments.userKey, userDirectory=this.key) />

		<cfif count gt 0>
			<cfset application.security.logSecurityEvent(event="mfaDisabled", message="second factor disabled", userid=eventUserid, stFields={ by = arguments.by }) />
			<farcry:logevent type="security" event="mfaDisabled" userid="#eventUserid#" notes="by #arguments.by#" />
		</cfif>

		<cfreturn count />
	</cffunction>

	<cffunction name="getMFAStatus" access="public" output="false" returntype="struct" hint="Enrolment status for self-service and admin views">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = structnew() />
		<cfset var userKey = getUserKey(arguments.userid) />

		<cfset stResult.mode = getMFAMode() />
		<cfset stResult.bEnabled = stResult.mode neq "off" />
		<cfset stResult.bKeyConfigured = variables.oMFACrypto.isKeyConfigured() />
		<cfset stResult.userKey = userKey />
		<cfset stResult.bEnrolled = len(userKey) and getFactorType().hasActiveAuthFactor(userKey=userKey, userDirectory=this.key) />
		<cfset stResult.bRequired = requiresMFA(userid=arguments.userid) />
		<cfif len(userKey)>
			<cfset stResult.qFactors = getFactorType().getFactors(userKey=userKey, userDirectory=this.key) />
		</cfif>

		<cfreturn stResult />
	</cffunction>


	<!--- MFA private helpers --->

	<cffunction name="verifyChallengeCode" access="private" output="false" returntype="struct" hint="Verifies a challenge submission: 6 digit codes against TOTP, anything else against recovery codes">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="code" type="string" required="true" />

		<cfset var stResult = { verified = false, reason = "badCode", message = "", method = "" } />
		<cfset var stFactor = structnew() />
		<cfset var stVerify = structnew() />
		<cfset var stRedeem = structnew() />
		<cfset var secret = "" />

		<cfif not len(arguments.code)>
			<cfset stResult.reason = "noSubmission" />
			<cfreturn stResult />
		</cfif>

		<cfif len(arguments.code) eq 6 and isNumeric(arguments.code)>
			<!--- authenticator code --->
			<cfset stResult.method = "totp" />
			<cfset stFactor = getFactorType().getActiveFactor(userKey=arguments.userKey, userDirectory=this.key, factorType="totp") />

			<cfif structIsEmpty(stFactor)>
				<cfset stResult.message = "The code was not recognised." />
				<cfset stResult.bLocked = recordMFAFailure(userKey=arguments.userKey) />
				<cfreturn stResult />
			</cfif>

			<cftry>
				<cfset secret = variables.oMFACrypto.decryptSecret(stFactor.stPayload.secret) />
				<cfcatch>
					<cfset application.security.logSecurityEvent(event="mfaUnavailable", level="error", message="mfa secret decryption failed", userid="#arguments.userid#_#this.key#") />
					<cfset stResult.reason = "mfaUnavailable" />
					<cfset stResult.message = "Your authenticator code cannot be checked right now. Use a recovery code, or contact your administrator." />
					<cfreturn stResult />
				</cfcatch>
			</cftry>

			<cfset stVerify = variables.oMFACrypto.verifyTOTP(secretB32=secret, code=arguments.code, lastAcceptedStep=(structKeyExists(stFactor.stPayload, "lastStep") ? stFactor.stPayload.lastStep : 0)) />

			<cfif stVerify.verified>
				<cfset stFactor.stPayload.lastStep = stVerify.step />
				<cfset getFactorType().updateFactorPayload(objectid=stFactor.objectid, stPayload=stFactor.stPayload) />
				<cfset application.fapi.getContentType("farUser").resetLoginFailures(objectid=arguments.userKey) />
				<cfset stResult.verified = true />
				<cfset stResult.reason = "" />
			<cfelse>
				<cfset stResult.reason = stVerify.reason />
				<cfset stResult.message = (stVerify.reason eq "replayedCode") ? "That code has already been used. Wait for your app to show a new code." : "The code was not recognised." />
				<cfset stResult.bLocked = recordMFAFailure(userKey=arguments.userKey) />
			</cfif>
		<cfelse>
			<!--- recovery code --->
			<cfset stResult.method = "recoveryCode" />
			<cfset stRedeem = getFactorType().redeemRecoveryCode(userKey=arguments.userKey, userDirectory=this.key, code=arguments.code) />

			<cfif stRedeem.redeemed>
				<cfset application.fapi.getContentType("farUser").resetLoginFailures(objectid=arguments.userKey) />
				<cfset stResult.verified = true />
				<cfset stResult.reason = "" />
				<cfset stResult.recoveryRemaining = stRedeem.remaining />
			<cfelse>
				<cfset stResult.reason = "badRecoveryCode" />
				<cfset stResult.message = "The code was not recognised." />
				<cfset stResult.bLocked = recordMFAFailure(userKey=arguments.userKey) />
			</cfif>
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="recordMFAFailure" access="private" output="false" returntype="boolean" hint="Feeds a failed second factor into the shared login lockout; returns true when the account is now locked">
		<cfargument name="userKey" type="string" required="true" />

		<cfset var failureCount = application.fapi.getContentType("farUser").addLoginFailure(objectid=arguments.userKey, reason="Incorrect second factor") />

		<cfreturn failureCount gte int(application.fapi.getConfig("general", "loginAttemptsAllowed", 5)) />
	</cffunction>

	<cffunction name="issueRecoveryCodes" access="private" output="false" returntype="array" hint="Generates a fresh recovery code set, stores the hashes and returns the plain codes for one-time display">
		<cfargument name="userKey" type="string" required="true" />

		<cfset var aCodes = variables.oMFACrypto.generateRecoveryCodes(10) />
		<cfset var aHashes = arraynew(1) />
		<cfset var code = "" />

		<cfloop array="#aCodes#" index="code">
			<!--- hash the normalised form (no dash/case) so redemption matches regardless of how the user types it --->
			<cfset arrayAppend(aHashes, application.security.cryptlib.encodePassword(password=reReplace(ucase(code), "[^A-Z0-9]", "", "all"), hashname=getOutputHashName())) />
		</cfloop>

		<cfset getFactorType().saveRecoveryCodes(userKey=arguments.userKey, userDirectory=this.key, aHashes=aHashes) />

		<cfreturn aCodes />
	</cffunction>

	<cffunction name="getUserKey" access="private" output="false" returntype="string" hint="Resolves a userid to the stable user key (the farUser objectid); empty string when not found">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stUser = application.fapi.getContentType("farUser").getByUserID(userid=arguments.userid) />

		<cfif structKeyExists(stUser, "objectid")>
			<cfreturn stUser.objectid />
		</cfif>

		<cfreturn "" />
	</cffunction>

	<cffunction name="getUserRoleIDs" access="private" output="false" returntype="string" hint="The user's role objectids, resolved from their group membership (mirrors login())">
		<cfargument name="userid" type="string" required="true" />

		<cfset var aGroups = getUserGroups(arguments.userid) />
		<cfset var lGroups = "" />
		<cfset var group = "" />

		<cfloop array="#aGroups#" index="group">
			<cfset lGroups = listAppend(lGroups, "#group#_#this.key#") />
		</cfloop>

		<cfreturn application.security.factory.role.groupsToRoles(lGroups) />
	</cffunction>

	<cffunction name="getFactorType" access="private" output="false" returntype="any" hint="Returns the farMFAFactor type component">
		<cfreturn application.fapi.getContentType("farMFAFactor") />
	</cffunction>

	<cffunction name="getMFAMode" access="private" output="false" returntype="string" hint="The effective mfa mode: off / optional / required">
		<cfreturn application.fapi.getConfig("security", "mfaMode", "off") />
	</cffunction>

	<cffunction name="getIssuer" access="private" output="false" returntype="string" hint="The otpauth issuer shown in the authenticator app: the site title, qualified with the environment label outside production so entries from different environments stay distinguishable">
		<cfset var issuer = application.fapi.getConfig("security", "mfaIssuer", "") />
		<cfset var oEnv = "" />
		<cfset var env = "" />

		<!--- explicit override wins --->
		<cfif len(issuer)>
			<cfreturn issuer />
		</cfif>

		<!--- default: the site title (not the project folder name), e.g. "buy NSW" --->
		<cfset issuer = application.fapi.getConfig("general", "sitetitle", "") />
		<cfif not len(issuer)>
			<cfset issuer = application.applicationname />
		</cfif>

		<!--- append the environment label for non-production envs: "buy NSW Development", "buy NSW UAT" --->
		<cfif structKeyExists(application, "stCOAPI") and structKeyExists(application.stCOAPI, "configEnvironment")>
			<cfset oEnv = application.fapi.getContentType("configEnvironment") />
			<cfset env = oEnv.getEnvironment() />
			<cfif not listFindNoCase("production,unknown", env) and len(oEnv.getLabel(env))>
				<cfset issuer = issuer & " " & oEnv.getLabel(env) />
			</cfif>
		</cfif>

		<cfreturn issuer />
	</cffunction>

	<cffunction name="getEnrolContext" access="private" output="false" returntype="struct" hint="Returns the session stash for an in-progress enrolment: the pending interstitial context when one exists, otherwise a self-service stash">
		<cfif structKeyExists(session, "fc") and structKeyExists(session.fc, "mfaPending")>
			<cfparam name="session.fc.mfaPending.context" default="#structnew()#" />
			<cfreturn session.fc.mfaPending.context />
		</cfif>

		<cfparam name="session.fc" default="#structnew()#" />
		<cfparam name="session.fc.stMFAEnrol" default="#structnew()#" />
		<cfreturn session.fc.stMFAEnrol />
	</cffunction>


	<!--- =============================
	  Pre 4.1 data migration functions
	============================== --->
	
	<cffunction name="migratePermissions" access="private" output="false" returntype="struct" hint="Migrates the permission data, and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qPermissions = "" />
		<cfset var oPermission = createObject("component", application.stcoapi["farPermission"].packagePath) />
		<cfset var stObj = structnew() />
		<cfset var perm = "" />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qPermissions">
			select	*
			from	#application.dbowner#dmPermission
		</cfquery>
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farPermission(createdby,datetimecreated,datetimelastupdated,label,lastupdatedby,locked,lockedBy,objectid,ownedby,shortcut,title)
					(select '' as createdBy, getdate() as datetimecreated, getdate() as datetimelastupdated, permissionname as label, 'upgrade' as lastupdatedby, 0 as locked, '' as lockedBy, left(newid(),23)+right(newid(),12) as objectid, '' as ownedBy, permissionname as shortcut, permissionname as title
					from #application.dbowner#dmPermission)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farPermission_aRelatedTypes(parentid,data,typename,seq)
					(select np.objectid as parentid,op.permissiontype as data,'' as typename,1 as seq
					from #application.dbowner#farPermission np join #application.dbowner#dmPermission op on np.shortcut=op.permissionname
					where op.permissiontype<>'PolicyGroup')
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#refObjects(objectid,typename)
					(select objectid,'farPermission' as typename
					from #application.dbowner#farPermission)
				</cfquery>
			</cfcase>
			
			<cfdefaultcase>
				<!--- Add data --->
				<cfloop query="qPermissions">
					<cfset stObj = structnew() />
					<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
					<cfset stObj.title = permissionname />
					<cfset stObj.shortcut = permissionname />
					<cfset stObj.label = permissionname />
					<cfif permissiontype neq "PolicyGroup">
						<cfparam name="stObj.aRelatedtypes" default="#arraynew(1)#" />
						<cfset arrayappend(stObj.aRelatedtypes,permissiontype) />
					</cfif>
					
					<cfset oPermission.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
					
					<cfset stResult[permissionid] = stObj.objectid />
				</cfloop>
			</cfdefaultcase>
			
		</cfswitch>
		
		<!--- Add new permisions - the generic permission set --->
		<cfloop list="Approve,Create,Delete,Edit,RequestApproval,CanApproveOwnContent" index="perm">
			<cfset stObj = structnew() />
			<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
			<cfset stObj.title = "Generic #perm#" />
			<cfset stObj.shortcut = "generic#perm#" />
			<cfset stObj.label = "Generic #perm#" />
			
			<cfset oPermission.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateRoles" access="private" output="false" returntype="struct" hint="Migrates the roles (policy groups previously) and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qPolicyGroups = "" />
		<cfset var oRole = createObject("component", application.stcoapi["farRole"].packagePath) />
		<cfset var stObj = structnew() />
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farRole(createdBy,datetimecreated,datetimelastupdated,isdefault,label,lastupdatedby,locked,lockedBy,objectid,ownedby,title,webskins)
					(select 'upgrade' as createdBy, getdate() as datetimecreated, getdate() as datetimelastupdated, 
						case policygroupname when 'Anonymous' then 1 else 0 end as isdefault, policygroupname as label, 
						'upgrade' as lastupdatedby, 0 as locked, '' as lockedBy, left(newid(),23)+right(newid(),12) as objectid,
						'' as ownedby, policygroupname as title, case when policygroupname='Anonymous' then 'display*' + char(13) + char(10) + 'execute*' when policygroupname in ('Contributors','Publishers','SiteAdmin','SysAdmin') then '*' else '' end as webskins
					from #application.dbowner#dmPolicyGroup)
				</cfquery>
				
				<cfquery datasource="#application.dsn#" name="qPolicyGroups">
					select	objectid,title,policygroupid
					from	#application.dbowner#farRole r
							join
							#application.dbowner#dmPolicyGroup pg
							on r.title=pg.policygroupname
				</cfquery>
				<cfloop query="qPolicyGroups">
					<cfset stResult[qPolicyGroups.policygroupid] = qPolicyGroups.objectid />
					<cfset stResult[qPolicyGroups.title] = qPolicyGroups.objectid />
				</cfloop>
			</cfcase>
			
			<cfdefaultcase>
				<!--- Get data --->
				<cfquery datasource="#application.dsn#" name="qPolicyGroups">
					select	*
					from	#application.dbowner#dmPolicyGroup
				</cfquery>
				
				<!--- Add data --->
				<cfloop query="qPolicyGroups">
					<cfset stObj = structnew() />
					<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
					<cfset stObj.title = policygroupname />
					<cfset stObj.label = policygroupname />
					<cfif policygroupname eq "Anonymous">
						<cfset stObj.isdefault = true />
					</cfif>
					
					<cfswitch expression="#policygroupname#">
						<cfcase value="anonymous">
							<cfset stObj.webskins = "display*#chr(13)##chr(10)#execute*" />
						</cfcase>
						<cfcase value="Contributors,Publishers,SiteAdmin,SysAdmin" delimiters=",">
							<cfset stObj.webskins = "*" />
						</cfcase>
						<cfdefaultcase>
							<cfset stObj.webskins = "" />
						</cfdefaultcase>
					</cfswitch>
					
					<cfset oRole.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
					
					<cfset stResult[policygroupid] = stObj.objectid />
					<cfset stResult[stObj.title] = stObj.objectid />
				</cfloop>		
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateGroups" access="private" output="false" returntype="struct" hint="Migrates the user directory groups and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qGroups = "" />
		<cfset var oGroup = createObject("component", application.stcoapi["farGroup"].packagePath) />
		<cfset var stObj = structnew() />
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into farGroup(createdby,datetimecreated,datetimelastupdated,label,lastupdatedby,locked,lockedBy,objectid,ownedby,title)
					(select 'upgrade' as createdBy, getdate() as datetimecreated, getdate() as datetimelastupdated,groupname as label,
						'upgrade' as lastupdatedby,0 as locked,'' as lockedBy,left(newid(),23)+right(newid(),12) as objectid,
						'' as ownedby,groupname as title
					from #application.dbowner#dmGroup)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#refObjects(objectid,typename)
					(select objectid,'farGroup' as typename
					from #application.dbowner#farGroup)
				</cfquery>
				
				<cfquery datasource="#application.dsn#" name="qGroups">
					select	objectid,title,groupid
					from	#application.dbowner#farGroup ng
							join
							#application.dbowner#dmGroup og
							on ng.title=og.groupname
				</cfquery>
				<cfloop query="qGroups">
					<cfset stResult[qGroups.groupid] = qGroups.objectid />
					<cfset stResult[qGroups.title] = qGroups.objectid />
				</cfloop>
			</cfcase>
			
			<cfdefaultcase>
				<!--- Get data --->
				<cfquery datasource="#application.dsn#" name="qGroups">
					select	*
					from	#application.dbowner#dmGroup
				</cfquery>
				
				<!--- Add data --->
				<cfloop query="qGroups">
					<cfset stObj = structnew() />
					<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
					<cfset stObj.title = groupname />
					<cfset stObj.label = groupname />
					
					<cfset oGroup.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
					
					<cfset stResult[groupid] = stObj.objectid />
					<cfset stResult[groupname] = stObj.objectid />
				</cfloop>		
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateUsers" access="private" output="false" returntype="struct" hint="Migrates the user directory users and returns a struct mapping the old ids to the new objectids">
		<cfset var stResult = structnew() />
		<cfset var qUsers = "" />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		<cfset var stObj = structnew() />
		<cfset var typename = "" />
		<cfset var property = "" />
		<cfset var oAlterType = createObject("component", "farcry.core.packages.farcry.alterType") />
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farUser(createdby,datetimecreated,datetimelastupdated,label,lastupdatedby,lGroups,locked,lockedBy,objectid,ownedby,password,userid,userstatus)
					(select 'upgrade' as createdby,getdate() as datetimecreated,getdate() as datetimelastupdated,userlogin as label,
						'upgrade' as lastupdatedby, '' as lGroups,0 as locked,'' as lockedBy,left(newid(),23)+right(newid(),12) as objectid,
						'' as ownedby, userpassword as password,userlogin as userid,case userstatus when 4 then 'active' else 'inactive' end as userstatus
					from #application.dbowner#dmUser)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#refObjects(objectid,typename)
					(select objectid,'farUser' as typename
					from #application.dbowner#farUser)
				</cfquery>
				
				<cfquery datasource="#application.dsn#" name="qUsers">
					select userid,objectid from farUser
				</cfquery>
				<cfloop query="qUsers">
					<cfset stResult[qUsers.userid] = qUsers.objectid />
				</cfloop>
			</cfcase>
			
			<cfdefaultcase>
				<!--- Get data --->
				<cfquery datasource="#application.dsn#" name="qUsers">
					select	*
					from	#application.dbowner#dmUser
				</cfquery>
				
				<!--- Add data --->
				<cfloop query="qUsers">
					<cfset stObj = structnew() />
					<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
					<cfset stObj.userid = userlogin />
					<cfset stObj.password = userpassword />
					<cfset stObj.label = userlogin />
					<cfif userstatus eq 4>
						<cfset stObj.userstatus = "active" />
					<cfelse>
						<cfset stObj.userstatus = "disabled" />
					</cfif>
					
					<cfset oUser.createData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
					
					<cfset stResult[userid] = stObj.objectid />
				</cfloop>
			</cfdefaultcase>
		</cfswitch>

		<cfloop collection="#application.types#" item="typename">
			<cfloop list="createdby,lastupdatedby,lockedby" index="property">
				<!--- Update ownedby --->
				<cfif oAlterType.isCFCDeployed(typename=typename) and not find("_",typename)>

					<cfswitch expression="#application.dbType#">
						<cfcase value="mysql,mysql5">
							<!--- Update profiles --->
							<cfquery datasource="#application.dsn#">
							update	#application.dbowner##typename# t inner join 
									#application.dbowner#dmProfile
									on t.#property#=dmProfile.username
							set		t.#property# = concat(dmProfile.username, '_', dmProfile.userDirectory)							
							</cfquery>
						</cfcase>
						<cfcase value="ora">
							<!--- Update profiles --->
							<cfquery datasource="#application.dsn#">
								UPDATE #typename# t
								SET	t.#property# = (
									SELECT u.username || '_' || u.userDirectory
									FROM dmProfile u
									WHERE to_char(t.#property#) = to_char(u.username)
								)
								WHERE EXISTS (
									SELECT u.username || '_' || u.userDirectory
									FROM dmProfile u
									WHERE to_char(t.#property#) = to_char(u.username)
								)
							</cfquery>
						</cfcase>
						<cfdefaultcase>
							<!--- Update profiles --->
							<cfquery datasource="#application.dsn#">
								update	type
								set		#property# = dmProfile.username + '_' + dmProfile.userDirectory
								from	#application.dbowner##typename# type
										inner join 
										#application.dbowner#dmProfile
										on type.#property#=dmProfile.username
							</cfquery>	
						</cfdefaultcase>
					</cfswitch>
										
				</cfif>
				
			</cfloop>
		</cfloop>	
		
		<cfswitch expression="#application.dbType#">
			<cfcase value="mysql,mysql5">
				<!--- Update profiles --->
				<cfquery datasource="#application.dsn#">
					UPDATE	#application.dbowner#dmProfile
					SET		userName = CONCAT(userName, '_', userDirectory)
					WHERE	userName NOT LIKE <cfqueryparam value="%\_%" cfsqltype="cf_sql_varchar" />
				</cfquery>
			</cfcase>
			<cfcase value="mssql,mssql2005">
				<!--- Update profiles --->
				<cfquery datasource="#application.dsn#">
					update	#application.dbowner#dmProfile
					set		username=username + '_' + userDirectory
					where	username not like '%[_]%'
				</cfquery>
			</cfcase>
			<cfcase value="ora">
				<!--- Update profiles --->
				<cfquery datasource="#application.dsn#">
					UPDATE	#application.dbowner#dmProfile
					SET		username=username || '_' || userDirectory
					WHERE	username NOT LIKE '%!_%' ESCAPE '!'
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<!--- Update profiles --->
				<cfquery datasource="#application.dsn#">
					update	#application.dbowner#dmProfile
					set		username=username + '_' + userDirectory
					where	username not like '%_%'
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="migrateUserGroups" access="private" output="false" returntype="numeric" hint="Migrates the user directory groups">
		<cfargument name="users" type="struct" required="true" hint="Maps old user ids to new objectids" />
		<cfargument name="groups" type="struct" required="true" hint="Maps old gruop ids to new objectids" />
		
		<cfset var result = 0 />
		<cfset var qUserGroups = "" />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		<cfset var stObj = structnew() />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qUserGroups">
			select		*
			from		#application.dbowner#dmUserToGroup
			order by	userid
		</cfquery>
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into farUser_aGroups(parentid,data,typename,seq)
					(select fu.objectid as parentid,fg.objectid as data,'farGroup' as typename,0 as seq from farUser fu
					join dmUser du on fu.userid=du.userLogin
					join dmUserToGroup dug on du.userid=dug.userid
					join dmGroup dg on dug.groupid=dg.groupid
					join farGroup fg on dg.groupName=fg.title)
				</cfquery>
				
				<cfset result = qUserGroups.recordcount />
			</cfcase>
			
			<cfdefaultcase>
				<!--- Add data --->
				<cfoutput query="qUserGroups" group="userid">
					<!--- Make sure user still exists before migrating --->
					<cfif structKeyExists(arguments.users, qUserGroups.userid)>
						<cfset stObj = oUser.getData(objectid=arguments.users[qUserGroups.userid]) />
						<cfparam name="stObj.aGroups" default="#arraynew(1)#" />
						
						<cfoutput>
							<!--- Make sure group still exists before migrating --->
							<cfif structKeyExists(arguments.groups, qUserGroups.groupid)>
								<cfset arrayappend(stObj.aGroups,arguments.groups[qUserGroups.groupid]) />
								<cfset result = result + 1 />
							</cfif>
						</cfoutput>
						
						<cfset oUser.setData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
					</cfif>
				</cfoutput>
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="migrateMappings" access="private" output="false" returntype="numeric" hint="Migrates the mappings between the user directory groups and the Farcry roles">
		<cfargument name="groups" type="struct" required="true" hint="Maps old group ids to new objectids" />
		<cfargument name="roles" type="struct" required="true" hint="Maps old role ids to new objectids" />
		
		<cfset var result = 0 />
		<cfset var qMappings = "" />
		<cfset var oRole = createObject("component", application.stcoapi["farRole"].packagePath) />
		<cfset var stObj = structnew() />
		
		<!--- Get data --->
		<cfquery datasource="#application.dsn#" name="qMappings">
			select		*
			from		#application.dbowner#dmExternalGroupToPolicyGroup
			order by	PolicyGroupId
		</cfquery>
		
		<!--- Add data --->
		<cfoutput query="qMappings" group="PolicyGroupId">
			<cfif structkeyexists(arguments.roles,PolicyGroupId)>
				<cfset stObj = oRole.getData(objectid=arguments.roles[PolicyGroupId]) />
				<cfparam name="stObj.aGroups" default="#arraynew(1)#" />
				
				<cfoutput>
					<cfset arrayappend(stObj.aGroups,"#externalgroupname#_#ucase(externalgroupuserdirectory)#") />
					<cfset result = result + 1 />
				</cfoutput>
				
				<cfset oRole.setData(stProperties=stObj,user="migratescript",auditNote="Data migrated from pre 4.1") />
			</cfif>
		</cfoutput>
		
		<cfreturn result />
	</cffunction>	
	
	<cffunction name="migrateBarnacles" access="private" output="false" returntype="numeric" hint="Migrates the role permissions">
		<cfargument name="permissions" type="struct" required="true" hint="Maps old permission ids to new objectids" />
		<cfargument name="roles" type="struct" required="true" hint="Maps old role ids to new objectids" />
		
		<cfset var result = 0 />
		<cfset var qBarnacles = "" />
		<cfset var oRole = createObject("component", application.stcoapi["farRole"].packagePath) />
		<cfset var oBarnacle = createObject("component", application.stcoapi["farBarnacle"].packagePath) />
		
		<cfswitch expression="#application.dbtype#">
			<cfcase value="mssql">
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#farBarnacle(barnaclevalue,createdby,datetimecreated,datetimelastupdated,label,lastupdatedby,locked,lockedby,objectid,objecttype,ownedby,permissionid,referenceid,roleid)
					(select ob.status as barnaclevalue,'upgrade' as createdby,getdate() as datetimecreated,getdate() as datetimelastupdated,
						'' as label,'upgrade' as lastupdatedby,0 as locked,'' as lockedBy,
						left(newid(),23)+right(newid(),12) as objectid,ref.typename as objecttype,
						'' as ownedby,np.objectid as permissionid,reference1 as referenceid,nr.objectid as roleid
					from #application.dbowner#dmPermissionBarnacle ob
					join #application.dbowner#refObjects ref on ob.reference1=ref.objectid
					join #application.dbowner#dmPermission op on ob.permissionid=op.permissionid
					join #application.dbowner#farPermission np on op.permissionname=np.title
					join #application.dbowner#dmPolicyGroup olr on ob.policygroupid=olr.policygroupid
					join #application.dbowner#farRole nr on olr.policygroupname=nr.title
					where reference1 like '________-____-____-________________' and status=1)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into #application.dbowner#refObjects(objectid,typename)
					(select objectid,'farBarnacle' as typename
					from #application.dbowner#farBarnacle)
				</cfquery>
				<cfquery datasource="#application.dsn#" name="qBarnacles">
					select * from #application.dbowner#dmPermissionBarnacle where reference1 like '________-____-____-________________' and status=1
				</cfquery>
				<cfset result = result + qBarnacles.recordcount />
				
				<cfquery datasource="#application.dsn#">
					ALTER TABLE dbo.farRole_aPermissions ADD [tempseq] int NOT NULL IDENTITY (1, 1)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					insert into farRole_aPermissions(data,parentid,seq,typename)
					(select np.objectid as data, nr.objectid as parentid, 0 as seq, 'farPermission' as typename
					from dmPermissionBarnacle ob
					join dmPermission op on ob.permissionid=op.permissionid
					join farPermission np on op.permissionname=np.title
					join dmPolicyGroup olr on ob.policygroupid=olr.policygroupid
					join farRole nr on olr.policygroupname=nr.title
					where reference1='PolicyGroup' and status=1)
				</cfquery>
				<cfquery datasource="#application.dsn#">
					update farRole_aPermissions set seq=[tempseq]
				</cfquery>
				<cfquery datasource="#application.dsn#">
					ALTER TABLE farRole_aPermissions DROP COLUMN [tempseq]
				</cfquery>
				<cfquery datasource="#application.dsn#" name="qBarnacles">
					select * from #application.dbowner#dmPermissionBarnacle where reference1 like 'PolicyGroup' and status=1
				</cfquery>
				<cfset result = result + qBarnacles.recordcount />
			</cfcase>
			
			<cfdefaultcase>
				<!--- Get data --->
				<cfquery datasource="#application.dsn#" name="qBarnacles">
					select		*
					from		#application.dbowner#dmPermissionBarnacle
					where		status = 1
					order by	PolicyGroupId
				</cfquery>
				
				<!--- Add data --->
				<cfoutput query="qBarnacles" group="PolicyGroupId">
					<cfif structkeyexists(arguments.roles,PolicyGroupId)>
						<cfoutput>
							<cfif structkeyexists(arguments.permissions,permissionid)>
								<cfif len(reference1) and isvalid("uuid",reference1)>
									<!--- If this barnacle is related to a particular item, the new barnacle structure (which refers to items in an array) has already been created --->
									<cfset oBarnacle.updateRight(role=arguments.roles[PolicyGroupId],permission=arguments.permissions[permissionid],object=reference1,right=status)>
								<cfelseif reference1 eq "PolicyGroup">
									<!--- If this barnacle isn't related to a particular item, add it as a generic permission to this role --->
									<cfset oRole.updatePermission(role=arguments.roles[PolicyGroupId],permission=arguments.permissions[permissionid],has=true) />
								</cfif>
								
								<cfset result = result + 1 />
							</cfif>
						</cfoutput>
					</cfif>
				</cfoutput>
			</cfdefaultcase>
		</cfswitch>
		
		<!--- Attach the new permissions - the generic permission set --->
		<cfset oRole.updatePermission(role=arguments.roles["Contributors"],permission="genericCreate",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Contributors"],permission="genericEdit",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Contributors"],permission="genericRequestApproval",has=true) />
		
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericApprove",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericCanApproveOwnContent",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericCreate",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericDelete",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericEdit",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["Publishers"],permission="genericRequestApproval",has=true) />
		
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericApprove",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericCanApproveOwnContent",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericCreate",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericDelete",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericEdit",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SiteAdmin"],permission="genericRequestApproval",has=true) />
		
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericApprove",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericCanApproveOwnContent",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericCreate",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericDelete",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericEdit",has=true) />
		<cfset oRole.updatePermission(role=arguments.roles["SysAdmin"],permission="genericRequestApproval",has=true) />
		
		<cfset result = result + 21 />
		
		<cfreturn result />
	</cffunction>
		
	<cffunction name="migrate" access="public" output="true" returntype="string" hint="Migrates data from the previous DB structure and returns the results">
		<cfset var result = "" />
		
		<!--- Migrate basic data --->
		<cfset var stPermissions = migratePermissions() />
		<cfset var stRoles = migrateRoles() />
		<cfset var stGroups = migrateGroups() />
		<cfset var stUsers = migrateUsers() />
		
		<!--- Process relational data and build result string --->
		<cfset result = result & "Permissions: #structcount(stPermissions)#<br/>" />
		<cfset result = result & "Roles: #structcount(stRoles)#<br/>" />
		<cfset result = result & "Groups: #structcount(stGroups)#<br/>" />
		<cfset result = result & "Users: #structcount(stUsers)#<br/>" />
		<cfset result = result & "User group membership: #migrateUserGroups(stUsers,stGroups)#<br/>" />
		<cfset result = result & "Role-group mappings: #migrateMappings(stGroups,stRoles)#<br/>" />
		<cfset result = result & "Barnacles: #migrateBarnacles(stPermissions,stRoles)#<br/>" />
		
		<cfreturn result />
	</cffunction>

</cfcomponent>
