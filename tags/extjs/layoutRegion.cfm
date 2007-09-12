<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: extjs Layout Region Div --->
<!--- @@description: Places a Layout Region Div on the page.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>


<cfparam name="attributes.id" default="" />
<cfparam name="attributes.title" default="" />
<cfparam name="attributes.class" default="" />
<cfparam name="attributes.style" default="" />

<!------------------ 
START TAG
 ------------------>
<cfif thistag.executionMode eq "start">
<cfoutput>
<div id="#attributes.id#" class="#attributes.class#" style="#attributes.style#">
</cfoutput>
</cfif>


<cfif thistag.executionMode eq "End">
<cfoutput>
</div>
</cfoutput>
</cfif>


<cfsetting enablecfoutputonly="false">