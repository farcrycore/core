<!--- @@description:
	<p>Renders a dropdown select box, check boxes or radio buttons with data provided via a comma separated list or from a method call</p> --->

<!--- @@examples:
	<p>Basic</p>
	<code>
	<cfproperty
 			ftSeq="15"
 			ftFieldset="Colors"
 			name="podHeaderColor"
	 		type="string"
	 		hint="Pod Header Color"
	 		required="false"
	 		default=""
	 		ftLabel="Pod Header Color"
 			ftType="list"
 			ftList="apple,orange,kiwi"/>
	</code> 
	<p>List with different values from text</p>
	<code>
	<cfproperty
 			ftSeq="15"
 			ftFieldset="Colors"
 			name="podHeaderColor"
	 		type="string"
	 		hint="Pod Header Color"
	 		required="false"
	 		default=""
	 		ftLabel="Pod Header Color"
 			ftType="list"
 			ftList="APP:apple,ORA:orange,KIW:kiwi"/>
	</code>
	<p>List rendered as check boxes</p>
	<code>
	<cfproperty
 			ftSeq="15"
 			ftFieldset="Colors"
 			name="podHeaderColor"
	 		type="string"
	 		hint="Pod Header Color"
	 		required="false"
	 		default=""
	 		ftLabel="Pod Header Color"
 			ftType="list"
 			ftList="apple,orange,kiwi"
			ftRenderType="checkbox"/>
	</code>
	<p>List rendered as radio buttons</p>
	<code>
	<cfproperty
 			ftSeq="15"
 			ftFieldset="Colors"
 			name="podHeaderColor"
	 		type="string"
	 		hint="Pod Header Color"
	 		required="false"
	 		default=""
	 		ftLabel="Pod Header Color"
 			ftType="list"
 			ftList="apple,orange,kiwi"
			ftRenderType="radio"/>
	</code>
	
	<p>List with a method call to populate</p>
	<code>
	<cfproperty
 			ftSeq="15"
 			ftFieldset="Colors"
 			name="podHeaderColor"
	 		type="string"
	 		hint="Pod Header Color"
	 		required="false"
	 		default=""
	 		ftLabel="Pod Header Color"
 			ftType="list"
 			ftListData="myMethod"
			/>
	</code>
	<p>List with a method call to populate from another type component</p>
	<code>
	<cfproperty
 			ftSeq="15"
 			ftFieldset="Colors"
 			name="podHeaderColor"
	 		type="string"
	 		hint="Pod Header Color"
	 		required="false"
	 		default=""
	 		ftLabel="Pod Header Color"
 			ftType="list"
 			ftListData="myMethod"
			ftListDataTypename="dmNews"/>
	</code>
