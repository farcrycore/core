<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Project drop down list --->

<cfif thistag.ExecutionMode eq "end">
	<cfif structKeyExists(server, "stFarcryProjects") AND structcount(server.stFarcryProjects) GT 1>
		<cfset aDomainProjects = arraynew(1) />
		<cfloop collection="#server.stFarcryProjects#" item="thisproject">
			<cfif isstruct(server.stFarcryProjects[thisproject]) and listcontains(server.stFarcryProjects[thisproject].domains,cgi.http_host)>
				<cfset arrayappend(aDomainProjects,thisproject) />
			</cfif>
		</cfloop>
		
		<cfif arraylen(aDomainProjects) gt 1>
			<cfoutput>
				<fieldset class="formSection">
					<legend>Project Selection</legend>
					<div class="fieldSection string">
						<label class="fieldsectionlabel" for="selectFarcryProject"> Project  : </label>
						<div class="fieldAlign">
							<select id="selectFarcryProject" onchange="window.location='#application.url.webtop#/login.cfm?returnUrl=#urlencodedformat(url.returnUrl)#&farcryProject='+this.value;">						
								<cfloop from="1" to="#arraylen(aDomainProjects)#" index="i">
									<option value="#thisProject#"<cfif cookie.currentFarcryProject eq thisProject> selected</cfif>>#server.stFarcryProjects[aDomainProjects[i]].displayname#</option>
								</cfloop>						
							</select>
						</div>
						<br class="clearer"/>
					</div>	
				</fieldset>
			</cfoutput>
		</cfif>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />