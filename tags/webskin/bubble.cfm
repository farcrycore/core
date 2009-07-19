<cfsetting enablecfoutputonly="true">
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
<!--- @@displayname: Ext Notification Message --->
<!--- @@description: Displays a notification message on next request end.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />




<cfparam name="attributes.title" default="" /><!--- The title of the message --->
<cfparam name="attributes.message" default="" /><!--- The actual message. This can be replaced with generatedContent --->
<cfparam name="attributes.pause" default="3000" type="numeric" /><!--- How long (in milliseconds) the message appears before being removed --->
<cfparam name="attributes.sticky" default="false" type="boolean" /><!--- Keep the message displayed until the user actively closes. --->
<cfparam name="attributes.image" default="" /><!--- Image to display with the message --->

<!--- legacy attribute --->
<cfif structKeyExists(attributes,"bAutoHide")>
	<cfset attributes.sticky = false />
</cfif>

<cfparam name="request.mode.ajax" default="false" />

<cfif thistag.executionMode eq "Start">
	<!--- IGNORE START MODE --->
</cfif>

<cfif thistag.executionMode eq "End">

	<cfif not len(attributes.message)>
		<cfset attributes.message = thisTag.generatedContent />
	</cfif>
	
	<cfset thisTag.generatedContent = "" />
	
	<cfif request.mode.ajax>
		<cfoutput>
		$j.gritter.add({
			// (string | mandatory) the heading of the notification
			title: '#jsstringformat(attributes.title)#',
			// (string | mandatory) the text inside the notification
			text: '#jsstringformat(attributes.message)#',
			// (string | optional) the image to display on the left
			image: '#attributes.image#',
			// (bool | optional) if you want it to fade out on its own or just sit there
			sticky: #attributes.sticky#, 
			// (int | optional) the time you want it to be alive for before fading out (milliseconds)
			time: #attributes.pause#
		});
		</cfoutput>
	
			
	<cfelse>
		<cfparam name="session.aGritterMessages" default="#arrayNew(1)#" />
		<cfset stMessage = structNew() />
		<cfset stMessage.title = JSStringFormat(attributes.title) />
		<cfset stMessage.message = JSStringFormat(attributes.message) />
		<cfset stMessage.image = attributes.image />
		<cfset stMessage.pause = attributes.pause />
		<cfset stMessage.sticky = attributes.sticky />
		<cfset arrayAppend(session.aGritterMessages, stMessage) />
		
		
	</cfif>

	
</cfif>
<cfsetting enablecfoutputonly="false">