<!------------------------------------------------------------------------
contentObjectDelete (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectdelete.cfm,v 1.9 2003/11/05 05:03:33 tom Exp $
$Author: tom $
$Date: 2003/11/05 05:03:33 $
$Name:  $
$Revision: 1.9 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

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


