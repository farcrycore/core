<cfcomponent extends="forms" displayname="Farcry Form Theme" output="false"
	hint="The form for Handling webskins to render farcry forms">

	<cffunction name="getDefaultFormtoolInputClasses" output="false" returntype="struct"
		hint="Extend this method in your UI specific form theme component to provide default input field class attribute values for each formtool that requires it">

		<cfset var stClasses = {
			"array" = "",
			"arrayList" = "",
			"arrayupload" = "",
			"boolean" = "",
			"category" = "",
			"country" = "",
			"creditcardcvv" = "",
			"creditcardexpiry" = "",
			"creditcardnumber" = "",
			"creditcardtype" = "",
			"datetime" = "",
			"email" = "",
			"field" = "",
			"file" = "",
			"hidden" = "",
			"image" = "",
			"integer" = "",
			"join" = "",
			"list" = "",
			"longchar" = "",
			"navigation" = "",
			"numeric" = "",
			"password" = "",
			"permissions" = "",
			"reversearray" = "",
			"reverseuuid" = "",
			"richtext" = "",
			"state" = "",
			"string" = "",
			"typeahead" = "",
			"url" = "",
			"uuid" = "",
			"video" = "",
			"webskin" = ""
		}>

		<cfreturn stClasses>
	</cffunction>

	<cffunction name="getFormtoolInputClass" output="false" returntype="string">
		<cfargument name="formtool" required="true" type="string">

		<cfset var stClasses = getDefaultFormtoolInputClasses()>
		<cfset var classname = "">

		<cfif structKeyExists(stClasses, arguments.formtool)>
			<cfset classname = stClasses[arguments.formtool]>
		</cfif>

		<cfreturn classname>
	</cffunction>

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