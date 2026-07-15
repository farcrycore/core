<cfsetting enablecfoutputonly="true">
<!--- @@displayname: MFA Status --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!---
	Read-only status of multi-factor authentication: how it is configured, what factors are
	enrolled (aggregate counts only - no per-user data, no secrets shown), and whether stored TOTP
	secrets need migrating onto the current encryption key after a rotation. When migration is
	needed, an admin can start a background re-wrap (the bulk counterpart to the lazy re-wrap on
	login); progress is read from a server-scope flag. All figures come from indexed aggregate
	queries. SecurityManagement-gated. See docs/0014.
--->

<cfif not application.security.checkPermission(permission="SecurityManagement")>
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<skin:loadJS id="farcry-form" />

<cfscript>
	oCrypto = createObject("component", application.factory.oUtils.getPath("security", "mfaCrypto")).init();
	oFactor = application.fapi.getContentType("farMFAFactor");
	udKey = "CLIENTUD";
	oUD = application.security.userdirectories[udKey];
	appName = application.applicationname;
	flagKey = appName & "|" & udKey;

	// configuration (read-only; no secrets)
	mfaMode = application.fapi.getConfig("security", "mfaMode", "off");
	uvPolicy = application.fapi.getConfig("security", "mfaPasskeyUserVerification", "preferred");
	challengeTimeout = application.fapi.getConfig("security", "mfaChallengeTimeout", 10);
	keyConfigured = oCrypto.isKeyConfigured();
	currentKeyId = oCrypto.getCurrentKeyId();
	retainedKeys = oCrypto.retainedKeyCount();

	// factor statistics + migration status (indexed aggregate queries - no row loading)
	stStats = oFactor.getFactorStats(userDirectory = udKey);
	stMig = oFactor.getTOTPMigrationStats(currentKeyId = currentKeyId, userDirectory = udKey);

	// migration progress flag (server scope, per application)
	function readMigrationFlag() {
		if (structKeyExists(server, "farcryMFAMigration") and structKeyExists(server.farcryMFAMigration, flagKey)) {
			return server.farcryMFAMigration[flagKey];
		}
		return {};
	}
	stFlag = readMigrationFlag();
	bRunning = structKeyExists(stFlag, "running") and stFlag.running;

	// action handling: two-step confirm before starting a background migration
	action = structKeyExists(form, "selectedObjectID") ? form.selectedObjectID : "";
	migMsg = "";
	if (action eq "__migrate__" and not bRunning and keyConfigured and stMig.needsMigration gt 0) {
		startedByU = (structKeyExists(session, "security") and structKeyExists(session.security, "userid")) ? session.security.userid : "";
		try {
			stStart = oUD.migrateStoredSecrets(startedBy = startedByU);
			if (stStart.started) {
				migMsg = "Migration started.";
			} else if (stStart.reason eq "alreadyRunning") {
				migMsg = "A migration is already running.";
			}
		} catch (any e) {
			migMsg = "Could not start the migration right now. Please try again in a moment.";
		}
		stFlag = readMigrationFlag();
		bRunning = structKeyExists(stFlag, "running") and stFlag.running;
		stMig = oFactor.getTOTPMigrationStats(currentKeyId = currentKeyId, userDirectory = udKey);
	}
	bConfirm = (action eq "__migrateconfirm__" and not bRunning and keyConfigured and stMig.needsMigration gt 0);

	// display helpers
	pctCurrent = (stMig.total gt 0) ? round(stMig.current / stMig.total * 100) : 100;
	migPlural = (stMig.needsMigration neq 1) ? "s" : "";
	migBtnLabel = "Migrate " & stMig.needsMigration & " secret" & migPlural & " to the current key";
	flagTotal = structKeyExists(stFlag, "total") ? stFlag.total : 0;
	flagDone = structKeyExists(stFlag, "done") ? stFlag.done : 0;
	flagFailed = structKeyExists(stFlag, "failed") ? stFlag.failed : 0;
	pctRun = (flagTotal gt 0) ? round((flagDone + flagFailed) / flagTotal * 100) : 100;
