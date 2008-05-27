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
contentObjectDisplay (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectdisplay.cfm,v 1.1 2005/05/24 03:54:27 geoff Exp $
$Author: geoff $
$Date: 2005/05/24 03:54:27 $
$Name:  $
$Revision: 1.1 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Runs a display template from the webskin on a specified object instance. 
------------------------------------------------------------------------->
<cfinclude template="_funclibrary.cfm">

<cftry>
<cfscript>
// attributes
	reqParam("objectid");
	optParam("typename", "");
	optParam("template", "displayTeaser");

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
	// writeoutput("#objcall#.getDisplay(#attributes.objectid#, '#attributes.template#')");
	Evaluate("#objcall#.getDisplay('#attributes.objectid#', '#attributes.template#')");
</cfscript>

<cfcatch><cfdump var="#cfcatch#"></cfcatch>

</cftry>
<!--- debug output --->
<cfif isDefined("bcacheused") AND bcacheused>
	<cftrace type="information" category="coapi" text="Request cache used for #attributes.typename#.#attributes.method#()" var="attributes.objectid">
<cfelse>
	<cftrace type="information" category="coapi" text="Instance created for #attributes.typename#.#attributes.method#()" var="attributes.objectid">
</cfif>
