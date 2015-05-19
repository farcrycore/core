<cfcomponent extends="formTheme" displayname="Uni-Form Form Theme" output="false"
	hint="The form for Handling webskins to render farcry forms">

	<cffunction name="getValidationConfig" output="false" returntype="struct"
		hint="The jQuery Validate selector configuration for handling the display of validation messages within forms">

		<cfset var stValConfig = structNew()>

		<cfset stValConfig.wrapper = "">
		<cfset stValConfig.errorElement = "p">
		<cfset stValConfig.errorElementClass = "errorField">
		<cfset stValConfig.errorPlacementSelector = "div.ctrlHolder">
		<cfset stValConfig.fieldContainerSelector = "div.ctrlHolder">
		<cfset stValConfig.fieldContainerClass = "error">

		<cfreturn stValConfig>
	</cffunction>

</cfcomponent>