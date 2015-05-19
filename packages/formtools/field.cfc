<cfcomponent name="field" displayname="field" hint="Field component to liase with all string types"> 
		
	<cfproperty name="ftSeq" required="false" hint="Used if you are relying on the framework to render your form. Used to sort the fields on the form." />
	<cfproperty name="ftFieldset" required="false" hint="Used if you are relying on the framework to render your form. Used to group the fields into HTML fieldsets." />
	<cfproperty name="ftWizardStep" required="false" hint="Used if you are relying on the framework to render your form. Used to setup a wizard which is a multi step form process." />
	<cfproperty name="ftType" required="false" hint="Tells the framework which of the formtool ui components to use when rendering your form. This will default to the [type]." />
	<cfproperty name="ftLabel" required="false" hint="Used by the FarCry form layout as the label of the form field. This will default to the [name]." />
	<cfproperty name="ftLabelAlignment" required="false" default="inline" options="inline,block" hint="Used by FarCry Form Layouts for positioning of labels. inline or block." />
	<cfproperty name="ftShowLabel" required="false" default="true" hint="Set this to false to hide the label when rendering the field." />
	<cfproperty name="ftMultiField" required="false" default="false" hint="add wrapper div with class of multiField for extra styling." />
	<cfproperty name="ftClass" required="false" default="" hint="CSS Class that can be used on the formtool input" />
	<cfproperty name="ftStyle" required="false" default="" hint="CSS Style that can be used on the formtool input" />
	<cfproperty name="ftPlaceholder" required="false" default="" hint="CSS placeholder text" />
	<cfproperty name="ftValidation" required="false" hint="List of CSS classes that can be used for js validation" />
	<cfproperty name="ftEditMethod" required="false" hint="The function that will be used to render the html output for editing a property" />
	<cfproperty name="ftDisplayMethod" required="false" hint="The function that will be used to render the html output for displaying a property" />
	<cfproperty name="ftValidateMethod" required="false" hint="The function that will be used to render the html output for validating (processing) a property form submission" />
	<cfproperty name="ftAjaxMethod" required="false" hint="The function that will be used to render the html output for ajax requests of a property" />
	<cfproperty name="ftAutoSave" required="false" default="false" hint="Should the object be saved if the field changes?" />
	<cfproperty name="ftWatchFields" required="false" default="" hint="If any of these fields change, then update the current field? Use the format 'typename.property' if you wish to update all field regardless of object. Use just 'property' if you wish to update just that object." />
	<cfproperty name="ftReloadOnAutoSave" required="false" default="false" hint="If the property is autosaved, should the entire page be refreshed?" />
	<cfproperty name="ftRefreshPropertyOnAutoSave" required="false" default="false" hint="If the property is autosaved, should the field be refreshed?" />
	
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.field" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />
		<cfset var maxLength = 0 />

		<cfif 
			structKeyExists(application.fc.lib.db.tablemetadata,arguments.typename) AND 
			structKeyExists(application.fc.lib.db.tablemetadata[arguments.typename].fields,arguments.stMetadata.name) AND
			len(application.fc.lib.db.tablemetadata[arguments.typename].fields[arguments.stMetadata.name].precision)>
			
			<cfif NOT findNoCase(",", application.fc.lib.db.tablemetadata[arguments.typename].fields[arguments.stMetadata.name].precision)>
				<cfset maxLength = application.fc.lib.db.tablemetadata[arguments.typename].fields[arguments.stMetadata.name].precision />
			</cfif>
		</cfif>

		<cfsavecontent variable="html">
			<cfoutput><input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#application.fc.lib.esapi.encodeForHTMLAttribute(arguments.stMetadata.value)#" class="textInput #arguments.inputClass# #arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" placeholder="#arguments.stMetadata.ftPlaceholder#" <cfif maxLength neq 0>maxLength="#maxLength#"</cfif> /></cfoutput>
		</cfsavecontent>

		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		
		<cfsavecontent variable="html">
			<cfoutput>#arguments.stMetadata.value#</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult = passed(value=stFieldPost.Value) />
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->	
		<cfif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required") AND NOT len(stFieldPost.Value)>
			<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is a required field.") />
		</cfif>
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	
	<cffunction name="failed" access="public" output="false" returntype="struct" hint="This will return a struct with stMessage">
		<cfargument name="value" required="true" type="any" hint="The value that is to be returned.">
		<cfargument name="message" required="false" type="string" default="Not a valid value" hint="The message that will appear under the field.">
		<cfargument name="class" required="false" type="string" default="validation-advice" hint="The class of the div wrapped around the message.">
	
		<cfset var r_stResult = structNew() />
		<cfset r_stResult.value = arguments.value />
		<cfset r_stResult.bSuccess = false />
		<cfset r_stResult.stError = structNew() />
		<cfset r_stResult.stError.message = application.fc.lib.esapi.encodeForHTML(arguments.message) />
		<cfset r_stResult.stError.class = arguments.class />
		
		<cfreturn r_stResult />
	</cffunction>
	
	<cffunction name="passed" access="public" output="false" returntype="struct" hint="This will return a struct with stMessage">
		<cfargument name="value" required="true" type="any" hint="The value that is to be returned.">
		
		<cfset var r_stResult = structNew() />
		<cfset r_stResult.value = arguments.value />
		<cfset r_stResult.bSuccess = true />
		<cfset r_stResult.stError = structNew() />
		<cfset r_stResult.stError.message = "" />
		<cfset r_stResult.stError.class = "" />
		
		<cfreturn r_stResult />
	</cffunction>



	<cffunction name="getAjaxURL" access="public" output="false" returntype="string" hint="Returns the URL to use for custom AJAX functionality">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfargument name="combined" required="false" type="boolean" default="false" hint="Force the url parameters into ?/abc/def format" />
		
		<cfif arguments.combined>
			<cfreturn "#application.url.webtop#/facade/ftajax.cfm?/ajaxmode/1/formtool/#arguments.stMetadata.ftType#/typename/#arguments.typename#/fieldname/#arguments.fieldname#/property/#arguments.stMetadata.name#/objectid/#arguments.stObject.objectid#" />
		<cfelse>
			<cfreturn "#application.url.webtop#/facade/ftajax.cfm?ajaxmode=1&formtool=#arguments.stMetadata.ftType#&typename=#arguments.typename#&fieldname=#arguments.fieldname#&property=#arguments.stMetadata.name#&objectid=#arguments.stObject.objectid#" />
		</cfif>
	</cffunction>
	
	<cffunction name="addWatch" access="public" output="true" returntype="string" hint="Adds ajax update functionality for the field">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="html" type="string" required="true" hint="The html to wrap" />
		
		<cfset var prefix = left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name)) />
		<cfset var result = "" />
		<cfset var thisprop = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfparam name="arguments.stMetadata.ftWatch" default="" /><!--- Set this value to a list of property names. Formtool will attempt to update with the ajax function when those properties change. --->
		<cfparam name="arguments.stMetadata.ftLoaderHTML" default="Loading..." /><!--- The HTML displayed in the field while the new UI is being ajaxed in --->
		
		<cfif len(arguments.stMetadata.ftWatch)>
			
			<skin:loadJS id="fc-jquery" />
			
			<cfsavecontent variable="result">
				<skin:onReady>
				<cfoutput>
					<cfloop list="#arguments.stMetadata.ftWatch#" index="thisprop">
						addWatch("#prefix#","#thisprop#",{ 
							prefix:'#prefix#',
							objectid:'#arguments.stObject.objectid#', 
							fieldname:'#arguments.fieldname#',
							ftLoaderHTML:'#jsstringformat(arguments.stMetadata.ftLoaderHTML)#',
							typename:'#arguments.typename#',
							property:'#arguments.stMetadata.name#',
							formtool:'#arguments.stMetadata.ftType#',
							watchedproperty:'#thisprop#'
						});
					</cfloop>
				</cfoutput>
				</skin:onReady>
			
				<cfoutput><div id='#arguments.fieldname#ajaxdiv'>#arguments.html#</div></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfset result = arguments.html />
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="ajax" output="false" returntype="string" hint="Response to ajax requests for this formtool">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var stMD = duplicate(arguments.stMetadata) />
		<cfset var oType = createobject("component",application.stCOAPI[arguments.typename].packagepath) />
		<cfset var FieldMethod = "" />
		<cfset var html = "" />
		
		<cfset stMD.ajaxrequest = "true" />
		
		<cfif len(stMetadata.ftAjaxMethod)>
			<cfset FieldMethod = stMetadata.ftAjaxMethod />
			
			<!--- Check to see if this method exists in the current oType CFC. If not, use the formtool --->
			<cfif not structKeyExists(oType,stMetadata.ftAjaxMethod)>
				<cfset oType = this />
			</cfif>
		<cfelse>
			<cfif structKeyExists(oType,"ftEdit#url.property#")>
				<cfset FieldMethod = "ftEdit#url.property#">
			<cfelse>
				<cfset FieldMethod = "edit" />
				<cfset oType = application.formtools[url.formtool].oFactory />
			</cfif>
		</cfif>
		
		<cfinvoke component="#oType#" method="#FieldMethod#" returnvariable="html">
			<cfinvokeargument name="typename" value="#arguments.typename#" />
			<cfinvokeargument name="stObject" value="#arguments.stObject#" />
			<cfinvokeargument name="stMetadata" value="#stMD#" />
			<cfinvokeargument name="fieldname" value="#arguments.fieldname#" />
		</cfinvoke>
		
		<cfreturn html />
	</cffunction>


	<!------------------ 
	FILTERING FUNCTIONS
	 ------------------>	
	<cffunction name="getFilterUIOptions">
		<cfreturn "contains,starts with,ends with,exactly,is empty,is not empty" />
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
				
				<cfcase value="contains,starts with,ends with,exactly">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfoutput>
					<input type="string" name="#arguments.fieldname#value" value="#arguments.stFilterProps.value#" />
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
				
				<cfcase value="contains,starts with,ends with,exactly">
					<cfif structKeyExists(arguments.stFilterProps, "value")>
						<cfoutput>
						#arguments.stFilterProps.value#
						</cfoutput>
					</cfif>
				</cfcase>
				<cfcase value="is empty,is not empty">
					<cfoutput>&nbsp;</cfoutput>
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
				
				<cfcase value="contains">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif len(arguments.stFilterProps.value)>
						<cfoutput>#arguments.filterProperty# LIKE '%#replace(arguments.stFilterProps.value,"'","''","ALL")#%'</cfoutput>
					</cfif>
				</cfcase>
				
				<cfcase value="starts with">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif len(arguments.stFilterProps.value)>
						<cfoutput>#arguments.filterProperty# LIKE '#replace(arguments.stFilterProps.value,"'","''","ALL")#%'</cfoutput>
					</cfif>
				</cfcase>
				
				<cfcase value="ends with">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif len(arguments.stFilterProps.value)>
						<cfoutput>#arguments.filterProperty# LIKE '%#replace(arguments.stFilterProps.value,"'","''","ALL")#'</cfoutput>
					</cfif>
				</cfcase>
				
				<cfcase value="exactly">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif len(arguments.stFilterProps.value)>
						<cfoutput>#arguments.filterProperty# = '%#replace(arguments.stFilterProps.value,"'","''","ALL")#%'</cfoutput>
					</cfif>
				</cfcase>

				
				<cfcase value="is empty">
					<cfoutput>
					(
					#arguments.filterProperty# is null
					or #arguments.filterProperty# = ''
					)
					</cfoutput>
				</cfcase>

				
				<cfcase value="is not empty">
					<cfoutput>
					(
					#arguments.filterProperty# is not null
					AND #arguments.filterProperty# != ''
					)
					</cfoutput>
				</cfcase>				
			
			</cfswitch>
			
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
		
		
		
	<!--- CORE INITIALISATION METHODS --->
	<cffunction name="initMetaData" access="public" hint="Extract all component metadata in a flat format for loading into a shared scope." output="false" returntype="struct">
		<cfargument name="stMetaData" type="struct" required="false" default="#structNew()#" hint="Structure to which this cfc's parameters are appended" />
	
		<cfset var stReturnMetadata = arguments.stMetaData />
		<cfset var stNewProps = getPropsAsStruct() />
		<cfset var md = getMetaData(this) />		
		<cfset var mdExtend = md />
		<cfset var key = "" />
		
		<!--- If we are updating a type that already exists then we need to update only the metadata that has changed. --->
		<cfparam name="stReturnMetadata.stProps" default="#structnew()#" />
		<cfset stReturnMetadata.stProps = application.factory.oUtils.structMerge(stReturnMetadata.stProps,stNewProps) />
		
		<cfloop condition="not structisempty(mdExtend)">
			<cfloop collection="#md#" item="key">
				<cfif key neq "PROPERTIES" AND key neq "EXTENDS" AND key neq "FUNCTIONS" AND key neq "TYPE">
					<cfparam name="stReturnMetadata.#key#" default="#md[key]#" />				
				</cfif>
			</cfloop>
			<cfif structkeyexists(mdExtend,"extends") and not findnocase(mdExtend.extends.name,"fourq")>
				<cfset mdExtend = mdExtend.extends />
			<cfelse>
				<cfset mdExtend = structnew() />
			</cfif>
		</cfloop>
		
		<!--- Param component metadata --->
		<cfparam name="stReturnMetadata.displayname" default="#listlast(stReturnMetadata.name,'.')#" />
		
		<!--- This sets up the array which will contain the name of all types this type extends --->
		<cfset stReturnMetadata.aExtends = application.coapi.coapiadmin.getExtendedTypeArray(packagePath=md.name)>
			
		
		<cfreturn stReturnMetadata />
		
	</cffunction> 
	
	
	<cffunction name="getPropsAsStruct" returntype="struct" hint="Get all extended properties and return as a flattened structure." access="private" output="false">
		<cfset var aAncestors = getAncestors(getMetaData(this))>
		<cfset var stProperties = StructNew()>
		<cfset var curAncestor = "">
		<cfset var curProperty = "">
		<cfset var i = "">
		<cfset var j = "">
		<cfset var prop = "">
		<cfset var success = "">
		
		<cfloop index="i" from="1" to="#ArrayLen(aAncestors)#">
			<cfset curAncestor = duplicate(aAncestors[i])>
			
			<cfif StructKeyExists(curAncestor,"properties")>
				<cfloop index="j" from="1" to="#ArrayLen(curAncestor.properties)#">
					<cfif not structKeyExists(stProperties, curAncestor.properties[j].name)>
						<cfset stProperties[curAncestor.properties[j].name] = structNew() />
						<cfset stProperties[curAncestor.properties[j].name].metadata = structNew() />
						<cfset stProperties[curAncestor.properties[j].name].origin = "" />
					</cfif>
					<cfset stProperties[curAncestor.properties[j].name].origin = curAncestor.name />
					<cfset success = structAppend(stProperties[curAncestor.properties[j].name].metadata, curAncestor.properties[j]) />
				</cfloop>
			</cfif>
		</cfloop>

		<cfloop collection="#stProperties#" item="prop">
			<!--- make sure all metadata has a default and required --->
			<cfif NOT StructKeyExists(stProperties[prop].metadata,"required")>
				<cfset stProperties[prop].metadata.required = "no">
			</cfif>
			
			<cfif NOT StructKeyExists(stProperties[prop].metadata,"default")>
				<cfset stProperties[prop].metadata.default = "">
			</cfif>
		</cfloop>

		<cfreturn stProperties>
	</cffunction>
			
	<cffunction name="getAncestors" hint="Get all the extended components as an array of isolated component metadata." returntype="array" access="private" output="false">
		<cfargument name="md" required="Yes" type="struct">
			<cfset var aAncestors = arrayNew(1)>
			<cfscript>	
				if (structKeyExists(md, 'extends'))
					aAncestors = getAncestors(md.extends);
				arrayAppend(aAncestors, md);
			</cfscript>
		<cfreturn aAncestors>
	</cffunction>
	
	<cffunction name="prepMetadata" access="public" output="false" returntype="struct" hint="Allows modification of property metadata in the displayLibrary* webskins">
		<cfargument name="stObject" type="struct" required="true" hint="The object being edited" />
		<cfargument name="stMetadata" type="struct" required="true" hint="The property metadata" />
		<cfreturn arguments.stMetadata />
	</cffunction>
	
	
</cfcomponent> 
