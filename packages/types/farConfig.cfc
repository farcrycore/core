<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent displayname="Configuration" extends="types" output="false" hint="Many aspects of the application can be configured to behave specifically as you need them.  Modify the setup by tweaking the configuration just the way you need it." 
	bSystem="true" bArchive="true" icon="fa-cog">
<!---------------------------------------------- 
type properties
----------------------------------------------->
	<cfproperty name="configkey" type="string" default="" hint="The variable used in the config struct" ftLabel="Config" ftType="string" ftValidation="required" />
	<cfproperty name="configtypename" type="string" default="" ftLabel="Config Typename" ftType="string" ftValidation="required" />
	<cfproperty ftSeq="1" ftFieldSet="Config" name="configdata" type="longchar" default="" hint="The config values encoded in JSON" ftLabel="Config" ftType="longchar" ftShowLabel="false" />

<!---------------------------------------------- 
object methods
----------------------------------------------->
	<cffunction name="getForm" access="public" returntype="string" description="Returns the name of the form for the given key" output="false">
		<cfargument name="key" type="string" required="true" hint="The key">
		
		<cfset var thisform = "">
		
		<cfloop collection="#application.stCOAPI#" item="thisform">
			<cfif left(thisform,6) eq "config">
				<cfif structkeyexists(application.stCOAPI[thisform],"key") and application.stCOAPI[thisform].key eq arguments.key>
					<cfreturn thisform>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn "">
	</cffunction>
	
	<cffunction name="ftEditConfigData" access="public" returntype="string" description="Provides edit functionality for config data" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var stObj = structnew() /><!--- Used to store the current set of values --->
		<cfset var ReturnHTML = "" /><!--- The output for the field --->
		<cfset var prefix = "" /><!--- The form id for this field --->
		<cfset var thisform = "" /><!--- Loop variable for form names --->
		<cfset var qMetadata = querynew("empty") /><!--- Config metadata --->
		<cfset var qFieldSets = querynew("empty") /><!--- The fieldsets supported by the config --->
		<cfset var legend = "" />
		<cfset var IncludeFieldSet = true />
		<cfset var thisprop = "" />
		<cfset var lFieldSets	= '' />
		<cfset var iFieldset	= '' />
		<cfset var qFieldset	= '' />
		<cfset var propertyFormat = '' />
		<cfset var stMeta = structNew() />
		<cfset var stPropValues = structnew() />

		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
		<!--- If the field already has a value then use that --->
		<cfset stObj = deserializeJSON(arguments.stMetadata.value)>
		
		<!--- If the config is unknown, attempt to match it by form key --->
		<cfif not structkeyexists(stObj,"typename")>
			<cfset stObj.typename = getForm(key=arguments.stObject.configkey) />
		</cfif>
		
		<cfif structkeyexists(stObj,"typename") and structkeyexists(application.stCOAPI,stObj.typename)>
		
			<cfset qMetadata = application.stCOAPI[stobj.typename].qMetadata />
		
			<cfsavecontent variable="ReturnHTML">		
				<ft:form>
					
				<cfquery dbtype="query" name="qFieldSets">
				SELECT ftFieldset
				FROM qMetadata
				WHERE ftFieldset <> '#stobj.typename#'
				ORDER BY ftseq
				</cfquery>
				
				<cfset lFieldSets = "" />
				<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
					<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
				</cfoutput>
				
				<cfif listLen(lFieldSets)>
								
					<cfloop list="#lFieldSets#" index="iFieldset">	

						<cfquery dbtype="query" name="qFieldset">
							SELECT 		*
							FROM 		qMetadata
							WHERE 		ftFieldset = '#iFieldset#'
							ORDER BY 	ftSeq
						</cfquery>

						<ft:fieldset Legend="#iFieldset#" helptitle="#qFieldset.fthelptitle#" helpsection="#qFieldset.fthelpsection#">
							<cfloop query="qFieldset">

								<cfset propertyFormat = "edit">
								<cfif isDefined("application.config_readonly.#arguments.stObject.configkey#.#qFieldset.propertyname#")>
									<cfset propertyFormat = "display">
									<cfset stMeta = structNew()>
									<cfset stMeta[qFieldset.propertyname] = structNew()>
									<cfset stMeta[qFieldset.propertyname].ftHint = "This field is read only and cannot be edited via the webtop">
									<cfset stPropValues[qFieldset.propertyname] = application.config_readonly[arguments.stObject.configkey][qFieldset.propertyname]>
								</cfif>

								<ft:object stObject="#stObj#" format="#propertyFormat#" lExcludeFields="label" lFields="#qFieldset.propertyname#" stPropMetadata="#stMeta#" stPropValues="#stPropValues#" inTable="false" IncludeFieldSet="false" />

							</cfloop>
						</ft:fieldset>

					</cfloop>
						
				<cfelse>
				
					<!--- All Fields: default edit handler --->
					<cfif structKeyExists(stObj, "label")>
						<cfset legend = stObj.label />
					<cfelse>
						<cfset legend = "" />
						<cfset IncludeFieldSet = false />
					</cfif>
					<ft:object stObject="#stObj#" lExcludeFields="label" Legend="#legend#" IncludeFieldSet="#IncludeFieldSet#"  />
					
				</cfif>
					
				</ft:form>
				
				<cfoutput>
					<input type="hidden" name="#arguments.fieldname#formname" value="#stObj.typename#" />
					<input type="hidden" name="#arguments.fieldname#objectid" value="#stObj.objectid#" />
					<input type="hidden" name="#arguments.fieldname#" value="#application.fc.lib.esapi.encodeForHTMLAttribute(arguments.stMetadata.value)#" />
				</cfoutput>
			</cfsavecontent>
			
		<cfelse>
		
			<cfsavecontent variable="ReturnHTML">
				<cfoutput>
					<p class="error">There is no form for this data. To allow it to be edited, create a form component prefixed with "config" and give it a key attribute matching the key for this config (e.g. key="general"). Add cfproperty tags to this component for the config variables that define formtool metadata and defaults.</p>
				</cfoutput>
			</cfsavecontent>
		
		</cfif>
		
			<cfreturn ReturnHTML>
	</cffunction>

	<cffunction name="ftValidateConfigData" access="public" returntype="struct" description="Validates configdata" output="false">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stObj = structnew() /><!--- The object to be processed --->
		<cfset var prop = "" /><!--- The current property being retrieved --->
		<cfset var stResult = structNew() /><!--- The result of this validation --->
		<cfset var stProperties = structnew() /><!--- The form property struct --->
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
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
			<cfset stObj = deserializeJSON(arguments.stFieldPost.value)>
			
			<!--- Validate the data --->
			<ft:validateFormObjects typename="#arguments.stFieldPost.stSupporting.formname#">
				<cfloop collection="#stProperties#" item="prop">
					<cfif not listcontainsnocase("typename,objectid",prop)>
						<cfset stResult.bSuccess = stResult.bSuccess and request.stFarcryFormValidation[stProperties.ObjectID][prop].bSuccess />
					</cfif>
				</cfloop>
				
				<cfset structappend(stObj,stProperties,true) />
			</ft:validateFormObjects>
		<cfelse>
			<cfset stObj = createobject("component",application.stCOAPI[arguments.stFieldPost.stSupporting.formname].packagepath).getData(application.fc.utils.createJavaUUID()) />
			<cfset stObj.typename = arguments.stFieldPost.stSupporting.formname />
			
			<!--- No validation required --->
		</cfif>
		
		<!--- Convert result back to JSON --->
		<cfset stResult.value = serializeJSON(stObj)>
		
		<cfreturn stResult>
	</cffunction>
	

	<cffunction name="migrateConfigWDDXtoJSON" access="public" output="true" returntype="string" hint="Updates a pre-FC7 WDDX config to JSON format. Returns the new JSON data on success, empty string if nothing was migrated.">
		<cfargument name="objectid" type="string" required="true" hint="The objectid of the config record">
		
		<cfset var result = "">
		<cfset var stConfig = structNew()>
		<cfset var stObj = getData(objectid=arguments.objectid)>
		<cfset var formkey = "">

		<cfif isWDDX(stObj.configdata)>
			<!--- read the existing WDDX config, converting previously escaped chars --->
			<cfwddx action="wddx2cfml" input="#stObj.configdata#" output="stConfig">
			<cfloop collection="#stConfig#" item="formkey">
				<cfif issimplevalue(stConfig[formkey])>
					<cfset stConfig[formkey] = replacelist(stConfig[formkey],"&gt;,&lt;,&apos;,&quot;,&amp;",">,<,',"",&") />
				</cfif>
			</cfloop>
			<!--- save the new JSON config --->
			<cfset stObj.configdata = serializeJSON(stConfig)>
			<cfset stObj.label = autoSetLabel(stProperties=stObj)>
			<cfset setData(stProperties=stObj)>

			<cfset result = stObj.configdata>
		</cfif>

		<cfreturn result>
	</cffunction>

 	<cffunction name="autoSetLabel" access="public" output="false" returntype="string" hint="Automagically sets the label">
		<cfargument name="stProperties" required="true" type="struct">

		<cfset var newLabel = stProperties.configkey>

		<cfif structKeyExists(stProperties, "configtypename") AND len(stProperties.configtypename) and isDefined("application.stCOAPI.#stProperties.configtypename#.displayname")>
			<cfset newLabel = trim(application.stCOAPI[stProperties.configtypename].displayname)>			
		</cfif>

		<cfreturn newLabel>
	</cffunction>

	<cffunction name="getConfig" access="public" output="true" returntype="struct" hint="Finds the config for the specified config, create it if it doesn't exist, then return it">
		<cfargument name="key" type="string" required="true" hint="The key of the config to load" />
		<cfargument name="bAudit" type="boolean" default="true" required="false" hint="Allows the installer to not audit" />
		<cfargument name="bIgnoreCache" type="boolean" default="false" required="false" hint="Ignores the object broker cache and retrieves from the database" />

		<cfset var qConfig = "" />
		<cfset var migratedConfig = "" />
		<cfset var stObj = structnew() />
		<cfset var configkey = "" />
		<cfset var bChanged = false />
		<cfset var stDefault = structnew() />
		<cfset var formkey = "" />
		<cfset var stResult = structnew() />

		<cfif isdefined("application.fc.lib.objectbroker") and not arguments.bIgnoreCache>
			<!--- if the objectbroker is set up and we aren't skipping the cache, get the config from object broker --->
			<cfset stResult = application.fc.lib.objectbroker.GetFromObjectBroker(arguments.key,"config") />
		</cfif>

		<!--- as a final resort, get the config from the db --->
		<cfif structIsEmpty(stResult)>
			<!--- Find a config item that stores this config data --->
			<cfquery datasource="#application.dsn#" name="qConfig">
				select	*, 'farConfig' AS typename
				from	farConfig
				where	configkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.key#" />
			</cfquery>
			
			<cfif qConfig.recordcount>
				<!--- migrate old WDDX configs to JSON --->
				<cfif isWDDX(qConfig.configdata[1])>
					<cfset migratedConfig = migrateConfigWDDXtoJSON(objectid=qConfig.objectid[1])>
					<cfset querySetCell(qConfig, "configdata", migratedConfig, 1)>
				</cfif>

				<!--- deserialise JSON into config struct --->
				<cfif isJSON(qConfig.configdata[1])>
					<cfset stResult = deserializeJSON(qConfig.configdata[1])>				
				</cfif>
			</cfif>
			
			<!--- make sure the result is a struct --->
			<cfif not isStruct(stResult)>
				<cfset stResult = structnew() />
				<cfset bChanged = true />
			</cfif>

			<!--- Find the config form component with that key --->
			<cfif structKeyExists(qConfig, "configtypename") AND NOT len(qConfig.configtypename) and not structkeyexists(stResult,"typename")>
				<cfset stResult.typename = getForm(arguments.key) />
				<cfset bChanged = true />
			</cfif>

			<!--- handle missing configs --->
			<cfif structIsEmpty(stResult)>
				<cfset stResult.typename = getForm(arguments.key) />
				<cfset bChanged = true />
			</cfif>

			<!--- update with missing values --->
			<cfif structkeyexists(stResult, "typename") AND structkeyexists(application.stCOAPI,stResult.typename)>
				<cfset stDefault = createobject("component",application.stCOAPI[stResult.typename].packagepath).getData(application.fc.utils.createJavaUUID()) />
				<cfloop collection="#stDefault#" item="formkey">
					<cfif not structkeyexists(stResult,formkey)>
						<cfset stResult[formkey] = stDefault[formkey] />
						<cfset bChanged = true />
					</cfif>
				</cfloop>
			<cfelse>
				<cfset bChanged = true />
			</cfif>

			<!--- if the config was updated, save to db --->
			<cfif bChanged>
				<!--- Copy the result back to an stObj --->
				<cfset stObj.configdata = serializeJSON(stResult)>

				<!--- Set up the config item values --->
				<cfif qConfig.recordcount>
					<cfset stObj.objectid = qConfig.objectid[1] />
				<cfelse>
					<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
				</cfif>
				<cfset stObj.typename = "farConfig" />
				<cfset stObj.configkey = arguments.key />
				<cfif structKeyExists(stResult, "typename")>
					<cfset stObj.configtypename = stResult.typename />				
				</cfif>
				<cfset stObj.label = autoSetLabel(stProperties=stObj)>				
				<cfset stObj.datetimecreated = now() />

				<!--- Save the config data (ensures that new configs and new properties are saved) --->
				<cfif isdefined("application.fc.lib")>
					<cfset setData(stProperties=stObj,bAudit=arguments.bAudit) />
				</cfif>
			</cfif>

			<cfif structkeyexists(stResult,"typename")>
				<cfset structdelete(stResult,"typename") />
			</cfif>
			<cfif structkeyexists(stResult,"objectid")>
				<cfset structdelete(stResult,"objectid") />
			</cfif>

			<cfset stResult.datetimeLastUpdated = now() />

			<cfif isdefined("application.fc.lib.objectbroker")>
				<cfset application.fc.lib.objectBroker.AddToObjectBroker(stResult,"config",arguments.key) />
			</cfif>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getConfigKeys" access="public" output="false" returntype="string" hint="Returns a list of the config keys the application supports">
		<cfset var thisform = "" />
		<cfset var result = "" />
		<cfset var qConfig = "" />
		
		<cfquery datasource="#application.dsn#" name="qConfig">
			select	*, 'farConfig' AS typename
			from	#application.dbowner#farConfig
			<cfif len(result)>
				where	configkey not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="result" />)
			</cfif>
		</cfquery>
		
		<cfset result = valuelist(qConfig.configkey) />
		
		<cfloop list="#application.factory.oUtils.getComponents('forms')#" index="thisform">
			<cfif left(thisform,6) eq "config" and not listFindNoCase(result,application.stCOAPI[thisform].key)>
				<cfset result = listappend(result,application.stCOAPI[thisform].key) />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="reloadConfig" access="public" output="false" hint="Reloads all configuration data and re-applies the values for any read-only config properties">

		<cfset var configkey = "">
		<cfset var stReadOnly = structNew()>

		<cfparam name="application.config_readonly" default="#structNew()#">
		<cfset stReadOnly = duplicate(application.config_readonly)>

		<cfset structclear(application.config) />
		<cfloop list="#getConfigKeys()#" index="configkey">
			<cfset application.config[configkey] = getConfig(key=configkey,bIgnoreCache=true) />
			<cfset applyReadOnlyConfig(configkey)>
		</cfloop>
	</cffunction>

	<cffunction name="applyReadOnlyConfig" access="public" output="false" hint="Reloads all configuration data and re-applies the values for any read-only config properties">
		<cfargument name="configkey" required="true">

		<cfparam name="application.config_readonly" default="#structNew()#">

		<!--- re-apply read only properties --->
		<cfif isDefined("application.config_readonly.#arguments.configkey#")>
			<cfset structAppend(application.config[arguments.configkey], application.config_readonly[arguments.configkey], true)>
		</cfif>
	</cffunction>

	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfset var config = "" />
		<cfset var thisprop = "" />
		
		<cfset config = deserializeJSON(arguments.stProperties.configdata)>
		<cfset config.datetimeLastUpdated = now() />

		<!--- re-apply read only properties --->
		<cfset applyReadOnlyConfig(arguments.stProperties.configkey)>
		
		<!--- run the config object's process method --->
		<cfif structKeyExists(stProperties, "configtypename") AND len(stProperties.configtypename) and structkeyexists(application.stCOAPI,stProperties.configtypename)>
			<cfset config = application.fapi.getContentType(stProperties.configtypename).process(fields = config) />
		</cfif>

		<cfset application.config[arguments.stProperties.configkey] = duplicate(config) />

		<cfif isdefined("application.fc.lib.objectbroker")>
			<cfset application.fc.lib.objectBroker.AddToObjectBroker(config,"config",arguments.stProperties.configkey) />
		</cfif>
		
		<cfreturn arguments.stProperties />
	</cffunction>
	
	<cffunction name="Edit" access="public" output="true" returntype="void" hint="Default edit handler.">
		<cfargument name="ObjectID" required="yes" type="string" default="" />
		<cfargument name="onExitProcess" required="no" type="any" default="Refresh" />
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var qMetadata = application.types[stobj.typename].qMetadata />
		<cfset var displayname = stObj.configkey />
		<cfset var thisform = "" />
		<cfset var qFields	= '' />

		<cfloop collection="#application.stCOAPI#" item="thisform">
			<cfif left(thisform,6) eq "config" and structkeyexists(application.stCOAPI[thisform],"key") and application.stCOAPI[thisform].key eq stObj.configkey and structkeyexists(application.stCOAPI[thisform],"displayname")>
				<cfset displayname = application.stCOAPI[thisform].displayname />
			</cfif>
		</cfloop>
		
		<cfquery dbtype="query" name="qFields">
			SELECT 		propertyname
			FROM 		qMetadata
			WHERE 		ftFieldset = 'Config'
			ORDER BY 	ftSeq
		</cfquery>
	
		<!---------------------------------------
		ACTION:
		 - default form processing
		---------------------------------------->
		<cfif structKeyExists(url, "dialogID")>
			<cfset onExitProcess = structNew() />
			<cfset onExitProcess.Type = "HTML" />
			<cfsavecontent variable="onExitProcess.content">
				<cfoutput>
					<script type="text/javascript">
					parent.$j('##fcModal').modal('hide');
					</script>
				</cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfset onExitProcess = structnew() />
			<cfset onExitProcess.type = "URL" />
			<cfset onExitProcess.content = "refresh" />
		</cfif>
		
		<ft:processForm action="Save" Exit="true">
			<ft:processFormObjects typename="#stobj.typename#" />
		</ft:processForm>
	
		<ft:processForm action="Cancel" Exit="true" />
		
		<ft:form>
			<!--- All Fields: default edit handler --->
			<ft:object objectID="#arguments.ObjectID#" typename="#stObj.typename#" format="edit" lFields="#valuelist(qFields.propertyname)#" r_stFields="stFields" />
			
			<cfoutput>
				#stFields.configData.html#
			</cfoutput>
			
			<ft:buttonPanel>
				<ft:button value="Save" /> 
				<ft:button value="Cancel" validate="false" />
			</ft:buttonPanel>
			
		</ft:form>
	
	</cffunction>

</cfcomponent>