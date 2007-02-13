<!------------------------------------------------------------------------
contentObjectGetMultiple (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectgetmultiple.cfm,v 1.17 2005/05/24 03:54:27 geoff Exp $
$Author: geoff $
$Date: 2005/05/24 03:54:27 $
$Name:  $
$Revision: 1.17 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
A wrapper to get multiple content object instances and return their
structures.
------------------------------------------------------------------------->
<!--- 
TODO:
This might be more efficient if we set up a getDataSet() function in 
fourq rather than looping here.

Objects have to be a specific type... maybe needs to be updated to pull
mixed types.

when type attribute not passed the typename attribute requires very 
fixed methodology to work... need to refine
 --->
<cfinclude template="_funclibrary.cfm">

<cfscript>
// attributes
	reqParam("lobjectids");
	optParam("typename", "");
	optParam("r_stObjects", "stObjects");
	optParam("r_qObjects", "qObjects");
	optParam("lstatus", "");
	optParam("dsn", application.dsn);
	optParam("bShallow", false);

// return structure
	stTmp = StructNew();
</cfscript>
<cfloop list="#attributes.lObjectIDs#" index="i">

<cfscript>
// initialise vars
	/* 
	$TODO: - currently doing a typename lookup for each objectid - this 
	will get horrifically inneficient. Find a better solution. $
	*/
	contenttype="";
	q4 = createObject("component", "farcry.farcry_core.packages.fourq.fourq");
	contenttype = q4.findType(objectid=i,dsn=attributes.dsn);
	
	if (not len(contenttype)) {
		continue; // ie. go to next iteration
	}
	setVariable("attributes.typename", application.types[contenttype].typePath);

	// using typename
	o = createObject("component", "#attributes.typename#");
	stObj = o.getData(objectid=i,dsn=attributes.dsn,bshallow=attributes.bShallow);
	// dump(o, "object");
	// dump(i, "getData");
	if (NOT len(attributes.lstatus) OR NOT isDefined("stObJ.status")) {
		// if there is no status specified or the obj has no status property
		stTmp[stObj.objectid] = Duplicate(stObj);
	} else {
		// check status of the obj before including
		if (attributes.lstatus contains stObJ.status)
			stTmp[stObj.objectid] = Duplicate(stObj);
	}
</cfscript>

</cfloop>

<cfscript>
// return result
if (IsDefined("attributes.r_stObjects")) {
	SetVariable("caller.#attributes.r_stObjects#", stTmp);
}
</cfscript>

<!--- $todo: need to implement return result for r_qObjects GB$ --->
