<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Change Password --->
<!--- @@description: Form for users to change their own password --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<cfset stUser = getByUserId(application.factory.oUtils.listSlice(session.security.userid,1,-2,"_")) />
<cfif structkeyexists(stObj,"bDefaultObject") and stObj.bDefaultObject>
	<cfset stObj = stUser />
</cfif>

<!--- user can only update their own password --->	
<cfif NOT application.factory.oUtils.listSlice(application.security.getCurrentUserID(),1,-2,"_") eq stObj.userid>
	<cfthrow message="Invalid Password Change" detail="You cannot edit other user passwords." />
</cfif>

<!----------------------------- 
ACTION	
------------------------------>
<ft:processform action="Save">
	<ft:validateFormObjects objectid="#stobj.objectid#" />
	
	<ft:processformobjects objectid="#stobj.objectid#" />
	<cfoutput>
		<span class="success">Your password has been updated.</span>
	</cfoutput>
</ft:processform>

<ft:processform action="Save,Cancel" url="#application.url.webtop#/overview/home.cfm?UPDATEAPP=false&sec=home&SUB=overview" />

<!----------------------------- 
VIEW	
------------------------------>
<ft:form heading="#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#">

	<cfset stMetadata = structnew() />
	<cfset stMetadata.password.ftRenderType = "changepassword" />
	<cfset stMetadata.password.ftLabel = "Your Profile Password" />

	<ft:object objectid="#stObj.objectid#" typename="farUser" lfields="password" stPropMetadata="#stMetadata#" IncludeFieldSet="false"  />

	<ft:buttonPanel>
		<ft:button value="Save" text="Change Password" color="orange" />
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>


<cfsetting enablecfoutputonly="false" />