<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfparam name="attributes.nodetype" default="dmNavigation"> 


<cffunction name="checkForDraft" hint="checks to see if object has a draft version">
	<cfargument name="stObject" required="true">
		<cfquery datasource="#application.dsn#" name="qHasDraft">
			SELECT objectID,status from #application.dbowner##stObject.typename# where versionID = '#stObject.objectID#' 
		</cfquery>
		<cfif qHasDraft.recordcount EQ 1 >
			<cfscript>
				result = structNew();
				result.objectID = qHasDraft.objectID;
				result.status = qHasDraft.status;
			</cfscript>
		<cfelse>
			<cfscript>
				result = structNew();
				result.objectID = 0;
				result.status = 'na';
			</cfscript>
		</cfif>
		<cfreturn result>
</cffunction>		
	

<cffunction name="mungeobjects">
<!--- this is crack - if you have to smoke it talk to grb first --->
	<cfargument name="stObjs" required="Yes">
	<cfloop collection="#stObjs#" item="key">
		<cfscript>
			if (StructKeyExists(stObjs['#key#'], "CREATEDBY"))
				stObjs['#key#'].ATTR_CREATEDBY = stObjs['#key#'].createdby;
			if (StructKeyExists(stObjs['#key#'], "DATETIMECREATED"))
				stObjs['#key#'].ATTR_DATETIMECREATED = stObjs['#key#'].datetimecreated;
			if (StructKeyExists(stObjs['#key#'], "LASTUPDATEDBY"))
				stObjs['#key#'].ATTR_LASTUPDATEDBY = stObjs['#key#'].lastupdatedby;
			if (StructKeyExists(stObjs['#key#'], "DATETIMELASTUPDATED"))
				stObjs['#key#'].ATTR_DATETIMELASTUPDATED = stObjs['#key#'].datetimelastupdated;
			
			
			
			typename = stObjs['#key#'].typename;
		
		// if navigation item smoke the object up with some aNavChild entries
		if (typename is attributes.nodetype) { 
			oTree = createObject("component","#application.packagepath#.farcry.tree");
			qChildren = oTree.getChildren(objectid=key);
			stObjs['#key#'].aNavChild = ListToArray(ValueList(qChildren.ObjectID));
			if (NOT ArrayLen(stObjs['#key#'].aNavChild))
				stObjs['#key#'].aNavChild = ""; // tree seems to barf on empty array
			if (NOT ArrayLen(stObjs['#key#'].aObjectIDs))
				stObjs['#key#'].aObjectIDs = ""; // tree seems to barf on empty array	
		 }
		 if (StructKeyExists(stObjs['#key#'], "VERSIONID") AND StructKeyExists(stObjs['#key#'], "STATUS"))
		 {
		 	if (stObjs['#key#'].status IS "approved")
			{
				draftObject = checkForDraft(stObjs['#key#']);
				if (draftObject.objectID NEQ 0)
				{
					stObjs['#key#'].BHASDRAFT = 1;
					stObjs['#key#'].DRAFTOBJECTID = draftObject.objectID;
					stObjs['#key#'].DRAFTSTATUS = draftObject.status;
				}
			}
		}	
	 		
		 	
		</cfscript>
	</cfloop>
	<!--- <cfdump var="#stObjs#">	 --->
	<cfreturn stObjs>
</cffunction>






<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/treeData.cfm,v 1.19 2005/02/07 23:24:23 spike Exp $
$Author: spike $
$Date: 2005/02/07 23:24:23 $
$Name: milestone_3-0-1 $
$Revision: 1.19 $

|| DESCRIPTION || 
Retrieves object(s) [and relations] information and returns it in js format.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> [attributes.lObjectIds]: list of objectIds to grab.
-> [attributes.get]: What to retrieve, can be ancestors, descendants, children.
-> [attributes.stripFields]: Fields that are too long to return are stripped
<- [attribute.r_javascript]: caller variable to return javascript code to

|| HISTORY ||
$Log: treeData.cfm,v $
Revision 1.19  2005/02/07 23:24:23  spike
Added site tree custom icon overlay for dmNavigation that has an external link associated with it. Icon overlay is the same as the one for dmInclude.

Revision 1.18  2004/08/07 09:17:51  geoff
Removed some very old Spectra COAPI integration code, and added support for fourq.getdata() bshallow option.  This should improve tree performance by not retrieving longtext field properties for objects in the tree.

