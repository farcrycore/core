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
<!--- @@displayname: Depricated Tag --->
<!--- @@description:  As a core developer you can flag deprecated code by using this tag to pass in a depricated message --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.message" type="string" />

	<cfif isdefined("application.log.bDeprecated") AND application.log.bDeprecated>		
		<cftrace type="warning" inline="false" text="#GetBaseTemplatePath()# - #attributes.message#" abort="false" />
		<cflog file="deprecated" application="true" type="warning" text="#GetBaseTemplatePath()# - #attributes.message#" />
		<cf_logevent location="#getPageContext().getPage().getCurrentTemplatePath()#" type="application" event="deprecated" notes="#attributes.message#" />
	</cfif>
	
</cfif>

<cfsetting enablecfoutputonly="false">