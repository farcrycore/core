<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Installation wizard --->
<!--- @@description: Encapsulates the HTML and wizard navigation for install configuration --->

<cfset stErrors = structnew() />

<!--- Determine if a step needs to be processed --->
<cfif structKeyExists(form, "farcrySubmitButton")>
	<cfif structKeyExists(form, "currentStep")>
		<cfif form.currentStep><!--- Run for all step processing --->
			<cfloop collection="#form#" item="field">
				<cfif findNoCase("addWebrootMapping", field) OR findNoCase("bInstallDBOnly", field)>
					<cfset session.oUI.stConfig[field] = listFirst(form[field]) />
				<cfelse>
					<cfset session.oUI.stConfig[field] = form[field] />
				</cfif>
				
				<cfif len(session.oUI.stConfig.DBOwner) AND right(session.oUI.stConfig.DBOwner,1) NEQ ".">
					<cfset session.oUI.stConfig.DBOwner = "#session.oUI.stConfig.DBOwner#." />
				</cfif>
			</cfloop>
			
			<cfif session.oUI.stConfig.bInstallDBOnly>
				<cfset session.oUI.stConfig.projectInstallType = "CFMapping" />
			</cfif>
		</cfif>
		
		<cfif form.currentStep eq 1 or form.currentStep eq 6>
			<cfif not session.oUI.stConfig.bInstallDBOnly>
				<cfset structappend(stErrors,session.oInstall.validateDetails(session.oUI.stConfig)) />
			</cfif>
		</cfif>
		
		<cfif form.currentStep eq 2 or form.currentStep eq 6>
			<cfset structappend(stErrors,session.oInstall.validateDatabase(session.oUI.stConfig)) />
		</cfif>
		
		<cfif form.currentStep eq 3 or form.currentStep eq 6>
			<cfset structappend(stErrors,session.oInstall.validateSkeleton(session.oUI.stConfig)) />
		</cfif>
		
		<cfif form.currentStep eq 4 or form.currentStep eq 6>
			<cfset structappend(stErrors,session.oInstall.validatePlugins(session.oUI.stConfig)) />
		</cfif>
		
		<cfif form.currentStep eq 5 or form.currentStep eq 6>
			
		</cfif>
		
		<cfif form.currentStep eq 6 and form.farcrySubmitButton EQ "INSTALL NOW">
			<cfset session.oUI.currentStep = "install" />
		</cfif>
		
		<cfloop collection="#stErrors#" item="thisfield">
			<cfif not thisfield eq "plugins">
				<cfoutput>
					<script type="text/javascript">
						Ext.onReady(function(){	
							var errorField = Ext.get('#thisfield#')
							errorField.boxWrap();
							errorField.insertHtml('afterEnd', '#jsstringFormat("<div><h3>Error</h3><p>#stErrors[thisfield]#</p></div>")#');
							
						})
					</script>
				</cfoutput>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfif structisempty(stErrors)>
		<!--- Update the completed steps to include the one just posted. --->
		<cfif not listFindNoCase(session.oUI.lCompletedSteps, form.currentStep)>
			<cfset session.oUI.lCompletedSteps = listAppend(session.oUI.lCompletedSteps, form.currentStep) />
		</cfif>
		
		<!--- Set to next step --->
		<cfif form.farcrySubmitButton EQ "Next">
			<cfset session.oUI.currentStep = form.currentStep + 1 />
		</cfif>
		
		<!--- Set to previous step --->
		<cfif form.farcrySubmitButton EQ "Previous">
			<cfset session.oUI.currentStep = form.currentStep - 1 />
		</cfif>
		
		<!--- Set to requested step only if it has previously been completed. This protects against session timeouts --->
		<cfif form.farcrySubmitButton EQ "GoToStep" and isNumeric(form.GoToStep)>
			<cfif listFindNoCase(session.oUI.lCompletedSteps, form.GoToStep)>
				<cfset session.oUI.currentStep = form.GoToStep />
			<cfelse>
				<cfset session.oUI.currentStep = 1 />
			</cfif>
		</cfif>
		
	</cfif>
	
</cfif>

<cfif not session.oUI.currentstep eq "install">
	<!--- Form and wizard nav --->
	<cfoutput>
		<form action="#cgi.script_name#" method="post" name="installForm">
			<input type="hidden" id="goToStep" name="goToStep" value="" />
			<input type="hidden" name="currentStep" value="#session.oUI.currentStep#" />
			<div style="margin-bottom:25px;">
				<div style="background:url(images/dots.gif) repeat-x center;">
					<table align="center">
						<tr>
	</cfoutput>
							
	<cfloop from="1" to="6" index="i">
		
		<cfif i EQ session.oUI.currentStep>
			<cfset iconType = 1 />
		<cfelseif listFindNoCase(session.oUI.lCompletedSteps, i)>
			<cfset iconType = 0 />
		<cfelse>
			<cfset iconType = 2 />
		</cfif>
		
		<cfoutput>
			<td align="center" style="width:60px;">
				<cfif iconType EQ 0>
					<input type="image" name="farcrySubmitButton" value="goToStep" src="images/function_#i#_#iconType#.gif" onclick="Ext.get('goToStep').set({value:'#i#'},false);" />
				<cfelse>
					<img src="images/function_#i#_#iconType#.gif" alt="" />
				</cfif>
				
			</td>
		</cfoutput>
		
	</cfloop>
						
	<cfoutput>
						</tr>
					</table>
				</div>
			</div>
	</cfoutput>
	
	<!--- Step HTML --->
	<cfinclude template="_wizard_#session.oUI.currentstep#.cfm" />
	
	<!--- Form submit --->
	<cfoutput><div style="text-align:right;margin-top:25px;"></cfoutput>
	<cfif session.oUI.currentstep EQ 1>
		<cfoutput><input type="submit" name="farcrySubmitButton" value="Next" /></cfoutput>
	<cfelseif session.oUI.currentstep EQ 6>
		<cfoutput>
			<input type="submit" name="farcrySubmitButton" value="Previous" />
			<input type="submit" name="farcrySubmitButton" value="INSTALL NOW" />
		</cfoutput>
	<cfelse>
		<cfoutput>
			<input type="submit" name="farcrySubmitButton" value="Previous" />
			<input type="submit" name="farcrySubmitButton" value="Next" />
		</cfoutput>
	</cfif>
	<cfoutput></div></cfoutput>
	
	<cfoutput>
		</form>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />