<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">


<cfset 	resultmsg = "#application.adminBundle[session.dmProfile.locale].draftObjRestoreFailed#">

<cftry>

	<cfscript>
		//check permissions on objects nav parent
		bEdit = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#URL.navid#",permissionName="edit");
	</cfscript>
	<!--- Get draft object --->
	<cfif bEdit>
		<q4:contentobjectget objectId="#URL.objectId#" r_stObject="stObj">
		<!--- get live object --->
		<cfif structKeyExists(stObj,'versionID') AND len(trim(stObj.versionID)) EQ 35>
			<q4:contentobjectget objectId="#stObj.versionid#" r_stObject="stLiveObj">
			
			<cfscript>
				lExcludeKeys = 'objectid,versionid,datetimecreated,createdby,datetimelastupdated,lastupdatedby,lockedBy,locked,status';
				
				for(key IN stObj)
				{
					if (NOT listFindNoCase(lExcludeKeys,key))
					{
						stObj[key] = stLiveObj[key];	
					}
					else
					{
						if(NOT key IS 'objectid')
							structDelete(stObj,key);
					}		
					
				}
				stObj.datetimelastupdated = createODBCDateTime(now());
				o = createObject('component',application.types[stobj.typename].typepath);
				o.setData(stProperties=stObj,auditNote='Live object data restored to draft',bAudit=true);
				resultmsg = '#application.adminBundle[session.dmProfile.locale].liveObjRestoredOK#';
			</cfscript>
		</cfif>
	</cfif>
	
	
	<cfoutput>
	<script>
		if(parent.restoreResult)
			parent.restoreResult('#resultmsg#');		
	</script>
	</cfoutput>
	<cfcatch>
		<cfoutput>
			<script>
				if(parent.restoreResult)
					parent.restoreResult('#resultmsg#');		
			</script>
		</cfoutput>	
		<cfdump var="#cfCatch#">
	</cfcatch>

</cftry>
<!--- Need to try and delete the PLP if it exists - relies on people sticking to this naming convention though so not rock solid. --->
<cftry>
	<cffile action="DELETE" file="#application.path.plpstorage#/#session.dmSec.authentication.userlogin#_#stObj.objectID#.plp">
	<cfcatch><!--- dont do anything ---></cfcatch>
</cftry>


