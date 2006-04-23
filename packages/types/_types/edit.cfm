<!--- Get the properties for the object --->
		<cfset props = getMetaData(this).properties>
		<!--- Create a structure to hold the form fields --->
		<cfset stReturn = structNew()>
		
		<cfif isDefined('arguments.objectid')>
			<cfset stInput = structNew()>
			<cfset stInput.objectid = arguments.objectid>
			<cfset tmp = getData(argumentcollection=stInput)>
			<cfloop collection="#tmp#" item="i">
			<cfset this[i] = tmp[i]>
			</cfloop>
		</cfif>
		
		<!--- Loop over the properties invoking the editControl method on each of them --->
		<cfloop from="1" to="#arraylen(props)#" index="i">
			<!--- Create a shortcut name for the property --->
			<cfset thisprop = props[i]>
			
			<!--- By default we assume that we should create a form field for this property --->
			<cfparam name="thisprop.createFormField" default="true" type="boolean">
			
			<cfif thisProp.createFormField>
			
				<!--- Create a structure in stReturn for this property --->
				<cfset stReturn[thisprop.name] = structNew()>
				<!--- Create a default value for the property --->
				<cfparam name="thisprop.default" default="">
				<!--- Check if this property exists in the current object --->
				<cfif not structKeyExists(this,thisprop.name)>
					<!--- Assign the default value for the property --->
					<cfset this[thisprop.name] = thisprop.default>
				</cfif>
				
				<cfparam name="arguments.stEditFields" default="#structNew()#">
				
				
				<!--- Check which edit method to use for this property --->
				<cfif StructKeyExists(arguments.stEditFields,thisprop.name) and structKeyExists(arguments.stEditFields[thisprop.name],'editmethod')>
					<cfset method = arguments.stEditFields[thisprop.name].editmethod>
				<cfelseif isDefined('thisprop.editmethod')>
					<cfset method = thisprop.editmethod>
				<cfelse>
					<cfset method = 'editControl'>
				</cfif>
				
				<!--- Create a structure to hold the editor properties for this method --->
				<cfset stEditProps = structNew()>
				
				<!--- Add any properties defined in the cfproperty tag --->
				<cfif isDefined('thisprop.editProps')>
					<cfset stEditProps = structNew()>
					<cfloop list="#thisprop.editProps#" index="i" delimiters=";">
					<cfset stEditProps[listFirst(i,':')] = listlast(i,':')>
					</cfloop>
				</cfif>
				
				<!--- Update the stEditProps structure with any properties which
				have been explicitly passed in --->
				<cfif StructKeyExists(arguments.stEditFields,thisprop.name) and structkeyExists(arguments.stEditFields[thisprop.name],'props')>
					<cfset null = structAppend(stEditProps,arguments.stEditFields[thisprop.name]['props'],true)>
				</cfif>
				
				
				<!--- Invoke the editControl method and pass the fieldname and value arguments --->
				<cfinvoke component="4q.properties.#thisprop.type#" method="#method#" returnvariable="html">
					<cfinvokeargument name="fieldname" value="#thisprop.name#">
					<cfinvokeargument name="value" value="#this[thisprop.name]#">
					<cfinvokeargument name="editProps" value="#stEditProps#">
				</cfinvoke>
				
				<!--- Check if we need to build the validation function call --->
				<cfif isDefined('thisprop.validationtype')>
				
					<cfparam name="thisprop.validationmessage" default="Error in form field">
					<cfparam name="thisprop.regex" default="^.+$">
					
					<cfinvoke component="4q.properties.#thisprop.type#" method="clientValidation" returnvariable="validation">
						<cfinvokeargument name="validationtype" value="#thisprop.validationtype#">
						<cfinvokeargument name="validationmessage" value="#thisprop.validationmessage#">
						<cfinvokeargument name="regex" value="#thisprop.regex#">
						<cfinvokeargument name="fieldname" value="#thisprop.name#">
					</cfinvoke>
					<!--- Add the html returned to the stReturn structure --->
					<cfset stReturn[thisprop.name].validate = validation>
				</cfif>
				
				<!--- Add the html returned to the stReturn structure --->
				<cfset stReturn[thisprop.name].formfield = html>
			</cfif>
		</cfloop>