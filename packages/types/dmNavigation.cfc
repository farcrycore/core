<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/dmNavigation.cfc,v 1.20.2.11 2006/03/08 00:32:13 paul Exp $
$Author: paul $
$Date: 2006/03/08 00:32:13 $
$Name: milestone_3-0-1 $
$Revision: 1.20.2.11 $

|| DESCRIPTION || 
$Description: dmNavigation type $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent name="dmNavigation" extends="types" displayname="Navigation" hint="Navigation nodes are combined with the ntm_navigation table to build the site layout model for the FarCry CMS system." bUseInTree="1" bFriendly="1" bObjectBroker="true">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty ftSeq="1" ftFieldSet="General Details" name="title" type="nstring" hint="Object title.  Same as Label, but required for overview tree render." required="no" default="" ftLabel="Title" />

<cfproperty ftSeq="5" ftFieldSet="Advanced" name="lNavIDAlias" type="string" hint="A Nav alias provides a human interpretable link to this navigation node.  Each Nav alias is set up as key in the structure application.navalias.<i>aliasname</i> with a value equal to the navigation node's UUID." required="no" default="" ftLabel="Alias" />
<cfproperty ftSeq="10" ftFieldSet="Advanced" name="ExternalLink" type="string" hint="URL to an external (ie. off site) link." required="no" default="" ftType="list" ftLabel="Redirect to" ftListData="getExternalLinks" />

<cfproperty name="fu" type="string" hint="Friendly URL for this node." required="no" default="" ftLabel="Friendly URL" />
<cfproperty name="aObjectIDs" type="array" hint="Holds objects to be displayed at this particular node.  Can be of mixed types." required="no" default="" ftJoin="dmImage" />
<cfproperty name="options" type="string" hint="No idea what this is for." required="no" default="" ftLabel="Options" />
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft" ftLabel="Status" />
<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<!--- <cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	
	<cfinclude template="_dmNavigation/edit.cfm">
</cffunction> --->


<cffunction name="getExternalLinks" access="public" returntype="string" output="false" hint="Returns a list of all navigation nodes in the system with an alias">

	<cfset var lResult = ":#application.adminBundle[session.dmProfile.locale].noneForSelect#" />
	<cfset var aNavalias = listToArray(listSort(structKeyList(application.navid),'textnocase'))>
	

	<cfloop from="1" to="#arraylen(aNavalias)#" index="i">
		<cfset lResult = listAppend(lResult, "#application.navid[aNavalias[i]]#:#aNavalias[i]#") />
	</cfloop>

	<cfreturn lResult />
</cffunction>



<cffunction name="AfterSave" access="public" output="true" returntype="struct" hint="Called from ProcessFormObjects and run after the object has been saved.">
	<cfargument name="stProperties" required="yes" type="struct" hint="A structure containing the contents of the properties that were saved to the object.">
	
	<cflock scope="Application" timeout="20">
		<cfset application.navid = getNavAlias()>
	</cflock>
	
	<cfquery datasource="#application.dsn#">
	UPDATE #application.dbowner#nested_tree_objects 
	SET objectName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.title#">
	WHERE objectID = '#stProperties.ObjectID#'
	</cfquery>
	
	
	<cfreturn stProperties />
</cffunction>
		
			

<cffunction name="getParent" access="public" returntype="query" output="false" hint="Returns the navigation parent of child (dmHTML page for example)">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of element needing a parent">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	
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
		<cfset navfilter[1]="status = '#arguments.status#'">
		<cfset qNav = o.getDescendants(objectid=arguments.objectid, lColumns='title,lNavIDAlias, status', depth=0, afilter=navfilter)>
	<cfreturn qNav>
</cffunction>


<cffunction name="delete" access="public" hint="Specific delete method for dmNavigation. Removes all descendants">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	
	<!--- get object details --->
	<cfset stObj = getData(arguments.objectid)>
	<cfif NOT structIsEmpty(stObj)>
		<cfinclude template="_dmNavigation/delete.cfm">
	</cfif>
</cffunction>

<cffunction name="getNavAlias" access="public" hint="Return a structure of all the dmNavigation nodes with aliases." returntype="struct" output="false">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">

	<cfset var stResult = structNew()>
	<cfset var q = "">

	<!--- $TODO: all app vars should be passed in as arguments! 
	move application.dbowner (and others no doubt) GB$ --->
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfquery datasource="#arguments.dsn#" name="q">
				SELECT objectID, lNavIDAlias
				FROM #application.dbowner#dmNavigation
				WHERE lNavIDAlias IS NOT NULL
			</cfquery>
		</cfcase>
		<cfdefaultcase>
			<cfquery datasource="#arguments.dsn#" name="q">
				SELECT objectID, lNavIDAlias
				FROM #application.dbowner#dmNavigation
				WHERE lNavIDAlias <> ''
			</cfquery>
		</cfdefaultcase>
	</cfswitch>

	<cfloop query="q">
		<cfscript>
			if(len(q.lNavIdAlias))
			{
				for( i=1; i le ListLen(q.lNavIdAlias); i=i+1 )
				{
					alias = Trim(ListGetAt(q.lNavIdAlias,i));
					if (NOT StructKeyExists(stResult, alias))
						stResult[alias] = q.objectID;
					else 
						stResult[alias] = ListAppend(stResult[alias], q.objectID);
				}
			}
		</cfscript>
	</cfloop>
	<cfreturn stResult>
