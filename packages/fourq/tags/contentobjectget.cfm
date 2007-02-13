<!------------------------------------------------------------------------
contentObjectGet (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectget.cfm,v 1.15 2005/10/24 03:49:16 guy Exp $
$Author: guy $
$Date: 2005/10/24 03:49:16 $
$Name:  $
$Revision: 1.15 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)
Paul Harrison (harrisonp@cbc.curtin.edu.au)

Description:
A wrapper to get a content object instance and return its structure.
------------------------------------------------------------------------->
<!--- ContentObjectGet --->

<cfif thisTag.executionmode eq "start">

	<cfinclude template="_funclibrary.cfm">

	<cftry>
		<cfscript>
			// attributes
			reqParam("objectid");
			optParam("typename", "");
			optParam("r_stObject", "stObject");
		    optParam("dsn", application.dsn);
		
			// type lookup if required
			if (NOT len(attributes.typename)) {
				q4 = createObject("component", "farcry.farcry_core.fourq.fourq");
				typename = q4.findType(objectid=attributes.objectid,dsn=attributes.dsn);
				//its possible that missing objects will kill this so we only want to create object if we actually get a typename result
				if (len(typename))
				{
					setVariable("attributes.typename", application.types[typename].typePath);
				}
			}
			
			// using type
			//if typename is empty - we cant create an object, return an empty structure instead
			if(len(attributes.typename))
			{
				// check for request cache of obj instance
				uniqueId = replace(attributes.objectid,'-','','all');
				objcall="request.o#uniqueid#";
				bcacheused=1;
				if (NOT isDefined(objcall)) {
					request["o#uniqueid#"] = createObject("component", "#attributes.typename#");
					bcacheused=0;
				}
				stObj= request["o#uniqueid#"].getData(objectid=attributes.objectid,dsn=attributes.dsn);
			}
			else
				stObj = structNew();
			
			// return result
			SetVariable("caller.#attributes.r_stObject#", stObj);
		</cfscript>
		<cfcatch>
			<cfdump var="#cfcatch#">
			<cfabort>
		</cfcatch>
	</cftry>
	
	<!--- debug output --->
	<cfif isDefined("bcacheused") AND bcacheused>
		<cftrace type="information" category="coapi" text="Request cache used for #attributes.typename#.getdata()" var="stObj.objectid">
	<cfelse>
		<cftrace type="information" category="coapi" text="Instance created #attributes.typename#.getdata()" var="stObj.objectid">
	</cfif>

</cfif>