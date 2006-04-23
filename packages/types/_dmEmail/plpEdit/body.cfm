<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/body.cfm,v 1.2 2003/08/28 01:41:39 paul Exp $
$Author: paul $
$Date: 2003/08/28 01:41:39 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmEmail -- Body PLP Step $
$TODO: $

|| DEVELOPER ||
$Developer: Andrew Robertson (andrewr@daemon.com.au) $
--->

<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="farcry">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<farcry:plpNavigationMove>


<cfif NOT thisstep.isComplete>
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">

	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">Body</div>
	<div class="FormTable">
	<textarea name="body" rows="20" cols="60">#output.body#</textarea></cfoutput>
	</div>
	<farcry:PLPNavigationButtons bDropDown="true">
		
	<cfoutput></form></cfoutput>
	
<cfelse>
	<farcry:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="No">