

<cfcomponent name="DOB" extends="field" displayname="datetime" hint="Field component to liase with all datetime types"> 
		
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.dob" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var fieldStyle = "">
		<cfset var ToggleOffDateTimeJS = "" />
		<cfset var html = "" />
		<cfset var bfieldvisible = "" />
		<cfset var fieldvisibletoggletext = "" />
		<cfset var locale = "">
		<cfset var localeMonths = "">
		<cfset var i = "">
		
		<cfparam name="arguments.stMetadata.ftDateFormatMask" default="dd mmm yyyy">
		<cfparam name="arguments.stMetadata.ftStartYear" default="#year(now())#">
		<cfparam name="arguments.stMetadata.ftEndYear" default="#year(now()) - 100#">
		
		<cfif isDefined("session.dmProfile.locale") AND len(session.dmProfile.locale)>
			<cfset locale = session.dmProfile.locale>
		<cfelse>
			<cfset locale = "en_AU">
		</cfif>			
		
		<cfset localeMonths = createObject("component", "/farcry/core/packages/farcry/gregorianCalendar").getMonths(locale) />

		<cfsavecontent variable="html">
			<cfoutput>
			
			<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateFormatMask)#" />
			<select name="#arguments.fieldname#Day" id="#arguments.fieldname#Day">
			<option value="">--</option>
			<cfloop from="1" to="31" index="i">
				<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Day(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#i#</option>
				</cfloop>
			</select>	
		
			<select name="#arguments.fieldname#Month" id="#arguments.fieldname#Month">
				<option value="">--</option>
				<cfloop from="1" to="12" index="i">
					<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Month(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#localeMonths[i]#</option>
				</cfloop>
			</select>
		
			<select name="#arguments.fieldname#Year" id="#arguments.fieldname#Year">
				<option value="">--</option>
				<cfloop from="#arguments.stMetadata.ftStartYear#" to="#arguments.stMetadata.ftEndYear#" index="i" step="-1">
					<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Year(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#i#</option>
				</cfloop>
			</select>	
			<br style="clear:both;" />						
			
			</cfoutput>
		</cfsavecontent>		
		
		<cfreturn html>
	</cffunction>
	
		<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
			<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
			<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
			<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
			<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	
			<cfset var html = "" />
			
			
			<cfparam name="arguments.stMetadata.ftDateMask" default="d-mmm-yy">
			
			<cfsavecontent variable="html">
				<cfif len(arguments.stMetadata.value) AND isDate(arguments.stMetadata.value)>
					<cfoutput>#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateMask)#</cfoutput>
				</cfif>
			</cfsavecontent>
			
			<cfreturn html>
		</cffunction>
	
		<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
			<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
			<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
			<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
			<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
			
			<cfset var stResult = passed(value="") />
			<cfset var newDate = "" />
			
			<!--- --------------------------- --->
			<!--- Perform any validation here --->
			<!--- --------------------------- --->
			<cfif structKeyExists(arguments.stFieldPost.stSupporting,"day")
				AND structKeyExists(arguments.stFieldPost.stSupporting,"month")
				AND structKeyExists(arguments.stFieldPost.stSupporting,"year")>
				
				<cfif len(arguments.stFieldPost.stSupporting.day) OR len(arguments.stFieldPost.stSupporting.month) OR len(arguments.stFieldPost.stSupporting.year)>
					<cftry>
						<cfset newDate = createDate(arguments.stFieldPost.stSupporting.year, arguments.stFieldPost.stSupporting.month, arguments.stFieldPost.stSupporting.day) />
						<cfset stResult = passed(value="#newDate#") />
						<cfcatch type="any">
							<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="You need to select a valid date.") />
						</cfcatch>
					</cftry>
				</cfif>
			</cfif>			
			
		
			<cfif stResult.bSuccess>
				<cfset arguments.stFieldPost.value = stResult.value />
				<cfset stResult = super.validate(objectid=arguments.objectid, typename=arguments.typename, stFieldPost=arguments.stFieldPost, stMetadata=arguments.stMetadata )>
			</cfif>
		
			<!--- ----------------- --->
			<!--- Return the Result --->
			<!--- ----------------- --->
			<cfreturn stResult>
			
		</cffunction>
	
	</cfcomponent> 
