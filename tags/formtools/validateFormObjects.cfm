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


	<!--- This structure contains the methods to be used to save the field --->
	<cfparam name="attributes.stPropMethods" default="#structNew()#" >
	
	
	<!--- Could be types or rules.. --->
	<cfparam name="attributes.PackageType" default="types">
	
	<!--- Flag to process image autogenerate routine.. --->
	<cfparam name="attributes.bimageautogenerate" default="false" />
	
	<!--- list of arrayList fields to process on AfterSave.. --->
	<cfparam name="attributes.lArrayListGenerate" default="" />
	
	<!--- Allow processing to session only. --->
	<cfparam name="attributes.bSessionOnly" default="false" />
	
	
	<cfset Caller[attributes.r_stProperties] = structNew()>
	<cfset Caller.lSavedObjectIDs = "">

	<cfparam name="FORM.farcryFormPrefixes" default="" >
	<cfparam name="variables.farcryFormPrefixesToProcess" default="" >

	<cfparam name="REQUEST.stFarcryFormValidation" default="#structNew()#" />
	<cfparam name="REQUEST.stFarcryFormValidation.bSuccess" default="true" />


	 
	<!--- Check to see if we should be performing server side validation --->
	<cfif structKeyExists(form, "FARCRYFORMVALIDATION") AND NOT form.FARCRYFORMVALIDATION >
		<cfexit method="exittag">
	</cfif>
	
	<!--- ------------------------------------------------- --->
	<!--- Setup the main parameters used by this custom tag --->
	<!--- ------------------------------------------------- --->
	<cfset stSetup = init(stObj=attributes.stObj,ObjectID=attributes.ObjectID,Typename=attributes.Typename)>
	<cfset stType = stSetup.stType>
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
	
				
				<cfif NOT isDefined("CALLER.stPLP.plp.inputObjects") or NOT structKeyExists(CALLER.stPLP.plp.inputObjects,stObj.ObjectID)>
					<cfset CALLER.stPLP.plp.inputObjects[stObj.ObjectID] = Duplicate(stObj)>	
					<cfset CALLER.stPLP.plp.outputObjects[stObj.ObjectID] = Duplicate(stObj)>	
				</cfif>
			
			
			<!--- Processing a Type --->
			<cfelse>
	
				<cfif structKeyExists(FORM,"#Prefix#typename") AND FORM["#Prefix#typename"] EQ attributes.typename>
	
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
	

	<cfset dummy = StructDelete(Caller,"stProperties")>

	<cfset ProcessingFormObjectPosition = ProcessingFormObjectPosition  + 1>

	<cfif ProcessingFormObjectPosition LTE ListLen(variables.farcryFormPrefixesToProcess)>

		<cfset SetupProcessObject(Position=ProcessingFormObjectPosition)>
		
		<cfexit method="loop" >

	</cfif>


</cfif>


