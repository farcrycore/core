<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Installation process --->
<!--- @@description: Performs the actual installation process --->

<cfoutput>
	<h1>Installing Your FarCry Application</h1>
	<p>&nbsp;</p>
	
	<div id="p2" style="width:100%;text-align:left;"></div>
	
	<div id="installComplete"></div>
	
	<script type="text/javascript">
		var pbar = new Ext.ProgressBar({
	        text:'Ready',
	        id:'pbar2',
	        cls:'left-align',
	        renderTo:'p2'
	    });
	    
		function updateProgressBar(pct, text){
			pbar.updateProgress(pct, text);
		}
	</script>
</cfoutput>
	
<cfif not session.oUI.bComplete>
	<cfset session.oUI.stConfig.webroot = expandpath("/") />
	
	<cfset session.oUI.stConfig.pluginwebroots = "" />
	<cfset qPlugins = session.oInstall.getPlugins() />
	<cfloop query="qPlugins">
		<cfif structkeyexists(form,"addWebrootMapping#qPlugins.value#") and form["addWebrootMapping#qPlugins.value#"]>
			<cfset session.oUI.stConfig.pluginwebroots = listappend(session.oUI.stConfig.pluginwebroots,qPlugins.value) />
		</cfif>
	</cfloop>
	
	<cfset stResult = session.oInstall.install(argumentCollection=session.oUI.stConfig) />
	
	<cfif stResult.bSuccess>
			
		<!--- 
		This sets up a cookie on the users system so that if they try and login to the webtop and the webtop can't determine which project it is trying to update,
		it will know what projects they will be potentially trying to edit.  --->
		<cfparam name="server.stFarcryProjects" default="#structNew()#" />
		
		<cfif NOT session.oUI.stConfig.bInstallDBOnly>
			<cfif not structKeyExists(server.stFarcryProjects, stResult.projectDirectoryName)>
				<cfset server.stFarcryProjects[stResult.projectDirectoryName] = structnew() />
				<cfset server.stFarcryProjects[stResult.projectDirectoryName].displayname = session.oUI.stConfig.displayName />
				<cfset server.stFarcryProjects[stResult.projectDirectoryName].domains = "" />
			</cfif>
			<cfif not listcontains(server.stFarcryProjects[stResult.projectDirectoryName].domains,cgi.http_host)>
				<cfset server.stFarcryProjects[stResult.projectDirectoryName].domains = listappend(server.stFarcryProjects[stResult.projectDirectoryName].domains,cgi.http_host) />
			</cfif>
		</cfif>
		
		<cfsavecontent variable="installCompleteHTML">
			<cfoutput>
				<p>&nbsp;</p>
				<div>
					<div class="item">
						<h2><strong>Congratulations!</strong>  Your application has sucessfully installed.</h2>
						<p>The installer has created an administration account for you to logon to the FarCry webtop:</p>
						<p>&nbsp;</p>
						
						<ul>
							<li>Username: <strong>#stResult.adminUser#</strong></li>
							<li>Password: <strong>#stResult.adminPassword#</strong></li>
						</ul>
						
						<p>&nbsp;</p>
						<p class="warning">WARNING: Be sure to <strong>change this account</strong> information on your first login for security reasons.</p>
						<p>&nbsp;</p>
	
					</div>
					<div class="itemButtons">
						<form name="installComplete" id="installComplete" method="post" action="">
							<input type="button" name="login" value="LOGIN TO THE FARCRY WEBTOP" onClick="alert('Your default Farcry login is\n\n u: #stResult.adminUser#\n p: #jsstringformat(stResult.adminPassword)#');window.open('#stResult.webtopURL#')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
							<input type="button" name="view" value="VIEW SITE" onClick="window.open('#stResult.siteURL#')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
							<input type="button" name="install" value="INSTALL ANOTHER PROJECT" onClick="window.open('#cgi.script_name#?restartInstaller=1', '_self')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
						</form><br /> 
					</div>
				</div>
	
			</cfoutput>
		</cfsavecontent>
		
		<cfoutput>
			<script type="text/javascript">
				Ext.get('installComplete').dom.innerHTML = '#jsstringformat(installCompleteHTML)#';
			</script>
		</cfoutput>
		
		<cfset session.oUI.bComplete = true />
		
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />