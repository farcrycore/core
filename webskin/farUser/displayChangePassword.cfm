<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Change password --->
<!--- @@description: Form for users to change their own password --->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<admin:header title="#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#" />
	
<cfif listfirst(application.security.getCurrentUserID(),"_") eq stObj.userid>
	<ft:processform action="Save">
		<ft:processformobjects objectid="#stobj.objectid#">
			<cfoutput>
				<span class="success">Profile saved</span>
			</cfoutput>
		</ft:processformobjects>
	</ft:processform>
	
	<ft:form heading="#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#">
	
		<cfset stMetadata = structnew() />
		<cfset stMetadata.password.ftRenderType = "changepassword" />
	
		<ft:object objectid="#stObj.objectid#" typename="farUser" lfields="password" stPropMetadata="#stMetadata#" />
		
		<ft:farcrybuttonPanel>
			<ft:farcrybutton value="Save" />
			<ft:farcrybutton value="Cancel" onclick="window.close()" />
		</ft:farcrybuttonPanel>
	</ft:form>
<cfelse>
	<cfoutput>
		<span class="error">You can not edit other users' passwords.</span>
	</cfoutput>
</cfif>
	
<admin:footer />

<cfsetting enablecfoutputonly="false" />