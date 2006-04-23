<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/htmlbody.cfm,v 1.1 2003/08/28 01:44:34 paul Exp $
$Author: paul $
$Date: 2003/08/28 01:44:34 $
$Name: b201 $
$Revision: 1.1 $

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
	<cfoutput>
	<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">

	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">Body</div>
	
	<farcry:richTextEditor textareaname="htmlbody">
	
	
	<farcry:PLPNavigationButtons bDropDown="true">
	</form>	
	                                                                                                                                                                                                                                          </form></cfoutput>
	
<cfelse>
	<farcry:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="No">