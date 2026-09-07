<cfcomponent displayname="Archive" hint="Content archive functionality" output="false" component="fcTypes">
	
	<!--- The basic rule is: if publicly visible content is changed, archive first --->
	
	<cffunction name="beforesave" access="public" output="false" hint="Invoked immediately before DB is updated">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="oType" type="any" required="true" hint="A CFC instance of the object type" />
		<cfargument name="stProperties" type="struct" required="true" hint="The object" />
		<cfargument name="auditNote" type="string" required="true" />
		<cfargument name="bAudit" type="boolean" required="true" hint="Pass in 0 if you wish no audit to take place">
		
		<cfset var stObj = "" />
		<cfset var stProps = duplicate(arguments.stProperties) />
		<cfset var lastupdatedby = "">

		<!--- nothing to archive when an update app is happening --->
		<cfif NOT isDefined("application.bInit") OR application.bInit eq false>
			<cfreturn />
		</cfif>
		
		<!--- DON'T AUDIT === DON'T ARCHIVE --->
		<cfif not arguments.bAudit>
			<cfreturn />
		</cfif>
		
		<cfif structKeyExists(arguments.stProperties, "lastupdatedby") AND len(arguments.stProperties.lastupdatedby)>
			<cfset lastupdatedby = arguments.stProperties.lastupdatedby>
		<cfelse>	
			<cfif application.security.isLoggedIn()>
				<cfset lastupdatedby = application.security.getCurrentUserID()>
			<cfelse>
				<cfset lastupdatedby = "Unknown">
			</cfif>
		</cfif>

		<cfif not structkeyexists(this,"oArchive")>
			<cfset this.oArchive = application.fapi.getContentType("dmArchive") />
		</cfif>
		
		<!--- NOT ARCHIVABLE --->
		<cfif not application.stCOAPI[arguments.typename].bArchive>
			<cfset application.fapi.logEvent("events", "debug", "save: not archivable", {typename=arguments.typename, objectid=arguments.stProperties.objectid}) />
			<cfreturn />
		</cfif>
		
		<!--- NEW CONTENT --->
		<cfif structkeyexists(stProps,"bDefaultObject")>
			<cfset application.fapi.logEvent("events", "debug", "save: new object a", {typename=arguments.typename, objectid=arguments.stProperties.objectid}) />
			<cfreturn />
		</cfif>
		
		
		<cfset stObj = arguments.oType.getData(objectid=arguments.stProperties.objectid,bUseInstanceCache=false) />
		<cfset structappend(stProps,stObj,false) />
		
		
		<!--- NEW CONTENT --->
		<cfif structkeyexists(stObj,"bDefaultObject")>
			<cfset application.fapi.logEvent("events", "debug", "save: new object b", {typename=arguments.typename, objectid=arguments.stProperties.objectid}) />
			<cfreturn />
		</cfif>
		
		<!--- DRAFT / PENDING --->
		<cfif structkeyexists(application.stCOAPI[arguments.typename].stProps,"status") and not (stProps.status eq "approved" and stObj.status eq "approved")>
			<cfset application.fapi.logEvent("events", "debug", "save: draft / pending", {typename=arguments.typename, objectid=arguments.stProperties.objectid}) />
			<cfreturn />
		</cfif>
		
		<!--- NO CHANGES --->
		<cfif application.fc.lib.diff.getObjectDiff(left=stObj,right=stProps,includeInvisibleProperties=true).countDifferent eq 0>
			<cfset application.fapi.logEvent("events", "debug", "save: no changes", {typename=arguments.typename, objectid=arguments.stProperties.objectid}) />
			<cfreturn />
		</cfif>
		
		
		<!--- Archivable --->
		<cfif arguments.auditNote eq "Archive rolled back">
			<cfset application.fapi.logEvent("events", "debug", "save: archived, rollback", {typename=arguments.typename, objectid=arguments.stProperties.objectid}) />
			<cfset this.oArchive.archiveObject(stObj=stObj,event="rolled back",username=lastupdatedby)>
		<cfelseif not structkeyexists(stObj,"versionID")>
			<cfset application.fapi.logEvent("events", "debug", "save: archived, save", {typename=arguments.typename, objectid=arguments.stProperties.objectid}) />
			<cfset this.oArchive.archiveObject(stObj=stObj,event="saved",username=lastupdatedby)>
		<cfelse>
			<cfset application.fapi.logEvent("events", "debug", "save: archived, publish", {typename=arguments.typename, objectid=arguments.stProperties.objectid}) />
			<cfset this.oArchive.archiveObject(stObj=stObj,event="published",username=lastupdatedby)>
		</cfif>
	</cffunction>
	
	<cffunction name="beforedelete" access="public" hint="I am invoked when a content object has been deleted">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="oType" type="any" required="true" hint="A CFC instance of the object type" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		<cfargument name="user" type="string" required="true" />
		<cfargument name="auditNote" type="string" required="true" />
		
		<cfset var archivable = application.stCOAPI[arguments.typename].bArchive />
		<cfset var hasstatus = false />
		<cfset var published = false />
		<cfset var hasdraft = false />
		<cfset var hasversion = false />
		<cfset var stArchive = "" />
		<cfset var q = "" />
		
		<cfif not structkeyexists(this,"oArchive")>
			<cfset this.oArchive = application.fapi.getContentType("dmArchive") />
		</cfif>
		
		<!--- IN SOME CASES FARCRY NEEDS TO MANUALLY TRIGGER THIS EVENT EARLIER, CAUSING IT TO HAPPEN TWICE - PREVENT ANY AFTER THE FIRST --->
		<cfif structkeyexists(request,"deleted") and listfind(request.deleted,arguments.stObject.objectid)>
			<cfset application.fapi.logEvent("events", "debug", "delete: already handled", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn />
		</cfif>
		<cfparam name="request.deleted" default="" />
		<cfset request.deleted = listappend(request.deleted,arguments.stObject.objectid) />
		
		<!--- NOT ARCHIVABLE --->
		<cfif not application.stCOAPI[arguments.typename].bArchive>
			<cfset application.fapi.logEvent("events", "debug", "delete: not archivable", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn />
		</cfif>
		
		<!--- OBJECT WITH APPROVED VERSION (drafts aren't archived) --->
		<cfif structkeyexists(arguments.stObject,"versionid") and len(arguments.stObject.versionID)>
			<cfset application.fapi.logEvent("events", "debug", "delete: has approved version", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn />
		</cfif>
		
		
		<!--- Archivable - published --->
		<cfif not structkeyexists(arguments.stObject,"status") or arguments.stObject.status eq "approved">
			<cfif structkeyexists(arguments.stObject,"versionid")>
				<cfset q = application.fapi.getContentObjects(typename=arguments.typename,versionID_eq=arguments.stObject.objectid) />
				<cfset application.fapi.logEvent("events", "debug", "delete: archived", {typename=arguments.typename, objectid=arguments.stObject.objectid, deleted=(q.recordcount eq 0)}) />
				<cfset this.oArchive.archiveObject(stObj=arguments.stObject,event="deleted",username=arguments.user,bDeleted=q.recordcount eq 0)>
			<cfelse>
				<cfset application.fapi.logEvent("events", "debug", "save: archived", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
				<cfset this.oArchive.archiveObject(stObj=arguments.stObject,event="deleted",username=arguments.user,bDeleted=1)>
			</cfif>
				
			<cfreturn />
		</cfif>
		
		
		<!--- NOT VERSIONED --->
		<cfif not structkeyexists(arguments.stObject,"versionID") or not len(arguments.stObject.versionID)>
			<cfset application.fapi.logEvent("events", "debug", "delete: not versioned", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn>
		</cfif>
		
		<!--- Special case: there was a draft and approved version, the approved version was deleted, then the draft version - now the latest archive needs to be flagged bDeleted = true --->
		<cfset q = application.fapi.getContentObjects(typename=arguments.stObject.typename,objectid_eq=arguments.stObject.versionid) />
		<cfif q.recordcount eq 0>
			<cfset application.fapi.logEvent("events", "debug", "delete: set bDeleted=false", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			
			<cfset q = application.fapi.getContentObjects(typename="dmArchive",versionid_eq=arguments.stObject.versionid,orderby="datetimecreated desc",maxrows=1) />
			
			<cfset stArchive = structnew() />
			<cfset stArchive.typename = "dmArchive" />
			<cfset stArchive.objectid = q.objectid />
			<cfset stArchive.bDeleted = true />
			<cfset application.fapi.setData(stProperties=stArchive) />
		</cfif>
	</cffunction>
	
	<cffunction name="statusChanged" access="public" hint="I am invoked when a content object has been deleted">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="oType" type="any" required="true" hint="A CFC instance of the object type" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		<cfargument name="newStatus" type="string" required="true" />
		<cfargument name="previousStatus" type="string" required="true" />
		<cfargument name="auditNote" type="string" required="true" />
		
		<cfset var stObj = "" />
		
		<cfif not structkeyexists(this,"oArchive")>
			<cfset this.oArchive = application.fapi.getContentType("dmArchive") />
		</cfif>
		
		<!--- NOT ARCHIVABLE --->
		<cfif not application.stCOAPI[arguments.typename].bArchive>
			<cfset application.fapi.logEvent("events", "debug", "status changed: not archivable", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn />
		</cfif>
		
		<!--- NO STATUS --->
		<cfif not structkeyexists(application.stCOAPI[arguments.typename].stProps,"status")>
			<cfset application.fapi.logEvent("events", "debug", "status changed: no status", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn />
		</cfif>
		
		<!--- NEW OBJECT --->
		<cfif structkeyexists(arguments.stObject,"bDefaultObject")>
			<cfset application.fapi.logEvent("events", "debug", "status changed: new object a", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn />
		</cfif>
		
		
		<cfset stObj = arguments.oType.getData(objectid=arguments.stObject.objectid,bUseInstanceCache=false) />
		
		
		<!--- NEW OBJECT --->
		<cfif structkeyexists(stObj,"bDefaultObject")>
			<cfset application.fapi.logEvent("events", "debug", "status changed: new object b", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn />
		</cfif>
		
		<!--- WASN'T SENT BACK TO DRAFT --->
		<cfif arguments.newStatus neq "draft">
			<cfset application.fapi.logEvent("events", "debug", "status changed: not sent back to draft", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn />
		</cfif>
		
		<!--- THIS IS A DRAFT COPY OF AN APPROVED OBJECT --->
		<cfif structkeyexists(stObj,"versionID") and arguments.stObject.versionID neq "">
			<cfset application.fapi.logEvent("events", "debug", "status changed: draft version", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
			<cfreturn />
		</cfif>
		
		
		<!--- Archivable --->
		<cfset application.fapi.logEvent("events", "debug", "status changed: archived", {typename=arguments.typename, objectid=arguments.stObject.objectid}) />
		<cfset this.oArchive.archiveObject(stObj=stObj,event="unpublished",username=arguments.stObject.lastupdatedby) />
	</cffunction>
	
</cfcomponent>