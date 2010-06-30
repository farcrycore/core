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
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/versions.cfc,v 1.4.2.2 2006/01/23 22:30:32 geoff Exp $
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
<cfcomponent extends="types" bAbstract="true" displayname="Bridging Table Abstract Class" hint="This component allows the user to extend tables that have automatically been created by an array type cfc property -- it should only be inherited." bRefObjects="false">
<!--------------------------------------------------------------------
system attributes
  properties that all content types require in FarCry
--------------------------------------------------------------------->	
<cfproperty name="parentID" type="uuid" hint="objectID of primary object in the MANY To MANY relationship" required="yes" default="" />
<cfproperty name="data" type="uuid" hint="objectID of foreign object in the MANY To MANY relationship" required="yes" default="" />
<cfproperty name="seq" type="numeric" hint="Enables the array field to be sorted." required="yes" default="0" />
<cfproperty name="typename" type="string" hint="Stores the typename that the data id relates to." default="" />


</cfcomponent>

