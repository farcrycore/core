<!--- @@description:
	<p>Renders a dropdown select box, check boxes or radio buttons with data provided via a commer seperated list or from a method call</p> --->

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
	<p>List rendered as check boxes</p>
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
	<p>List rendered as radio buttons</p>
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
	<p>List with a method call to populate</p>
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
	<p>List with a method call to populate from another type component</p>
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
	
--->
<cfcomponent extends="field" name="list" displayname="list" hint="Field component to liase with all list field types"> 
 
	<cfproperty name="ftList" required="false" default="" hint="comma separated list of values or variable:value pairs to appear in the drop down. e.g apple,orange,kiwi or APP:apple,ORA:orange,KIW:kiwi" />
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

	<cffunction name="getListData" access="private" output="false" returntype="string" hint="This will return a list that is used by the edit function">
		<cfargument name="objectid" required="false" type="string" default="" hint="The objectid of the record we are getting the list for if available.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this property is part of.">
		<cfargument name="property" required="true" type="string" hint="The name of the property">
		<cfargument name="stPropMetadata" required="false" type="struct" default="#structnew()#" hint="The properties metadata if available">
		
		<cfset var rListData = "" />
		<cfset var oList = "" />
		<cfset var result = "" />
		
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
				<cfif rListData.recordCount AND listFindNoCase(rListData.columnList, "value") AND listFindNoCase(rListData.columnList, "name")>
					<cfloop query="rListData">
						<cfset result = listAppend(result, "#rListData.value#:#rListData.name#") />
					</cfloop>
				</cfif>
			<cfelse>
				<cfset result = rListData />
			</cfif>
		<cfelse>
			<cfset result = arguments.stPropMetadata.ftList />	
		</cfif>
			
		<cfreturn result />
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var optionValue = "" />
		<cfset var rListData = "" />
		<cfset var i = "" />
		<cfset var oList = "" />
		<cfset var lData = "" />

	
		<cfset lData = getListData(	objectid="#arguments.stobject.objectid#", 
									typename="#arguments.typename#",
									property="#arguments.stMetadata.name#",
									stPropMetadata="#arguments.stMetadata#") /> 
		
		<cfif listLen(lData)>
			<cfswitch expression="#arguments.stMetadata.ftRenderType#">
				
				<cfcase value="dropdown">								
					<cfsavecontent variable="html">
					
						<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#" class="selectInput #arguments.stMetadata.ftClass#" style="#arguments.stMetadata.ftStyle#"<cfif arguments.stMetadata.ftSelectMultiple> multiple="multiple"</cfif>></cfoutput>
						<cfloop list="#lData#" index="i">
							<cfif Left(i, 1) EQ ":">
								<cfset optionValue = "" /><!--- This means that the developer wants the value to be an empty string --->
							<cfelse>
								<cfset optionValue = ListFirst(i,":") />
							</cfif>
							<cfoutput><option value="#optionValue#" <cfif listFindNoCase(arguments.stMetadata.value, optionValue) or arguments.stMetadata.value eq optionValue> selected</cfif>>#ListLast(i , ":")#</option></cfoutput>
						</cfloop>
						<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=""></cfoutput>
						
					</cfsavecontent>					
				</cfcase>
				
				<cfcase value="checkbox">
					<cfsavecontent variable="html">
						
						<cfoutput>
						<div class="multiField">	
							<cfset tmpCount=0>
							<cfloop list="#lData#" index="i">
								<cfset tmpCount=tmpCount + 1>
								<cfif Left(i, 1) EQ ":">
									<cfset optionValue = "" /><!--- This means that the developer wants the value to be an empty string --->
								<cfelse>
									<cfset optionValue = ListFirst(i,":") />
								</cfif>
								<label class="inlineLabel">
									<input type="checkbox" name="#arguments.fieldname#" class="checkboxInput #IIF(listLen(lData) eq tmpCount ,DE(" #arguments.stMetadata.ftClass#"),DE(""))#" id="#arguments.fieldname#" value="#optionValue#"<cfif listFindNoCase(arguments.stMetadata.value, optionValue)> checked="checked"</cfif> />										
									<!--- <label class="fieldsectionlabel" class="fieldsectionlabel" for="#arguments.fieldname#">#ListLast(i , ":")#</label> --->
									<!--- MPS: styles aren't working so we are removing label for now until we have time to look at the css --->
									#ListLast(i , ":")#
									<cfif arguments.stMetadata.ftMultipleLines><br class="fieldsectionbreak" /></cfif> 
								</label />
							</cfloop>
							<input type="hidden" name="#arguments.fieldname#" value="">	
						</div>																		
						</cfoutput>
									
					</cfsavecontent>
				</cfcase>
				
				<cfcase value="radio">
					<cfsavecontent variable="html">
						
						<cfoutput>
							<div class="multiField">	
								<cfset tmpCount=0>
								<cfloop list="#lData#" index="i">
									<cfset tmpCount=tmpCount + 1>
									<cfif Left(i, 1) EQ ":">
										<cfset optionValue = "" /><!--- This means that the developer wants the value to be an empty string --->
									<cfelse>
										<cfset optionValue = ListFirst(i,":") />
									</cfif>
									<label class="inlineLabel">
										<input type="radio" name="#arguments.fieldname#" id="#arguments.fieldname#"  class="#IIF(listLen(lData) eq tmpCount,DE(" #arguments.stMetadata.ftClass#"),DE(""))#" value="#optionValue#"<cfif listFindNoCase(arguments.stMetadata.value, optionValue)> checked="checked"</cfif> />
										<!--- <label class="fieldsectionlabel" class="fieldsectionlabel" for="#arguments.fieldname#">#ListLast(i , ":")#</label> --->
										<!--- MPS: styles aren't working so we are removing label for now until we have time to look at the css --->
										#ListLast(i , ":")#
										<cfif arguments.stMetadata.ftMultipleLines><br class="fieldsectionbreak" /></cfif> 
									</label>
								</cfloop>
								<input type="hidden" name="#arguments.fieldname#" value="">
							
							</div>
						</cfoutput>
									
					</cfsavecontent>
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
		<cfset var lData = getListData(	objectid="#arguments.stobject.objectid#", 
									typename="#arguments.typename#",
									property="#arguments.stMetadata.name#",
									stPropMetadata="#arguments.stMetadata#") /> 
			
		<cfloop list="#lData#" index="i">			
			<cfif listFindNoCase(arguments.stMetadata.value,ListFirst(i,":"))>
				<cfset html = listappend(html,ListLast(i,":")) />
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
		<cfset var optionValue = "" />
		<cfset var lData = getListData(	typename="#filterTypename#",
										property="#filterProperty#") /> 
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="has selected">
					
					<cfparam name="arguments.stFilterProps.value" default="" />
					
					<cfoutput><select id="#arguments.fieldname#value" name="#arguments.fieldname#value" class="selectInput" multiple="multiple"></cfoutput>
					<cfloop list="#lData#" index="i">
						<cfif Left(i, 1) EQ ":">
							<cfset optionValue = "" /><!--- This means that the developer wants the value to be an empty string --->
						<cfelse>
							<cfset optionValue = ListFirst(i,":") />
						</cfif>
						<cfoutput><option value="#optionValue#" <cfif listFindNoCase(arguments.stFilterProps.value, optionValue) or arguments.stFilterProps.value eq optionValue> selected</cfif>>#ListLast(i , ":")#</option></cfoutput>
					</cfloop>
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
		<cfset var lData = getListData(	typename="#arguments.filterTypename#",
										property="#arguments.filterProperty#") /> 
										
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="has selected">
					<cfparam name="arguments.stFilterProps.value" default="" />
					<cfloop list="#lData#" index="i">			
						<cfif listFindNoCase(arguments.stFilterProps.value,ListFirst(i,":"))>
							<cfset html = listappend(html,ListLast(i,":")) />
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