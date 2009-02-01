<cfcomponent displayname="FarCry Friendly URL Table" hint="Manages FarCry Friendly URL's" extends="types" output="false" bDocument="true" scopelocation="application.fc.factory.farFU" bObjectBroker="true" objectBrokerMaxObjects="1000">
	<cfproperty ftSeq="1" name="refobjectid" type="string" default="" hint="stores the objectid of the related object" ftLabel="Ref ObjectID" />
	<cfproperty ftSeq="2" name="friendlyURL" type="string" default="" hint="The Actual Friendly URL" ftLabel="Friendly URL" bLabel="true" />		
	<cfproperty ftSeq="3" name="queryString" type="string" default="" hint="The query string that will be parsed and placed in the url scope of the request" ftLabel="Query String" />		
	<cfproperty ftSeq="4" name="fuStatus" type="integer" default="" hint="Status of the Friendly URL." ftType="list" ftDefault="2" ftList="1:System Generated,2:Custom,0:archived" ftLabel="Status" />
	<cfproperty ftSeq="5" name="redirectionType" type="string" default="" hint="Type of Redirection" ftType="list" ftDefault="301" ftList="none:None,301:Moved Permanently (301),307:Temporary Redirect (307)" ftLabel="Type of Redirection" />
	<cfproperty ftSeq="6" name="redirectTo" type="string" default="" hint="Where to redirect to" ftType="list" ftList="default:To the default FU,objectid:Direct to the object ID" ftLabel="Redirect To" />
	<cfproperty ftSeq="7" name="bDefault" type="boolean" default="0" hint="Only 1 Friendly URL can be the default that will be used by the system" ftDefault="0" ftLabel="Default" />
	<cfproperty ftSeq="8" name="applicationName" type="string" default="" hint="The application name that the friendly URL is a part of. Useful for subsites.">

	<cffunction name="onAppInit" returntype="any" access="public" output="false" hint="Initializes the friendly url scopes and returns a copy of this initialised object">

		<cfset variables.stMappings = structNew() />
		<cfset variables.stLookup = structNew() /><!--- SHOULD ONLY CONTAIN THE DEFAULT FU TO BE USED FOR THIS OBJECT --->
		
		<cfset setupCoapiAlias() />
		<cfset initialiseMappings() />		
		
		<cfreturn this />
		
	</cffunction>
	

	<cffunction name="isUsingFU" returnType="boolean" access="public" output="false" hint="Returns whether the system should use Friendly URLS">
		
		<cfif not structKeyExists(variables, "bUsingFU")>
			<cfset variables.bUsingFU = pingFU() />
		</cfif>
		
		<cfreturn variables.bUsingFU />
	</cffunction>
	
	<cffunction name="turnOn" returnType="boolean" access="public" output="false" hint="Returns whether the system should use Friendly URLS">
		
		<cfset variables.bUsingFU = true />
		
		<cfreturn variables.bUsingFU />
	</cffunction>
	
	<cffunction name="turnOff" returnType="boolean" access="public" output="false" hint="Returns whether the system should use Friendly URLS">
		
		<cfset variables.bUsingFU = false />
		
		<cfreturn variables.bUsingFU />
	</cffunction>
		
	
	<cffunction name="pingFU" returnType="boolean" access="public" output="false" hint="Pings a test friendly url to determine if Friendly URLS are available">
		
		<cfset var pingResponse = "" />
		<cfset var bAvailable = false />
		
		<cftry>
			<cfhttp url="http://#cgi.server_name##application.url.webroot#/pingFU" throwonerror="true" timeout="1" port="#cgi.server_port#" result="pingResponse" />
		
			<cfif findNoCase("PING FU SUCCESS", pingResponse.Filecontent)>
				<cfset bAvailable = true />
			</cfif>
			 
			<cfcatch type="any">
				<cfset bAvailable = false />
			</cfcatch>
		</cftry>
		
		<cfreturn bAvailable />
	</cffunction>
	

	
	<cffunction name="archiveFU" access="public" returntype="struct" hint="Archives the FU passed in" output="No">
		<cfargument name="objectID" required="true" hint="ObjectID of FU to archive" type="string" />

		<cfset var stLocal = StructNew()>
		
		<cfset stLocal.stReturn = StructNew()>
		<cfset stLocal.stReturn.bSuccess = 1>
		<cfset stLocal.stReturn.message = "">

		<cfset stLocal.stProperties = getData(objectID="#arguments.objectID#") />
		
		<!--- See if there is already an archive version of this friendly URL for the same refObjectID --->
		<cfquery datasource="#application.dsn#" name="stLocal.qDuplicate">
		SELECT objectid
		FROM farFU
		WHERE refObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stLocal.stProperties.refObjectID#">
		AND friendlyURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stLocal.stProperties.friendlyURL#">
		AND fuStatus = 0
		</cfquery>
		
		<!--- If no duplicate, archive it --->
		<cfif NOT stLocal.qDuplicate.recordCount>
			<!--- SET THE STATUS OF THE FU OBJECT TO 0 (archived) --->
			<cfset stLocal.stProperties.objectid = application.fc.utils.createJavaUUID() />
			<cfset stLocal.stProperties.fuStatus = 0 />
			<cfset stLocal.stProperties.bDefault = 0 />
			<cfset stLocal.stProperties.redirectionType = "301" />
			<cfset stLocal.stProperties.redirectTo =  "default" />
			<cfset stLocal.stResult = setData(stProperties="#stLocal.stProperties#") />
		</cfif>
		<cfreturn stLocal.stReturn>
	</cffunction>
	
			
	<cffunction name="setDefaultFU" returnType="struct" access="public" output="false" hint="Returns successful status of attempt to make a FU the default for that objectid">
		<cfargument name="objectid" required="yes" hint="Objectid of Friendly URL to make the default" />
			
		<cfset var stLocal = structNew() />

		<cfset stLocal.stReturn = StructNew()>
		<cfset stLocal.stReturn.bSuccess = 1>
		<cfset stLocal.stReturn.message = "">
		
		<cfset stLocal.stFU = getData(objectid="#arguments.objectID#") />
		
		<cfif stLocal.stFU.fuStatus GT 0>
			<cfset stLocal.qFUs = getFUList(objectID="#stLocal.stFU.refobjectid#", status="current") />
			
			<!--- REMOVE THE CURRENT DEFAULT FU --->
			<cfloop query="stLocal.qFUs">
				<cfif stLocal.qFUs.bDefault>
					<cfset stLocal.stProps = structNew() />
					<cfset stLocal.stProps.objectID = stLocal.qFUs.objectid />
					<cfset stLocal.stProps.bDefault = 0 />
					<cfset stLocal.stProps.redirectionType = "301" />
					<cfset stLocal.stProps.redirectTo = "default" />					
					<cfset stLocal.stResult = setData(stProperties="#stLocal.stProps#") />
				</cfif>
			</cfloop>

			<!--- SET THE NEW DEFAULT FU --->
			<cfset stLocal.stProps = structNew() />
			<cfset stLocal.stProps.objectID = stLocal.stFU.objectid />
			<cfset stLocal.stProps.bDefault = 1 />
			<!--- JUST IN CASE THE USER ASKED TO REDIRECT TO THE DEFAULT, WE DONT WANT THEM REDIRECTING TO THE DEFAULT (WHICH IS NOW THIS OBJECT) --->
			<cfif stLocal.stFU.redirectTo EQ "default">
				<cfset stLocal.stProps.redirectionType = "none" />
				<cfset stLocal.stProps.redirectTo = "objectid" />
			</cfif>
			
			<cfset stLocal.stResult = setData(stProperties="#stLocal.stProps#") />
			
		</cfif>
		
		<cfset setMapping(objectid="#stLocal.stFU.objectid#") />

		<cfreturn stLocal.stReturn />
		
	</cffunction>

	<cffunction name="getDefaultFUObject" returnType="struct" access="public" output="false" hint="Returns the default FU objectid for an object. Returns empty string if no default is set.">
		<cfargument name="refObjectID" required="yes" hint="Objectid of the RefObject to retrieve the default" />
			
		<cfset var stLocal = structNew() />
		
		<cfset stLocal.stDefaultFU = structNew() />

		<cfif structKeyExists(variables.stLookup, "#arguments.refObjectID#")>
			<cfset stLocal.stDefaultFU = variables.stLookup["#arguments.refObjectID#"] />
		<cfelse>
			<!--- 
			SORTING BY DEFAULT FIRST SO THAT IF WE HAVE A DEFAULT SETUP IT WILL BE PICKED UP.
			However, if no default is available, we will automatically get the custom first or else finally the system
			 --->
			<cfquery datasource="#application.dsn#" name="stLocal.qDefault">
			SELECT objectid 
			FROM farFU
			WHERE refObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.refObjectID#" />
			AND fuStatus > 0
			ORDER BY bDefault DESC, fuStatus DESC 
			</cfquery>		
		
			<cfif stLocal.qDefault.recordCount>
				<cfset stLocal.stDefaultFU = getData(objectid="#stLocal.qDefault.objectID#") />
				<cfset setMapping(objectid="#stLocal.qDefault.objectID#") />
			</cfif>
		</cfif>
		
		<cfreturn stLocal.stDefaultFU />
		
	</cffunction>
	
	<cffunction name="createCustomFU" access="public" returntype="struct" hint="Returns the success state of creating a new Custom FU of an object" output="false">
		<cfargument name="objectID" required="false" default="#application.fc.utils.createJavaUUID()#" hint="the objectid to use for the new object.">
		<cfargument name="refObjectID" required="true" type="uuid" hint="Content item objectid.">
		<cfargument name="friendlyURL" required="true" type="string" hint="The Friendly URL to create" />
		<cfargument name="queryString" required="false" type="string" default="" hint="The query string that will be parsed and placed in the url scope of the request" />		
		<cfargument name="fuStatus" required="false" type="numeric" default="2" hint="Status of the Friendly URL" />
		<cfargument name="redirectionType" required="false" type="string" default="301" hint="Type of Redirection" />
		<cfargument name="redirectTo" required="false" type="string" default="default" hint="Where to redirect to" />
		<cfargument name="bDefault" required="false" type="boolean" default="0" hint="Only 1 Friendly URL can be the default that will be used by the system" />

		<cfset var stResult = structNew() />
		<cfset var stDefaultFU = structNew() />
		
		<cfset arguments.friendlyURL = cleanFU(friendlyURL="#arguments.friendlyURL#", bCheckUnique="true") />

		<!--- If there is currently no default, set this as the default --->
		<cfset stDefaultFU = getDefaultFUObject(refObjectID="#arguments.refObjectID#") />
		<cfif structIsEmpty(stDefaultFU) or NOT stDefaultFU.bDefault>
			<cfset arguments.bDefault = 1 />
		</cfif>
				
		<cfset stResult = setData(stProperties="#arguments#") />
		
		<cfif arguments.bDefault EQ 1>
			<cfset stResult = setDefaultFU(objectid="#arguments.objectid#") />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	
	<cffunction name="cleanFU" access="public" returntype="string" hint="Cleans up the Friendly URL and ensures it is Unique." output="yes" bDocument="true">
		<cfargument name="friendlyURL" required="yes" type="string" hint="The actual Friendly URL to use">
		<cfargument name="bCheckUnique" required="false" type="boolean" default="true" hint="Check to see if the Friendly URL has already been taken">
		<cfargument name="fuID" required="false" type="string" default="" hint="The objectid of the farFU object the friendly URL is attached to. This is used to exclude from the check unique function.">
		
		<cfset var stLocal = structNew() />
		<cfset var cleanFU = "">
		<cfset var bDuplicate = true />
		<cfset var duplicateCounter = "" />
		
		<!--- replace spaces in title --->
		<cfset cleanFU = replace(arguments.friendlyURL,' ','-',"all")>
		<!--- replace duplicate dashes with a single dash --->
		<cfset cleanFU = REReplace(cleanFU,"-+","-","all")>
		<!--- replace the html entity (&amp;) with and --->
		<cfset cleanFU = reReplaceNoCase(cleanFU,'&amp;','and',"all")>
		<!--- remove illegal characters in titles --->
		<cfset cleanFU = reReplaceNoCase(cleanFU,'[,:\?##����]','',"all")>
		<!--- change & to "and" in title --->
		<cfset cleanFU = reReplaceNoCase(cleanFU,'[&]','and',"all")>
		<!--- prepend fu url pattern and add suffix --->
		<cfset cleanFU = ReplaceNocase(cleanFU,"//","/","All")>
		<cfset cleanFU = LCase(cleanFU)>
		<cfset cleanFU = ReReplaceNoCase(cleanFU,"[^a-z0-9/]","-","all")>
		<cfset cleanFU = ReReplaceNoCase(cleanFU,"  "," ","all")>
		<cfset cleanFU = ReReplaceNoCase(cleanFU," ","-","all")>
		<cfset cleanFU = Trim(cleanFU)>
		
		<cfif left(cleanFU,1) NEQ "/">
			<cfset cleanFU = "/#cleanFU#" />
		</cfif>	
		
		<!--- Remove Trailing Slashes --->
		<cfif len(cleanFU) GT 1 AND right(cleanFU,1) EQ "/">
			<cfset cleanFU = left(cleanFU,len(cleanFU) -1) />
		</cfif>		

		<cfif arguments.bCheckUnique>
			<cfset cleanFU = getUniqueFU(friendlyURL="#cleanFU#", fuID="#arguments.fuID#") />			
		</cfif>
		
		<cfreturn cleanFU />
	</cffunction>
	
	<cffunction name="getUniqueFU" access="private" returntype="string" hint="Returns a unique friendly url. The objectid of the current friendly url can be passed in to make sure we are not picking it up in the unique query">
		<cfargument name="friendlyURL" required="true" hint="The friendly URL we are trying to make unique" />
		<cfargument name="fuID" required="false" default="" hint="The objectid of the farFU record to exclude from the db query" />
		
		<cfset var qDuplicates = "" />
		<cfset var bDuplicate = true />
		<cfset var duplicateCounter = "" />
		<cfset var cleanFU = arguments.friendlyURL />
		
		<cfloop condition="#bDuplicate#">	
			<cfquery datasource="#application.dsn#" name="qDuplicates">
			SELECT objectid
			FROM farFU
			WHERE friendlyURL = <cfqueryparam value="#cleanFU##duplicateCounter#" cfsqltype="cf_sql_varchar">	
			<cfif len(arguments.fuID)>
				AND objectid <> <cfqueryparam value="#arguments.fuID#" cfsqltype="cf_sql_varchar">
			</cfif>				
			AND fuStatus > 0
			</cfquery>
	
					
			<cfset bDuplicate = qDuplicates.recordCount />
			
			<cfif bDuplicate GT 0>			
				<cfif isNumeric(duplicateCounter)>
					<cfset duplicateCounter = duplicateCounter + 1 />
				<cfelse>
					<cfset duplicateCounter = 1 />
				</cfif>				
			</cfif>	
		</cfloop>
		
		<cfset cleanFU = "#cleanFU##duplicateCounter#" />			
		
		<cfreturn cleanFU />	
			
	</cffunction>
	
	<cffunction name="setSystemFU" access="public" returntype="struct" hint="Returns the success state of setting the System FU of an object" output="false">
		<cfargument name="objectid" required="true" type="uuid" hint="Content item objectid.">
		<cfargument name="typename" required="false" default="" type="string" hint="Content item typename if known.">
		
		<cfset var stLocal = structNew() />
		
		<cfset stLocal.stResult = structNew() />
		<cfset stLocal.stResult.bSuccess = true />
		<cfset stLocal.stResult.message = "" />
		
		<!--- get the object --->
		<cfset stLocal.stObj = application.coapi.coapiutilities.getContentObject(objectid="#arguments.objectid#", typename="#arguments.typename#") />
		
		<!--- Make sure we want friendly urls on this content type --->
		<cfif StructKeyExists(application.stcoapi[stLocal.stObj.typename],"bFriendly") AND application.stcoapi[stLocal.stObj.typename].bFriendly>
			
			<!--- Only create friendly urls on approved content --->
			<cfif not StructKeyExists(stLocal.stObj,"status") OR stLocal.stObj.status EQ "approved">

				<!--- Get the current system fu object for a given refobjectid --->
				<cfset stLocal.stCurrentSystemObject = getSystemObject(refObjectID="#arguments.objectid#") />
				
				<!--- Generate the new system FU for the current object --->
				<cfset stLocal.newFriendlyURL = getSystemFU(objectID="#arguments.objectid#", typename="#arguments.typename#") />
				
				<cfif structIsEmpty(stLocal.stCurrentSystemObject)>
				
					<!--- See if their is a current default object --->
					<cfset stLocal.stCurrentDefaultObject = getDefaultFUObject(refObjectID="#arguments.objectid#") />
				
					<!--- No System FU object currently set --->
					<cfset stLocal.stCurrentSystemObject.objectid = application.fc.utils.createJavaUUID() />
					<cfset stLocal.stCurrentSystemObject.refObjectID = arguments.objectid />
					<cfset stLocal.stCurrentSystemObject.fuStatus = 1 />
					<cfset stLocal.stCurrentSystemObject.redirectionType = "none" />
					<cfset stLocal.stCurrentSystemObject.redirectTo = "default" />
					<cfset stLocal.stCurrentSystemObject.friendlyURL = getUniqueFU(friendlyURL="#stLocal.newFriendlyURL#") />
					
					<!--- If no default object, set this as the default --->
					<cfif structIsEmpty(stLocal.stCurrentDefaultObject)>
						<cfset stLocal.stCurrentSystemObject.bDefault = 1 />
					</cfif>
					
					<cfset stLocal.stResult = setData(stProperties="#stLocal.stCurrentSystemObject#") />

				<cfelse>
					<cfset stLocal.newFriendlyURL = getUniqueFU(friendlyURL="#stLocal.newFriendlyURL#", FUID="#stLocal.stCurrentSystemObject.objectid#") />
					<cfif stLocal.newFriendlyURL NEQ stLocal.stCurrentSystemObject.friendlyURL>
						<!--- NEED TO ARCHIVE OLD SYSTEM OBJECT AND UPDATE --->
						<cfset stLocal.stResult = archiveFU(objectid="#stLocal.stCurrentSystemObject.objectid#") />
						<cfset stLocal.stCurrentSystemObject.friendlyURL = stLocal.newFriendlyURL />
						<cfset stLocal.stResult = setData(stProperties="#stLocal.stCurrentSystemObject#") />
					</cfif>
				</cfif>
		
				<cfset setMapping(objectid="#stLocal.stCurrentSystemObject.objectid#") />				
				
				
			<cfelse>
				<cfset stLocal.stResult.bSuccess = false />
				<cfset stLocal.stResult.message = "Friendly URLs" />
			</cfif>
		<cfelse>
			<cfset stLocal.stResult.bSuccess = false />
			<cfset stLocal.stResult.message = "#arguments.typename# does not require friendly URLs" />
		</cfif>
		
			
		<cfreturn stLocal.stResult />
	</cffunction>

	<cffunction name="getSystemObject" access="public" returntype="struct" hint="Returns the current system fu object for a given refobjectid" output="false">
		<cfargument name="refObjectID" required="true" type="uuid" hint="Content item objectid.">
		
		<cfset var stLocal = structNew() />
		
		<cfset stLocal.stResult = structNew() />
		
		<cfquery datasource="#application.dsn#" name="stLocal.q">
		SELECT objectid
		FROM farFU
		WHERE refObjectID = <cfqueryparam value="#arguments.refObjectID#" cfsqltype="cf_sql_varchar">
		AND fuStatus = 1
		</cfquery>
		
		<cfif stLocal.q.recordCount EQ 1>
			<cfset stLocal.stResult = getData(objectid="#stLocal.q.objectid#") />
		</cfif>
		
		<cfreturn stLocal.stResult />
	</cffunction>
	
	<cffunction name="getSystemFU" access="private" returntype="string" hint="Returns the FU of an object generated by the system" output="false">
		<cfargument name="objectid" required="true" type="uuid" hint="Content item objectid.">
		<cfargument name="typename" required="false" default="" type="string" hint="Content item typename if known.">
		
		<cfset var systemFU = "" />
		<cfset var stobj = application.coapi.coapiUtilities.getContentObject(objectID="#arguments.objectid#", typename="#arguments.typename#") />
		<cfset var stFriendlyURL = StructNew()>
		<cfset var objNavigation = CreateObject("component", application.stcoapi['dmNavigation'].packagePath) />
		<cfset var qNavigation=querynew("parentid")>
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		

		<cfif isDefined("application.stCoapi.#stObj.typename#.bFriendly") AND application.stCoapi[stObj.typename].bFriendly>
		
			<!--- default stFriendlyURL structure --->
			<cfset stFriendlyURL.objectid = stobj.objectid>
			<cfset stFriendlyURL.friendlyURL = "">
			<cfset stFriendlyURL.querystring = "">
	
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySystemFU" r_html="systemFU" alternateHTML="">
			
			<cfif NOT len(systemFU)>
			
				<cfif StructKeyExists(application.stcoapi[stobj.typename], "bUseInTree") AND application.stcoapi[stobj.typename].bUseInTree>
					<!--- This determines the friendly url by where it sits in the navigation node  --->
					<cfset qNavigation = objNavigation.getParent(stobj.objectid)>

					<!--- if its got a tree parent, build from navigation folders --->
					<!--- TODO: this might be better done by checking for bUseInTree="true" 
								or remove it entirely.. ie let tree content have its own fu as well as folder fu
								or set up tree content to have like page1.cfm style suffixs
								PLUS need collision detection so don't overwrite another tree based content item fro utility nav
								PLUS need to exclude trash branch (perhaps just from total rebuild?
								GB 20060117 --->
					<cfif qNavigation.recordcount>
						<!--- The object is in the tree so prefix the objects FU with the navigation FU --->
						<skin:view typename="dmNavigation" objectid="#qNavigation.parentid#" webskin="displaySystemFU" r_html="systemFU">
					</cfif>
				</cfif>
				
				<!--- otherwise, generate friendly url based on content type --->
				<cfif NOT len(systemFU)>
					<cfif StructkeyExists(application.stcoapi[stobj.typename],"fuAlias")>
						<cfset systemFU = "/#application.stcoapi[stobj.typename].fuAlias#" />
					<cfelseif StructkeyExists(application.stcoapi[stobj.typename],"displayName")>
						<cfset systemFU = "/#application.stcoapi[stobj.typename].displayName#" />
					<cfelse>
						<cfset systemFU = "/#ListLast(application.stcoapi[stobj.typename].name,'.')#" />
					</cfif>	
				</cfif>			
			
				<cfif structKeyExists(stobj, "fu") AND len(trim(stobj.fu))>
					<cfset systemFU = systemFU & "/#stobj.fu#">
				<cfelse>
					<cfset systemFU = systemFU & "/#stobj.label#">
				</cfif>
			</cfif>
		</cfif>
		
 		<cfreturn cleanFU(friendlyURL=systemFU, bCheckUnique="false") />
	</cffunction>	
	
	
	<cffunction name="migrate" access="private" hint="Migrates the legacy reffriendlyURL table to the new hotness farFU">
		<cfquery datasource="#application.dsn#" name="qLegacy">
		SELECT * FROM reffriendlyURL
		</cfquery>
		<cfset lLegacyFields = qLegacy.columnList />
		<cfloop query="qLegacy">
			<cfset stProps = structNew() />
			<cfloop list="#lLegacyFields#" index="i">
				<cfset stProps[i] = qLegacy[i][currentRow] />
			</cfloop>
			<cfif structKeyExists(stProps, "friendlyURL")>
				<!--- Remove Trailing Slashes --->
				<cfset stProps.friendlyURL = trim(stProps.friendlyURL) />
				<cfif len(stProps.friendlyURL) GT 1 AND right(stProps.friendlyURL,1) EQ "/">
					<cfset stProps.friendlyURL = left(stProps.friendlyURL,len(stProps.friendlyURL) -1) />
				</cfif>		
			</cfif>
			<cfset stProps.fuStatus = qLegacy.status />
			<cfset stProps.queryString = qLegacy.query_string />
			
			<cfif qLegacy.status EQ 1>
				<cfset stProps.redirectionType = "none" />
				<cfset stProps.redirectTo = "default" />
				<cfset stProps.bDefault = 1 />
			<cfelse>
				<cfset stProps.redirectionType = "301" />
				<cfset stProps.redirectTo = "default" />
				<cfset stProps.bDefault = 0 />
			</cfif>
			
			<cfset stResult = createData(stProperties="#stProps#") />
		</cfloop>
		
		<cfif isDefined("application.config.fuSettings.lExcludeObjectIDs") AND listLen(application.config.fuSettings.lExcludeObjectIDs)>
			<cfloop list="#application.config.fuSettings.lExcludeObjectIDs#" index="excludeObjectID">

				<cfquery datasource="#application.dsn#" name="qExcludeFUs">
				select * from farFU
				where refObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(excludeObjectID)#" />
				AND bDefault = 1
				</cfquery>
				
				<cfif qExcludeFUs.recordCount>
					<!--- Need to change to redirect to objectid --->
					<cfset stProperties = structNew() />
					<cfset stProperties.objectid = qExcludeFUs.objectid />
					<cfset stProperties.redirectionType = "301" />
					<cfset stProperties.redirectTo = "objectid" />
					<cfset stResult = setData(stProperties="#stProperties#") />
				<cfelse>
					<!--- Need to create and redirect to objectID --->
					<cfset stProperties = structNew() />
					<cfset stProperties.objectid = application.fc.utils.createJavaUUID() />
					<cfset stProperties.refObjectID = trim(excludeObjectID) />
					<cfset stProperties.bDefault = 1 />
					<cfset stProperties.redirectionType = "301" />
					<cfset stProperties.redirectTo = "objectid" />
					<cfset stProperties.friendlyURL = getSystemFU(objectid="#excludeObjectID#",bCheckUnique="true") />
					
					<cfset stResult = setData(stProperties="#stProperties#") />
				</cfif>
				
			</cfloop>
		</cfif>
		
	</cffunction>
  
	<cffunction name="setupCoapiAlias" access="public" hint="Initializes the friendly url coapi aliases" output="false" returntype="void" bDocument="true">

		<cfset var i = "" />
			
		<cfset application.fc.fuID = structNew() />
		
		<cfif structKeyExists(application, "stCoapi")>
			<cfloop list="#structKeyList(application.stcoapi)#" index="i">	
				<cfset application.fc.fuID[application.stcoapi[i].fuAlias] = i />
			</cfloop>
		</cfif>		
		
	</cffunction>
	
	<cffunction name="setMapping" access="public" output="false" returntype="void" hint="Add a FU record to the application scope mapping table.">
		<cfargument name="objectid" required="true" hint="The objectid of the farFU record we wish to add to the mapping tables.">
		
		<cfset var stFU = getData(objectid="#arguments.objectid#") />
		
		<!--- fu mappings --->
		<cfset variables.stMappings[stFU.friendlyURL] = StructNew() />
		<cfset variables.stMappings[stFU.friendlyURL].objectid = stFU.objectid />
		<cfset variables.stMappings[stFU.friendlyURL].refobjectid = stFU.refObjectID />
		<cfset variables.stMappings[stFU.friendlyURL].queryString = stFU.queryString />
		
		<cfif stFU.bDefault>
			<!--- fu lookup --->
			<cfset variables.stLookup[stFU.refobjectid] = stFU />
		</cfif>
		
	</cffunction>
	
	<cffunction name="initialiseMappings" access="public" hint="Updates the fu application scope with all the persistent FU mappings from the database." output="false" returntype="void" bDocument="true">

		<cfset var stLocal = StructNew()>
		<cfset var stResult = StructNew()>
		<cfset var stDeployResult = StructNew()>
		
		<!--- initialise fu scopes --->
		<cfset variables.stMappings = structNew() />
		<cfset variables.stLookup = structNew() />
		<cfset variables.fuExlusions = structNew() />
		
		<!--- Check to make sure the farFU table has been deployed --->
		<cftry>
			<cfquery datasource="#application.dsn#" name="stLocal.qPing">
			SELECT count(objectID)
			FROM #application.dbowner#farFU
			</cfquery>
		
			<cfcatch type="database">
				<cflock name="deployFarFUTable" timeout="30">
					<!--- The table has not been deployed. We need to deploy it now --->
					<cfset stDeployResult = deployType(dsn=application.dsn,bDropTable=true,bTestRun=false,dbtype=application.dbtype) />		
					<cfset migrate() />
				</cflock>		
			</cfcatch>
		</cftry>
		
		
		<!--- retrieve list of all dmNavigation FU's that are not retired --->
		<cfquery name="stLocal.q" datasource="#application.dsn#">
		SELECT	fu.objectid, fu.friendlyurl, fu.refobjectid, fu.queryString, fu.bDefault
		FROM	#application.dbowner#farFU fu, 
				#application.dbowner#refObjects r
		WHERE	r.objectid = fu.refobjectid
		AND r.typename = 'dmNavigation'
		AND fu.bDefault = 1
		AND fu.fuStatus > 0
		</cfquery>
		
		<!--- load mappings to application scope --->
		<cfloop query="stLocal.q">
			<cfset setMapping(objectid="#stLocal.q.objectid#") />
		</cfloop>
		
	</cffunction>

	<cffunction name="parseURL" returntype="void" access="public" output="false" hint="Parses the url.furl and places relevent keys into request.fc namespace.">
		
		<cfset var oFU = createObject("component","#application.packagepath#.farcry.fu") />
		<cfset var stFU = structNew() />
		<cfset var stURL = structNew() />	
		<cfset var stLocal = structNew() />
		
		<!--- If the browser has added a trailing / to a friendly URL, strip it out. --->
		<cfif structKeyExists(url, "furl") AND len(url.furl) GT 1 AND right(url.furl,1) EQ "/">
			<cfset url.furl = left(url.furl,len(url.furl) -1) />
		</cfif>
		
		<cfif structKeyExists(url, "furl") AND len(url.furl) AND url.furl NEQ "/">
			
			<cfset stFU = getFUData(url.furl) />
		
			<cfif not structIsEmpty(stFU)>
				
				<cfset request.fc.objectid = stFU.refobjectid>
				<cfloop index="iQstr" list="#stFU.queryString#" delimiters="&">
					<cfset url["#listFirst(iQstr,'=')#"] = listLast(iQstr,"=")>
				</cfloop>

				<!--- check if this friendly url is a retired link.: if not then show page --->
				<cfif stFU.redirectionType NEQ "none" and not request.mode.ajax>
					<cfif stFU.redirectTo EQ "default">
						<cfset stLocal.stDefaultFU = getDefaultFUObject(refObjectID="#stFU.refObjectID#") />
						<cfif not structIsEmpty(stLocal.stDefaultFU) AND stLocal.stDefaultFU.objectid NEQ stFU.objectid>
							<cfset stLocal.redirectURL = "#application.url.webroot##stLocal.stDefaultFU.friendlyURL#?#stLocal.stDefaultFU.queryString#" />
							<cfloop collection="#url#" item="i">
								<cfif i NEQ "furl">
									<cfset stLocal.redirectURL = "#stLocal.redirectURL#&#i#=#url[i]#" />
								</cfif>
							</cfloop>
							
							<cfheader statuscode="#stFU.redirectionType#"><!--- statustext="Moved permanently" --->
							<cfheader name="Location" value="#application.factory.outils.fixURL(stLocal.redirectURL)#">
							<cfabort>
							
						</cfif>
					<cfelse>
						<cfset stLocal.redirectURL = "#application.url.webroot#/index.cfm?objectid=#stFU.refObjectID#" />
						<cfloop collection="#url#" item="i">
							<cfif i NEQ "furl">
								<cfset stLocal.redirectURL = "#stLocal.redirectURL#&#i#=#url[i]#" />
							</cfif>
						</cfloop>
					
						<cfheader statuscode="#stFU.redirectionType#"><!--- statustext="Moved permanently" --->
						<cfheader name="Location" value="#application.factory.outils.fixURL(stLocal.redirectURL)#">
						<cfabort>						
						
					</cfif>

				<cfelse>
					<cfset request.fc.objectid = stFU.refobjectid>
					<cfloop index="iQstr" list="#stFU.queryString#" delimiters="&">
						<cfset url["#listFirst(iQstr,'=')#"] = listLast(iQstr,"=")>
					</cfloop>
				</cfif>
				
			<cfelse>
				
						
				<cfloop list="#url.furl#" index="i" delimiters="/">
					<cfif isUUID(i)>
						<cfset request.fc.objectid = i />
						
					<cfelseif structKeyExists(application.stCoapi, "#i#")>
						<!--- CHECK FOR TYPENAME FIRST --->
						<cfset request.fc.type = i />
			
					<cfelseif structKeyExists(application.fc.fuID, "#i#")>
						<cfset request.fc.type = application.fc.fuID[i] />
					<cfelse>
						<!--- If we get to here, then we need to confirm we have a type defined. If not, we need to determine from objectid --->
						<cfif structKeyExists(request.fc, "objectid") AND (not structKeyExists(request.fc, "type") or not len(request.fc.type))>
							<cfset request.fc.type = application.coapi.coapiUtilities.findType(objectid="#request.fc.objectid#") />
						</cfif>
						<cfif structKeyExists(request.fc, "type") and len(request.fc.type)>	
							<cfif not structKeyExists(request.fc, "view")>
								<!--- Only check for other attributes once the type is determined. --->				
								<cfif len(application.coapi.coapiAdmin.getWebskinPath(typename="#request.fc.type#", template="#i#"))>
									<!--- THIS MEANS ITS A WEBSKIN --->
									<cfset request.fc.view = i />
								</cfif>
	
							<cfelse>
								<!--- Only check for other attributes once the type is determined. --->				
								<cfif len(application.coapi.coapiAdmin.getWebskinPath(typename="#request.fc.type#", template="#i#"))>
									<!--- THIS MEANS ITS A WEBSKIN --->
									<cfset request.fc.bodyView = i />
								</cfif>
								
							</cfif>
						</cfif>
					</cfif>	
			
							
							
				</cfloop>
			
			</cfif>
		<cfelseif isUsingFU() and not request.mode.ajax>
			<cfif structKeyExists(url, "objectid") AND url.objectid NEQ application.navid.home AND structKeyExists(variables.stLookup, url.objectid)>
				<cfset stLocal.stDefaultFU = getData(objectid="#variables.stLookup[url.objectid].objectid#") />
			
				<cfif stLocal.stDefaultFU.redirectionType EQ "none">
				
						<cfset stLocal.redirectURL = "#application.url.webroot##stLocal.stDefaultFU.friendlyURL#?#stLocal.stDefaultFU.queryString#" />
						<cfloop collection="#url#" item="i">
							<cfif i NEQ "objectid" and i NEQ "fURL">				
								<cfset stLocal.redirectURL = "#stLocal.redirectURL#&#i#=#url[i]#" />
							</cfif>
						</cfloop>

						<cfheader statuscode="301"><!--- statustext="Moved permanently" --->
						<cfheader name="Location" value="#application.factory.outils.fixURL(stLocal.redirectURL)#">
						<cfabort>		
				</cfif>
			</cfif>
		</cfif>
		
		
	</cffunction>
	
	
	
	<cffunction name="getFUData" access="public" returntype="struct" hint="Returns the farFU object based on the FU passed in." output="false">
		<cfargument name="friendlyURL" type="string" required="Yes">
		<cfargument name="dsn" required="no" default="#application.dsn#"> 

		<cfset var stReturnFU = StructNew()>
		<cfset var stLocal = StructNew()>
		

		<!--- check if the FU exists in the applictaion scope [currently active] --->
		<cfif StructKeyExists(variables.stMappings,arguments.friendlyURL)>
			<cfset stReturnFU = getData(objectid="#variables.stMappings[arguments.friendlyURL].objectid#") />
		<cfelse>
			<cfquery datasource="#arguments.dsn#" name="stLocal.qGet">
			SELECT	fu.objectid
			FROM	#application.dbowner#farFU fu, 
					#application.dbowner#refObjects r
			WHERE	r.objectid = fu.refobjectid
			AND fu.friendlyURL = <cfqueryparam value="#arguments.friendlyURL#" cfsqltype="cf_sql_varchar">
			ORDER BY fu.bDefault DESC, fu.fuStatus DESC
			</cfquery>

			<cfif stLocal.qGet.recordCount>
				<cfset stReturnFU = getData(objectid="#stLocal.qGet.objectid#") />
			</cfif>
		</cfif>

		<cfreturn stReturnFU>
	</cffunction>
	


	<cffunction name="rebuildFU" access="public" returntype="struct" hint="rebuilds friendly urls for a particular type" output="true">

		<cfargument name="typeName" required="true" type="string">
		<cfset var stLocal = structnew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">

		<cfquery name="stLocal.qList" datasource="#application.dsn#">
		SELECT	objectid, label
		FROM	#application.dbowner##arguments.typeName#
		WHERE	label != '(incomplete)'
		</cfquery>

		<!--- clean out any friendly url for objects that have been deleted --->
		<!--- <cfquery name="stLocal.qDelete" datasource="#application.dsn#">
		DELETE
		FROM	#application.dbowner#farFU
		WHERE	refobjectid NOT IN (SELECT objectid FROM #application.dbowner#refObjects)
		</cfquery>
 --->
		<!--- delete old friendly url for this type --->
		<!--- <cfquery name="stLocal.qDelete" datasource="#application.dsn#">
		DELETE
		FROM	#application.dbowner#farFU
		WHERE	refobjectid IN (SELECT objectid FROM #application.dbowner##arguments.typeName#)
		</cfquery> --->
		
		<cfset stLocal.iCounterUnsuccess = 0>

		<cfloop query="stLocal.qList">
			<cfset setSystemFU(objectid="#stLocal.qList.objectid#", typename="#arguments.typeName#") />
		</cfloop>

		<cfset stLocal.iCounterSuccess = stLocal.qList.recordcount - stLocal.iCounterUnsuccess>
		<cfset stLocal.returnstruct.message = "#stLocal.iCounterSuccess# #arguments.typeName# rebuilt successfully.<br />">
 		<cfreturn stLocal.returnstruct>
	</cffunction>
	

	<cffunction name="setFriendlyURL" access="public" returntype="struct" hint="Default setfriendlyurl() method for content items." output="false">
		<cfargument name="objectid" required="true" type="uuid" hint="Content item objectid.">
		<cfargument name="typename" required="false" default="" type="string" hint="Content item typename if known.">
		
		<cfset var stReturn = StructNew()>
		<cfset var stobj = application.coapi.coapiUtilities.getContentObject(objectID="#arguments.objectid#", typename="#arguments.typename#") />
		<cfset var stFriendlyURL = StructNew()>
		<cfset var objNavigation = CreateObject("component", application.stcoapi['dmNavigation'].packagePath) />
		<cfset var qNavigation=querynew("parentid")>
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<!--- default return structure --->
		<cfset stReturn.bSuccess = 1>
		<cfset stReturn.message = "Set friendly URL for #arguments.objectid#.">

		<cfif isDefined("application.stCoapi.#stObj.typename#.bFriendly") AND application.stCoapi[stObj.typename].bFriendly>
		
			<!--- default stFriendlyURL structure --->
			<cfset stFriendlyURL.objectid = stobj.objectid>
			<cfset stFriendlyURL.friendlyURL = "">
			<cfset stFriendlyURL.querystring = "">
		

			
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displayDefaultFU" r_html="stFriendlyURL.friendlyURL" alternateHTML="">
			
			<cfif NOT len(stFriendlyURL.friendlyURL)>
				<!--- This determines the friendly url by where it sits in the navigation node  --->
				<cfset qNavigation = objNavigation.getParent(stobj.objectid)>
				
				<!--- if its got a tree parent, build from navigation folders --->
				<!--- TODO: this might be better done by checking for bUseInTree="true" 
							or remove it entirely.. ie let tree content have its own fu as well as folder fu
							or set up tree content to have like page1.cfm style suffixs
							PLUS need collision detection so don't overwrite another tree based content item fro utility nav
							PLUS need to exclude trash branch (perhaps just from total rebuild?
							GB 20060117 --->
				<cfif qNavigation.recordcount>
					<cfset stFriendlyURL.friendlyURL = createFUAlias(qNavigation.parentid)>
				
				<!--- otherwise, generate friendly url based on content type --->
				<cfelse> 
					<cfif StructkeyExists(application.stcoapi[stobj.typename],"fuAlias")>
						<cfset stFriendlyURL.friendlyURL = "/#application.stcoapi[stobj.typename].fuAlias#" />
					<cfelseif StructkeyExists(application.stcoapi[stobj.typename],"displayName")>
						<cfset stFriendlyURL.friendlyURL = "/#application.stcoapi[stobj.typename].displayName#" />
					<cfelse>
						<cfset stFriendlyURL.friendlyURL = "/#ListLast(application.stcoapi[stobj.typename].name,'.')#" />
					</cfif>
					
				</cfif>				
			
				<cfif structKeyExists(stobj, "fu") AND trim(stobj.fu) neq "">
					<cfset stFriendlyURL.friendlyURL = stFriendlyURL.friendlyURL & "/#stobj.fu#">
				<cfelse>
					<cfset stFriendlyURL.friendlyURL = stFriendlyURL.friendlyURL & "/#stobj.label#">
				</cfif>
			</cfif>
			<!--- set friendly url in database --->
			
			<cfset setFU(stFriendlyURL.objectid, stFriendlyURL.friendlyURL, stFriendlyURL.querystring)>
		</cfif>
		
 		<cfreturn stReturn />
	</cffunction>
	
	
	<cffunction name="deleteMapping" access="public" returntype="boolean" hint="Deletes a mapping and writes the map file to disk" output="No">
		<cfargument name="alias" required="yes" type="string">
		
		<cfquery datasource="#application.dsn#" name="qDelete">
		DELETE	
		FROM	#application.dbowner#farFu 				
		WHERE	friendlyURL = <cfqueryparam value="#arguments.alias#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfset StructDelete(variables.stMappings,arguments.alias)>
		<!--- <cfset dataObject.removeMapping(arguments.alias)> --->
		<cfreturn true>
	</cffunction>
	

	<cffunction name="getFUstruct" access="public" returntype="struct" hint="Returns a structure of all friendly URLs, keyed on object id." output="No">
		<cfargument name="domain" required="no" type="string" default="#cgi.server_name#">
		
		<cfset var stMappings = initialiseMappings()>
		<cfset var stFU = structnew()>
		
		<cfloop collection="#stMappings#" item="i">
			<cfif findnocase(domain,i)>
				<cfset stFU[listgetat(stMappings[i],2,"=")] = "/" & listRest(i,'/')>
			</cfif>
		</cfloop>
		
		<cfreturn stFU>
	</cffunction>		
				
	<cffunction name="IsUUID" returntype="boolean" access="private" output="false" hint="Returns TRUE if the string is a valid CF UUID.">
		<cfargument name="str" type="string" default="" />
	
		<cfreturn REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", str) />
	</cffunction>
	
	
	<cffunction name="deleteAll" access="public" returntype="boolean" hint="Deletes all mappings and writes the map file to disk" output="No">
		
		<cfset var stLocal = structNew() />
		<!--- <cfset var mappings = getMappings()>
		<cfset var dom = "">
		<cfset var i = ""> --->
		<!--- loop over all entries and delete those that match domain --->
		
		<cfquery datasource="#application.dsn#" name="stLocal.qDelete">
		DELETE	
		FROM	#application.dbowner#farFu
		WHERE	fuStatus != 2
		</cfquery>
		
		<cfset initialiseMappings() />
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="deleteFU" access="public" returntype="boolean" hint="Deletes a mappings and writes the map file to disk" output="No" bDocument="true">
		<cfargument name="alias" required="yes" type="string" hint="old alias of object to delete">
		
		<cfset var dom = "">
		<cfset var sFUKey = "">		
		<cfset var mappings = structCopy(variables.stMappings)>
		
		<!--- loop over all domains --->
		<cfloop list="#application.config.fusettings.domains#" index="dom">
			<cfset sFUKey = "#dom##arguments.alias#">
			<cfset aFuKey = structFindKey(mappings,sFUKey,"one")>
			<cfif arrayLen(aFuKey)>
				<cfset deleteMapping(sFUKey)>
			</cfif>
		</cfloop>
		<!--- <cfset updateAppScope()> --->
		<cfreturn true>
	</cffunction>
		
		

   <cffunction name="createFUAlias" access="public" returntype="string" hint="Creates the FU Alias for a given objectid" output="no">
		<cfargument name="objectid" required="Yes">
		<cfargument name="bIncludeSelf" required="no" default="1">

		<cfset var stLocal = StructNew()>
		<cfset stLocal.qListAncestors = application.factory.oTree.getAncestors(objectid=arguments.objectid,bIncludeSelf=arguments.bIncludeSelf)>
		<cfset stLocal.returnString = "">

		<cfif stLocal.qListAncestors.RecordCount>
			<!--- remove root & home --->
			<cfquery dbtype="query" name="stLocal.qListNav">
			SELECT 	objectID
			FROM 	stLocal.qListAncestors
			WHERE 	nLevel >= 2
			ORDER BY nLevel
			</cfquery>
			
			<cfset stLocal.lNavID = ValueList(stLocal.qListNav.objectid)>
			<cfset stLocal.lNavID = ListQualify(stLocal.lNavID,"'")>

			<cfif stLocal.lNavID NEQ "" AND arguments.objectid NEQ application.navid.home>
				<!--- optimisation: get all dmnavgiation data to avoid a getData() call --->
				<cfquery name="stLocal.qListNavAlias" datasource="#application.dsn#">
		    	SELECT	dm.objectid, dm.label, dm.fu 
		    	FROM	#application.dbowner#dmNavigation dm, #application.dbowner#nested_tree_objects nto
		    	WHERE	dm.objectid = nto.objectid
		    			AND dm.objectid IN (#preserveSingleQuotes(stLocal.lNavID)#)
		    	ORDER by nto.nlevel ASC
				</cfquery>
		
				<cfloop query="stLocal.qListNavAlias">
					<!--- check if has FU if so use it --->
					<cfif trim(stLocal.qListNavAlias.fu) NEQ "">
						<cfset stLocal.returnString = ListAppend(stLocal.returnString,trim(stLocal.qListNavAlias.fu))>
					<cfelse> <!--- no FU so use label --->
						<cfset stLocal.returnString = ListAppend(stLocal.returnString,trim(stLocal.qListNavAlias.label))>
					</cfif>
				</cfloop>
				
			</cfif>
		</cfif>
		
		<!--- change delimiter --->
		<cfset stLocal.returnString = listChangeDelims(stLocal.returnString,"/") />
		<!--- remove spaces --->
		<cfset stLocal.returnString = ReReplace(stLocal.returnString,' +','-',"all") />
		<cfif Right(stLocal.returnString,1) NEQ "/">
			<cfset stLocal.returnString = stLocal.returnString & "/">
		</cfif>

   		<cfreturn lcase(stLocal.returnString)>
	</cffunction>	
	
	<cffunction name="createAndSetFUAlias" access="public" returntype="string" hint="Creates and sets an the FU mapping for a given dmNavigation object. Returns the generated friendly URL." output="No">
		<cfargument name="objectid" required="true" hint="The objectid of the dmNavigation node" />
		<cfset var breadCrumb = "">

		<cfif arguments.objectid eq application.navid.home>
			<cfset breadcrumb = "" /><!--- application.config.fusettings.urlpattern --->
		<cfelse>
			<cfset breadcrumb = createFUAlias(objectid=arguments.objectid) />
		</cfif>
	
		<cfif breadCrumb neq "">
			<cfset setFU(objectid=arguments.objectid,alias=breadcrumb) />
		</cfif>
		<cfreturn breadCrumb />
	</cffunction>
	
	<cffunction name="createAll" access="public" returntype="boolean" hint="Deletes old mappings and creates new entries for entire tree, and writes the map file to disk" output="No">
		
		<!--- get nav tree --->
		<cfset var qNav = application.factory.oTree.getDescendants(objectid=application.navid.home, depth=50)>
		<cfset var qAncestors = "">
		<cfset var qCrumb = "">
		<cfset var breadCrumb = "">
		<cfset var oNav = createObject("component",application.types.dmNavigation.typepath)>
		<cfset var i = 0>

		<!--- remove existing fu's --->
		<cfset deleteALL()>
		<!--- set error template --->		
		<!--- <cfset setErrorTemplate("#application.url.webroot#")> --->
		<!--- set nav variable --->
		<!--- <cfset setURLVar("nav")> --->
		<!--- loop over nav tree and create friendly urls --->
		<cfloop query="qNav">
			<cfset createAndSetFUAlias(objectid=qNav.objectid) />
		</cfloop>

		<!--- create fu for home--->
		<!--- <cfset createAndSetFUAlias(objectid=application.navid.home) /> --->

		<cfset onAppInit() />
		<cfreturn true />
	</cffunction>
	
	<cffunction name="setFU" access="public" returntype="string" hint="Sets an fu" output="yes" bDocument="true">
		<cfargument name="objectid" required="yes" type="UUID" hint="objectid of object to link to">
		<cfargument name="alias" required="yes" type="string" hint="alias of object to link to">
		<cfargument name="querystring" required="no" type="string" default="" hint="extra querystring parameters">
		
		<cfset var dom = "">
		<!--- replace spaces in title --->
		<cfset var newAlias = replace(arguments.alias,' ','-',"all")>
		<!--- replace duplicate dashes with a single dash --->
		<cfset newAlias = REReplace(newAlias,"-+","-","all")>
		<!--- replace the html entity (&amp;) with and --->
		<cfset newAlias = reReplaceNoCase(newAlias,'&amp;','and',"all")>
		<!--- remove illegal characters in titles --->
		<cfset newAlias = reReplaceNoCase(newAlias,'[,:\?##����]','',"all")>
		<!--- change & to "and" in title --->
		<cfset newAlias = reReplaceNoCase(newAlias,'[&]','and',"all")>
		<!--- prepend fu url pattern and add suffix --->
		<cfset newAlias = newAlias>
		<cfset newAlias = ReplaceNocase(newAlias,"//","/","All")>
		<cfset newAlias = LCase(newAlias)>
		<cfset newAlias = ReReplaceNoCase(newAlias,"[^a-z0-9/]"," ","all")>
		<cfset newAlias = ReReplaceNoCase(newAlias,"  "," ","all")>
		<cfset newAlias = Trim(newAlias)>
		<cfset newAlias = ReReplaceNoCase(newAlias," ","-","all")>		
		<!--- loop over domains and set fu ---> 
		<!--- <cfloop list="#application.config.fusettings.domains#" index="dom"> --->
			<cfset setMapping(alias=newAlias,mapping="#application.url.conjurer#?objectid=#arguments.objectid#",querystring=arguments.querystring)>
		<!--- </cfloop> --->
		<!--- <cfset updateAppScope()> --->
	</cffunction>
	
	<cffunction name="getFU" access="public" returntype="string" hint="Retrieves fu for a real url, returns original ufu if non existent." output="yes" bDocument="true">
		<cfargument name="objectid" required="false" type="string" default="" hint="objectid of object to link to">
		<cfargument name="type" required="false" type="string" default="" hint="typename of object to link to">
		<cfargument name="view" required="false" type="string" default="" hint="view used to render the page layout">
		<cfargument name="bodyView" required="false" type="string" default="" hint="view used to render the body content">

		<cfset var returnURL = "">
		<cfset var bFoundFU = false /><!--- State used to determine if we found a friendly URL --->
		
		<cfif application.fc.factory.farFU.isUsingFU()>
			
			<cfif len(arguments.objectid)>
				<!--- LOOK UP IN MEMORY CACHE ---> 
				<cfif structKeyExists(variables.stLookup, arguments.objectid)>
					<cfset returnURL = variables.stLookup[arguments.objectid].friendlyURL />
					<cfset bFoundFU = true />
				
				<!--- IF NOT IN CACHE CHECK THE DATABASE --->
				<cfelse>

					<!--- GET FRIENDLY URL BASED ON THE OBJECTID --->					
					<cfset stFUObject = getDefaultFUObject(refObjectID="#arguments.objectid#") />
					
					<!--- JUST IN CASE WE DONT HAVE A DEFAULT FU SET, USE THE SYSTEM OBJECT IF AVAILABLE --->
					<cfif structIsEmpty(stFUObject)>
						<cfset stFUObject = getSystemObject(refObjectID="#arguments.objectid#") />
					</cfif>
					
					<!--- IF WE FOUND AN FU, THE USE IT, OTHERWISE START THE URL SYNTAX --->
					<cfif NOT structIsEmpty(stFUObject)>
						<cfset returnURL = "#stFUObject.friendlyURL#">			
						<cfset bFoundFU = true />
					<cfelse>
						<cfset returnURL = "/#arguments.objectid#">
					</cfif>					
				</cfif>				
			</cfif>
			
			<!---------------------------------------------------------------------
			 IF WE HAVE OUR OTHER URL SYNTAX ATTRIBUTES, APPEND THEM TO THE URL
			 --------------------------------------------------------------------->			
			<cfif len(arguments.type) OR  len(arguments.view) OR len(arguments.bodyView)>
			
				<!--- IF WE ARE USING A FRIENDLY URL OR OUR URL ALREADY CONTAINS A QUESTION MARK, THEN WE CAN USE REGULAR URL VARIABLES  --->
				<cfif bFoundFU OR FindNoCase("?", returnURL)>
					<cfif len(arguments.type)>
						<cfset returnURL = "#returnURL#&type=#arguments.type#" />
					</cfif>
					<cfif len(arguments.view)>
						<cfset returnURL = "#returnURL#&view=#arguments.view#" />
					</cfif>
					<cfif len(arguments.bodyView)>
						<cfset returnURL = "#returnURL#&bodyView=#arguments.bodyView#" />
					</cfif>		
				<cfelse>
					<!--- OTHERWISE WE CAN USE THE URL SYNTAX OF /OBJECTID/TYPE/VIEW/BODYVIEW --->
					<cfif len(arguments.type)>
						<cfset returnURL = "#returnURL#/#arguments.type#" />
					</cfif>
					<cfif len(arguments.view)>
						<cfset returnURL = "#returnURL#/#arguments.view#" />
					</cfif>
					<cfif len(arguments.bodyView)>
						<cfif NOT len(arguments.view)>
							<!--- If we have a bodyView, we must include the view for the syntax to work. --->
							<cfset returnURL = "#returnURL#/displayPageStandard" />
						</cfif>
						<cfset returnURL = "#returnURL#/#arguments.bodyView#" />
					</cfif>		
				</cfif>
			</cfif>			
			
		<!------------------------------------------------------------------------------------------ 
		WE ARE NOT USING FRIENDLY URLS SO SIMPLY SETUP THE URL STRING WITH THE ARGUMENTS PASSED IN
		 ------------------------------------------------------------------------------------------>
		<cfelse>			
			<cfset returnURL = "#application.url.conjurer#?" />
			
			<cfif len(arguments.objectid)>
				<cfset returnURL = "#returnURL#objectid=#arguments.objectid#" />
			</cfif>
			<cfif len(arguments.type)>
				<cfset returnURL = "#returnURL#&type=#arguments.type#" />
			</cfif>
			<cfif len(arguments.view)>
				<cfset returnURL = "#returnURL#&view=#arguments.view#" />
			</cfif>
			<cfif len(arguments.bodyView)>
				<cfset returnURL = "#returnURL#&bodyView=#arguments.bodyView#" />
			</cfif>
		</cfif>
		
		<cfreturn returnURL>
	</cffunction>

	<cffunction name="getFUList" access="public" returntype="query" hint="returns a query of FU for a particular objectid and status" output="false">
		<cfargument name="objectid" required="yes" hint="Objectid of object" />
		<cfargument name="fuStatus" required="no" default="current" hint="status of friendly you want, [all (0,1,2), current (1,2), system (1), custom (2), archived (0)]" />
			   
		<cfset var stLocal = StructNew()>
		<cfset stLocal.fuStatus = "">

		<cfswitch expression="#arguments.fuStatus#">
			<cfcase value="current">
				<cfset stLocal.fuStatus = "1,2">
			</cfcase>
		
			<cfcase value="system">
				<cfset stLocal.fuStatus = "1">
			</cfcase>
		
			<cfcase value="custom">
				<cfset stLocal.fuStatus = "2">
			</cfcase>
		
			<cfcase value="archived">
				<cfset stLocal.fuStatus = "0">
			</cfcase>
					
			<cfdefaultcase>
				<cfset stLocal.fuStatus = "0,1,2">
			</cfdefaultcase>
		</cfswitch>
		
		<!--- get friendly url based on the objectid --->
		<cfswitch expression="#application.dbtype#">
		<cfcase value="ora,oracle">					
			<cfquery datasource="#application.dsn#" name="stLocal.qList">
			SELECT	u.*
			FROM	#application.dbowner#farFU u, 
					#application.dbowner#refObjects r
			WHERE	r.objectid = u.refobjectid
					AND u.refobjectid = <cfqueryparam value="#arguments.objectid#" cfsqltype="cf_sql_varchar">
					AND u.fuStatus IN (<cfqueryparam value="#stLocal.fuStatus#" list="true">)
			ORDER BY fuStatus DESC
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery datasource="#application.dsn#" name="stLocal.qList">
			SELECT	u.*
			FROM	#application.dbowner#farFU u inner join 
					#application.dbowner#refObjects r on r.objectid = u.refobjectid
			WHERE	refobjectid = <cfqueryparam value="#arguments.objectid#" cfsqltype="cf_sql_varchar">
				AND fuStatus IN (<cfqueryparam value="#stLocal.fuStatus#" list="true">)
			ORDER BY fuStatus DESC
			</cfquery>
		</cfdefaultcase>
		</cfswitch>
		
		<cfreturn stLocal.qList>
		
	</cffunction>
	
	<cffunction name="fInsert" access="public" returntype="struct" hint="returns a query of FU for a particular objectid" output="No">
		<cfargument name="stForm" required="yes" hint="friendly url struct" type="struct" />

		<cfset var stLocal = StructNew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">

		<!--- If the ref object does not currently have a default FU, set this as the default --->
		<cfif structKeyExists(arguments.stForm, "refObjectID")>
			<cfset stLocal.defaultFU = getDefault(refObjectID="#arguments.stForm.refObjectID#") />
			<cfif not len(stLocal.defaultFU)>
				<cfset arguments.stForm.bDefault = 1 />
			</cfif>
		</cfif>
		
		<cftry>

			<cfif left(arguments.stForm.friendlyURL,1) NEQ "/">
				<cfset arguments.stForm.friendlyURL = "/#arguments.stForm.friendlyURL#" />
			</cfif>
			
			<cfquery datasource="#application.dsn#" name="stLocal.qCheck">
			SELECT	objectid
			FROM	#application.dbowner#farFu
			WHERE	lower(friendlyURL) = <cfqueryparam value="#LCase(arguments.stForm.friendlyurl)#" cfsqltype="cf_sql_varchar">
				AND fuStatus > 0
			</cfquery>
			
			<cfif stLocal.qCheck.recordcount EQ 0>
				<cfset arguments.stForm.objectID = application.fc.utils.createJavaUUID()>
				<cfset stResult = createData(stProperties="#arguments.stForm#") />
				
			
				<!--- add to app scope --->
				<cfif arguments.stForm.fuStatus GT 0>
					<cfset variables.stMappings[arguments.stForm.friendlyURL] = StructNew() />
					<cfset variables.stMappings[arguments.stForm.friendlyURL].refobjectid = arguments.stForm.refObjectID />
					<cfset variables.stMappings[arguments.stForm.friendlyURL].queryString = arguments.stForm.querystring />
					<cfset variables.stLookup[arguments.stForm.refObjectID] = arguments.stForm.friendlyURL />
				</cfif>
			<cfelse>
				<cfset stLocal.returnstruct.bSuccess = 0>
				<cfset stLocal.returnstruct.message = "Sorry the Friendly URL: #arguments.stForm.friendlyurl# is currently active.<br />">
			</cfif>

			<cfcatch>
				<cfset stLocal.returnstruct.bSuccess = 0>
				<cfset stLocal.returnstruct.message = "#cfcatch.message# - #cfcatch.detail#">
			</cfcatch>
		</cftry>
		
		<cfreturn stLocal.returnstruct>
	</cffunction>
	
	<cffunction name="fDelete" access="public" returntype="struct" hint="returns a query of FU for a particular objectid" output="No">
		<cfargument name="stForm" required="yes" hint="friendly url struct" type="struct" />

		<cfset var stLocal = StructNew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">

		<cftry>
			<cfset arguments.stForm.lDeleteObjectid = ListQualify(arguments.stForm.lDeleteObjectid,"'")>
			<cfquery datasource="#application.dsn#" name="stLocal.qList">
			SELECT	friendlyurl
			FROM	#application.dbowner#farFu
			WHERE	objectid IN (#preservesinglequotes(arguments.stForm.lDeleteObjectid)#)
			</cfquery>

			<cfquery datasource="#application.dsn#" name="stLocal.qDelete">
			DELETE
			FROM	#application.dbowner#farFu
			WHERE	objectid IN (#preservesinglequotes(arguments.stForm.lDeleteObjectid)#)
			</cfquery>
			
			<cfloop query="stLocal.qList">
				<!--- delete from app scope --->
				<cfset StructDelete(application.FU.mappings,stLocal.qList.friendlyurl)>
			</cfloop>

			<cfcatch>
				<cfset stLocal.returnstruct.bSuccess = 0>
				<cfset stLocal.returnstruct.message = "#cfcatch.message# - #cfcatch.detail#">
			</cfcatch>
		</cftry>
		
		<cfreturn stLocal.returnstruct>
	</cffunction>
		
</cfcomponent>