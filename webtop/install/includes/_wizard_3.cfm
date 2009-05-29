<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Step 3 --->
<!--- @@description: Skeletons --->

<cfset qSkeletons = session.oInstall.getSkeletons() />

<cfoutput>
	<h1>Project Skeleton</h1>
    <div class="item">
      	<label for="skeleton">Skeleton <em>*</em></label>
		<div class="field">
			<select id="skeleton" name="skeleton">
				<option value="">-- Select Skeleton --</option>
				<cfloop query="qSkeletons">
					<option value="#qSkeletons.value#" <cfif session.oUI.stConfig.skeleton EQ qSkeletons.value>selected="selected"</cfif>>
						#qSkeletons.label# (<cfif qSkeletons.supported>Supported<cfelse>Not supported</cfif>)
					</option>
				</cfloop>
			</select>
			<div class="fieldHint">Skeletons are like sample applications.  They can contain specific templates, functionality and data.  Choose the skeleton that most closely resembles the application you are building.  If in doubt, select <strong>Mollio</strong> &##8212; its a simple web application.</div>
		</div>
		<div class="clear"></div>
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />