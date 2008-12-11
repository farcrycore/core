<cfcomponent name="state" displayname="State" hint="Field containing a state or province" extends="farcry.core.packages.formtools.field"> > 
		
	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
	
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qCommon = "" />
		<cfset var qAll = "" />
		<cfset var qCountries = "" />
		<cfset var thisprop = "" />
		
		<cfparam name="arguments.stMetadata.ftCountries" default="" /><!--- Defaults to all --->
		<cfparam name="arguments.stMetadata.ftValue" default="name" /><!--- "code" | "name" --->
		
		<cfif structkeyexists(arguments.stMetadata,"ftWatch") and len(arguments.stMetadata.ftWatch)>
			<cfset arguments.stMetadata.ftCountries = arguments.stObject[listfirst(arguments.stMetadata.ftWatch)] />
		</cfif>
		
		<cfset qAll = getStates(arguments.stMetadata.ftCountries) />
		<cfquery dbtype="query" name="qCountries">
			select distinct countryname from qAll
		</cfquery>
		
		<cfif qAll.recordcount>
			<cfsavecontent variable="html">
				<cfoutput>
					<select name="#arguments.fieldname#" id="#arguments.fieldname#" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#">
				</cfoutput>
				
				<cfoutput query="qAll" group="countryname">
					<cfif qCountries.recordcount gt 1><optgroup label="#qAll.countryname[qAll.currentrow]#"></cfif>
					
					<cfoutput><option value="#qAll[arguments.stMetadata.ftValue][qAll.currentrow]#">#qAll.name[qAll.currentrow]#</option></cfoutput>
				
					<cfif qCountries.recordcount gt 1></optgroup></cfif>
				</cfoutput>
				
				<cfoutput>
					</select>
				</cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfset html = "N/A<input type='hidden' name='#arguments.fieldname#' value='N/A' />" />
		</cfif>
		
		<cfreturn html />
	</cffunction>

	<cffunction name="getStates" returntype="query" output="false" access="public" hint="Returns states and acronyms">
		<cfargument name="countries" type="string" required="false" hint="Including this argument restricts the states to certain countries or country codes" />
		
		<cfset var q = querynew("countrycode,countryname,code,name") />
		
		<cfif not structkeyexists(this,"qStates")>
			<!--- Australia --->
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","ACT") /><cfset querysetcell(q,"name","Australian Capital Territory") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NSW") /><cfset querysetcell(q,"name","New South Wales") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NT") /><cfset querysetcell(q,"name","Northern Territory") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","QLD") /><cfset querysetcell(q,"name","Queensland") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","SA") /><cfset querysetcell(q,"name","South Australia") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","VIC") /><cfset querysetcell(q,"name","Victoria") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","WA") /><cfset querysetcell(q,"name","Western Australia") /><cfset querysetcell(q,"countrycode","AU") /><cfset querysetcell(q,"countryname","Australia") />
			
			<!--- New Zealand --->
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","AUK") /><cfset querysetcell(q,"name","Auckland") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","BOP") /><cfset querysetcell(q,"name","Bay of Plenty") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","CAN") /><cfset querysetcell(q,"name","Canterbury") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","GIS") /><cfset querysetcell(q,"name","Gisborne") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","HKB") /><cfset querysetcell(q,"name","Hawke's Bay") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MWT") /><cfset querysetcell(q,"name","Manawatu-Wanganui") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","MBH") /><cfset querysetcell(q,"name","Marlborough") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NSN") /><cfset querysetcell(q,"name","Nelson") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","NTL") /><cfset querysetcell(q,"name","Northland") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","OTA") /><cfset querysetcell(q,"name","Otago") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","STL") /><cfset querysetcell(q,"name","Southland") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TKI") /><cfset querysetcell(q,"name","Taranaki") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","TAS") /><cfset querysetcell(q,"name","Tasman") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","WKO") /><cfset querysetcell(q,"name","Waikato") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","WGN") /><cfset querysetcell(q,"name","Wellington") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			<cfset queryaddrow(q) /><cfset querysetcell(q,"code","WTC") /><cfset querysetcell(q,"name","West Coast") /><cfset querysetcell(q,"countrycode","NZ") /><cfset querysetcell(q,"countryname","New Zealand") />
			
			<cfset this.qStates = q />
		</cfif>
		
		<cfquery dbtype="query" name="q">
			select		countrycode,countryname,code,name
			from		this.qStates
			<cfif structkeyexists(arguments,"countries") and len(arguments.countries)>
				where	countrycode in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.countries#">)
						OR countryname in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.countries#">)
			</cfif>
			order by	countryname,name
		</cfquery>
		
		<cfreturn q />
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = arguments.stMetadata.value />
		<cfset var q = "" />
		
		<cfif structkeyexists(arguments.stMetadata,"ftValue") and arguments.stMetadata.ftValue eq "code">
			<cfset q = getCountries(arguments.stMetadata.value) />
			<cfset html = q.name[1] />
		</cfif>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = passed(value=stFieldPost.Value) />
		
		<cfif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required") AND NOT len(stFieldPost.Value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is a required field.") />
		</cfif>
	
		<cfreturn stResult />
	</cffunction>
	
</cfcomponent>
