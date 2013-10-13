<cfcomponent extends="types" name="dmWizard" displayname="wizard" hint="wizard" bSystem="true" 
	bAudit="false"
	bRefObjects="false">
	
	<!--------type properties-------->
	<cfproperty name="ReferenceID" type="string" displayname="Reference ID" hint="Reference ID of the wizard. A UUID for an existing object or a Typename for a new object" required="yes" >
	<cfproperty name="UserLogin" type="string" displayname="User Login" hint="Login ID of the user." required="no" default="" >
	<cfproperty name="Data" type="longchar" displayname="WDDX Data" hint="WDDX packet of the wizard Data." required="no" default="" >
	<cfproperty name="PrimaryObjectID" type="UUID" displayname="Primary ObjectID" hint="Object ID of the Primary Object." required="no" default="" >
	<cfproperty name="Steps" type="longchar" displayname="Steps" hint="List of steps in the wizard Process" required="no" default="" >
	<cfproperty name="CurrentStep" type="numeric" displayname="Current Step" hint="Current Step in the wizard Process" required="no" default="1" >
	
	
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	
	
	<cffunction name="Read" access="public" output="true" returntype="struct" hint="Returns the wizard Object with the WDDX Data field converted to a CF Structure">
		<cfargument name="wizardID" required="no" type="UUID">
		<cfargument name="UserLogin" required="no" type="String" default="unknown">
		<cfargument name="ReferenceID" required="no" type="String">
		
		<cfset var stwizard	= '' />
		<cfset var qwizard	= '' />
		<cfset var stwizardData	= '' />

		<cfif arguments.userLogin EQ "unknown" AND application.security.isLoggedIn()>
			<cfset arguments.userlogin = application.security.getCurrentUserID()>
		</cfif>
		
		<cfif isDefined("arguments.wizardID") and len(arguments.wizardID)>
			<cfset stwizard = getData(objectID=arguments.wizardID) />
		<cfelseif isDefined("arguments.UserLogin") and len(arguments.UserLogin) AND isDefined("arguments.ReferenceID") and len(arguments.ReferenceID)>
			<cfquery datasource="#application.dsn#" name="qwizard">
			SELECT *
			FROM dmWizard
			WHERE ReferenceID = '#arguments.ReferenceID#'
			AND UserLogin = '#arguments.UserLogin#'
			</cfquery>
			
			<!--- If the wizard exists, create the CF struct to return --->
			<cfif qwizard.RecordCount>
				<cfset stwizard = getData(objectID=qwizard.objectid) />
			<cfelseif isDefined("arguments.UserLogin") and len(arguments.UserLogin) AND isDefined("arguments.ReferenceID") and len(arguments.ReferenceID)>
				<cfset stwizard = Create(ReferenceID=arguments.ReferenceID,UserLogin=arguments.UserLogin)>
			</cfif>
			
		</cfif>
		
		<cfif isDefined("stwizard.Data")>
			<!--- only run this if the wddx packet has not already been extracted into a struct --->
			<cfif not isStruct(stwizard.Data)>
				<cfif IsWDDX(stwizard.Data)>
					<cfwddx action="WDDX2CFML" input="#stwizard.Data#" output="stwizardData">
					<cfset stwizard.Data = duplicate(stwizardData) />
				<cfelse>
					<cfset stwizard = Create(ReferenceID=stwizard.ReferenceID,UserLogin=arguments.UserLogin)>
					<cfwddx action="WDDX2CFML" input="#stwizard.Data#" output="stwizardData">
					<cfset stwizard.Data = duplicate(stwizardData) />
				</cfif>
			</cfif>
		<cfelse>
			<cfabort showerror="Farcy could not find or create the wizard requested." />
		</cfif>
		
		<!--- return the struct --->
		<cfreturn stwizard>
		
			
	</cffunction>
	
	<cffunction name="create" access="public" output="false" returntype="struct">
		<cfargument name="ReferenceID" required="yes" type="String">
		<cfargument name="UserLogin" required="yes" type="String">
		
		<cfset var stProperties = StructNew()>
		<cfset var typename = "" />
		<cfset var stResult = structnew() />
		<cfset var stWizard = structnew() />
		<cfset var o	= '' />
		<cfset var st	= '' />

		<cfset stProperties.UserLogin = arguments.UserLogin>
		<cfset stProperties.ReferenceID = arguments.ReferenceID>
		
		
		<cfif isvalid("uuid",arguments.ReferenceID)>
			<cfset typename = findType(ObjectID=arguments.ReferenceID) />
			<cfset o = createObject("component",application.stcoapi["#typename#"].packagepath) />
			<cfset st = o.getData(objectid=arguments.ReferenceID) />
		<cfelse>
			<cfif structKeyExists(application.stcoapi,arguments.ReferenceID)>
				<cfset o = createObject("component",application.stcoapi["#arguments.ReferenceID#"].packagepath) />
				<cfset st = o.getData(objectid=application.fc.utils.createJavaUUID()) />
			</cfif>
		</cfif>
		
		<cfset stProperties.PrimaryObjectID = st.ObjectID>
		<cfset stProperties.CurrentStep = 1>
		<cfset stProperties.OwnedBy = 'help'>
		
		<cfset variables.data = StructNew() />
		<cfset variables.data[st.ObjectID] = st />
		
		<cfwddx action="CFML2wddx" input="#variables.data#" output="stProperties.Data">
		
		<cfset stResult = createData(stProperties=stProperties,user=stProperties.UserLogin) />
		<cfset stwizard = getData(objectID=stresult.objectid) />
		
		<cfreturn stwizard>
	
	</cffunction>
	
	
	<cffunction name="Write" access="public" output="true" returntype="struct" hint="Saves the wizard to the DB and returns the wizard Data as a structure">
		<cfargument name="ObjectID" required="yes" type="UUID">
		<cfargument name="CurrentStep" required="no" type="numeric">
		<cfargument name="Steps" required="no" type="string" default="">
		<cfargument name="Data" required="no" type="Struct">
		
		<cfset var stwizard	= getData(objectID=arguments.objectid) />
		<cfset var stResult	= '' />
		<cfset var stProperties	= '' />
		<cfset var bsuccess	= '' />
		<cfset var i	= '' />
		<cfset var stwizardData	= '' />
			
	
		<cfif isDefined("arguments.CurrentStep") AND len(arguments.CurrentStep)>
			<cfset stwizard.CurrentStep = arguments.CurrentStep>
		</cfif>
		
		<cfif isDefined("arguments.Steps") AND len(arguments.steps)>
			<cfset stwizard.Steps = arguments.Steps>
		</cfif>
		
		<cfif isDefined("arguments.Data")>
			<cfwddx action="CFML2wddx" input="#arguments.data#" output="stwizard.Data">
		</cfif>
		
	
		<cfset stResult = setData(stProperties=stwizard,user=stwizard.UserLogin) />
		
		<cfset stwizard = getData(objectID=arguments.objectid) />
		
		<cfwddx action="WDDX2CFML" input="#stwizard.Data#" output="stwizardData">
		<cfset stwizard.Data = stwizardData />
		
		
		<!--- 
		<!--- we need to loop through each wizard object and save to the session --->
		<cfloop list="#structKeyList(stwizard.Data)#" index="i">
			<cfset stProperties = stwizard.Data[i] />
	
			<cfset bsuccess = createObject("component", application.stcoapi[stProperties.typename].packagepath).setdata(stProperties=stProperties,bSessionOnly="true") />
	
		</cfloop> --->
		
		<!--- return the struct --->
		<cfreturn stwizard>
	
	</cffunction>
	
	<cffunction name="setWizardObject" access="public" output="true" returntype="struct" hint="updates a single object in the wizard, and">
		<cfargument name="wizardID" required="no" type="UUID">
		<cfargument name="stProperties" required="no" type="Struct">
		
		<cfset var stResult = structNew() />
		<cfset var stwizard = read(wizardID=arguments.wizardID) />
		<cfset var prop	= '' />
		
		<cfif structKeyExists(stWizard.data, arguments.stProperties.objectid)>
			<!--- Make sure the struct passed in has an objectid --->
			<cfif structKeyExists(arguments.stProperties, "objectid")>	
				
				<!--- Loop through all the properties passed in and update the object in the wizard --->
				<cfloop collection="#arguments.stProperties#" item="prop">
	
					<cfset stWizard.data[arguments.stProperties.objectid][prop] = stProperties[prop] />
	
				</cfloop>
				
				<!--- Write the updated data back into the wizard --->
				<cfset stwizard = Write(objectid=arguments.wizardID, Data=stWizard.data) />
			<cfelse>
				<cfabort showerror="arguments.stProperties must contain an objectid" />
			</cfif>
		<cfelse>
			<cfabort showerror="The wizard object passed in must already be in the wizards dataset" />
		</cfif>
		
		
		<!--- return the struct --->
		<cfreturn stwizard>
	
	</cffunction>
	
	
	
	
	<cffunction name="deleteData" access="public" output="false" returntype="struct" hint="Delete the specified objectid and corresponding data, including array properties and refObjects.">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var stwizard = read(wizardid=arguments.objectid) />
		<cfset var WizardObjectID = "" />
		<cfset var stWizardObject = structNew() />
		
		<cfparam name="session.tempObjectStore" default="#structNew()#" />
		
		<cfif structKeyExists(stWizard, "data")>
			<cfloop collection="#stwizard.data#" item="wizardObjectID">
				<cfset stWizardObject.objectid = stWizard.data[wizardObjectID].objectid />
				<cfset stWizardObject.typename = stWizard.data[wizardObjectID].typename />
				<cfset createObject("component", application.stcoapi[stWizardObject.typename].packagepath).setLock(locked=false,stobj=stWizardObject) />
				
				<cfset structDelete(Session.TempObjectStore, wizardObjectID) />
			</cfloop>
			
		</cfif>	
		
		<cfreturn super.deleteData(objectid=arguments.objectid,dsn=arguments.dsn, dbowner=arguments.dbowner) />
	</cffunction>


</cfcomponent>
