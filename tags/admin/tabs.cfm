<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/admin/tabs.cfm,v 1.4 2004/07/15 02:01:35 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:01:35 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
Creates tab

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

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
