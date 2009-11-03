<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit Profile --->
<!--- @@description: Form for users editing their own profile --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfset oUser = createobject("component",application.stCOAPI.farUser.packagepath) />


<!----------------------------- 
ACTION	
------------------------------>
<ft:serverSideValidation />

<ft:processform action="Save" exit="true">
	<ft:processformobjects typename="farUser" lArrayListGenerate="lgroups" />
	
	<!--- track whether we have saved a farUser record--->
	<cfset savedUserID = lsavedobjectids />
	
	<ft:processformobjects typename="dmProfile">
		
		<!--- We only check the profile/faruser relationship if we saved a CLIENTUD user --->
		<cfif len(savedUserID)>
			<cfset stUser = oUser.getData(objectid=savedUserID) />
			
			<!--- If the current username is not the same one we saved (ie. new user) --->
			<cfif stProperties.username NEQ "#stUser.userid#_CLIENTUD"><!--- New user --->
				<cfset stProperties.username = "#stUser.userid#_CLIENTUD" />
				<cfset stProperties.userdirectory = "CLIENTUD" />
			</cfif>
		</cfif>			
		
	</ft:processformobjects>
</ft:processform>

<ft:processform action="Cancel" exit="true" />


<!----------------------------- 
VIEW	
------------------------------>
<cfoutput>
	<h1>EDIT: #listfirst(stObj.username,"_")# - #stObj.userdirectory#</h1>
</cfoutput>

<ft:form>
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" lfields="firstname,lastname,breceiveemail,emailaddress,phone,fax,position,department,locale,overviewHome" lhiddenFields="username,userdirectory" legend="User details" />
	
	<cfif stObj.userdirectory eq "CLIENTUD" or stObj.userdirectory eq "">

		<cfset userID = application.factory.oUtils.listSlice(stObj.username,1,-2,"_") />
		<cfset stUser = oUser.getByUserID(userID) />
		
		<cfif structIsEmpty(stUser) or stUser.userid eq "">
			<skin:view key="newprofileuser" typename="farUser" webskin="editProfileUser" />
		<cfelse>
			<ft:object stObject="#stUser#" typename="farUser" lfields="userstatus,aGroups" legend="Security" />
		</cfif>
		
	</cfif>
	
	<ft:farcryButtonPanel>
		<ft:button value="Save" color="orange" />
		<ft:button value="Cancel" validate="false" />
	</ft:farcryButtonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />