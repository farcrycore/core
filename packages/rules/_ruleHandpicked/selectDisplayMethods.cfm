<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/_ruleHandpicked/selectDisplayMethods.cfm,v 1.3 2003/07/10 02:07:06 brendan Exp $
$Author: brendan $
$Date: 2003/07/10 02:07:06 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: ruleHandpicked PLP - choose teaser handler (teaser.cfm) $
$TODO: Clean up whitespace issues, revise formatting 20030503 GB$

|| DEVELOPER ||
$Developer: Paul Harrison (paul@daemon.com.au) $
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cffunction name="cleanUUID">
	<cfargument name="objectID" type="uuid">
	<cfset rObjectID = trim(replace(arguments.objectID,"-","","ALL"))> 
	<cfreturn rObjectID>
</cffunction>


<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfloop list="#output.lObjectIDs#" index="i">
	<cfset thisObjectID = cleanUUID(i)>
	<cfparam name="output.method_#thisObjectID#.displayMethod" default=""> 
	<cfif isDefined("form.method_#thisObjectID#.displayMethod")>
		<cfset "output.method_#thisObjectID#.displayMethod" = evaluate("form.method_" & thisObjectID & ".displayMethod")>
	</cfif>
</cfloop>

<tags:plpNavigationMove>

<!--- defaults for this step --->
<cfparam name="output.orderby" default="label">
<cfparam name="output.orderdir" default="asc">
<cfparam name="output.lObjectids" default="">

<cfif NOT thisstep.isComplete>


<cfset lObjectIDs = "#ListChangeDelims(output.lobjectIDs,"','",",")#">
<cfscript> 
	sql = "SELECT * from #output.dmType# WHERE objectID IN ('#lObjectIDs#')";
</cfscript>
<cfquery name="qGetObjects" datasource="#application.dsn#">
	#preserveSingleQuotes(sql)#
</cfquery>


<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">
<cfoutput>
	
	<div class="FormTitle">Select Object Type</div>
	<div class="FormTable" align="center" style="width:500px">
	
 	<table>
	<tr>
		<td>
			Object Type - #output.dmType#
		</td>
	</tr>
	<tr>
		<td>
			
		</td>
	</tr>										
	
	</table>
		
	<table width="100%" style="border:thin solid Black;" >
	
		<tr>
			<td>
				Label
			</td>
			<td>
				Last Updated
			</td>
			<td>
				Display Method
			</td>
		</tr>
		
		<nj:listTemplates typename="#output.dmType#" prefix="displayTeaser" r_qMethods="qDisplayTypes"> 
		
		<cfloop query="qGetObjects">
		<tr id="row#objectID#">
			
			<td>
				#label#
			</td>
			<td>
				#dateformat(datetimelastupdated,"dd-mmm-yyyy")#
			</td>
			<td>
				<cfset thisObjectID = cleanUUID(objectID)>
				<select name="method_#thisObjectID#.displayMethod" size="1" class="field">
				
				<cfloop query="qDisplayTypes">
					
					<option value="#methodName#" <cfif evaluate("output.method_" & thisObjectID & ".displayMethod") IS methodname>selected</cfif>>#displayName#</option>
				</cfloop>
				</select>
			</td>
		</tr>
		</cfloop>
	</table>
	<!--- <input type="button" onClick="this.form.submit();" value="update"> --->
	
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