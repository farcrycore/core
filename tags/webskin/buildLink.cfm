<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/buildLink.cfm,v 1.16.2.2 2006/01/26 06:49:20 geoff Exp $
$Author: geoff $
$Date: 2006/01/26 06:49:20 $
$Name: milestone_3-0-1 $
$Revision: 1.16.2.2 $

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
$in: xCode -- eXtra code to be placed inside the anchor tag $
--->

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.linktext" default="">
	<cfparam name="attributes.target" default="_self">
	<cfparam name="attributes.bShowTarget" default="false">
	<cfparam name="attributes.externallink" default="">
	<cfparam name="attributes.class" default="">
	<cfparam name="attributes.urlOnly" default="false">
	<cfparam name="attributes.xCode" default="">
	<cfparam name="attributes.includeDomain" default="false">
	<cfparam name="attributes.stParameters" default="#StructNew()#">

	<!---
	Only initialize FU if we're using Friendly URL's
	We cannot guarantee the Friendly URL Servlet exists otherwise
	--->
	<cfif application.config.plugins.fu>
		<cfset objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
	</cfif>
	
	<cfif attributes.includeDomain>
        <cfset href = "http://#cgi.http_host#">
    <cfelse>
        <cfset href = "">
    </cfif>

	<!--- check for sim link --->
	<cfif len(attributes.externallink)>
		<!--- check for friendly url --->
		<cfif application.config.plugins.fu>
			<cfset href = href & objFU.getFU(attributes.externallink)>
		<cfelse>
			<cfset href = href & application.url.conjurer & "?objectid=" & attributes.externallink>
		</cfif>
	<cfelse>
		<!--- check for friendly url --->
		<cfif application.config.plugins.fu>
			<cfset href = href & objFU.getFU(attributes.objectid)>
		<cfelse>
			<cfset href = href & application.url.conjurer & "?objectid=" & attributes.objectid>
		</cfif>
	</cfif>

	<!--- check for extra URL parameters --->
	<cfif NOT StructIsEmpty(attributes.stParameters)>
		<cfset stLocal = StructNew()>
		<cfset stLocal.parameters = "">
		<cfset stLocal.iCount = 0>
		<cfloop collection="#attributes.stParameters#" item="stLocal.key">
			<cfif stLocal.iCount GT 0>
				<cfset stLocal.parameters = stLocal.parameters & "&">
			</cfif>
			<cfset stLocal.parameters = stLocal.parameters & stLocal.key & "=" & URLEncodedFormat(attributes.stParameters[stLocal.key])>
			<cfset stLocal.iCount = stLocal.iCount + 1>
		</cfloop>

		<!--- check for friendly url --->
		<cfif application.config.plugins.fu>
			<!--- if FU is turned on then append extra URL parameters with a leading '?' --->
			<cfset href = href & "?" & stLocal.parameters>
		<cfelse>
		  	<!--- if FU is turned off then append extra URL parameters with a leading '&' as there will already be URL params (i.e. "?objectid=") --->
			<cfset href = href & "&" & stLocal.parameters>
		</cfif>
	</cfif>
	
	<!--- Are we mean to display an a tag or the URL only? --->
	<cfif attributes.urlOnly EQ true>
		<!--- display the URL only --->
		<cfset tagoutput=href>

	<cfelse>
		<!--- display link --->
		<cfset tagoutput='<a href="#href#"'>
		<cfif len(attributes.class)>
			<cfset tagoutput=tagoutput & ' class="#attributes.class#"'>
		</cfif>
		<cfif len(attributes.xCode)>
			<cfset tagoutput=tagoutput & ' #attributes.xCode#'>
		</cfif>
		<cfif attributes.bShowTarget eq true>
			<cfset tagoutput=tagoutput & ' target="#attributes.target#"'>
		</cfif>
		<cfset tagoutput=tagoutput & '>'>
	</cfif>

<!--- thistag.ExecutionMode is END --->
<cfelse>
	<!--- Was only the URL requested? If so, we don't need to close any tags --->
	<cfif attributes.urlOnly EQ false>
		<cfif len(attributes.linktext)>
			<cfset tagoutput=tagoutput & trim(attributes.linktext) & '</a>'>
		<cfelse>
			<cfset tagoutput=tagoutput & trim(thistag.generatedcontent) & '</a>'>
		</cfif>
	</cfif>

	<!--- clean up whitespace --->
	<cfset thistag.GeneratedContent=tagoutput>
</cfif>

<cfsetting enablecfoutputonly="No">