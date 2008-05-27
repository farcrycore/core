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
contentObjectGet (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobject.cfm,v 1.11 2004/11/30 17:06:16 tom Exp $
$Author: tom $
$Date: 2004/11/30 17:06:16 $
$Name:  $
$Revision: 1.11 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Runs a method on a specified object instance. Mimics the Spectra 
tag of the same name.
------------------------------------------------------------------------->
<cfinclude template="_funclibrary.cfm">

<cfscript>
// attributes
	reqParam("objectid");
	optParam("typename", "");
	optParam("method", "display");

// type lookup if required
	if (NOT len(attributes.typename)) {
		q4 = createObject("component", "farcry.core.packages.fourq.fourq");
		typename = q4.findType(attributes.objectid);
		setVariable("attributes.typename", application.types[typename].typePath);
	}
	
// using type	
	// check for request cache of obj instance
	uniqueId = replace(attributes.objectid,'-','','all');
	objcall="request.o#uniqueid#";
	bcacheused=1;
	if (NOT isDefined(objcall)) {
		request["o#uniqueid#"] = createObject("component", "#attributes.typename#");
		bcacheused=0;
	}
	Evaluate("#objcall#.#attributes.method#(attributes.objectid)");
</cfscript>

<!--- debug output --->
<cfif isDefined("bcacheused") AND bcacheused>
	<cftrace type="information" category="coapi" text="Request cache used for #attributes.typename#.#attributes.method#()" var="attributes.objectid" />
<cfelse>
	<cftrace type="information" category="coapi" text="Instance created for #attributes.typename#.#attributes.method#()" var="attributes.objectid" />
</cfif>
