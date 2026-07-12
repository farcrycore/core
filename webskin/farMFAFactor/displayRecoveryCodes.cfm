<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Recovery codes block --->
<!--- @@description: Composable fragment: renders a freshly issued recovery code set for one-time display, in two columns (Bootstrap row-fluid/span6). Expects request.fc.aMFARecoveryCodes (array of plain codes) from the composing view; the codes are stored hashed and cannot be shown again. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfparam name="request.fc.aMFARecoveryCodes" default="#arraynew(1)#" />

<cfif arraylen(request.fc.aMFARecoveryCodes)>
	<cfset iTotal = arraylen(request.fc.aMFARecoveryCodes) />
	<cfset iHalf = ceiling(iTotal / 2) />

	<cfoutput>
		<div class="mfa-recovery">
			<div class="alert alert-warning">
				<admin:resource key="security.mfa.recovery.warning">Store these recovery codes somewhere safe (a password manager or printout). Each code works once, and they are shown only now.</admin:resource>
			</div>
			<div class="row-fluid">
				<ul class="unstyled span6 mfa-recovery-codes">
					<cfloop from="1" to="#iHalf#" index="i"><li><code>#encodeForHTML(request.fc.aMFARecoveryCodes[i])#</code></li></cfloop>
				</ul>
				<ul class="unstyled span6 mfa-recovery-codes">
					<cfloop from="#iHalf + 1#" to="#iTotal#" index="i"><li><code>#encodeForHTML(request.fc.aMFARecoveryCodes[i])#</code></li></cfloop>
				</ul>
			</div>
		</div>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">
