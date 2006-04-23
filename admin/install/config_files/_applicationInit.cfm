<cfsetting enablecfoutputonly="Yes">

<!--- Server Specific Variables --->
<cfinclude template="_serverSpecificVars.cfm">
<cftrace inline="no" text="Server Specific Variables setup" category="project">

<!--- initialise dmSec --->
<cfinclude template="/farcry/farcry_core/tags/farcry/_dmSec.cfm">

<!--- dmSec User Directory setup --->
<cfinclude template="_dmSecUserDirectories.cfm">
<cftrace inline="no" text="dmSec User Directory setup" category="project">

<cfsetting enablecfoutputonly="no">