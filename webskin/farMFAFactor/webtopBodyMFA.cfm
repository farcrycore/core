<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Multi-factor enrolment --->
<!--- @@description: Webtop admin report of users with an enrolled second factor, each linking to the per-user reset. Permission-gated on SecurityManagement (see docs/0014). --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not application.security.checkPermission(permission="SecurityManagement")>
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfset qReport = application.fapi.getContentType("farMFAFactor").getEnrolmentReport() />
<cfset oUser = application.fapi.getContentType("farUser") />

<!--- collapse factor rows into one row per user for display ("ordered" is the cross-engine spelling; Lucee and ACF both accept it) --->
<cfset stUsers = structnew("ordered") />
<cfloop query="qReport">
	<cfset userRef = qReport.userDirectory & "|" & qReport.userKey />
	<cfif not structKeyExists(stUsers, userRef)>
		<cfset label = qReport.userKey />
		<cfif qReport.userDirectory eq "CLIENTUD">
			<cfset stU = oUser.getData(objectid=qReport.userKey) />
			<cfif not structIsEmpty(stU)>
				<cfset label = stU.userid />
			</cfif>
		</cfif>
		<cfset stUsers[userRef] = { userKey = qReport.userKey, ud = qReport.userDirectory, label = label, factors = "" } />
	</cfif>
	<cfset stUsers[userRef].factors = listAppend(stUsers[userRef].factors, qReport.factorType) />
</cfloop>

<admin:header>

<cfoutput><h1><admin:resource key="security.mfa.admin.reporttitle">Multi-factor enrolment</admin:resource></h1></cfoutput>

<cfif application.fapi.getConfig("security","mfaMode","off") eq "off">
	<cfoutput><div class="alert alert-info"><admin:resource key="security.mfa.manage.disabled">Multi-factor authentication is not enabled on this site.</admin:resource></div></cfoutput>
</cfif>

<cfif not structCount(stUsers)>
	<cfoutput><div class="alert alert-info"><admin:resource key="security.mfa.admin.noneenrolled">No users have enrolled a second factor.</admin:resource></div></cfoutput>
<cfelse>
	<cfoutput>
		<table class="table table-striped">
			<thead>
				<tr>
					<th><admin:resource key="security.mfa.admin.col.user">User</admin:resource></th>
					<th><admin:resource key="security.mfa.admin.col.directory">Directory</admin:resource></th>
					<th><admin:resource key="security.mfa.admin.col.factors">Factors</admin:resource></th>
					<th></th>
				</tr>
			</thead>
			<tbody>
				<cfloop collection="#stUsers#" item="userRef">
					<cfset stRow = stUsers[userRef] />
					<tr>
						<td>#encodeForHTML(stRow.label)#</td>
						<td>#encodeForHTML(stRow.ud)#</td>
						<td>#encodeForHTML(stRow.factors)#</td>
						<td>
							<cfif stRow.ud eq "CLIENTUD">
								<a class="btn btn-small" href="#application.url.webtop#/?id=dashboard&typename=farUser&objectid=#stRow.userKey#&bodyView=editMFAReset"><admin:resource key="security.mfa.admin.manage">Manage / reset</admin:resource></a>
							</cfif>
						</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
	</cfoutput>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="false" />
