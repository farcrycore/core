<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/htmlbody.cfm,v 1.5 2004/07/16 01:42:49 brendan Exp $
$Author: brendan $
$Date: 2004/07/16 01:42:49 $
$Name: milestone_2-3-2 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: dmEmail -- Body PLP Step $
$TODO: $

|| DEVELOPER ||
$Developer: Andrew Robertson (andrewr@daemon.com.au) $
--->

<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">

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
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].body#</div>
	
	<farcry:richTextEditor textareaname="htmlbody" value="#output.htmlbody#">
	
	
	<farcry:PLPNavigationButtons bDropDown="true">
	</form>	
	                                                                                                                                                                                                                                          </form></cfoutput>
	
<cfelse>
	<farcry:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="No">