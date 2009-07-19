<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit user password --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<ft:processform action="Save" exit="true">
	<ft:processformobjects typename="farUser" />
</ft:processform>

<ft:processform action="Cancel" exit="true" />


<admin:header />

<cfoutput>
	<h1>CHANGE PASSWORD: #stObj.userid#</h1>
</cfoutput>

<ft:form>
	<cfset stPropMetadata = structnew() />
	<cfset stPropMetadata.password.ftValidation = "required" />
	<ft:object stObject="#stObj#" typename="farUser" lfields="password" includeFieldSet="false" stPropMetadata="#stPropMetadata#" />
	
	<ft:buttonPanel>
		<ft:button value="Save" color="orange" />
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>

<admin:footer />

<cfsetting enablecfoutputonly="false" />