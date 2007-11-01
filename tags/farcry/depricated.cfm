<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname:  --->
<!--- @@description:  As a core developer you can flag deprecated code by using this tag to pass in a depricated message --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.message" default="">

	<cfif isdefined("application.log.bDeprecated") AND application.log.bDeprecated>
		
		<cftrace type="warning" inline="false" text="#GetBaseTemplatePath()# - #attributes.message#" abort="false" />
		<cflog file="deprecated" application="true" type="warning" text="#GetBaseTemplatePath()# - #attributes.message#" />
	</cfif>
	
</cfif>

