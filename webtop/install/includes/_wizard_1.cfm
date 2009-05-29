<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Step 1 --->
<!--- @@description: Application details --->

<cfset qLocales = session.oInstall.getLocales() />

<cfoutput>	
	<h1>Project Details</h1>
	<div id="project-details" <cfif session.oUI.stConfig.bInstallDBOnly>style="display:none;"</cfif>>
		<div class="item" style="border-top: 1px solid rgb(227, 227, 227);margin-top: 25px;">
			<div class="item">
		      	<label for="displayName">Project Name <em>*</em></label>
				<div class="field">
					<input type="text" id="displayName" name="displayName" value="#session.oUI.stConfig.displayName#" />
					<div class="fieldHint">Project name is for display purposes only, and can be just about anything you like.</div>
				</div>
				<div class="clear"></div>
			</div>	
			<div class="item">
		      	<label for="applicationName">Project Folder Name <em>*</em></label>
				<div class="field">
					<input type="text" id="applicationName" name="applicationName" value="#session.oUI.stConfig.applicationName#" />
					<div class="fieldHint">Project folder name corresponds to the underlying installation folder and application name of your project.  It must adhere to the standard ColdFusion naming conventions for variables; namely start with a letter and consist of only letters, numbers and underscores.</div>
				</div>
				<div class="clear"></div>
			</div>
			<div class="item">
		      	<label for="applicationName">Locales <em>*</em></label>
				<div class="field">
					<input type="hidden" name="locales" value="" />
					<select id="locales" name="locales" multiple="multiple" size="5">
						<cfloop query="qLocales">
							<option value="#qLocales.value#" <cfif listFindNoCase(session.oUI.stConfig.locales,qLocales.value)>selected="selected"</cfif>>#qLocales.label#</option>
						</cfloop>
					</select>
					<div class="fieldHint">Set the relevant locales for your application.  Just because the locale can be selected does not mean a relevant translation is available.  If in doubt just leave the defaults.</div>
				</div>
				<div class="clear"></div>
			</div>	
		</div>
		
		<div class="item" style="border-top: 1px solid rgb(227, 227, 227);margin-top: 25px;">
			<div class="item">
		      	<label for="applicationName">Update Application Key <em>*</em></label>
				<div class="field">
					<input type="text" id="updateappKey" name="updateappKey" value="#session.oUI.stConfig.updateappKey#" />
					<div class="fieldHint">This is the key that can be used at the end of the url parameter [updateapp] to reinitialise your application. <strong>Administrators can use updateapp=1</strong></div>
				</div>
				<div class="clear"></div>
			</div>
		</div>	
	</div>
	
	
	<div class="item" style="border-top: 1px solid rgb(227, 227, 227);margin-top: 25px;">
		<div class="item">
	      	<label for="displayName">Administrator Password <em>*</em></label>
			<div class="field">
				<input type="text" id="adminPassword" name="adminPassword" value="#session.oUI.stConfig.adminPassword#" />
				<div class="fieldHint">This is the password you will use to log in to your project with the "farcry" username.</div>
			</div>
			<div class="clear"></div>
		</div>	
	</div>

	
	<div class="item" style="border-top: 1px solid rgb(227, 227, 227);margin-top: 25px;">
		<h2>Advanced Users Only</h2>
      	<label for="displayName">Install DB Only <em>*</em></label>
		<div class="field">
			<input type="checkbox" id="bInstallDBOnly" name="bInstallDBOnly" value="1" <cfif session.oUI.stConfig.bInstallDBOnly>checked</cfif> />
			<input type="hidden" id="bInstallDBOnly" name="bInstallDBOnly" value="0" />
			<div class="fieldHint">If you already have a project set and simply want to install the application into a new datasource, select this option. <strong>Advanced users only.</strong></div>
		</div>
		<div class="clear"></div>
	</div>		

	<script type="text/javascript">
	Ext.onReady(function(){	
		var field = Ext.get('bInstallDBOnly');
		field.on('change', checkDBOnly);		
	})
	
	
		
	function checkDBOnly() {
		
		
		
		if(this.dom.checked)
		{
			Ext.get('project-details').slideOut('t', {
			    easing: 'easeIn',
			    duration: .5,
			    useDisplay: true
			});	
			
			Ext.get('applicationName').dom.value = 'dbinstallonly_#right(createUUID(), 5)#';
				
		}
		else 
		{
			
			Ext.get('project-details').slideIn('t', {
			    easing: 'easeOut',
			    duration: .5,
			    remove: false,
			    useDisplay: true
			});
			Ext.get('applicationName').dom.value = '';
		}
	}
	
	</script>	
</cfoutput>

<cfsetting enablecfoutputonly="false" />