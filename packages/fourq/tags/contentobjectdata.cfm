<!------------------------------------------------------------------------
contentObjectData (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/core/packages/fourq/tags/contentobjectdata.cfm,v 1.5 2003/03/19 02:16:42 internal Exp $
$Author: internal $
$Date: 2003/03/19 02:16:42 $
$Name:  $
$Revision: 1.5 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
A wrapper to update a content object instance.
------------------------------------------------------------------------->
<cfinclude template="_funclibrary.cfm">

<cfscript>
// attributes
	reqParam("objectid");
	reqParam("typename");
	reqParam("stProperties");
    optParam("dsn", application.dsn);

// define argument collection
	args.objectid=attributes.objectid;
    args.dsn=attributes.dsn;
	args.stProperties=attributes.stProperties;
	
// using type
	o = createObject("component", "#attributes.typename#");
	o.setData(argumentCollection=args);
</cfscript>

