<!--- @@description:
	<p>Displays a select box with a list of templates</p> --->

<!--- @@examples:
	<p>Basic</p>
	<code>
	<cfproperty 
		name="displayMethod" type="string" hint="Display method to render." required="yes" default="displayPageStandard"
		ftseq="3" ftfieldset="General Details" ftwizardStep="General Details" ftlabel="Content Template" 
		fttype="webskin" />
	</code> 
	<p>Get only templates with filename starting with 'gavinisgreat'</p>
	<code>
	<cfproperty 
		name="displayMethod" type="string" hint="Display method to render." required="yes" default="displayPageStandard"
		ftseq="3" ftfieldset="General Details" ftwizardStep="General Details" ftlabel="Content Template" 
		fttype="webskin" ftPrefix="gavinisgreat"/>
	</code>
--->
<cfcomponent extends="field" name="webskin" displayname="webskin" hint="Used to liase with webskin type fields"> 
	<cfproperty name="ftPrefix" type="string" hint="Only webskins that start with this value are displayed" required="false" default="" />
	<cfproperty name="ftTypename" type="string" hint="The type from which webskins are to be selected" required="false" default="" />
	<cfproperty name="bExcludeCoreViews" type="string" hint="Excludes webskins defined in core from selection" required="false" default="false" />
	
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.webskin" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />
		<cfset var oType = "" />
		<cfset var qWebskins = "*" />
		<cfset var qWebskinsTemp = querynew("empty") />
		<cfset var thistype = "" />
		
		<cfparam name="arguments.stMetadata.ftPrefix" default="">
		<cfparam name="arguments.stMetadata.ftTypename" default="#arguments.typename#"><!--- The typename that the webskin is to be selected for. It defaults to the typename of the object this field is contained in. --->
		<cfparam name="arguments.stMetadata.bExcludeCoreViews" default="false">
	
		<cfif NOT len(arguments.stMetadata.ftTypename)>
			<cfset arguments.stMetadata.ftTypename = arguments.typename />
		</cfif>

		<cfloop list="#arguments.stMetadata.ftTypename#" index="thistype">
			<cfif isquery(qWebskins)>
				<cfset oType=createobject("component", application.stCoapi[thistype].packagepath) />
				<cfset qWebskinsTemp=oType.getWebskins(typename='#thistype#', prefix=arguments.stMetadata.ftPrefix) />
				<cfif qWebskinsTemp.recordcount>
					<cfquery dbtype="query" name="qWebskins">
						select	*
						from	qWebskins
						where	name in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(qWebskinsTemp.name)#">)
						<cfif structKeyExists(arguments.stMetadata, "bExcludeCoreViews") and arguments.stMetadata.bExcludeCoreViews>and path not like '/farcry/core/%'</cfif>
						order by displayname
					</cfquery>
				<cfelse>
					<cfquery dbtype="query" name="qWebskins">
						select	*
						from	qWebskins
						where	name = 'select nothing here'
					</cfquery>
				</cfif>
			<cfelse>
				<cfset oType=createobject("component", application.stCoapi[thistype].packagepath) />
				<cfset qWebskins=oType.getWebskins(typename='#thistype#', prefix=arguments.stMetadata.ftPrefix) />
				<cfquery dbtype="query" name="qWebskins">
						select	*
						from	qWebskins
						where	name in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(qWebskins.name)#">)
						<cfif structKeyExists(arguments.stMetadata, "bExcludeCoreViews") and arguments.stMetadata.bExcludeCoreViews>and path not like '/farcry/core/%'</cfif>
						order by displayname
				</cfquery>
			</cfif>
		</cfloop>

		<cfsavecontent variable="html">
			<!--- Place custom code here! --->

			<cfoutput>
			<cfif isDefined("qWebskins") AND qWebskins.RecordCount>
				<select name="#arguments.fieldname#" id="#arguments.fieldname#" class="selectInput #arguments.stMetadata.ftClass#">
					<cfloop query="qWebskins">						
						<option value="#ReplaceNoCase(qWebskins.name, '.cfm', '','ALL')#"<cfif ReplaceNoCase(qWebskins.name, '.cfm', '','ALL')  eq arguments.stMetadata.value> selected="selected"</cfif>>#qWebskins.displayname#</option>
					</cfloop>
				</select>
			<cfelse>
				No Content Templates Available
				<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" />
			</cfif>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var displayname = "#arguments.stMetadata.value#" />
		<cfset var webskinTypename = arguments.typename />
		<cfset var oType = "" />
		
		<cfif structKeyExists(arguments.stMetadata, "ftTypename") AND len(arguments.stMetadata.ftTypename)>
			<cfset webskinTypename = arguments.stMetadata.ftTypename />
		</cfif>
		

		<cfif len(arguments.stMetadata.value)>
			<cfset displayname=application.coapi.coapiadmin.getWebskinDisplayname(typename=listfirst(webskinTypename), template="#arguments.stMetadata.value#") />
		</cfif>	
		
		
		<cfreturn displayname />
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.It consists of value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.Value>
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->

		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent>