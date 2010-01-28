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
contentObjectGetMultiple (fourQ COAPI)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/tags/contentobjectgetmultiple.cfm,v 1.17 2005/05/24 03:54:27 geoff Exp $
$Author: geoff $
$Date: 2005/05/24 03:54:27 $
$Name:  $
$Revision: 1.17 $

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


<!--- MPS: Single query to load objectId typename map. Note to Daemon: this could (should?) be intergrated as a new method in fourq.cfc --->
<cfquery name="qGetTypename" datasource="#application.dsn#">
	SELECT	typename, objectId
	FROM	refObjects
	WHERE	objectID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.lObjectIds#" list="true" />)
</cfquery>

<!--- MPS: Create a map of objectId's and their respective 'typename'. This will prevent having to query this simple metadata on every objectid iteration --->
<cfset stObjectMeta = structNew() />
<cfloop query="qGetTypename">
	<cfset stObjectMeta[qGetTypename.objectId] = qGetTypename.typename />
</cfloop>

<!--- MPS: Struct to hold request based singletons of each content type cfc, we don't need to have instance objects in this scenario --->
<cfset stObjectComponents = structNew() />


<cfloop list="#attributes.lObjectIDs#" index="i">
<cftry>
	<cfscript>
		contenttype = stObjectMeta[i];
		if (len(contenttype)) 
		{
			if (NOT structKeyExists(stObjectComponents, contenttype))
			{
				stObjectComponents[contenttype] = createObject("component", application.types[contenttype].typePath);
			}
			o = stObjectComponents[contenttype];
			stObj = o.getData(objectid=i,dsn=attributes.dsn,bshallow=attributes.bShallow);
			
			if (NOT len(attributes.lstatus) OR NOT isDefined("stObJ.status")) 
			{
				// if there is no status specified or the obj has no status property
				stTmp[stObj.objectid] = Duplicate(stObj);
			} 
			else 
			{
				// check status of the obj before including
				if (attributes.lstatus contains stObJ.status)
					stTmp[stObj.objectid] = Duplicate(stObj);
			}	
		}
	</cfscript>
	<cfcatch>
		<!--- hmm.. sometimes stObjectMeta[i] is not correctly populated --->
	</cfcatch>
</cftry>
</cfloop>

<cfscript>
// return result
if (IsDefined("attributes.r_stObjects")) {
	SetVariable("caller.#attributes.r_stObjects#", stTmp);
}
</cfscript>

<!--- $todo: need to implement return result for r_qObjects GB$ --->
