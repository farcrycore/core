<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: UD Login Select --->
<!--- @@description: Creates a select list so that users can log into the supported user directories --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfif thistag.ExecutionMode eq "Start">
	<cfif listlen(application.security.getAllUD()) GT 1>
		<ft:fieldset>
			<ft:field label="Select User Directory" for="selectuserdirectories" rbkey="security.login.selectuserdirectory">
			
				<cfoutput><select name="selectuserdirectories" id="selectuserdirectories" onchange="window.location=this.value;"></cfoutput>
				
				<cfloop list="#application.security.getAllUD()#" index="thisud">
					<cfoutput>
						<option value="#application.fapi.getLink(href=application.url.webtoplogin,urlParameters='ud=#thisud#')#"<cfif application.security.getDefaultUD() eq thisud> selected="selected"</cfif>>#application.security.userdirectories[thisud].title#</option>
					</cfoutput>
				</cfloop>
				
				<cfoutput></select></cfoutput>
		
			</ft:field>
		</ft:fieldset>	
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />