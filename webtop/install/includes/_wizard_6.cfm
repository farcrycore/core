<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Step 6 --->
<!--- @@description: Review --->

<cfoutput>
	<h1>Installation Confirmation</h1>
	<cfif NOT session.oUI.stConfig.bInstallDBOnly>
		<div class="section">
		
			<div class="item summary">
				<label>Project Name:</label>
				<div class="field fieldDisplay">#session.oUI.stConfig.displayName#</div>
				<div class="clear">&nbsp;</div>
			</div>
		
			<div class="item summary">
				<label>Project Folder Name:</label>
				<div class="field fieldDisplay">#session.oUI.stConfig.applicationName#</div>
				<div class="clear">&nbsp;</div>
			</div>
			<div class="item summary">
				<label>Locales:</label>
				<div class="field fieldDisplay">
					<cfset qLocales = session.oInstall.getLocales() />
					<cfloop query="qLocales">
						<cfif listfindnocase(session.oUI.stConfig.locales,qLocales.value)>
							#qLocales.label#<br />
						</cfif>
					</cfloop>
				</div>
				<div class="clear">&nbsp;</div>
			</div>
		</div>
	</cfif>
	
	<div class="section">
	<div class="item summary">
		<cfif session.oUI.stConfig.bInstallDBOnly>
			<p style="text-align:center;"><strong>DATABASE ONLY INSTALLATION</strong></p>
		</cfif>
		<label>DSN:</label>
		<div class="field fieldDisplay">#session.oUI.stConfig.dsn#</div>
		<div class="clear">&nbsp;</div>
	</div>
	<div class="item summary">
		<label>Database Type:</label>
		<div class="field fieldDisplay">#session.oUI.stConfig.dbType#</div>
		<div class="clear">&nbsp;</div>
	</div>
	<cfif len(session.oUI.stConfig.dbOwner)>
		<div class="item summary">
			<label>Database Owner:</label>
			<div class="field fieldDisplay">#session.oUI.stConfig.dbOwner#</div>
			<div class="clear">&nbsp;</div>
		</div>
	</cfif>
	</div>
	
	<div class="section">
	<div class="item summary">
		<label>Skeleton:</label>
		<div class="field fieldDisplay">
			<cfset oManifest = createObject("component", "#session.oUI.stConfig.skeleton#.install.manifest")>
			#oManifest.name#
		</div>
		<div class="clear">&nbsp;</div>
	</div>
	</div>
	
	
	<div class="section">
	<div class="item summary">
		<label>Plugins:</label>
		<div class="field fieldDisplay">
			<cfloop list="#session.oUI.stConfig.plugins#" index="PluginName">
				<cfset oManifest = createObject("component", "farcry.plugins.#PluginName#.install.manifest")>
				<div style="border:1px dotted ##e3e3e3;margin-bottom:10px;padding:5px;">
					#oManifest.name# - #oManifest.description#
					<cfif isDefined("session.oUI.stConfig.addWebrootMapping#PluginName#") AND session.oUI.stConfig["addWebrootMapping#PluginName#"]>
						<div class="fieldHint">COPYING WEBROOT</div>
					</cfif>
				</div>
			</cfloop>
		</div>
		<div class="clear">&nbsp;</div>
	</div>
	</div>
	
	<cfif NOT session.oUI.stConfig.bInstallDBOnly>
		<div class="section">
		<div class="item summary">
			<label>Project Webroot Install Type:</label>
			<div class="field fieldDisplay">
				<cfswitch expression="#session.oUI.stConfig.projectInstallType#">
					<cfcase value="SubDirectory">
						A sub-directory under the web root
					</cfcase>
					<cfcase value="Standalone">
						Directly into the web root
					</cfcase>
					<cfdefaultcase>
						Into /farcry/projects/#session.oUI.stConfig.applicationName#/www
					</cfdefaultcase>
				</cfswitch>
			</div>
			<div class="clear">&nbsp;</div>
		</div>
		</div>
	</cfif>
</cfoutput>

<cfsetting enablecfoutputonly="false" />