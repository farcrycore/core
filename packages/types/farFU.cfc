<cfcomponent 
	displayname="FarCry Friendly URL Table" hint="Manages FarCry Friendly URL's" extends="types" output="false" 
	bDocument="true" scopelocation="application.fc.factory.farFU" 
	bObjectBroker="true" objectBrokerMaxObjects="10000" 
	fuAlias="fu"
	bSystem="true"
	icon="fa-link">
	
	<cfproperty 
		name="refobjectid" type="string" default="" hint="stores the objectid of the related object" 
		ftSeq="1" ftLabel="Ref ObjectID" dbIndex="true" />
		
	<cfproperty 
		name="friendlyURL" type="string" default="" hint="The Actual Friendly URL" bLabel="true"
		ftSeq="2" ftLabel="Friendly URL" dbIndex="true"  />
		
	<cfproperty 
		name="queryString" type="string" default="" hint="The query string that will be parsed and placed in the url scope of the request" 
		ftSeq="3" ftLabel="Query String" />	
		
	<cfproperty 
		name="fuStatus" type="integer" default="" hint="Status of the Friendly URL." 
		ftSeq="4"  ftLabel="Status"
		ftType="list" ftList="1:System Generated,2:Custom,0:archived" ftDefault="2" />
		
	<cfproperty 
		name="redirectionType" type="string" default="" hint="Type of Redirection" 
		ftSeq="5" ftLabel="Type of Redirection"
		ftType="list" ftList="none:None,301:Moved Permanently (301),307:Temporary Redirect (307)" ftDefault="301" />
		
	<cfproperty 
		name="redirectTo" type="string" default="" hint="Where to redirect to" 
		ftSeq="6" ftLabel="Redirect To" 
		ftType="list" ftList="default:To the default FU,objectid:Direct to the object ID" />
		
	<cfproperty 
		name="bDefault" type="boolean" default="0" hint="Only 1 Friendly URL can be the default that will be used by the system" 
		ftSeq="7" ftLabel="Default" 
		ftDefault="0" />
		
	<cfproperty 
		name="applicationName" type="string" default="" hint="The application name that the friendly URL is a part of. Useful for subsites."
		ftSeq="8" >

	<cffunction name="onAppInit" returntype="any" access="public" output="false" hint="Initializes the friendly url scopes and returns a copy of this initialised object">

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
			<cfif CGI.SERVER_PORT_SECURE>
				<cfhttp url="https://#cgi.server_name##application.url.webroot#/pingFU" throwonerror="true" timeout="1" port="#cgi.server_port#" result="pingResponse" />
			<cfelse>
				<cfhttp url="http://#cgi.server_name##application.url.webroot#/pingFU" throwonerror="true" timeout="1" port="#cgi.server_port#" result="pingResponse" />
			</cfif>
		
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
			<cfset setMapping(objectid=stLocal.stProps.objectID) />

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
		
		<cfset setMapping(objectid=stLocal.stFU.objectid) />

		<cfreturn stLocal.stReturn />
		
	</cffunction>

	<cffunction name="getDefaultFUObject" returnType="struct" access="public" output="false" hint="Returns the default FU objectid for an object. Returns empty string if no default is set.">
		<cfargument name="refObjectID" required="yes" hint="Objectid of the RefObject to retrieve the default" />
		<cfargument name="bIgnoreCache" required="false" type="boolean" default="false" />
			
		<cfset var stLocal = structNew() />
		<cfset var stDefaultFU = structNew() />
		
		<cfif not arguments.bIgnoreCache>
			<cfset stDefaultFU = getFUStructByObjectID(arguments.refObjectID) />
		</cfif>
		
		<cfif structIsEmpty(stDefaultFU)>
			<!--- 
			SORTING BY DEFAULT FIRST SO THAT IF WE HAVE A DEFAULT SETUP IT WILL BE PICKED UP.
			However, if no default is available, we will automatically get the custom first or else finally the system
			 --->
			<cfquery datasource="#application.dsn#" name="stLocal.qDefault">
				SELECT 		f.objectid as objectid, r.typename as typename
				FROM 		farFU f
							INNER JOIN 
							refObjects r
							on f.refobjectid = r.objectid
				WHERE 		f.refobjectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.refObjectID#" />
							AND f.fuStatus > 0
				ORDER BY 	f.bDefault DESC, f.fuStatus DESC 
			</cfquery>		
		
			<cfif stLocal.qDefault.recordCount>
				<cfset stDefaultFU = getData(objectid="#stLocal.qDefault.objectID#") />

				<cfif not arguments.bIgnoreCache>
					<cfset setMapping(objectid="#stLocal.qDefault.objectID#", bForce="true", typename="#stLocal.qDefault.typename#") /><!--- Setting bForce ensures that this FU is used as the default because it MAY not have a default set. --->
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn stDefaultFU />
		
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
	
	
	<cffunction name="cleanFU" access="public" returntype="string" hint="Cleans up the Friendly URL and ensures it is Unique." output="false" bDocument="true">
		<cfargument name="friendlyURL" required="yes" type="string" hint="The actual Friendly URL to use">
		<cfargument name="bCheckUnique" required="false" type="boolean" default="true" hint="Check to see if the Friendly URL has already been taken">
		<cfargument name="fuID" required="false" type="string" default="" hint="The objectid of the farFU object the friendly URL is attached to. This is used to exclude from the check unique function.">
		
		<cfset var stLocal = structNew() />
		<cfset var cleanFU = "" />
		<cfset var bDuplicate = true />
		<cfset var duplicateCounter = "" />
		
		<cfset cleanFU = LCase(arguments.friendlyURL)>
		
		<!--- custom replacement of country specific chars BEFORE other standard replacements --->
		<cfset cleanFU = replaceCountrySpecificChars(FUstring="#cleanFU#") />

		<!--- replace the html entity (&amp;) with and --->
		<cfset cleanFU = reReplaceNoCase(cleanFU,'&amp;','and',"all")>
		<!--- change & to "and" in title --->
		<cfset cleanFU = reReplaceNoCase(cleanFU,'[&]','and',"all")>
		<!--- prepend fu url pattern and add suffix --->
		<cfset cleanFU = ReReplaceNocase(cleanFU,"/{2,}","/","All")>
		<cfset cleanFU = ReReplaceNoCase(cleanFU,"[^a-z0-9/]+","-","all")>
		<cfset cleanFU = ReReplaceNoCase(cleanFU,"-($|/)","\1","all")>
		<cfset cleanFU = ReReplaceNoCase(cleanFU,"(^|/)-","\1","all")>
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
	
	
	<cffunction name="replaceCountrySpecificChars" access="private" returntype="string" hint="Replaces country specific chars in the Friendly URL." output="false">
		<cfargument name="FUstring" required="yes" type="string" hint="The actual Friendly URL to use">
		
		<cfset var userLanguage = "en" />
		<cfset var stCurrentProfile = application.fapi.getCurrentUsersProfile() />
		<cfset var result = arguments.FUstring />
		
		<cfif structKeyExists(stCurrentProfile, "locale")>
			<cfset userLanguage = left(stCurrentProfile.locale,2) />
		</cfif>
		
		<!--- !!! Replace country specific chars ONLY with URL compatible chars 'a-z' and '0-9' !!! --->
		<cfswitch expression="#userLanguage#">
			<cfcase value="de">
				<!--- DE :: GERMAN :: Replacement rules for replacing chars in FU --->
				<cfset result = ReReplaceNoCase(result,"[ä]+","ae","all")>
				<cfset result = ReReplaceNoCase(result,"[ö]+","oe","all")>
				<cfset result = ReReplaceNoCase(result,"[ü]+","ue","all")>
				<cfset result = ReReplaceNoCase(result,"[ß]+","ss","all")>
				<!--- replace the html entity (&amp;) with german "und" --->
				<cfset result = reReplaceNoCase(result,'&amp;','und',"all")>
				<!--- change & to german "und" in title --->
				<cfset result = reReplaceNoCase(result,'[&]','und',"all")>
				<!--- Custom replacement of illegal characters in titles                  
				      Special regex characters have to be escape with a backslash '\'     
				      Special characters are: + * ? . [ ^ $ ( ) { | \                 --->
				<cfset result = reReplaceNoCase(result,"['§%~`´\+\*\?\.\^\$]+",'',"all")>
			</cfcase>

			<!--- further '<cfcase> </cfcase>' replacements for other languages can follow HERE --->

		</cfswitch>
		
		<!--- return the replaced FU-String --->
		<cfreturn result />
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
		<cfif not StructKeyExists(application.stcoapi[stLocal.stObj.typename],"bFriendly") or not application.stcoapi[stLocal.stObj.typename].bFriendly>
			<cfset stLocal.stResult.bSuccess = false />
			<cfset stLocal.stResult.message = "#arguments.typename# does not require friendly URLs" />
			<cfreturn stLocal.stResult />
		</cfif>
			
		<!--- Only create friendly urls on approved content --->
		<cfif StructKeyExists(stLocal.stObj,"status") and not stLocal.stObj.status EQ "approved">
			<cfset stLocal.stResult.bSuccess = false />
			<cfset stLocal.stResult.message = "Object not approved" />
			<cfreturn stLocal.stResult />
		</cfif>
		
		<!--- Get current default and system FUs --->
		<cfset stLocal.stCurrentDefaultObject = getDefaultFUObject(refObjectID=arguments.objectid) />
		<cfset stLocal.stCurrentSystemObject = getSystemObject(refObjectID="#arguments.objectid#") />
		
		<!--- If the default isn't the system FU, and the system FU has been deleted, don't regenerate one --->
		<cfif structisempty(stLocal.stCurrentSystemObject) and not structisempty(stLocal.stCurrentDefaultObject) and stLocal.stCurrentDefaultObject.bDefault>
			<cfset stLocal.stResult.bSuccess = false />
			<cfset stLocal.stResult.message = "System FU not needed" />
			<cfreturn stLocal.stResult />
		</cfif>
		
		<!--- Generate the new system FU for the current object --->
		<cfset stLocal.newFriendlyURL = getSystemFU(objectID="#arguments.objectid#", typename="#arguments.typename#") />
		
		<cfif structIsEmpty(stLocal.stCurrentSystemObject)>
			<!--- No System FU object currently set --->
			<cfset stLocal.stCurrentSystemObject.objectid = application.fc.utils.createJavaUUID() />
			<cfset stLocal.stCurrentSystemObject.refObjectID = arguments.objectid />
			<cfset stLocal.stCurrentSystemObject.fuStatus = 1 />
			<cfset stLocal.stCurrentSystemObject.redirectionType = "none" />
			<cfset stLocal.stCurrentSystemObject.redirectTo = "default" />
			<cfset stLocal.stCurrentSystemObject.friendlyURL = getUniqueFU(friendlyURL="#left(stLocal.newFriendlyURL,245)#") />
			
			<!--- If no default object, set this as the default --->
			<cfif structIsEmpty(stLocal.stCurrentDefaultObject)>
				<cfset stLocal.stCurrentSystemObject.bDefault = 1 />
			</cfif>
			<cftry>
			<cfset stLocal.stResult = setData(stProperties="#stLocal.stCurrentSystemObject#") />
			<cfcatch type="any">
				<cfoutput><p>#getUniqueFU(friendlyURL="#stLocal.newFriendlyURL#")#</p></cfoutput>
				<cfdump var="#stLocal#" expand="false" label="stLocal" />
				<cfdump var="#cfcatch#"><cfabort />
			</cfcatch>
			</cftry>
		<cfelse>
			<cfset stLocal.newFriendlyURL = getUniqueFU(friendlyURL="#left(stLocal.newFriendlyURL,245)#", FUID="#stLocal.stCurrentSystemObject.objectid#") />
			<cfif stLocal.newFriendlyURL NEQ stLocal.stCurrentSystemObject.friendlyURL>
				<!--- NEED TO ARCHIVE OLD SYSTEM OBJECT AND UPDATE --->
				<cfset stLocal.stResult = archiveFU(objectid="#stLocal.stCurrentSystemObject.objectid#") />
				<cfset stLocal.stCurrentSystemObject.friendlyURL = stLocal.newFriendlyURL />
				<cfset stLocal.stResult = setData(stProperties="#stLocal.stCurrentSystemObject#") />
			</cfif>
		</cfif>
		
		<cfset setMapping(objectid="#stLocal.stCurrentSystemObject.objectid#") />
		
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
		

		<cfif structkeyexists(stObj,"typename") and isDefined("application.stCoapi.#stObj.typename#.bFriendly") AND application.stCoapi[stObj.typename].bFriendly>
		
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
		
		<cfset var lLegacyFields	= '' />
		<cfset var stProps	= '' />
		<cfset var stResult	= '' />
		<cfset var i	= '' />
		<cfset var qLegacy	= '' />

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
		
	</cffunction>
  
	<cffunction name="setupCoapiAlias" access="public" hint="Initializes the friendly url coapi and webskin aliases" output="false" returntype="void" bDocument="true">

		<cfset var thistype = "" />
		<cfset var thiswebskin = "" />
		
		<cfset this.typeFU = structNew() />
		<cfset this.webskinFU = structnew() />
		
		<cfif structKeyExists(application, "stCoapi")>
			<cfloop collection="#application.stcoapi#" item="thistype">
				<cfif len(application.stcoapi[thistype].fuAlias)>
					<cfset this.typeFU[application.stcoapi[thistype].fuAlias] = thistype />
				</cfif>
				
				<cfset this.webskinFU[thistype] = structnew() >
				<cfloop collection="#application.stCOAPI[thistype].stWebskins#" item="thiswebskin">
					<cfif len(application.stCOAPI[thistype].stWebskins[thiswebskin].fuAlias)>
						<cfset this.webskinFU[thistype][application.stCOAPI[thistype].stWebskins[thiswebskin].fuAlias] = thiswebskin />
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>		
		
	</cffunction>
	
	<cffunction name="setMapping" access="public" output="false" returntype="void" hint="Add a FU record to the application scope mapping table.">
		<cfargument name="objectid" required="true" hint="The objectid of the farFU record we wish to add to the mapping tables.">
		<cfargument name="bForce" required="false" default="false" hint="Force the URL Struct to use this as the FU and not look for a default. This captures the problem where there IS no default.">
		<cfargument name="typename" required="false" default="" hint="The typename of the object">
		
		<cfset var stFU = getData(objectid="#arguments.objectid#") />
		<cfset var thisfu = "" />
		
		<cfif structkeyexists(arguments,"typename") and len(arguments.typename)>
			<cfset cacheURLStructByURL(stFU.friendlyURL,createURLStruct(farFUID=arguments.objectid,bForce=arguments.bForce,typename="#arguments.typename#")) />
		<cfelse>
			<cfset cacheURLStructByURL(stFU.friendlyURL,createURLStruct(farFUID=arguments.objectid,bForce=arguments.bForce)) />
		</cfif>

		<cfif stFU.bDefault>
			<cfset cacheFUStructByObjectID(stFU.refobjectid,stFU) />
		</cfif>
	</cffunction>
	
	<cffunction name="initialiseMappings" access="public" hint="Updates the fu application scope with all the persistent FU mappings from the database." output="false" returntype="void" bDocument="true">

		<cfset var stLocal = StructNew()>
		<cfset var stResult = StructNew()>
		<cfset var stDeployResult = StructNew()>
		<cfset var qLookup = "" />
		<cfset var stFU = structnew() />
		
		<!--- Check to make sure the farFU table has been deployed --->
		<cfif not application.fc.lib.db.isDeployed(typename="farFU",dsn=application.dsn)>
			<cflock name="deployFarFUTable" timeout="30">
				<!--- The table has not been deployed. We need to deploy it now --->
				<cfset application.fc.lib.db.deployType(typename="farFU",dsn=application.dsn,bDropTable=false) />
				<cfset migrate() />
			</cflock>		
		</cfif>
		
		
		<!--- retrieve list of all dmNavigation FU's that are not retired --->
		<cfquery name="stLocal.q" datasource="#application.dsn#">
			SELECT	fu.objectid, fu.friendlyurl, fu.refobjectid, fu.queryString, fu.bDefault, fu.fuStatus, fu.redirectionType, fu.redirectTo, fu.bDefault, fu.applicationname, r.typename
			FROM	#application.dbowner#farFU fu, 
					#application.dbowner#refObjects r
			WHERE	r.objectid = fu.refobjectid
					AND r.typename = 'dmNavigation'
					AND fu.bDefault = 1
					AND fu.fuStatus > 0
		</cfquery>
		
		<!--- load mappings to application scope --->
		<cfloop query="stLocal.q">
			<cfset stFU = structnew() />
			<cfset stFU.objectid = stLocal.q.objectid />
			<cfset stFU.refObjectID = stLocal.q.refObjectID />
			<cfset stFU.friendlyURL = stLocal.q.friendlyURL />
			<cfset stFU.querystring = stLocal.q.querystring />
			<cfset stFU.fuStatus = stLocal.q.fuStatus />
			<cfset stFU.redirectionType = stLocal.q.redirectionType />
			<cfset stFU.redirectTo = stLocal.q.redirectTo />
			<cfset stFU.bDefault = stLocal.q.bDefault />
			<cfset stFU.applicationname = stLocal.q.applicationname />
			<cfset stFU.refTypename = stLocal.q.typename />
			
			<cfset cacheURLStructByURL(stFU.friendlyURL,createURLStruct(stFU=stFU)) />
			
			<cfif stFU.bDefault>
				<!--- fu lookup --->
				<cfset cacheFUStructByObjectID(stFU.refobjectid,stFU) />
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="parseURL" returntype="struct" access="public" output="false" hint="Parses the url.furl and returns all relevent url variables.">
		<cfargument name="stURL" type="struct" required="true" default="#url#" hint="Reference to the URL struct" />
		
		<cfset var stLocalURL = duplicate(arguments.stURL) /><!--- Duplicate so we are not changing the referenced struct --->
		<cfset var stFU = structNew() />
		<cfset var stLocal = structNew() />
		<cfset var iQstr = "" />
		<cfset var i = "" />
		<cfset var stResult = structNew() />
		
		<!--- If the browser has added a trailing / to a friendly URL, strip it out. --->
		<cfif structKeyExists(stLocalURL, "furl") AND len(stLocalURL.furl) GT 1 AND right(stLocalURL.furl,1) EQ "/">
			<cfset stLocalURL.furl = left(stLocalURL.furl,len(stLocalURL.furl) -1) />
		</cfif>
		
		<cfif structkeyexists(stLocalURL, "furl") and len(stLocalURL.furl) gt 1>
			<cfset stResult = getURLStructByURL(stLocalURL.furl) />
		</cfif>
		
		<!--- Merge the FU data with the URL data --->
		<cfset StructAppend(stResult, stLocalURL, "true") />
		
		<!--- Normalise type fuAlias in query string --->
		<cfif structkeyexists(stResult,"type")>
			<cfif structkeyexists(this.typeFU,stResult.type)>
				<cfset stResult.type = this.typeFU[stResult.type] />
			</cfif>
		</cfif>
		
		<cfif structkeyexists(stResult,"objectid")
			AND not structKeyExists(stResult, "type")>
				<cfset stResult.type = application.fapi.findType(objectid=stResult.objectid) />
		</cfif>
		
		<!--- If there is an objectid but no type ... return immediately --->
		<cfif structkeyexists(stResult,"objectid") and not len(stResult.type)>
			<cfif (structkeyexists(stResult,"debug") and stResult.debug)>
				<cfthrow message="Objectid [#stResult.objectid#] does not refer to a valid record" />
			<cfelse>
				<cfreturn stResult />
			</cfif>
		</cfif>
		
		<!--- Normalise view fuAlias in query string --->
		<cfset stResult["__allowredirect"] = true />
		<cfif structkeyexists(stResult,"view") AND structKeyExists(stResult, "type")>
			<cfif not structkeyexists(this.webskinFU,stResult.type)>
				<cfreturn stResult />
			<cfelseif structkeyexists(this.webskinFU[stResult.type],stResult.view)>
				<cfset stResult.view = "#this.webskinFU[stResult.type][stResult.view]#" />
			<cfelseif structkeyexists(application.stCOAPI[stResult.type].stWebskins,stResult.view)>
				<!--- parameter is already the webskin name --->
			<cfelse>
				<!--- If the view is not a valid webskin for this type ... return immediately --->
				<cfset stResult["404"] = "Webskin [#stResult.view#] does not exist for type [#stResult.type#]" />
				<cfreturn stResult />
			</cfif>
			
			
			<cfset stResult["__allowredirect"] = stResult["__allowredirect"] and application.stCOAPI[stResult.type].stWebskins[stResult.view].allowredirect />
			
			<cfif application.stCOAPI[stResult.type].stWebskins[stResult.view].viewstack eq "data">
				<cfset stResult["__allowredirect"] = false />
			</cfif>
			
			<!--- Check the page viewbinding --->
			<cfif structkeyexists(stResult,"objectid") and not listcontainsnocase("any,object",application.stCOAPI[stResult.type].stWebskins[stResult.view].viewbinding)>
				<cfset stResult["404"] = "You are trying to bind an object [#stResult.objectid#] to a type webskin [#stResult.view#]" />
				<cfreturn stResult />
			</cfif>
			<cfif not structkeyexists(stResult,"objectid") and not listcontainsnocase("any,type",application.stCOAPI[stResult.type].stWebskins[stResult.view].viewbinding)>
				<cfset stResult["404"] = "You are trying to bind a type [#stResult.type#] to an object webskin [#stResult.view#]" />
				<cfreturn stResult />
			</cfif>
		</cfif>
		
		<!--- Normalise bodyView fuAlias in query string --->
		<cfif structkeyexists(stResult,"bodyView")>
			<cfif structkeyexists(this.webskinFU[stResult.type],stResult.bodyView)>
				<cfset stResult.bodyView = "#this.webskinFU[stResult.type][stResult.bodyView]#" />
			<cfelseif structkeyexists(application.stCOAPI[stResult.type].stWebskins,stResult.bodyView)>
				<!--- parameter is already the webskin name --->
			<cfelse>
				<!--- If the view is not a valid webskin for this type ... return immediately --->
				<cfset stResult["404"] = "Webskin [#stResult.bodyView#] does not exist for type [#stResult.type#]" />
				<cfreturn stResult />
			</cfif>
			
			<cfset stResult["__allowredirect"] = stResult["__allowredirect"] and application.stCOAPI[stResult.type].stWebskins[stResult.bodyview].allowredirect />
			
			<!--- Check the body viewbinding --->
			<cfif structkeyexists(stResult,"objectid") and not listcontainsnocase("any,object",application.stCOAPI[stResult.type].stWebskins[stResult.bodyView].viewbinding)>
				<cfset stResult["404"] = "You are trying to bind an object [#stResult.objectid#] to a type webskin [#stResult.bodyView#]" />
				<cfreturn stResult />
			</cfif>
			<cfif not structkeyexists(stResult,"objectid") and not listcontainsnocase("any,type",application.stCOAPI[stResult.type].stWebskins[stResult.bodyView].viewbinding)>
				<cfset stResult["404"] = "You are trying to bind a type [#stResult.type#] to an object webskin [#stResult.bodyView#]" />
				<cfreturn stResult />
			</cfif>
		</cfif>
		
		<cfif (structKeyExists(request.fc, "disableFURedirction") AND request.fc.disableFURedirction) or not stResult["__allowredirect"]>
			<!--- DON'T REDIRECT. This is sometimes nessesary like under the webtop. --->
		<cfelse>
			<!--- Handle redirection case --->
			<cfif structkeyexists(stResult,"__redirectionURL") and not structKeyExists(stResult, "ajaxmode")>
				<!--- Don't want to resend the furl --->
				<cfset structdelete(stLocalURL,"furl") />
				<cfif not isvalid("integer",stResult.__redirectionType)>
					<cfset stResult.__redirectionType = 301>
				</cfif>
				<cfheader statuscode="#stResult['__redirectionType']#" /><!--- statustext="Moved permanently" --->
				<cfheader name="Location" value="#application.fapi.fixURL(url=stResult['__redirectionURL'],addvalues=application.factory.oUtils.deleteQueryVariable('furl,objectid',cgi.query_string))#" charset="utf-8" />
				<cfabort />
			</cfif>
			
			<!--- If the user went to an objectid=xyz URL, but should be using a friendly URL, redirect them --->
			<cfif (not structKeyExists(stLocalURL, "furl") or stLocalURL.furl eq "" or stLocalURL.furl EQ "/") 
					and isUsingFU() 
					and not structKeyExists(stResult, "ajaxmode")
					and structKeyExists(stResult, "objectid") and stResult.objectid NEQ application.fapi.getNavID('home')>
					
				<cfset stLocal.stDefaultFU = getFUStructByObjectID(stResult.objectid) />
				
				<cfif not structisempty(stLocal.stDefaultFU) and stLocal.stDefaultFU.redirectionType EQ "none">
					<!--- Don't want to resend the furl or the objectid --->
					<cfset structdelete(stLocalURL,"furl") />
					<cfset structdelete(stLocalURL,"objectid") />
					<cfset structdelete(stLocalURL,"updateapp") />
					
					<cfheader statuscode="301" /><!--- statustext="Moved permanently" --->
					<cfheader name="Location" value="#application.fapi.getLink(objectid=stResult.objectid, urlParameters=application.factory.oUtils.deleteQueryVariable('furl,objectid',cgi.query_string), ampDelim="&")#" charset="utf-8" />
					<cfabort />
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="createURLStruct" access="public" returntype="struct" hint="Creates a set of URL variables from a farFU object and/or a fuParametersString">
		<cfargument name="farFUID" type="uuid" required="false" hint="The objectid of a farFU object" />
		<cfargument name="fuParameters" type="string" required="false" hint="The portion of the furl value that needs to be parsed" />
		<cfargument name="bForce" required="false" default="false" hint="Force the URL Struct to use this as the FU and not look for a default. This captures the problem where there IS no default.">
		<cfargument name="stFU" type="struct" required="false" hint="The full farFU object" />
		<cfargument name="typename" type="string" required="false" hint="The typename of the farFUID" />
		
		<cfset var stResult = structnew() />
		<cfset var qsToken = "" />
		<cfset var fuVars = "@type,@objectid,@pageview,@bodyview,@paramname" />
		<cfset var paramType = "" />
		<cfset var stWS = structnew() />
		<cfset var fuParam = "" />
		<cfset var stLocal = structnew() />
		
		<cfif structkeyexists(arguments,"farFUID") and not structkeyexists(arguments,"stFU")>
			<cfset arguments.stFU = getData(objectid=arguments.farFUID) />
			<cfif not structkeyexists(arguments,"typename")>
				<cfset arguments.stFU.refTypename = application.fapi.findType(arguments.stFU.refObjectID) />
			<cfelse>
				<cfset arguments.stFU.refTypename = arguments.typename>
			</cfif>
		</cfif>
		
		<cfif structkeyexists(arguments,"stFU")><!--- Grab URL variables from the farFU object --->
			<!--- Associated object --->
			<cfset stResult.objectid = arguments.stFU.refObjectID />
			<cfset stResult.type = arguments.stFU.refTypename />
			
			<!--- Query string variables --->
			<cfloop index="qsToken" list="#arguments.stFU.queryString#" delimiters="&">
				<cfset stResult["#listFirst(qsToken,'=')#"] = listLast(qsToken,"=")>
			</cfloop>
			
			<!--- If extra fURL parameters are provided, do not attempt to extract objectid or type --->
			<cfset fuVars = listdeleteat(fuVars,listfind(fuVars,"@objectid")) />
			<cfset fuVars = listdeleteat(fuVars,listfind(fuVars,"@type")) />
			
			<!--- Redirect information --->
			<cfif arguments.stFU.redirectionType NEQ "none">
				<!--- NOTE: URL information is still included in a redirect struct as the redirect will not be honoured for ajax requests --->
				
				<cfif arguments.stFU.redirectTo EQ "default" AND NOT arguments.stFU.bDefault eq 1 AND NOT arguments.bForce>
					
					<cfset stLocal.stDefaultFU = getDefaultFUObject(refObjectID=arguments.stFU.refObjectID) />
					
					<cfif not structIsEmpty(stLocal.stDefaultFU) AND stLocal.stDefaultFU.objectid NEQ stFU.objectid>
						<cfset stResult["__redirectionURL"] = "#application.url.webroot##stLocal.stDefaultFU.friendlyURL#" />
					</cfif>
				<cfelse>
					<cfset stResult["__redirectionURL"] = "#application.url.webroot#/index.cfm?objectid=#arguments.stFU.refObjectID#" />
				</cfif>
				
				<cfif structkeyexists(stResult,"__redirectionURL")>
					<cfif structkeyexists(arguments,"fuParameters")>
						<cfset stResult["__redirectionURL"] = stResult["__redirectionURL"] & arguments.fuParameters />
					</cfif>
					<cfif len(arguments.stFU.queryString) or len(rereplacenocase(cgi.query_string,"furl=[^&]+&?",""))>
						<cfif find("?",stResult["__redirectionURL"])>
							<cfset stResult["__redirectionURL"] = stResult["__redirectionURL"] & "&" & listappend(arguments.stFU.queryString,rereplacenocase(cgi.query_string,"furl=[^&]+&?",""),"&") />
						<cfelse>
							<cfset stResult["__redirectionURL"] = stResult["__redirectionURL"] & "?" & listappend(arguments.stFU.queryString,rereplacenocase(cgi.query_string,"furl=[^&]+&?",""),"&") />
						</cfif>
					</cfif>
					
					<cfset stResult["__redirectionType"] = arguments.stFU.redirectionType />
				</cfif>
			</cfif>
		</cfif>
		
		<cfif structkeyexists(arguments,"fuParameters")><!--- Parse URL variables from the string --->
			<cfloop list="#arguments.fuParameters#" index="fuParam" delimiters="/">
				<cfloop list="#fuVars#" index="paramType">
					<cfswitch expression="#paramType#">
						<cfcase value="@type">
							<!--- Parameter matches a type fuAlias --->
							<cfif structKeyExists(this.typeFU, fuParam)>
								<cfset stResult.type = this.typeFU[fuParam] />
								<cfset fuVars = listdeleteat(fuVars,listfind(fuVars,"@type")) />
								<cfbreak />
							</cfif>
							
							<!--- Parameter matches a type name --->
							<cfif structKeyExists(application.stCOAPI, fuParam)>
								<cfset stResult.type = fuParam />
								<cfset fuVars = listdeleteat(fuVars,listfind(fuVars,"@type")) />
								<cfbreak />
							</cfif>
						</cfcase>
						
						<cfcase value="@objectid">
							<cfif isValid("uuid",fuParam)>
								<cfset stResult.objectid = fuParam />
								<cfset fuVars = listdeleteat(fuVars,listfind(fuVars,"@objectid")) />
								
								<!--- If the form [/type]/objectid was used, and there is an actual FU available, setup a redirect to that --->
								<cfset stLocal.stDefaultFU = getDefaultFUObject(stResult.objectid) />
								<cfif not structIsEmpty(stLocal.stDefaultFU) AND stLocal.stDefaultFU.objectid NEQ stResult.objectid AND stLocal.stDefaultFU.redirectionType EQ "none">
									<!--- NOTE: URL information is still included in a redirect struct as the redirect will not be honoured for ajax requests --->
									<cfset stResult["__redirectionURL"] = "#application.url.webroot##stLocal.stDefaultFU.friendlyURL#" />
									<cfset stResult["__redirectionType"] = "301" />
								</cfif>
								
								<!--- Type and ObjectID can be used together - but only in that order. Don't check for type anymore. --->
								<cfif listcontains(fuVars,"@type")>
									<cfset stResult.type = application.fapi.findType(fuParam) />
									<cfset fuVars = listdeleteat(fuVars,listfind(fuVars,"@type")) />
								</cfif>
								
								<cfbreak />
							</cfif>
						</cfcase>
						
						<cfcase value="@pageview">
							<!--- Views can only be specified if the type is known... --->
							<cfif structKeyExists(stResult, "type") and len(stResult.type)>
							
								<cfset stWS = structNew() />
								
								<cfif structkeyexists(this.webskinFU[stResult.type],fuParam)>
									<cfset stWS = application.stCOAPI[stResult.type].stWebskins[this.webskinFU[stResult.type][fuParam]] />
								<cfelseif structkeyexists(application.stCOAPI[stResult.type].stWebskins,fuParam)>
									<cfset stWS = application.stCOAPI[stResult.type].stWebskins[fuParam] />
								</cfif>
								
								<cfif not structisempty(stWS)>
									<cfif structkeyexists(stResult,"__redirectionURL")>
										<cfset stResult["__redirectionURL"] = stResult["__redirectionURL"] & "/" & fuParam />
									</cfif>
								
									<!--- We can call any webskin in the viewstack if in ajax mode --->
									<cfif listcontainsnocase("page,any,data",stWS.viewstack) or findNoCase('ajaxmode',arguments.fuParameters)>
										<cfset stResult.view = stWS.methodname />
										<cfset fuVars = listdeleteat(fuVars,listfind(fuVars,"@pageview")) />
	
										<cfbreak />
									<cfelse>
										<!--- 
										The webskin is valid name but not a full page view so quick check to see if it is a valid bodyView, 
										if not...then it does not have the correct view stack descriptor.
										 --->
										<cfif not listcontainsnocase("body,any",stWS.viewstack)>
											<cfthrow message="This webskin (type:#stResult.type# & webskin:#stWS.methodname#) is not positioned in the view stack as page, body, any or ajax." />
										</cfif>
									</cfif>
								</cfif>
							</cfif>
						</cfcase>
						
						<cfcase value="@bodyview">
							<!--- Views can only be specified if the type is known... --->
							<cfif structKeyExists(stResult, "type") and len(stResult.type)>
							
								<cfset stWS = structNew() />
								
								<cfif structkeyexists(this.webskinFU[stResult.type],fuParam)>
									<cfset stWS = application.stCOAPI[stResult.type].stWebskins[this.webskinFU[stResult.type][fuParam]] />
								<cfelseif structkeyexists(application.stCOAPI[stResult.type].stWebskins,fuParam)>
									<cfset stWS = application.stCOAPI[stResult.type].stWebskins[fuParam] />
								</cfif>
								
								<cfif not structisempty(stWS)>
									<cfif structkeyexists(stResult,"__redirectionURL")>
										<cfset stResult["__redirectionURL"] = stResult["__redirectionURL"] & "/" & fuParam />
									</cfif>
									
									<cfif listcontainsnocase("body,any",stWS.viewstack)>
										<cfset stResult.bodyView = stWS.methodname />
										<cfset fuVars = listdeleteat(fuVars,listfind(fuVars,"@bodyview")) />
										
										<!--- Page view is always provided before body view --->
										<cfif listcontains(fuVars,"@pageview")>
											<cfset fuVars = listdeleteat(fuVars,listfind(fuVars,"@pageview")) />
										</cfif>
										
										<cfbreak />
									<cfelse>
										<cfthrow message="This webskin (type:#stResult.type# & webskin:#stWS.methodname#) is not positioned in the view stack as body or any." />
									</cfif>
								</cfif>
							</cfif>
						</cfcase>
						
						<cfcase value="@paramname"><!--- If we got to this item all other possible matches are complete --->
							<cfset stResult[fuParam] = "" />
							<cfset fuVars = fuParam /><!--- Next token will be the value of this variable --->
							<cfbreak />
						</cfcase>
						
						<cfdefaultcase><!--- This can only happen if the case "@paramname" sets a variable name --->
							<cfset stResult[paramType] = fuParam />
							<cfset fuVars = "@paramname" /><!--- Next token will be a parameter name --->
							
							<cfif structkeyexists(stResult,"__redirectionURL")>
								<cfset stResult["__redirectionURL"] = stResult["__redirectionURL"] & "/" & paramType & "/" & fuParam />
							</cfif>
							
							<cfbreak />
						</cfdefaultcase>
					</cfswitch>
				</cfloop>
			</cfloop>
		</cfif>
		
		<cfreturn stResult />
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

		<cfif structkeyexists(stObj,"typename") and isDefined("application.stCoapi.#stObj.typename#.bFriendly") AND application.stCoapi[stObj.typename].bFriendly>
		
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
	
	
	<cffunction name="deleteMapping" access="public" returntype="boolean" hint="Deletes an FU mapping from cache, and removes related record from the farFU table." output="false">
		<cfargument name="alias" required="yes" type="string">
		
		<cfset var qDelete	= '' />
		
		<cfquery datasource="#application.dsn#" name="qDelete">
		DELETE	
		FROM	#application.dbowner#farFU 				
		WHERE	friendlyURL = <cfqueryparam value="#arguments.alias#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfset cacheURLStructByURL(arguments.alias,structnew()) />

		<cfreturn true>
	</cffunction>
	
	
	<cffunction name="deleteAll" access="public" returntype="boolean" hint="Deletes all mappings and writes the map file to disk" output="No">
		
		<cfset var stLocal = structNew() />
		<!--- <cfset var mappings = getMappings()>
		<cfset var dom = "">
		<cfset var i = ""> --->
		<!--- loop over all entries and delete those that match domain --->
		
		<cfquery datasource="#application.dsn#" name="stLocal.qDelete">
		DELETE	
		FROM	#application.dbowner#farFU
		WHERE	fuStatus != 2
		</cfquery>
		
		<cfset initialiseMappings() />
		
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

			<cfif stLocal.lNavID NEQ "" AND arguments.objectid NEQ application.fapi.getNavID('home')>
				<!--- optimisation: get all dmnavgiation data to avoid a getData() call --->
				<cfquery name="stLocal.qListNavAlias" datasource="#application.dsn#">
		    	SELECT	dm.objectid, dm.label, dm.fu 
		    	FROM	#application.dbowner#dmNavigation dm, #application.dbowner#nested_tree_objects nto
		    	WHERE	dm.objectid = nto.objectid
		    			AND dm.objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#stLocal.lNavID#" />)
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

		<cfif arguments.objectid eq application.fapi.getNavID('home')>
			<cfset breadcrumb = "" /><!--- application.fapi.getConfig("fusettings","urlpattern") --->
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
		<cfset var qNav = application.factory.oTree.getDescendants(objectid=application.fapi.getNavID('home'), depth=50)>
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
		<!--- custom replacement of country specific chars BEFORE other standard replacements --->
		<cfset newAlias = replaceCountrySpecificChars(FUstring="#newAlias#") />
		
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
		<!--- <cfloop list="#application.fapi.getConfig("fusettings","domains")#" index="dom"> --->
			<cfset setMapping(alias=newAlias,mapping="#application.url.conjurer#?objectid=#arguments.objectid#",querystring=arguments.querystring)>
		<!--- </cfloop> --->
		<!--- <cfset updateAppScope()> --->
	</cffunction>
	
	<cffunction name="getFU" access="public" returntype="string" hint="Retrieves fu for a real url, returns original ufu if non existent." output="false" bDocument="true">
		<cfargument name="objectid" required="false" type="string" default="" hint="objectid of object to link to">
		<cfargument name="type" required="false" type="string" default="" hint="typename of object to link to">
		<cfargument name="view" required="false" type="string" default="" hint="view used to render the page layout">
		<cfargument name="bodyView" required="false" type="string" default="" hint="view used to render the body content">
		<cfargument name="ampDelim" required="false" type="string" default="&amp;" hint="The string to use for query string delimiters" />

		<cfset var returnURL = "">
		
		<cfset var typeFU = "" />
		<cfset var viewFU = "" />
		<cfset var bodyFU = "" />
		<cfset var thistype = "" />
		<cfset var stBodyView = "" />
		<cfset var stView = "" />
		<cfset var bMustUseRegularURLParams = false />
		<cfset var qLookup = "" />
		<cfset var stFUObject	= '' />
		<cfset var id = "" />
		
		<cfif len(arguments.type)>
			<cfif isdefined("application.stCOAPI.#arguments.type#.fuAlias") and len(application.stCOAPI[arguments.type].fuAlias)>
				
				<cfif getExistsTypeFU(arguments.type)>
					<cfset typeFU = arguments.type />
				<cfelse>
					<cfset typeFU = application.stCOAPI[arguments.type].fuAlias />
				</cfif>
				
			<cfelse>
				<cfset typeFU = arguments.type />
			</cfif>
			<cfset thistype = arguments.type />
		<cfelseif len(arguments.objectid)>
			<cfset thistype = application.fapi.findType(arguments.objectid) />
		</cfif>
		<cfif len(arguments.view)>
			<cfset stView = application.coapi.coapiadmin.getWebskin(thistype, arguments.view) />
			<cfif len(thistype) and structKeyExists(stView, "fuAlias") and len(stView.fuAlias)>
				<cfset viewFU = stView.fuAlias />
			<cfelse>
				<cfset viewFU = arguments.view />
			</cfif>
			<!--- If we have defined the view, and not the bodyView and the view is not set to page, then in order for the URL Parsing to work, we MUST explicitly tell the url that the webskin is for the view --->
			<cfif not structKeyExists(stView, "viewStack") OR not listFind("page,any,data", stView.viewStack)>
				<cfif not len(arguments.bodyView)>
					<cfset bMustUseRegularURLParams = true />
				</cfif>
			</cfif>
		</cfif>
		<cfif len(arguments.bodyView)>
			<cfset stBodyView = application.coapi.coapiadmin.getWebskin(thistype, arguments.bodyView) />
			<cfif len(thistype) and structKeyExists(stBodyView, "fuAlias") and len(stBodyView.fuAlias)>
				<cfset bodyFU = stBodyView.fuAlias />
			<cfelse>
				<cfset bodyFU = arguments.bodyView />
			</cfif>
			
			<!--- If we have defined the bodyView and NOT the view, then in order for the URL Parsing to work, we MUST explicitly tell the url that the bodyView webskin is for the bodyView --->
			<cfif structKeyExists(stBodyView, "viewStack") AND stBodyView.viewStack NEQ "body">
				<cfif not len(arguments.view)>
					<cfset bMustUseRegularURLParams = true />
				</cfif>
			</cfif>
		</cfif>

		<cfif application.fc.factory.farFU.isUsingFU()>
			
			<cfif len(arguments.objectid) AND len(thistype)>

				<cfif structKeyExists(application.stcoapi, thistype) AND structKeyExists(application.stcoapi[thistype],"bFriendly") AND application.stcoapi[thistype].bFriendly>
					
					<cfset stFUObject = getFUStructByObjectID(arguments.objectid) />

					<!--- IF WE FOUND AN FU, THE USE IT, OTHERWISE START THE URL SYNTAX --->
					<cfif NOT structIsEmpty(stFUObject)>
						<cfset returnURL = "#stFUObject.friendlyURL#">
					</cfif>

				</cfif>

				<cfif not len(returnURL)>
					
					<cfif len(arguments.type)>							
						<cfset returnURL = "/#typeFU#" />
					</cfif>
					
					<cfset returnURL = "#returnURL#/#arguments.objectid#">

				</cfif>


			<cfelseif len(typeFU)>
				<cfset returnURL = "/#typeFU#" />			
			</cfif>
			
			<!---------------------------------------------------------------------
			 IF WE HAVE OUR OTHER URL SYNTAX ATTRIBUTES, APPEND THEM TO THE URL
			 --------------------------------------------------------------------->			
			<cfif len(arguments.type) OR  len(arguments.view) OR len(arguments.bodyView)>
				
				<!--- The home page can't have implied parameters --->
				<cfif returnURL eq "/">
					<cfset returnURL = "/?" />
				</cfif>
				
				<!--- If we must use regular URL parameters, then make sure we have the ? --->
				<cfif bMustUseRegularURLParams>
					<cfif NOT FindNoCase("?", returnURL)>
						<cfset returnURL = "#returnURL#?" />
					</cfif>
				</cfif>
				
				<!--- IF OUR URL ALREADY CONTAINS A QUESTION MARK, THEN WE MUST USE REGULAR URL VARIABLES  --->
				<cfif FindNoCase("?", returnURL)>
					<cfif len(arguments.view)>
						<cfset returnURL = "#returnURL##arguments.ampDelim#view=#viewFU#" />
					</cfif>
					<cfif len(arguments.bodyView)>
						<cfset returnURL = "#returnURL##arguments.ampDelim#bodyView=#bodyFU#" />
					</cfif>
				<cfelse>
					<!--- OTHERWISE WE CAN USE THE URL SYNTAX OF /OBJECTID/TYPE/VIEW/BODYVIEW --->
					<cfif len(arguments.view)>
						<cfset returnURL = "#returnURL#/#viewFU#" />
					</cfif>
					<cfif len(arguments.bodyView)>
						<cfset returnURL = "#returnURL#/#bodyFU#" />
					</cfif>		
				</cfif>
			</cfif>			
			
		<!------------------------------------------------------------------------------------------ 
		WE ARE NOT USING FRIENDLY URLS SO SIMPLY SETUP THE URL STRING WITH THE ARGUMENTS PASSED IN
		 ------------------------------------------------------------------------------------------>
		<cfelse>			
			<cfset returnURL = "/index.cfm?" />
			
			<cfif len(arguments.type)>
				<cfset returnURL = "#returnURL##arguments.ampDelim#type=#typeFU#" />
			</cfif>
			<cfif len(arguments.objectid)>
				<cfset returnURL = "#returnURL##arguments.ampDelim#objectid=#arguments.objectid#" />
			</cfif>
			<cfif len(arguments.view)>
				<cfset returnURL = "#returnURL##arguments.ampDelim#view=#viewFU#" />
			</cfif>
			<cfif len(arguments.bodyView) and not listcontainsnocase("displayBody,displayTypeBody",arguments.bodyView)>
				<cfset returnURL = "#returnURL##arguments.ampDelim#bodyView=#bodyFU#" />
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
		<cfcase value="postgresql">					
			<cfquery datasource="#application.dsn#" name="stLocal.qList">
			SELECT	u.*
			FROM	#application.dbowner#farFU u, 
					#application.dbowner#refObjects r
			WHERE	r.objectid = u.refobjectid
					AND u.refobjectid = <cfqueryparam value="#arguments.objectid#" cfsqltype="cf_sql_varchar">
					AND u.fuStatus IN (#stLocal.fuStatus#)
			ORDER BY fuStatus DESC
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery datasource="#application.dsn#" name="stLocal.qList">
			SELECT	u.*
			FROM	#application.dbowner#farFU u inner join 
					#application.dbowner#refObjects r on r.objectid = u.refobjectid
			WHERE	refobjectid = <cfqueryparam value="#arguments.objectid#" cfsqltype="cf_sql_varchar">
				AND fuStatus IN (<cfqueryparam value="#stLocal.fuStatus#" list="true" cfsqltype="cf_sql_integer">)
			ORDER BY fuStatus DESC
			</cfquery>
		</cfdefaultcase>
		</cfswitch>
		
		<cfreturn stLocal.qList>
		
	</cffunction>

	<cffunction name="setData" access="public" output="false" returntype="struct" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
		<cfargument name="bSessionOnly" type="string" required="false" default="false">
		
		<!--- We need to make sure we update our stDBLookup anytime we save an FU --->
		<cfif structKeyExists(arguments.stProperties, "friendlyURL") AND listlen(arguments.stProperties.friendlyURL, "/") eq 1>
			<cfset cacheExistsTypeFU(listgetat(arguments.stProperties.friendlyURL,1,"/"), true) />
		</cfif>
		
		<cfreturn super.setData(argumentCollection="#arguments#") />
	</cffunction>
	

	<cffunction name="getExistsTypeFU" access="public" output="false" returntype="boolean">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="bIgnoreCache" type="boolean" default="false" required="false" />

		<cfset var stResult = {} />
		<cfset var qLookup = "" />

		<cfif not arguments.bIgnoreCache>
			<cfset stResult = application.fc.lib.objectbroker.GetFromObjectBroker("exists-"&arguments.typename,"fuLookup") />
		</cfif>

		<cfif structIsEmpty(stResult)>
			<cfquery datasource="#application.dsn#" name="qLookup">
				select objectid, friendlyURL
				from farFU
				where friendlyURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="/#application.stCOAPI[arguments.typename].fuAlias#" />
			</cfquery>

			<cfif qLookup.recordcount>
				<cfset stResult = { exists=true } />
			<cfelse>
				<cfset stResult = { exists=false } />
			</cfif>

			<cfset cacheExistsTypeFU(arguments.typename,stResult.exists) />
		</cfif>

		<cfreturn stResult.exists />
	</cffunction>

	<cffunction name="cacheExistsTypeFU" access="public" output="false" returntype="boolean">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="data" type="boolean" required="true" />
		
		<cfset application.fc.lib.objectBroker.AddToObjectBroker({ exists=arguments.data },"fuLookup","exists-"&arguments.typename) />

		<cfreturn arguments.data />
	</cffunction>
	
	<cffunction name="getFUStructByObjectID" access="public" output="false" returntype="struct">
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="bIgnoreCache" type="boolean" default="false" required="false" />
		
		<cfset var stResult = "" />
		<cfset var qLookup = "" />

		<cfif not arguments.bIgnoreCache>
			<cfset stResult = application.fc.lib.objectbroker.GetFromObjectBroker("fu-"&arguments.objectid,"fuLookup") />
		</cfif>

		<cfif structIsEmpty(stResult)>
			<!--- GET FRIENDLY URL BASED ON THE OBJECTID --->					
			<cfset stResult = getDefaultFUObject(refObjectID=arguments.objectid,bIgnoreCache=true) />
			
			<!--- JUST IN CASE WE DONT HAVE A DEFAULT FU SET, USE THE SYSTEM OBJECT IF AVAILABLE --->
			<cfif structIsEmpty(stResult)>
				<cfset stResult = getSystemObject(refObjectID=arguments.objectid) />
			</cfif>

			<cfset stResult = cacheFUStructByObjectID(arguments.objectid,stResult) />
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="cacheFUStructByObjectID" access="public" output="false" returntype="struct">
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="data" type="struct" required="true" />
		
		<cfset application.fc.lib.objectBroker.AddToObjectBroker(arguments.data,"fuLookup","fu-"&arguments.objectid) />

		<cfreturn duplicate(arguments.data) />
	</cffunction>

	<cffunction name="getURLStructByURL" access="public" output="false" returntype="struct">
		<cfargument name="friendlyURL" type="string" required="true" />
		<cfargument name="bIgnoreCache" type="boolean" default="false" required="false" />
		
		<cfset var stReturnFU = StructNew()>
		<cfset var stLocal = StructNew()>
		<cfset var fuList = "" />
		<cfset var fuThis = "" />
		<cfset var fuToken = "" />
		<cfset var bParamName = 1 />
		<cfset var tmpFriendlyURL = "" />
		<cfset var stReturnFU = {} />

		<cfif not arguments.bIgnoreCache>
			<cfset stReturnFU = application.fc.lib.objectbroker.GetFromObjectBroker("us-" & hash(lcase(arguments.friendlyURL)),"fuLookup") />
		</cfif>
		
		<cfif structIsEmpty(stReturnFU)>
			<!--- Strongest match: the exact FU is in database ---> 
			<cfquery datasource="#application.dsn#" name="stLocal.qGet"> 
				SELECT		farFU.objectid as objectid,farFU.friendlyURL as friendlyURL,refObjects.typename as typename 
				FROM 		farFU 
							INNER JOIN 
							refObjects 
							on farFU.refobjectid = refObjects.objectid 
				WHERE		farFU.friendlyURL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.friendlyURL#" /> 
				ORDER BY 	farFU.bDefault DESC, farFU.fuStatus DESC 
			</cfquery>
			
			<cfif stLocal.qGet.recordcount>
				<cfset stReturnFU = cacheURLStructByURL(arguments.friendlyURL,createURLStruct(farFUID=stLocal.qGet.objectid[1],typename=stLocal.qGet.typename[1])) />
			</cfif>
		</cfif>
		
		<cfif structisempty(stReturnFU)>
			<!--- 
			Second strongest match: a part of the FU is in the database (matches against the start of the FU) 
				- Some old FU's have double slashes. This is to address some legacy situations where a double slash was included as part of the FU. We need to make sure the double slashes remain.
			--->
			
			<cfset tmpFriendlyURL = replaceNoCase(arguments.friendlyURL, "//", "+++", "all") />
			
			<cfloop list="#tmpFriendlyURL#" index="fuToken" delimiters="/">
				<cfif left(fuToken,3) eq "+++">
					<cfset fuThis = "#fuThis##replaceNoCase(fuToken, '+++', '//')#" />
				<cfelse>
					<cfset fuThis = "#fuThis#/#replaceNoCase(fuToken, '+++', '//')#" />
				</cfif>
				<cfset fuList = listappend(fuList,fuThis) />
			</cfloop>
			
			<cfquery datasource="#application.dsn#" name="stLocal.qGet">
				SELECT		objectid,friendlyURL
				FROM		#application.dbowner#farFU
				WHERE		friendlyURL in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#fuList#" />)
				ORDER BY 	friendlyURL desc, bDefault DESC, fuStatus DESC
			</cfquery>
			<cfif stLocal.qGet.recordcount>
				<cfset stReturnFU = cacheURLStructByURL(arguments.friendlyURL,createURLStruct(farFUID=stLocal.qGet.objectid[1],fuParameters=replacenocase(arguments.friendlyURL,stLocal.qGet.friendlyURL,""))) />
			</cfif>
		</cfif>
		
		<cfif structIsEmpty(stReturnFU)>
			<!--- Weakest match: the first fURL token is a UUID or a typename/type alias --->
			<cfif isvalid("uuid",listfirst(arguments.friendlyURL,"/")) 
					or structkeyexists(this.typeFU,listfirst(arguments.friendlyURL,"/")) 
					or structkeyexists(application.stCOAPI,listfirst(arguments.friendlyURL,"/"))>
				<cfset stReturnFU = cacheURLStructByURL(arguments.friendlyURL,createURLStruct(fuParameters=arguments.friendlyURL)) />
			</cfif>
		</cfif>
		
		<!--- No match - this is probably a 404 --->
		<cfreturn stReturnFU />
	</cffunction>

	<cffunction name="cacheURLStructByURL" access="public" output="false" returntype="struct">
		<cfargument name="friendlyURL" type="string" required="true" />
		<cfargument name="data" type="struct" required="true" />
		
		<cfset application.fc.lib.objectBroker.AddToObjectBroker(arguments.data,"fuLookup","us-" & hash(lcase(arguments.friendlyURL))) />

		<cfreturn duplicate(arguments.data) />
	</cffunction>

</cfcomponent>