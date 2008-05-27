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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!------------------------------------------------------------------------
contentObjectCreate (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectcreate.cfm,v 1.7 2003/03/19 02:16:42 internal Exp $
$Author: internal $
$Date: 2003/03/19 02:16:42 $
$Name:  $
$Revision: 1.7 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
A wrapper to create a content object instance.
------------------------------------------------------------------------->
<cfinclude template="_funclibrary.cfm">

<cfscript>
// attributes
	reqParam("typename");
	reqParam("stProperties");
    optParam("bAudit", "true");
    optParam("dsn", application.dsn);
	optParam("r_ObjectID", "ObjectID");

// define argument collection
	args.stProperties=attributes.stProperties;
    args.dsn=attributes.dsn;
    args.bAudit=attributes.bAudit;
	if (IsDefined("args.stProperties.objectid"))
		args.objectid=args.stProperties.objectid; 
	else
		args.objectid=CreateUUID(); 
	
// using type
	o = createObject("component", "#attributes.typename#");
	o.createData(argumentCollection=args);

// return objectid
	SetVariable("caller.#attributes.r_ObjectID#", args.objectid);
</cfscript>


