<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Step 4 --->
<!--- @@description: Plugins --->

<cfset qPlugins = session.oInstall.getPlugins() />

<cfoutput>
	<h1>Plugins</h1>
	<p>Plugins are code libraries that can be added to your project to change the look and feel, extend existing functionality or even add completely new features.  Your choice of "skeleton" will have pre-selected those plugins required for your skeleton to work properly. Feel free to add additional plugins that you think might be useful &##8212; remember, you can always uninstall or install plugins at a later date.</p>
	<p>&nbsp;</p>
	
	<!--- set plugins to blank in case no plugins are listed at all and skeleton is requiring one --->
    <input type="hidden" name="plugins" value="" />
		<div class="plugins">
		<cfloop query="qPlugins">
			<div id="plugin-#qPlugins.value#">
				<table cellspacing="10" cellpadding="0" class="plugin">
				<tr>
					<td valign="top" width="25px;">
						<input type="checkbox" id="plugin#qPlugins.value#" name="plugins" value="#qPlugins.value#" <cfif listContainsNoCase(session.oUI.stConfig.plugins, qPlugins.value)>checked</cfif> />
					</td>
					<td valign="top">
						<p>
							<strong>#qPlugins.label#</strong> <cfif qPlugins.supported>(Supported)<cfelse>(Not supported)</cfif><br />
							<em>#qPlugins.description#</em>
						</p>
						<cfif not session.oUI.stConfig.bInstallDBOnly>
							<cfif qPlugins.requiresmapping>
								<cfif listContainsNoCase(session.oUI.stConfig.plugins, qPlugins.value)>
									<cfset pluginMappingDisplay = 'block' />
								<cfelse>
									<cfset pluginMappingDisplay = 'none' />
								</cfif>
								<table cellspacing="10" cellpadding="0" id="plugin#qPlugins.value#AddWebroot" style="display:#pluginMappingDisplay#;">
								<tr>
									<td valign="top" width="25px;">
										<input type="checkbox" id="addWebrootMapping#qPlugins.value#" name="addWebrootMapping#qPlugins.value#" value="1" <cfif not isDefined("session.oUI.stConfig.addWebrootMapping#qPlugins.value#") or session.oUI.stConfig["addWebrootMapping#qPlugins.value#"]>checked</cfif> />
									</td>
									<td>
										<p><strong>Copy Plugin Webroot to project</strong></p>
										<div class="fieldHint">This plugin requires a webroot mapping. You can create the webroot mapping on your webserver, or alteratively you can select to have the webroot copied into your project to avoid having to create the mapping.</div>
									</td>
								</tr>
								</table>
								<input type="hidden" name="addWebrootMapping#qPlugins.value#" value="0" />
									<script type="text/javascript">
									Ext.onReady(function(){	
										var field = Ext.get('plugin#qPlugins.value#');
										field.on('change', checkPluginWebroot);
										
									})
									</script>
							</cfif>
						</cfif>

					</td>
				</tr>
				</table>
			</div>
		</cfloop>
		</div>

	</cfoutput>	
	
	<cfoutput>
	<script type="text/javascript">
		
		function checkPluginWebroot() {
			
			
			
			if(this.dom.checked)
			{
				Ext.get(this.id + 'AddWebroot').slideIn('t', {
				    easing: 'easeIn',
				    duration: .5,
				    useDisplay: true
				});	
					
			}
			else 
			{
				
				Ext.get(this.id + 'AddWebroot').ghost('b', {
				    easing: 'easeOut',
				    duration: .5,
				    remove: false,
				    useDisplay: true
				});
			}
		}
	</script>	
</cfoutput>

<cfsetting enablecfoutputonly="false" />