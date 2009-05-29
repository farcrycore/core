<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Step 5 --->
<!--- @@description: Deployment type --->

<cfoutput>
	<h1>Deployment Configuration</h1>
	
	<cfif session.oUI.stConfig.bInstallDBOnly>
		<p><strong>This is not relevent when performing a database only installation.</strong></p>
	<cfelse>
		<p>FarCry Core can support a variety of different configurations for deployment.  The installer supports three options.  If you are after a custom deployment option select "Advanced Configuration".</p>
		<p>&nbsp;</p>
		
		<div class="section">		
			<h3>
				<cfif fileExists(expandPath("/farcryConstructor.cfm"))>
					<input type="radio" id="projectInstallType" name="projectInstallType" disabled="true" value="SubDirectory" />
					<span style="text-decoration:line-through;">Sub-Directory</span>
				<cfelse>
					<input type="radio" id="projectInstallType" name="projectInstallType" value="SubDirectory" <cfif session.oUI.stConfig.projectInstallType EQ "SubDirectory">checked</cfif> />
					Sub-Directory
				</cfif>
			</h3>
			<cfif fileExists(expandPath("/farcryConstructor.cfm"))>
				<p><strong style="color:red;">You can't install as a sub-directory when a project exists in the webroot</strong></p>
			</cfif>
			<p>For multiple application deployment under a single webroot.  If you only have a single web site configured for your server, and would like to run multiple FarCry applications select me.</p>
			<p>Note each application will run under its own sub-directory, for example: http://localhost:8500/myproject</p>
		</div>
		
		<div class="section">	
			<h3>
				<cfif fileExists(expandPath("/farcryConstructor.cfm"))>
					<input type="radio" id="projectInstallType" name="projectInstallType" disabled="true" value="Standalone" />
					<span style="text-decoration:line-through;">Standalone</span>
				<cfelse>
					<input type="radio" id="projectInstallType" name="projectInstallType" value="Standalone" <cfif session.oUI.stConfig.projectInstallType EQ "Standalone">checked</cfif> />
					Standalone
				</cfif>
			</h3>
			<cfif fileExists(expandPath("/farcryConstructor.cfm"))>
				<p><strong style="color:red;">You can't install as standalone when a project exists in the webroot</strong></p>
			</cfif>
			<p>Specifically aimed at one application per website. For standalone application deployment and/or shared hosting deployment that allows for a single project select me.</p>
			<p>Note the application will run directly under the webroot, for example: http://localhost/</p>
		</div>
		
		<div class="section">		
			<h3>
				<input type="radio" id="projectInstallType" name="projectInstallType" value="CFMapping" <cfif session.oUI.stConfig.projectInstallType EQ "CFMapping">checked</cfif> />
				Advanced Configuration (ColdFusion and/or Web Server Mappings)
			</h3>
			<p>An enterprise configuration that allows for an unlimited number of projects to share a single core framework and library of plugins. Sharing is done through common reference to specific ColdFusion mapping or specific web server mapping (aka web virtual directory) of /farcry.</p>
			<p>Note this is an advanced option for custom configurations and deployments.  You may need to perform additional configuration to make your FarCry application operational.  Only select me if you know what you are doing.
		</div>
	</cfif>
</cfoutput>

<cfsetting enablecfoutputonly="false" />