<cffunction name="Init">
	<cfargument name="stObj" required="true" type="any">
	<cfargument name="ObjectID" required="true" type="string">
	<cfargument name="typename" required="true" type="string">
	
	<cfset stResult = StructNew()>
	
	<cfif isStruct(arguments.stObj) and NOT structIsEmpty(arguments.stObj)>


		<cfset stResult.stObj = arguments.stObj>
		<cfset stResult.typename = arguments.stObj.typename>
		
			
		<cfset stPackage = application.stcoapi[stResult.typename]>
		<cfset packagePath = application.stcoapi[stResult.typename].packagepath>
		
		
		<cfset stResult.stType = createobject("component",packagePath)>
		<cfset stResult.lFields = StructKeyList(stPackage.stprops)>
		<cfset stResult.stFields = stPackage.stprops>


	
	<cfelseif len(arguments.ObjectID)>

		
		<cfif not isDefined("arguments.typename") or not len(arguments.typename)>

			<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
			<cfset arguments.typename = q4.findType(objectid=arguments.objectid)>

		</cfif>
		
		
		<cfset stResult.typename = arguments.typename>
			
		<cfset stPackage = application.stcoapi[stResult.typename]>
		<cfset packagePath = application.stcoapi[stResult.typename].packagepath>
		
		
		<cfset stResult.stType = createobject("component",packagePath)>

		<cfset stResult.stObj = stResult.stType.getData(arguments.objectID)>

		<cfset stResult.lFields = StructKeyList(stPackage.stprops)>
		<cfset stResult.stFields = stPackage.stprops>
		
	<cfelseif len(arguments.typename)>


		<cfset stResult.stObj = StructNew()>
		<cfset stResult.typename = arguments.typename>
			
		<cfset stPackage = application.stcoapi[stResult.typename]>
		<cfset packagePath = application.stcoapi[stResult.typename].packagepath>
		
		
		
		<cfset stResult.stType = createobject("component",packagePath)>
		<cfset stResult.lFields = StructKeyList(stPackage.stprops)>
		<cfset stResult.stFields = stPackage.stprops>
	<cfelse>
		<!--- PROCESSING ALL SUBMITTED OBJECTS --->
		<!--- <cfabort showerror="Processing Unknown Form Objects"> --->
		<!--- <cfexit> --->
	</cfif>
		
	<cfreturn stResult> 
</cffunction>

<cffunction name="SetupProcessObject" access="private" output="true" returntype="void">
	<cfargument name="Position" required="yes" type="numeric">
	


	<cfset ProcessingFormObjectPrefix = ListGetAt(variables.farcryFormPrefixesToProcess,arguments.Position)>

	<cfset Caller[attributes.r_stProperties] = structNew() />

	<cfloop list="#lFields#" index="i" >

		<cfif structKeyExists(FORM,"#ProcessingFormObjectPrefix##i#")>
			
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

		</cfif>
	</cfloop>
	
			
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
			
			<cfif i EQ "ObjectID" or i EQ "typename">
				<cfset "Caller.#attributes.r_stProperties#.#i#" = Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i].value>
			<cfelse>
				<cfinvoke component="#tFieldType#" method="#FieldMethod#" returnvariable="stResult">
					<cfinvokeargument name="ObjectID" value="#FORM['#ProcessingFormObjectPrefix#objectid']#">
					<cfinvokeargument name="Typename" value="#FORM['#ProcessingFormObjectPrefix#typename']#">
					<cfinvokeargument name="stFormPost" value="#Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost']#">
					<cfinvokeargument name="stFieldPost" value="#Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost'][i]#">
					<cfinvokeargument name="stMetadata" value="#ftFieldMetadata#">
				</cfinvoke>
				
				<cfset request.stFarcryFormValidation["#FORM['#ProcessingFormObjectPrefix#objectid']#"][i] = stResult />		
				
				<cfif structKeyExists(stResult, "bSuccess") and not stResult.bSuccess>
					
					<!--- FLAG THE FORM SUBMISSION AN UNSUCCESSFULL --->
					<cfset request.stFarcryFormValidation.bSuccess = false />
					
					<!--- CANCEL THE FORM SUBMISSION --->
					<cfset structDelete(form, "FARCRYFORMSUBMITBUTTON") />
					<cfset structDelete(form, "FARCRYFORMSUBMITTED") />
				</cfif>
						<cftry>	
				<cfset Caller[attributes.r_stProperties][i] = stResult.Value />
				<cfcatch><cfdump var="#Request.farcryForm.stObjects[ProcessingFormObjectPrefix]['FormPost']#"><cfdump var="#i#"><cfdump var="#stResult#"><cfabort></cfcatch></cftry>
				
				
				
			</cfif>
		
		
		
		</cfif>
	</cfloop>
	
	<cfif structKeyExists(FORM,"#ProcessingFormObjectPrefix#typename")>
		<cfset "Caller.#attributes.r_stProperties#.typename" = Evaluate("FORM['#ProcessingFormObjectPrefix#typename']")>
	</cfif>
</cffunction>
