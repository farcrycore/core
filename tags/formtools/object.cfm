<!---
	@@description: 
	<p>
		This tag is used to render a contentType on a display page
	</p>
	
	@@examples: 
	<p>Basic usage. Rendering a packages/forms object:</p>
	<code>
		&tl;ft:object typename="mmInquiry" /&gt;
	</code>
	
	<p>Rendering specific fields</p>
	<code>
		&lt;ft:object typename="farLogin" lFields="username,password" prefix="login" legend="" /&gt;
	</code>
	
	<p>Separate items from the same contentType, but grouped so ft:processFormObjects only sees one object:</p>
	<code>
		&lt;h1&gt;Your Stuff&lt;/h1&gt;
		&tl;ft:object typename="mmInquiry" lFields="firstname,lastname" key="thereCanBeOnlyOne" /&gt;

		&lt;h1&gt;Other Stuff&lt;/h1&gt;
		&tl;ft:object typename="mmInquiry" lFields="kidsname,dogsname" key="thereCanBeOnlyOne" /&gt;
	</code>
--->
 <cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
 <cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
 <cfimport taglib="/farcry/core/tags/grid/" prefix="grid" >

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<!---<cfset ParentTag = GetBaseTagList()>
<cfif ListFindNoCase(ParentTag, "cf_wizard")>
	<cfabort showerror="You must use the wiz:object inside of a wizard...">
</cfif> --->
		


