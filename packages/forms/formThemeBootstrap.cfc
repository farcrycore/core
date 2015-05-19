<cfcomponent extends="formTheme" displayname="Bootstrap 2.3.2+ Form Theme" output="false" 
	hint="The form for Handling webskins to render farcry forms">

	<cffunction name="getValidationConfig" output="false" returntype="struct"
		hint="The jQuery Validate selector configuration for handling the display of validation messages within forms">

		<cfset var stValConfig = structNew()>

		<cfset stValConfig.wrapper = "">
		<cfset stValConfig.errorElement = "p">
		<cfset stValConfig.errorElementClass = "text-error">
		<cfset stValConfig.errorPlacementSelector = "div.control-group">
		<cfset stValConfig.fieldContainerSelector = "div.control-group">
		<cfset stValConfig.fieldContainerClass = "error">

		<cfreturn stValConfig>
	</cffunction>

</cfcomponent>