<cfsetting enablecfoutputonly="yes">

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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/_farcryOnRequestEnd.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name:  $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Functionality to be run at the end of every page, including stats logging$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/core" prefix="core" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif structKeyExists(session, "aGritterMessages") AND arrayLen(session.aGritterMessages)>
	<skin:loadJS id="jquery" />
	<skin:loadJS id="gritter" />
	<skin:loadCSS id="gritter" />
	
	<skin:onReady>
		<cfloop from="1" to="#arrayLen(session.aGritterMessages)#" index="i">
			<cfoutput>
			$j.gritter.add({
				// (string | mandatory) the heading of the notification
				title: '#jsstringformat(session.aGritterMessages[i].title)#',
				// (string | mandatory) the text inside the notification
				text: '#jsstringformat(session.aGritterMessages[i].message)#',
				// (string | optional) the image to display on the left
				image: '#session.aGritterMessages[i].image#',
				// (bool | optional) if you want it to fade out on its own or just sit there
				sticky: #session.aGritterMessages[i].sticky#, 
				// (int | optional) the time you want it to be alive for before fading out (milliseconds)
				time: #session.aGritterMessages[i].pause#
			});
			</cfoutput>
		</cfloop>		
	</skin:onReady>
	
	<cfset session.aGritterMessages = arrayNew(1) />
</cfif>



<!--- Add the loaded libraries into the header --->
<core:cssInHead />
<core:jsInHead />



<cfif structKeyExists(Request,"inHead") AND NOT structIsEmpty(Request.InHead) AND NOT request.mode.ajax>		
	<!--- Check for each stPlaceInHead variable and output relevent html/css/js --->
			
	<cfsavecontent variable="variables.placeInHead">		
				
		<!--- This is the result of any skin:htmlHead calls --->
		<cfparam name="request.inhead.stCustom" default="#structNew()#" />
		<cfparam name="request.inhead.aCustomIDs" default="#arrayNew(1)#" />
		
		<cfif arrayLen(request.inhead.aCustomIDs)>
			<cfloop from="1" to="#arrayLen(request.inHead.aCustomIDs)#" index="i">
				<cfif structKeyExists(request.inHead.stCustom, request.inHead.aCustomIDs[i])>
					<cfoutput>
					#request.inHead.stCustom[request.inHead.aCustomIDs[i]]#
					</cfoutput>
				</cfif>
			</cfloop>
		</cfif>
		
			
		<!--- This is the result of any skin:onReady calls --->
		<cfparam name="request.inhead.stOnReady" default="#structNew()#" />
		<cfparam name="request.inhead.aOnReadyIDs" default="#arrayNew(1)#" />
		
		<cfif arrayLen(request.inhead.aOnReadyIDs)>
			<cfoutput>
			<script type="text/javascript">
				$j(document).ready(function() {	
			</cfoutput>
			
			<cfloop from="1" to="#arrayLen(request.inHead.aOnReadyIDs)#" index="i">
				<cfif structKeyExists(request.inHead.stOnReady, request.inHead.aOnReadyIDs[i])>
					<cfoutput>
					#request.inHead.stOnReady[request.inHead.aOnReadyIDs[i]]#
					</cfoutput>
				</cfif>
			</cfloop>
			
			<cfoutput>
				})
			</script>
			</cfoutput>
			
		</cfif>

	</cfsavecontent>
	
	<cfif len(variables.placeInHead)>
		<cftry>
 			<cfhtmlHead text="#variables.placeInHead#" />
			<cfcatch type="any">
				<cfset application.fapi.throw(argumentCollection="#cfcatch#") />
			</cfcatch>
		</cftry>	
	</cfif>
</cfif>



<cfsetting enablecfoutputonly="no">