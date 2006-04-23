<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmRedirect.cfc,v 1.2 2004/09/08 08:04:33 geoff Exp $
$Author: geoff $
$Date: 2004/09/08 08:04:33 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmRedirect Type $

|| DEVELOPER ||
$Developer: Daniela Milton (daniela@daemon.com.au) $

--->

<cfcomponent extends="types" displayname="dmRedirect handler" hint="Holds redirect url information for user to resolve a refered link.">

<!------------------------------------------------------------------------
	type properties
------------------------------------------------------------------------->
<!--- randomly generated unique id for this link (6 alpha num chars) --->
<cfproperty name="shortID" type="string" hint="Unique ID of this redirect link." required="yes" default=0> 
<!--- the URL that is associated with this redirect --->
<cfproperty name="destinationURL" type="string" hint="Destination URL of this redirect (full url)." required="yes" default="/index.cfm"> 
<!--- how many hits has this redirect generated? --->
<cfproperty name="hits" type="numeric" hint="Holds the number of hits this referred URL has had." required="no" default=0> 
<!--- redirect type: 
	 'STF' (send to friend) 
	 '' (eCards)
	 '' (custom links that need tracking eg - email campaign)
--->
<cfproperty name="redirectType" type="string" hint="Holds the type of redirect." required="no" default=""> 
<!--- the page title that the user will be redirected to --->
<cfproperty name="title" type="nstring" hint="URL page title that the user will be redirected to." required="no" default="">

<!--- Object Methods --->
<!--- NO methods for this object --->	
</cfcomponent>