<cfif thistag.ExecutionMode EQ "Start">

	<cfparam name="attributes.ObjectID" default=""><!--- ObjectID of object to render --->
	<cfparam name="attributes.stObject" default=""><!--- Object to render --->
	<cfparam name="attributes.typename" default=""><!--- Type of Object to render --->
	<cfparam name="attributes.key" default=""><!--- Used to group several ft:objects into one object. (Used to generate a new object) For example, if you have several ft:object's in an ft:form you can use this to group them into one object for ft:processFormObjects --->
	<cfparam name="attributes.ObjectLabel" default=""><!--- Used to group and label rendered object if required --->
	<cfparam name="attributes.lFields" default=""><!--- List of fields to render --->
	<cfparam name="attributes.lExcludeFields" default="label"><!--- List of fields to exclude from render --->
	<cfparam name="attributes.class" default=""><!--- wrapper class around output --->
	<cfparam name="attributes.style" default=""><!--- wrapper style around output --->
	<cfparam name="attributes.format" default="edit"><!--- edit or display --->
	<cfparam name="attributes.IncludeLabel" default="1">
	<cfparam name="attributes.labelClass" default="control-label"><!--- The class to be applied to all labels --->
	<cfparam name="attributes.IncludeFieldSet" default="">
	<cfparam name="attributes.legend" default=""><!--- the legend to output on the fieldset --->
	<cfparam name="attributes.helpTitle" default=""><!--- title for the help section --->
	<cfparam name="attributes.helpText" default=""><!--- text to provide help information for the fieldset --->
	<cfparam name="attributes.IncludeBR" default="1">
	<cfparam name="attributes.InTable" default="0">
	<cfparam name="attributes.insidePLP" default="0"><!--- how are we rendering the form --->
	<cfparam name="attributes.r_stFields" default=""><!--- the name of the structure that is to be returned with the form field information. --->
	<cfparam name="attributes.r_stPrefix" default=""><!--- the name of the structure that is to be returned with the form field prefix used. --->
	<cfparam name="attributes.stPropMetadata" default="#structNew()#"><!--- This is used to override the default metadata as setup in the type.cfc --->
	<cfparam name="attributes.wizardID" default=""><!--- If this object call is part of a wizard, the object will be retrieved from the wizard storage --->
	<cfparam name="attributes.bValidation" default="true"><!--- Flag to determine if client side validation classes are added to this section of the form. --->
	<cfparam name="attributes.lHiddenFields" default=""><!--- List of fields to render as hidden fields that can be use to inject a value into the form post. --->
	<cfparam name="attributes.stPropValues" default="#structNew()#">
	<cfparam name="attributes.bIncludeSystemProperties" default="false"><!--- Allow system properties to be displayed.. --->
	<cfparam name="attributes.lock" default="true"><!--- Lock if editing. --->
	<cfparam name="attributes.bShowFieldHints" default="true" type="boolean"><!--- Flag to determine if the field hints are display. --->
	<cfparam name="attributes.prefix" default="" /><!--- Allows the developer to pass in the prefix they wish to use. Default is the objectid stripped of the dashes. --->
	<cfparam name="attributes.focusField" default="" /><!--- Enter the name of the field to focus on when rendering the form. --->
	<cfparam name="attributes.autosave" default="" /><!--- Enter boolean to toggle default autosave values on properties --->
	
	
	<cfset variables.stReturnFields = structNew()>

	<!--- If the attributes [IncludeFieldSet] has not been explicitly defined, work out the value. --->
	<cfif attributes.includeFieldSet EQ "">
		<cfif len(attributes.r_stFields)>
			<cfset attributes.includeFieldSet = 0 />
		<cfelse>
			<cfset attributes.includeFieldSet = 1 />
		</cfif>
	</cfif>
	
	
	<!--- Never render the following fields if editing unless specifically requested. --->
	<cfif NOT attributes.bIncludeSystemProperties OR attributes.format EQ "edit">
		<cfset attributes.lExcludeFields = ListAppend(attributes.lExcludeFields,"objectid,locked,lockedby,lastupdatedby,ownedby,datetimelastupdated,createdby,datetimecreated,versionID,status")>
	</cfif>

	
	<cfif len(attributes.ObjectID)>
	<!--- build metadata from objectid --->
	
		<cfif not isDefined("attributes.typename") or not len(attributes.typename)>
			<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
			<cfset attributes.typename = q4.findType(objectid=attributes.objectid)>
		</cfif>		
	
		<cfif NOT len(attributes.typename)>
			<cfthrow type="Application" errorcode="tags.formtools.object" message="Typename could not be resolved for #attributes.objectid#." detail="Tried to look up typename and got nothing.  Content item does not exist in refObjects." />
		</cfif>
		
		<cfset stPackage = application.stcoapi[attributes.typename] />
		<cfset packagePath = application.stcoapi[attributes.typename].packagepath />
		
		<cfset oType = createobject("component",packagePath)>
		<cfset lFields = ValueList(stPackage.qMetadata.propertyname)>
		<cfset stFields = stPackage.stprops>
		<cfset typename = attributes.typename>
		<cfset ObjectID = attributes.ObjectID>
		
		<cfset stObj = oType.getData(attributes.objectID)>
	
	
	<cfelseif isStruct(attributes.stObject)>
	<!--- build metadata from complete object structure --->
		
		<cfset stObj = attributes.stObject>		
		<cfset attributes.typename = stObj.typename>	
		
	
		<cfset stPackage = application.stcoapi[attributes.typename] />
		<cfset packagePath = application.stcoapi[attributes.typename].packagepath />
				
		<cfset oType = createobject("component",packagePath)>
		<cfset lFields = ValueList(stPackage.qMetadata.propertyname)>
		<cfset stFields = stPackage.stprops>
		<cfset typename = attributes.typename>
		<cfset ObjectID = attributes.stObject.ObjectID>


	<cfelseif len(attributes.typename)>
	<!--- build metadata from type details --->
	
			
		<cfset stPackage = application.stcoapi[attributes.typename] />
		<cfset packagePath = application.stcoapi[attributes.typename].packagepath />
	
		<cfset oType = createobject("component",packagePath)>
		<cfset lFields = ValueList(stPackage.qMetadata.propertyname)>
		<cfset stFields = stPackage.stprops>
		<cfset typename = attributes.typename>
		
		
		<cfif len(attributes.key)>
			<cfparam name="session.stTempObjectStoreKeys" default="#structNew()#" />
			<cfparam name="session.stTempObjectStoreKeys[attributes.typename]" default="#structNew()#" />

			<cfif structKeyExists(session.stTempObjectStoreKeys[attributes.typename], attributes.key)>
				<cfif structKeyExists(Session.TempObjectStore, session.stTempObjectStoreKeys[attributes.typename][attributes.key])>
					<cfset attributes.objectid = session.stTempObjectStoreKeys[attributes.typename][attributes.key] />
				</cfif>
			</cfif>	
				
			
			<cfif not len(attributes.objectid)>
				<cfset attributes.objectid = application.fc.utils.createJavaUUID() />
				<cfset session.stTempObjectStoreKeys[attributes.typename][attributes.key] = attributes.objectid>
				<cfset st = oType.getData(objectID = attributes.objectid) />
				<cfset stResult = oType.setData(stProperties=st, bSessionOnly="true") />
			</cfif>	
		<cfelse>	
			<cfset attributes.objectid = application.fc.utils.createJavaUUID() />		
		</cfif>
		
		<cfset stObj = oType.getData(objectID="#attributes.objectid#")>
		
		
		<cfset ObjectID = stObj.objectID>
			
		
	
	<cfelse>
	<!--- nothing relevant passed into tag; throw --->
		<cfthrow type="Application" errorcode="tags.formtools.object" message="Object metadata could not be determined." detail="Make sure you actually passed in a value for either objectid, stobject or typename attributes." />
	</cfif>
	

	<cfset lFieldsToRender =  "">

	<!--- allow for whitespace in field list attributes by trimming --->
	<cfset attributes.lFields = replacenocase(attributes.lFields, " ", "", "ALL") />
	<cfset attributes.lHiddenFields = replacenocase(attributes.lHiddenFields, " ", "", "ALL") />
	<cfset attributes.lExcludeFields = replacenocase(attributes.lExcludeFields, " ", "", "ALL") />
	
	<!--- Determine fields to render --->

	<cfloop list="#attributes.lFields#" index="i">
		<cfif ListFindNoCase(variables.lFields,i)>
			<cfset lFieldsToRender =  listappend(lFieldsToRender,i)>