Revision 1.17  2004/07/15 02:03:00  brendan
i18n updates

Revision 1.15  2003/12/01 05:41:30  paul
Removed reference to oTree in app scope and instatiated on this page instead. Seemed to fix weirdness.

Revision 1.14  2003/11/17 07:56:40  paul
Removal of setVariable functions.

Revision 1.13  2003/10/28 06:48:56  paul
Some fairly drastic changes to the way the tree is updated after a move. Consider this beta!

Revision 1.12  2003/10/08 09:01:45  paul
Large number of changes that will allow you to use tree code and functionality with any 'nodetype'. By default dmnavigation tree is rendered.

Revision 1.11  2003/08/08 04:23:36  brendan
tree calls to reference application.factory object

Revision 1.10  2003/04/09 08:04:59  spike
Major update to remove need for multiple ColdFusion and webserver mappings.

Revision 1.9  2003/04/08 08:47:39  paul
CFC security updates

Revision 1.8  2003/02/10 04:01:24  geoff
Updates to inlcude application.dbowner vars in <cfquery>

Revision 1.7  2003/01/20 00:49:38  pete
changed request.stLoggedInUser to session.dmSec.authentication

Revision 1.6  2002/10/30 23:26:45  brendan
removed call to application.fourq.packagepath

Revision 1.5  2002/10/29 01:32:32  brendan
modified draft object id fields

Revision 1.4  2002/10/16 07:20:57  brendan
moved tree code out of fourq and into core

|| END FUSEDOC ||
--->

<cfparam name="attributes.lObjectIds">
<cfparam name="attributes.get">
<cfparam name="attributes.lStripFields" default="">
<cfparam name="attributes.topLevelVariable">

<cfparam name="attributes.r_javascript">

<!--- string to hold the output javascript --->
<cfset jsout = "">
<cfset stAllObjects = structNew()>

<cfloop index="objectId" list="#attributes.lObjectIds#">
	<cfif len(objectId) eq 35 OR objectId eq '0'>
	<cfinvoke component="farcry.core.packages.fourq.fourq" returnvariable="thisTypename" method="findType" objectID="#ObjectId#">
	
	<!--- get all objects that pertain to get --->

	<nj:treeGetRelations typename="#thisTypename#" objectId="#objectId#" get="#attributes.get#" bInclusive="1" r_stObjects="stObjects" nodetype="#attributes.nodetype#">
	<!--- begin: munge object structure to reflect f# --->
	<cfset stobjects = mungeobjects(stObjects)>
	<!--- end: munge object structure to reflect f# --->
		
	<cfscript>
	// loop through the returned objects and get the aObjectIds
	stCheckObjects = stObjects;
	
	lObjectIds = "";
	
	for( objId in stCheckObjects )
	{	
		if( structKeyExists( stCheckObjects[objId], "aObjectIds" ) ){
			if ( isArray(stCheckObjects[objId].aObjectIds) )
				lObjectIds = listAppend( lObjectIds, ArrayToList( stCheckObjects[objId].aObjectIds ) );
		}		
	}
	</cfscript>
		
	
	<q4:contentobjectGetMultiple bActive="0" lObjectIds="#lObjectIds#" r_stObjects="stNewObjects" bshallow="true">

	<!--- begin: munge object structure to reflect f# --->
	<cfset stNewobjects = mungeobjects(stNewObjects)>
	<!--- end: munge object structure to reflect f# --->

	<cfscript>
	stCheckObjects = stNewObjects;
	StructAppend( stObjects, stNewObjects, "Yes" );

	// now strip fields
	// duplicate stObjects so we dont screw up the request cache(cachitron)
	stObjects = duplicate(stObjects);

	for( objId in stObjects)
	{
		s = stObjects[ objId ];
		if( structKeyExists( s, "ATTR_DATETIMECREATED" ) )
				s["ATTR_DATETIMECREATED"] = DateFormat(s["ATTR_DATETIMECREATED"])&" "&TimeFormat(s["ATTR_DATETIMECREATED"]);
		if( structKeyExists( s, "ATTR_DATETIMELASTUPDATED" ) )
				s["ATTR_DATETIMELASTUPDATED"] = DateFormat(s["ATTR_DATETIMELASTUPDATED"])&" "&TimeFormat(s["ATTR_DATETIMELASTUPDATED"]);
			
		for( index=1; index lte listLen(attributes.lStripFields); index=index+1 )
		{
			listItem = listGetAt( attributes.lStripFields, index );
			if( structKeyExists( s, listItem ) ) StructDelete( s, listItem );
		}
	}
	
	StructAppend( stAllObjects, stObjects, "Yes" );
	</cfscript>
		
