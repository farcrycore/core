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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
<cfparam name="attributes.pause" default="3" type="numeric" /><!--- How long the message appears before being removed --->
<cfparam name="attributes.bAutoHide" default="true" type="boolean" /><!--- Automatically hide the message after the pause --->

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
			<script type="text/javascript">
			Ext.example.init, Ext.example;
			Ext.example.msg('#attributes.title#','#attributes.message#', #attributes.pause#, #attributes.bAutoHide#);
			</script>
		</cfoutput>	
	<cfelse>
		<cfparam name="session.aExtMessages" default="#arrayNew(1)#" />
		<cfset stMessage = structNew() />
		<cfset stMessage.title = JSStringFormat(attributes.title) />
		<cfset stMessage.message = JSStringFormat(attributes.message) />
		<cfset stMessage.pause = attributes.pause />
		<cfset stMessage.bAutoHide = attributes.bAutoHide />
		<cfset arrayAppend(session.aExtMessages, stMessage) />
		
		
	</cfif>

	
</cfif>
<cfsetting enablecfoutputonly="false">