<!--- 			
			<!--- If the user explicitly wants a field to appear, remove it from the exclusion list. --->
			<cfif ListFindNoCase(attributes.lExcludeFields,i)>
				<cfset attributes.lExcludeFields =  listdeleteat(attributes.lExcludeFields,ListFindNoCase(attributes.lExcludeFields,i))>
			</cfif> --->
		</cfif>
		
		<!--- If the user explicitly wants a field to appear, remove it from the exclusion list. --->
		<cfif ListFindNoCase(attributes.lExcludeFields,i)>
			<cfset attributes.lExcludeFields =  listdeleteat(attributes.lExcludeFields,ListFindNoCase(attributes.lExcludeFields,i))>
		</cfif>
	</cfloop>
	

	<!--- Determine fields to render but as hidden fields --->
	<cfloop list="#attributes.lHiddenFields#" index="i">
		<cfif ListFindNoCase(variables.lFields,i)>
			<cfset lFieldsToRender =  listappend(lFieldsToRender,i)>
		</cfif>
		
		<!--- If the user explicitly wants a field to appear as a hidden form field, remove it from the exclusion list. --->
		<cfif ListFindNoCase(attributes.lExcludeFields,i)>
			<cfset attributes.lExcludeFields =  listdeleteat(attributes.lExcludeFields,ListFindNoCase(attributes.lExcludeFields,i))>
		</cfif>
	</cfloop>	
	
	<!--- If still no fields, just default to all the fields in the type --->
	<cfif not len(lFieldsToRender)>
		<cfset lFieldsToRender = variables.lFields>
	</cfif>	
	
	
	<!--- Determine fields to exclude from render --->
	<cfif isDefined("attributes.lExcludeFields") and len(attributes.lExcludeFields)>
		<cfloop list="#lFieldsToRender#" index="i">
			<cfif ListFindNoCase(attributes.lExcludeFields,i)>
				<cfset lFieldsToRender =  listdeleteat(lFieldsToRender,ListFindNoCase(lFieldsToRender,i))>
			</cfif>
		</cfloop>
	</cfif>

		
	<!--- CHECK TO SEE IF OBJECTED HAS ALREADY BEEN RENDERED. IF SO, USE SAME PREFIX --->
	<cfif isDefined("variables.stObj") and not structIsEmpty(variables.stObj)>
	
		<cfif not isDefined("Request.farcryForm.stObjects")>
			<!--- If the call to this tag is not made within the confines of a <ft:form> tag, then we need to create a temp one and then delete it at the end of the tag. --->
			<cfset Request.farcryForm.stObjects = StructNew()>
			<cfset Request.tmpDeleteFarcryForm = attributes.ObjectID>		
		</cfif>
		
		<cfloop list="#StructKeyList(Request.farcryForm.stObjects)#" index="key">
			<cfif structKeyExists(request.farcryForm.stObjects,'#key#') 
				AND structKeyExists(request.farcryForm.stObjects[key],'farcryformobjectinfo')
				AND structKeyExists(request.farcryForm.stObjects[key].farcryformobjectinfo,'ObjectID')
				AND (
						request.farcryForm.stObjects[key].farcryformobjectinfo.ObjectID EQ stObj.ObjectID
					)>
					<cfset variables.prefix = key>
			</cfif>			
			
		</cfloop>

	</cfif>
	

	<cfset Variables.CurrentCount = StructCount(request.farcryForm.stObjects) + 1>

	<!--- Determine the prefix to be used for this object --->
	<cfparam name="variables.prefix" default="" />		
	<cfif not len(variables.prefix)>
		<cfif len(attributes.prefix)>
			<cfset variables.prefix = attributes.prefix />
		<cfelse>
			<cfset variables.prefix = "fc#reReplace(variables.ObjectID,'[^\w]', '', 'all')#" />
		</cfif>
	</cfif>
	
	
	<cfset Request.farcryForm.stObjects[variables.prefix] = StructNew()>
		
	
	<!--- IF WE ARE RENDERING AN EXISTING OBJECT, ADD THE OBJECTID TO stObjects --->	
	<cfif isDefined("variables.stObj") and not structIsEmpty(variables.stObj)>
		<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID = stObj.ObjectID>
	</cfif>
	
	<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.typename = typename>
	<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectLabel = attributes.ObjectLabel>
	
	<cfif attributes.lock AND attributes.format EQ "Edit">
		<cfset Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.lock = true />
	</cfif>

