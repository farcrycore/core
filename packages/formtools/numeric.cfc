

<cfcomponent extends="field" name="numeric" displayname="numeric" hint="Field component to liase with all string types"> 
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.numeric" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />
		
		
		<cfparam name="arguments.stMetadata.ftIncludeDecimal" default="true">
		<cfparam name="arguments.stMetadata.ftCurrencySymbol" default="">
		<cfparam name="arguments.stMetadata.ftPrefix" default="">
		<cfparam name="arguments.stMetadata.ftSuffix" default="">
		<cfparam name="arguments.stMetadata.ftMask" default="">
		
		<cfif len(arguments.stMetadata.ftMask)>
			<cfset arguments.stMetadata.value = trim(NumberFormat(arguments.stMetadata.value, arguments.stMetadata.ftMask))>
		<cfelse>
			<!--- This is for legacy. You should use just ftPrefix and ftSuffix --->
			<cfif len(arguments.stMetadata.ftCurrencySymbol)>
				<cfset arguments.stMetadata.ftPrefix = arguments.stMetadata.ftCurrencySymbol />
			</cfif>

			<cfif stMetadata.ftIncludeDecimal>
				<cfset arguments.stMetadata.value = DecimalFormat(arguments.stMetadata.value)>
			<cfelse>
				<cfset arguments.stMetadata.value = NumberFormat(arguments.stMetadata.value)>
			</cfif>
		</cfif>
		
		<cfsavecontent variable="html">
			<cfoutput><input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.ftPrefix##arguments.stMetadata.value##arguments.stMetadata.ftSuffix#" <cfif structKeyExists(arguments.stMetadata,'ftStyle')>style="#arguments.stMetadata.ftstyle#"</cfif> class="textInput #arguments.inputClass# #arguments.stMetadata.ftclass#" /></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />
		
		
		<cfparam name="arguments.stMetadata.ftIncludeDecimal" default="true">
		<cfparam name="arguments.stMetadata.ftCurrencySymbol" default="">
		<cfparam name="arguments.stMetadata.ftPrefix" default="">
		<cfparam name="arguments.stMetadata.ftSuffix" default="">
		<cfparam name="arguments.stMetadata.ftMask" default="">
		
		<cfif len(arguments.stMetadata.ftMask)>
			<cfset arguments.stMetadata.value = NumberFormat(arguments.stMetadata.value, arguments.stMetadata.ftMask)>
		<cfelse>
			<!--- This is for legacy. You should use just ftPrefix and ftSuffix --->
			<cfif len(arguments.stMetadata.ftCurrencySymbol)>
				<cfset arguments.stMetadata.ftPrefix = arguments.stMetadata.ftCurrencySymbol />
			</cfif>
			
			<cfif NOT stMetadata.ftIncludeDecimal>
				<cfset arguments.stMetadata.value = NumberFormat(arguments.stMetadata.value)>
			</cfif>
		</cfif>
		
		<cfsavecontent variable="html">
			<cfoutput>#arguments.stMetadata.ftPrefix##arguments.stMetadata.value##arguments.stMetadata.ftSuffix#</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>	

		<cfparam name="arguments.stMetadata.ftCurrencySymbol" default="">
		<cfparam name="arguments.stMetadata.ftPrefix" default="">
		<cfparam name="arguments.stMetadata.ftSuffix" default="">
		
		<!--- This is for legacy. You should use just ftPrefix and ftSuffix --->
		<cfif len(arguments.stMetadata.ftCurrencySymbol)>
			<cfset arguments.stMetadata.ftPrefix = arguments.stMetadata.ftCurrencySymbol />
		</cfif>		
		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "#stFieldPost.Value#">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfset stResult.value = ReplaceNoCase(stResult.value, ",","","all")>
		
		<cfif len(trim(arguments.stMetadata.ftPrefix))>
			<cfset stResult.value = ReplaceNoCase(stResult.value, trim(arguments.stMetadata.ftPrefix), "","all")>
		</cfif>
		<cfif len(trim(arguments.stMetadata.ftSuffix))>
			<cfset stResult.value = ReplaceNoCase(stResult.value, trim(arguments.stMetadata.ftSuffix), "","all")>
		</cfif>
		
		
		<cfset stResult.value = trim(stResult.value) />
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>



	<cffunction name="getFilterUIOptions">
		<cfreturn "less than,less than or equal to,equal to,greater than,greater than or equal to,between" />
	</cffunction>
	
	<cffunction name="editFilterUI">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="false" type="struct" hint="Contains the metadata for the all fields for the current typename.">
				
		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="less than,less than or equal to,equal to,greater than,greater than or equal to">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfoutput>
					<input type="string" name="#arguments.fieldname#value" value="#arguments.stFilterProps.value#" />
					</cfoutput>
				</cfcase>
				
				<cfcase value="between">
					<cfparam name="arguments.stFilterProps.from" default="" />
					<cfparam name="arguments.stFilterProps.to" default="" />
					<cfoutput>
					<input type="string" name="#arguments.fieldname#from" value="#arguments.stFilterProps.from#" />
					<input type="string" name="#arguments.fieldname#to" value="#arguments.stFilterProps.to#" />
					</cfoutput>
				</cfcase>
			
			</cfswitch>
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
	
	<cffunction name="displayFilterUI">
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="less than,less than or equal to,equal to,greater than,greater than or equal to">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfoutput>
					#arguments.stFilterProps.value#
					</cfoutput>
				</cfcase>
				
				<cfcase value="between">
					<cfparam name="arguments.stFilterProps.from" default="" />
					<cfparam name="arguments.stFilterProps.to" default="" />
					<cfoutput>
					#arguments.stFilterProps.from# - #arguments.stFilterProps.to#
					</cfoutput>
				</cfcase>
			
			</cfswitch>
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
	
	<cffunction name="getFilterSQL">

		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="less than">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif isNumeric(arguments.stFilterProps.value)>
						<cfoutput>#arguments.filterProperty# < #arguments.stFilterProps.value#</cfoutput>
					</cfif>
				</cfcase>
				<cfcase value="less than or equal to">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif isNumeric(arguments.stFilterProps.value)>
						<cfoutput>#arguments.filterProperty# <= #arguments.stFilterProps.value#</cfoutput>
					</cfif>
				</cfcase>
				<cfcase value="equal to">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif isNumeric(arguments.stFilterProps.value)>
						<cfoutput>#arguments.filterProperty# = #arguments.stFilterProps.value#</cfoutput>
					</cfif>
				</cfcase>
				<cfcase value="greater than">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif isNumeric(arguments.stFilterProps.value)>
						<cfoutput>#arguments.filterProperty# > #arguments.stFilterProps.value#</cfoutput>
					</cfif>
				</cfcase>
				<cfcase value="greater than or equal to">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif isNumeric(arguments.stFilterProps.value)>
						<cfoutput>#arguments.filterProperty# >= #arguments.stFilterProps.value#</cfoutput>
					</cfif>
				</cfcase>
				
				<cfcase value="between">
					<cfparam name="arguments.stFilterProps.from" default="" />
					<cfparam name="arguments.stFilterProps.to" default="" />
					
					<cfif isNumeric(arguments.stFilterProps.from) AND isNumeric(arguments.stFilterProps.to)>
						<cfoutput>
							(
								#arguments.filterProperty# 
								BETWEEN
								#arguments.stFilterProps.from#
								AND 
								#arguments.stFilterProps.to#
							)
						</cfoutput>
					</cfif>
				</cfcase>
			
			</cfswitch>
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
	
	
</cfcomponent> 
