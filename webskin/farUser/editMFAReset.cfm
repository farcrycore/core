<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Reset multi-factor --->
<!--- @@description: Webtop admin control to reset (remove) a user's second factor. Admins can reset factors, never view secrets. Permission-gated on SecurityManagement (see docs/0014). --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not application.security.checkPermission(permission="SecurityManagement")>
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfparam name="url.objectid" default="" />

<cfif not len(url.objectid)>
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfset oUD = application.security.userdirectories["CLIENTUD"] />

<!-----------------------------
ACTION
------------------------------>
<ft:processform action="Reset multi-factor">
	<cfset count = oUD.resetMFA(userKey=url.objectid, by="admin") />
	<cfif count gt 0>
		<skin:bubble title="Multi-factor authentication has been reset for this user" tags="security,info" />
	<cfelse>
		<skin:bubble title="This user had no second factor enrolled" tags="security,info" />
	</cfif>
</ft:processform>

<cfset stUser = application.fapi.getContentType("farUser").getData(objectid=url.objectid) />

<cfif structIsEmpty(stUser) or not structKeyExists(stUser, "userid") or not len(stUser.userid)>
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfset stStatus = oUD.getMFAStatus(userid=stUser.userid) />

<!-----------------------------
VIEW
------------------------------>
<admin:header>

<cfoutput><h1><admin:resource key="security.mfa.admin.title">Multi-factor authentication</admin:resource></h1></cfoutput>

<cfif not stStatus.bEnabled>
	<cfoutput><div class="alert alert-info"><admin:resource key="security.mfa.manage.disabled">Multi-factor authentication is not enabled on this site.</admin:resource></div></cfoutput>
<cfelseif stStatus.bEnrolled>
	<cfoutput>
		<div class="alert alert-success"><admin:resource key="security.mfa.admin.enrolled">This user has an active second factor.</admin:resource></div>
		<p><admin:resource key="security.mfa.admin.resethelp">Resetting removes the user's authenticator and recovery codes. They will be asked to enrol again at next login if your policy requires it. Verify the person's identity out of band before resetting.</admin:resource></p>
	</cfoutput>
	<ft:form>
		<ft:buttonPanel>
			<ft:button value="Reset multi-factor" text="Reset multi-factor" color="red" validate="false" />
		</ft:buttonPanel>
	</ft:form>
<cfelse>
	<cfoutput><div class="alert alert-info"><admin:resource key="security.mfa.admin.notenrolled">This user has no second factor enrolled.</admin:resource></div></cfoutput>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="false" />
