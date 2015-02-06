<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Change Password --->
<!--- @@description: Form for users to change their own password --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<ft:serverSideValidation />

<cfset stUser = getByUserId(application.factory.oUtils.listSlice(session.security.userid,1,-2,"_")) />
<cfset stObj = stUser />

<!--- user can only update their own password --->	
<cfif NOT application.factory.oUtils.listSlice(application.security.getCurrentUserID(),1,-2,"_") eq stObj.userid>
	<cfthrow message="Invalid Password Change" detail="You cannot edit other user passwords." />
</cfif>

<!----------------------------- 
ACTION	
------------------------------>
<ft:processform action="Save">
	<ft:validateFormObjects typename="farUser" objectid="#stobj.objectid#" />

	<cfif request.stFarcryFormValidation.bSuccess>
		<ft:processformobjects objectid="#stobj.objectid#" />
		<skin:bubble title="Your password has been updated" rbkey="coapi.farUser.changepassword.passwordchanged" tags="security,info" />
	</cfif>
</ft:processform>

<!----------------------------- 
VIEW	
------------------------------>
<admin:header>

<cfoutput><h1>#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#</h1></cfoutput>

<ft:form>
	<cfset stMetadata = structnew() />
	<cfset stMetadata.password.ftRenderType = "changepassword" />
	<cfset stMetadata.password.ftLabel = "Your Profile Password" />

	<!--- Paranoid security precaution: don't give the stored password to the form renderer --->
	<cfset stObj.password = "" />
	<ft:object stObject="#stObj#" typename="farUser" lfields="password" stPropMetadata="#stMetadata#" IncludeFieldSet="false"  />

	<ft:buttonPanel>
		<ft:button value="Save" text="Change Password" color="orange" />
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>

<admin:footer>

<cfsetting enablecfoutputonly="false" />