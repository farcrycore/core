<cfsetting enablecfoutputonly="true">
<cfsilent>

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
<!--- @@displayname: machineSpecfic --->
<!--- @@description: Executes the contents of the tag only if the machine name matches the current machine name the code is running on.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

	
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>
</cfsilent>

<cfif thisTag.ExecutionMode EQ "Start">
	
	<cfparam name="attributes.name" type="string" /><!---  your local machine name  --->
	
	<cftry>	
		<cfset machineName = createObject("java", "java.net.InetAddress").localhost.getHostName() />
		
		<cfcatch>
			<cfset machineName = "localhost" />
		</cfcatch>
	</cftry>
	
	<cfif not listFindNoCase(attributes.name, machineName)>
		<cfsetting enablecfoutputonly="false">
		<cfexit>
	</cfif>
	
</cfif>

<cfsetting enablecfoutputonly="false">