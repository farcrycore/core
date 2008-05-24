<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Change Password --->
<!--- @@description: Form for users to change their own password --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<!--- user can only update their own password --->	
<cfif NOT listfirst(application.security.getCurrentUserID(),"_") eq stObj.userid>
	<cfthrow message="Invalid Password Change" detail="You cannot edit other user passwords." />
</cfif>

<!----------------------------- 
ACTION	
------------------------------>
<ft:validateFormObjects objectid="#stobj.objectid#" />

<ft:processform action="Save">
	<ft:processformobjects objectid="#stobj.objectid#" />
	<cfoutput>
		<span class="success">Your password has been updated.</span>
	</cfoutput>
</ft:processform>


<!----------------------------- 
VIEW	
------------------------------>
<ft:form heading="#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#">

	<cfset stMetadata = structnew() />
	<cfset stMetadata.password.ftRenderType = "changepassword" />
	<cfset stMetadata.password.ftLabel = "Your Profile Password" />

	<ft:object objectid="#stObj.objectid#" typename="farUser" lfields="password" stPropMetadata="#stMetadata#" IncludeFieldSet="false"  />

	<ft:farcryButtonPanel>
		<ft:button value="Save" text="Change Password" color="orange" />
		<ft:button value="Cancel" />
	</ft:farcryButtonPanel>
</ft:form>


<cfsetting enablecfoutputonly="false" />