</cffunction>

<cffunction name="renderOverview" access="public" hint="Renders options available on the overview page" output="false">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
	
	<!--- get object details --->
	<cfset stObj = getData(arguments.objectid)>
	
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

<cffunction name="setFriendlyURL" access="public" returntype="struct" hint="dmNavigation specific frienly url." output="false">
	<cfargument name="objectid" required="false" default="#instance.stobj.objectid#" type="uuid" hint="Content item objectid.">
	<cfset var stReturn = StructNew()>
	<cfset var stobj = getdata(arguments.objectid)>
	<cfset var stFriendlyURL = StructNew()>
	<cfset var inav=0>
	<cfset var objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
	<cfset var objNavigation = CreateObject("component","#Application.packagepath#.types.dmNavigation")>
	<cfset var qNavigation=querynew("objectid")>
	
	<!--- default return structure --->
	<cfset stReturn.bSuccess = 1>
	<cfset stReturn.message = "Set friendly URL for #arguments.objectid#.">

	<!--- default stFriendlyURL structure --->
	<cfset stFriendlyURL.objectid = stobj.objectid>
	<cfset stFriendlyURL.friendlyURL = "">
	<cfset stFriendlyURL.querystring = "">
	
	<cfset bExclude = 0>
	<cfloop index="iNav" list="#stobj.lNavIDAlias#">
		<cfif ListFindNoCase(application.config.fusettings.lExcludeNavAlias, iNav)>
			<cfset bExclude = 1>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfif bExclude EQ 0>
		<!--- This determines the friendly url by where it sits in the navigation node  --->
		<cfset stFriendlyURL.friendlyURL = objFU.createFUAlias(stobj.objectid,0)>
		<cfif trim(stobj.fu) neq "">
			<cfset stFriendlyURL.friendlyURL = stFriendlyURL.friendlyURL & stobj.fu>
		<cfelse>
			<cfset stFriendlyURL.friendlyURL = stFriendlyURL.friendlyURL & stobj.label>
		</cfif>
		<cfset objFU.setFU(stFriendlyURL.objectid, stFriendlyURL.friendlyURL, stFriendlyURL.querystring)>
	</cfif>
	<cfreturn stReturn>
</cffunction>

<cffunction name="fRebuildFriendlyURLs" access="public" returntype="struct" hint="Rebuilds friendly URLs" output="true">
	<cfset var stLocal = structnew()>
	<cfset stLocal.returnstruct = StructNew()>
	<cfset stLocal.returnstruct.bSuccess = 1>
	<cfset stLocal.returnstruct.message = "">
	
	<cfquery name="stLocal.qList" datasource="#application.dsn#">
	SELECT	objectid, title as label, fu
	FROM	#application.dbowner#dmNavigation
	WHERE	label != '(incomplete)'
		AND objectid != '#application.navid.root#'
	</cfquery>
			
	<!--- used to retrieve default of where item is in tree --->
	<cfset stLocal.objNavigation = CreateObject("component","#Application.packagepath#.types.dmNavigation")>
	<cfset stLocal.objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
	<cfset stLocal.stFriendlyURL = StructNew()>
	<cfset stLocal.iCounterUnsuccess = 0>
	<cftry>
		<cfloop query="stLocal.qList">
			<!--- This determines the friendly url by where it sits in the navigation node  --->
			<cfset stLocal.stFriendlyURL.objectid = stLocal.qList.objectid>
			<cfset stLocal.stFriendlyURL.querystring = "">
			<cfset stLocal.stFriendlyURL.friendlyURL = stLocal.objFU.createFUAlias(stLocal.qList.objectid,0)>
			<cfif trim(stLocal.qList.fu) neq "">
				<cfset stLocal.stFriendlyURL.friendlyURL = stLocal.stFriendlyURL.friendlyURL & stLocal.qList.fu>
			<cfelse>
				<cfset stLocal.stFriendlyURL.friendlyURL = stLocal.stFriendlyURL.friendlyURL & stLocal.qList.label>
			</cfif>
		
			<cfset stLocal.objFU.setFU(stLocal.stFriendlyURL.objectid, stLocal.stFriendlyURL.friendlyURL, stLocal.stFriendlyURL.querystring)>
		</cfloop>

		<cfcatch>
			<cfset stLocal.iCounterUnsuccess = stLocal.iCounterUnsuccess + 1>
		</cfcatch>
	</cftry>

	<cfset stLocal.iCounterSuccess = stLocal.qList.recordcount - stLocal.iCounterUnsuccess>
	<cfset stLocal.returnstruct.message = "#stLocal.iCounterSuccess# navigation rebuilt successfully.<br />">
	<cfreturn stLocal.returnstruct>
</cffunction>

<cffunction name="buildTreeCreateTypes" access="public" returntype="array" hint="Creates array of content types that can be created" output="false">
	<cfargument name="lTypes" required="true" type="string">

	<cfset var aReturn = ArrayNew(1)>
	<cfset var aTypes = listToArray(arguments.lTypes)>

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
</cfcomponent>