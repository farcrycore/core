<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/sitemap.cfm,v 1.20.2.2 2006/02/15 23:13:19 gstewart Exp $
$Author: gstewart $
$Date: 2006/02/15 23:13:19 $
$Name: milestone_3-0-1 $
$Revision: 1.20.2.2 $

|| DESCRIPTION || 
$Description: Farcry - Sitemap Include
- Used to display list of navigation items in the application 
Requires: skin:buildlink tag
$
$TODO: maybe, add class options for the display$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@deamon.com.au) $

|| ATTRIBUTES ||
$in: attributes.bDisplay - default="false"$
$in: attributes.depth - default="4" type="numeric"$
$in: attributes.r_navQuery - default="r_navQuery"$
$out: caller.r_navQuery - complete qNav query$
--->

<cfimport taglib="/farcry/farcry_core/tags/webskin" prefix="skin">

<cfparam name="attributes.bDisplay" default="false">
<cfparam name="attributes.depth" default="4" type="numeric">
<cfparam name="attributes.r_navQuery" default="r_navQuery">
<cfparam name="attributes.startPoint" default="#application.navid.home#">

<cfif attributes.bDisplay>
	<skin:genericNav navID="#attributes.startPoint#" depth="#attributes.depth#">
<cfelse>
	<!--- return query to calling page --->
	<cfset "caller.#attributes.r_navquery#" = qNav>
</cfif>
<!--- <cfscript>
	// get navigation elements to root
	strSQLNavStatus = listQualify(request.mode.lvalidstatus, "'");
	navFilter=arrayNew(1);
	navfilter[1]="status IN (#strSQLNavStatus#)";
	navfilter[2]="(SELECT n.status FROM dmNavigation n WHERE n.objectid = ntm.parentid) IN (#strSQLNavStatus#)";    
	qNav = request.factory.oTree.getDescendants(objectid=attributes.startPoint, depth=attributes.depth, afilter=navFilter, lcolumns="externallink");
	lv0 = listFirst(listSort(valueList(qNav.nlevel),"numeric","asc")); //sort the value list and grab the first value as nlevel for plateau
	depth = listFirst(listSort(valueList(qNav.nlevel),"numeric","asc")); // sort the value list and grab the first value as the default depth ie. plateau
</cfscript>
<cfset stNodes = fGetChildrenNodes(attributes.startPoint,qnav)>
<cfif attributes.bDisplay><cfoutput>
<ul></cfoutput><cfloop index="i" from="1" to="#Arraylen(stNodes.aChildren)#">
	#fDisplay(stNodes.aChildren[i])#</cfloop><cfoutput>
</ul></cfoutput>
<cfelse>
	<!--- return query to calling page --->
	<cfset "caller.#attributes.r_navquery#" = qNav>
</cfif>

<cffunction name="fGetChildrenNodes" returntype="struct">
	<cfargument name="parentObjectID" required="true" type="uuid">
	<cfargument name="qnav" required="true" type="query">
	<cfset var stLocal = StructNew()>	
	<cfset stLocal.stNode = StructNew()>
	<cfset stLocal.stNode.objectid = arguments.parentObjectID>
	<cfset stLocal.stNode.aChildren = ArrayNew(1)>
	
	<cfquery name="stLocal.qSelfData" dbtype="query">
	SELECT	objectid, parentid, typename, objectname, externallink
	FROM	arguments.qnav
	WHERE	objectid = <cfqueryparam value="#arguments.parentObjectID#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfset stLocal.stNode.typename = stLocal.qSelfData.typename>
	<cfset stLocal.stNode.parentid = stLocal.qSelfData.parentid>
	<cfset stLocal.stNode.objectname = stLocal.qSelfData.objectname>
	<cfset stLocal.stNode.externallink = stLocal.qSelfData.externallink>
					
	<cfquery name="stLocal.qListChildren" dbtype="query">
	SELECT	objectid, parentid, typename, objectname, externallink
	FROM	arguments.qnav
	WHERE	parentid = <cfqueryparam value="#arguments.parentObjectID#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfset stLocal.iCounter = 0>
	<cfloop query="stLocal.qListChildren">
		<cfset stLocal.iCounter = stLocal.iCounter + 1>
		<cfset stLocal.tempNode = fGetChildrenNodes(stLocal.qListChildren.objectid, arguments.qnav)>
		<cfset ArrayAppend(stLocal.stNode.aChildren,stLocal.tempNode)>
	</cfloop>
	<cfreturn stLocal.stNode>
</cffunction>

<cffunction name="fDisplay">
	<cfargument name="stNode" required="true" type="struct">
	<cfimport taglib="/farcry/farcry_core/tags/webskin" prefix="skin">
	<cfset var stLocal = StructNew()><cfoutput>
	<li>
		<skin:buildlink objectid="#arguments.stNode.objectid#" externallink="#arguments.stNode.externallink#">#arguments.stNode.objectname#</skin><cfif ArrayLen(arguments.stNode.aChildren)>
		<ul><cfloop index="stLocal.i" from="1" to="#ArrayLen(arguments.stNode.aChildren)#">
			#fDisplay(arguments.stNode.aChildren[stLocal.i])#</cfloop>
		</ul></cfif>
	</li></cfoutput>
</cffunction> --->
<cfsetting enablecfoutputonly="no">