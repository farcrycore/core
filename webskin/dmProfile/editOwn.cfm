<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit Personal Profile --->
<!--- @@description: Form for users editing their own profile --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfset stObj = getData(objectid=session.dmProfile.objectid, bUseInstanceCache=false) />

<!--- 
 // process form  
--------------------------------------------------------------------------------->
<ft:processform action="Save" url="refresh">
	<ft:processformobjects typename="#stObj.typename#" objectid="#stobj.objectid#">
		<cfset structappend(session.dmProfile,stProperties,true) />

		<skin:bubble title="Profile Saved" bAutoHide="false" tags="type,dmProfile,update,info">
			<cfoutput>Your profile has been saved. You can always update your profile by using the dropdown menu by your name in the top right.</cfoutput>
		</skin:bubble>
		
		<cfset session.firstLogin = false />
	</ft:processformobjects>
</ft:processform>


<!--- 
 // view: personal edit handler 
--------------------------------------------------------------------------------->
<cfif session.firstLogin>
	<cfoutput>
		<h1>Welcome to FarCry</h1>
		<p>This seems to be the first time you've logged into the webtop. Please update your profile now.</p>
	</cfoutput>
<cfelse>
	<cfoutput>
		<h1>#application.rb.getResource('coapi.dmProfile.general.editprofile@label','Edit Your Profile')#</h1>
	</cfoutput>
</cfif>

<ft:form>
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" 
		lfields="firstname,lastname,avatar,emailaddress,phone,breceiveemail" 
		legend="Personal Details" />
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" 
		lfields="locale,timeFormat" 
		legend="Webtop Settings" />
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" 
		lfields="userName,lastLogin" format="display" 
		legend="Login Details" />
	
	<ft:buttonPanel>
		<ft:button value="Save" text="Update Profile" color="orange" />
		<ft:button value="Cancel" validation="false" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />