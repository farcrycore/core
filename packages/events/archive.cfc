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
			<cfif request.mode.debug><cflog file="events" text="save #arguments.typename# #arguments.stProperties.objectid#: not archivable"></cfif>
			<cfreturn />
		</cfif>
		
		<!--- NEW CONTENT --->
		<cfif structkeyexists(stProps,"bDefaultObject")>
			<cfif request.mode.debug><cflog file="events" text="save #arguments.typename# #arguments.stProperties.objectid#: new object a"></cfif>
			<cfreturn />
		</cfif>
		
		
		<cfset stObj = arguments.oType.getData(objectid=arguments.stProperties.objectid,bUseInstanceCache=false) />
		<cfset structappend(stProps,stObj,false) />
		
		
		<!--- NEW CONTENT --->
		<cfif structkeyexists(stObj,"bDefaultObject")>
			<cfif request.mode.debug><cflog file="events" text="save #arguments.typename# #arguments.stProperties.objectid#: new object b"></cfif>
			<cfreturn />
		</cfif>
		
		<!--- DRAFT / PENDING --->
		<cfif structkeyexists(application.stCOAPI[arguments.typename].stProps,"status") and not (stProps.status eq "approved" and stObj.status eq "approved")>
			<cfif request.mode.debug><cflog file="events" text="save #arguments.typename# #arguments.stProperties.objectid#: draft / pending"></cfif>
			<cfreturn />
		</cfif>
		
		<!--- NO CHANGES --->
		<cfif application.fc.lib.diff.getObjectDiff(left=stObj,right=stProps,includeInvisibleProperties=true).countDifferent eq 0>
			<cfif request.mode.debug><cflog file="events" text="save #arguments.typename# #arguments.stProperties.objectid#: no changes"></cfif>
			<cfreturn />
		</cfif>
		
		
		<!--- Archivable --->
		<cfif arguments.auditNote eq "Archive rolled back">
			<cfif request.mode.debug><cflog file="events" text="save #arguments.typename# #arguments.stProperties.objectid#: archived, rollback"></cfif>
			<cfset this.oArchive.archiveObject(stObj=stObj,event="rolled back",username=lastupdatedby)>
		<cfelseif not structkeyexists(stObj,"versionID")>
			<cfif request.mode.debug><cflog file="events" text="save #arguments.typename# #arguments.stProperties.objectid#: archived, save"></cfif>
			<cfset this.oArchive.archiveObject(stObj=stObj,event="saved",username=lastupdatedby)>
		<cfelse>
			<cfif request.mode.debug><cflog file="events" text="save #arguments.typename# #arguments.stProperties.objectid#: archived, publish"></cfif>
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
			<cfif request.mode.debug><cflog file="events" text="delete #arguments.typename# #arguments.stObject.objectid#: already handled"></cfif>
			<cfreturn />
		</cfif>
		<cfparam name="request.deleted" default="" />
		<cfset request.deleted = listappend(request.deleted,arguments.stObject.objectid) />
		
		<!--- NOT ARCHIVABLE --->
		<cfif not application.stCOAPI[arguments.typename].bArchive>
			<cfif request.mode.debug><cflog file="events" text="delete #arguments.typename# #arguments.stObject.objectid#: not archivable"></cfif>
			<cfreturn />
		</cfif>
		
		<!--- OBJECT WITH APPROVED VERSION (drafts aren't archived) --->
		<cfif structkeyexists(arguments.stObject,"versionid") and len(arguments.stObject.versionID)>
			<cfif request.mode.debug><cflog file="events" text="delete #arguments.typename# #arguments.stObject.objectid#: has approved version"></cfif>
			<cfreturn />
		</cfif>
		
		
		<!--- Archivable - published --->
		<cfif not structkeyexists(arguments.stObject,"status") or arguments.stObject.status eq "approved">
			<cfif structkeyexists(arguments.stObject,"versionid")>
				<cfset q = application.fapi.getContentObjects(typename=arguments.typename,versionID_eq=arguments.stObject.objectid) />
				<cfif request.mode.debug><cflog file="events" text="delete #arguments.typename# #arguments.stObject.objectid#: archived, deleted=#q.recordcount eq 0#"></cfif>
				<cfset this.oArchive.archiveObject(stObj=arguments.stObject,event="deleted",username=arguments.user,bDeleted=q.recordcount eq 0)>
			<cfelse>
				<cfif request.mode.debug><cflog file="events" text="save #arguments.typename# #arguments.stObject.objectid#: archived"></cfif>
				<cfset this.oArchive.archiveObject(stObj=arguments.stObject,event="deleted",username=arguments.user,bDeleted=1)>
			</cfif>
				
			<cfreturn />
		</cfif>
		
		
		<!--- NOT VERSIONED --->
		<cfif not structkeyexists(arguments.stObject,"versionID") or not len(arguments.stObject.versionID)>
			<cfif request.mode.debug><cflog file="events" text="delete #arguments.typename# #arguments.stObject.objectid#: not versioned"></cfif>
			<cfreturn>
		</cfif>
		
		<!--- Special case: there was a draft and approved version, the approved version was deleted, then the draft version - now the latest archive needs to be flagged bDeleted = true --->
		<cfset q = application.fapi.getContentObjects(typename=arguments.stObject.typename,objectid_eq=arguments.stObject.versionid) />
		<cfif q.recordcount eq 0>
			<cfif request.mode.debug><cflog file="events" text="delete #arguments.typename# #arguments.stObject.objectid#: set bDeleted=false"></cfif>
			
			<cfset q = application.fapi.getContentObjects(typename="dmArchive",versionid_eq=arguments.stObject.versionid,orderby="datetimecreated desc",maxrows=1) />
			
			<cfset stArchive = structnew() />
			<cfset stArchive.typename = "dmArchive" />
			<cfset stArchive.objectid = q.objectid />
			<cfset stArchive.bDeleted = true />
			<cfset application.fapi.setData(stProperties=stNew) />
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
			<cfif request.mode.debug><cflog file="events" text="status changed #arguments.typename# #arguments.stObject.objectid#: not archivable"></cfif>
			<cfreturn />
		</cfif>
		
		<!--- NO STATUS --->
		<cfif not structkeyexists(application.stCOAPI[arguments.typename].stProps,"status")>
			<cfif request.mode.debug><cflog file="events" text="status changed #arguments.typename# #arguments.stObject.objectid#: no status"></cfif>
			<cfreturn />
		</cfif>
		
		<!--- NEW OBJECT --->
		<cfif structkeyexists(arguments.stObject,"bDefaultObject")>
			<cfif request.mode.debug><cflog file="events" text="status changed #arguments.typename# #arguments.stObject.objectid#: new object a"></cfif>
			<cfreturn />
		</cfif>
		
		
		<cfset stObj = arguments.oType.getData(objectid=arguments.stObject.objectid,bUseInstanceCache=false) />
		
		
		<!--- NEW OBJECT --->
		<cfif structkeyexists(stObj,"bDefaultObject")>
			<cfif request.mode.debug><cflog file="events" text="status changed #arguments.typename# #arguments.stObject.objectid#: new object b"></cfif>
			<cfreturn />
		</cfif>
		
		<!--- WASN'T SENT BACK TO DRAFT --->
		<cfif arguments.newStatus neq "draft">
			<cfif request.mode.debug><cflog file="events" text="status changed #arguments.typename# #arguments.stObject.objectid#: not sent back to draft"></cfif>
			<cfreturn />
		</cfif>
		
		<!--- THIS IS A DRAFT COPY OF AN APPROVED OBJECT --->
		<cfif structkeyexists(stObj,"versionID") and arguments.stObject.versionID neq "">
			<cfif request.mode.debug><cflog file="events" text="status changed #arguments.typename# #arguments.stObject.objectid#: draft version"></cfif>
			<cfreturn />
		</cfif>
		
		
		<!--- Archivable --->
		<cfif request.mode.debug><cflog file="events" text="status changed #arguments.typename# #arguments.stObject.objectid#: archived"></cfif>
		<cfset this.oArchive.archiveObject(stObj=stObj,event="unpublished",username=arguments.stObject.lastupdatedby) />
	</cffunction>
	
</cfcomponent>