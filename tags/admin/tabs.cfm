<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/admin/tabs.cfm,v 1.3 2003/03/26 00:20:46 brendan Exp $
$Author: brendan $
$Date: 2003/03/26 00:20:46 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
Creates tab

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfsetting enablecfoutputonly="Yes">

<cfswitch expression="#ThisTag.ExecutionMode#">

	<cfcase value="Start">
		<!--- Initialise variables --->
	</cfcase>

	<cfcase value="End">
		<cftry>
			<!--- Generate tabs --->
			<cfloop from="1" to="#ArrayLen(ThisTag.tabs)#" index="i">
				<cfoutput><a href="#thistag.tabs[i].href#" class="#thistag.tabs[i].class#" target="#thistag.tabs[i].target#" title="#thistag.tabs[i].title#" <cfif thistag.tabs[i].onclick neq "">onClick="#thistag.tabs[i].onclick#"</cfif> <cfif thistag.tabs[i].id neq "">id="#thistag.tabs[i].id#"</cfif> <cfif thistag.tabs[i].style neq "">style="#thistag.tabs[i].style#"</cfif>>#thistag.tabs[i].text#</a></cfoutput>
			</cfloop>
		<cfcatch>
			<!--- do nothing --->
		</cfcatch>
	</cftry>	
	</cfcase>

</cfswitch>

<cfsetting enablecfoutputonly="No">