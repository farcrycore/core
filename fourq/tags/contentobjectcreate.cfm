<!------------------------------------------------------------------------
contentObjectCreate (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectcreate.cfm,v 1.7 2003/03/19 02:16:42 internal Exp $
$Author: internal $
$Date: 2003/03/19 02:16:42 $
$Name:  $
$Revision: 1.7 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

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


