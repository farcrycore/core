<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit user --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset setLock(locked=true,stobj=stobj) />

<!--- Save user and profile --->
<ft:processForm action="Save" Exit="true">
	<ft:processFormObjects typename="farUser" r_stProperties="stUser" />
	<ft:processFormObjects typename="dmProfile" r_stProperties="stProfile">
		<cfset stProfile.username = "#stUser.userid#_CLIENTUD" />
		<cfset stProfile.userdirectory = "CLIENTUD" />
		<cfset stProfile.bActive = true />
	</ft:processFormObjects>
	
	<cfset setLock(locked=false,objectid=stobj.objectid) />
</ft:processForm>

<!--- Cancel edit --->
<ft:processForm action="Cancel" Exit="true">
	<cfset setLock(locked=false,objectid=stobj.objectid) />
</ft:processForm>

<cfset oProfile = createobject("component",application.stCOAPI.dmProfile.packagepath) />
<cfif len(stObj.userid)>
	<cfset stProfile = oProfile.getProfile("#stObj.userid#_CLIENTUD") />
	<cfif not stProfile.bInDB>
		<cfset stProfile = oProfile.getData(objectid=createuuid()) />
	</cfif>
<cfelse>
	<cfset stProfile = oProfile.getData(objectid=createuuid()) />
</cfif>

<ft:form>
	<cfoutput>
		<h1>EDIT: <cfif len(stObj.userid)>#stObj.userid#<cfelse>(incomplete)</cfif></h1>
	</cfoutput>

	<ft:object stobject="#stObj#" format="edit" lfields="userid,password,aGroups,userstatus" legend="User details" />
	
	<skin:view stObject="#stProfile#" webskin="editProfile" />
	
	<ft:farcryButtonPanel>
		<ft:farcrybutton value="Save" />
		<ft:farcrybutton value="Cancel" />
	</ft:farcryButtonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />