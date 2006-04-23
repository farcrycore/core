<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/buildLink.cfm,v 1.12 2003/12/08 00:47:35 ben Exp $
$Author: ben $
$Date: 2003/12/08 00:47:35 $
$Name: milestone_2-1-2 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: Helps to construct a FarCry style link -- works out whether the links is a symlink or normal farcry link and checks for friendly url$
$TODO: make a corresponding UDF $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid -- navigation obj id$
$in: title -- link text $
$in: external -- external link for nav node $
$in: class -- css class for link$
$in: target -- target window for link$
--->

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.target" default="_self">
	<cfparam name="attributes.bShowTarget" default="true">
	<cfparam name="attributes.externallink" default="">
	<cfparam name="attributes.class" default="">
	<cfparam name="attributes.urlOnly" default="false">
	<cfparam name="attributes.xCode" default="">
	<cfparam name="attributes.includeDomain" default="false">

    <cfif attributes.includeDomain>
        <cfset href = "http://#cgi.http_host#">
    <cfelse>
        <cfset href = "">
    </cfif>

	<!--- check for sim link --->
	<cfif len(attributes.externallink)>
		<!--- check for friendly url --->
		<cfif application.config.plugins.fu>
			<cfset href = href & application.factory.oFU.getFU(attributes.externallink)>
		<cfelse>
			<cfset href = href & application.url.conjurer & "?objectid=" & attributes.externallink>
		</cfif>
	<cfelse>
		<!--- check for friendly url --->
		<cfif application.config.plugins.fu>
			<cfset href = href & application.factory.oFU.getFU(attributes.objectid)>
		<cfelse>
			<cfset href = href & application.url.conjurer & "?objectid=" & attributes.objectid>
		</cfif>
	</cfif>

	<!--- Are we mean to display an a tag or the URL only? --->
	<cfif attributes.urlOnly EQ true>

		<!--- display the URL only --->
		<cfoutput>#href#</cfoutput>

	<cfelse>

		<!--- display link --->
		<cfoutput><a href="#href#"<cfif len(attributes.class)> class="#attributes.class#"</cfif><cfif len(attributes.xCode)> #attributes.xCode#</cfif><cfif attributes.bShowTarget eq true> target="#attributes.target#"</cfif>></cfoutput>

	</cfif>

<cfelse>

	<!--- Was only the URL requested? If so, we don't need to close any tags --->
	<cfif attributes.urlOnly EQ false>
		<cfoutput></a></cfoutput>
	</cfif>

</cfif>
<cfsetting enablecfoutputonly="No">