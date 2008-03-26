<cfsetting enablecfoutputonly="Yes" requestTimeout="600">
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

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
		<cffile action="write" file="#application.path.project#/www#stObj.directory#/rss.xml" output="" />
	</cfif>
	<cfhttp url="http://#cgi.http_host#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&format=rss" />
	<cffile action="write" file="#application.path.project#/www#stObj.directory#/rss.xml" output="#cfhttp.fileContent#" />
	<cfoutput><p>Created <a href="#stObj.directory#/rss.xml">RSS feed</a></p></cfoutput>
	
	<!--- Atom --->
	<cfif not fileexists("#application.path.project#/www#stObj.directory#/atom.xml")>
		<cffile action="write" file="#application.path.project#/www#stObj.directory#/atom.xml" output="" />
	</cfif>
	<cfhttp url="http://#cgi.http_host#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&format=atom" />
	<cffile action="write" file="#application.path.project#/www#stObj.directory#/atom.xml" output="#cfhttp.fileContent#" />
	<cfoutput><p>Created <a href="#stObj.directory#/atom.xml">Atom feed</a></p></cfoutput>
	
	<!--- RSS --->
	<cfif len(stObj.mediaproperty)>
		<cfif not fileexists("#application.path.project#/www#stObj.directory#/podcast.xml")>
			<cffile action="write" file="#application.path.project#/www#stObj.directory#/podcast.xml" output="" />
		</cfif>
		<cfhttp url="http://#cgi.http_host#/#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&format=podcast" />
		<cffile action="write" file="#application.path.project#/www#stObj.directory#/podcast.xml" output="#cfhttp.fileContent#" />
		<cfoutput><p>Created <a href="#stObj.directory#/podcast.xml">iTunes podcast</a></p></cfoutput>
	</cfif>
<cfelse>
    <!--- not an XML feed --->
	<cfdump var="#stobj#" label="Things did not go according to plan..">
</cfif>

<cfsetting enablecfoutputonly="No">