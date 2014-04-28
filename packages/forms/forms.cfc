<cfcomponent 
	displayname="Base Form Component" 
	extends="farcry.core.packages.types.types" bAbstract="true" 
	hint="Abstract class. Provides default handlers and defines structure for a form." 
	bObjectBroker="false"
	icon="fa-code">

	<cfproperty name="objectid" type="uuid" ftDefault="application.fc.utils.createJavaUUID()" ftDefaultType="evaluate" />

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
		<cfset var qFieldSets = queryNew("") />
		<cfset var qFieldset = queryNew("") />

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
			<cfset arguments.stProperties.objectid = application.fc.utils.createJavaUUID() />
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
		<cfset structappend(arguments.stProperties,getData(objectid=arguments.stProperties.ObjectID,typename=variables.typename),false) />	

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
		<cfset var tempObjectStore = structNew() />
		
		<cfset init() />
		
		<!---------------------------------------------------------------
		Create a reference to the tempObjectStore in the session.
		This is done so that if the session doesn't exist yet (in the case of application.cfc applicationStart), we can trap the error and continue on our merry way.
		 --------------------------------------------------------------->
		<cftry>
			<cfset tempObjectStore = Session.TempObjectStore />
			<cfcatch type="any">
				<!--- ignore the error and assume it just doesnt exist yet.  --->
			</cfcatch>
		</cftry>
				
		<cfset stObj.typename = variables.typename />
		
		<!--- Check to see if the object is in the temporary object store --->
		<cfif structKeyExists(tempObjectStore,arguments.objectid) AND arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs>
			
			<!--- get from the temp object stroe --->
			<cfset stObj = tempObjectStore[arguments.objectid] />

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
			
			<cfset stObj.objectid = arguments.objectid />

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
		<cfargument name="onExitProcess" required="no" type="any" default="Refresh" />
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var qMetadata = application.stCOAPI[stobj.typename].qMetadata />

		<cfset var qwizardSteps = queryNew("") />
		<cfset var qwizardStep = queryNew("") />
		<cfset var qFieldSets = queryNew("") />
		<cfset var qFieldset = queryNew("") />

		
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
				
				<ft:buttonPanel>
					<ft:button value="Save" /> 
					<ft:button value="Cancel" validate="false" />
				</ft:buttonPanel>
				
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

</cfcomponent>