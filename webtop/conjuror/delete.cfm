<!--- 
merge of ../admin/navajo/delete.cfm and ../tags/navajo/delete.cfm
 --->
<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<cfif isDefined("URL.objectID")>
	
	<!--- Get the object --->
	
	<q4:contentobjectget objectid="#url.ObjectId#" r_stobject="stObj">
	
	<sec:CheckPermission permission="Edit" type="#stObj.typename#" objectid="#url.objectid#">
	
		<!--- This gets the parent object -- need this to clean up its reference to the object we are deleting --->
		<cfscript>
			oType = createObject("component", application.types[stObj.typename].typePath);
			oNav = createObject("component", application.types.dmNavigation.typePath);
			if (stObj.typename IS 'dmNavigation')
			{
				qGetParent = application.factory.oTree.getParentID(objectID = stObj.objectID);
				parentObjectID = qGetParent.parentID;	
			}
			else
			{
			// likely to be a parent object with aObjects property (eg. dmHTML, dmNews)
				qGetParent = oNav.getParent(objectid=stObj.objectID);
				parentObjectID = qGetParent.objectID;
			}
		</cfscript>
		
		<!--- get the parentID --->
		<q4:contentobjectget objectid="#parentObjectId#" r_stobject="srcObjParent">
		
		<cfif NOT stObj.typename IS "dmNavigation">
			<cfset key = 'aobjectids'>
			<cfloop index="i" from="#ArrayLen(srcObjParent[key])#" to="1" step="-1">
				<cfif srcObjParent[key][i] eq stObj.objectId>
					<cfset ArrayDeleteAt( srcObjParent[key], i )>
				</cfif>
			</cfloop>
			<cfscript>
				// $TODO: may want to check if this is necessary, implies that date value has been changed on get. GB$
				srcObjParent.datetimecreated = createODBCDate("#datepart('yyyy',srcObjParent.datetimecreated)#-#datepart('m',srcObjParent.datetimecreated)#-#datepart('d',srcObjparent.datetimecreated)#");
				srcObjParent.datetimelastupdated = createODBCDate(now());
				
				// update the parent object instance
				oParentType = createobject("component", application.types[srcObjParent.typename].typePath);
				oParentType.setData(stProperties=srcObjParent,auditNote="Child deleted");	
			</cfscript>
			<!--- $TODO: may need to remove typename attribute and force a lookup -- what if it's a custom type? GB$ --->
		</cfif>	
		
		<!--- type specific delete options --->
		<cfscript>
			oType.delete(stObj.objectId);
		</cfscript>
		
		<!--- Update the tree view --->
		<nj:updateTree objectId="#parentObjectID#"> 
		
		<!--- update overview page --->
		<cfoutput>
			<script>
					top['editFrame'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#parentObjectID#';
			</script>
		</cfoutput>
	
	</sec:CheckPermission>

<cfelse>
	<cfthrow detail="URL.objectID not passed">
</cfif>

<cfsetting enablecfoutputonly="No">