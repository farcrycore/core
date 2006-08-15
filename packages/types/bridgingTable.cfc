<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/versions.cfc,v 1.4.2.2 2006/01/23 22:30:32 geoff Exp $
$Author: geoff $
$Date: 2006/01/23 22:30:32 $
$Name: milestone_3-0-1 $
$Revision: 1.4.2.2 $

|| DESCRIPTION || 
$Description: Component Versions Abstract class for contenttypes package.  
This class defines default handlers and system attributes.$

|| DEVELOPER ||
$Developer: Geoff Bowers (geoff@daemon.com.au) $
--->
<cfcomponent extends="types" bAbstract="true" displayname="Bridging Table Abstract Class" hint="This component allows the user to extend tables that have automatically been created by an array type cfc property -- it should only be inherited.">
<!--------------------------------------------------------------------
system attributes
  properties that all content types require in FarCry
--------------------------------------------------------------------->	
<cfproperty name="parentID" type="uuid" hint="objectID of primary object in the MANY To MANY relationship" required="yes" default="" />
<cfproperty name="data" type="uuid" hint="objectID of foreign object in the MANY To MANY relationship" required="yes" default="" />
<cfproperty name="seq" type="numeric" hint="Enables the array field to be sorted." required="yes" default="0" />


</cfcomponent>

