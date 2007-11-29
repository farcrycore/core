<cfcomponent bAbstract="true" displayname="Base Form Component" hint="Abstract class. Provides default handlers and defines structure for a form." extends="farcry.core.packages.fourq.fourq" bObjectBroker="0">
	<cfproperty name="objectid" type="uuid" ftDefault="createuuid()" ftDefaultType="evaluate" />

	<!--- 
		The purpose of a 'form' component is to provide a way of generating formtool forms that aren't based on types or rules. 
		Add properties to a form component in exactly the same way as you would for a type 
	--->
	
	<!--- PUBLIC VARIABLES --->
	<cfset this.metadata = structnew() />
	
	<cffunction name="init" access="public" output="false" returntype="any" hint="Initializes component">
		<cfset this.metadata = getMetaData(this) />
		
		<cfif not structKeyExists(this.metadata,"bAbstract") or this.metadata.bAbstract EQ "False">
			<!--- Initialize form metadata --->
			<cfset variables.tableMetadata = createobject('component','farcry.core.packages.fourq.TableMetadata').init() />
			<cfset tableMetadata.parseMetadata(getMetadata(this)) />
			<cfset variables.typename = variables.tableMetadata.getTableName() />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="display" access="public" returntype="any" output="Yes" hint="Outputs form data in non-editable format">
		<cfargument name="objectid" required="yes" type="UUID">
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var HTML = "" />
		<cfset var qMetadata = queryNew("objectID") />

		<cfset qMetadata = application.types[stobj.typename].qMetadata >
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
		<ft:form>
			<cfquery dbtype="query" name="qFieldSets">
				SELECT ftwizardStep, ftFieldset
				FROM qMetadata
				WHERE ftFieldset <> '#stobj.typename#'
				Group By ftwizardStep, ftFieldset
				ORDER BY ftSeq
			</cfquery>
			
			<cfif qFieldSets.recordcount GTE 1>
				
				<cfloop query="qFieldSets">
					<cfquery dbtype="query" name="qFieldset">
						SELECT *
						FROM qMetadata
						WHERE ftFieldset = '#qFieldsets.ftFieldset#'
						ORDER BY ftSeq
					</cfquery>
					
					<ft:object ObjectID="#arguments.ObjectID#" format="display" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" inTable=false IncludeFieldSet=1 Legend="#qFieldSets.ftFieldset#" />
				</cfloop>
				
				
			<cfelse>
			
				<!--- default edit handler --->
				<ft:object ObjectID="#arguments.ObjectID#" format="display" lExcludeFields="label" lFields="" inTable=false IncludeFieldSet=1 Legend="#stObj.Label#" />
			</cfif>
		</ft:form>
	</cffunction>
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		
		<cfif not structKeyExists(arguments.stProperties,"objectid")>
			<cfset arguments.stProperties.objectid = createUUID() />
		</cfif>
				
		<cfreturn duplicate(arguments.stProperties) />
	</cffunction>

	<cffunction name="setData" access="public" output="true" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		
		<!--- INCLUDED FOR COMPATABILITY WITH TYPES --->
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		
		<!--- INCLUDED FOR COMPATABILITY WITH TYPES --->
		<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	
		
		<cfset init() />
		
		<!--- 
			Append the default properties of this object into the properties that have been passed.
			The overwrite flag is set to false so that the default properties do not overwrite the ones passed in.
		 --->
		<cfset structappend(arguments.stProperties,getData(objectid=arguments.stProperties.ObjectID,typename=variables.typename),false)/ >	

		<!--------------------------------------- 
		If the object is to be stored in the session scope only.
		Note sure how this fits with the transitory nature of a form, am assuming this is used for 'unsuccessful' submissions
		----------------------------------------->
			
		<!--- Add object to temporary object store --->
		<cfparam name="session.TempObjectStore" default="#structnew()#" />
		<cfset Session.TempObjectStore[arguments.stProperties.ObjectID] = arguments.stProperties />
		<cfif not arguments.bSessionOnly>
			
			<cfset arguments.stProperties = this.process(arguments.stProperties) />
		
		</cfif>
		
		<cfreturn duplicate(arguments.stProperties) />
	</cffunction>
	
	<cffunction name="getData" access="public" output="false" returntype="struct" hint="Get data for a specific objectid and return as a structure, including array properties and typename.">
		<cfargument name="objectid" type="uuid" required="true">
		
		<!--- INCLUDED FOR COMPATABILITY WITH TYPES --->
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="bShallow" type="boolean" required="false" default="false" hint="Setting to true filters all longchar property types from record.">
		<cfargument name="bFullArrayProps" type="boolean" required="false" default="true" hint="Setting to true returns array properties as an array of structs instead of an array of strings IF IT IS AN EXTENDED ARRAY.">
		<cfargument name="bUseInstanceCache" type="boolean" required="false" default="true" hint="setting to use instance cache if one exists">
		<cfargument name="bArraysAsStructs" type="boolean" required="false" default="false" hint="Setting to true returns array properties as an array of structs instead of an array of strings.">
		
		<!--- Variables --->
		<cfset var prop = "" />
		<cfset var stObj = structnew() />
		
		<cfset init() />
		
		<cfset stObj.typename = variables.typename />
		
		<!--- Check to see if the object is in the temporary object store --->
		<cfif structKeyExists(Session,"TempObjectStore") AND structKeyExists(Session.TempObjectStore,arguments.objectid) AND arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs>
			
			<!--- get from the temp object stroe --->
			<cfset stObj = Session.TempObjectStore[arguments.objectid] />

		<cfelse>
			
			<!--- Get default values --->
			<cfloop collection="#application.stCOAPI[variables.typename].stProps#" item="prop">
				
				<cfparam name="application.stCOAPI[variables.typename].stProps[prop].metadata.Default" default="">
				<cfparam name="application.stCOAPI[variables.typename].stProps[prop].metadata.ftDefaultType" default="value">
				<cfparam name="application.stCOAPI[variables.typename].stProps[prop].metadata.ftDefault" default="#application.stCOAPI[variables.typename].stProps[prop].metadata.Default#">
				
				<cfif application.stCOAPI[variables.typename].stProps[prop].metadata.type eq "array"> 
					<!--- set to the default if it is not already defined above --->
					<cfset stObj[prop] = arrayNew(1)>
				<cfelse>
					
					<cfswitch expression="#application.stCOAPI[variables.typename].stProps[prop].metadata.ftDefaultType#">
						<cfcase value="Evaluate">
							<cfset stObj[prop] = Evaluate(application.stCOAPI[variables.typename].stProps[prop].metadata.ftDefault) />
						</cfcase>
						<cfcase value="Expression">
							<cfset stObj[prop] = Evaluate(DE(application.stCOAPI[variables.typename].stProps[prop].metadata.ftDefault)) />
						</cfcase>
						<cfdefaultcase>
							<cfset stObj[prop] = application.stCOAPI[variables.typename].stProps[prop].metadata.ftDefault />
						</cfdefaultcase>
					</cfswitch>
					
				</cfif>
			</cfloop>
			
			<cfparam name="stObj.objectid" default="#createuuid()#" />

		</cfif>

		<cfreturn stObj>
	</cffunction>

	<cffunction name="process" access="public" output="false" returntype="struct" hint="Empty process function">
		<cfargument name="fields" type="struct" required="true" hint="The fields submitted" />
		
		<cfreturn arguments.fields />
	</cffunction>

	<cffunction name="setLock" access="public" output="false" hint="INCLUDED FOR COMPATABILITY WITH TYPES" returntype="void">
		<cfargument name="locked" type="boolean" required="true" hint="Turn the lock on or off.">
		<cfargument name="lockedby" type="string" required="false" hint="Name of the user locking the object." default="">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		<cfargument name="stobj" required="No" default="#StructNew()#"> 
		
	</cffunction>
	
	<cffunction name="Edit" access="public" output="true" returntype="void" hint="Default edit handler.">
		<cfargument name="ObjectID" required="yes" type="string" default="" />
		<cfargument name="onExit" required="no" type="any" default="Refresh" />
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var qMetadata = application.types[stobj.typename].qMetadata />
		
		<!-------------------------------------------------- 
		WIZARD:
		- build default formtool wizard
		--------------------------------------------------->		
		<cfquery dbtype="query" name="qwizardSteps">
			SELECT ftwizardStep
			FROM qMetadata
			WHERE ftwizardStep <> '#stobj.typename#'
			Group By ftwizardStep
			ORDER BY ftSeq
		</cfquery>
		
		<!------------------------ 
		Work out if we are creating a wizard or just a simple form.
		If there are multiple wizard steps then we will be creating a wizard
		 ------------------------>
		<cfif qwizardSteps.recordcount GT 1>
			
			<!--- Always save wizard WDDX data --->
			<wiz:processwizard excludeAction="Cancel">
			
				<!--- Save the Primary wizard Object --->
				<wiz:processwizardObjects typename="#stobj.typename#" />	
					
			</wiz:processwizard>
			
			<wiz:processwizard action="Save" Savewizard="true" Exit="true" /><!--- Save wizard Data to Database and remove wizard --->
			<wiz:processwizard action="Cancel" Removewizard="true" Exit="true" /><!--- remove wizard --->
			
			
			<wiz:wizard ReferenceID="#stobj.objectid#" title="#stobj.label#">
			
				<cfloop query="qwizardSteps">
						
					<cfquery dbtype="query" name="qwizardStep">
						SELECT		*
						FROM		qMetadata
						WHERE		ftwizardStep = '#qwizardSteps.ftwizardStep#'
						ORDER BY	ftSeq
					</cfquery>
				
					<wiz:step name="#qwizardSteps.ftwizardStep#">
						

						<cfquery dbtype="query" name="qFieldSets">
							SELECT		ftwizardStep, ftFieldset
							FROM		qMetadata
							WHERE		ftwizardStep = '#qwizardSteps.ftwizardStep#'
							AND 		ftFieldset <> '#stobj.typename#'
							Group By 	ftwizardStep, ftFieldset
							ORDER BY 	ftSeq
						</cfquery>
						
						<cfif qFieldSets.recordCount>
											
							<cfloop query="qFieldSets">
							
								<cfquery dbtype="query" name="qFieldset">
									SELECT		*
									FROM 		qMetadata
									WHERE 		ftFieldset = '#qFieldsets.ftFieldset#'
									ORDER BY 	ftSeq
								</cfquery>
								
								<wiz:object ObjectID="#stObj.ObjectID#" lfields="#valuelist(qFieldset.propertyname)#" format="edit" intable="false" legend="#qFieldset.ftFieldset#" helptitle="#qFieldset.fthelptitle#" helpsection="#qFieldset.fthelpsection#" />
							</cfloop>
							
						<cfelse>
							
							<wiz:object ObjectID="#stObj.ObjectID#" lfields="#valuelist(qwizardStep.propertyname)#" format="edit" intable="false" />
						
						</cfif>
						
					</wiz:step>
				
				</cfloop>
				
			</wiz:wizard>	
				
		<!------------------------ 
		If there is only 1 wizard step (typename by default) then we will be creating a simple form
		 ------------------------>		 
		<cfelse>
		
			<cfquery dbtype="query" name="qFieldSets">
				SELECT 		ftwizardStep, ftFieldset
				FROM 		qMetadata
				WHERE 		ftFieldset <> '#stobj.typename#'
				Group By 	ftwizardStep, ftFieldset
				ORDER BY 	ftSeq
			</cfquery>
		
			<!--- PERFORM SERVER SIDE VALIDATION --->
			<!--- <ft:serverSideValidation /> --->
		
			<!---------------------------------------
			ACTION:
			 - default form processing
			---------------------------------------->
			<ft:processForm action="Save" Exit="true">
				<ft:processFormObjects typename="#stobj.typename#" />
			</ft:processForm>

			<ft:processForm action="Cancel" Exit="true" />
			
			<ft:form>
				<cfif qFieldSets.recordcount GTE 1>
					
					<cfloop query="qFieldSets">
						<cfquery dbtype="query" name="qFieldset">
							SELECT 		*
							FROM 		qMetadata
							WHERE 		ftFieldset = '#qFieldsets.ftFieldset#'
							ORDER BY 	ftSeq
						</cfquery>
						
						<ft:object ObjectID="#arguments.ObjectID#" format="edit" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" inTable="false" IncludeFieldSet="true" Legend="#qFieldSets.ftFieldset#" helptitle="#qFieldset.fthelptitle#" helpsection="#qFieldset.fthelpsection#" />
					
					</cfloop>
					
				<cfelse>
				
					<!--- All Fields: default edit handler --->
					<ft:object ObjectID="#arguments.ObjectID#" format="edit" lExcludeFields="label" lFields="" IncludeFieldSet=1 Legend="#stObj.Label#" />
					
				</cfif>
				
				<ft:farcryButtonPanel>
					<ft:farcryButton value="Save" /> 
					<ft:farcryButton value="Cancel" validate="false" />
				</ft:farcryButtonPanel>
				
			</ft:form>
		</cfif>

	</cffunction>
	
	<!--- 
		INCLUDED FOR COMPATABILITY WITH TYPES
		Since a 'join' is has no point except when saving to the database, forms should not have array properties 
		These methods will ensure that adding an array property won't simply crash the form
	--->
	<cffunction name="getArrayFieldAsQuery" access="public" output="true" returntype="query">
		
		<cfargument name="ObjectID" required="no" type="string" default="" hint="This is the PK for which we are getting the linked FK's. If the ObjectID passed is empty, the we are creating a new object and it will therefore not have an objectID">
		<cfargument name="Fieldname" required="yes" type="string">
		<cfargument name="typename" required="yes" type="string" default="">
		<cfargument name="ftJoin" required="yes" type="string" /><!--- This is a list of typenames as defined in the metadata of the property --->
		
		<cfreturn queryNew("parentid,data,seq,typename") />
			
	</cffunction>
	
	<cffunction name="AddArrayObject" access="public" output="true" returntype="any" hint="This is the Edit Method that is used in the Library">
		<cfargument name="typename" required="yes" type="string">

	</cffunction>
	
	<cffunction name="PickArrayObject" access="public" output="true" returntype="any" hint="This is the Edit Method that is used in the Library">
		<cfargument name="ObjectID" required="yes" type="UUID">

	</cffunction>
		
	<cffunction name="SelectedArrayObject" access="public" output="true" returntype="any" hint="This is the Edit Method that is used in the Library">
		<cfargument name="ObjectID" required="yes" type="UUID">
	
	</cffunction>
			
	<cffunction name="getLibraryData" access="public" output="false" returntype="query" hint="Return a query of all content instances for generic library interface.">
		<cfreturn queryNew("ObjectID,Label") />
	</cffunction>

	<cffunction name="getI18Property" access="public" output="true" returntype="string" hint="Provides access to I18 values for properties">
		<cfargument name="property" type="string" required="true" hint="The property being queried" default="" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />

		<cfset meta = "" />
		<cfset prop = arguments.value />

		<cfset init() />

		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfif len(application.stCOAPI[variables.typename].stProps[arguments.property].metadata["ftLabel"])>
					<cfreturn application.rb.getResource("coapi.#variables.typename#.properties.#arguments.property#@#arguments.value#",application.stCOAPI[variables.typename].stProps[arguments.property].metadata["ftLabel"]) />
				<cfelse>
					<cfreturn application.rb.getResource("coapi.#variables.typename#.properties.#arguments.property#@#arguments.value#",application.stCOAPI[variables.typename].stProps[arguments.property].metadata["name"]) />
				</cfif>
			</cfcase>
		</cfswitch>
		
		<cfreturn application.rb.getResource("coapi.#variables.typename#.properties.#arguments.property#@#arguments.value#","") />
	</cffunction>

	<cffunction name="getI18Step" access="public" output="false" returntype="string" hint="Provides access to I18 values for labels etc">
		<cfargument name="step" type="numeric" required="true" hint="The step being queried" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />
		
		<cfset var qSteps = "" />
		<cfset prop = arguments.value />

		<cfset init() />

		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfset prop = "ftWizardStep" />
			</cfcase>
		</cfswitch>
		
		<cfquery dbtype="query" name="qSteps">
			select		ftWizardStep
			from		application.stCOAPI.#variables.typename#.qMetadata
			where		ftWizardStep <> '#variables.typename#'
			group by 	ftWizardStep
			order by	ftSeq
		</cfquery>
		
		<cfreturn application.rb.getResource("coapi.#variables.typename#.steps.#arguments.step#@#arguments.value#",qSteps[prop][arguments.step]) />
	</cffunction>

	<cffunction name="getI18Fieldset" access="public" output="false" returntype="string" hint="Provides access to I18 values for labels etc">
		<cfargument name="step" type="numeric" required="false" hint="The step being queried" default="0" />
		<cfargument name="fieldset" type="numeric" required="true" hint="The fieldset being queried" default="0" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />
		
		<cfset var qSteps = "" />
		<cfset var qFieldsets = "" />
		<cfset prop = arguments.value />

		<cfset init() />

		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfset prop = "ftFieldset" />
			</cfcase>
			<cfcase value="helptitle">
				<cfset prop = "fthelptitle" />
			</cfcase>
			<cfcase value="helpsection">
				<cfset prop = "fthelpsection" />
			</cfcase>
		</cfswitch>
		
		<cfif arguments.step>
			<cfquery dbtype="query" name="qSteps">
				select		ftWizardStep
				from		application.stCOAPI.#variables.typename#.qMetadata
				where		ftWizardStep <> '#variables.typename#'
				group by 	ftWizardStep
				order by	ftSeq
			</cfquery>
		</cfif>
		
		<cfquery dbtype="query" name="qFieldsets">
			select		ftFieldset, ftHelpTitle, ftHelpSection
			from		application.stCOAPI.#variables.typename#.qMetadata
			<cfif arguments.step>
				where		ftWizardStep = '#qSteps.ftWizardStep[arguments.step]#'
			</cfif>
			group by	ftFieldSet, ftHelpTitle, ftHelpSection
			order by	ftSeq
		</cfquery>
		
		<cfif arguments.step>
			<cfreturn application.rb.getResource("coapi.#variables.typename#.steps.#arguments.step#.fieldsets.#arguments.fieldset#@#arguments.value#",qFieldsets[prop][arguments.fieldset]) />
		<cfelse>
			<cfreturn application.rb.getResource("coapi.#variables.typename#.fieldsets.#arguments.fieldset#@#arguments.value#",qFieldsets[prop][arguments.fieldset]) />
		</cfif>
	</cffunction>
	
	<cffunction name="getView" access="public" output="true" returntype="string" hint="Returns the HTML of a view from the webskin content type folder.">
		<cfargument name="objectid" required="no" type="UUID" hint="ObjectID of the object that is to be rendered by the webskin view." />
		<cfargument name="template" required="yes" type="string" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
		<cfargument name="stparam" required="false" type="struct" default="#structNew()#" hint="Structure of parameters to be passed into the display handler." />
		<cfargument name="stobject" required="no" type="struct" hint="Property structure to render in view.  Overrides any property structure mapped to arguments.objectid. Useful if you want to render a view with a modified content item.">
		<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
		<cfargument name="OnExit" required="no" type="any" default="">
		<cfargument name="alternateHTML" required="no" type="string" hint="If the webskin template does not exist, if this argument is sent in, its value will be passed back as the result.">
		<cfargument name="hashKey" required="no" default="" type="string" hint="Pass in a key to be used to hash the objectBroker webskin cache">
		
		<cfset var stResult = structNew() />
		<cfset var stObj = StructNew() />
		<cfset var WebskinPath = "" />
		<cfset var webskinHTML = "" />
		<cfset var stCurrentView = structNew() />

		<!--- make sure that .cfm isn't passed to this method in the template argument --->
		<cfif listLast(arguments.template,".") EQ "cfm">
			<cfset arguments.template = ReplaceNoCase(arguments.template,".cfm", "", "all") />
		</cfif>

		
		<cfif isDefined("arguments.stobject")>
			<cfset stobj=arguments.stobject />
			<cfset instance.stobj = stObj />
		<cfelse>
			<!--- If the objectid has not been sent, we need to create a default object. --->
			<cfparam name="arguments.objectid" default="#CreateUUID()#" type="uuid">
			<!--- get the data for this instance --->
			<cfset stObj = getData(objectid=arguments.objectID,dsn=arguments.dsn)>		
		</cfif>

		<!--- Check permissions on this webskin --->
		<cfif not application.security.checkPermission(type=stObj.typename,webskin=arguments.template)>
			<cfsavecontent variable="webskinHTML"><cfinclude template="#application.coapi.coapiadmin.getWebskinPath(stObj.typename,'deniedaccess')#" /></cfsavecontent>
			<cfreturn webskinHTML />
		</cfif>
			
		<cfif NOT structIsEmpty(stObj)>	
		
			<!--- Check to see if the webskin is in the object broker --->
			<cfset webskinHTML = application.coapi.objectBroker.getWebskin(objectid=stobj.objectid, typename=stobj.typename, template=arguments.template, hashKey="#arguments.hashKey#") />		

			<cftimer label="getView: #stobj.typename# (#arguments.template#)">
			<cfif not len(webskinHTML)>
				<cfset webskinPath = application.coapi.coapiadmin.getWebskinPath(typename=stObj.typename, template=arguments.template) />
						
				<cfif len(webskinPath)>
					
					<!--- Setup the current request.aAncestorWebskins in case this does not yet exist --->
					<cfif not structKeyExists(request, "aAncestorWebskins")>
						<cfset request.aAncestorWebskins = arrayNew(1) />
					</cfif>	
					<!--- Add the current view to the array --->
					<cfset stCurrentView.objectid = stobj.objectid />
					<cfset stCurrentView.typename = stobj.typename />
					<cfset stCurrentView.template = arguments.template />
					<cfset stCurrentView.hashKey = arguments.hashKey />
					<cfset stCurrentView.timeout = application.coapi.coapiadmin.getWebskinTimeOut(typename=stObj.typename, template=arguments.template) />
					<cfset stCurrentView.hashURL = application.coapi.coapiadmin.getWebskinHashURL(typename=stObj.typename, template=arguments.template) />
					<cfset stCurrentView.okToCache = 1 />
					<cfset stCurrentView.inHead = structNew() />
					<cfset stCurrentView.inHead.stCustom = structNew() />
					<cfset stCurrentView.inHead.aCustomIDs = arrayNew(1) />
					<cfset arrayAppend(request.aAncestorWebskins, stCurrentView) />					
					
					<!--- Include the View --->
					<cfsavecontent variable="webskinHTML">
						<cfinclude template="#WebskinPath#">
					</cfsavecontent>
										
					<!--- If the current view (Last Item In the array) is still OkToCache --->
					<cfif request.aAncestorWebskins[arrayLen(request.aAncestorWebskins)].okToCache>
						<!--- Add the webskin to the object broker if required --->
						<cfset bAdded = application.coapi.objectBroker.addWebskin(objectid=stobj.objectid, typename=stobj.typename, template=arguments.template, html=webskinHTML, stCurrentView=stCurrentView) />	
					</cfif>
					
					<cfif arrayLen(request.aAncestorWebskins)>
						
						<cfset oWebskinAncestor = createObject("component", application.stcoapi.dmWebskinAncestor.packagePath) />						
						
						<!--- 
						Loop through ancestors to determine whether to add to dmWebskinAncestor Table
						Only webskins that are cached are added to the table.
						 --->
						<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">
							
							<!--- Add the ancestor records so we know where this webskin is located throughout the site. --->
							<cfif stobj.objectid NEQ request.aAncestorWebskins[i].objectID>
								<cftimer label="Indexing webskin: #request.aAncestorWebskins[i].typename#/request.aAncestorWebskins[i].template "/>
								<cfif listFindNoCase(application.stcoapi[request.aAncestorWebskins[i].typename].lObjectBrokerWebskins, request.aAncestorWebskins[i].template)>
									<cfif application.stcoapi[request.aAncestorWebskins[i].typename].stObjectBrokerWebskins[request.aAncestorWebskins[i].template].timeout NEQ 0>
							
										<cfset bAncestorExists = oWebskinAncestor.checkAncestorExists(webskinObjectID=stobj.objectid, ancestorID=request.aAncestorWebskins[i].objectID, ancestorTemplate=request.aAncestorWebskins[i].template) />
											
										<cfif not bAncestorExists>
											<cfset stProperties = structNew() />
											<cfset stProperties.webskinObjectID = stobj.objectid />
											<cfset stProperties.ancestorID = request.aAncestorWebskins[i].objectID />
											<cfset stProperties.ancestorTypename = request.aAncestorWebskins[i].typename />
											<cfset stProperties.ancestorTemplate = request.aAncestorWebskins[i].template />
											
											<cfset stResult = oWebskinAncestor.createData(stProperties=stProperties) />
										</cfif>
									</cfif>
								</cfif>
							</cfif>
							
							<!--- If this webskin is to never cache, make sure all ancestors also never cache --->
							<cfif stCurrentView.timeout EQ 0>
								<cfset request.aAncestorWebskins[i].okToCache = 0 />
							</cfif>
							
							<!--- If this webskin is to have its url hashed, make sure all ancestors also have their webskins hashed --->
							<cfif stCurrentView.hashURL>
								<cfset request.aAncestorWebskins[i].hashURL = true />
							</cfif>
							<!--- If this webskin is to add a hashKey, make sure all ancestors also have the hashKey added --->
							<cfif len(stCurrentView.hashKey)>
								<cfset request.aAncestorWebskins[i].hashKey = "#request.aAncestorWebskins[i].hashKey##stCurrentView.hashKey#" />
							</cfif>
						</cfloop>
					</cfif>
					
					<!--- Remove the current view (last item in the array) from the Ancestor Webskins array --->
					<cfset ArrayDeleteAt(request.aAncestorWebskins, arrayLen(request.aAncestorWebskins)) />
					
				<cfelseif structKeyExists(arguments, "alternateHTML")>
					<cfset webskinHTML = arguments.alternateHTML />
				<cfelse>
					<cfthrow type="Application" detail="Error: Template not found [/webskin/#stObj.typename#/#arguments.template#.cfm] and no alternate html provided." />
				</cfif>	
			</cfif>		
			</cftimer>
		<cfelse>
			<cfthrow type="Application" detail="Error: When trying to render [/webskin/#stObj.typename#/#arguments.template#.cfm] the object was not created correctly." />	
		</cfif>
		<cfreturn webskinHTML />
	</cffunction>
	
</cfcomponent>