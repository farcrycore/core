<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header:  $
$Author:  $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
Sets html cache header parameters for web pages.

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> [attributes.days]: How many days to cache for
-> [attributes.hours]: How many hours to cache for
-> [attributes.minutes]: How many minutes to cache for
-> [attributes.seconds]: How many seconds to cache for
-> [url.CacheControlDebug]: Shows how long page is cached for if anything other than 0
--->

<!--- exit tag if its been closed, ie don't run twice --->
<cfif thistag.executionmode eq "end">
	<cfexit method="exittag" />
</cfif>

<!---
	Some firewalls strip off the CFHEADER information,
	some browsers don't support META tags,
	so it's best to include both CFHEADER and META
--->

<cfparam name="url.CacheControlDebug" default="0">

<cfif not( isDefined("attributes.days") OR
			isDefined("attributes.hours") OR
			isDefined("attributes.minutes") OR
			isDefined("attributes.seconds") ) >
	<CFHEADER NAME="Expires" VALUE="Tue, 01 Jan 1985 00:00:01 GMT">
	<CFHEADER NAME="Pragma" VALUE="no-cache">
	<CFHEADER NAME="cache-control" VALUE="no-cache, no-store, must-revalidate">
	
	<cfoutput>
	<META HTTP-EQUIV="Expires" CONTENT="Tue, 01 Jan 1985 00:00:01 GMT" />
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache" />
	<META HTTP-EQUIV="cache-control" CONTENT="no-cache, no-store, must-revalidate" />
	</cfoutput>
	<cfif ( url.CacheControlDebug neq 0 )>
		<cfoutput>Page cached until: Page not cached</cfoutput>
	</cfif>
<cfelse>
	<cfscript>
	gmt = gettimezoneinfo();
	gmt = gmt.utcHourOffset;
	if (gmt EQ 0)
	{
		gmt="";
	}
	else if (gmt GT 0)
	{
		gmt="+"&gmt;
	}

	dateTo=now();
	if ( isDefined("attributes.days") ) dateTo = dateAdd( 'D', #attributes.days#, dateTo );
	if ( isDefined("attributes.hours") )dateTo = dateAdd( 'H', #attributes.hours#, dateTo );
	if ( isDefined("attributes.minutes") )dateTo = dateAdd( 'N', #attributes.minutes#, dateTo );
	if ( isDefined("attributes.seconds") )dateTo = dateAdd( 'S', #attributes.seconds#, dateTo );
	dateString = "#DateFormat( dateTo, 'DDD, DD MMM YYYY' )# #TimeFormat( dateTo, 'HH:mm:ss' )# GMT#gmt#";
	
	if ( url.CacheControlDebug neq 0 ) writeoutput("Page cached until: #dateString#");
	</cfscript>
	
	<CFHEADER NAME="Expires" VALUE="#dateString#">
	<cfoutput>
	<META HTTP-EQUIV="Expires" CONTENT="#dateString#" />
	</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="No">
