<cfsetting enablecfoutputonly="Yes" />
<cfprocessingDirective pageencoding="utf-8" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/conjuror/evocation.cfm,v 1.11 2005/09/08 23:32:54 gstewart Exp $
$Author: gstewart $
$Date: 2005/09/08 23:32:54 $
$Name: milestone_3-0-0 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: 
Central page for Object Creation
 - midway refactoring
 - creates an instance of any type based object and returns to central invocation URL
 - Hoping to replace ../navajo/createobject.cfm with this template.
  
evocation n.
   1. The act of evoking.
   2. Creation anew through the power of the memory or imagination.
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- include tag libraries --->
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<!--- include function libraries --->
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<!--- required parameters --->
<cfparam name="url.typename" type="string">

<!--- optional parameters --->
<cfparam name="url.objectId" default="">
<cfparam name="url.nodetype" default="dmNavigation"><!--- deprecated: backward compatability --->
<cfparam name="url.parenttype" default="#url.nodetype#">
<cfparam name="url.parentproperty" default="aobjectids">
<cfparam name="url.method" default="edit">

<!--- 
Parent Object: URL.OBJECTID
	if objectid is specified, it means we're attempting to attach the new object 
	we're trying to create to this objectid.  typically this would be a dmnavigation 
	parent.  however, it would be nice if this could be any parent content type.
	
	At the moment, its whatever is specified in URL.nodetype AND that the content type has
	an aObjectIDs property field.
 --->
<cfif len(url.objectId)>
	<!--- get the data for the object --->
	<q4:contentobjectget objectid="#url.objectId#" bactiveonly="False" r_stobject="stParent">
<cfelse>
	<!--- create empty stparent --->
	<cfset stparent=structnew()>
</cfif>

<!--- 
	make sure parent content type can hold an object before doing anything 
	ie. by default checks aObjectIDs is a property
 --->	
<cfif len(url.objectId) AND not structKeyExists(stParent,url.parentproperty)>
	<cfthrow type="evocation" message="<strong>Error:</strong> #application.adminBundle[session.dmProfile.locale].noaObjectIds#">
<cfelse>
<!--- populate stproperties with default values from component metadata --->
	<!--- default properties (common to all types) --->
	
	<cfset stProps=structNew()>
	<cfset stProps.objectid = createUUID()>
	<cfset stProps.label = "(incomplete)">
	<cfset stProps.title = "">
	<cfset stProps.lastupdatedby = session.dmSec.authentication.userlogin>
	<cfset stProps.datetimelastupdated = Now()>
	<cfset stProps.createdby = session.dmSec.authentication.userlogin>
	<cfset stProps.datetimecreated = Now()>
	<cfset stProps.ownedby = session.dmProfile.objectid>
	<cfset stDefaultProperties = application.types[url.typename].stProps>
	
	<!--- loop through the default content type properties --->
	<cfloop collection="#stDefaultProperties#" item="propertie">
		<!--- check if date type, and set default to the default assigned OR to now() --->
		<cfif stDefaultProperties[propertie].metadata.type EQ "date">
			<cfif IsDate(stDefaultProperties[propertie].metadata.default)>
				<cfset stProps[propertie] = stDefaultProperties[propertie].metadata.default>
			<cfelse>
				<cfswitch expression="#url.typename#">
					<cfcase value="dmNews">
						<!--- set a default expiry date --->
						<cfif propertie eq "expiryDate">
							<cfset stProps[propertie] =DateAdd(application.config.general.newsExpiryType,application.config.general.newsExpiry,"#now()#")>
						<cfelse>
							<cfset stProps[propertie] = CreateODBCDate(now())>
						</cfif>
					</cfcase>
					<cfcase value="dmEvent">
						<!--- set a default expiry date --->
						<cfif propertie eq "expiryDate">
							<cfset stProps[propertie] =DateAdd(application.config.general.eventsExpiryType,application.config.general.eventsExpiry,"#now()#")>
						<cfelse>
							<cfset stProps[propertie] = CreateODBCDate(now())>
						</cfif>
					</cfcase>
					<cfdefaultcase>
						<cfset stProps[propertie] = CreateODBCDate(now())>
					</cfdefaultcase>
				</cfswitch>
			</cfif>
		<cfelse>
			<cfif stDefaultProperties[propertie].metadata.required AND NOT StructKeyExists(stProps, propertie) AND stDefaultProperties[propertie].metadata.type neq "array"> 
				<!--- set to the default if it is not already defined above --->
				<cfif StructKeyExists(stDefaultProperties[propertie].metadata, "default")>
					<cfset stProps[propertie] = stDefaultProperties[propertie].metadata.default>
				<cfelse>
					<!--- if property is required and has no default value or passed in value throw error --->
					<cfthrow type="evocation" message="#propertie# is a required property and no default value is specified.">
				</cfif>
			</cfif>
		</cfif>
	</cfloop>


	<!--- create object instance --->
	<cfset oType = createobject("component", application.types[url.typename].typePath)>
	<cfset stNewObj = oType.createData(stProperties=stProps)>
	<cfset NewObjId = stNewObj.objectid>
	
	<!--- if object creation fails -- halt processing and output debugging --->
	<cfif NOT stNewObj.bsuccess>
		<cfdump var="#stnewobj#">
		<cfabort>
	</cfif>
			
	<!--- 
	Parent Reference:
		update reference to parent object  
	--->
	<!--- does the reference already exist? if so there is a problem. --->
	<cfif structkeyexists(stparent, url.parentproperty)>
		<cfset lrefobjectids=arraytolist(evaluate("stParent.#url.parentproperty#"))>
		<cfif len(url.objectId) AND lrefobjectids contains NewObjID>
			<cfthrow type="evocation" message="The object #NewObjID# is already referenced by parent object #stparent.objectid#.">
		</cfif>
	</cfif>
	
	<!--- now attach the object to the specified parent --->
	<cfif len(url.objectId)>
		<cfif url.typename IS url.parenttype>
		<!--- relationship is same content type, eg dmnavigation and dmnavigation --->
			<cfif NOT stParent.typename IS url.parenttype>
				<!--- if content typs of parent is not actually the spcified parenttype then fail --->
				<cfthrow type="evocation" message="#application.adminBundle[session.dmProfile.locale].cantCreateNavObj#">
			<cfelse>
				<!--- TODO: 
						we're assuming this is an NTM based content type and it might not be. 
						test for known NTM types (dmNavigation,categories) and fail if its 
						different for now.
				--->
				<cfif "dmNavigation,categories" DOES NOT CONTAIN stparent.typename>
					<cfthrow type="evocation" message="Evocation reference attachment only supports known NTM types: dmNavigation and categories.">
				</cfif>
				<!--- otherwise, insert this node into the tree --->
				<cfscript>
					qChildren = request.factory.oTree.getChildren(objectid=stParent.objectID,typename=stParent.typename);
					position = qChildren.recordCount + 1;
					streturn = request.factory.oTree.setChild(objectName=stProps.label,typename=typename,parentID=stParent.objectID,objectID=newObjId,pos=position);
				</cfscript>
				</cfif>
		<cfelse>
			<!--- Append new ObjectIDs to AObjects array --->
			<cfscript>
				arrayAppend(evaluate("stParent.#url.parentproperty#"), NewObjID);
				stParent.DATETIMELASTUPDATED = createODBCDate(now());
				oParentType = createobject("component", application.types[stParent.typename].typePath);
				oParentType.setData(stProperties=stParent);
			</cfscript>
		</cfif>
			
		<cfif len(stParent.objectID)>
			<!--- output JS to refresh the overview tree --->
			<nj:updateTree objectId="#stParent.objectID#" complete="0">
		</cfif>
	</cfif>
	
	<!--- Now that we know its type and new objectID go and edit the object --->
	<cfscript>
	// from utility library
	st = filterStructure(URL,'objectid,nodetype,parenttype,parentproperty');
	queryString=structToNamePairs(st); 
	</cfscript>

	<!--- redirect to the edit handler for this content item --->
	<cfoutput>
		<script type="text/javascript">
			window.location="#application.url.farcry#/conjuror/invocation.cfm?objectId=#NewObjID#&#queryString#";
		</script>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="No">