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
<cfcomponent displayname="Permission" 
	extends="types" output="false" 
	hint="Each permission corresponds to a right to perform an action, access a section of the webtop, or view a webskin. A collection of permssions is called a Role." 
	bsystem="true"
	icon="fa-key">
<!---------------------------------------------- 
type properties
----------------------------------------------->
	<cfproperty 
		name="title" type="string" default="" hint="The name of this permission" bLabel="true" 
		ftSeq="1" ftFieldset="General Details" ftLabel="Title" ftvalidation="required"
		fthint="Title is a descriptive label only."
		ftType="string" />
		
	<cfproperty 
		name="shortcut" type="string" default="" hint="Shortcut for permission to use in code" 
		ftSeq="2" ftFieldset="General Details" ftLabel="Alias" ftvalidation="required"
		fthint="The code shortcut is the variable name for the permission used in programming. It must adhere to the standard CF variable naming convention. Note if you change this value you may need to make corresponding changes in your code base." 
		ftType="string" />
		
	<cfproperty 
		name="aRelatedtypes" type="array" default="" hint="If this permission is item-specific set this field to the types that it can be applied to" 
		ftSeq="3" ftFieldset="General Details" ftLabel="Bind Permission"
		fthint="Permissions can be bound to a specific content type. Set this field to nominate the types it can be applied to. Only those types capable of being bound are shown." 
		ftType="array" ftJoin="farPermission" ftRenderType="list" ftLibraryData="getRelatedTypeList" ftShowLibraryLink="false" />
		
	<cfproperty 
		name="aRoles" type="string" default="" hint="Meta-property for managing this properties relationships with roles." 
		ftSeq="4" ftFieldset="Access Privileges" ftLabel="Roles" 
		fthint="Assign the security roles that will have access to this permission."
		ftType="reversearray" ftJoin="farRole" ftSelectMultiple="true" ftJoinProperty="aPermissions" bSave="false" />

	<cfproperty 
		name="bSystem" type="boolean" default="0"  required="yes" hint="Defines if the permission is required and managed by the FarCry framework." 
		ftSeq="5" ftFieldset="General Details" ftLabel="System Permission" 
		fthint="Defines if the permission is required and managed by the FarCry framework." />
		
	<cfproperty 
		name="hint" type="longchar" default="" hint="A hint describing how/where this permission is used"
		ftSeq="6" ftFieldset="General Details" ftLabel="Hint" ftvalidation=""
		fthint="A hint describing how/where this permission is used"
		ftType="longchar" />
		
	<cfproperty 
		name="bDisabled" type="boolean" default="0"  required="yes" hint="Defines if the permission is to be disabled ready for deletion" 
		ftSeq="7" ftFieldset="General Details" ftLabel="Disabled" 
		fthint="Defines if the permission is to be disabled ready for deletion." />
		
<!---------------------------------------------- 
library data methods; used by formtools
----------------------------------------------->
	<cffunction name="getRelatedTypeList" access="public" output="false" returntype="query" hint="A library data method that returns the types that can be associated with a permission. References the ftJoin attribute of the farBarnacle aObjects property.">
		<cfset var qResult = querynew("objectid,label","varchar,varchar") />
		<cfset var ud = "" />
		<cfset var group = "" />
		<cfset var thistype	= '' />
		
		<cfif structkeyexists(application.stCOAPI,"farBarnacle")>
			<cfloop list="#application.stCOAPI.farBarnacle.stProps.referenceid.metadata.ftJoin#" index="thistype">
				<cfif structkeyexists(application.stCOAPI,thistype)>
					<cfset queryaddrow(qResult) />
					<cfset querysetcell(qResult,"objectid","#thistype#") />
					<cfset querysetcell(qResult,"label","#application.stCOAPI[thistype].displayname#")>
				</cfif>
			</cfloop>
			<cfset queryaddrow(qResult) />
			<cfset querysetcell(qResult,"objectid","webtop") />
			<cfset querysetcell(qResult,"label","Webtop")>
		</cfif>
		
		<cfreturn qResult />
	</cffunction>


