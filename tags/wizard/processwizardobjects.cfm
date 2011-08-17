<cfif application.security.isLoggedIn()>
	<cfset Variables.LockedBy = application.security.getCurrentUserID()>
<cfelse>
	<cfset Variables.LockedBy = "anonymous">
</cfif>


<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">
	
	<!--- Object to render --->
	<cfparam name="attributes.stObj" default="#structNew()#" >
	
	<!--- ObjectID of object to render --->
	<cfparam name="attributes.ObjectID" default="" >
	
	<!--- Type of Object to render --->
	<cfparam name="attributes.typename" default="" >
	
	<!--- This is used to override the default metadata as setup in the type.cfc. Can be usefull if wanting to specify a different validation method (ftValidationMethod) --->
	<cfparam name="attributes.stPropMetadata" default="#structNew()#">
	
	
	<cfparam name="typename" default="" >
	
	<!--- The structure to return the form variables into to process before creating/saving --->
	<cfparam name="attributes.r_stProperties" default="stProperties" >
	
	<!--- The name of the CALLER structure that contains the current stwizard object. --->
	<cfparam name="attributes.r_stwizard" default="stwizard" >
	


	<!--- This structure contains the methods to be used to save the field --->
	<cfparam name="attributes.stPropMethods" default="#structNew()#" >
	
	<!--- Could be types or rules.. --->
	<cfparam name="attributes.PackageType" default="types">
	
	<!--- list of arrayList fields to process on AfterSave.. --->
	<cfparam name="attributes.lArrayListGenerate" default="" />
	
	<cfset Caller[attributes.r_stProperties] = structNew()>
	<cfset Caller.lSavedObjectIDs = "">

	<cfparam name="FORM.farcryFormPrefixes" default="" >
	<cfparam name="variables.farcryFormPrefixesToProcess" default="" >

	<!--- Generally the stwizard is stored in CALLER.stwizard however this can be overridden in Processwizard --->
	<cfif not structKeyExists(CALLER,attributes.r_stwizard)>
		<cfabort showerror="The stwizard is not available. Please ensure it is passed correctly" />
	</cfif>	
	<cfset stwizard = CALLER[attributes.r_stwizard] />

	<!--- ------------------------------------------------- --->
	<!--- Setup the main parameters used by this custom tag --->
	<!--- ------------------------------------------------- --->
	<cfset stSetup = init(stwizard=stwizard,stObj=attributes.stObj,ObjectID=attributes.ObjectID,Typename=attributes.Typename)>
	<cfset oType = stSetup.oType>
	<cfset stObj = stSetup.stObj>
	<cfset lFields = stSetup.lFields>
	<cfset stFields = stSetup.stFields>
	<cfset typename = stSetup.typename>

	<!--- --------------------------------------------------------------------- --->
	<!--- Loop through all the prefixes and determine which prefixes to process --->
	<!--- --------------------------------------------------------------------- --->
	<cfloop list="#form.farcryFormPrefixes#" index="variables.Prefix" >
			
		<!--- Clean up Form[ObjectIDs] and FORM[Typenames] incase of duplications caused by Dynamic Array Library Pickers. --->
		<cfif structKeyExists(form,"#variables.Prefix#ObjectID") AND ListLen(FORM["#variables.Prefix#ObjectID"]) GT 1>			
			<cfset FORM["#variables.Prefix#ObjectID"] = ListGetAt(FORM["#variables.Prefix#ObjectID"],1)>			
		</cfif>
		<cfif structKeyExists(form,"#variables.Prefix#typename") AND ListLen(FORM["#variables.Prefix#typename"]) GT 1>
			<cfset FORM["#variables.Prefix#typename"] = ListGetAt(FORM["#variables.Prefix#typename"],1)>
		</cfif>
		
		
		<cfif NOT listFindNoCase(variables.farcryFormPrefixesToProcess,variables.Prefix)><!--- Eliminates Duplicates --->
			
			<!--- Processing an Object --->
			<cfif isDefined("stObj.ObjectID") AND len(stObj.ObjectID)>	
				
				<cfif structKeyExists(form,"#Prefix#ObjectID") AND FORM["#Prefix#ObjectID"] EQ stObj.ObjectID>
					
					<cfset variables.farcryFormPrefixesToProcess = ListAppend(variables.farcryFormPrefixesToProcess,Prefix )>
	
				</cfif>

			<!--- Processing a Type --->
			<cfelse>
				<cfif structKeyExists(FORM,"#Prefix#typename") AND FORM["#Prefix#typename"] EQ stSetup.typename>					
					<cfset variables.farcryFormPrefixesToProcess = ListAppend(variables.farcryFormPrefixesToProcess,Prefix )>	
				</cfif>	
			</cfif>
		</cfif>

	</cfloop>
		
	<cfif NOT len(variables.farcryFormPrefixesToProcess)>
		<cfexit method="exittag">
	</cfif>
	
	
	<cfset ProcessingFormObjectPosition = 1>
	
	
	<!--- DO THIS THE FIRST TIME THROUGH (AND THEN AGAIN IN THE END for each loop --->
	<cfset SetupProcessObject(Position=ProcessingFormObjectPosition)>
			
	

</cfif>


<cfif thistag.ExecutionMode EQ "End">
	
	
	<cfif (isDefined("Request.BreakProcessingCurrentFormObject") AND Request.BreakProcessingCurrentFormObject EQ 1)>
		
		<!--- DO NOT PROCESS THIS LOOP --->
		<cfset Request.BreakProcessingCurrentFormObject = 0>

	<cfelse>

		<cfset oType = createobject("component",application.stcoapi[typename].packagepath)>
		<cfif application.security.isLoggedIn()>
			<cfset Caller[attributes.r_stProperties].lastupdatedby = application.security.getCurrentUserID()>
		<cfelse>
			<cfset Caller[attributes.r_stProperties].lastupdatedby = "anonymous">
		</cfif>
		
		
		<!--- APPEND the object that is currently in the wizard to the form submitted object --->
		<cfif structKeyExists(stwizard.data, Caller[attributes.r_stProperties].objectid)>
			<cfset bResult = structAppend(Caller[attributes.r_stProperties], stwizard.data[Caller[attributes.r_stProperties].objectid], false )  />
		</cfif>

		<cfset oImageFormTool = createObject("component", application.formtools["image"].packagepath) />
		<cfset Caller[attributes.r_stProperties] = oImageFormTool.ImageAutoGenerateBeforeSave(typename=typename,stProperties=Caller[attributes.r_stProperties],stFields=stFields, stFormPost=Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost']) />
		
		<cfif structKeyExists(oType,"BeforeSave")>
			<cfset Caller[attributes.r_stProperties] = oType.BeforeSave(stProperties=Caller[attributes.r_stProperties],stFields=stFields, stFormPost=Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost']) />	
		</cfif>
	
		<cfif len(attributes.lArrayListGenerate)>
			
			<cfset oFormTools = createObject("component", "farcry.core.packages.farcry.formtools") />
			<cfloop list="#attributes.lArrayListGenerate#" index="i">
				<cfset arrayField = stFields[i].metadata.ftArrayField />
				<cfif structKeyExists(stFields[i].metadata, "ftListType")>
					<cfset ListType = stFields[i].metadata.ftListType />
				<cfelse>
					<cfset ListType = "none" />
				</cfif>
				<cfif structKeyExists(stFields[i].metadata, "ftWebskin")>
					<cfset Webskin = stFields[i].metadata.ftWebskin />
				<cfelse>
					<cfset Webskin = "" />
				</cfif>
				<cfif structKeyExists(stFields[i].metadata, "ftIncludeLink")>
					<cfset bIncludeLink = stFields[i].metadata.ftIncludeLink />
				<cfelse>
					<cfset bIncludeLink = "false" />
				</cfif>
				<cfset Caller[attributes.r_stProperties][i] = oFormTools.ArrayListGenerate(aField=Caller[attributes.r_stProperties][arrayField]) />
			</cfloop>

		</cfif>
		
	
		<!--- Not in the wizard and therefore a new object. Need to save to db and then put in the wizard --->
		<cfif NOT structKeyExists(stwizard.data,Caller[attributes.r_stProperties].objectid)>
			<cfset stObj = oType.setData(stProperties=Caller[attributes.r_stProperties],user=Variables.LockedBy)>
			<cfset stwizard.data[Caller[attributes.r_stProperties].objectid] =  Duplicate(stObj)>
		</cfif>
		
		<!--- TO DO. NEED TO ADD ALL PROPERTIES TO DATA AND NOT JUST THE ONES SUBMITTED. --->
		<cfloop list="#structKeyList(Caller[attributes.r_stProperties])#" index="i">
			<cfset stwizard.data[Caller[attributes.r_stProperties].objectid][i] = Caller[attributes.r_stProperties][i]>
		</cfloop>		


		<cfset caller.lSavedObjectIDs = listappend(caller.lSavedObjectIDs,Caller[attributes.r_stProperties].ObjectID)>
	
	</cfif>



	
	<cfset dummy = StructDelete(Caller,"stProperties")>

	<cfset ProcessingFormObjectPosition = ProcessingFormObjectPosition  + 1>

	<cfif ProcessingFormObjectPosition LTE ListLen(variables.farcryFormPrefixesToProcess)>

		<cfset SetupProcessObject(Position=ProcessingFormObjectPosition)>
		
		<cfexit method="loop" >

	<cfelse>
		
		<!--- Save the wizard and return it to the CALLER --->
		<cfset stwizard = createObject("component",application.stcoapi['dmWizard'].packagepath).Write(ObjectID=stwizard.ObjectID,Data="#stwizard.Data#")>
			
		<!--- Return the updated stwizard to the CALLER. --->
		<cfset CALLER[attributes.r_stwizard] = stwizard />
		
		
	</cfif>


</cfif>


<cffunction name="Init" output="true" access="private" returntype="struct" hint="Returns a Structure containing the component,  fieldlist, field metadata and type of object to be processed. If only 1 object is to be processed then it also passes that object back in stObj.">
	<cfargument name="stwizard" required="true" type="struct">
	<cfargument name="stObj" required="true" type="struct">
	<cfargument name="ObjectID" required="true" type="string">
	<cfargument name="typename" required="true" type="string">	
	
	<cfset var stResult = StructNew()><!--- Returning Structure --->
	
	
	<cfif not structIsEmpty(arguments.stObj)>
		<!--- We need to process the object that has been passed.  --->
		<cfset arguments.ObjectID = arguments.stObj.ObjectID>
	</cfif>
		
	<cfif  structIsEmpty(arguments.stObj) AND not len(arguments.ObjectID) AND not len(arguments.typename)>
		<!--- We need to process the the Primary Object of the wizard we are processing  --->
		<cfset arguments.ObjectID = stwizard.PrimaryObjectID />
	</cfif>

	
	<cfif len(arguments.ObjectID)>
		<!--- We are processing the Object/ObjectID passed --->
		<cfif isStruct(arguments.stObj) and NOT structIsEmpty(arguments.stObj)>
	
			<cfset stResult.oType = createobject("component",application.stcoapi[arguments.stObj.typename].packagepath)>
			<cfset stResult.stObj = arguments.stObj>
			<cfset stResult.lFields = StructKeyList(application.stcoapi[arguments.stObj.typename].stprops)>
			<cfset stResult.stFields = application.stcoapi[arguments.stObj.typename].stprops>
			<cfset stResult.typename = arguments.stObj.typename>
		
		<cfelse>
			
			<cfif not isDefined("arguments.typename") or not len(arguments.typename)>
				<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
				<cfset arguments.typename = q4.findType(objectid=arguments.objectid)>
			</cfif>
			
			<!--- populate the primary values --->
			<cfset stResult.typename = arguments.typename>
			<cfset stResult.oType = createobject("component",application.stcoapi[arguments.typename].packagepath)>
			<cfset stResult.lFields = StructKeyList(application.stcoapi[arguments.typename].stprops)>
			<cfset stResult.stFields = application.stcoapi[arguments.typename].stprops>

			<cfif structKeyExists(stwizard.data,arguments.objectid)>
				<cfset stResult.stObj = stwizard.data[arguments.objectID]>
			<cfelse>
				<!--- Get the object from the DB --->
				<cfset stResult.stObj = stResult.oType.getData(arguments.objectID)>
			</cfif>
			
		</cfif>	
			

	<cfelseif len(arguments.typename)>

		<cfset stResult.oType = createobject("component",application.stcoapi[arguments.typename].packagepath)>
		<cfset stResult.stObj = StructNew()>
		<cfset stResult.lFields = StructKeyList(application.stcoapi[arguments.typename].stprops)>
		<cfset stResult.stFields = application.stcoapi[arguments.typename].stprops>
		<cfset stResult.typename = arguments.typename>
		
	<cfelse>
		<cfabort showerror="Attempting Processing Unknown Form Objects">
	</cfif>
		
	<cfreturn stResult> 
	
</cffunction>

<cffunction name="SetupProcessObject" access="private" output="true" returntype="void" hint="Sets up the caller structure that contains the fields submitted by the form for the current object after they have been processed by each relevent Field Validate method">
	<cfargument name="Position" required="yes" type="numeric">

	<cfset ProcessingFormObjectPrefix = ListGetAt(variables.farcryFormPrefixesToProcess,arguments.Position)>

	<cfset Caller[attributes.r_stProperties] = structNew() />
	
	<cfloop list="#lFields#" index="i" >

		<cfif structKeyExists(FORM,"#ProcessingFormObjectPrefix##i#")>
			
		
			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['MetaData'][i] = StructNew()>

			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['MetaData'][i] = Duplicate(stFields[i].MetaData)>
	
			<cfset ftFieldMetadata = request.farcryForm.stObjects[ProcessingFormObjectPrefix].MetaData[i]>
			<cfset ftFieldMetadata.FormFieldPrefix = ProcessingFormObjectPrefix>
	
			
			<!--- If we have been sent stPropMetadata for this field then we need to append it to the default metatdata setup in the type.cfc  --->
			<cfif structKeyExists(attributes.stPropMetadata,ftFieldMetadata.Name)>
				<cfset StructAppend(ftFieldMetadata, attributes.stPropMetadata[ftFieldMetadata.Name])>
			</cfif>
			
			<!--- SETUP REQUIRED PARAMETERS --->
			<cfif not isDefined("ftFieldMetadata.ftType")>
	
				<cfset ftFieldMetadata.ftType = ftFieldMetadata.Type>
	
			</cfif>
			
			<cfif NOT StructKeyExists(application.formtools,ftFieldMetadata.ftType)>
				<cfif StructKeyExists(application.formtools,ftFieldMetadata.Type)>
					<cfset ftFieldMetadata.ftType = ftFieldMetadata.Type>
				<cfelse>
					<cfset ftFieldMetadata.ftType = "Field">
				</cfif>
			</cfif>	
		
		
				
			<!--- Need to put all the form fields relevent to this field into a struct. This will include any fields that begin with the name of the field. ie. OrderDate field will also put OrderDateDay, OrderDateMonth and OrderDateYear into the struct --->
			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i] = StructNew()>
			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].value = "">
			<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].stSupporting = StructNew()>

			<cfloop list="#StructKeyList(FORM)#" index="j">
				<cfif FindNoCase("#ProcessingFormObjectPrefix##i#",j)>
				
					<!--- This will strip out the prefix from the FormFields and enable us to send a clean formpost structure to validate with only the current object formfields by their original name. --->
					<cfif "#ProcessingFormObjectPrefix##i#" EQ j>
						<!--- This is the actual field value --->
						<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].value = FORM[j]>
					<cfelse>
						<!--- These are supporting fields --->
						<cfset Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].stSupporting[ReplaceNoCase(j,'#ProcessingFormObjectPrefix##i#','')] = FORM[j]>
					</cfif>
					
				</cfif>
			</cfloop>

			<!--- Default fieldType to the object type --->
			<cfset tFieldType = createobject("component",application.stCOAPI[FORM['#ProcessingFormObjectPrefix#typename']].packagepath) />
				
			<!--- Need to determine which method to run on the field --->
			<cfif len(ftFieldMetadata.ftValidateMethod)>
				<cfset FieldMethod = ftFieldMetadata.ftValidateMethod>
				
				<!--- Check to see if this method exists in the current oType CFC. If not hange o to the formtool --->
				<cfif not structKeyExists(tFieldType,ftFieldMetadata.ftValidateMethod)>
					<cfset tFieldType = application.formtools[ftFieldMetadata.ftType].oFactory.init() />
				</cfif>
			<cfelseif structKeyExists(tFieldType,"ftValidate#ftFieldMetadata.Name#")>
				<cfset FieldMethod = "ftValidate#ftFieldMetadata.Name#" />
			<cfelse>
				<cfset FieldMethod = "validate" />
				<cfset tFieldType = application.formtools[ftFieldMetadata.ftType].oFactory.init() />
			</cfif>

			<cfif (i EQ "ObjectID") OR (i EQ "typename")>
				<cfset "Caller.#attributes.r_stProperties#.#i#" = Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].value>
			<cfelse>
				<cfinvoke component="#tFieldType#" method="#FieldMethod#" returnvariable="stResult">
					<cfinvokeargument name="ObjectID" value="#FORM['#ProcessingFormObjectPrefix#objectid']#">
					<cfinvokeargument name="Typename" value="#FORM['#ProcessingFormObjectPrefix#typename']#">			
					<cfinvokeargument name="stFieldPost" value="#Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i]#">
					<cfinvokeargument name="stMetadata" value="#ftFieldMetadata#">
				</cfinvoke>
							
				<cfset "Caller.#attributes.r_stProperties#.#i#" = stResult.Value>
				
					
				
				<cfif ftFieldMetadata.Type eq "array">
					<cfloop list="#structKeyList(stFields)#" index="j">
						<cfif structKeyExists(stFields[j].metadata, "ftType") AND structKeyExists(stFields[j].metadata, "ftArrayField") AND stFields[j].metadata.ftType EQ "arrayList" AND stFields[j].metadata.ftArrayField EQ i>
						
							<cfset attributes.lArrayListGenerate = listAppend(attributes.lArrayListGenerate, j) />
							
						</cfif>
						
					</cfloop>
				</cfif>
			
			</cfif>
		
		
		
		</cfif>
	</cfloop>
		
	<cfif structKeyExists(FORM,"#ProcessingFormObjectPrefix#typename")>
		<cfset "Caller.#attributes.r_stProperties#.typename" = Evaluate("FORM['#ProcessingFormObjectPrefix#typename']")>
	</cfif>
	
		
</cffunction>
