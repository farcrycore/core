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
<ft:processform action="Save" exit="true">
	<ft:processformobjects typename="farUser" r_stProperties="stUser" />
	<ft:processformobjects typename="dmProfile">
		<cfif stProperties.userdirectory eq ""><!--- New user --->
			<cfset stProperties.username = "#stUser.userid#_CLIENTUD" />
			<cfset stProperties.userdirectory = "CLIENTUD" />
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
	<ft:object objectid="#stObj.objectid#" typename="dmProfile" lfields="firstname,lastname,breceiveemail,emailaddress,phone,fax,position,department,locale,overviewHome" lhiddenFields="userdirectory" legend="User details" />
	
	<cfif stObj.userdirectory eq "CLIENTUD" or stObj.userdirectory eq "">
		
		<cfif stObj.username eq "">
			<cfset stUser = oUser.getData(objectid=createuuid()) />
			<cfset stUser.userdirectory = "CLIENTUD" />
			<cfset lFields = "userid,password,userstatus,aGroups" />
		<cfelse>
			<cfset stUser = oUser.getByUserID(listfirst(stObj.username,"_")) />
			<cfset lFields = "userstatus,aGroups" />
		</cfif>
		
		<ft:object stObject="#stUser#" typename="farUser" lfields="#lFields#" legend="Security" />
	</cfif>
	
	<ft:farcryButtonPanel>
		<ft:button value="Save" color="orange" />
		<ft:button value="Cancel" />
	</ft:farcryButtonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />