<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/sitemap.cfm,v 1.12 2004/03/04 19:27:17 tom Exp $
$Author: tom $
$Date: 2004/03/04 19:27:17 $
$Name: milestone_2-2-1 $
$Revision: 1.12 $

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

<cfscript>
	// get navigation elements to root
	navFilter=arrayNew(1);
	navfilter[1]="status IN (#listQualify(request.mode.lvalidstatus, "'")#)";
	qNav = request.factory.oTree.getDescendants(objectid=attributes.startPoint, depth=attributes.depth, afilter=navFilter, lcolumns="externallink");
	lv0 = listFirst(listSort(valueList(qNav.nlevel),"numeric","asc")); //sort the value list and grab the first value as nlevel for plateau
	depth = listFirst(listSort(valueList(qNav.nlevel),"numeric","asc")); // sort the value list and grab the first value as the default depth ie. plateau
</cfscript>

<cfif attributes.bDisplay>
	<cfoutput>
	<!--id=sitemap-->
	<div id="sitemap">
	<ul>
	</cfoutput>
	
	<cfloop query="qNav">
		<cfscript>
		if (qNav.nlevel eq depth) {
			// do nothing
		} else if (qNav.nlevel gt depth) {
			// depth increase indent
			writeoutput('<ul>
		');
			depth=depth+1;
		} else if (qNav.nlevel lt depth) {
			// depth decrease outdent
			for (i=1;qNav.nlevel - depth;i=1+1)
			{
				writeoutput("</ul></li>");
				depth=depth-1;
			}
		}
		// writeoutput("<li>#qnav.objectname#</li>");
		// next depth
		nextrow = qnav.currentrow+1;
		ndepth=qnav.nlevel[nextrow];
		</cfscript>
		
		<cfif qNav.nlevel eq lv0>
			<cfoutput>
			<li></cfoutput><skin:buildlink objectid="#qNav.objectid#" externallink="#qNav.externallink#"><cfoutput>#qNav.objectname#</cfoutput></skin:buildLink><cfif qNav.nlevel eq ndepth><cfoutput></li></cfoutput></cfif>
		<cfelse>
			<cfoutput>
			<li></cfoutput><skin:buildlink objectid="#qNav.objectid#" externallink="#qNav.externallink#"><cfoutput>#qNav.objectname#</cfoutput></skin:buildLink><cfoutput></li></cfoutput>
		</cfif>
	</cfloop>
	
	<cfoutput>
	<cfif depth neq lv0></ul></cfif>
	</ul>
	</div>
	<!--/id=sitemap-->
	</cfoutput>

<cfelse>
	<!--- return query to calling page --->
	<cfset "caller.#attributes.r_navquery#" = qNav>
</cfif>

<cfsetting enablecfoutputonly="no">