<!---------------------------------------------- 
object methods
----------------------------------------------->	
	<cffunction name="permissionExists" access="public" output="false" returntype="boolean" hint="Returns true if the permission exists">
		<cfargument name="permission" type="string" required="true" hint="The permission shortcut" />
	
		<cfset var qPermissions = "" />
		
		<cfif not application.security.hasLookup(permission=arguments.permission)>
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select	objectid
				from	#application.dbOwner#farPermission
				where	lower(shortcut)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.permission)#" />
			</cfquery>
			
			<cfif qPermissions.recordcount>
				<cfset application.security.setLookup(permission=arguments.permission,objectid=qPermissions.objectid[1]) />
				<cfreturn true />
			<cfelse>
				<cfreturn false />
			</cfif>
		<cfelse>
			<cfreturn true />
		</cfif>
	</cffunction>
	
	<cffunction name="getTypePermission" access="public" output="false" returntype="string" hint="Returns the objectid for the specified type permission">
		<cfargument name="typename" type="string" required="true" hint="The content type" />
		<cfargument name="permission" type="string" required="true" hint="The permission name" />
		
		<cfif permissionExists("#arguments.typename##arguments.permission#")>
			<cfreturn getID("#arguments.typename##arguments.permission#") />
		<cfelseif permissionExists("generic#arguments.permission#")>
			<cfreturn getID("generic#arguments.permission#") />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>
	
	<cffunction name="getTypePermissionType" access="public" output="false" returntype="string" hint="Returns the type for a type permission, an empty string if it isn't one">
		<cfargument name="objectid" type="string" required="false" hint="The objectid of the permission to check" />
		<cfargument name="stObject" type="struct" required="false" hint="The permission to check" />
		
		<cfset var shortcut = "" />
		<cfset var thistype = "" />
		
		<cfif structkeyexists(arguments,"objectid")>
			<cfset shortcut = getData(objectid=arguments.objectid).shortcut />
		<cfelse>
			<cfset shortcut = arguments.stObject.shortcut />
		</cfif>
		
		<cfloop collection="#application.stCOAPI#" item="thistype">
			<cfif application.stCOAPI[thistype].class eq "type" and refindnocase("^#thistype#",shortcut)>
				<cfreturn thistype />
			</cfif>
		</cfloop>
		
		<cfreturn "" />
	</cffunction>
	
	<cffunction name="getID" access="public" output="false" returntype="string" hint="Returns the objectid for the specified object">
		<cfargument name="name" type="string" required="true" hint="Pass in a permission name and the objectid will be returned" />
		
		<cfset var qPermissions = "" />
		
		<cfif not application.security.hasLookup(permission=arguments.name)>
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select	objectid
				from	#application.dbOwner#farPermission
				where	lower(shortcut)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.name)#" />
			</cfquery>
			
			<cfif qPermissions.recordcount>
				<cfreturn application.security.setLookup(permission=arguments.name,objectid=qPermissions.objectid[1]) />
			<cfelse>
				<cfreturn "" />
			</cfif>
		<cfelse>
			<cfreturn application.security.getLookup(permission=arguments.name) />
		</cfif>
	</cffunction>
	
	<cffunction name="getLabel" access="public" output="false" returntype="string" hint="Returns the label for the specified object">
		<cfargument name="objectid" type="uuid" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qPermissions = "" />
		
		<cfquery datasource="#application.dsn#" name="qPermissions">
			select	shortcut
			from	#application.dbOwner#farPermission
			where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<cfreturn qPermissions.shortcut[1] />
	</cffunction>	

	<cffunction name="setData" access="public" output="true" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	
		
		<cfset var qRoles = "" />
		<cfset var qBarnacles = "" />
		<cfset var stRole = structnew() />
		<cfset var stO = structnew() />
		
		<cfif structKeyExists(arguments.stProperties, "aRelatedTypes") AND arraylen(arguments.stProperties.aRelatedtypes)>
			<!--- Find related role-permissions --->
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	parentid as objectid, seq
				from	#application.dbowner#farRole_aPermissions
				where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stProperties.objectid#" />
			</cfquery>
			
			<!--- Find barnacles with types not in the new list --->
			<cfquery datasource="#application.dsn#" name="qBarnacles">
				select	objectid,referenceid,roleid,barnaclevalue,objecttype,permissionID
				from	#application.dbowner#farBarnacle
				where	permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stProperties.objectid#" />
						and objecttype not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arraytolist(arguments.stProperties.aRelatedtypes)#" />)
			</cfquery>
			
			<!--- Remove barnacles --->
			<cfloop query="qBarnacles">
				<cfset application.security.factory.barnacle.delete(objectid=qBarnacles.objectid[currentrow]) />
				
				<!--- Update permissions on objects --->
				<cfif qBarnacles.barnaclevalue neq 1>
					<cfparam name="stO.#qBarnacles.objecttype#" default="#application.fapi.getContentType(typename=qBarnacles.objecttype)#" />
					<cfset stO[qBarnacles.objecttype].onSecurityChange(changetype="object",objectid=qBarnacles.referenceid,typename=qBarnacles.objecttype,farRoleID=qBarnacles.roleid,farPermissionID=qBarnacles.permissionid,oldright=qBarnacles.barnaclevalue,newright=1) />
				</cfif>
			</cfloop>
		<cfelse>
			<!--- Find related barnacles --->
			<cfquery datasource="#application.dsn#" name="qBarnacles">
				select	*
				from	#application.dbowner#farBarnacle
				where	permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stProperties.objectid#" />
			</cfquery>
		</cfif>
		
		<!--- Remove objectid lookup --->
		<cfset application.security.initCache() />

		<cfreturn super.setData(argumentCollection="#arguments#") />
	</cffunction>
	
	<cffunction name="getAllPermissions" access="public" output="false" returntype="string" hint="Returns a list of all permissions (optionally restricted by related type)">
		<cfargument name="relatedtype" type="string" required="false" hint="The type to restrict permissions by" />
		
		<cfset var qPermissions = "" />
		
		<cfif not structkeyexists(arguments,"relatedtype")>
			<!--- Get all permissions --->
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select		objectid
				from		#application.dbowner#farPermission
				order by	title asc
			</cfquery>
		<cfelseif arguments.relatedtype eq "">
			<!--- Get all general permissions --->
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select		objectid
				from		#application.dbowner#farPermission
				where		objectid not in (
								select distinct parentid
								from	#application.dbowner#farPermission_aRelatedtypes
							)
				order by	title asc
			</cfquery>
		<cfelse>
			<!--- Get type specific permissions --->
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select		p.objectid
				from		#application.dbowner#farPermission p
							inner join
							#application.dbowner#farPermission_aRelatedtypes pt
							on p.objectid=pt.parentid
				where		pt.data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.relatedtype#" />
				order by	title asc
			</cfquery>
		</cfif>
		
		<cfreturn valuelist(qPermissions.objectid) />
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Removes any corresponding entries in farRole and farBarnacle" returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<cfset var qRoles = "" />
		<cfset var qBarnacles = "" />
		<cfset var stRole = structnew() />
		<cfset var stPermission = getData(objectid=arguments.objectid) />
		<cfset var stO = structnew() />
		
		<!--- Find related role-permissions --->
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	parentid as objectid, seq
			from	#application.dbowner#farRole_aPermissions
			where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>		
		
		<!--- Remove them from the roles --->
		<cfloop query="qRoles">
			<!--- Delete the permission --->
			<cfset stRole = application.security.factory.role.getData(qRoles.objectid[currentrow]) />
			<cfset arraydeleteat(stRole.aPermissions,qRoles.seq[currentrow]) />
			<cfset application.security.factory.role.setData(stRole) />
		</cfloop>
		
		<!--- Find related barnacles --->
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select	*
			from	#application.dbowner#farBarnacle
			where	permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<!--- Remove barnacles --->
		<cfloop query="qBarnacles">
			<cfset application.security.factory.barnacle.delete(objectid=qBarnacles.objectid[currentrow]) />
				
			<!--- Update permissions on objects --->
			<cfif qBarnacles.barnaclevalue neq 1>
				<cfparam name="stO.#qBarnacles.objecttype#" default="#application.fapi.getContentType(typename=qBarnacles.objecttype)#" />
				<cfset stO[qBarnacles.objecttype].onSecurityChange(changetype="object",objectid=qBarnacles.referenceid,typename=qBarnacles.objecttype,farRoleID=qBarnacles.roleid,farPermissionID=qBarnacles.permissionid,oldright=qBarnacles.barnaclevalue,newright=1) />
			</cfif>
		</cfloop>
		
		<!--- Remove name lookup --->
		<cfset application.security.removeLookup(permission=arguments.objectid) />
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,auditNote=arguments.auditNote) />
	</cffunction>
	
</cfcomponent>