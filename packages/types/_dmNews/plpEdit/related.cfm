<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/plpEdit/related.cfm,v 1.10 2005/07/25 03:33:37 guy Exp $
$Author: guy $
$Date: 2005/07/25 03:33:37 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: dmHTML PLP for edit handler - Related Links Step $
$TODO: clean up whispace management & formatting, add external links option 20030503 GB$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">
	
<!--- copy related items to a list for looping --->
<cfset relatedItems = arraytolist(output.arelatedIDs)>
<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<widgets:plpAction>

<cfif NOT thisstep.isComplete>

<widgets:plpWrapper>

<cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">
	<input type="hidden" name="plpAction" value="" />
	<fieldset>
	<widgets:relatedContent lRelatedTypeName="dmFile,dmImage">
	</fieldset>		
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form></cfoutput>

</widgets:plpWrapper>

</cfif>

<cfsetting enablecfoutputonly="No">