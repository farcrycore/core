<cfsetting enablecfoutputonly="true">
<!--- @@displayname: CDN Status --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!---
	Read-only status of the configured CDN locations. Up-front: where files go and, for S3, how
	credentials resolve / when they expire; the rest is behind a per-location details toggle.
	Secret values (secret key, session token, passwords) are never shown; a statically-configured
	access key ID is shown partially masked (first 4 + last 6 - it's the public half of the key,
	like a username, and the AKIA/ASIA prefix shows the key type). The connectivity test does a
	signed HEAD on a non-existent probe key (ioFileExists): 200/404 = credentials accepted and
	location reachable. Purely informational - it surfaces config so mis-config is easy to spot
	(e.g. static keys still present where an attached role was expected); it makes no judgements.
--->

<skin:loadJS id="farcry-form" />

<cfset qLocations = application.fc.lib.cdn.getLocations() />
<cfset bHasCreds = structkeyexists(application.fc.lib, "awscredentials") />

<!--- global credential refresh margin (footer) --->
<cfset refreshMargin = "" />
<cfif bHasCreds>
	<cftry>
		<cfset refreshMargin = application.fc.lib.awscredentials.refreshMarginSeconds />
		<cfcatch><cfset refreshMargin = "" /></cfcatch>
	</cftry>
</cfif>

<!--- Up-front fields, in display order: credential keys first (adjacent), then bucket + its host,
      then the rest alphabetical by label. Anything not listed here drops into "more details". --->
<cfset criticalOrder = "accessKeyId,awsSecretKey,sessionToken,bucket,domainHost,fullpath,host,hostname,password,path,pathPrefix,port,protocol,region,server,urlExpiry,urlpath,username,security" />

<!--- friendly labels for config keys (case-insensitive lookup; unmapped keys are humanised below) --->
<cfset stLabels = {
	"bucket" = "Bucket",
	"region" = "Region",
	"pathPrefix" = "Path prefix",
	"security" = "Visibility",
	"urlExpiry" = "Signed URL expiry (minutes)",
	"setACL" = "Set object ACL",
	"domain" = "Domain",
	"domainHost" = "Domain host",
	"domainType" = "Domain type",
	"fullpath" = "Full path",
	"urlpath" = "URL path",
	"accessKeyId" = "Access key ID",
	"awsSecretKey" = "Secret key",
	"sessionToken" = "Session token",
	"password" = "Password",
	"username" = "Username",
	"server" = "Server",
	"hostname" = "Hostname",
	"host" = "Host",
	"port" = "Port",
	"path" = "Path",
	"protocol" = "Protocol",
	"cdn" = "Driver",
	"name" = "Name",
	"bDebug" = "Debug logging",
	"localCacheSize" = "Local cache size",
	"credentialSet" = "Credential set (internal id)",
	"credentialSource" = "Credential source",
	"apiEndpoint" = "API endpoint",
	"apiEndpointPrefix" = "API endpoint prefix",
	"acl" = "ACL",
	"admins" = "Admins",
	"readers" = "Readers"
} />

<!--- friendly labels for the resolved provider id --->
<cfset stProviderLabels = {
	"static" = "static (inline keys)",
	"environment" = "environment (AWS_* vars)",
	"container" = "container endpoint (task role)",
	"instanceProfile" = "instance profile (EC2 role)"
} />

<!--- location(s) to connectivity-test this request (set by the Test buttons below) --->
<cfset testTarget = (structkeyexists(form, "selectedObjectID") ? form.selectedObjectID : "") />

<!--- build a display row per location, running the test inline only when requested --->
<cfset aRows = arraynew(1) />
<cfloop query="qLocations">
	<cfset stRow = {
		"name" = qLocations.name,
		"type" = qLocations.type,
		"config" = application.fc.lib.cdn.getLocation(qLocations.name),
		"cred" = structnew(),
		"tested" = false,
		"testok" = false,
		"testmsg" = ""
	} />

	<cfif stRow.type eq "s3" and bHasCreds and structkeyexists(stRow.config, "credentialSet") and len(stRow.config.credentialSet)>
		<cfset stRow.cred = application.fc.lib.awscredentials.describe(stRow.config.credentialSet) />
	</cfif>

	<cfif len(testTarget) and (testTarget eq "__all__" or testTarget eq stRow.name)>
		<cfset stRow.tested = true />
		<cftry>
			<cfset application.fc.lib.cdn.ioFileExists(location=stRow.name, file="__cdnstatus_probe__.txt") />
			<cfset stRow.testok = true />
			<cfset stRow.testmsg = (stRow.type eq "s3") ? "Credentials accepted, location reachable" : "Location reachable" />
			<cfif stRow.type eq "s3" and bHasCreds and structkeyexists(stRow.config, "credentialSet") and len(stRow.config.credentialSet)>
				<cfset stRow.cred = application.fc.lib.awscredentials.describe(stRow.config.credentialSet) />
			</cfif>
			<cfcatch>
				<cfset stRow.testok = false />
				<cfset stRow.testmsg = cfcatch.type & ": " & cfcatch.message />
			</cfcatch>
		</cftry>
	</cfif>

	<cfset arrayappend(aRows, stRow) />
</cfloop>


<cfoutput>
<style type="text/css">
	.cdn-panel { margin-bottom:1.6em; }
	.cdn-head { display:flex; align-items:center; border-bottom:1px solid ##e5e5e5; margin:1.6em 0 0.5em; padding:0 0 0.3em 9px; }
	.cdn-head-main { box-sizing:border-box; flex:0 0 auto; min-width:260px; display:flex; align-items:center; gap:0.6em; }
	.cdn-head h2 { color:##337ab7; font-size:1.4em; font-weight:500; margin:0; border:0; }
	.cdn-head .cdn-type { font-size:75%; }
	.cdn-summary { margin:0.3em 0 0.6em; color:##555; }
	button.cdn-toggle { margin:0.3em 0 0.5em; background:##fff; border:1px solid ##ddd; color:##333; box-shadow:none; }
	button.cdn-toggle:hover, button.cdn-toggle:focus, button.cdn-toggle:active { background:##fff; border-color:##adadad; color:##333; box-shadow:none; }
	.cdn-details { display:none; margin:0.4em 0 0 1.5em; padding-left:1em; border-left:3px solid ##e5e5e5; }
	.cdn-details.is-open { display:block; }
	table.cdn-props { margin-bottom:0.3em; }
	table.cdn-props td { padding:5px 9px; }
	table.cdn-props td.cdn-key { width:260px; box-sizing:border-box; white-space:nowrap; }
</style>
<h1>CDN Status</h1>
<p>An overview of the configured CDN locations and, for S3, how their credentials resolve.</p>
<p class="text-muted">
	Credential refresh margin: <strong><cfif isnumeric(refreshMargin)>#refreshMargin#s<cfelse>600s (default)</cfif></strong>
	(global, via <code>FARCRY_CDN_CRED_REFRESH_MARGIN_SECONDS</code>) &middot;
	<code>auto</code> resolution order: inline keys &rarr; AWS_* env &rarr; container/task role &rarr; EC2 instance role.
</p>
</cfoutput>

<ft:form>
<cfloop array="#aRows#" index="stRow">
	<cfset stCfg = stRow.config />
	<cfset stCred = stRow.cred />
	<cfset bS3 = (stRow.type eq "s3") />

	<!--- configured source: explicit credentialSource, or classic static keys --->
	<cfset configuredSource = "static (classic keys)" />
	<cfif bS3 and structkeyexists(stCfg, "credentialSource") and len(trim(stCfg.credentialSource))>
		<cfset configuredSource = lcase(trim(stCfg.credentialSource)) />
	</cfif>

	<!--- resolved provider, from the cached snapshot (describe().resolvedSource) --->
	<cfset resolvedLabel = "not resolved yet" />
	<cfif bS3 and structkeyexists(stCred,"cached") and stCred.cached>
		<cfif structkeyexists(stCred,"resolvedSource") and len(stCred.resolvedSource)>
			<cfset resolvedLabel = structkeyexists(stProviderLabels, stCred.resolvedSource) ? stProviderLabels[stCred.resolvedSource] : stCred.resolvedSource />
		<cfelse>
			<!--- resolver predates resolvedSource (or not yet reloaded): creds are cached, provider unknown --->
			<cfset resolvedLabel = "resolved" />
		</cfif>
	</cfif>

	<!--- "more details" keys = everything not up-front, sorted by friendly label --->
	<cfset aDetail = arraynew(1) />
	<cfloop array="#listToArray(structKeyList(stCfg))#" index="dk">
		<cfif not listfindnocase(criticalOrder, dk)>
			<cfset arrayappend(aDetail, (structkeyexists(stLabels, dk) ? stLabels[dk] : ucFirst(lcase(reReplace(dk, "([a-z0-9])([A-Z])", "\1 \2", "all")))) & "|" & dk) />
		</cfif>
	</cfloop>
	<cfset arraySort(aDetail, "textnocase") />

	<cfoutput>
		<div class="cdn-panel">
			<div class="cdn-head">
				<div class="cdn-head-main">
					<h2>#encodeForHTML(stRow.name)#</h2>
					<span class="label <cfif bS3>label-info<cfelse>label-default</cfif> cdn-type">#ucase(encodeForHTML(stRow.type))#</span>
				</div>
				<ft:button value="Test" text="Test connectivity" selectedObjectID="#stRow.name#" validate="false" />
			</div>

			<!--- connectivity result first, directly under the heading --->
			<cfif stRow.tested>
				<p title="#encodeForHTMLAttribute(stRow.testmsg)#">
					<cfif stRow.testok><span class="text-success"><strong>Connectivity OK</strong></span><cfelse><span class="text-danger"><strong>Connectivity failed</strong></span></cfif>
					&middot; #encodeForHTML(stRow.testmsg)#
				</p>
			</cfif>

			<!--- one-line credentials summary (also separates the head rule from the table) --->
			<cfif bS3>
				<p class="cdn-summary">
					<strong>Credentials:</strong> #encodeForHTML(configuredSource)# &rarr; <strong>#encodeForHTML(resolvedLabel)#</strong>
					<cfif structkeyexists(stCred,"cached") and stCred.cached>
						<cfif structkeyexists(stCred,"hasSessionToken") and stCred.hasSessionToken>
							&middot; <span class="label label-warning">temporary</span>
							<cfif isDate(stCred.expiration)>
								&middot; expires #dateformat(stCred.expiration,"yyyy-mm-dd")# #timeformat(stCred.expiration,"HH:mm")#
								<cfif isnumeric(stCred.secondsRemaining)>
									<cfif stCred.secondsRemaining gt 0> (in #int(stCred.secondsRemaining/3600)#h #int((stCred.secondsRemaining mod 3600)/60)#m)<cfelse> <span class="text-danger">(expired)</span></cfif>
								</cfif>
							</cfif>
						<cfelse>
							&middot; long-lived (no expiry)
						</cfif>
					</cfif>
					<cfif structkeyexists(stCred,"lastError") and len(stCred.lastError)>
						<br /><span class="text-danger">Last refresh error:</span> #encodeForHTML(stCred.lastError)#
					</cfif>
				</p>
			<cfelseif stRow.type eq "local">
				<p class="cdn-summary"><strong>Credentials:</strong> none &middot; Local filesystem</p>
			<cfelseif stRow.type eq "ftp">
				<p class="cdn-summary"><strong>Credentials:</strong> username / password &middot; FTP</p>
			<cfelse>
				<p class="cdn-summary"><strong>Credentials:</strong> see configuration &middot; #ucase(encodeForHTML(stRow.type))#</p>
			</cfif>

			<!--- up-front fields, in the order defined by criticalOrder --->
			<table class="table table-striped table-condensed cdn-props">
				<tbody>
					<cfloop list="#criticalOrder#" index="ck">
						<cfif structkeyexists(stCfg, ck)>
							<cfset thisVal = stCfg[ck] />
							<cfset bFullMask = (refindnocase("secret|password|token|authorization", ck) gt 0) />
							<cfset bKeyId = (not bFullMask and refindnocase("accesskey", ck) gt 0) />
							<cfset thisLabel = structkeyexists(stLabels, ck) ? stLabels[ck] : ucFirst(lcase(reReplace(ck, "([a-z0-9])([A-Z])", "\1 \2", "all"))) />
							<tr>
								<td class="cdn-key"><strong title="#encodeForHTMLAttribute(ck)#">#encodeForHTML(thisLabel)#</strong></td>
								<td>
									<cfif bFullMask><cfif isSimpleValue(thisVal) and len(trim(thisVal))><span class="text-muted">set (hidden)</span><cfelse><span class="text-muted">(empty)</span></cfif>
									<cfelseif bKeyId><cfif isSimpleValue(thisVal) and len(trim(thisVal)) gt 14>#encodeForHTML(left(trim(thisVal),4))#&hellip;#encodeForHTML(right(trim(thisVal),6))#<cfelseif isSimpleValue(thisVal) and len(trim(thisVal))><span class="text-muted">set (hidden)</span><cfelse><span class="text-muted">(empty)</span></cfif>
									<cfelseif isSimpleValue(thisVal)>#encodeForHTML(thisVal)#
									<cfelse><span class="text-muted">#encodeForHTML(serializeJSON(thisVal))#</span></cfif>
								</td>
							</tr>
						</cfif>
					</cfloop>
				</tbody>
			</table>

			<cfif arraylen(aDetail)>
				<button type="button" class="btn btn-default btn-xs cdn-toggle"><i class="fa fa-chevron-right"></i> More details</button>
				<div class="cdn-details">
					<table class="table table-striped table-condensed cdn-props">
						<tbody>
							<cfloop array="#aDetail#" index="pair">
								<cfset thisLabel = listfirst(pair, "|") />
								<cfset dk = listlast(pair, "|") />
								<cfset thisVal = stCfg[dk] />
								<cfset bFullMask = (refindnocase("secret|password|token|authorization", dk) gt 0) />
								<cfset bKeyId = (not bFullMask and refindnocase("accesskey", dk) gt 0) />
								<tr>
									<td class="cdn-key"><strong title="#encodeForHTMLAttribute(dk)#">#encodeForHTML(thisLabel)#</strong></td>
									<td>
										<cfif bFullMask><cfif isSimpleValue(thisVal) and len(trim(thisVal))><span class="text-muted">set (hidden)</span><cfelse><span class="text-muted">(empty)</span></cfif>
										<cfelseif bKeyId><cfif isSimpleValue(thisVal) and len(trim(thisVal)) gt 14>#encodeForHTML(left(trim(thisVal),4))#&hellip;#encodeForHTML(right(trim(thisVal),6))#<cfelseif isSimpleValue(thisVal) and len(trim(thisVal))><span class="text-muted">set (hidden)</span><cfelse><span class="text-muted">(empty)</span></cfif>
										<cfelseif isSimpleValue(thisVal)>#encodeForHTML(thisVal)#
										<cfelse><span class="text-muted">#encodeForHTML(serializeJSON(thisVal))#</span></cfif>
									</td>
								</tr>
							</cfloop>
						</tbody>
					</table>
				</div>
			</cfif>
		</div>
	</cfoutput>
</cfloop>

<ft:buttonPanel>
	<ft:button value="Test all" text="Test all locations" selectedObjectID="__all__" validate="false" />
</ft:buttonPanel>
</ft:form>

<skin:onReady><cfoutput>
	$j('.cdn-toggle').on('click', function(){
		var d = $j(this).next('.cdn-details');
		var open = d.toggleClass('is-open').hasClass('is-open');
		$j(this).html('<i class="fa fa-chevron-' + (open ? 'down' : 'right') + '"></i> ' + (open ? 'Fewer' : 'More') + ' details');
	});
</cfoutput></skin:onReady>

<cfsetting enablecfoutputonly="false">
