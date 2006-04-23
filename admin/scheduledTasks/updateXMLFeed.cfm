<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/scheduledTasks/updateXMLFeed.cfm,v 1.3 2003/11/05 04:46:09 tom Exp $
$Author: tom $
$Date: 2003/11/05 04:46:09 $
$Name: milestone_2-1-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Emails an overview report for site activity $
$TODO: $

|| DEVELOPER ||
$Developer: Quentin Zervaas (quentin@mitousa.com) $

|| ATTRIBUTES ||
$in: oid - the value is the object id of the XML feed object$
$out:$
--->

<!--- @@displayname: XML Feed Update --->
<cfsetting enablecfoutputonly="Yes" requestTimeout="600">

<cfparam name="url.oid" default="">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfparam name="stargs.typename" default="dmXMLExport">

<q4:contentobjectget objectid="#url.oid#" r_stobject="stObj">

<cfif IsStruct(stObj) and not StructIsEmpty(stObj) and stObj.typename eq stArgs.typename>
    <cfscript>
        o = createObject("component", application.types[stArgs.typename].typePath);
        o.generate(stObj.objectid);
    </cfscript>
<cfelse>
    <!--- not an XML feed --->
</cfif>

<cfsetting enablecfoutputonly="No">