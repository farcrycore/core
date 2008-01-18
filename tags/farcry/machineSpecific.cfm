<cfsetting enablecfoutputonly="true">
<cfsilent>

<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: machineSpecfic --->
<!--- @@description: Executes the contents of the tag only if the machine name matches the current machine name the code is running on.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

	
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>
</cfsilent>

<cfif thisTag.ExecutionMode EQ "Start">
	
	<cfparam name="attributes.name" type="string" /><!---  your local machine name  --->
	
	<cfset machineName = createObject("java", "java.net.InetAddress").localhost.getHostName() />
	
	<cfif not listFindNoCase(attributes.name, machineName)>
		<cfsetting enablecfoutputonly="false">
		<cfexit>
	</cfif>
	
</cfif>

<cfsetting enablecfoutputonly="false">