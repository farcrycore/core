<cfsetting enablecfoutputonly="Yes">

<!--- 
|| BEGIN FUSEDOC ||

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/Attic/njEktron_scrub.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
$Author: petera $
$Date: 2002/09/27 06:54:04 $
$Name: b100 $
$Revision: 1.1.1.1 $

|| DESCRIPTION || 
Scrubs crap from ecktron.

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)
Geoff Bowers (modius@daemon.com.au)
Nick Shearer (nick@daemon.com.au)

|| ATTRIBUTES ||
-> [attributes.in]: var containing string to be scrubbed
<- [attributes.out]: var, optional defaults to in

|| HISTORY ||
$Log: njEktron_scrub.cfm,v $
Revision 1.1.1.1  2002/09/27 06:54:04  petera
no message

Revision 1.2  2002/09/18 01:03:28  geoff
no message

Revision 1.1  2002/09/03 00:19:21  geoff
no message

Revision 1.3  2002/04/26 02:41:30  matson
no message

Revision 1.2  2002/04/26 02:10:19  matson
no message

Revision 1.1  2001/11/21 15:26:11  matson
no message

Revision 1.4  2001/09/26 21:59:17  matson
changed urlroot to rooturl

Revision 1.3  2001/08/02 16:40:44  nick
added fusedoc comments

Revision 1.2  2001/06/22 13:04:11  matson
Added html strip attributes to remove everything but the color attribute from fonts



|| END FUSEDOC ||
--->



<cfparam name="attributes.in">
<cfparam name="attributes.out" default="#attributes.in#">

<cfif isDefined("caller.#attributes.in#")>
	<cfset in = evaluate("caller.#attributes.in#")>
	<!--- <cfset in = ReplaceNoCase(in,'src="http://#cgi.server_name##application.url.farcry#/images', 'src="../images', 'ALL')> --->
	
	<cf_HtmlStripAttributes value="#in#" tag="font" validAttributes="color" r_Object="in">

	<cfset "caller.#attributes.out#" = in>	
</cfif>


<cfsetting enablecfoutputonly="No">