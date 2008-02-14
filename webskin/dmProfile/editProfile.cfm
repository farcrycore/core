<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit profile --->
<!--- @@description: Form for users editing their own profile --->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<admin:header title="#application.rb.getResource('coapi.dmProfile.general.editprofile@label','Edit your profile')#" />
	
<cfif application.security.getCurrentUserID() eq stObj.username>
	<ft:processform action="Save">
		<ft:processformobjects objectid="#stobj.objectid#">
			<cfoutput>
				<span class="success">Profile saved</span>
			</cfoutput>
			<cfset session.firstLogin = false />
		</ft:processformobjects>
	</ft:processform>
	
	<cfif session.firstLogin>
		<cfoutput><p class="success">This is the first time you've logged into the webtop. Please complete your profile form with your details.</p></cfoutput>
	</cfif>
	
	<ft:form heading="#application.rb.getResource('coapi.dmProfile.general.editprofile@label','Edit your profile')#">
		<ft:object objectid="#stObj.objectid#" typename="dmProfile" lfields="firstname,lastname,breceiveemail,emailaddress,phone,fax,position,department,locale" />
		
		<ft:farcrybuttonPanel>
			<ft:farcrybutton value="Save" />
			<ft:farcrybutton value="Cancel" onclick="window.close()" />
		</ft:farcrybuttonPanel>
	</ft:form>
<cfelse>
	<cfoutput>
		<span class="error">You can not edit other users' profiles.</span>
	</cfoutput>
</cfif>
	
<admin:footer />

<cfsetting enablecfoutputonly="false" />