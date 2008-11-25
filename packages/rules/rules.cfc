<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
		<cfargument name="template" required="no" type="string" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
		<cfargument name="webskin" required="no" type="string" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
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

		<cfif structkeyexists(arguments,"webskin") and len(arguments.webskin)>
			<cfset arguments.template = arguments.webskin />
		<cfelseif not structkeyexists(arguments,"template") or not len(arguments.template)>
			<cfthrow message="The getView function requires the template or webskin argument.">
		</cfif>
			
		<!--- make sure that .cfm isn't passed to this method in the template argument --->
		<cfif listLast(arguments.template,".") EQ "cfm">
			<cfset arguments.template = ReplaceNoCase(arguments.template,".cfm", "", "all") />
		</cfif>

		
		<cfif isDefined("arguments.stobject")>
			<cfset stobj=arguments.stobject />
			<cfset instance.stobj = stObj />
		<cfelse>
			<!--- If the objectid has not been sent, we need to create a default object. --->
			<cfparam name="arguments.objectid" default="#application.fc.utils.createJavaUUID()#" type="uuid">
			<!--- get the data for this instance --->
			<cfset stObj = getData(objectid=arguments.objectID,dsn=arguments.dsn)>
		</cfif>

		<!--- Check permissions on this webskin --->
		<cfif arguments.template eq "deniedaccess" or not application.security.checkPermission(type=stObj.typename,webskin=arguments.template)>
			<cfif structKeyExists(request, "aAncestorWebskins")>
				<cfloop from="1" to="#arraylen(request.aAncestorWebskins)#" index="i">
					<cfset request.aAncestorWebskins[i].okToCache = 0 />
					<cfset request.aAncestorWebskins[i].cacheTimeout = stCurrentView.cacheTimeout />
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
					<cfset stCurrentView.cacheStatus = application.coapi.coapiadmin.getWebskinCacheStatus(typename=stObj.typename, template=arguments.template) />
					<cfset stCurrentView.cacheTimeout = application.coapi.coapiadmin.getWebskinCacheTimeOut(typename=stObj.typename, template=arguments.template) />
					<cfset stCurrentView.cacheByURL = application.coapi.coapiadmin.getWebskincacheByURL(typename=stObj.typename, template=arguments.template) />
					<cfset stCurrentView.cacheByRoles = application.coapi.coapiadmin.getWebskincacheByRoles(typename=stObj.typename, template=arguments.template) />
					<cfset stCurrentView.okToCache = 1 />
					<cfset stCurrentView.inHead = structNew() />
					<cfset stCurrentView.inHead.stCustom = structNew() />
					<cfset stCurrentView.inHead.aCustomIDs = arrayNew(1) />
					<cfset stCurrentView.inHead.stOnReady = structNew() />
					<cfset stCurrentView.inHead.aOnReadyIDs = arrayNew(1) />
					<cfset arrayAppend(request.aAncestorWebskins, stCurrentView) />
	
					<!--- Include the View --->
                    <cfsavecontent variable="webskinHTML">
                        <cfif isdefined("request.mode.design") AND request.mode.design>
                            <cfoutput><webskin typename="#stobj.typename#" Template="#arguments.template#" Path="#WebskinPath#"></cfoutput>
                        </cfif>
                        <cfinclude template="#WebskinPath#">
                        <cfif isdefined("request.mode.design") AND request.mode.design>
                            <cfoutput></webskin></cfoutput>
                        </cfif>
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
								
								<cfif structKeyExists(application.stcoapi[request.aAncestorWebskins[i].typename].stWebskins, request.aAncestorWebskins[i].template)>
									<cfif application.stcoapi[request.aAncestorWebskins[i].typename].stWebskins[request.aAncestorWebskins[i].template].cacheStatus GT 0>
							
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
							<cfif stCurrentView.cacheStatus EQ -1>
								<cfset request.aAncestorWebskins[i].okToCache = 0 />
							</cfif>
							
							<!--- If the timeout of this webskin is less than its parents, reset the parents timeout so timeout propogates upwards --->
							<cfif stCurrentView.cacheTimeout LT request.aAncestorWebskins[i].cacheTimeout>
								<cfset request.aAncestorWebskins[i].cacheTimeout = stCurrentView.cacheTimeout />
							</cfif>
							
							<!--- If this webskin is to have its url hashed, make sure all ancestors also have their webskins hashed --->
							<cfif stCurrentView.cacheByURL>
								<cfset request.aAncestorWebskins[i].cacheByURL = true />
							</cfif>
							<cfif stCurrentView.cacheByRoles>
								<cfset request.aAncestorWebskins[i].cacheByRoles = true />
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
			<cfset arguments.stProperties.objectid = application.fc.utils.createJavaUUID() />
		</cfif>
		
		<cfset stNewObject = super.createData(arguments.stProperties) />
		<farcry:logevent objectid="#arguments.stProperties.objectid#" type="rules" event="create" notes="#arguments.auditNote#" />
		
		<cfreturn stNewObject />
	</cffunction>
	
		
	<cffunction name="delete" access="public" hint="Basic delete method for all objects.">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#application.security.getCurrentUserID()#">
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
		<cfset var updateHTML = "" />		
		<cfset var onExit = StructNew() />	
		<cfset var lWizardSteps = "" />
		<cfset var iWizardStep = "" />
		<cfset var lFieldSets = "" />
		<cfset var iFieldSet = "" />
			
		
		<cfset onExit.Type = "HTML" />
		<cfsavecontent variable="onExit.content">
			<cfoutput>
				<script type="text/javascript">
					<cfif structkeyexists(url,"iframe")>
						<!--- parent.location.reload(); --->
						parent.reloadContainer('#url.container#')
					<cfelse>
						<!--- window.opener.location.reload(); --->
						window.opener.reloadContainer('#url.containerID#')
					</cfif>
					
					<cfif structkeyexists(url,"iframe")>
						parent.closeDialog();
					<cfelse>
						window.close();
					</cfif>						
				</script>
			</cfoutput>
		</cfsavecontent>
		
		<cfset updateHTML = getView(stobject="#stobj#", template="update", alternateHTML="", OnExit="#onExit#") />
		
		<cfif len(updateHTML)>
			<cfoutput>#updateHTML#</cfoutput>
		<cfelse>
			<!--- IF THE ONLY PROPS ARE OBJECTID and LABEL, then let the user know that we have nothing to edit here. --->
			<cfif listLen(structKeyList(application.rules[stobj.typename].stProps)) LTE 2>
				<cfoutput><h3>No Parameters required</h3></cfoutput>
			</cfif>

			<cfquery dbtype="query" name="qwizardSteps">
			SELECT ftwizardStep
			FROM qMetadata
			WHERE ftwizardStep <> '#stobj.typename#'
			ORDER BY ftSeq
			</cfquery>
			
			<cfset lWizardSteps = "" />
			<cfoutput query="qWizardSteps" group="ftWizardStep" groupcasesensitive="false">
				<cfset lWizardSteps = listAppend(lWizardSteps,qWizardSteps.ftWizardStep) />
			</cfoutput>
			
						
			<!------------------------ 
			Work out if we are creating a wizard or just a simple form.
			If there are multiple wizard steps then we will be creating a wizard
			 ------------------------>
			<cfif listLen(lWizardSteps) GT 1>
				
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
				
					<cfloop list="#lWizardSteps#" index="iWizardStep">
							
						<cfquery dbtype="query" name="qwizardStep">
						SELECT *
						FROM qMetadata
						WHERE ftwizardStep = '#iWizardStep#'
						ORDER BY ftSeq
						</cfquery>
					
						<wiz:step name="#iWizardStep#">
							
	
							<cfquery dbtype="query" name="qFieldSets">
							SELECT ftFieldset
							FROM qMetadata
							WHERE ftwizardStep = '#iWizardStep#'
							AND ftFieldset <> '#stobj.typename#'				
							ORDER BY ftSeq
							</cfquery>
							<cfset lFieldSets = "" />
							<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
								<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
							</cfoutput>
							
							
							<cfif listlen(lFieldSets)>
												
								<cfloop list="#lFieldSets#" index="iFieldSet">
							
									<cfquery dbtype="query" name="qFieldset">
									SELECT *
									FROM qMetadata
									WHERE ftwizardStep = '#iWizardStep#' and ftFieldset = '#iFieldSet#'
									ORDER BY ftSeq
									</cfquery>
									
									
									<wiz:object ObjectID="#stObj.ObjectID#" PackageType="rules" lfields="#valuelist(qFieldset.propertyname)#" format="edit" intable="false" legend="#iFieldSet#" />
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
				SELECT ftFieldset
				FROM qMetadata
				WHERE ftFieldset <> '#stobj.typename#'
				ORDER BY ftseq
				</cfquery>
				
				<cfset lFieldSets = "" />
				<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
					<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
				</cfoutput>
			
			
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
			
					<cfif listLen(lFieldSets)>
						
						<cfloop list="#lFieldSets#" index="iFieldset">
							
							<cfquery dbtype="query" name="qFieldset">
							SELECT *
							FROM qMetadata
							WHERE ftFieldset = '#iFieldset#'
							ORDER BY ftSeq
							</cfquery>
							
							<ft:object ObjectID="#arguments.ObjectID#" PackageType="rules" format="edit" lExcludeFields="label" lFields="#valuelist(qFieldset.propertyname)#" IncludeFieldSet="true" Legend="#iFieldset#" />
						</cfloop>
						
						
					<cfelse>
					
						<!--- default edit handler --->
						<ft:object ObjectID="#arguments.ObjectID#" PackageType="rules" format="edit" lExcludeFields="label" lFields="" IncludeFieldSet="false" />
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
			<cfif application.security.isLoggedIn()>
				<cfset arguments.lockedBy = application.security.getCurrentUserID() />
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
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#application.security.getCurrentUserID()#">
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
	

	<cffunction name="getArrayFieldAsQuery" access="public" output="true" returntype="query">
		
		<cfargument name="ObjectID" required="no" type="string" default="" hint="This is the PK for which we are getting the linked FK's. If the ObjectID passed is empty, the we are creating a new object and it will therefore not have an objectID">
		<cfargument name="Fieldname" required="yes" type="string">
		<cfargument name="typename" required="yes" type="string" default="">
		<cfargument name="ftJoin" required="yes" type="string" /><!--- This is a list of typenames as defined in the metadata of the property --->
		
		<cfset var q = queryNew("parentid,data,seq,typename") />
		
		<cfif NOT len(arguments.typename)>
			<cfset arguments.typename  = findType(objectID="#arguments.ObjectID#")>
		</cfif>
		
		<cfquery datasource="#application.dsn#" name="q">
		SELECT *
		FROM #arguments.typename#_#arguments.Fieldname#
		WHERE #arguments.typename#_#arguments.Fieldname#.parentID = '#arguments.ObjectID#'
		ORDER BY #arguments.typename#_#arguments.Fieldname#.seq ASC
		</cfquery>		
	
		<cfreturn q />
			
	</cffunction>
		
			
</cfcomponent>