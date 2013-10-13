<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
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
<cfcomponent name="dmNavigation" extends="types" displayname="Navigation" 
	hint="Navigation nodes are combined with the ntm_navigation table to build the site layout model for the FarCry CMS system." 
	bUseInTree="1" bFriendly="1" bObjectBroker="true"
	icon="icon-folder-open">
	<!------------------------------------------------------------------------
	type properties
	------------------------------------------------------------------------->	
	<cfproperty name="title" type="nstring" required="no" default=""  hint="Object title.  Same as Label, but required for overview tree render."
		ftSeq="1" ftFieldSet="General Details" ftLabel="Navigation Menu Title" 	 
		ftHint="The navigation title is used when building the navigation menu for your website. Consider using a short menu title." />
	
	<cfproperty name="target" type="string" hint="The target of the navigation." required="no" default="" ftDefault="_self"
		ftSeq="5" ftFieldSet="Navigation Behaviour" ftLabel="Link target" 
		ftType="list" ftList="_self:Current window,_blank:New window" />
	
	<cfproperty name="navType" type="string" hint="The behaviour of this navigation node." required="true" default="aObjectIDs" ftDefault="aObjectIDs"
		ftSeq="6" ftFieldSet="Navigation Behaviour" ftLabel="Choose Navigation Behaviour"
		ftType="list" ftList="aObjectIDs:Normal Content (Recommended),internalRedirectID:Internal Redirect,externalRedirectURL:External Redirect,ExternalLink:Mirror Content" />
	
	<cfproperty name="aObjectIDs" type="array" hint="Holds objects to be displayed at this particular node.  Can be of mixed types." required="no" default="" 
		ftSeq="7" ftFieldSet="Navigation Behaviour" ftLabel="Content" ftHint="Select the type of content to appear when the visitor browses to this navigation item. If you select this option, you will be automatically redirected to edit the new content item."
		ftJoin="dmHTML" />
	
	<cfproperty name="internalRedirectID" type="uuid" hint="The internal object to redirect to." required="no" default=""
		ftSeq="8" ftFieldSet="Navigation Behaviour" ftLabel="Internal Redirect" ftHint="Redirect the user to the selected content."
		ftType="uuid" ftJoin="dmNavigation" />
	
	<cfproperty name="externalRedirectURL" type="string" hint="The internal object to redirect to." required="no" default=""
		ftSeq="9" ftFieldSet="Navigation Behaviour" ftLabel="External Redirect" ftHint="Redirect the user to the selected URL."
		ftType="url" />
	
	<cfproperty name="ExternalLink" type="uuid" hint="Used to store nav alias redirection reference." required="no" default=""
		ftSeq="10" ftFieldSet="Navigation Behaviour" ftLabel="Mirror Selected Item" ftHint="Show selected content instead of the children of this navigation item."
		ftType="uuid" ftJoin="dmNavigation" />
	
	<cfproperty name="lNavIDAlias" type="string" hint="A Nav alias provides a human interpretable link to this navigation node.  Each Nav alias is set up as key in the structure application.navalias.<i>aliasname</i> with a value equal to the navigation node's UUID." required="no" default="" 
		ftSeq="15" ftFieldSet="Advanced" 
		ftLabel="Alias"
		ftHint="The alias is an advanced option that can be used to programatically reference this navigation item." />
	
	
	
	<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft" ftLabel="Status" />

	<!---
	deprecated type properties
	------------------------------------------------------------------------->
	<cfproperty name="options" type="string" hint="DEPRECATED: No idea what this is for." required="no" default="" />
	<cfproperty name="fu" type="string" hint="DEPRECATED: Friendly URL for this node. Use FU sub-system instead." required="no" default="" />
		
	<!------------------------------------------------------------------------
	object methods 
	------------------------------------------------------------------------->
	<cffunction name="getExternalLinks" access="public" returntype="query" output="false" hint="Returns a list of all navigation nodes in the system with an alias">
	
		<cfset var oNav = createObject("component", application.stcoapi["dmNavigation"].packagePath) />
		<cfset var i = "" />
		<cfset var j = "" />
		<cfset var q = queryNew("value,name") />
		<cfset var stNav	= '' />
		
		<cfset queryaddrow(q,1) />
		<cfset querysetcell(q, "value", "") />
		<cfset querysetcell(q, "name", "#application.rb.getResource('coapi.dmNavigation.properties.externallink@nooptions','-- None --')#") />
		
		<cfloop collection="#application.navid#" item="i">
			<cfloop list="#application.navid[i]#" index="j">
				<cfset stNav = oNav.getData(objectid="#j#") />
				<cfset queryaddrow(q,1) />
				<cfset querysetcell(q, "value", j) />
				<cfset querysetcell(q, "name", "#stNav.title# (#i#)") />	
			</cfloop>		
		</cfloop>
		
		<cfquery dbtype="query" name="q">
		SELECT *
		FROM q
		ORDER BY name
		</cfquery>

		<cfreturn q />
	</cffunction>
	
	
	
	<cffunction name="AfterSave" access="public" output="true" returntype="struct" hint="Called from ProcessFormObjects and run after the object has been saved.">
		<cfargument name="stProperties" required="yes" type="struct" hint="A structure containing the contents of the properties that were saved to the object.">
		
		<cflock scope="Application" timeout="20">
			<cfset application.navid = getNavAlias()>
		</cflock>
		
		<cfif structKeyExists(stProperties, "title")>
			<cfquery datasource="#application.dsn#">
			UPDATE #application.dbowner#nested_tree_objects 
			SET objectName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.title#">
			WHERE objectID = '#stProperties.ObjectID#'
			</cfquery>
		</cfif>
		
		<cfset application.fc.lib.objectbroker.flushTypeWatchWebskins(objectid=arguments.stProperties.objectid,typename=arguments.stProperties.typename) />
		
		<cfreturn stProperties />
	</cffunction>
			
				
	
	<cffunction name="getParent" access="public" returntype="query" output="false" hint="Returns the navigation parent of child (dmHTML page for example)">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of element needing a parent">
		<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
		
		<cfset var qGetParent	= '' />
		
		<cfquery name="qGetParent" datasource="#arguments.dsn#">
			SELECT parentid FROM #application.dbowner#dmNavigation_aObjectIDs
			WHERE data = '#arguments.objectid#'	
		</cfquery>
		
		<cfreturn qGetParent>
	</cffunction>
	
	<cffunction name="getChildren" access="public" returntype="query" output="false" hint="Returns the navigation children (dmHTML page for example)">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of children's parent to be returned">
		<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
		<cfargument name="status" required="no" type="string" default="approved">
			<cfset var o = createObject("component", "#application.packagepath#.farcry.tree")>
			<cfset var navFilter=arrayNew(1)>
			<cfset var qNav	= '' />
			
			<cfset navfilter[1]="status = '#arguments.status#'">
			<cfset qNav = o.getDescendants(objectid=arguments.objectid, lColumns='title,lNavIDAlias, status', depth=1, afilter=navfilter)>
		<cfreturn qNav>
	</cffunction>
	
	<cffunction name="getSiblings" access="public" returntype="query" output="false" hint="Returns the sibblings of a node navigation ">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of children's parent to be returned">
		<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
		<cfargument name="status" required="no" type="string" default="approved">
			<cfset var o = createObject("component", "#application.packagepath#.farcry.tree")>
			<cfset var navFilter=arrayNew(1)>
			<cfset var qNav	= '' />
			
			<cfset navfilter[1]="status = '#arguments.status#'">
			<cfset qNav = o.getDescendants(objectid=arguments.objectid, lColumns='title,lNavIDAlias, status', depth=0, afilter=navfilter)>
		<cfreturn qNav>
	</cffunction>
	
	
	<cffunction name="delete" access="public" hint="Specific delete method for dmNavigation. Removes all descendants">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<!--- get object details --->
		<cfset var stObj = getData(arguments.objectid)>
		
		<cfset var oHTML = createObject("component", application.stcoapi.dmHTML.packagePath) />
		<cfset var stHTML = structNew() />
		<cfset var qRelated = queryNew("blah") />
		<cfset var qDeleteRelated = queryNew("blah") />
		<cfset var qGetDescendants = "" />
		<cfset var oNavigation = createObject("component", application.types.dmNavigation.typePath) />
		<cfset var fuUrl = "" />
		<cfset var i = 0 />
		<cfset var objType = "" />
		<cfset var stReturn = StructNew()>
		<cfset var oType	= '' />
		
		<cfif not len(arguments.user)>
			<cfif application.security.isLoggedIn()>
				<cfset arguments.user = application.security.getCurrentUserID() />
			<cfelse>
				<cfset arguments.user = 'anonymous' />
			</cfif>
		</cfif>
		
		<cfif NOT structIsEmpty(stObj)>
		
			<!--- Announce the delete event to listeners --->
			<!--- NOTE: this is the same event called by types.delete(). It is the reponsibility of the events listener to ignore duplicates. --->
			<cfset application.fc.lib.events.announce(	component = "fcTypes", eventName = "beforedelete",
														typename = stObj.typename,
														oType = this,
														stObject = stObj,
														user = arguments.user,
														auditNote = arguments.auditNote) />
			
			<cfscript>
				// get descendants
				qGetDescendants = application.factory.oTree.getDescendants(objectid=stObj.objectID);
				
				// delete fu
				if (application.fc.factory.farFU.isUsingFU()) {
					fuUrl = application.fc.factory.farFU.getFU(objectid=stObj.objectid);
					application.fc.factory.farFU.deleteMapping(fuUrl);
				}
				
				// check for associated objects 
				if(structKeyExists(stObj,"aObjectIds") and arrayLen(stObj.aObjectIds)) {

					// loop over associated objects
					for(i=1; i LTE arrayLen(stObj.aObjectIds); i=i+1) {

						// work out typename
						objType = findType(stObj.aObjectIds[i]);
						if (len(objType)) {
							// delete associated object
							oType = createObject("component", application.types[objType].typePath);
							oType.delete(stObj.aObjectIds[i]);
						}
					}
				}
				
				// loop over descendants
				for(i=1; i LTE qGetDescendants.recordcount; i=i+1) {
					// delete descendant
					delete(qGetDescendants.objectId[i]);
				}
				
				// delete actual object
				super.delete(argumentCollection=arguments);
				
				// delete branch
				application.factory.oTree.deleteBranch(objectid=stObj.objectID);
				
				// remove permissions
				application.factory.oAuthorisation.deletePermissionBarnacle(objectid=stObj.objectID);
				
			</cfscript>
			
			<!--- Find any dmHTML pages that reference this navigation node. --->
			<cfquery datasource="#application.dsn#" name="qRelated">
			SELECT * FROM dmHTML_aRelatedIDs
			WHERE data = '#stobj.objectid#'
			</cfquery>
			
			<cfif qRelated.recordCount>
	
				<!--- Delete any of these relationships --->
				<cfquery datasource="#application.dsn#" name="qDeleteRelated">
				DELETE FROM dmHTML_aRelatedIDs
				WHERE data = '#stobj.objectid#'
				</cfquery>
							
				<!--- Loop over and refresh the object broker if required --->
				<cfloop query="qRelated">
					<cfset stHTML = oHTML.getData(objectid=qRelated.parentid, bUseInstanceCache=false) />				
				</cfloop>		
							
			</cfif>
			
			<cfset stReturn.bSuccess = true>
			<cfset stReturn.message = "#stObj.label# (#stObj.typename#) deleted.">
			<cfreturn stReturn>
		<cfelse>
			
			<cfset stReturn.bSuccess = false>
			<cfset stReturn.message = "#arguments.objectid# (dmNavigation) not found.">
			<cfreturn stReturn>
		
		</cfif>
	</cffunction>
	
	<cffunction name="getNavAlias" access="public" hint="Return a structure of all the dmNavigation nodes with aliases." returntype="struct" output="false">
		<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	
		<cfset var stResult = structNew()>
		<cfset var q = "">
		<cfset var i	= '' />
		
		<!--- $TODO: all app vars should be passed in as arguments! 
		move application.dbowner (and others no doubt) GB$ --->
		<cfquery datasource="#arguments.dsn#" name="q">
		SELECT nav.objectID, nav.lNavIDAlias, ntm.nLeft
		FROM	#application.dbowner#dmNavigation nav, 
				#application.dbowner#nested_tree_objects ntm
		WHERE	nav.objectid = ntm.objectid
		AND lNavIDAlias <> ''
		AND lNavIDAlias IS NOT NULL
		ORDER BY ntm.nLeft
		</cfquery>
	
		<cfloop query="q">
			<cfscript>
				if(len(q.lNavIdAlias))
				{
					for( i=1; i le ListLen(q.lNavIdAlias); i=i+1 )
					{
						alias = Trim(ListGetAt(q.lNavIdAlias,i));
						if (NOT StructKeyExists(stResult, alias)) {
							stResult[alias] = q.objectID;
						} else { 
							//stResult[alias] = ListAppend(stResult[alias], q.objectID);
						}
					}
				}
			</cfscript>
		</cfloop>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="renderOverview" access="public" hint="Renders options available on the overview page" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
		
		<!--- get object details --->
		<cfset var stObj = getData(arguments.objectid)>
		
		<cfinclude template="_dmNavigation/renderOverview.cfm">
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="renderObjectOverview" access="public" hint="Renders entire object overiew" output="true">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
			
		<!--- get object details --->
		<cfset var stObj = getData(arguments.objectid)>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.html = "">		
		<cfinclude template="_dmNavigation/renderObjectOverview.cfm">
		<cfreturn stLocal.html>
	
	</cffunction>
	
	<cffunction name="buildTreeCreateTypes" access="public" returntype="array" hint="Creates array of content types that can be created" output="false">
		<cfargument name="lTypes" required="true" type="string">
	
		<cfset var aReturn = ArrayNew(1)>
		<cfset var aTypes = listToArray(arguments.lTypes)>
		<cfset var i	= '' />
		
		<!--- build core types first --->
		<cfloop index="i" from="1" to="#arrayLen(aTypes)#">
			<cfif structKeyExists(Application.types[aTypes[i]],"bUseInTree")
				  AND Application.types[aTypes[i]].bUseInTree
				  AND NOT (structKeyExists(Application.types[aTypes[i]],"bCustomType")
						   AND Application.types[aTypes[i]].bCustomType)>
				<cfset ArrayAppend(aReturn, descriptionStructForType(aTypes[i])) />
			</cfif>
		</cfloop>
	
		<!--- then custom types --->
		<cfloop index="i" from="1" to="#arrayLen(aTypes)#">
			<cfif structKeyExists(Application.types[aTypes[i]],"bUseInTree")
				  AND Application.types[aTypes[i]].bUseInTree
				  AND structKeyExists(Application.types[aTypes[i]],"bCustomType")
				  AND Application.types[aTypes[i]].bCustomType>
				<cfset ArrayAppend(aReturn, descriptionStructForType(aTypes[i])) />
			</cfif>
		</cfloop>
		
		<cfreturn aReturn />
	</cffunction>
	
	<cffunction name="descriptionStructForType" access="private" returntype="struct">
		<cfargument name="typeName" type="string" required="true" />
		<cfset var stType = structNew()>
		<cfset stType.typename = arguments.typeName />
		<cfif structKeyExists(application.types[arguments.typename], "displayname")>
			<cfset stType.description = application.types[arguments.typename].displayName />
		<cfelse>
			<cfset stType.description = arguments.typeName />
		</cfif>
		<cfreturn stType />
	</cffunction>

	<cffunction name="ftEditaObjectIDs" access="public" returntype="string" description="This will return a string of formatted HTML text to enable the editing of the property" output="false">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />
		<cfset var qTypes = querynew("typename,displayname,hint","varchar,varchar,varchar") />
		<cfset var thistype = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfloop list="#structkeylist(application.stcoapi)#" index="thistype">
			<cfif structkeyexists(application.stCOAPI[thistype],"bUseInTree") and application.stCOAPI[thistype].bUseInTree>
				<cfif thistype NEQ "dmNavigation">
					<cfset queryaddrow(qTypes) />
					<cfset querysetcell(qTypes,"typename",thistype) />
					<cfset querysetcell(qTypes,"displayname",application.fapi.getContentTypeMetadata(thistype,"displayname", thistype)) />
					<cfset querysetcell(qTypes,"hint",application.fapi.getContentTypeMetadata(thistype,"hint", "")) />
				</cfif>
			</cfif>
		</cfloop>
		<cfquery dbtype="query" name="qTypes">
			select		*
			from		qTypes
			order by	displayname
		</cfquery>
		
		<cfif qTypes.recordcount>
			<skin:loadCSS id="fc-fontawesome" />
					
			<cfsavecontent variable="html">
				<cfoutput>
					<div class="multiField">
					<table class="layout" style="border-collapse:collapse;">
				</cfoutput>
				
				<cfloop query="qTypes">
					<cfoutput>
					<tr>
						<td style="padding:5px;vertical-align:top;border:1px solid ##DFDFDF;border-width:1px 0px 1px 1px;">
							<input type="radio" name="#arguments.fieldname#typename" id="#arguments.fieldname#typename" value="#qTypes.typename#" />
						</td>
						<td style="padding:8px;vertical-align:top;border:1px solid ##DFDFDF;border-width:1px 0px 1px 0px;">
							<cfif len(application.stCOAPI[qTypes.typename].icon)>
								<i class="#application.stCOAPI[qTypes.typename].icon# icon-2x"></i>
							<cfelse>
								<i class="icon-file icon-2x"></i>
							</cfif>
						</td>
						<td style="vertical-align:top;border:1px solid ##DFDFDF;border-width:1px 1px 1px 0px;">
							<b>#qTypes.displayname#</b><br>
							#qTypes.hint#
						</td>
					</tr>
					</cfoutput>				
				</cfloop>
				<cfoutput>
					</table>
					<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" />
					</div>
				</cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="html">
				<cfoutput>
					<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value=" " />
					<input type="hidden" name="#arguments.fieldname#typename" id="#arguments.fieldname#typename" value="" />
					<div>No types available</div>
				</cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="ftValidateaObjectIDs" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		

		<cfset var stResult = structnew() />
		<cfset var stChild = structnew() />
		<cfset var oType = "" />
		
		<cfset stResult.value = arraynew(1) />
		<cfset stResult.bSuccess = true />
		<cfset stResult.stError = structNew() />
		<cfset stResult.stError.message = "" />
		<cfset stResult.stError.class = "" />
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		
		<cfif structkeyexists(arguments.stFieldPost.stSupporting,"typename")>
			<cfif len(arguments.stFieldPost.stSupporting.typename)>
				<cfset oType = createobject("component",application.stCOAPI[arguments.stFieldPost.stSupporting.typename].packagepath) />
				<cfset stChild = oType.getData(objectid=application.fc.utils.createJavaUUID()) />
				<cfset oType.setData(stProperties=stChild,bSessionOnly=true) />
				
				<cfset arrayappend(stResult.value,stChild.objectid) />
			</cfif>
		<cfelse>
			<cfset stResult.stError.class = "validation-advice" />
			<cfset stResult.stError.message = "The necessary fields were not present" />
		</cfif>
			
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
	</cffunction>

</cfcomponent>