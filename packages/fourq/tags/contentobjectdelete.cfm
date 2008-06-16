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
<!------------------------------------------------------------------------
contentObjectDelete (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectdelete.cfm,v 1.9 2003/11/05 05:03:33 tom Exp $
$Author: tom $
$Date: 2003/11/05 05:03:33 $
$Name:  $
$Revision: 1.9 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
A wrapper to delete a content object instance.
------------------------------------------------------------------------->
<cfinclude template="_funclibrary.cfm">

<cfscript>
// attributes
	optParam("typename","");
    optParam("dsn", application.dsn);
	reqParam("ObjectID");


//type lookup if required
	if (NOT len(attributes.typename)) {
		q4 = createObject("component", "farcry.core.packages.fourq.fourq");
		typename = q4.findType(attributes.objectid);
		setVariable("attributes.typename", application.types[typename].typePath);
	}	

// using type
	o = createObject("component", "#attributes.typename#");
	o.deleteData(objectid=attributes.objectid,dsn=attributes.dsn);
</cfscript>


