<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/buildLink.cfm,v 1.5 2003/07/28 01:01:50 ben Exp $
$Author: ben $
$Date: 2003/07/28 01:01:50 $
$Name: b131 $
$Revision: 1.5 $

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
	<cfparam name="attributes.externallink" default="">
	<cfparam name="attributes.class" default="">
	
	<!--- check for sim link --->
	<cfif len(attributes.externallink)>
		<cfset href= application.url.conjurer & "?objectid=" & attributes.externallink>
	<cfelse>	
		<!--- check for friendly url --->
		<cfif application.config.plugins.fu>
			<cfobject component="#application.packagepath#.farcry.fu" name="fu">
			<cfset href = fu.getFU(attributes.objectid)>
		<cfelse>
			<cfset href = application.url.conjurer & "?objectid=" & attributes.objectid>
		</cfif>
	</cfif>
	
	<!--- display link --->
	<cfoutput><a href="#href#" <cfif len(attributes.class)>class="#attributes.class#"</cfif> target="#attributes.target#"></cfoutput>

<cfelse>

	<cfoutput></a></cfoutput>

</cfif>
<cfsetting enablecfoutputonly="No">
