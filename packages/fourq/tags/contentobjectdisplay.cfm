<!------------------------------------------------------------------------
contentObjectDisplay (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectdisplay.cfm,v 1.1 2005/05/24 03:54:27 geoff Exp $
$Author: geoff $
$Date: 2005/05/24 03:54:27 $
$Name:  $
$Revision: 1.1 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

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
