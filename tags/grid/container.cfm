<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: html div --->
<!--- @@description: A standard HTML div tag usefull when coding so that opening and closing cfoutput tags are not required thereby cleaning up output.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.id" default="" />
	<cfparam name="attributes.class" default="" />
	<cfparam name="attributes.style" default="" />

	<cfoutput><div <cfif len(attributes.id)>id="#attributes.id#"</cfif> class="container <cfif len(attributes.class)>#attributes.class#</cfif>" <cfif len(attributes.style)>style="#attributes.style#"</cfif>></cfoutput>
</cfif>

<cfif thistag.executionMode eq "End">
	
	<cfoutput></div></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">