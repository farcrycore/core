<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/plpEdit/body.cfm,v 1.34 2005/10/29 12:21:36 geoff Exp $
$Author: geoff $
$Date: 2005/10/29 12:21:36 $
$Name: milestone_3-0-1 $
$Revision: 1.34 $

|| DESCRIPTION || 
$Description: body step for dmNews plp. Displays text editor with option to toggle to plain html text area. $

|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au)$
--->
<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<cfset onClickEvent = fGetOnclickEvent()>

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
