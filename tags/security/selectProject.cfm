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
							<select name="selectFarcryProject" id="selectFarcryProject" onchange="window.location='#application.fapi.getLink(href=application.url.webtoplogin,urlParameters='farcryProject=+this.value')#';">
								<cfloop from="1" to="#arraylen(aDomainProjects)#" index="i">
									<cfif len(aDomainProjects[i])>
										<option value="#aDomainProjects[i]#"<cfif cookie.currentFarcryProject eq aDomainProjects[i]> selected="selected"</cfif>>#server.stFarcryProjects[aDomainProjects[i]].displayname#</option>
									</cfif>
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