</cfscript>

<cfoutput>
<style type="text/css">
	.mfa-panel { margin:0 0 1.3em; }
	.mfa-head { display:flex; align-items:center; gap:0.8em; margin:1.5em 0 0.4em; padding:0 0 0.35em; border-bottom:1px solid ##e5e5e5; }
	.mfa-head h2 { color:##337ab7; font-size:1.3em; font-weight:500; margin:0; border:0; }
	table.mfa-props { margin-bottom:0.6em; }
	table.mfa-props > tbody > tr:first-child > td { border-top:0; }
	table.mfa-props td.mfa-key { width:280px; white-space:nowrap; }
	.mfa-tiles { display:flex; gap:12px; flex-wrap:wrap; margin:0.3em 0 0.4em; }
	.mfa-tile { flex:1 1 0; min-width:120px; background:##f7f7f7; border-radius:6px; padding:12px 14px; }
	.mfa-tile .n { font-size:24px; font-weight:500; color:##333; }
	.mfa-tile .l { font-size:12px; color:##777; margin-top:3px; }
	.mfa-bar { height:16px; background:##eee; border-radius:3px; overflow:hidden; margin:0.3em 0 0.5em; }
	.mfa-bar-fill { height:100%; background:##5cb85c; }
	.mfa-note { font-size:12px; color:##999; margin-top:0.4em; }
</style>
<h1>Multi-factor authentication</h1>
<p>How MFA is configured, what's enrolled, and whether any stored authenticator secrets need migrating after an encryption-key rotation.</p>
</cfoutput>

<ft:form>
<cfoutput>

	<div class="mfa-panel">
		<div class="mfa-head"><h2>Configuration</h2></div>
		<table class="table table-striped table-condensed mfa-props">
			<tbody>
				<tr><td class="mfa-key"><strong>Mode</strong></td><td><cfif mfaMode eq "required"><span class="label label-info">Required</span><cfelseif mfaMode eq "optional"><span class="label label-default">Optional</span><cfelse><span class="label label-default">Off</span></cfif></td></tr>
				<tr><td class="mfa-key"><strong>Encryption key</strong></td><td><cfif keyConfigured><span class="label label-success">Configured</span><cfelse><span class="label label-important">Not set</span> <span class="text-muted">enrolment and migration are unavailable</span></cfif></td></tr>
				<tr><td class="mfa-key"><strong>Current key id</strong></td><td><code>#encodeForHTML(currentKeyId)#</code></td></tr>
				<tr><td class="mfa-key"><strong>Retained keys</strong></td><td>#retainedKeys#<cfif retainedKeys gt 0> <span class="text-muted">held for decryption during a rotation</span></cfif></td></tr>
				<tr><td class="mfa-key"><strong>Passkey verification</strong></td><td><code>#encodeForHTML(uvPolicy)#</code></td></tr>
				<tr><td class="mfa-key"><strong>Challenge timeout</strong></td><td>#val(challengeTimeout)# minutes</td></tr>
			</tbody>
		</table>
	</div>

	<div class="mfa-panel">
		<div class="mfa-head"><h2>Enrolled factors</h2></div>
		<div class="mfa-tiles">
			<div class="mfa-tile"><div class="n">#stStats.enrolledUsers#</div><div class="l">Enrolled users</div></div>
			<div class="mfa-tile"><div class="n">#stStats.totp#</div><div class="l">Authenticator apps</div></div>
			<div class="mfa-tile"><div class="n">#stStats.passkey#</div><div class="l">Passkeys</div></div>
			<div class="mfa-tile"><div class="n">#stStats.recoveryCode#</div><div class="l">Recovery-code sets</div></div>
		</div>
	</div>

	<div class="mfa-panel">
		<div class="mfa-head"><h2>Key rotation &amp; migration</h2></div>

		<cfif len(migMsg)><p class="text-success">#encodeForHTML(migMsg)#</p></cfif>

		<cfif not keyConfigured>
			<p class="text-danger"><i class="fa fa-exclamation-triangle"></i> The MFA encryption key is not set, so migration is unavailable.</p>

		<cfelseif bRunning>
			<p><span class="text-success"><i class="fa fa-refresh fa-spin"></i> <strong>Migration running</strong></span> &middot; #flagDone# migrated<cfif flagFailed gt 0>, <span class="text-danger">#flagFailed# failed</span></cfif> of #flagTotal#.</p>
			<div class="mfa-bar"><div class="mfa-bar-fill" style="width:#pctRun#%;"></div></div>
			<table class="table table-striped table-condensed mfa-props">
				<tbody>
					<tr><td class="mfa-key"><strong>Started</strong></td><td>#dateformat(stFlag.startedAt,"yyyy-mm-dd")# #timeformat(stFlag.startedAt,"HH:mm:ss")#<cfif len(stFlag.startedBy)> by #encodeForHTML(stFlag.startedBy)#</cfif></td></tr>
					<tr><td class="mfa-key"><strong>Last record migrated</strong></td><td><cfif isDate(stFlag.lastRecordAt)>#timeformat(stFlag.lastRecordAt,"HH:mm:ss")#<cfelse><span class="text-muted">-</span></cfif></td></tr>
				</tbody>
			</table>
			<ft:button value="Refresh" text="Refresh progress" selectedObjectID="__refresh__" validate="false" />

		<cfelseif stMig.total eq 0>
			<p class="text-muted">No authenticator (TOTP) secrets are enrolled yet.</p>

		<cfelseif stMig.needsMigration eq 0>
			<p><span class="text-success"><i class="fa fa-check-circle"></i> <strong>All current</strong></span> &middot; all #stMig.total# authenticator secret<cfif stMig.total neq 1>s are</cfif><cfif stMig.total eq 1> is</cfif> sealed with the current key (id <code>#encodeForHTML(currentKeyId)#</code>).</p>
			<cfif structKeyExists(stFlag, "finishedAt") and isDate(stFlag.finishedAt)>
				<p class="mfa-note">Last migration finished #dateformat(stFlag.finishedAt,"yyyy-mm-dd")# #timeformat(stFlag.finishedAt,"HH:mm:ss")#: #flagDone# migrated<cfif flagFailed gt 0>, #flagFailed# failed</cfif>.</p>
			</cfif>

		<cfelse>
			<p><i class="fa fa-exclamation-triangle text-warning"></i> <strong>#stMig.needsMigration#</strong> of #stMig.total# authenticator secret<cfif stMig.needsMigration neq 1>s are</cfif><cfif stMig.needsMigration eq 1> is</cfif> sealed under a previous key and should be migrated to the current key.</p>
			<div class="mfa-bar"><div class="mfa-bar-fill" style="width:#pctCurrent#%;"></div></div>
			<p class="mfa-note">#stMig.current# on the current key &middot; #stMig.needsMigration# to migrate.</p>

			<cfif retainedKeys eq 0>
				<p class="text-danger"><i class="fa fa-exclamation-triangle"></i> No previous keys are retained (<code>mfaEncryptKeysOld</code> is empty), so secrets sealed under an old key cannot be decrypted. Add the previous key before migrating.</p>
			</cfif>

			<cfif bConfirm>
				<div class="alert alert-warning">This re-encrypts #stMig.needsMigration# authenticator secret#migPlural# onto the current key, in the background. It's safe to run more than once. Start now?</div>
				<ft:button value="Start migration" text="Start the migration now" selectedObjectID="__migrate__" validate="false" />
				<ft:button value="Cancel" selectedObjectID="__cancel__" validate="false" />
			<cfelse>
				<ft:button value="#migBtnLabel#" selectedObjectID="__migrateconfirm__" validate="false" />
			</cfif>
		</cfif>
	</div>

</cfoutput>
</ft:form>

<cfsetting enablecfoutputonly="false">
