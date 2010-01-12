<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit Generic User --->

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
	<ft:processformobjects typename="dmProfile" />
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
	
	<ft:buttonPanel>
		<ft:button value="Save" color="orange" />
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />