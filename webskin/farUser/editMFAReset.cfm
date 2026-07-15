<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Manage multi-factor --->
<!--- @@description: Modal (opened from the "Manage multi-factor" action on the User Administration list) to review and reset a user's second factors. Shows the user and their enrolled factors so an admin can verify before resetting. Permission-gated on SecurityManagement. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not application.security.checkPermission(permission="SecurityManagement")>
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfset oUD = application.security.userdirectories["CLIENTUD"] />
<cfset oFactor = application.fapi.getContentType("farMFAFactor") />
<cfset stFactorIcons = { totp = "fa-mobile", passkey = "fa-key", recoveryCode = "fa-life-ring" } />

<!-----------------------------
ACTION
------------------------------>
<ft:processform action="Reset multi-factor" exit="true">
	<cfset oUD.resetMFA(userKey=stObj.objectid, by="admin") />
	<skin:bubble title="Multi-factor authentication reset" message="Reset for #encodeForHTML(stObj.userid)#" tags="security,info" />
</ft:processform>

<ft:processform action="Cancel" exit="true" />

<!-----------------------------
VIEW
------------------------------>
<cfset qFactors = oFactor.getFactors(userKey=stObj.objectid, userDirectory="CLIENTUD", status="active") />
<cfset recoveryRemaining = oFactor.getRecoveryCodesRemaining(userKey=stObj.objectid, userDirectory="CLIENTUD") />

<admin:header />

<cfoutput>
	<h1><i class="fa fa-lock"></i> <admin:resource key="security.mfa.admin.title">Multi-factor authentication</admin:resource></h1>
</cfoutput>

<cfif qFactors.recordcount>

	<cfoutput>
		<p><admin:resource key="security.mfa.admin.resetintro">Review this user's multi-factor authentication below. Resetting removes their passkeys, authenticator and recovery codes; verify their identity out of band first.</admin:resource></p>

		<dl class="dl-horizontal">
			<dt><admin:resource key="security.mfa.admin.col.user">User</admin:resource></dt>
			<dd>#encodeForHTML(stObj.userid)#</dd>
			<dt><admin:resource key="security.mfa.admin.col.directory">Directory</admin:resource></dt>
			<dd>CLIENTUD</dd>
		</dl>

		<table class="table table-striped">
			<thead>
				<tr>
					<th><admin:resource key="security.mfa.admin.col.factor">Factor</admin:resource></th>
					<th><admin:resource key="security.mfa.admin.col.enrolled">Enrolled</admin:resource></th>
					<th><admin:resource key="security.mfa.admin.col.lastused">Last used</admin:resource></th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="qFactors">
					<tr>
						<td><i class="fa fa-fw #structKeyExists(stFactorIcons, qFactors.factorType) ? stFactorIcons[qFactors.factorType] : 'fa-lock'#"></i> <cfif qFactors.factorType eq "recoveryCode"><strong><admin:resource key="security.mfa.admin.recoverycodes">Recovery codes</admin:resource></strong><br /><i class="fa fa-fw"></i> <small class="muted">#recoveryRemaining# <admin:resource key="security.mfa.admin.remaining">remaining</admin:resource></small><cfelseif qFactors.factorType eq "passkey"><strong>#encodeForHTML(len(qFactors.label) ? qFactors.label : "Passkey")#</strong><br /><i class="fa fa-fw"></i> <small class="muted"><admin:resource key="security.mfa.admin.kind.passkey">Passkey</admin:resource></small><cfelseif qFactors.factorType eq "totp"><strong><admin:resource key="security.mfa.admin.authapp">Authenticator app</admin:resource></strong><cfelse><strong>#encodeForHTML(len(qFactors.label) ? qFactors.label : qFactors.factorType)#</strong></cfif></td>
						<td>#dateformat(qFactors.datetimecreated, "d mmm yyyy")#</td>
						<td><cfif isDate(qFactors.lastUsed)>#dateformat(qFactors.lastUsed, "d mmm yyyy")#, #timeformat(qFactors.lastUsed, "h:mm tt")#<cfelse><admin:resource key="security.mfa.admin.never">never</admin:resource></cfif></td>
					</tr>
				</cfloop>
			</tbody>
		</table>

		<div class="alert alert-warning"><admin:resource key="security.mfa.admin.resethelp">Resetting removes every factor. They will be asked to enrol again at next login if your policy requires it.</admin:resource></div>
	</cfoutput>

	<ft:form>
		<cfoutput>
			<div class="pull-right">
				<ft:button value="Cancel" validate="false" />
				<ft:button class="btn-danger" icon="fa-power-off" value="Reset multi-factor" validate="false" />
			</div>
			<div class="clearfix"></div>
		</cfoutput>
	</ft:form>

<cfelse>

	<cfoutput><div class="alert alert-info"><admin:resource key="security.mfa.admin.notenrolled">This user has no active second factor.</admin:resource></div></cfoutput>

	<ft:form>
		<cfoutput>
			<div class="pull-right">
				<ft:button value="Cancel" text="Close" validate="false" />
			</div>
			<div class="clearfix"></div>
		</cfoutput>
	</ft:form>

</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />
