<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/_ruleHandpicked/selectType.cfm,v 1.5 2004/07/30 08:34:40 phastings Exp $
$Author: phastings $
$Date: 2004/07/30 08:34:40 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: ruleHandpicked PLP - select object type (selectType.cfm) $
$TODO: Clean up whitespace issues, revise formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Paul Harrison (paul@daemon.com.au) $
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfprocessingDirective pageencoding="utf-8">

<cfparam name="output.dmType" default="dmNews">
<cfparam name="output.intro" default="">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>

<!--- defaults for this step --->

<cfif NOT thisstep.isComplete>
<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">
<cfoutput>
	
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].selectObjType#</div>
	<div class="FormTable" align="center">
 	<table>
	
	<tr>
		<td align="center" >
			#application.adminBundle[session.dmProfile.locale].selectObjTypeLabel#
			<select name="dmType">
			<cfloop collection="#application.types#" item="type">
				<cfif structKeyExists(application.types[type],"BSCHEDULE")>
					<option value="#type#" <cfif output.dmType IS type>selected</cfif>>#type#</option>
				</cfif> 
			</cfloop>
			</select>
		</td>
	</tr>										
	</table>
	</div>

	

	<div class="FormTableClear">
		<tags:plpNavigationButtons>
	</div>
	</cfoutput>
</cfform>

	
<cfelse>
	<cfparam name="form.aIds" default="">
	<tags:plpUpdateOutput>
</cfif>
