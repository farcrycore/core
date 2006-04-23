<cfsetting enablecfoutputonly="yes" />

<cfif isDefined("request.ver") and request.ver>
	<cfoutput><!-- _genericNav $Revision: 1.2 $ --></cfoutput>
</cfif>

	<!---  Description:	Revised code of the original generic Nav to add classes to the path of the nav and code tidy up 
	 Author:		ben bishop - revised: Gavin Stewart
	 Version:		1.5
	 
	 in:
	 		navID			uuid		parent objectID
	 		depth			integer		number of descendant levels to query
	 		id				string		id of UL (typically for CSS)
	 		class			string		CSS class of UL
	 		flagfirst		boolean		flag to distinguish the first item
	 
	 		functionMethod	string		tree method, defaults to getDescendants
    		    functionArgs	list		list of arguments for method --->
<!--- params --->
<cfparam name="attributes.navID" default="#request.navID#">
<cfparam name="attributes.depth" default="1">
<cfparam name="attributes.startLevel" default="2">
<cfparam name="attributes.id" default="">
<cfparam name="attributes.bFirst" default="0">
<cfparam name="attributes.bActive" default="0">
<cfparam name="attributes.bIncludeHome" default="0">
<cfparam name="attributes.sectionObjectID" default="#request.navID#">
<cfparam name="attributes.functionMethod" default="getDescendants">
<cfparam name="attributes.functionArgs" default="depth=attributes.depth">
<cfparam name="attributes.functionMethod" default="getDescendants">
<cfparam name="attributes.bDump" default="0">
<cfparam name="attributes.class" default="">
<cfparam name="request.sectionObjectID" default="#request.navID#">


<cfif application.config.plugins.fu>
	<cfset fu = createObject("component","#application.packagepath#.farcry.fu")>
</cfif>
<!--- // get navigation items --->
<cfset o = createObject("component", "#application.packagepath#.farcry.tree")>
<cfset navFilter=arrayNew(1)>
<cfset navfilter[1]="status IN (#listQualify(request.mode.lvalidstatus, "'")#)">
<cfset qNav = evaluate("o."&attributes.functionMethod&"(objectid=attributes.navID, lColumns='externallink', "&attributes.functionArgs&", afilter=navFilter)")>
<!--- // get ansestors of attributes.navID --->
<cfset qAncestors = o.getAncestors(request.navID)>
<cfset lAncestors = valuelist(qAncestors.objectid)>
<cffunction name="dump">
	<cfargument name="arg">
	<cfdump var="#arg#">
	<cfabort/>
</cffunction>
<cfscript>
	// initialise counters
	currentlevel=0; // nLevel counter
	ul=0; // nested list counter

	// build menu [bb: this relies on nLevels, starting from nLevel 2]
	for(i=1; i lt incrementvalue(qNav.recordcount); i=i+1){
		if(qNav.nLevel[i] gte attributes.startLevel){
			//dump("test");
			//check external links
			if(len(qNav.externallink[i])){
				object = trim(qNav.externallink[i]);
			}
			else{
				object = trim(qNav.ObjectID[i]);
			}
			//check for friendly urls
			if(application.config.plugins.fu){
				href = fu.getFU(object);
			}
			else{
				href = application.url.conjurer & "?objectid=" & object;
			}
			itemclass='';
			if(i eq 1 and attributes.bFirst){
				itemclass=itemclass & 'first ';
			}
			if(attributes.bActive and trim(qNav.ObjectID[i]) eq request.sectionObjectID or listfind(lAncestors, trim(qNav.ObjectID[i]))){
				itemclass=itemclass & 'active ';
			}
			
			// update counters
			previouslevel=currentlevel;
			currentlevel=qNav.nLevel[i];
			// build nested list
			// if first item, open first list
			if(previouslevel eq 0) {
				writeOutput("<ul");
				// add id or class if specified
				if(len(attributes.id)){
					writeOutput(" id=""#attributes.id#""");
				}
				if(len(attributes.class)){
					writeOutput(" class=""#attributes.class#""");
				}
				writeOutput(">");
				//include home if requested
				if(attributes.bIncludeHome){
					writeOutput("<li");
					if(request.sectionObjectID eq application.navid.home){
						writeOutput(" class=""active""");
					}
					writeOutput("><a href=""#application.url.webroot#/"">Home</a></li>");
				}
				ul=ul+1;
			}
			else if(currentlevel gt previouslevel){
				// if new level, open new list
				writeOutput("<ul>");
				ul=ul+1;
			}
			else if(currentlevel lt previouslevel){
				// if end of level, close items and lists until at correct level
				writeOutput(repeatString("</li></ul></li>",previousLevel-currentLevel));
				ul=ul-(previousLevel-currentLevel);
			}
			else{
				// close item
				writeOutput("</li>");
			}
			// open a list item
			writeOutput("<li");
			if(len(trim(itemclass))){
				// add a class
				writeOutput(" class="""&trim(itemclass)&"""");
			}
			// write the link
			writeOutput("><a href="""&href&""">"&trim(qNav.ObjectName[i])&"</a>");
		}
	}
	// end of data, close open items and lists
	writeOutput(repeatString("</li></ul>",ul));
</cfscript>
<cfsetting enablecfoutputonly="no" />