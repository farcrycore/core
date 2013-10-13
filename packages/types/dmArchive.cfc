<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
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
<cfcomponent 
	displayname="Content Archive" 
	extends="types" 
	hint="Archive: universal container for archived and deleted content items." 
	bRefObjects="false" bAudit="false" bArchive="false" bSystem="true"
	icon="icon-archive">
	
	<!------------------------------------------------------------------------
	type properties
	------------------------------------------------------------------------->

	<cfproperty name="archiveID" type="UUID" required="no" default=""
		hint="ID of archived entry">
	
	<cfproperty name="event" type="string" required="no" default="" ftLabel="Event"
		hint="The event that triggered the creation of this archive">
	
	<cfproperty name="objectTypename" type="string" required="no" default="" ftLabel="Typename"
		hint="The archived type">
	
	<cfproperty name="bDeleted" type="boolean" required="no" default="false" ftLabel="Deleted"
		hint="True if this is the last archive of a deleted object">
	
	<cfproperty name="username" type="string" required="no" default="" ftLabel="User"
		hint="The user that triggered this action">
	
	<cfproperty name="ipaddress" type="string" required="no" default="" ftLabel="IP Address"
		hint="The IP from which this was done">
	
	<cfproperty name="lRoles" type="string" required="no" default="" ftLabel="Roles"
		hint="The roles the user had">
	
	<cfproperty name="objectWDDX" type="longchar" required="no" default=""
		hint="WDDX packet that defines the object being archived">
	
	<cfproperty name="metaWDDX" type="longchar" required="no" default=""
		hint="WDDX packet that defines various metadata properties and relationships, including friendly URLs, tree location, categories, and archived file locations">
	
	
	<!--- Object Methods --->
	<cffunction name="archiveObject" access="public" hint="archiving of related items to content types (eg. files and images)" returntype="struct">
		<cfargument name="stObj" required="yes" type="struct">
		<cfargument name="event" required="yes" type="string">
		<cfargument name="username" required="yes" type="string">
		<cfargument name="bDeleted" required="no" type="boolean" default="false">
		<cfargument name="stMeta" required="no" type="struct" />
		
		<cfset var stLocal = StructNew()>
		<cfset var thisprop = "" />
		<cfset var stMetaData = structnew() />
		
		<cfset stlocal.returnStruct = StructNew()>
		<cfset stLocal.stObj = StructCopy(arguments.stObj)>
		
		<!--- Set up the dmArchive structure to save --->
		<cfset stLocal.stProps = structNew()>
		<cfset stLocal.stProps.objectID = application.fc.utils.createJavaUUID()>
		<cfset stLocal.stProps.archiveID = stLocal.stObj.objectID>
		<cfset stLocal.stProps.event = arguments.event>
		<cfset stLocal.stProps.objectTypename = arguments.stObj.typename>
		<cfset stLocal.stProps.bDeleted = arguments.bDeleted>
		<cfset stLocal.stProps.username = arguments.username>
		<cfset stLocal.stProps.ipaddress = cgi.REMOTE_ADDR>
		<cfset stLocal.stProps.lRoles = application.security.getCurrentRoles()>
		<cfset stLocal.stProps.label = stLocal.stObj.label>
		
		<!--- Add object data to archive --->
		<cfwddx input="#stLocal.stObj#" output="stLocal.stProps.objectWDDX"  action="cfml2wddx">
		
		<!--- Get object metadata --->
		<cfif not structkeyexists(arguments,"stMeta")>
			<cfset arguments.stMeta = getMeta(stObject=arguments.stObj) />
		</cfif>
		
		<!--- Archive media --->
		<cfloop collection="#stLocal.stObj#" item="thisprop">
			<cfif (issimplevalue(stLocal.stObj[thisprop]) and len(stLocal.stObj[thisprop])) and structkeyexists(application.stCOAPI[stLocal.stObj.typename].stProps,thisprop)>
				<cfset stMetadata = application.stCOAPI[stLocal.stObj.typename].stProps[thisprop].metadata />
				<cfparam name="stMetadata.ftType" default="#stMetadata.type#" />
				
				<cfif (not structkeyexists(stMetadata,"bArchive") or stMetadata.bArchive) and structkeyexists(application.formtools[stMetadata.ftType].oFactory,"onArchive")>
					<cfset queryaddrow(arguments.stMeta.files) />
					<cfset querysetcell(arguments.stMeta.files,"property",thisprop) />
					<cfset querysetcell(arguments.stMeta.files,"filename",stLocal.stObj[thisprop]) />
					<cfset querysetcell(arguments.stMeta.files,"archive",application.formtools[stMetadata.ftType].oFactory.onArchive(typename=stLocal.stObj.typename,stObject=stLocal.stObj,stMetadata=stMetadata,archiveID=stLocal.stProps.objectid)) />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfwddx input="#arguments.stMeta#" output="stLocal.stProps.metaWDDX"  action="cfml2wddx">
		
		<cfset createData(stProperties=stLocal.stProps)>
		
		<cfset stLocal.returnstruct.archive = stLocal.stProps />
		<cfset stLocal.returnstruct.object = stLocal.stObj />
		<cfset stLocal.returnstruct.metadata = arguments.stMeta />
		
		<cfreturn stlocal.returnStruct>
	</cffunction>
	
	<cffunction name="rollbackArchive" access="public" returntype="struct" hint="Sends a archived object live and archives current version">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="archiveID"  type="uuid" required="true" hint="the archived object to be sent back live">
		<cfargument name="typename" type="string" required="false">
		
		<cfset var stResult = structnew() />
		<cfset var stArchive = structnew() />
		<cfset var stArchiveDetail = structnew() />
		<cfset var stNav = structnew() />
		<cfset var q = "" />
		<cfset var stMeta = structnew() />
		<cfset var stParent = structnew() />
		<cfset var stPrev = structnew() />
		<cfset var stMetadata = structnew() />
		<cfset var stLocation = structnew() />
		
		<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
		
		<cfif NOT structkeyexists(arguments,"typename")>
			<cfset arguments.typename = createObject("component","farcry.core.packages.fourq.fourq").findType(objectid=arguments.objectid) />
		</cfif>
		
		<cflock name="archive_#arguments.archiveID#" timeout="50" type="exclusive">
			<!--- retrieve archive version --->
			<cfset stArchive = getData(objectid=arguments.archiveID) />
			
			<cfset stResult.archive = stArchive />
			
			<!--- Convert wddx archive object --->
			<cfwddx input="#stArchive.metawddx#" output="stMeta" action="wddx2cfml">
			<cfwddx input="#stArchive.objectwddx#" output="stArchiveDetail"  action="wddx2cfml">
			<cfset stArchiveDetail.objectid = arguments.objectID>
			<cfset stArchiveDetail.locked = 0>
			<cfset stArchiveDetail.lockedBy = "">
			
			<cfset stResult.previous = application.fapi.getContentObject(typename=stArchiveDetail.typename,objectid=stArchiveDetail.objectid) />
			<cfset stResult.object = stArchiveDetail />
			<cfset stResult.metadata = stMeta />
			
			<!--- Restore archived media --->
			<cfloop query="#stMeta.files#">
				<cfset stMetadata = application.stCOAPI[stArchiveDetail.typename].stProps[stMeta.files.property].metadata />
				<cfparam name="stMetadata.ftType" default="#stMetadata.type#" />
				
				<cfif structkeyexists(application.formtools[stMetadata.ftType].oFactory,"onRollback")>
					<!--- onRollback ALWAYS uses makeUnique - if the property has the same file with the same name, it will NOT be overwritten --->
					<cfset stArchiveDetail[stMeta.files.property] = application.formtools[stMetadata.ftType].oFactory.onRollback(typename=stLocal.stObj.typename,stObject=stLocal.stObj,stMetadata=stMetadata,archiveID=stProps.objectid) />
				</cfif>
			</cfloop>
			
			<!--- Update current live object with archive property values	 --->
			<cfset application.fapi.setData(stProperties=stArchiveDetail,auditNote='Archive rolled back')>
			
			<!--- Remove deprecated media --->
			<cfloop query="#stMeta.files#">
				<cfset stMetadata = application.stCOAPI[stArchiveDetail.typename].stProps[stMeta.files.property].metadata />
				
				<cfif structkeyexists(application.formtools[stMetadata.ftType].oFactory,"onRollback") and structkeyexists(application.formtools[stMetadata.ftType].oFactory,"onDelete") and stResult.previous[stMeta.files.property] neq stArchiveDetail[stMeta.files.property]>
					<!--- in many cases, rolled back files will change from abc.pdf => abc1.pdf, and we need to delete the old filename --->
					<cfset  application.formtools[stMetadata.ftType].oFactory.onDelete(typename=stLocal.stObj.typename,stObject=stResult.previous,stMetadata=stMetadata) />
				</cfif>
			</cfloop>
			
			<!--- If this is an undelete and has a parent, attempt to put it in the tree --->
			<cfif stArchive.bDeleted eq true and isdefined("stMeta.tree.parent")>
				<cfset stParent = application.fapi.getContentObject(typename="dmNavigation",objectid=stMeta.tree.parent) />
				
				<cfif structisempty(stParent) or structkeyexists(stParent,"bDefaultObject")>
					<!--- Make sure there is an "Undelete navigation node" --->
					<cfif structkeyexists(application.navid,"undelete")>
						<cfset stParent = application.fapi.getContentObject(typename="dmNavigation",objectid=application.navid.undelete) />
					<cfelse>
						<cfset stParent = application.fapi.getContentObject(typename="dmNavigation",objectid=createuuid()) />
						<cfset stParent.title = "Undelete" />
						<cfset stParent.label = "Undelete" />
						<cfset stParent.lNavIDAlias = "undelete" />
						<cfset application.fapi.setData(stProperties=stParent) />
						<cfset application.factory.oTree.setYoungest(parentid=application.navid.root,objectid=stParent.objectid,objectname=stParent.label,typename="dmNavigation") />
						<cfset application.navid["undelete"] = stParent.objectID />
					</cfif>
				</cfif>
				
				<cfif stArchiveDetail.typename eq "dmNavigation">
					<cfset application.factory.oTree.setYoungest(parentid=stParent.objectid,objectid=stArchiveDetail.objectid,objectname=stArchiveDetail.label,typename="dmNavigation") />
				<cfelse>
					<cfif not arrayfind(stParent.aObjectIDs,stArchiveDetail.objectid)>
						<cfset arrayappend(stParent.aObjectIDs,stArchiveDetail.objectid) />
						<cfset application.fapi.setData(stProperties=stParent) />
					</cfif>
				</cfif>
				
				<cfset stResult.parent = stParent />
			</cfif>
			
			<!--- Assign the previous categories --->
			<cfset createobject("component","farcry.core.packages.farcry.category").assignCategories(objectid=stArchiveDetail.objectid,lCategoryIDs=valuelist(stMeta.categories.objectid),alias="root") />
			
			<!--- Make sure no existing archives for this object have bDeleted set to true --->
			<cfset q = application.fapi.getContentObjects(typename="dmArchive",archiveID_eq=stArchive.archiveID,bDeleted_eq=true) />
			<cfif q.recordcount>
				<cfset stArchive = getData(objectid=q.objectid[1]) />
				<cfset stArchive.bDeleted = false />
				<cfset setData(stProperties=stArchive) />
			</cfif>
			
			<cfif application.stCOAPI[typename].bUseInTree>
				<!--- update tree --->
				<nj:getNavigation objectId="#arguments.objectID#" bInclusive="1" r_stObject="stNav" r_ObjectId="arguments.objectId">
				<cfif isstruct(stNav) and structkeyexists(stNav,"objectid")>
					<nj:updateTree ObjectId="#stNav.objectId#">
				</cfif>
			</cfif>						
		</cflock>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="undeleteArchive" access="public" returntype="array" hint="Undeletes an archived object - throws an error if the selected archive has a live version">
		<cfargument name="archiveID"  type="uuid" required="true" hint="the archived object to be sent back live">
		<cfargument name="cascade" type="boolean" required="false" default="false" hint="Set to true to automatically undelete children and related content" />
		
		<cfset var stArchive = getData(objectid=arguments.archiveID) />
		<cfset var stArchiveObject = "" />
		<cfset var q = application.fapi.getContentObjects(typename=stArchive.objectTypename,objectid_eq=stArchive.archiveID) />
		<cfset var aResult = arraynew(1) />
		<cfset var thisprop = "" />
		<cfset var aResultSub = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var objectTypename = "" />
		<cfset var tmp	= '' />
		<cfset var stArchiveDetail	= '' />

		<cfif stArchive.bDeleted eq false>
			<cfwddx action="cfml2wddx" input="#stArchive#" output="tmp">
			<cfthrow message="Archive has not been flagged as the delete archive" type="undelete" detail="#tmp#" />
		<cfelseif q.recordcount>
			<cfthrow message="Archive is for an object that still exists" type="undelete" />
		</cfif>
		
		<cfif len(stArchive.objectTypename)>
			<cfset objectTypename = stArchive.objectTypename />
		<cfelse>
			<cfwddx action="wddx2cfml" input="#stArchive.objectWDDX#" output="stArchiveDetail" />
			<cfset objectTypename = stArchiveDetail.typename />
		</cfif>
		
		<cfset aResult[1] = rollbackArchive(stArchive.archiveID,arguments.archiveID,objectTypename) />
		
		<!--- Undelete related content --->
		<cfloop collection="#aResult[1].object#" item="thisprop">
			<cfif structkeyexists(application.stCOAPI[aResult[1].object.typename].stProps,thisprop) and application.stCOAPI[aResult[1].object.typename].stProps[thisprop].metadata.type eq "uuid">
				<cfset q = application.fapi.getContentObjects(typename="dmArchive",archiveID_eq=aResult[1].object[thisprop],bDeleted_eq=true) />
				
				<cfif q.recordcount>
					<cfset aResultSub = undeleteArchive(archiveID=q.objectid,cascade=arguments.cascade) />
					
					<cfloop from="1" to="#arraylen(aResultSub)#" index="i">
						<cfset arrayappend(aResult,aResultSub[i]) />
					</cfloop>
				</cfif>
			<cfelseif structkeyexists(application.stCOAPI[aResult[1].object.typename].stProps,thisprop) and application.stCOAPI[aResult[1].object.typename].stProps[thisprop].metadata.type eq "array">
				<cfloop from="1" to="#arraylen(aResult[1].object[thisprop])#" index="i">
					<cfif issimplevalue(aResult[1].object[thisprop][i])>
						<cfset q = application.fapi.getContentObjects(typename="dmArchive",archiveID_eq=aResult[1].object[thisprop][i],bDeleted_eq=true) />
						
						<cfif q.recordcount>
							<cfset aResultSub = undeleteArchive(archiveID=q.objectid,cascade=arguments.cascade) />
							
							<cfloop from="1" to="#arraylen(aResultSub)#" index="j">
								<cfset arrayappend(aResult,aResultSub[j]) />
							</cfloop>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<!--- Undelete children --->
		<cfif structkeyexists(aResult[1].metadata,"tree") and structkeyexists(aResult[1].metadata.tree,"children")>
			<cfloop query="#aResult[1].metadata.tree.children#">
				<cfset q = application.fapi.getContentObjects(typename="dmArchive",archiveID_eq=aResult[1].metadata.tree.children.objectid,bDeleted_eq=true) />
				
				<cfif q.recordcount>
					<cfset aResultSub = undeleteArchive(archiveID=q.objectid,cascade=arguments.cascade) />
					
					<cfloop from="1" to="#arraylen(aResultSub)#" index="j">
						<cfset arrayappend(aResult,aResultSub[j]) />
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn aResult />
	</cffunction>
	
	
	<cffunction name="getMeta" access="public" output="false" returntype="struct" hint="Returns metadata for the specified object">
		<cfargument name="stObject" type="struct" required="true" />
		
		<cfset var stResult = structnew() />
		<cfset var q = "" />
		<cfset var thisprop = "" />
		
		<!---  friendly URL archive (query as WDDX) --->
		<cfset stResult.friendlyurls = application.fapi.getContentObjects(typename="farFU",lProperties="*",refObjectID_eq=arguments.stObject.objectid) />
		
		<!--- category archive (struct of UUID/label) --->
		<cfset stResult.tmpcategories = "" />
		<cfloop collection="#arguments.stObject#" item="thisprop">
			<cfif structkeyexists(application.stCOAPI[arguments.stObject.typename].stProps,thisprop) and structkeyexists(application.stCOAPI[arguments.stObject.typename].stProps[thisprop].metadata,"ftType") and application.stCOAPI[arguments.stObject.typename].stProps[thisprop].metadata.ftType eq "category">
				<cfset stResult.tmpcategories = listappend(stResult.tmpcategories,arguments.stObject[thisprop]) />
			</cfif>
		</cfloop>
		<cfquery datasource="#application.dsn#" name="stResult.categories">
			select	objectid,label
			from	dmCategory
			where	objectid in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#stResult.tmpcategories#" />)
		</cfquery>
		
		<!--- peripheral tree data (parentid, array of children) --->
		<cfif arguments.stObject.typename eq "dmNavigation">
			<cfset stResult.tree = structnew() />
			<cfset stResult.tree.parent = trim(application.factory.oTree.getParentID(objectid=arguments.stObject.objectid).parentid) />
			<cfset stResult.tree.children = application.factory.oTree.getChildren(objectid=arguments.stObject.objectid) />
		<cfelseif application.stCOAPI[arguments.stObject.typename].bUseInTree>
			<cfset q = application.fapi.getContentType("dmNavigation").getParent(objectid=arguments.stObject.objectid) />
			<cfif q.recordcount>
				<cfset stResult.tree = structnew() />
				<cfset stResult.tree.parent = q.parentid[1] />
			</cfif>
		</cfif>
		
		<!--- initialize files query (populated in archiveObject) --->
		<cfset stResult.files = querynew('property,filename,archive') />
		
		<cfreturn stResult />
	</cffunction>
	
	
	<cffunction name="ftDisplayEvent" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfif len(arguments.stMetadata.value)>
			<cfreturn ucase(left(arguments.stMetadata.value,1)) & mid(arguments.stMetadata.value,2,len(arguments.stMetadata.value)) />
		<cfelse>
			<cfreturn "Unknown" />
		</cfif>
	</cffunction>

	<cffunction name="ftDisplayObjectTypename" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfif len(arguments.stMetadata.value) and structkeyexists(application.stCOAPI,arguments.stMetadata.value) and structkeyexists(application.stCOAPI[arguments.stMetadata.value],"displayname")>
			<cfreturn application.stCOAPI[arguments.stMetadata.value].displayname />
		<cfelse>
			<cfreturn arguments.stMetadata.value />
		</cfif>
	</cffunction>
	
	<cffunction name="ftDisplayUsername" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var username = arguments.stMetadata.value />
		<cfset var stProfile = structnew() />
		
		<cfif not len(username)>
			<cfset username = arguments.stObject.createdby />
		</cfif>
		
		<cfset stProfile = application.fapi.getContentType("dmProfile").getProfile(username) />
		
		<cfif len(stProfile.firstname) or len(stProfile.lastname)>
			<cfreturn trim(stProfile.firstname & " " & stProfile.lastname) & " (" & username & ")" />
		<cfelse>
			<cfreturn username />
		</cfif>
	</cffunction>
	
	<cffunction name="ftDisplayLRoles" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var roles = "" />
		<cfset var thisrole = "" />
		
		<cfloop list="#arguments.stMetadata.value#" index="thisrole">
			<cfset roles = listappend(roles,application.security.factory.role.getLabel(thisrole)) />
		</cfloop>
		
		<cfreturn replace(roles,",",", ","ALL") />
	</cffunction>
	
</cfcomponent>