<!--- 
	<cfif len(attributes.class)>
		<cfoutput><div class="#attributes.class#"></cfoutput>
	</cfif>
	<cfif attributes.IncludeFieldSet>
		<cfoutput><fieldset class="fieldset"></cfoutput>
	
		<cfif isDefined("attributes.legend") and len(attributes.legend)>
			<!--- <cfoutput><h2 class="legend">#attributes.legend#</h2></cfoutput> --->
			<cfoutput><legend>#attributes.legend#</legend></cfoutput>
		</cfif>	
	</cfif>
	
	<cfif structKeyExists(attributes,"HelpSection") and len(attributes.HelpSection)>
		<cfoutput>
			<div class="helpsection">
				<cfif structKeyExists(attributes,"HelpTitle") and len(attributes.HelpTitle)>
					<h4>#attributes.HelpTitle#</h4>
				</cfif>
				<p>#attributes.HelpSection#</p>
			</div>
		</cfoutput>
	</cfif> --->
	
	
	<cfset ftTypeMetadataAutoSave = application.fapi.getContentTypeMetadata(typename="#typename#", md="ftAutoSave", default="") />
	

	<cfloop list="#lFieldsToRender#" index="i">
		
		<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i] = StructNew()>

		<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i] = Duplicate(stFields[i].MetaData)>
		
		<!--- I18 conversion of field properties --->
		<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].ftLabel = oType.getI18Property(property=i,value='label') />
		<cfif structkeyexists(Request.farcryForm.stObjects[variables.prefix]['MetaData'][i],"ftHint") and len(Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].ftHint)>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].ftHint = oType.getI18Property(property=i,value='hint') />
		<cfelse>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].ftHint = "" />	
		</cfif>
		
		
		<!--- If we have been sent stPropValues for this field then we need to set it to this value  --->
		<cfif structKeyExists(request, "stFarcryFormValidation")
			AND structKeyExists(request.stFarcryFormValidation, stObj.ObjectID)
			AND structKeyExists(request.stFarcryFormValidation[stObj.ObjectID], i) >
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = request.stFarcryFormValidation['#stObj.ObjectID#']['#i#'].value />
		<cfelseif structKeyExists(attributes.stPropValues,i)>
			<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = attributes.stPropValues[i]>
			<cfset variables.stObj[i] = attributes.stPropValues[i]>
		<cfelse>
			<cfif isDefined("variables.stObj") and not structIsEmpty(variables.stObj)>					
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = variables.stObj[i]>
			<cfelseif structKeyExists(stFields[i].MetaData, "ftDefault")>
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = stFields[i].MetaData.ftDefault>
			<cfelseif structKeyExists(stFields[i].MetaData, "Default")>
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = stFields[i].MetaData.Default>
			<cfelse>
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value = "">
			</cfif>
								
		</cfif>
		
		<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].formFieldName = "#variables.prefix##stFields[i].MetaData.Name#">
			
		
		<!--- CAPTURE THE HTML FOR THE FIELD --->		
		<cfset ftFieldMetadata = request.farcryForm.stObjects[variables.prefix].MetaData[i]>
		
		<!--- If we have been sent stPropMetadata for this field then we need to append it to the default metatdata setup in the type.cfc  --->
		<cfif structKeyExists(attributes.stPropMetadata,ftFieldMetadata.Name)>
			<cfset StructAppend(ftFieldMetadata, attributes.stPropMetadata[ftFieldMetadata.Name])>
		</cfif>
		

		<!--- Add validation classes --->
		<cfif attributes.bValidation>
			<cfif len(ftFieldMetadata.ftValidation)>
				<cfloop list="#ftFieldMetadata.ftValidation#" index="iValidation">
					<cfset ftFieldMetadata.ftClass = "#ftFieldMetadata.ftClass# #lcase(iValidation)#">
				</cfloop>
			</cfif>
		</cfif>
		<cfset ftFieldMetadata.ftClass = Trim(ftFieldMetadata.ftClass)>
		

		<cfif len(attributes.focusField) AND ftFieldMetadata.Name EQ attributes.focusField>
			<cfset ftFieldMetadata.ftClass = "#ftFieldMetadata.ftClass# focus" />
		</cfif>
	
		<!--- CHECK TO ENSURE THE FORMTOOL TYPE EXISTS. OTHERWISE USE THE DEFAULT [FIELD] --->
		<cfif NOT StructKeyExists(application.formtools,ftFieldMetadata.ftType)>
			<cfif StructKeyExists(application.formtools,ftFieldMetadata.Type)>
				<cfset ftFieldMetadata.ftType = ftFieldMetadata.Type>
			<cfelse>
				<cfset ftFieldMetadata.ftType = "Field">
			</cfif>
		</cfif>		
				
		<cfparam name="ftFieldMetadata.ftShowLabel" default="true" />	
				
		
		<cfset tFieldType = application.fapi.getFormtool(ftFieldMetadata.ftType) />
		
		<!--- If we have temporarily changed the formtool type, then make sure we have the required defaults. --->
		<cfif ftFieldMetadata.ftType NEQ application.fapi.getPropertyMetadata(typename='#typename#', property='#i#', md='ftType')>
			
			<cfset stFormtoolDefaults = application.coapi.coapiAdmin.getFormtoolDefaults(formtool=ftFieldMetadata.ftType) />

			<cfset structAppend(ftFieldMetadata,stFormtoolDefaults,false) />

		</cfif>
		
		
		<!--- Need to determine which method to run on the field --->		
		<cfif structKeyExists(ftFieldMetadata,"Method")><!--- Have we been requested to run a specific method on the field. This can enable the user to run a display method inside an edit form for instance --->
			<cfset FieldMethod = ftFieldMetadata.method>
		<cfelse>
			<cfif attributes.Format EQ "Edit" and ftFieldMetadata.ftType NEQ "arrayList" and (not structKeyExists(ftFieldMetadata, "ftDisplayOnly") or not ftFieldMetadata.ftDisplayOnly)>
				<cfif len(ftFieldMetadata.ftEditMethod)>
					<cfset FieldMethod = ftFieldMetadata.ftEditMethod>
					
					<!--- Check to see if this method exists in the current oType CFC. if so. Change tFieldType the Current oType --->
					<cfif structKeyExists(oType,ftFieldMetadata.ftEditMethod)>
						<cfset tFieldType = oType>
					</cfif>
				<cfelse>
					<cfif structKeyExists(oType,"ftEdit#ftFieldMetadata.Name#")>
						<cfset FieldMethod = "ftEdit#ftFieldMetadata.Name#">						
						<cfset tFieldType = oType>
					<cfelse>
						<cfset FieldMethod = "Edit">
					</cfif>
					
				</cfif>
			<cfelse>
					
				<cfif len(ftFieldMetadata.ftDisplayMethod)>
					<cfset FieldMethod = ftFieldMetadata.ftDisplayMethod>
					<!--- Check to see if this method exists in the current oType CFC. if so. Change tFieldType the Current oType --->
					
					<cfif structKeyExists(oType,ftFieldMetadata.ftDisplayMethod)>
						<cfset tFieldType = oType>
					</cfif>
				<cfelse>
					<cfif structKeyExists(oType,"ftDisplay#ftFieldMetadata.Name#")>
						<cfset FieldMethod = "ftDisplay#ftFieldMetadata.Name#">						
						<cfset tFieldType = oType>
					<cfelse>
						<cfset FieldMethod = "display">
					</cfif>
					
				</cfif>
			</cfif>
		</cfif>	

	
			<!--- If the field is supposed to be hidden --->
		<cfif ListFind(attributes.lHiddenFields,i)>
		
			<cfsavecontent variable="variables.returnHTML">
				
				<cfif isArray(variables.stObj[i])>
					<cfset hiddenValue = arrayToList(Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value) />
				<cfelse>
					<cfset hiddenValue = Request.farcryForm.stObjects[variables.prefix]['MetaData'][i].value />
					
				</cfif>
				<!--- <cfif isArray(variables.stObj[i])>
					<cfset hiddenValue = arrayToList(variables.stObj[i]) />
				<cfelse>
					<cfset hiddenValue = variables.stObj[i] />
				</cfif> --->
				<cfoutput><input type="hidden" id="#variables.prefix##ftFieldMetadata.Name#" name="#variables.prefix##ftFieldMetadata.Name#" value="#hiddenValue#" /></cfoutput>
			</cfsavecontent>
			
			<cfif NOT len(Attributes.r_stFields)>
				<cfoutput>#variables.returnHTML#</cfoutput>
			<cfelse>
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][ftFieldMetadata.Name].HTML = returnHTML>
			</cfif>
		<cfelse>	
			
			<cfset variables.returnHTML = "">

			
			<cfif structKeyExists(tFieldType,FieldMethod)>
				

				<cftry>				
					
					<cfinvoke component="#tFieldType#" method="#FieldMethod#" returnvariable="variables.returnHTML">
						<cfinvokeargument name="typename" value="#typename#">
						<cfinvokeargument name="stObject" value="#stObj#">
						<cfinvokeargument name="stMetadata" value="#ftFieldMetadata#">
						<cfinvokeargument name="fieldname" value="#variables.prefix##ftFieldMetadata.Name#">
						<cfinvokeargument name="stPackage" value="#stPackage#">
						<cfinvokeargument name="prefix" value="#variables.prefix#">
					</cfinvoke>
					<cfset variables.returnHTML = application.formtools[ftFieldMetadata.ftType].oFactory.addWatch(typename=typename,stObject=stObj,stMetadata=ftFieldMetadata,fieldname="#variables.prefix##ftFieldMetadata.Name#",html=variables.returnHTML) />
										
					<cfcatch><cfdump var="#cfcatch#" expand="false"><cfabort></cfcatch>
				</cftry>
				
				<cfset variables.errorClass = "" />
				<cfset variables.formValidationMessage = "" />
				<cfset variables.formValidationMessageInner = "" />
				<cfif structKeyExists(request, "stFarcryFormValidation")
					AND structKeyExists(request.stFarcryFormValidation, stObj.ObjectID)
					AND structKeyExists(request.stFarcryFormValidation[stObj.ObjectID], i)
					AND structKeyExists(request.stFarcryFormValidation[stObj.ObjectID][i], "bSuccess")
					AND NOT request.stFarcryFormValidation[stObj.ObjectID][i].bSuccess >
					
					<cfset variables.formValidationMessageInner = request.stFarcryFormValidation[stObj.ObjectID][i].stError.message>
					<cfsavecontent variable="variables.formValidationMessage">
						<cfoutput>#request.stFarcryFormValidation[stObj.ObjectID][i].stError.message#</cfoutput>
						<!--- <div class="#request.stFarcryFormValidation[stObj.ObjectID][i].stError.class#">#request.stFarcryFormValidation[stObj.ObjectID][i].stError.message#</div> --->
					</cfsavecontent>
					
					<cfset variables.errorClass = "error" />
				</cfif>
				
				
			</cfif>

			<cfif isDefined("request.hideAutoSaveWrapper") AND request.hideAutoSaveWrapper EQ 1>
				<!--- Leave returnHTML as is --->
			<cfelse>
			
				
			
				<cfsavecontent variable="variables.returnHTML">
					<cfoutput>
					<span id="wrap-#variables.prefix##ftFieldMetadata.Name#" class="propertyRefreshWrap" ft:format="#attributes.format#" ft:type="#stObj.typename#" ft:objectid="#stObj.objectid#" ft:property="#ftFieldMetadata.Name#" ft:prefix="#variables.prefix#" ft:watchFieldname="#stObj.typename#.#ftFieldMetadata.Name#" ft:reloadOnAutoSave="#yesNoFormat(ftFieldMetadata.ftReloadOnAutoSave)#" ft:refreshPropertyOnAutoSave="#yesNoFormat(ftFieldMetadata.ftRefreshPropertyOnAutoSave)#" watchFieldname="#stObj.typename#.#ftFieldMetadata.Name#" ft:watchingFields="<cfif structKeyExists(FTFIELDMETADATA, "ftWatchingFields")>#ftFieldMetadata.ftWatchingFields#</cfif>" >
						#variables.returnHTML#
					</span>
					</cfoutput>
				</cfsavecontent>
				
				<!--- TODO: --->
				<!--- <cfif ftFieldMetadata.ftMultifield>
					<cfsavecontent variable="variables.returnHTML">
						<cfoutput><div class="multiField">#variables.returnHTML#</div></cfoutput>
					</cfsavecontent>
				</cfif> --->
				
			
				<cfset bAddAutoSave = false>
				
				<cfif len(attributes.autosave)>
					<cfset bAddAutoSave = attributes.autosave />
				<cfelseif isDefined("Request.farcryForm.autoSave") AND len(Request.farcryForm.autoSave)>
					<cfset bAddAutoSave = Request.farcryForm.autoSave />
				<cfelse>
					<cfif ftTypeMetadataAutoSave EQ "*" OR listFindNoCase(ftTypeMetadataAutoSave,ftFieldMetadata.Name)>
						<cfset bAddAutoSave = true>
					<cfelseif ftFieldMetadata.ftAutoSave>
						<cfset bAddAutoSave = true>
					</cfif>
				</cfif>
				
				<cfif bAddAutoSave>
						
					
					<cfsavecontent variable="variables.returnHTML">
						<cfoutput>
						<span class="wrap-save-on-change">#variables.returnHTML#</span>
						</cfoutput>
					</cfsavecontent>
					
					
					<!--- '#application.url.webtop#/facade/ftajax.cfm?ajaxmode=1&formtool='+watcher.formtool+'&typename='+watcher.typename+'&fieldname='+watcher.fieldname+'&property='+watcher.property+'&objectid='+watcher.objectid --->
					
					<cfif NOT request.mode.ajax><!--- We do not want multiple of this live watching code on a page --->
						<skin:onReady id="wrap-save-on-change">
						<cfoutput>
							
							$fc.reloadWebskinWraps = function(options) {
								var $defaultOptions = {
								    typename: '',
								    objectid: '',
								    webskin: ''
								}
								
								var $options = $.extend({}, $defaultOptions, options || {});
								
								$j('.webskin-wrap').each(function(index) {
									var $webskinWrap = $j(this);
									var $webskinTypename = $webskinWrap.attr('ft:typename');
									var $webskinObjectID = $webskinWrap.attr('ft:objectid');
									var $webskinView = $webskinWrap.attr('ft:webskin');
									
									var bRefresh = true;
									
									if($options.typename.length){
										if( $webskinTypename != $options.typename ) {
											bRefresh = false;
										}
									}
									
									if($options.objectid.length){
										if( $webskinObjectID != $options.objectid ) {
											bRefresh = false;
										}
									}
									
									if($options.webskin.length){
										if( $webskinView != $options.webskin ) {
											bRefresh = false;
										}
									}
									
									if (bRefresh){
										$fc.reloadWebskinWrap($webskinWrap);
									}
								});
								
							}
							
							$fc.reloadWebskinWrap = function($webskinWrap,focusFieldID) {
								
								focusFieldID = focusFieldID ? focusFieldID : '';
								
								
								var $webskinTypename = $webskinWrap.attr('ft:typename');
								var $webskinObjectID = $webskinWrap.attr('ft:objectid');
								var $webskinView = $webskinWrap.attr('ft:webskin');
								
								$j( $webskinWrap ).toromask('&nbsp;');
								$j( $webskinWrap ).load('/index.cfm?ajaxmode=1&type=' + $webskinTypename + '&objectid=' + $webskinObjectID + '&view=' + $webskinView, function(){
									$j( $webskinWrap ).torounmask('');
									if (focusFieldID.length){ $j('##' + focusFieldID).focus(); }
								});
							}
							
							$j(document).on('change', '.wrap-save-on-change input:not(.helper),.wrap-save-on-change textarea:not(.helper),.wrap-save-on-change select:not(.helper)', function() {	
								
								
								var $propertyWrap = $j(this).closest('.propertyRefreshWrap');
								var propertyPrefix = $propertyWrap.attr('ft:prefix');
								var propertyType = $propertyWrap.attr('ft:type');
								var propertyObjectID = $propertyWrap.attr('ft:objectid');
								var propertyName = $propertyWrap.attr('ft:property');
								var propertyWatchingFields = $propertyWrap.attr('ft:watchingFields');
								var reloadOnAutoSave = $propertyWrap.attr('ft:reloadOnAutoSave');
								var autoSaveToSessionOnly = $j(this).closest('form').hasClass('autoSaveToSessionOnly');
								
								var $webskinWrap = $j(this).closest('.webskin-wrap');
								var webskinType = $webskinWrap.attr('ft:typename');
								var webskinObjectID = $webskinWrap.attr('ft:objectid');
								var webskinView = $webskinWrap.attr('ft:webskin');
								
								lData = $propertyWrap.find("input,textarea,select").serialize();
								lData = lData.replace(new RegExp( propertyPrefix, "gi" ),"");
								
								$j.ajaxq('AutoSave',{
								
									type: "POST",
									cache: false,
									url: '/index.cfm?ajaxmode=1&type=' + propertyType + '&objectid=' + propertyObjectID + '&view=ajaxSaveProperty&bSessionOnly=' + autoSaveToSessionOnly + '&propertyName=' + propertyName, 
									context: $j(this),
									success: function(data){
										
										$j('.webskin-wrap').each(function(index) {
											var $currentWebskinWrap = $j(this);
											
											var $webskinWatchFields = $j(this).attr("ft:watchFields");
											
											if ($webskinWatchFields.length){
												var valueArray = $webskinWatchFields.split(",");
																						
												for(var i=0; i<valueArray.length; i++){
													if (valueArray[i] == (propertyPrefix + propertyName) ){
														// refresh the webskin wrap
														$fc.reloadWebskinWrap( $currentWebskinWrap );	
													} else if(valueArray[i] == (propertyName) ){
														// refresh the webskin wrap
														$fc.reloadWebskinWrap( $currentWebskinWrap );	
													}
												}
														
											}						
										});
										
										
										if(data['BSUCCESS'] == 1) {
											var focusFieldID = '';
											if ($webskinWrap.length) {
												var focusFieldID = $(':focus').attr('id');
												$fc.reloadWebskinWrap($webskinWrap, focusFieldID);
												
											} else {
												
												if (reloadOnAutoSave == 'Yes'){
													location=location;
												} else {
													$fc.refreshProperty( $j(this).closest('span.propertyRefreshWrap') );
													
													if (propertyWatchingFields.length){
														var valueArray = propertyWatchingFields.split(",");
																								
														for(var i=0; i<valueArray.length; i++){
															if (valueArray[i].indexOf('.') !== -1) {
																// refresh all properties regardless of object
																var elSelector = "span.propertyRefreshWrap[ft\\:watchFieldname='" + valueArray[i] + "']";
																
																$j(elSelector).each(function(index) {
																	$fc.refreshProperty( $j(this) );
																});
																		
															} else {			
																// only refresh the current objects property
																if ($j('##' + propertyPrefix + valueArray[i]).is(":focus")){
																	focusFieldID = $j('##' + propertyPrefix + valueArray[i]).attr('id');
																}
																
																$fc.refreshProperty( $j('##wrap-' + propertyPrefix + valueArray[i]), focusFieldID );
															}
														}
													}
												}
											}
										} else {
											$fc.refreshProperty( $j(this).closest('span.propertyRefreshWrap') );
											if (data['MESSAGE'].length){
												alert(data['MESSAGE']);
											} else {
												alert('Field [' + propertyName + '] was not saved');
											}
										}
										
									}, 
									error: function(data){	
									},
									complete: function(){
									},
									data: lData,
									
									timeout: 15000
								});
											
														
							});
						</cfoutput>
						</skin:onReady>
					</cfif>
				</cfif>
				
			</cfif>	
			
			<cfif NOT len(Attributes.r_stFields) and 1 eq 0>
				
				<grid:div class="control-group ctrlHolder #ftFieldMetadata.ftLabelAlignment#Labels #ftFieldMetadata.ftType# #variables.errorClass#">
					
					<cfoutput>#variables.formValidationMessage#</cfoutput>
					
					<cfif structKeyExists(ftFieldMetadata, "ftshowlabel")>
						<cfset bShowLabel = ftFieldMetadata.ftShowLabel />
					<cfelse>
						<cfset bShowLabel = true />
					</cfif>
		
					<cfif bShowLabel AND isDefined("Attributes.IncludeLabel") AND attributes.IncludeLabel EQ 1>
						<cfoutput><label for="#variables.prefix##ftFieldMetadata.Name#" class="#attributes.labelClass#">#ftFieldMetadata.ftlabel#<cfif findNoCase("required",ftFieldMetadata.ftClass)> <em>*</em> </cfif></label></cfoutput>
					</cfif>
					
	
					<cfoutput>
					<div class="controls">
						
		
						#variables.returnHTML#
						
						<cfif attributes.bShowFieldHints AND structKeyExists(ftFieldMetadata,"ftHint") and len(ftFieldMetadata.ftHint)>
							<!--- <cfoutput><p class="formHint">#ftFieldMetadata.ftHint#</p></cfoutput> --->
							<cfoutput><span class="help-inline">#ftFieldMetadata.ftHint#</span></cfoutput>
						<cfelse>
							<!--- <cfoutput><br style="clear:both;"></cfoutput> --->
						</cfif>
						
					</div>
					</cfoutput>
					
				</grid:div>
			<cfelse>
				
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][ftFieldMetadata.Name].HTML = variables.returnHTML>
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][ftFieldMetadata.Name].errorClass = variables.errorClass />
				<cfset Request.farcryForm.stObjects[variables.prefix]['MetaData'][ftFieldMetadata.Name].errorMessage = variables.formValidationMessageInner />
			
				<cfif structKeyExists(ftFieldMetadata, "ftshowlabel")>
					<cfset bShowLabel = ftFieldMetadata.ftShowLabel />
				<cfelse>
					<cfset bShowLabel = true />
				</cfif>
	
				<cfif bShowLabel AND isDefined("Attributes.IncludeLabel") AND attributes.IncludeLabel EQ 1>
					<cfsavecontent variable="Request.farcryForm.stObjects.#variables.prefix#.MetaData.#ftFieldMetadata.Name#.Label">
						<!--- <cfoutput><label for="#variables.prefix##ftFieldMetadata.Name#" class="#attributes.labelClass#">#ftFieldMetadata.ftlabel#<cfif findNoCase("required",ftFieldMetadata.ftClass)> <em>*</em> </cfif></label></cfoutput> --->
						<cfoutput>#ftFieldMetadata.ftlabel#<cfif findNoCase("required",ftFieldMetadata.ftClass)> <em>*</em> </cfif></cfoutput>
					</cfsavecontent>
				<cfelse>
					<cfset Request.farcryForm.stObjects[#variables.prefix#].MetaData[#ftFieldMetadata.Name#].Label = "">
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	

	
	

	
	<cfif len(Attributes.r_stFields) or 1 eq 1>
		<cfloop list="#attributes.r_stFields#" index="i">
			<cfif structKeyExists(Request.farcryForm.stObjects[variables.prefix],'MetaData')>
				<cfset CALLER[i] = Request.farcryForm.stObjects[variables.prefix]['MetaData']>
			<cfelse>
				<cfset CALLER[i] = StructNew()>
			</cfif>
			
			<cfset CALLER[i].lFieldsToRender = lFieldsToRender>
			<cfset CALLER[i].lHiddenFields = attributes.lHiddenFields>
			<cfset CALLER[i].fieldPrefix = variables.prefix>
		</cfloop>
	</cfif>
	
	<cfif len(Attributes.r_stPrefix)>
		<cfloop list="#attributes.r_stPrefix#" index="i">
			<cfset CALLER[i] = variables.prefix>
		</cfloop>
	</cfif>
	
</cfif>



<cfif thistag.ExecutionMode EQ "End">

	<cfif not len(Attributes.r_stFields)>
		
		<cfset attributes.formtheme = application.fapi.getConfig('formTheme','webtop')>
		
		<cfsavecontent variable="fieldsHTML">
			
			<!--- FIELDS --->
			<cfloop list="#lFieldsToRender#" index="i">
				
				<cfif NOT ListFind(attributes.lHiddenFields,i)>
					<cfset ftFieldMetadata = Request.farcryForm.stObjects[variables.prefix]['MetaData'][i]>
					
					<ft:field 	for="#ftFieldMetadata.formFieldName#" 
								label="#ftFieldMetadata.ftLabel#" 
								hint="#iif(attributes.bShowFieldHints,'ftFieldMetadata.ftHint','""')#" 
								errorMessage="#ftFieldMetadata.errorMessage#"
								class="#ftFieldMetadata.ftType# #ftFieldMetadata.errorClass#">
											
						<cfoutput>#ftFieldMetadata.html#</cfoutput>
						
					</ft:field>
				</cfif>
			</cfloop>
			
		</cfsavecontent>
	
	
	
			<!--- WRAPPER --->
			<cfif len(attributes.class) OR len(attributes.style)>
				<div class="#attributes.class#" style="#attributes.style#">
			</cfif>
			
			<!--- END WRAPPER --->
			<cfif len(attributes.class)>
				</div>
			</cfif>		
			
	<!--- 
	-Wrap		
	 -Fieldset
	  - Helpsection
	  - field
	  - field
		 --->
		<cfif attributes.IncludeFieldSet>
			<ft:fieldset legend="#attributes.legend#" helpTitle="#attributes.helpTitle#" helpText="#attributes.helpText#">
				<cfoutput>#fieldsHTML#</cfoutput>
			</ft:fieldset>
		<cfelse>
			<cfoutput>#fieldsHTML#</cfoutput>
		</cfif>
		
	</cfif>
	
	
	<cfoutput><input type="hidden" name="FarcryFormPrefixes" value="#variables.prefix#" /></cfoutput>
	
	<cfparam name="Request.farcryForm.lFarcryObjectsRendered" default="">

	<cfif attributes.format EQ "edit"
		AND StructKeyExists(Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo,"ObjectID")
		AND  NOT ListContains(Request.farcryForm.lFarcryObjectsRendered, Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID)>
			
		<cfoutput>
			<input type="hidden" name="#variables.prefix#ObjectID" value="#Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID#">
			<input type="hidden" name="#variables.prefix#Typename" value="#Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.Typename#">
		</cfoutput>
		

		
		<cfset Request.farcryForm.lFarcryObjectsRendered = ListAppend(Request.farcryForm.lFarcryObjectsRendered,Request.farcryForm.stObjects[variables.prefix].farcryformobjectinfo.ObjectID)>
	</cfif>
	
	<cfif isDefined("Request.tmpDeleteFarcryForm") AND Request.tmpDeleteFarcryForm EQ attributes.ObjectID AND  isDefined("Request.farcryForm")>
		<!--- If the call to this tag is not made within the confines of a <ft:form> tag and this is the object that created it, then we need to delete the temp one we created. --->
		<cfset dummy = structDelete(Request,"farcryForm")>
		<cfset dummy = structDelete(Request,"tmpDeleteFarcryForm")>
	</cfif>
</cfif>
