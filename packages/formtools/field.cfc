

<cfcomponent name="field" displayname="string" hint="Field component to liase with all string types"> 
		
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.field" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
	
		<cfsavecontent variable="html">
			<cfoutput><input type="Text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#HTMLEditFormat(arguments.stMetadata.value)#" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></cfoutput>
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
		<cfset r_stResult.stError.message = HTMLEditFormat(arguments.message) />
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




	<cffunction name="addWatch" access="public" output="true" returntype="string" hint="Adds ajax update functionality for the field">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="html" type="string" required="true" hint="The html to wrap" />
		
		<cfset var prefix = left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name)) />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
		
		<cfparam name="arguments.stMetadata.ftWatch" default="" /><!--- Set this value to a list of property names. Formtool will attempt to update with the ajax function when those properties change. --->
		<cfparam name="arguments.stMetadata.ftLoaderHTML" default="Loading..." /><!--- The HTML displayed in the field while the new UI is being ajaxed in --->
		
		<cfif not structkeyexists(arguments.stMetadata,"ajaxrequest") and len(arguments.stMetadata.ftWatch)>
			<skin:htmlHead library="extCoreJS" />
			<extjs:onReady id="ftWatch"><cfoutput>
				function getInputValue(name) {
					var objs = Ext.select("[name="+name+"]");
					var result = "";
					
					// input doesn't exist
					if (!objs.getCount()) {
						return "";
					}
					// checkbox
					else if (objs.item(0).dom.tagName=="INPUT" && objs.item(0).dom.type == 'checkbox') {
						result = [];
						objs.each(function(el){
							if (el.dom.checked) result.push(el.dom.value);
						});
						return result.join();
					}
					// radio
					else if (objs.item(0).dom.tagName=="INPUT" && objs.item(0).dom.type == 'radio') {
						objs = Ext.select("[name="+name+"][type=radio]");
						if (objs.getCount())
							return objs.item(0).dom.value;
						else
							return "";
					}
					// select
					else if (objs.item(0).dom.tagName=="SELECT") {
						return objs.item(0).dom.options[objs.item(0).dom.selectedIndex].value;
					}
					// everything else: text, password, hidden, etc
					else {
						result = [];
						objs.each(function(el){
							if (el.dom.checked) result.push(el.dom.value);
						});
						return result.join();
					}
				};
				
				function ajaxUpdate(event,el,opt) {
					var values = {};
					var watches = opt.ftWatch.split(",");
					for (var i=0; i<watches.length; i++)
						values[watches[i]] = getInputValue(opt.prefix+watches[i]);
					values[opt.property] = getInputValue(opt.prefix+opt.property);
					
					document.getElementById(opt.fieldname+"ajaxdiv").innerHTML = opt.ftLoaderHTML;
					Ext.Ajax.request({
						url: '#application.url.farcry#/facade/ftajax.cfm?formtool='+opt.formtool+'&typename='+opt.typename+'&fieldname='+opt.fieldname+'&property='+opt.property+'&objectid='+opt.objectid,
						success: function(response){
							this.update(response.responseText);
						},
						params: values,
						scope: Ext.get(opt.fieldname+"ajaxdiv")
					});
				};
			</cfoutput></extjs:onReady>
			<extjs:onReady><cfoutput>
				var opts#arguments.fieldname# = { 
					prefix:'#prefix#',
					objectid:'#arguments.stObject.objectid#', 
					fieldname:'#arguments.fieldname#',
					ftLoaderHTML:'#jsstringformat(arguments.stMetadata.ftLoaderHTML)#',
					ftWatch:'#arguments.stMetadata.ftWatch#',
					typename:'#arguments.typename#',
					property:'#arguments.stMetadata.name#',
					formtool:'#arguments.stMetadata.ftType#'
				};
				<cfloop list="#arguments.stMetadata.ftWatch#" index="thisprop">
					Ext.select("select[name=#prefix##thisprop#], input[name=#prefix##thisprop#][type=text], input[name=#prefix##thisprop#][type=password]").on("change",ajaxUpdate,this,opts#arguments.fieldname#);
					Ext.select("input[name=#prefix##thisprop#][type=checkbox], input[name=#prefix##thisprop#][type=radio]").on("click",ajaxUpdate,this,opts#arguments.fieldname#);
				</cfloop>
			</cfoutput></extjs:onReady>
		
			<cfreturn "<div id='#arguments.fieldname#ajaxdiv'>#arguments.html#</div>" />
		<cfelse>
			<cfreturn arguments.html />
		</cfif>
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
		
		<cfif structKeyExists(stMetadata,"ftEditMethod")>
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
	

</cfcomponent> 
