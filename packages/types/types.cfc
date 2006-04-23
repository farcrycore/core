<!--- 
Component Types
Abstract class for contenttypes package.  This class defines default 
handlers and system attributes.
 ---> 
<cfcomponent extends="fourq.fourq" bAbstract="true" displayname="Base Content Type" hint="Abstract class. Provides default handlers and system attributes for content object types.">

<!--------------------------------------------------------------------
system attributes
  properties that all types require
--------------------------------------------------------------------->	
<cfproperty name="ObjectID" type="UUID" hint="Primary key." required="yes">
<cfproperty name="label" type="string" hint="Object label or title." required="no" default="(not specified)"> 
<cfproperty name="datetimecreated" type="date" hint="Timestamp for record creation." required="yes" default=""> 
<cfproperty name="createdby" type="string" hint="Username for creator." required="yes" default=""> 
<cfproperty name="datetimelastupdated" type="date" hint="Timestamp for record last modified." required="yes" default=""> 
<cfproperty name="lastupdatedby" type="string" hint="Username for modifier." required="yes" default="">

<!--------------------------------------------------------------------
default handlers
  handlers that all types require
  these will likely be overloaded in production
--------------------------------------------------------------------->	
	<cffunction name="getDisplay" access="public" output="Yes">
		<cfargument name="objectid" required="yes" type="UUID">
		<cfargument name="template" required="yes" type="string">
		<!--- get the data for this instance --->
		<cfset stObj = getData(arguments.objectID)>		
		<!--- check to see if the displayMethod template exists --->
		<cfif NOT fileExists("#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm")>
		<cfabort showerror="Error: Template not found [#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm].">
		</cfif>
		

		<cfinclude template="/#application.applicationname#/#application.path.handler#/#stObj.typename#/#arguments.template#.cfm">
	</cffunction>

	<cffunction name="display" access="public" returntype="any" output="Yes">
		<cfargument name="objectid" required="yes" type="UUID">
		<cfoutput><p>This is the default output of <strong>types.Display()</strong>:</p></cfoutput>
		<cfset myObject = getData(arguments[1])>
		<cfdump var="#myObject#">
	</cffunction>

	<cffunction name="edit" access="public" output="true" returntype="struct">
		<!--- 
		Properties code not quite running yet...
		GB 20020518
		<cfinclude template="_types/edit.cfm"> 
		--->
		<cfoutput>
		This is the default types.edit() handler.  You need to build an edit interface!
		</cfoutput>
		<cfset stReturn = structNew()>
		<cfreturn stReturn>
	</cffunction>
	
	<cffunction name="processForm" access="public" output="Yes" returntype="struct">
		<cfargument name="formdata" required="yes" type="struct">
		<!--- Get the properties for the object --->
		<cfset props = getMetaData(this).properties>
		<!--- Create a structure to hold the results --->
		<cfset stProperties = structNew()>
		<!--- Create a structure to hold error data --->
		<cfset stErrors = structNew()>
		<!--- Loop over the properties invoking the processData method on each of them --->
		<cfloop from="1" to="#arraylen(props)#" index="i">
			<!--- Create a shorthand for the current property --->
			<cfset thisprop = props[i]>
			
			<!--- By default we assume that we should create a form field for this property --->
			<cfparam name="thisprop.createFormField" default="true" type="boolean">
			
			<!--- Assume that we want to process this field by default --->
			<cfset processfield = true>
			
			<!--- Check if a form field was created for this property. If so, 
			assign that value to the propertydata variable --->
			<cfif thisProp.createFormField>
				<cfset propertydata = formdata[thisprop.name]>
			<!--- Check if there is a default value. If so, evaluate
			that value and assign it to the propertdata variable --->
			<cfelseif isDefined('thisprop.default')>
				<cfset propertydata = evaluate(thisprop.default)>
			<!--- This property does not need to be processed --->
			<cfelse>
				<cfset processfield = false>
			</cfif>
			
			<!--- Check if we need to process the field --->
			<cfif processfield>
			
				<!--- Inovke the processFormField method for this property --->
				<cfinvoke component="4q.properties.#thisprop.type#" method="processFormField" returnvariable="results">
					<cfinvokeargument name="fieldData" value="#propertydata#">
					<cfinvokeargument name="propertyname" value="#thisprop.name#">
					<cfif isDefined('thisprop.validationtype')>
						<cfparam name="thisprop.regex" default="^.*$">
						<cfinvokeargument name="validationtype" value="#thisprop.validationtype#">
						<cfinvokeargument name="validationmessage" value="#thisprop.validationmessage#">
						<cfinvokeargument name="regex" value="#thisprop.regex#">
					</cfif>
				</cfinvoke>
				<!--- insert the results from the previous operation into stReturn --->
				<cfloop collection="#results#" item="i">
					<cfset stProperties[i] = results[i].data>
					<cfif not results[i].success>
						<cfset stErrors[i] = results[i].message>
					</cfif>
				</cfloop>
			</cfif>
			
			<!--- Check if this property is supposed to be inserted into the database.
			If not, remove it from the stReturn structure --->
			<cfparam name="thisprop.addToDb" type="boolean" default="true">
			<cfif not thisprop.addToDb>
				<cfset null = structDelete(stProperties,thisprop.name)>
			</cfif>
		</cfloop>
	
		<!--- create a structure to hold the properties --->
		<cfset stInput = structNew()>
		<cfset stInput.stProperties = stProperties>
		
		<!--- Check if there were any processing errors. If not, add the data to the db --->
		<cfif structIsEmpty(stErrors)>
			<!--- Set the success to true --->
			<cfset stReturn.success = true>
			<!--- Check if the objectid is a valid uuid --->
			<cfif len(stInput.stProperties.objectid) NEQ len(createuuid())>
				<!--- Must be a new object so we use createData() --->
				<cfset stInput.stProperties.objectid = createuuid()>
				<cfset result = this.createData(argumentCollection=stInput)>
			<cfelse>
				<!--- Must be an existing object so we use setData()--->
				<cfset result = this.setData(argumentCollection=stInput)>
			</cfif>
			
		<cfelse>
			<!--- set the success variable to false --->
			<cfset stReturn.success = false>
		</cfif>
		<!--- Add the data and errors to the stReturn structure --->
		<cfset stReturn.properties = stInput.stProperties>
		<cfset stReturn.stErrors = stErrors>
		
		<cfreturn stReturn>
	</cffunction>
	
</cfcomponent>

