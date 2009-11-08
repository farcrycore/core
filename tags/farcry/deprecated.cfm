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
<!--- @@displayname: Deprecated Tag --->
<!--- @@description:  As a core developer you can flag deprecated code by using this tag to pass in a deprecated message. --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.message" type="string" /><!--- The message to be logged.  Should include instructions for the appropriate best practice to replace the deprecated code. --->
	<cfset application.fapi.deprecated(attributes.message) />
</cfif>

<cfsetting enablecfoutputonly="false">