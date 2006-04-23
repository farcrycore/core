<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/listOfLinks.cfm,v 1.4 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: builds nested HTML lists from a query based on nLevels. $


|| DEVELOPER ||
$Developer: Ben Bishop (ben@daemon.com.au) $

Required attributes
	qData		query containing objectID, objectName, nLevel, externalLink
	
Optional attributes
	startLevel	minimum nLevel to display (for nav, typically = 2; Root = 0, Home = 1)
	objectID	objectID of active node
	lLineage	list of objectIDs, direct line from first node to active node
	listType	type of HTML list: ul (default), ol
	
	idList		ID of the first list
	
	** cumulative classe names can be applied to lists, items and anchors **
	classLIfirst		class of the very first list item
	classLIlineage		class of a list item in lLineage
	classLIcurrent		class of the list item matching current navID
	
--->

<cfparam name="attributes.qData"			type="query"	default="">

<cfparam name="attributes.startLevel"		type="integer"	default="2">
<cfparam name="attributes.objectID"			type="uuid"		default="#request.navID#">
<cfparam name="attributes.lLineage"			type="string"	default="">

<cfparam name="attributes.listType"			type="string"	default="ul">

<cfparam name="attributes.idList"			type="string"	default="">
<cfparam name="attributes.classLIfirst"		type="string"	default="">
<cfparam name="attributes.classLIlineage"	type="string"	default="">
<cfparam name="attributes.classLIcurrent"	type="string"	default="current">

<cfscript>
	// initial values
	qData = attributes.qData;
	
	if(application.config.plugins.fu) {
		fu = createObject("component","#application.packagepath#.farcry.fu");
	}
	
	currentlevel = -1; // set less than first possible nLevel (Root's nLevel is 0)
	list = 0; // number of open UL elements

	// loop through query records
	for(i=1; i lte qData.recordcount; i=i+1) {
		// only display record if its nLevel is greater than or equal the startLevel
		if(qData.nLevel[i] gte attributes.startLevel) {
			
		// CSS classes
			listID = '';
			LIclass = '';

			if(currentlevel eq -1) {
				listID = '#trim(attributes.idList)#';
				LIclass = LIclass & '#attributes.classLIfirst# ';
			}
			
			if(listFind(attributes.lLineage,trim(qData.ObjectID[i]))) { 
				LIclass = LIclass & '#attributes.classLIlineage# ';
			}
			
			if (trim(qData.ObjectID[i]) eq attributes.objectID) {
				LIclass = LIclass & '#attributes.classLIcurrent# ';
			}

			LIclass = trim(LIclass);


		// href value
			// is this an externalLink?
			if(len(qData.externalLink[i])) {
				object = trim(qData.externalLink[i]);
			}
			else {
				object = trim(qData.ObjectID[i]);
			}
			
			// are we using Friendly URLs or objectIDs?
			if(application.config.plugins.fu) {
				href = fu.getFU(object);
			}
			else {
				href = application.url.conjurer & "?objectid=" & object;
			}			
			
		// link label
			label = trim(qData.ObjectName[i]);
			
			
		// update levels
			previouslevel=currentlevel;
			currentlevel=qData.nLevel[i];
			
		// output markup
			// if new level, open new list
			if(currentlevel gt previouslevel) {
				writeOutput("<#attributes.listType#");
				
				// is there an ID for this list?
				if(len(listID)) {
					writeOutput(" id=""#listID#""");
				}
				writeOutput(">");
				
				list=list+1;
			}
			
			// if end of level, close items and lists until at correct level
			else if(currentlevel lt previouslevel) {
				writeOutput(repeatString("</li></#attributes.listType#></li>",previousLevel-currentLevel));
				list=list-(previousLevel-currentLevel);
			}

			// close item
			else {
				writeOutput("</li>");
			}
			
			
			// write the list item
			writeOutput("<li");
			
			if(len(LIclass)) {
				writeOutput(" class=""#LIclass#""");
			}
			
			writeOutput(">");

			// write the link
			writeOutput("<a href=""#href#"" title=""#label#"">#label#</a>");
		}
	}
	
	// end of data, close open items and lists
	writeOutput(repeatString("</li></#attributes.listType#>",list));

</cfscript>
