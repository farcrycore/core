<cfcomponent displayname="Archive" hint="Archive tests" extends="farcry.plugins.testMXUnit.tests.FarcryTestCase" output="false">
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfset var stObj = structnew() />
		
		<cfset super.setUp() />
		
		<cfset this.thread = CreateObject("java", "java.lang.Thread") />
		
		<cfset pinObjects(typename="dmNavigation",title="Undelete") />
		<cfset pinScope(variable="application.navid") />
		<cfset pinScope(variable="application.catid") />
		
		<cfset createTemporaryCategory(alias="archivetest",parentid=application.catid.root) />
		
		<!--- Profile --->
		<cfset this.testProfile = createuuid() />
		<cfset pinObjects(typename="dmArchive",archiveID=this.testProfile) />
		<cfset pinObjects(typename="farFU",refobjectid=this.testProfile) />
		<cfset createTemporaryObject(typename="dmProfile",objectid=this.testProfile,username="archive_TEST",firstname="Archive",lastname="Test",label="Archive Test") />
		
		<!--- Approved Include --->
		<cfset this.testIncludeApproved = createuuid() />
		<cfset pinObjects(typename="dmArchive",archiveID=this.testIncludeApproved) />
		<cfset pinObjects(typename="farFU",refobjectid=this.testIncludeApproved) />
		<cfset createTemporaryObject(typename="dmInclude",objectid=this.testIncludeApproved,status="approved",title="Archive",label="Archive",catInclude=application.catid.root,categories=application.catid.root) />
		
		<!--- Draft Include --->
		<cfset this.testIncludeDraft = createuuid() />
		<cfset pinObjects(typename="dmArchive",archiveID=this.testIncludeDraft) />
		<cfset pinObjects(typename="farFU",refobjectid=this.testIncludeDraft) />
		<cfset createTemporaryObject(typename="dmInclude",objectid=this.testIncludeDraft,status="draft",title="Archive 1",label="Archive 1") />
		
		<!--- Approved HTML --->
		<cfset this.testHTMLApproved = createuuid() />
		<cfset pinObjects(typename="dmArchive",archiveID=this.testHTMLApproved) />
		<cfset pinObjects(typename="dmHTML",versionID=this.testHTMLApproved) />
		<cfset pinObjects(typename="farFU",refobjectid=this.testHTMLApproved) />
		<cfset createTemporaryObject(typename="dmHTML",objectid=this.testHTMLApproved,status="approved",title="Archive",label="Archive") />
		
		<!--- Draft HTML --->
		<cfset this.testHTMLDraft = createuuid() />
		<cfset pinObjects(typename="dmArchive",archiveID=this.testHTMLDraft) />
		<cfset pinObjects(typename="dmHTML",versionID=this.testHTMLDraft) />
		<cfset pinObjects(typename="farFU",refobjectid=this.testHTMLDraft) />
		<cfset pinObjects(typename="dmNavigation",objectid=application.navid.home) />
		<cfset createTemporaryObject(typename="dmHTML",objectid=this.testHTMLDraft,status="draft",title="Archive 1",label="Archive 1") />
		
		<!--- Approved Navigation --->
		<cfset this.testNavigationApproved = createuuid() />
		<cfset this.testNavigationChild = createuuid() />
		<cfset this.testNavigationLeaf = createuuid() />
		<cfset pinObjects(typename="dmArchive",archiveID=this.testNavigationApproved) />
		<cfset pinObjects(typename="dmArchive",archiveID=this.testNavigationChild) />
		<cfset pinObjects(typename="farFU",refobjectid=this.testNavigationApproved) />
		<cfset pinObjects(typename="farFU",refobjectid=this.testNavigationChild) />
		<cfset createTemporaryNavigation(typename="dmNavigation",objectid=this.testNavigationApproved,status="approved",title="Archive",label="Archive",aObjectIDs=listtoarray(this.testNavigationLeaf),parentid=application.navid.home) />
		<cfset createTemporaryNavigation(typename="dmNavigation",objectid=this.testNavigationChild,status="approved",title="Child",label="Child",parentid=this.testNavigationApproved) />
		<cfset createTemporaryObject(typename="dmHTML",objectid=this.testNavigationLeaf,status="approved",title="Leaf",label="Leaf") />
		
	</cffunction>
	
	<cffunction name="tearDown" returntype="void" access="public">
		
		<cfset var startsetup = gettickcount()>
		<cfset super.tearDown() />
		<cflog file="test" text="teardown: #getTickcount()-startsetup#ms">
	</cffunction>
	
	
	<!--- SIMPLE CONTENT --->
	<cffunction name="basic_edit" displayname="Basic Object - Edit" hint="Check that an archive is created after saving a basic content object" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmProfile",objectid=this.testProfile) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset stObj.firstname = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmProfile",objectid=this.testProfile,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testProfile,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testProfile) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("saved",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmProfile",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(0,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Archive",stArchive.firstname,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="basic_delete" displayname="Basic Object - Delete" hint="Check that an archive is created after deleting a basic content object" returntype="void" access="public">
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset application.fapi.getContentType(typename="dmProfile").delete(objectid=this.testProfile) />
		
		<cfset assertNotObjectExists(typename="dmProfile",objectid=this.testProfile,timeframe=120,message="The database contains the deleted content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testProfile,timeframe=120,message="The database does not contain an archive for the deleted object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testProfile) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("deleted",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmProfile",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(1,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Archive",stArchive.firstname,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="basic_rollback" displayname="Basic Object - Rollback" hint="Check that an archive is created and the object is updated after a rollback" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmProfile",objectid=this.testProfile) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset stObj.firstname = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset this.thread.sleep(1000) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testProfile,orderby="datetimecreated desc") />
		<cfset application.fapi.getContentType("dmArchive").rollbackArchive(objectid=this.testProfile,archiveID=q.objectid[1],typename="dmProfile")>
		
		<cfset assertObjectExists(typename="dmProfile",objectid=this.testProfile,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testProfile,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testProfile,orderby="datetimecreated desc") />
		<cfset assertEquals(2,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("rolled back",q.event[1],"Incorrect archive event") />
		<cfset assertEquals("dmProfile",q.objectTypename[1],"Incorrect archive typename") />
		<cfset assertEquals(0,q.bDeleted[1],"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username[1],"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress[1],"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles[1],"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX[1],"","Archive is empty") />
		
		<cfwddx action="wddx2cfml" input="#q.objectWDDX[1]#" output="stArchive" />
		<cfset assertEquals("Hello world",stArchive.firstname,"Archive does not contain the previous values") />
		
		<cfset stObj = application.fapi.getContentObject(typename="dmProfile",objectid=this.testProfile) />
		<cfset assertEquals("Archive",stObj.firstname,"Incorrect restored firstname") />
	</cffunction>
	
	<cffunction name="basic_undelete" displayname="Basic Object - Undelete" hint="Check that the bDeleted flag is removed after rolling back a deleted object" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmProfile",objectid=this.testProfile) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		<cfset var aResult = arraynew(1) />
		
		<cfset application.fapi.getContentType(typename="dmProfile").delete(objectid=this.testProfile) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testProfile,orderby="datetimecreated desc") />
		<cfset aResult = application.fapi.getContentType("dmArchive").undeleteArchive(archiveID=q.objectid[1])>
		
		<cfset assertEquals(1,arraylen(aResult),"Unexpected number of undeleted objects") />
		<cfset assertObjectExists(typename="dmProfile",objectid=this.testProfile,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testProfile,timeframe=120,message="The database does not contain an archive for the edited object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testProfile,bDeleted=1,timeframe=120,message="The database contains an archive with the bDeleted flag") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testProfile,orderby="datetimecreated desc") />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		
		<cfset stObj = application.fapi.getContentObject(typename="dmProfile",objectid=this.testProfile) />
		<cfset assertEquals("Archive",stObj.firstname,"Incorrect restored firstname") />
	</cffunction>
	
	
	<!--- CONTENT WITH STATUS BUT NOT VERSIONS --->
	<cffunction name="status_editdraft" displayname="Object With Status - Edit draft" hint="Check that an archive is not created after editing a draft object with status" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmInclude",objectid=this.testIncludeDraft) />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmInclude",objectid=this.testIncludeDraft,timeframe=120,message="The database does not contain the content object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testIncludeDraft,timeframe=120,message="The database contains an archive for the edited object") />
	</cffunction>
	
	<cffunction name="status_editapproved" displayname="Object With Status - Edit approved" hint="Check that an archive is created after editing an approved object with status" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmInclude",objectid=this.testIncludeApproved) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmInclude",objectid=this.testIncludeApproved,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testIncludeApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testIncludeApproved) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("saved",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmInclude",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(0,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Archive",stArchive.title,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="status_unpublish" displayname="Object With Status - Unpublish" hint="Check that an archive is created after unpublishing an object with status" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmInclude",objectid=this.testIncludeApproved) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset stObj.status = "draft" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmInclude",objectid=this.testIncludeApproved,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testIncludeApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testIncludeApproved) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("unpublished",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmInclude",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(0,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Archive",stArchive.title,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="status_publish" displayname="Object With Status - Publish" hint="Check that an archive is not created after publishing an object with status" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmInclude",objectid=this.testIncludeDraft) />
		
		<cfset stObj.status = "approved" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmInclude",objectid=this.testIncludeDraft,timeframe=120,message="The database does not contain the content object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testIncludeDraft,timeframe=120,message="The database contains an archive for the edited object") />
	</cffunction>
	
	<cffunction name="status_deletedraft" displayname="Object With Status - Delete draft" hint="Check that an archive is created after deleting a draft object" returntype="void" access="public">
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset application.fapi.getContentType(typename="dmInclude").delete(objectid=this.testIncludeDraft) />
		
		<cfset assertNotObjectExists(typename="dmInclude",objectid=this.testIncludeDraft,timeframe=120,message="The database contains the deleted content object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testIncludeDraft,timeframe=120,message="The database does not contain an archive for the edited object") />
	</cffunction>
	
	<cffunction name="status_deleteapproved" displayname="Object With Status - Delete approved" hint="Check that an archive is created after deleting an approved object" returntype="void" access="public">
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset application.fapi.getContentType(typename="dmInclude").delete(objectid=this.testIncludeApproved) />
		
		<cfset assertNotObjectExists(typename="dmInclude",objectid=this.testIncludeApproved,timeframe=120,message="The database contains the deleted content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testIncludeApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testIncludeApproved) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("deleted",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmInclude",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(1,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Archive",stArchive.title,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="status_rollback" displayname="Object With Status - Rollback" hint="Check that an archive is created and the object is updated after a rollback" returntype="void" access="public" dependsOn="status_editapproved,metadata_categories">
		<cfset var stObj = application.fapi.getContentObject(typename="dmInclude",objectid=this.testIncludeApproved) />
		<cfset var q = "" />
		
		<cfset stObj.title = "Hello world" />
		<cfset stObj.catInclude = application.catid.archivetest />
		<cfset createobject("component","farcry.core.packages.farcry.category").assignCategories(objectid=stObj.objectid,lCategoryIDs=application.catid.archivetest,alias="root") />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset this.thread.sleep(1000) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testIncludeApproved,orderby="datetimecreated desc") />
		<cfset a = application.fapi.getContentType("dmArchive").rollbackArchive(objectid=this.testIncludeApproved,archiveID=q.objectid[1],typename="dmInclude")>
		
		<cfset assertObjectExists(typename="dmInclude",objectid=this.testIncludeApproved,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testIncludeApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = createobject("component","farcry.core.packages.farcry.category").getCategories(objectid=this.testIncludeApproved) />
		<cfset assertEquals("root",q,"Restored content is associated with unexpected categories") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testIncludeApproved,orderby="datetimecreated desc") />
		<cfset assertEquals(2,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("rolled back",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmInclude",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(0,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Hello world",stArchive.title,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="status_undelete" displayname="Object With Status - Undelete" hint="Check that the bDeleted flag is removed after rolling back a deleted object" returntype="void" access="public" dependson="status_deleteapproved,metadata_categories">
		<cfset var stObj = application.fapi.getContentObject(typename="dmInclude",objectid=this.testIncludeApproved) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		<cfset var aResult = arraynew(1) />
		
		<cfset application.fapi.getContentType(typename="dmInclude").delete(objectid=this.testIncludeApproved) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testIncludeApproved,orderby="datetimecreated desc") />
		<cfset aResult = application.fapi.getContentType("dmArchive").undeleteArchive(archiveID=q.objectid[1])>
		
		<cfset assertEquals(1,arraylen(aResult),"Unexpected number of undeleted objects") />
		<cfset assertObjectExists(typename="dmInclude",objectid=this.testIncludeApproved,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testIncludeApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testIncludeApproved,bDeleted=1,timeframe=120,message="The database contains an archive with the bDeleted flag") />
		
		<cfset q = createobject("component","farcry.core.packages.farcry.category").getCategories(objectid=this.testIncludeApproved) />
		<cfset assertEquals("root",q,"Restored content is associated with original categories") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testIncludeApproved,orderby="datetimecreated desc") />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		
		<cfset stObj = application.fapi.getContentObject(typename="dmInclude",objectid=this.testIncludeApproved) />
		<cfset assertEquals("Archive",stObj.title,"Incorrect restored title") />
	</cffunction>
	
	
	<!--- VERSIONED CONTENT --->
	<cffunction name="version_editdraft" displayname="Object With Versions - Edit draft" hint="Check that an archive is not created after editing a draft versioned object" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLDraft) />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmHTML",objectid=this.testHTMLDraft,timeframe=120,message="The database does not contain the content object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testHTMLDraft,timeframe=120,message="The database contains an archive for the edited object") />
	</cffunction>
	
	<cffunction name="version_editapproved" displayname="Object With Versions - Edit approved" hint="Check that an archive is created after editing an approved versioned object" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmHTML",objectid=this.testHTMLApproved,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testHTMLApproved) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("published",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmHTML",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(0,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Archive",stArchive.title,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="version_unpublish" displayname="Object With Versions - Unpublish" hint="Check that an archive is created after unpublishing a versioned object" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		<cfset request.mode.debug=true>
		<cfset stObj.status = "draft" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmHTML",objectid=this.testHTMLApproved,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testHTMLApproved) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("unpublished",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmHTML",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(0,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Archive",stArchive.title,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="version_publish" displayname="Object With Versions - Publish when no approved version" hint="Check that an archive is not created after publishing a versioned object with no existing approved version" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLDraft) />
		
		<cfset stObj.status = "approved" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmHTML",objectid=this.testHTMLDraft,timeframe=120,message="The database does not contain the content object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testHTMLDraft,timeframe=120,message="The database contains an archive for the edited object") />
	</cffunction>
	
	<cffunction name="version_deleteapproved" displayname="Object With Versions - Delete approved" hint="Check that an archive is created after deleting an approved versioned object" returntype="void" access="public">
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset application.fapi.getContentType(typename="dmHTML").delete(objectid=this.testHTMLApproved) />
		
		<cfset assertNotObjectExists(typename="dmHTML",objectid=this.testHTMLApproved,timeframe=120,message="The database contains the deleted content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testHTMLApproved) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("deleted",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmHTML",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(1,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Archive",stArchive.title,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="version_deletedraft" displayname="Object With Versions - Delete draft" hint="Check that an archive is not created after deleting a draft versioned object" returntype="void" access="public">
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset application.fapi.getContentType(typename="dmHTML").delete(objectid=this.testHTMLDraft) />
		
		<cfset assertNotObjectExists(typename="dmHTML",objectid=this.testHTMLDraft,timeframe=120,message="The database contains the content object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testHTMLDraft,timeframe=120,message="The database contains an archive for the edited object") />
	</cffunction>
	
	<cffunction name="version_createdraft" displayname="Object With Versions - Create draft" hint="Check that an archive is not created after creating a draft version version of an approved object" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		
		<cfset stObj.status = "draft" />
		<cfset stObj.versionID = stObj.objectid />
		<cfset stObj.objectid = createuuid() />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmHTML",objectid=this.testHTMLApproved,timeframe=120,message="The database does not contain the aaproved content object") />
		<cfset assertObjectExists(typename="dmHTML",objectid=stObj.objectid,timeframe=120,message="The database does not contain the draft content object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database contains an archive for the edited object") />
	</cffunction>
	
	<cffunction name="version_publishoverexisting" displayname="Object With Versions - Publish draft over existing approved version" hint="Check that an archive is created after publishing a draft object over an existing approved version" returntype="void" access="public" dependsOn="version_createdraft">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		<cfset var draftid = createuuid() />
		<cfset var oVersioning = createobject("component","#application.packagepath#.farcry.versioning") />
		
		<cfset stObj.status = "draft" />
		<cfset stObj.versionID = stObj.objectid />
		<cfset stObj.objectid = draftid />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		<cfset oVersioning.sendObjectLive(objectID=stObj.objectid,stDraftObject=stObj) />
		
		<cfset assertObjectExists(typename="dmHTML",objectid=this.testHTMLApproved,status="approved",title="Hello world",timeframe=120,message="The database does not contain the approved content object") />
		<cfset assertNotObjectExists(typename="dmHTML",objectid=draftid,timeframe=120,message="The database still contains the draft content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database does not contain an archive for the replaced object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testHTMLApproved) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("published",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmHTML",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(0,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Archive",stArchive.title,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="version_rollback" displayname="Object With Versions - Rollback" hint="Check that an archive is created and the object is updated after a rollback" returntype="void" access="public" dependsOn="version_publishoverexisting">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		<cfset var oVersioning = createobject("component","#application.packagepath#.farcry.versioning") />
		<cfset var draftid = createuuid() />
		
		<cfset stObj.status = "draft" />
		<cfset stObj.versionID = stObj.objectid />
		<cfset stObj.objectid = draftid />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset oVersioning.sendObjectLive(objectID=stObj.objectid,stDraftObject=stObj) />
		
		<cfset this.thread.sleep(1000) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testHTMLApproved,orderby="datetimecreated desc") />
		
		<cfset application.fapi.getContentType("dmArchive").rollbackArchive(objectid=this.testHTMLApproved,archiveID=q.objectid[1],typename="dmHTML")>
		
		<cfset assertObjectExists(typename="dmHTML",objectid=this.testHTMLApproved,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testHTMLApproved,orderby="datetimecreated desc") />
		<cfset assertEquals(2,q.recordcount,"Unexpected number of archives") />
		<cfset assertEquals("rolled back",q.event,"Incorrect archive event") />
		<cfset assertEquals("dmHTML",q.objectTypename,"Incorrect archive typename") />
		<cfset assertEquals(0,q.bDeleted,"Incorrect archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Hello world",stArchive.title,"Archive does not contain the previous values") />
	</cffunction>
	
	<cffunction name="version_undelete" displayname="Object With Versions - Undelete" hint="Check that the bDeleted flag is removed after rolling back a deleted object" returntype="void" access="public">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset var q = "" />
		<cfset var stArchive = structnew() />
		<cfset var aResult = arraynew(1) />
		
		<cfset application.fapi.getContentType(typename="dmHTML").delete(objectid=this.testHTMLApproved) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testHTMLApproved,orderby="datetimecreated desc") />
		<cfset aResult = application.fapi.getContentType("dmArchive").undeleteArchive(archiveID=q.objectid[1])>
		
		<cfset assertEquals(1,arraylen(aResult),"Unexpected number of undeleted objects") />
		<cfset assertObjectExists(typename="dmHTML",objectid=this.testHTMLApproved,timeframe=120,message="The database does not contain the content object") />
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		<cfset assertNotObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,bDeleted=1,timeframe=120,message="The database contains an archive with the bDeleted flag") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testHTMLApproved,orderby="datetimecreated desc") />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of archives") />
		
		<cfset stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset assertEquals("Archive",stObj.title,"Incorrect restored title") />
	</cffunction>
	
	
	<!--- TREE CONTENT --->
	<cffunction name="tree_undelete_leafwithparent" displayname="Tree Object - Undelete leaf (parent exists)" hint="Check that undeleting a leaf restores it to its original parent" returntype="void" access="public" dependsOn="version_undelete,metadata_tree_leafintree">
		<cfset var q = "" />
		<cfset var stNav = structnew() />
		<cfset var aResult = arraynew(1) />
		
		<cfset application.fapi.getContentType(typename="dmHTML").delete(objectid=this.testNavigationLeaf) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testNavigationLeaf,orderby="datetimecreated desc") />
		<cfset aResult = application.fapi.getContentType("dmArchive").undeleteArchive(archiveID=q.objectid[1])>
		
		<cfset assertEquals(1,arraylen(aResult),"Unexpected number of undeleted objects") />
		
		<cfset stNav = application.fapi.getContentObject(typename="dmNavigation",objectid=this.testNavigationApproved) />
		<cfset assertTrue(listfind(arraytolist(stNav.aObjectIDs),this.testNavigationLeaf),"Expected restored object to be attached original parent") />
	</cffunction>
	
	<cffunction name="tree_undelete_leafwithnoparent" displayname="Tree Object - Undelete leaf (parent does not exist)" hint="Check that undeleting a leaf restores it to the 'Undelete' node" returntype="void" access="public" dependsOn="version_undelete,metadata_tree_notintree">
		<cfset var q = "" />
		<cfset var stNav = "" />
		<cfset var aResult = arraynew(1) />
		
		<cfset application.fapi.getContentType(typename="dmNavigation").delete(objectid=this.testNavigationApproved) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,metaWDDX,event",archiveID_eq=this.testNavigationLeaf,orderby="datetimecreated desc") />
		<cfset aResult = application.fapi.getContentType("dmArchive").undeleteArchive(archiveID=q.objectid[1])>
		
		<cfset assertEquals(1,arraylen(aResult),"Unexpected number of undeleted objects") />
		<cfset assertVariable(variable="application.navid.undelete",message="'undelete' is not in application.navid") />
		
		<cfset stNav = application.fapi.getContentObject(typename="dmNavigation",objectid=application.navid.undelete) />
		<cfset assertTrue(listfind(arraytolist(stNav.aObjectIDs),this.testNavigationLeaf),"Expected restored object to be attached undelete node") />
	</cffunction>
	
	<cffunction name="tree_undelete_nodewithparent" displayname="Tree Object - Undelete node (parent exists)" hint="Check that undeleting a node restores it to its original parent" returntype="void" access="public" dependsOn="version_undelete,metadata_tree_leafintree">
		<cfset var q = "" />
		<cfset var parent = "" />
		<cfset var aResult = arraynew(1) />
		
		<cfset application.fapi.getContentType(typename="dmNavigation").delete(objectid=this.testNavigationChild) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testNavigationChild,orderby="datetimecreated desc") />
		<cfset aResult = application.fapi.getContentType("dmArchive").undeleteArchive(archiveID=q.objectid[1])>
		
		<cfset assertEquals(1,arraylen(aResult),"Unexpected number of undeleted objects") />
		
		<cfset qParent = application.factory.oTree.getParentID(this.testNavigationChild) />
		<cfset assertEquals(1,qParent.recordcount,"Undeleted object is not in tree") />
		<cfset assertEquals(this.testNavigationApproved,qParent.parentid,"Expected restored object to be attached to original parent") />
	</cffunction>
	
	<cffunction name="tree_undelete_nodewithnoparent" displayname="Tree Object - Undelete node (parent does not exist)" hint="Check that undeleting a node restores it to the 'Undelete' node" returntype="void" access="public" dependsOn="version_undelete,metadata_tree_notintree">
		<cfset var q = "" />
		<cfset var qParent = "" />
		<cfset var aResult = arraynew(1) />
		
		<cfset application.fapi.getContentType(typename="dmNavigation").delete(objectid=this.testNavigationApproved) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testNavigationChild,orderby="datetimecreated desc") />
		<cfset aResult = application.fapi.getContentType("dmArchive").undeleteArchive(archiveID=q.objectid[1])>
		
		<cfset assertEquals(1,arraylen(aResult),"Unexpected number of undeleted objects") />
		<cfset assertVariable(variable="application.navid.undelete",message="'undelete' is not in application.navid") />
		
		<cfset qParent = application.factory.oTree.getParentID(this.testNavigationChild) />
		<cfset assertEquals(1,qParent.recordcount,"Undeleted object is not in tree") />
		<cfset assertEquals(application.navid.undelete,qParent.parentid,"Expected restored object to be attached undelete node") />
	</cffunction>
	
	<cffunction name="tree_undelete_cascade" displayname="Tree Object - Cascading undelete" hint="Check that cascading undelete restores the object, it's children, and related objects" returntype="void" access="public" dependsOn="tree_undelete_nodewithparent,tree_undelete_nodewithparent">
		<cfset var q = "" />
		<cfset var parent = "" />
		<cfset var aResult = arraynew(1) />
		
		<cfset application.fapi.getContentType(typename="dmNavigation").delete(objectid=this.testNavigationApproved) />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,objectWDDX,event",archiveID_eq=this.testNavigationApproved,bDeleted_eq=true) />
		<cfset aResult = application.fapi.getContentType("dmArchive").undeleteArchive(archiveID=q.objectid[1],cascade=true)>
		
		<cfset assertEquals(3,arraylen(aResult),"Unexpected number of undeleted objects") />
		
		<cfset qParent = application.factory.oTree.getParentID(this.testNavigationChild) />
		<cfset assertEquals(1,qParent.recordcount,"Undeleted object is not in tree") />
		<cfset assertEquals(this.testNavigationApproved,qParent.parentid,"Expected restored child to be attached to restored parent") />
		
		<cfset stNav = application.fapi.getContentObject(typename="dmNavigation",objectid=this.testNavigationApproved) />
		<cfset assertTrue(listfind(arraytolist(stNav.aObjectIDs),this.testNavigationLeaf),"Expected restored related content to be attached restored parent") />
	</cffunction>
	
	
	<!--- METADATA --->
	<cffunction name="metadata_friendlyurls" displayname="Metadata - Friendly URLs" hint="Check that archiving stores all the friendly URLs for an object" returntype="void" access="public" dependsOn="version_editapproved">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset var q = "" />
		<cfset var stMeta = structnew() />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testHTMLApproved) />
		<cfset assertNotEquals("",q.metaWDDX,"Archive does not contain metadata") />
		<cfwddx action="wddx2cfml" input="#q.metaWDDX#" output="stMeta" />
		<cfset assertEquals(true,structkeyexists(stMeta,"friendlyurls"),"Archive metadata does not contain friendly URLs information") />
		<cfset assertEquals(true,isquery(stMeta.friendlyurls),"Archive friendly URL metadata is not a query") />
		<cfset assertEquals(1,stMeta.friendlyurls.recordcount,"Unexpected number of friendly URLs") />
		<cfset assertEquals(stObj.objectid,stMeta.friendlyurls.refobjectid,"Stored friendly URLs are for wrong object") />
		<cfset assertEquals("/html/archive",stMeta.friendlyURLs.friendlyURL,"Stored friendly URL is incorrect") />
	</cffunction>
	
	<cffunction name="metadata_tree_notintree" displayname="Metadata - Tree (not in tree)" hint="Check that archiving doesn't store tree information for content not in the tree" returntype="void" access="public" dependsOn="version_editapproved">
		<cfset var stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset var q = "" />
		<cfset var stMeta = structnew() />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testHTMLApproved) />
		<cfset assertNotEquals("",q.metaWDDX,"Archive does not contain metadata") />
		<cfwddx action="wddx2cfml" input="#q.metaWDDX#" output="stMeta" />
		<cfset assertEquals(false,structkeyexists(stMeta,"tree"),"Archive metadata contains tree information") />
	</cffunction>
	
	<cffunction name="metadata_tree_leafintree" displayname="Metadata - Tree (leaf in tree)" hint="Check that archiving stores parent information for leaves in the tree" returntype="void" access="public" dependsOn="version_editapproved">
		<cfset var stObj = "" />
		<cfset var q = "" />
		<cfset var stMeta = structnew() />
		
		<cfset stObj = application.fapi.getContentObject(typename="dmNavigation",objectid=application.navid.home) />
		<cfset arrayappend(stObj.aObjectIDs,this.testHTMLApproved) />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset stObj = application.fapi.getContentObject(typename="dmHTML",objectid=this.testHTMLApproved) />
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testHTMLApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testHTMLApproved) />
		<cfset assertNotEquals("",q.metaWDDX,"Archive does not contain metadata") />
		<cfwddx action="wddx2cfml" input="#q.metaWDDX#" output="stMeta" />
		<cfset assertEquals(true,structkeyexists(stMeta,"tree"),"Archive metadata does not contain tree information") />
		<cfset assertEquals(true,structkeyexists(stMeta.tree,"parent"),"Archive metadata does not contain parent id") />
		<cfset assertEquals(application.navid.home,stMeta.tree.parent,"Archive metadata contains wrong parent id") />
		<cfset assertEquals(false,structkeyexists(stMeta.tree,"children"),"Archive metadata contains children information") />
	</cffunction>
	
	<cffunction name="metadata_tree_navigation" displayname="Metadata - Tree (navigation)" hint="Check that archiving stores parent and children information for nodes in the tree" returntype="void" access="public" dependsOn="version_editapproved">
		<cfset var stObj = application.fapi.getContentObject(typename="dmNavigation",objectid=this.testNavigationApproved) />
		<cfset var q = "" />
		<cfset var stMeta = structnew() />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testNavigationApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testNavigationApproved) />
		<cfset assertNotEquals("",q.metaWDDX,"Archive does not contain metadata") />
		<cfwddx action="wddx2cfml" input="#q.metaWDDX#" output="stMeta" />
		<cfset assertEquals(true,structkeyexists(stMeta,"tree"),"Archive metadata does not contain tree information") />
		<cfset assertEquals(true,structkeyexists(stMeta.tree,"parent"),"Archive metadata does not contain parent id") />
		<cfset assertEquals(trim(application.navid.home),stMeta.tree.parent,"Archive metadata contains wrong parent id") />
		<cfset assertEquals(true,structkeyexists(stMeta.tree,"children"),"Archive metadata does not contain children information") />
		<cfset assertEquals(1,stMeta.tree.children.recordcount,"Unexpected number of children in archive metadata") />
		<cfset assertEquals(this.testNavigationChild,stMeta.tree.children.objectid[1],"Unexpected child in archive metadata") />
	</cffunction>
	
	<cffunction name="metadata_tree_navigationdelete" displayname="Metadata - Delete branch" hint="Check that deleting a branch stores parent and children information for child content" returntype="void" access="public" dependsOn="version_editapproved">
		<cfset var q = "" />
		<cfset var stMeta = structnew() />
		
		<cfset this.thread.sleep(1000) />
		
		<cfset application.fapi.getContentType("dmNavigation").delete(objectid=this.testNavigationApproved) />
		
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testNavigationApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testNavigationApproved,bDeleted_eq=1) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of parent archives") />
		<cfset assertEquals("deleted",q.event,"Incorrect parent archive event") />
		<cfset assertNotEquals("",q.metaWDDX,"Parent archive does not contain metadata") />
		<cfset assertEquals("dmNavigation",q.objectTypename,"Incorrect parent archive typename") />
		<cfset assertEquals(1,q.bDeleted,"Incorrect parent archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect parent archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect parent archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect parent archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Parent archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.metaWDDX#" output="stMeta" />
		<cfset assertEquals(true,structkeyexists(stMeta,"tree"),"Archive metadata does not contain tree information") />
		<cfset assertEquals(true,structkeyexists(stMeta.tree,"parent"),"Archive metadata does not contain parent id") />
		<cfset assertEquals(trim(application.navid.home),stMeta.tree.parent,"Archive metadata contains wrong parent id") />
		<cfset assertEquals(true,structkeyexists(stMeta.tree,"children"),"Archive metadata does not contain children information") />
		<cfset assertEquals(1,stMeta.tree.children.recordcount,"Unexpected number of children in archive metadata") />
		<cfset assertEquals(this.testNavigationChild,stMeta.tree.children.objectid[1],"Unexpected child in archive metadata") />
		
		<!--- Navigation child node --->
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testNavigationChild) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of child archives") />
		<cfset assertEquals("deleted",q.event,"Incorrect child archive event") />
		<cfset assertEquals("dmNavigation",q.objectTypename,"Incorrect child archive typename") />
		<cfset assertEquals(1,q.bDeleted,"Incorrect child archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect child archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect child archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect child archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Child archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Child",stArchive.title,"Child archive does not contain the previous values") />
		<cfset assertNotEquals(q.metaWDDX,"","Child archive metadata is empty") />
		<cfwddx action="wddx2cfml" input="#q.metaWDDX#" output="stArchive" />
		<cfset assertTrue(isdefined("stArchive.tree.parent"),"Child navigation archive does not have parent metadata") />
		<cfset assertEquals(this.testNavigationApproved,stArchive.tree.parent,"Child navigation archive does not have the correct parent") />
		
		<!--- Navigation child leaf --->
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testNavigationLeaf) />
		<cfset assertEquals(1,q.recordcount,"Unexpected number of leaf archives") />
		<cfset assertEquals("deleted",q.event,"Incorrect leaf archive event") />
		<cfset assertEquals("dmHTML",q.objectTypename,"Incorrect leaf archive typename") />
		<cfset assertEquals(1,q.bDeleted,"Incorrect leaf archive bDeleted flag") />
		<cfset assertEquals(application.security.getCurrentUserID(),q.username,"Incorrect leaf archive username") />
		<cfset assertEquals(cgi.REMOTE_ADDR,q.ipaddress,"Incorrect leaf archive IP address") />
		<cfset assertEquals(application.security.getCurrentRoles(),q.lRoles,"Incorrect leaf archive roles") />
		<cfset assertNotEquals(q.objectWDDX,"","Leaf archive is empty") />
		<cfwddx action="wddx2cfml" input="#q.objectWDDX#" output="stArchive" />
		<cfset assertEquals("Leaf",stArchive.title,"Leaf archive does not contain the previous values") />
		<cfset assertNotEquals(q.metaWDDX,"","Leaf metadata is empty") />
		<cfwddx action="wddx2cfml" input="#q.metaWDDX#" output="stArchive" />
		<cfset assertTrue(isdefined("stArchive.tree.parent"),"Leaf navigation archive does not have parent metadata") />
		<cfset assertEquals(this.testNavigationApproved,stArchive.tree.parent,"Leaf navigation archive does not have the correct parent") />
		
		<cfset request.mode.debug = false />
	</cffunction>
	
	<cffunction name="metadata_categories" displayname="Metadata - Categories" hint="Check that archiving stores category references" returntype="void" access="public" dependsOn="version_editapproved">
		<cfset var stObj = application.fapi.getContentObject(typename="dmInclude",objectid=this.testIncludeApproved) />
		<cfset var q = "" />
		<cfset var stMeta = structnew() />
		
		<cfset stObj.title = "Hello world" />
		<cfset application.fapi.setData(stProperties=stObj) />
		
		<cfset assertObjectExists(typename="dmArchive",archiveID=this.testIncludeApproved,timeframe=120,message="The database does not contain an archive for the edited object") />
		
		<cfset q = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=this.testIncludeApproved) />
		<cfset assertNotEquals("",q.metaWDDX,"Archive does not contain metadata") />
		<cfwddx action="wddx2cfml" input="#q.metaWDDX#" output="stMeta" />
		<cfset assertEquals(true,structkeyexists(stMeta,"categories"),"Archive metadata does not contain category information") />
		<cfset assertEquals(1,stMeta.categories.recordcount,"Unexpected number of categories in archive metadata") />
		<cfset assertEquals(application.catid.root,stMeta.categories.objectid[1],"Unexpected category in archive metadata") />
	</cffunction>
	
</cfcomponent>