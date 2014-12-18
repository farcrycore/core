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




<cfparam name="attributes.title" default="&nbsp;" /><!--- The title of the message --->
<cfparam name="attributes.message" default="" /><!--- The actual message. This can be replaced with generatedContent --->
<cfparam name="attributes.pause" default="3000" type="numeric" /><!--- How long (in milliseconds) the message appears before being removed --->
<cfparam name="attributes.sticky" default="false" type="boolean" /><!--- Keep the message displayed until the user actively closes. --->
<cfparam name="attributes.image" default="" /><!--- Image to display with the message --->
<cfparam name="attributes.tags" default="" /><!--- Tags to identify message categories later --->
<cfparam name="attributes.rbkey" default="general.message.#rereplace(attributes.title,'[^\w]','','ALL')#-#rereplace(attributes.message,'[^\w]','','ALL')#" /><!--- The resource path for this message. --->
<cfparam name="attributes.variables" default="#arraynew(1)#" /><!--- Variables for resource translation --->

<!--- legacy attribute --->
<cfif structKeyExists(attributes,"bAutoHide")>
	<cfset attributes.sticky = false />
</cfif>

<cfparam name="request.mode.ajax" default="false" />

<cfif thistag.executionMode eq "Start">
	<!--- IGNORE START MODE --->
</cfif>

<cfif thistag.executionMode eq "End">
	
	<cfloop collection="#attributes#" item="thisattr">
		<cfif refind("var\d+",thisattr)>
			<cfset attributes.variables[mid(thisattr,4,len(thisattr))] = attributes[thisattr] />
		</cfif>
	</cfloop>
	
	<cfif not len(attributes.message)>
		<cfset attributes.message = thisTag.generatedContent />
	</cfif>
	
	<cfif not len(trim(attributes.message))>
		<cfset attributes.message = "&nbsp;" />
	<cfelseif len(attributes.rbkey)>
		<cfset attributes.message = application.fapi.getResource(attributes.rbkey & "@message",attributes.message,attributes.variables) />
	</cfif>
	
	<cfif len(trim(attributes.title)) and len(attributes.rbkey)>
		<cfset attributes.title = application.fapi.getResource(attributes.rbkey & "@title",attributes.title,attributes.variables) />
	</cfif>
	
	<cfset thisTag.generatedContent = "" />
	
	<cfif request.mode.ajax>
		<cfoutput>
		<script type="application/javascript">
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
		</script>
		</cfoutput>
	
			
	<cfelse>
		<cfparam name="session.aGritterMessages" default="#arrayNew(1)#" />
		<cfset arrayAppend(session.aGritterMessages, duplicate(attributes)) />
	</cfif>

	
</cfif>
<cfsetting enablecfoutputonly="false">