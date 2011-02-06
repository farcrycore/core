<cfsetting enablecfoutputonly="Yes" requestTimeout="600">
<cfprocessingDirective pageencoding="utf-8">
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
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/scheduledTasks/updateXMLFeed.cfm,v 1.6.2.1 2006/05/06 11:29:14 geoff Exp $
$Author: geoff $
$Date: 2006/05/06 11:29:14 $
$Name: p300_b113 $
$Revision: 1.6.2.1 $

|| DESCRIPTION || 
$Description: Updates a XML Feed $

|| DEVELOPER ||
$Developer: Quentin Zervaas (quentin@mitousa.com) $

|| ATTRIBUTES ||
$in: oid - the value is the object id of the XML feed object$
$out:$
--->
<!--- @@displayname: XML Feed Update --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<cfparam name="url.oid" default="">

<q4:contentobjectget objectid="#url.oid#" r_stobject="stObj">

<cfif IsStruct(stObj) and not StructIsEmpty(stObj) and stObj.typename eq "dmXMLExport">
    <cfscript>
        o = createObject("component", application.types[stArgs.typename].typePath);
        o.generate(stObj.objectid);
    </cfscript>
<cfelseif IsStruct(stObj) and not StructIsEmpty(stObj) and stObj.typename eq "farWebfeed">
	<cfif not len(stObj.directory)>
		<cfset stObj.directory = "/feeds/#rereplace(stObj.title,'[^\w]+','-','ALL')#" />
	</cfif>
	
	<!--- Make sure the directory exists --->
	<cfif not directoryexists("#application.path.project#/www#stObj.directory#")>
		<cfdirectory action="create" directory="#application.path.project#/www#stObj.directory#" />
	</cfif>
	
	<!--- RSS --->
	<cfif not fileexists("#application.path.project#/www#stObj.directory#/rss.xml")>
		<cffile action="write" file="#application.path.project#/www#stObj.directory#/rss.xml" output="" mode="664" />
	</cfif>
	<cfhttp url="http://#cgi.http_host#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&view=feedRSS" />
	<cffile action="write" file="#application.path.project#/www#stObj.directory#/rss.xml" output="#cfhttp.fileContent#" mode="664" />
	<cfoutput><p>Created <a href="#stObj.directory#/rss.xml">RSS feed</a></p></cfoutput>
	
	<!--- Atom --->
	<cfif not fileexists("#application.path.project#/www#stObj.directory#/atom.xml")>
		<cffile action="write" file="#application.path.project#/www#stObj.directory#/atom.xml" output="" mode="664" />
	</cfif>
	<cfhttp url="http://#cgi.http_host#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&view=feedAtom" />
	<cffile action="write" file="#application.path.project#/www#stObj.directory#/atom.xml" output="#cfhttp.fileContent#" mode="664" />
	<cfoutput><p>Created <a href="#stObj.directory#/atom.xml">Atom feed</a></p></cfoutput>
	
	<!--- RSS --->
	<cfif len(stObj.mediaproperty)>
		<cfif not fileexists("#application.path.project#/www#stObj.directory#/podcast.xml")>
			<cffile action="write" file="#application.path.project#/www#stObj.directory#/podcast.xml" output="" mode="664" />
		</cfif>
		<cfhttp url="http://#cgi.http_host#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&view=feedPodcast" />
		<cffile action="write" file="#application.path.project#/www#stObj.directory#/podcast.xml" output="#cfhttp.fileContent#" mode="664" />
		<cfoutput><p>Created <a href="#stObj.directory#/podcast.xml">iTunes podcast</a></p></cfoutput>
	</cfif>
<cfelse>
    <!--- not an XML feed --->
	<cfdump var="#stobj#" label="Things did not go according to plan..">
</cfif>

<cfsetting enablecfoutputonly="No">