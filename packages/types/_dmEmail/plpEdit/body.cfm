<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/body.cfm,v 1.5 2005/09/02 06:27:37 guy Exp $
$Author: guy $
$Date: 2005/09/02 06:27:37 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: body step for dmNews plp. Displays text editor with option to toggle to plain html text area. $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/packages/fourq/tags/" prefix="q4">
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

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<widgets:plpAction>

<cfif NOT thisstep.isComplete>

<widgets:plpWrapper><cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post">
	<label for="body"><b>Body:</b>
		<textarea name="body" id="body">#output.body#</textarea>
	</label>

	<input type="hidden" name="plpAction" value="" />
	<input type="hidden" name="bBodySubmit" value="1" />
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form></cfoutput>
</widgets:plpWrapper>

<cfelse>
	<widgets:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="No">
