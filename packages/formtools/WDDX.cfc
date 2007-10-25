<cfcomponent displayname="WDDX form" hint="Provides a way to specify a form to encode as WDDX" extends="field" output="false">

	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.WDDX" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var stObj = structnew() /><!--- Used to store the current set of values --->
		<cfset var ReturnHTML = "" /><!--- The output for the field --->
		<cfset var prefix = "" /><!--- The form id for this field --->
		<cfset var stForms = structnew() /><!--- The forms that can be used --->
		<cfset var thisform = "" /><!--- Loop variable for form names --->
		
		<!--- By default, let the user select all forms --->
		<cfparam name="arguments.stMetadata.ftForm" default="" />
		
		<!--- By default let the user change the form after it has been selected --->
		<cfparam name="arguments.stMetadata.ftChangable" default="true" />
		
		<!--- Get struct of forms and form names --->
		<cfloop list="#application.factory.oUtils.getComponents('forms')#" index="thisform">
			<cfif refindnocase("^#arguments.stMetadata.ftForm#",thisform) and structkeyexists(application.stCOAPI,thisform)>
				<cfset stForms[thisform] = application.stCOAPI[thisform].displayname />
			</cfif>
		</cfloop>
		
		<cfif len(arguments.stMetadata.value)>
			<!--- If the field already has a value then use that --->
			<cfwddx action="wddx2cfml" input="#arguments.stMetadata.value#" output="stObj" />
			
			<cfsavecontent variable="ReturnHTML">
				<cfif arguments.stMetadata.ftChangable>
					<cfoutput>
						<select name="#arguments.fieldname#formname">
							<cfloop collection="#stForms#" item="thisform">
								<option value="#thisform#"<cfif thisform eq stObj.typename> selected</cfif>>#stForms[thisform]#</option>
							</cfloop>
						</select>
						<br class="clearer" />
					</cfoutput>
				<cfelse>
					<cfoutput>
						<input type="hidden" name="#arguments.fieldname#formname" value="#stObj.typename#" />
					</cfoutput>
				</cfif>
				
				<ft:object typename="#arguments.stMetadata.ftForm#" stObject="#stObj#" r_stPrefix="prefix" />
				
				<cfoutput>
					<input type="hidden" name="#arguments.fieldname#objectid" value="#stObj.objectid#" />
					<input type="hidden" name="#arguments.fieldname#" value="#htmlEditFormat(arguments.stMetadata.value)#" />
				</cfoutput>
			</cfsavecontent>
		<cfelse>
			<!--- Otherwise just use a default  form --->
			<cfsavecontent variable="ReturnHTML">
				<cfoutput>
					<select name="#arguments.fieldname#formname">
						<cfloop collection="#stForms#" item="thisform">
							<option value="#thisform#">#stForms[thisform]#</option>
						</cfloop>
					</select>
					
					<input type="hidden" name="#arguments.fieldname#" value="" />
				</cfoutput>
			</cfsavecontent>
		</cfif>
		
 		<cfreturn ReturnHTML>
		
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var stObj = structnew() /><!--- Used to store the current set of values --->
		<cfset var ReturnHTML = "" /><!--- The output for the field --->
		
		<!--- The form attribute is required --->
		<cfif not structKeyExists(arguments.stMetadata,"ftForm") and structkeyexists(application.stCOAPI,arguments.stMetadata.ftForm)>
			<cfreturn "" />
		</cfif>
		
		<cfif len(arguments.stMetadata.value)>
			<!--- If the field already has a value then use that --->
			<cfwddx action="wddx2cfml" input="#arguments.stMetadata.value#" output="stObj" />
			
			<cfsavecontent variable="ReturnHTML">
				<ft:object typename="#stObj.typename#" stObject="#stObj#" />
			</cfsavecontent>
		</cfif>
		
 		<cfreturn ReturnHTML>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stObj = structnew() /><!--- The object to be processed --->
		<cfset var prop = "" /><!--- The current property being retrieved --->
		<cfset var stResult = structNew() /><!--- The result of this validation --->
		<cfset var stProperties = structnew() /><!--- The form property struct --->
		
		<!--- Setup return struct --->
		<cfset stResult.bSuccess = true />
		<cfset stResult.value = "" />
		<cfset stResult.stError = StructNew() />
		
		<!--- If no form was selected then abort --->
		<cfif not len(arguments.stFieldPost.stSupporting.formname)>
			<cfreturn stResult />
		</cfif>
		
		<!--- If a previous version was passed in, get it, otherwise get the default for the new form --->
		<cfif len(arguments.stFieldPost.value)>
			<cfwddx action="wddx2cfml" input="#arguments.stFieldPost.value#" output="stObj" />
			
			<!--- If the form selected is not the same, replace the old data with the defaults for the new --->
			<cfif stObj.typename neq arguments.stFieldPost.stSupporting.formname>
				<cfset stObj = createobject("component",application.stCOAPI[arguments.stFieldPost.stSupporting.formname].packagepath).getData(createuuid()) />
				<cfset stObj.typename = arguments.stFieldPost.stSupporting.formname />
			
				<!--- No validation required --->
			<cfelse>
				<!--- Validate the data --->
				<ft:validateFormObjects typename="#arguments.stFieldPost.stSupporting.formname#" stObjectid="#listfirst('#arguments.stFieldPost.stSupporting.objectid#objectid')#">
					<cfloop collection="#stProperties#" item="prop">
						<cfif not listcontains("typename,objectid",prop)>
							<cfset stResult.bSuccess = stResult.bSuccess and request.stFarcryFormValidation[stProperties.objectid][prop].bSuccess />
						</cfif>
					</cfloop>
					
					<cfset stObj = duplicate(stProperties) />
				</ft:validateFormObjects>
			</cfif>
		<cfelse>
			<cfset stObj = createobject("component",application.stCOAPI[arguments.stFieldPost.stSupporting.formname].packagepath).getData(createuuid()) />
			<cfset stObj.typename = arguments.stFieldPost.stSupporting.formname />
			
			<!--- No validation required --->
		</cfif>
		
		<!--- Convert result back to WDDX --->
		<cfwddx action="cfml2wddx" input="#stObj#" output="stResult.value" />
		
		<cfreturn stResult>
	</cffunction>			
			
</cfcomponent>