</cfif>	
</cfloop>

<!--- This cfloop block basically blocks all children of dmHTML objects, and filters the tree by the
lAllowTypes list
 --->
<cfset lAllowTypes = "dmHTML,#attributes.nodetype#,dmInclude">
<cfloop collection="#stAllObjects#" item="objID">
	<cfoutput>
	<cfif structKeyExists(stAllObjects[objId], "aObjectIds" )  AND stAllObjects[objID].typename IS "dmHTML">
		
		<cfif isArray(stAllObjects[objId].aObjectIDs) AND arrayLen(stAllObjects[objId].aObjectIDs) GT 0>
			<cfloop from="#arrayLen(stAllObjects[objId].aObjectIDs)#" to="1" index="i" step="-1">
				<cfinvoke component="farcry.core.packages.fourq.fourq" method="findType" returnvariable="rTypeName" objectID="#stAllObjects[objID].aObjectIds[i]#">
				
				<cfif NOT listContainsNoCase(lAllowTypes,rTypeName) AND stAllObjects[objID].typename IS "dmHTML">
					 <cfset tmp = arrayDeleteAt(stAllObjects[objID].aObjectIds,i)> 
				</cfif>
			</cfloop>
				
		</cfif>
		<cfif isArray(stAllObjects[objID].aObjectIds)>
			<cfif NOT arrayLen(stAllObjects[objID].aObjectIDs)>
				<cfset stAllObjects[objID].aObjectIDs = "">
			</cfif>	
		</cfif>
	</cfif>
	<cfif NOT listContainsNoCase(lAllowTypes,stAllObjects[objID].typename) AND stAllObjects[objID].typename IS "dmHTML">
		<cfset temp = structDelete(stAllObjects,objID)>
	</cfif>
		
	</cfoutput>
</cfloop>


<!--- convert to wddx and return --->

<nj:WDDXToJavascript input="#stAllObjects#" output="jsout" toplevelvariable="#attributes.topLevelVariable#">

<!--- Generate the permissions data and append to jsout --->
<!--- for all the navigation objectIds generated, get the permissions structures --->
<!--- first get a list of filtered objectIds by navType --->
<cfset lNavIds = "">

<cfloop index="objId" list="#structKeyList(stAllObjects)#">
<!--- 
TODO
work out suitable solution for reserved names like "typename" 
--->
	<cfif stAllObjects[objId].typename IS attributes.nodetype>
	
	<!--- this may be slow, might have to pull from cache myself --->
	<cfscript>
	stObjectPermissions = application.factory.oAuthorisation.collateObjectPermissions(objectID=objID);
	
	mergePerms=StructNew();
	
	for( i=1; i lte ListLen( session.security.roles ); i=i+1 )
	{
		policyGroupId=ListGetAt(session.security.roles,i);
		
		if( structKeyExists( stObjectPermissions, policyGroupId) )
			stPolicyGroup = stObjectPermissions[policyGroupId];
			else continue;
		
		for( permissionName in stPolicyGroup)
		{	
			if( not StructKeyExists(mergePerms,permissionName) )
				 mergePerms[permissionName]=0;
			if( mergePerms[permissionName] eq 0 )
				 mergePerms[permissionName]=stPolicyGroup[permissionName].T;
			if( mergePerms[permissionName] eq -1 AND stPolicyGroup[permissionName].T eq 1 )
				mergePerms[permissionName]=1;
		}
	}
	
	outstring="";
	
	// only write out if the permission has been given or taken away, i.e. ignore inherited
	for( code in mergePerms )
	{
		outstring=outstring&"pt['#code#']=#mergePerms[code]#;";
	}
	
	if(len(outstring)) jsout=jsout&"pt=new Object();p['#objId#']=pt;"&outstring;
	
	</cfscript>
	</cfif>
</cfloop>


<cfset "caller.#attributes.r_javascript#" = jsout>

<cfif isDefined("attributes.r_lObjectIds")>
<cfset "caller.#attributes.r_lObjectIds#" = structKeyList(stAllObjects)>
</cfif>

<cfif isDefined("attributes.r_stObjects")>
	<cfset "caller.#attributes.r_stObjects#" = stAllObjects>
</cfif>

<cfsetting enablecfoutputonly="No">