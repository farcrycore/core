<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEvent/plpEdit/body.cfm,v 1.18.2.1 2006/01/25 12:37:08 geoff Exp $
$Author: geoff $
$Date: 2006/01/25 12:37:08 $
$Name: milestone_3-0-1 $
$Revision: 1.18.2.1 $

|| DESCRIPTION || 
$Description: body step for dmNews plp. Displays text editor with option to toggle to plain html text area. $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<!--- check for toggle option --->
<cfif isdefined("form.toggle")>
	<cfset session.toggleTextArea = 1>
<cfelse>
	<cfset session.toggleTextArea = 0>
</cfif>

<cfset onClickEvent = fGetOnclickEvent()>
	
<!--- copy related items to a list for looping --->
<cfset relatedItems = arraytolist(output.aObjectIds)>
<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<widgets:plpAction>

<cfif NOT thisstep.isComplete>

<widgets:plpWrapper>
<cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post"></cfoutput>

	<widgets:richTextEditor value="#output.body#">

	<cfoutput><div class="relateditems-wrap r-i-images"></cfoutput>
	<widgets:bodyInsertItem typename="dmImage">
	<cfoutput></div></cfoutput>

	<cfoutput><div class="relateditems-wrap r-i-files"></cfoutput>
	<widgets:bodyInsertItem typename="dmFile">
	<cfoutput></div></cfoutput>
	
	<cfoutput><div class="teaser-wrap"></cfoutput>
	<widgets:teaser>
	<cfoutput></div></cfoutput>
	<cfoutput>
	<input type="hidden" name="plpAction" value="" />
	<input type="hidden" name="bBodySubmit" value="1" />
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form>
</cfoutput>
</widgets:plpWrapper>

<cfelse>
	<widgets:plpUpdateOutput onclick="#onclickEvent#">
</cfif>

<cfsetting enablecfoutputonly="No">
