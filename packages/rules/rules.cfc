<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2004, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/rules/rules.cfc,v 1.15 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.15 $

|| DESCRIPTION || 
$Description: Abstract Rules Class $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayname="Rules Object" bAbstract="true" extends="farcry.core.packages.fourq.fourq" hint="Rules is an abstract class that contains">
	<cfproperty name="objectID" type="uuid" required="true" />
	<cfproperty name="label" type="nstring" default="">
	
	<cfproperty name="datetimelastupdated" displayname="Datetime lastupdated" type="date" hint="Timestamp for record last modified." required="no" default="" ftType="datetime" ftLabel="Last Updated"> 


	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">	
	<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz">	
	<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">	
	

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
		<cfset var oObjectBroker = createObject("component", "farcry.core.packages.fourq.objectBroker").init() />
		<cfset var stCurrentView = structNew() />
		<cfset var i = 0 />
			
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
		<cfif arguments.template eq "deniedaccess" or not application.security.checkPermission(type=stObj.typename,webskin=arguments.template)>
			<cfif structKeyExists(request, "aAncestorWebskins")>
				<cfloop from="1" to="#arraylen(request.aAncestorWebskins)#" index="i">
					<cfset request.aAncestorWebskins[i].okToCache = 0 />
					<cfset request.aAncestorWebskins[i].timeout = stCurrentView.timeout />
				</cfloop>
			</cfif>
			<cfsavecontent variable="webskinHTML"><cfinclude template="#application.coapi.coapiadmin.getWebskinPath(stObj.typename,'deniedaccess')#" /></cfsavecontent>
			<cfreturn webskinHTML />
		</cfif>
					
		<cfif NOT structIsEmpty(stObj)>		
		
			<!--- Check to see if the webskin is in the object broker --->
			<cfset webskinHTML = oObjectBroker.getWebskin(objectid=stobj.objectid, typename=stobj.typename, template=arguments.template, hashKey="#arguments.hashKey#") />		

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
					<cfset stCurrentView.inHead.stOnReady = structNew() />
					<cfset stCurrentView.inHead.aOnReadyIDs = arrayNew(1) />
					<cfset arrayAppend(request.aAncestorWebskins, stCurrentView) />
	
					<cfsavecontent variable="webskinHTML">
						<cfinclude template="#WebskinPath#">
					</cfsavecontent>
					
					<!--- If the current view (Last Item In the array) is still OkToCache --->
					<cfif request.aAncestorWebskins[arrayLen(request.aAncestorWebskins)].okToCache>
						<!--- Add the webskin to the object broker if required --->
						<cfset bAdded = oObjectBroker.addWebskin(objectid=stobj.objectid, typename=stobj.typename, template=arguments.template, html=webskinHTML, stCurrentView=stCurrentView) />
					</cfif>
					
					<cfif arrayLen(request.aAncestorWebskins)>
						
						<cfset oWebskinAncestor = createObject("component", application.stcoapi.dmWebskinAncestor.packagePath) />						
						
						<!--- 
						Loop through ancestors to determine whether to add to dmWebskinAncestor Table
						Only webskins that are cached are added to the table.
						 --->						
						<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">
							
							<!--- Add the ancestor records so we know where this webskin is located throughout the site. --->
							<cfif not structkeyexists(request.aAncestorWebskins[i],"objectid") or stobj.objectid NEQ request.aAncestorWebskins[i].objectID>
								<cftimer label="Indexing webskin: #request.aAncestorWebskins[i].typename#/request.aAncestorWebskins[i].template "/>
							
								<cfif listFindNoCase(application.stcoapi[request.aAncestorWebskins[i].typename].lObjectBrokerWebskins, request.aAncestorWebskins[i].template)>
									<cfif application.stcoapi[request.aAncestorWebskins[i].typename].stObjectBrokerWebskins[request.aAncestorWebskins[i].template].timeout NEQ 0>
							
										<cfset bAncestorExists = oWebskinAncestor.checkAncestorExists(webskinObjectID=stobj.objectid, ancestorID=request.aAncestorWebskins[i].objectID, ancestorTemplate=request.aAncestorWebskins[i].template) />
											
										<cfif not bAncestorExists>
											<cfset stProperties = structNew() />
											<cfset stProperties.webskinObjectID = stobj.objectid />
											<cfset stProperties.webskinTypename = "" />
											<cfset stProperties.webskinTemplate = "" />
											<cfif structkeyexists(request.aAncestorWebskins[i],"objectid")>
												<cfset stProperties.ancestorID = request.aAncestorWebskins[i].objectID />
											</cfif>
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
							
							<!--- If the timeout of this webskin is less than its parents, reset the parents timeout so timeout propogates upwards --->
							<cfif stCurrentView.timeout LT request.aAncestorWebskins[i].timeout>
								<cfif stCurrentView.timeout EQ "">
									<cfdump var="#stCurrentView#" expand="false" label="stCurrentView" />
<cfabort showerror="debugging" />								</cfif>
								<cfset request.aAncestorWebskins[i].timeout = stCurrentView.timeout />
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
		<cfelse>
			<cfthrow type="Application" detail="Error: When trying to render [/webskin/#stObj.typename#/#arguments.template#.cfm] the object was not created correctly." />	
		</cfif>
		
		
		
		<cfreturn webskinHTML />
	</cffunction>
		
	<cffunction name="getWebskins" returntype="query" access="public" output="false" hint="Returns a query of all available webskins. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" default="#gettablename()#" hint="Typename of instance." />
		<cfargument name="prefix" type="string" required="false" default="" hint="Prefix to filter template results." />
		
		<cfset var qWebskins = application.stcoapi[arguments.typename].qWebskins />
		
		<cfif len(arguments.prefix)>
			<cfquery dbtype="query" name="qWebskins">
			SELECT * FROM qWebskins
			WHERE lower(qWebskins.name) LIKE '#lCase(arguments.prefix)#%'
			</cfquery>
		</cfif>
		
		<cfreturn qWebskins />
	</cffunction>
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		
		<cfset var stNewObject = "" />
		
		<cfif not len(arguments.user)>
			<cfif isDefined("session.security.userID")>
				<cfset arguments.user = session.security.userID />
			<cfelse>
				<cfset arguments.user = 'anonymous' />			
			</cfif>
		</cfif>
		
		<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
		
		<cfif not structKeyExists(arguments.stProperties,"objectid")>
			<cfset arguments.stProperties.objectid = createUUID() />
		</cfif>
		
		<cfset stNewObject = super.createData(arguments.stProperties) />
		<farcry:logevent objectid="#arguments.stProperties.objectid#" type="rules" event="create" notes="#arguments.auditNote#" />
		
		<cfreturn stNewObject />
	</cffunction>
	
		
	<cffunction name="delete" access="public" hint="Basic delete method for all objects.">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Deleted">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		
		<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
		
		<cfset super.deleteData(arguments.objectid,arguments.dsn) />
		<farcry:logevent objectid="#arguments.objectid#" type="rule" event="delete" notes="#arguments.auditNote#" />
	</cffunction>	
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">

		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		
		<cfset var qMetadata = application.rules[stobj.typename].qMetadata >
		
		<cfset var updateHTML = getView(stobject="#stobj#", template="update", alternateHTML="") />
		
		
		
		<cfif len(updateHTML)>
			<cfoutput>#updateHTML#</cfoutput>
		<cfelse>
			<!--- IF THE ONLY PROPS ARE OBJECTID and LABEL, then let the user know that we have nothing to edit here. --->
			<cfif listLen(structKeyList(application.rules[stobj.typename].stProps)) LTE 2>
				<cfoutput><h3>No Parameters required</h3></cfoutput>
			</cfif>
			
			<cfset onExit = StructNew() />		
			<cfset onExit.Type = "URL" />
			<cfset onExit.Content = "#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" />
			
			
			
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
				<wiz:processwizard>
				
					<!--- Save the Primary wizard Object --->
					<wiz:processwizardObjects typename="#stobj.typename#" PackageType="rules" />	
						
				</wiz:processwizard>
				
				<wiz:processwizard action="Save" Savewizard="true" Exit="true"><!--- Save wizard Data to Database and remove wizard --->
					<extjs:bubble title="Rule Saved" bAutoHide="true">
						<cfoutput>The changes you have made to this rule have been saved.</cfoutput>
					</extjs:bubble>
				</wiz:processwizard>
				<wiz:processwizard action="Cancel" Removewizard="true" Exit="true"><!--- remove wizard --->
					<extjs:bubble title="Changes Cancelled" bAutoHide="true">
						<cfoutput>The changes you made to the rule were cancelled.</cfoutput>
					</extjs:bubble>
				</wiz:processwizard>
				
				
				<wiz:wizard ReferenceID="#stobj.objectid#">
				
					<cfloop query="qwizardSteps">
							
						<cfquery dbtype="query" name="qwizardStep">
						SELECT *
						FROM qMetadata
						WHERE ftwizardStep = '#qwizardSteps.ftwizardStep#'
						ORDER BY ftSeq
						</cfquery>
					
						<wiz:step name="#qwizardSteps.ftwizardStep#">
							
	
							<cfquery dbtype="query" name="qFieldSets">
							SELECT ftwizardStep, ftFieldset
							FROM qMetadata
							WHERE ftwizardStep = '#qwizardSteps.ftwizardStep#'
							AND ftFieldset <> '#stobj.typename#'
							Group By ftwizardStep, ftFieldset
							ORDER BY ftSeq
							</cfquery>
												
							<cfloop query="qFieldSets">
							
								<cfquery dbtype="query" name="qFieldset">
								SELECT *
								FROM qMetadata
								WHERE ftFieldset = '#qFieldsets.ftFieldset#'
								ORDER BY ftSeq
								</cfquery>
								
								
								<wiz:object ObjectID="#stObj.ObjectID#" PackageType="rules" lfields="#valuelist(qFieldset.propertyname)#" format="edit" intable="false" legend="#qFieldset.ftFieldset#" />
							</cfloop>
							
							
						</wiz:step>
					
					</cfloop>
					
				</wiz:wizard>	
					
					
					
					
			<!------------------------ 
			If there is only 1 wizard step (typename by default) then we will be creating a simple form
			 ------------------------>		 
			<cfelse>
			
				<cfquery dbtype="query" name="qFieldSets">
				SELECT ftwizardStep, ftFieldset
				FROM qMetadata
				WHERE ftFieldset <> '#stobj.typename#'
				Group By ftwizardStep, ftFieldset
				ORDER BY ftSeq
				</cfquery>
			
			
				<!---------------------------------------
				ACTION:
				 - default form processing
				---------------------------------------->
				<ft:processForm action="Save" Exit="true">
					<ft:processFormObjects typename="#stobj.typename#" PackageType="rules" />

					<extjs:bubble title="Rule Saved" bAutoHide="true">
						<cfoutput>The changes you have made to this rule have been saved.</cfoutput>
					</extjs:bubble>
					
				</ft:processForm>
				
				<ft:processForm action="Cancel" Exit="true">				
					<extjs:bubble title="Changes Cancelled" bAutoHide="true">
						<cfoutput>The changes you made to the rule were cancelled.</cfoutput>
					</extjs:bubble>
				</ft:processForm>
				
				
				
				<ft:form>
			
					<cfif qFieldSets.recordcount GT 1>
						
						<cfloop query="qFieldSets">
							<cfquery dbtype="query" name="qFieldset">
							SELECT *
							FROM qMetadata
							WHERE ftFieldset = '#qFieldsets.ftFieldset#'
							ORDER BY ftSeq
							</cfquery>
							
							<ft:object ObjectID="#arguments.ObjectID#" PackageType="rules" format="edit" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" inTable=false IncludeFieldSet=1 Legend="#qFieldSets.ftFieldset#" />
						</cfloop>
						
						
					<cfelse>
					
						<!--- default edit handler --->
						<ft:object ObjectID="#arguments.ObjectID#" PackageType="rules" format="edit" lExcludeFields="label" lFields="" inTable=false IncludeFieldSet=1 Legend="#stObj.Label#" />
					</cfif>
					
					<ft:farcryButtonPanel>
						<ft:farcryButton value="Save" /> 
						<ft:farcryButton value="Cancel" validate="false" />
					</ft:farcryButtonPanel>
					
				</ft:form>
			</cfif>
		
			
		</cfif>
				
	</cffunction> 
	

	<cffunction name="setLock" access="public" output="true" hint="Lock a content item to prevent simultaneous editing." returntype="void">
		<cfargument name="locked" type="boolean" required="true" hint="Turn the lock on or off.">
		<cfargument name="lockedby" type="string" required="false" hint="Name of the user locking the object." default="">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		<cfargument name="stobj" required="No" default="#StructNew()#"> 
		
		<!--- Determine who the record is being locked/unlocked by --->		
		<cfif not len(arguments.lockedBy)>
			<cfif isDefined("session.dmSec.authentication.userlogin") AND isDefined("session.dmSec.authentication.userDirectory")>
				<cfset arguments.lockedBy = "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#" />
			<cfelse>
				<cfset arguments.lockedBy = "anonymous" />
			</cfif>
		</cfif>
		
		
		<!--- if the properties struct not passed in grab the instance --->
		<cfif StructIsEmpty(arguments.stObj)>
			<!--- Default Objects should not be locked as this will create a record in the database. --->
			<cfif structKeyExists(instance, "stobj") AND (NOT structKeyExists(instance.stobj, "bDefaultObject") OR NOT instance.stobj.bDefaultObject)>
				<cfset instance.stobj.locked=arguments.locked>
				<cfif arguments.locked>
					<cfset instance.stobj.lockedby=arguments.lockedby>
				<cfelse>
					<cfset instance.stobj.lockedby="">
				</cfif>
				<!--- call fourq.setdata() (ie super) to bypass prepop of sys attributes by types.setdata() --->
				<cfset setdata(instance.stobj, arguments.lockedby, 0)>
			</cfif>
		<cfelseif NOT structKeyExists(arguments.stobj, "bDefaultObject") or NOT arguments.stobj.bDefaultObject >
			<cfset arguments.stobj.locked = arguments.locked>
			<cfif arguments.locked>
				<cfset arguments.stobj.lockedby=arguments.lockedby>
			<cfelse>
				<cfset arguments.stobj.lockedby="">
			</cfif>
			<!--- call fourq.setdata() (ie super) to bypass prepop of sys attributes by types.setdata() --->
			<cfset setdata(arguments.stobj, arguments.lockedby, 0)>
		</cfif>

	
		<!--- log event --->
		<cfif arguments.bAudit and isDefined("instance.stobj.objectid")>
			<farcry:logevent object="#instance.stObj.objectid#" type="rules" event="lock" notes="Locked: #yesnoformat(arguments.locked)#" />
		</cfif>
	</cffunction>
		
	
	<cffunction access="public" name="execute" output="true">
		<cfargument name="label" required="no" type="string" default="">
		<cfoutput><!-- #arguments[1]# : RULE IS EMPTY --></cfoutput>
	</cffunction>  
	
	<cffunction access="public" name="getRules" returntype="query" hint="Returns a two column query (rulename, bCustom) of available rules. Assumes that rule names are rule*.cfc">
		
		<cfset var qRules = queryNew("rulename,bCustom,displayname") />
		<cfset var rule = "" />
		<cfset var displayname = "" />

		<cfloop collection="#application.rules#" item="rule">
			<cfset queryAddRow(qRules, 1) />
			<cfset querySetCell(qRules,"rulename", rule) />
			<cfset querySetCell(qRules,"bCustom", application.rules[rule].bcustomrule) />
			
			<cfif structKeyExists(application.rules[rule],'displayname')>
				<cfset displayname = application.rules[rule].displayname />
			<cfelse>
				<cfset displayname = rule />
			</cfif>
			<cfset querySetCell(qRules,"displayname", displayname) />
		</cfloop>	
		
		<cfquery dbtype="query" name="qRules">
		SELECT * FROM qRules
		ORDER BY displayname
		</cfquery>
		
		<cfreturn qRules />		

	</cffunction>
	
	<cffunction name="setData" access="public" output="false" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array." returntype="struct">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated publishing rule.">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		
		
		<cfset var stReturn=structNew()>
					    
		<cfif NOT structKeyExists(arguments.stProperties, "datetimelastupdated")>
			<cfset arguments.stProperties.datetimelastupdated = createODBCDateTime(now()) />
		</cfif>
				
									    
		<cfset stReturn=super.setData(stProperties=arguments.stProperties, dsn=arguments.dsn, bSessionOnly=arguments.bSessionOnly) />
		<!--- log update --->
		<cfif arguments.bAudit>
			<farcry:logevent object="#arguments.stProperties.objectid#" type="rules" event="update" notes="#arguments.auditNote#" />
		</cfif>
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="BeforeSave" access="public" output="false" returntype="struct">
		<cfargument name="stProperties" required="true" type="struct">
		<cfargument name="stFields" required="true" type="struct">
		<cfargument name="stFormPost" required="false" type="struct">
		
		
		<!--- 
			This will set the default Label value. It first looks form the bLabel associated metadata.
			Otherwise it will look for title, then name and then anything with the substring Name.
		 --->
		<cfset var NewLabel = "" />
		
		<cfparam name="stProperties.label" default="">
		
		
		<cfloop list="#StructKeyList(arguments.stFields)#" index="field">
			<cfif structKeyExists(arguments.stProperties,field) AND isDefined("arguments.stFields.#field#.Metadata.bLabel") AND arguments.stFields[field].Metadata.bLabel>
				<cfset NewLabel = "#NewLabel# #arguments.stProperties[field]#">
			</cfif>
		</cfloop>

		<cfif not len(NewLabel)>
			<cfif structKeyExists(arguments.stProperties,"Title")>
				<cfset NewLabel = "#arguments.stProperties.title#">
			<cfelseif structKeyExists(arguments.stProperties,"Name")>
				<cfset NewLabel = "#arguments.stProperties.name#">
			<cfelse>
				<cfloop list="#StructKeyList(arguments.stProperties)#" index="field">
					<cfif FindNoCase("Name",field) AND field NEQ "typename">
						<cfset NewLabel = "#NewLabel# #arguments.stProperties[field]#">
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfif len(trim(NewLabel))>
			<cfset stProperties.label = trim(NewLabel) />
		<cfelse>
			<cfset stProperties.label = stProperties.label />
		</cfif>
		
		
		<cfset stProperties.datetimelastupdated = now() />
		
		<cfreturn stProperties>
	</cffunction>
	
</cfcomponent>