--->
<cfcomponent extends="field" name="list" displayname="list" hint="Field component to liase with all list field types"> 
 
	<cfproperty name="ftList" required="false" default="" hint="comma separated list of values or variable:value pairs to appear in the drop down. e.g apple,orange,kiwi or APP:apple,ORA:orange,KIW:kiwi" />
	<cfproperty name="ftListDelims" required="false" default="," hint="Overrides the list delimiter used in ftList or in the string returned by ftListData" />
	<cfproperty name="ftListData" required="false" default="" hint="Method call that must return a string in the same variable value pair format as the ftlist attribute OR a query containing the columns value & name. Method gets passed the objectid of the currently edited object as an argument. e.g apple,orange,kiwi or APP:apple,ORA:orange,KIW:kiwi or queryNew('value,name')" />
	<cfproperty name="ftListDataTypename" required="false" default="" hint="Specific typename to call ftlistdata method on." />
	<cfproperty name="ftRenderType" required="false" default="dropdown" options="dropdown,checkbox,radio" hint="The way the list will get rendered." />
	<cfproperty name="ftSelectMultiple" required="false" default="false" options="true,false" hint="used when ftRenderType=dropdown. It allows the user to select multiple items" />
	<cfproperty name="ftClass" required="false" default="" hint="sets a class for the form element" />
	<cfproperty name="ftstyle" required="false" default="" hint="allows in line styles to be added to form element" />
	<cfproperty name="ftMultipleLines" required="false" default="true" options="true,false" hint="for radio and checkbox only, adds a break between each checkox or radio button" />
	
	
		

	<!--- import tag libraries --->
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
	

	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.list" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>

	<cffunction name="getListData" access="private" output="false" returntype="query" hint="This will return a list that is used by the edit function">
		<cfargument name="objectid" required="false" type="string" default="" hint="The objectid of the record we are getting the list for if available.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this property is part of.">
		<cfargument name="property" required="true" type="string" hint="The name of the property">
		<cfargument name="stPropMetadata" required="false" type="struct" default="#structnew()#" hint="The properties metadata if available">
		
		<cfset var rListData = "" />
		<cfset var oList = "" />
		<cfset var result = querynew("value,name") />
		<cfset var i = "" />
		
		<cfif structIsEmpty(arguments.stPropMetadata)>
			<cfset arguments.stPropMetadata = application.fapi.getPropertyMetadata(typename="#arguments.typename#", property="#arguments.property#") />
		</cfif>

		<cfif len(arguments.stPropMetadata.ftListData) >
			<cfif len(arguments.stPropMetadata.ftListDataTypename)>
				<cfset oList = application.fapi.getContentType(arguments.stPropMetadata.ftListDataTypename) />
			<cfelse>
				<cfset oList = application.fapi.getContentType(arguments.typename) />
			</cfif>
			
			<cfinvoke component="#oList#" method="#arguments.stPropMetadata.ftListData#" returnvariable="rListData">
				<cfinvokeargument name="objectid" value="#arguments.objectID#" />
			</cfinvoke>
			
			<cfif isQuery(rListData)>
				<cfreturn rListData />
			</cfif>
		<cfelse>
			<cfset rListData = arguments.stPropMetadata.ftList />	
		</cfif>
		
		<cfif len(rListData)>
			<cfloop list="#rListData#" index="i" delimiters="#arguments.stPropMetadata.ftListDelims#">
				<cfset queryAddRow(result) />
				<cfset querySetCell(result, "name", ListLast(i , ":")) />
				<cfif Left(i, 1) EQ ":">
					<!--- This means that the developer wants the value to be an empty string --->
					<cfset querySetCell(result, "value", "") />
				<cfelse>
					<cfset querySetCell(result, "value", ListFirst(i,":")) />
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn result />
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />
		<cfset var tmpCount = "" />
		<cfset var optionValue = "" />
		<cfset var rListData = "" />
		<cfset var i = "" />
		<cfset var oList = "" />
		<cfset var lData = "" />

	
		<cfset qData = getListData(	objectid="#arguments.stobject.objectid#", 
									typename="#arguments.typename#",
									property="#arguments.stMetadata.name#",
									stPropMetadata="#arguments.stMetadata#") /> 
		
		<cfif qData.recordcount>
			<cfswitch expression="#arguments.stMetadata.ftRenderType#">
				
				<cfcase value="dropdown">								
					<cfsavecontent variable="html"><cfoutput>
						<select id="#arguments.fieldname#" name="#arguments.fieldname#" class="selectInput #arguments.inputClass# #arguments.stMetadata.ftClass#" style="#arguments.stMetadata.ftStyle#"<cfif arguments.stMetadata.ftSelectMultiple> multiple="multiple"</cfif>>
							<cfloop query="qData">
								<option value="#qData.value#"<cfif listFindNoCase(arguments.stMetadata.value, qData.value)> selected="selected"</cfif>>#qData.name#</option>
							</cfloop>
						</select>
						<input type="hidden" name="#arguments.fieldname#" value="">
					</cfoutput></cfsavecontent>					
				</cfcase>
				
				<cfcase value="checkbox">
					<cfsavecontent variable="html"><cfoutput>
						<div class="multiField">
							<cfloop query="qData">
								<label>
									<input type="checkbox" name="#arguments.fieldname#" class="checkboxInput #arguments.stMetadata.ftClass#" value="#qData.value#"<cfif listFindNoCase(arguments.stMetadata.value, qData.value)> checked="checked"</cfif> />
									#qData.name#
									<cfif arguments.stMetadata.ftMultipleLines><br class="fieldsectionbreak" /></cfif> 
								</label>
							</cfloop>
							<input type="hidden" name="#arguments.fieldname#" value="">	
						</div>
					</cfoutput></cfsavecontent>
				</cfcase>
				
				<cfcase value="radio">
					<cfsavecontent variable="html"><cfoutput>
						<div class="multiField">
							<cfloop query="qData">
								<label>
									<input type="radio" name="#arguments.fieldname#" class="required #arguments.stMetadata.ftClass#" value="#qData.value#"<cfif listFindNoCase(arguments.stMetadata.value, qData.value)> checked="checked"</cfif> />
									#qData.name#
									<cfif arguments.stMetadata.ftMultipleLines><br class="fieldsectionbreak" /></cfif> 
								</label>
							</cfloop>
							<input type="hidden" name="#arguments.fieldname#" value="">
						</div>
					</cfoutput></cfsavecontent>
				</cfcase>
				
				<cfdefaultcase></cfdefaultcase>
					
			</cfswitch>
		</cfif>


		<cfreturn html />

	</cffunction>
	
	
	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var i = "" />
		<cfset var html = "" />
		<cfset var oList = "" />
		<cfset var rListData = "" />
		<cfset var qData = getListData(	objectid="#arguments.stobject.objectid#", 
									typename="#arguments.typename#",
									property="#arguments.stMetadata.name#",
									stPropMetadata="#arguments.stMetadata#") /> 
			
		<cfloop query="qData">
			<cfif listFindNoCase(arguments.stMetadata.value, qData.value)>
				<cfset html = listappend(html, qData.name) />
			</cfif>
		</cfloop>
		
		<cfreturn html>
	</cffunction>
	
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = arguments.stFieldPost.Value />
		<cfset stResult.stError = StructNew()>	

		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfif len(trim(stResult.value))>
		
			<!--- Remove any leading or trailing empty list items --->
			<cfif stResult.value EQ ",">
				<cfset stResult.value = "" />
			</cfif>
			<cfif left(stResult.value,1) EQ ",">
				<cfset stResult.value = right(stResult.value,len(stResult.value)-1) />
			</cfif>
			<cfif right(stResult.value,1) EQ ",">
				<cfset stResult.value = left(stResult.value,len(stResult.value)-1) />
			</cfif>			
		<cfelse>
			<cfset stResult.value = "" />
		</cfif>
					
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	<!------------------ 
	FILTERING FUNCTIONS
	 ------------------>	
	<cffunction name="getFilterUIOptions">
		<cfreturn "has selected" />
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
		<cfset var stPropMetadata = application.fapi.getPropertyMetadata(	typename="#arguments.filterTypename#",
																			property="#arguments.filterProperty#" ) />
		<cfset var i = "" />
		<cfset var optionValue = "" />
		<cfset var qData = getListData(	typename="#filterTypename#",
										property="#filterProperty#") /> 
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="has selected">
					
					<cfparam name="arguments.stFilterProps.value" default="" />
					
					<cfoutput><select id="#arguments.fieldname#value" name="#arguments.fieldname#value" class="selectInput" multiple="multiple"></cfoutput>
					<cfoutput query="qData">
						<option value="#qData.value#"<cfif listFindNoCase(arguments.stFilterProps.value, qData.value) or arguments.stFilterProps.value eq qData.value> selected="selected"</cfif>>#qData.name#</option>
					</cfoutput>
					<cfoutput></select><input type="hidden" name="#arguments.fieldname#value" value=""></cfoutput>
									
				</cfcase>
							
			</cfswitch>
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
	
	<cffunction name="displayFilterUI">

		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		
		<cfset var resultHTML = "" />
		<cfset var html = "" />														
		<cfset var i = "" />
		<cfset var qData = getListData(	typename="#arguments.filterTypename#",
										property="#arguments.filterProperty#") /> 
										
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="has selected">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfloop query="qData">
						<cfif listFindNoCase(arguments.stFilterProps.value, qData.value)>
							<cfset html = listappend(html, qData.name) />
						</cfif>
					</cfloop>
					<cfoutput>#html#</cfoutput>
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
		<cfset var i = "" />
		<cfset var bFirst = true />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="has selected">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfif listLen(arguments.stFilterProps.value)>
					
						
						<cfoutput>
						(
						<cfloop list="#arguments.stFilterProps.value#" index="i">
							<cfif bFirst>
								<cfset bFirst = false />
							<cfelse>
							OR
							</cfif>
							#arguments.filterProperty# = '#i#'
						</cfloop>
						)
						</cfoutput>
					</cfif>
				</cfcase>
				
			
			</cfswitch>
			
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
		
		
			
</cfcomponent>