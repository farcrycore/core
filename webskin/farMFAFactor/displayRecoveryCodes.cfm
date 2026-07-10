<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Recovery codes block --->
<!--- @@description: Composable fragment: renders a freshly issued recovery code set for one-time display. Expects request.fc.aMFARecoveryCodes (array of plain codes) from the composing view; the codes are stored hashed and cannot be shown again. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfparam name="request.fc.aMFARecoveryCodes" default="#arraynew(1)#" />

<cfif arraylen(request.fc.aMFARecoveryCodes)>
	<cfoutput>
		<div class="mfa-recovery">
			<div class="alert alert-warning">
				<admin:resource key="security.mfa.recovery.warning">Store these recovery codes somewhere safe (a password manager or printout). Each code works once, and they are shown only now.</admin:resource>
			</div>
			<ul class="unstyled mfa-recovery-codes">
				<cfloop array="#request.fc.aMFARecoveryCodes#" index="code">
					<li><code>#encodeForHTML(code)#</code></li>
				</cfloop>
			</ul>
		</div>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">
