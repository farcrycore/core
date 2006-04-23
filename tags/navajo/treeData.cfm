<cfimport taglib="/farcry/fourq/tags" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">


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
			
		// add typeid
			typename = stObjs['#key#'].typename;
			//SetVariable("stObjs['#key#'].TYPEID", Evaluate("application.#typename#TypeID"));
		
		// if navigation item smoke the object up with some aNavChild entries
		if (typename is "dmNavigation") { 
			onav = createObject("component", "#application.packagepath#.farcry.tree");
			qChildren = onav.getChildren(objectid=key);
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
					SetVariable("stObjs['#key#'].BHASDRAFT",1);
					SetVariable("stObjs['#key#'].DRAFTOBJECTID",draftObject.objectID);
					SetVariable("stObjs['#key#'].DRAFTSTATUS",draftObject.status);
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
$Header: /cvs/farcry/farcry_core/tags/navajo/treeData.cfm,v 1.10 2003/04/09 08:04:59 spike Exp $
$Author: spike $
$Date: 2003/04/09 08:04:59 $
$Name: b131 $
$Revision: 1.10 $

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
moved tree code out of fourq and into farcry_core

Revision 1.3  2002/09/30 08:44:19  geoff
versioning updates for live objs (ph)

Revision 1.17  2002/09/30 07:38:59  geoff
no message

Revision 1.16  2002/09/12 07:11:11  geoff
no message

Revision 1.15  2002/09/10 04:53:37  geoff
no message

Revision 1.14  2002/09/05 00:52:20  geoff
no message

Revision 1.13  2002/09/04 23:14:39  geoff
no message

Revision 1.12  2002/09/04 04:52:42  geoff
no message

Revision 1.11  2002/08/29 03:37:30  geoff
no message

Revision 1.10  2002/08/26 03:43:13  geoff
no message

Revision 1.9  2002/08/22 00:09:38  geoff
no message

Revision 1.8  2002/07/26 04:12:02  geoff
no message

Revision 1.7  2002/07/18 04:39:44  geoff
no message

Revision 1.6  2002/07/17 07:46:51  geoff
no message

Revision 1.5  2002/07/16 07:25:00  geoff
*** empty log message ***

Revision 1.4  2002/07/09 04:36:37  geoff
no message

Revision 1.3  2002/06/28 03:49:31  geoff
f# object munge appears to be working now

Revision 1.2  2002/06/28 03:27:36  geoff
getting overview tree to happen

Revision 1.1.1.1  2002/06/27 07:30:11  geoff
Geoff's initial build


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
	<cfinvoke component="farcry.fourq.fourq" returnvariable="thisTypename" method="findType" objectID="#ObjectId#">
	
	<!--- get all objects that pertain to get --->

	<nj:treeGetRelations typename="#thisTypename#" objectId="#objectId#" get="#attributes.get#" bInclusive="1" r_stObjects="stObjects">
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
	
<!--- 	
	TODO
	need to implement bActive 
	lookup objectids without typename... otherwise tree will just be navids (typename="#application.packagepath#.types.dmNavigation")
--->
	
	
	<q4:contentobjectGetMultiple bActive="0" lObjectIds="#lObjectIds#" r_stObjects="stNewObjects">

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
<cfset lAllowTypes = "dmHTML,dmNavigation,dmImage,dmInclude">
<cfloop collection="#stAllObjects#" item="objID">
	<cfoutput>
	<cfif structKeyExists(stAllObjects[objId], "aObjectIds" )  AND stAllObjects[objID].typename IS "dmHTML">
		
		<cfif isArray(stAllObjects[objId].aObjectIDs) AND arrayLen(stAllObjects[objId].aObjectIDs) GT 0>
			<cfloop from="#arrayLen(stAllObjects[objId].aObjectIDs)#" to="1" index="i" step="-1">
				<cfinvoke component="farcry.fourq.fourq" method="findType" returnvariable="rTypeName" objectID="#stAllObjects[objID].aObjectIds[i]#">
				
				<cfif NOT listContainsNoCase(lAllowTypes,rTypeName) AND stAllObjects[objID].typename IS "dmHTML">			 <cfset tmp = arrayDeleteAt(stAllObjects[objID].aObjectIds,i)> 
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
	<cfif stAllObjects[objId].typename IS "dmNavigation">
	
	<!--- this may be slow, might have to pull from cache myself --->
	<cfscript>
		oAuthorisation = request.dmSec.oAuthorisation;
		stObjectPermissions = oAuthorisation.collateObjectPermissions(objectID=objID);
	</cfscript>
	
	<cfscript>
	mergePerms=StructNew();
	
	for( i=1; i lte ListLen( session.dmSec.authentication.lPolicyGroupIds); i=i+1 )
	{
		policyGroupId=ListGetAt(session.dmSec.authentication.lPolicyGroupIds,i);
		
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




















