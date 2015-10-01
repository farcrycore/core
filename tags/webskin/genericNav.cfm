<cfsetting enablecfoutputonly="yes" />

<!--- allow developers to close custom tag by exiting on end --->
<cfif thistag.ExecutionMode eq "end">
	<cfsetting enablecfoutputonly="false" />
	<cfexit method="exittag" />
</cfif>

<cfif isDefined("request.ver") and request.ver>
	<cfoutput><!-- _genericNav $Revision: 1.2.2.4 $ --></cfoutput>
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
<cfparam name="attributes.firstClass" default="first" /><!--- @@attrhint: If enabled, this css class name is applied to the first list element in the nav --->
<cfparam name="attributes.bLast" default="0">
<cfparam name="attributes.lastClass" default="last" /><!--- @@attrhint: If enabled, this css class name is applied to the last list element in the nav --->
<cfparam name="attributes.bActive" default="0">
<cfparam name="attributes.activeClass" default="active" /><!--- @@attrhint: If enabled, this css class name is applied to the active list element and its direct ancestors (<li>'s only) --->
<cfparam name="attributes.bIncludeHome" default="0">
<cfparam name="attributes.sectionObjectID" default="#request.navID#">
<cfparam name="attributes.functionMethod" default="getDescendants">
<cfparam name="attributes.functionArgs" default="depth=attributes.depth">
<cfparam name="attributes.bDump" default="0">
<cfparam name="attributes.class" default="">
<cfparam name="attributes.style" default="">
<cfparam name="request.sectionObjectID" default="#request.navID#">
<cfparam name="attributes.displayStyle" default="unorderedList">
<cfparam name="attributes.bHideSecuredNodes" default="0"><!--- MJB: check if option to Hide Nav Node Items that user does't have permission to access: default to 0 for backward compatibility --->
<cfparam name="attributes.afilter" default="#arrayNew(1)#">
<cfparam name="attributes.bSpan" default="false">
<cfparam name="attributes.separator" default="|">
<cfif attributes.functionMethod eq "getDescendants">
	<cfparam name="attributes.lColumns" default="navType,externallink,lNavIDAlias,internalRedirectID,externalRedirectURL,target" />
<cfelse>
	<cfparam name="attributes.lColumns" default="externallink,lNavIDAlias" />
</cfif>
<cfparam name="attributes.homeAlias" default="home" />


<!--- // get navigation items --->
<cfset o = createObject("component", "#application.packagepath#.farcry.tree")>
<cfset navFilter=duplicate(attributes.afilter)>
<cfset arrayAppend(navFilter, "status IN (#listQualify(request.mode.lvalidstatus, '''')#)") />
<cfset qNav = evaluate("o."&attributes.functionMethod&"(objectid=attributes.navID, lColumns=attributes.lColumns, "&attributes.functionArgs&", afilter=navFilter)")>

<!--- // get ansestors of attributes.navID --->
<cfset qAncestors = o.getAncestors(attributes.sectionObjectID)>
<cfset lAncestors = valuelist(qAncestors.objectid)>

<cfif attributes.bIncludeHome>
	<!--- // get application.navid.home objectName --->
	<cfset homeNode = o.getNode(objectID=#application.fapi.getNavID(attributes.homeAlias)#)>
</cfif>

<cfif attributes.bLast>
	<!--- here we get the most right nav so we can add a last class to it if needed --->
	<cfquery name="qMaxRight" dbtype="query">
		select max(nRight) as maxRight from qNav
	</cfquery>
</cfif>

<cfscript>

if (attributes.displayStyle EQ "aLink") {
	
	// Flag used to track when separators should be included
	bIncludeSeparator = false;
	//include home if requested
	if(attributes.bIncludeHome){
		
		homeURL = application.fapi.getLink(alias=attributes.homeAlias);
		if (not len(homeURL)){
			homeURL = "/";
		}
		// write the link
		writeOutput('<a href="#homeURL#" title="#trim(homeNode.objectName)#">');
		if(attributes.bSpan) writeOutput("<span>");
		writeOutput(trim(homeNode.objectName));
		if(attributes.bSpan) writeOutput("</span>");
		writeOutput("</a>");
		
		// Don't just output a separator as there may be no other links to output
		bIncludeSeparator = true;
	}
	
		
	// build menu [bb: this relies on nLevels, starting from nLevel 2]
	for(i=1; i lt incrementvalue(qNav.recordcount); i=i+1){
		
		
		if (attributes.bHideSecuredNodes EQ 0) {
			iHasViewPermission = 1;
		}
		else{
			iHasViewPermission = application.security.checkPermission(object=qNav.ObjectID[i],permission="View");
		}
		
		// Should we display the link?
		if (iHasViewPermission EQ 1 and qNav.nLevel[i] gte attributes.startLevel){
			if((structkeyexists(qNav,"navType") and qNav.navType[i] eq "externallink") or ((not structkeyexists(qNav,"navType") or qNav.navType[i] eq "") and structkeyexists(qNav,'externallink') and len(qNav.externallink[i]))){
				href = application.fapi.getLink(objectid=trim(qNav.ObjectID[i]));
			}
			else if (structkeyexists(qNav,"navType") and qNav.navType[i] eq "internalRedirectID"){
				href = application.fapi.getLink(objectid=qNav.internalRedirectID[i]);
			}
			else if (structkeyexists(qNav,"navType") and qNav.navType[i] eq "externalRedirectURL"){
				href = qNav.externalRedirectURL[i];
			}
			else{
				href = application.fapi.getLink(objectid=trim(qNav.ObjectID[i]));
			}
			
			// Only display a separator if the link
			if(bIncludeSeparator) {
				writeOutput(" #attributes.separator# ");
			}
			else{
				// Ensure a separator is displayed before future links
				bIncludeSeparator = true;
			}
			// write the link
			writeOutput('<a href="#href#" title="#trim(qNav.ObjectName[i])#"');
			if (structkeyexists(qNav,"target") and len(trim(qNav.target[i]))) writeOutput(' target="#qNav.target[i]#"');
			writeOutput(">");
			if(attributes.bSpan) writeOutput("<span>");
			writeOutput(trim(qNav.ObjectName[i]));
			if(attributes.bSpan) writeOutput("</span>");
			writeOutput("</a>");
		}
	}
}
else {

	// initialise counters
	currentlevel=0; // nLevel counter
	ul=0; // nested list counter
	bHomeFirst = false; // used to stop the first node being flagged as first if home link is inserted.
	bFirstNodeInLevel = true; // used to track the first node in each level.						
	// build menu [bb: this relies on nLevels, starting from nLevel 2]
	for(i=1; i lt incrementvalue(qNav.recordcount); i=i+1){
		
		
		if (attributes.bHideSecuredNodes EQ 0) {
			iHasViewPermission = 1;
		}
		else{
			iHasViewPermission = application.security.checkPermission(object=qNav.ObjectID[i],permission="View");
		}
		
		if (iHasViewPermission EQ 1)
		{
		
					
			if(qNav.nLevel[i] gte attributes.startLevel){
				if((structkeyexists(qNav,"navType") and qNav.navType[i] eq "externallink") or ((not structkeyexists(qNav,"navType") or qNav.navType[i] eq "") and structkeyexists(qNav,'externallink') and len(qNav.externallink[i]))){
					href = application.fapi.getLink(objectid=trim(qNav.ObjectID[i]));
				}
				else if (structkeyexists(qNav,"navType") and qNav.navType[i] eq "internalRedirectID"){
					href = application.fapi.getLink(objectid=qNav.internalRedirectID[i]);
				}
				else if (structkeyexists(qNav,"navType") and qNav.navType[i] eq "externalRedirectURL"){
					href = qNav.externalRedirectURL[i];
				}
				else{
					href = application.fapi.getLink(objectid=trim(qNav.ObjectID[i]));
				}
				itemclass='';
				
				if(structKeyExists(qNav,'lNavIDAlias') and listLen(qNav.lNavIDAlias[i])){
					for (j = 1; j LTE listLen(qNav.lNavIDAlias[i]); j = j + 1){
						itemclass=itemclass & listGetAt(qNav.lNavIDAlias[i],j) & " ";
					}	
				}
				if(qNav.nLevel[i] lt attributes.startlevel+attributes.depth - 1  and qNav.nRight[i]-qNav.nleft[i] neq 1) {
					itemclass=itemclass & 'parent ';	
				}
				

				//this means it is the last column in nav
				if(attributes.bLast and qNav.nRight[i] eq qMaxRight.maxRight){
					itemclass=itemclass & '#attributes.lastClass# ';
				}
				if(attributes.bActive and (trim(qNav.ObjectID[i]) eq attributes.sectionObjectID or listfind(lAncestors, trim(qNav.ObjectID[i])))){
					itemclass=itemclass & '#attributes.activeClass# ';
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
					if(len(attributes.style)){
						writeOutput(" style=""#attributes.style#""");
					}
					writeOutput(">");
					//include home if requested
					if(attributes.bIncludeHome){
						homeclass = 'home ';
						
						if(attributes.bFirst){
							homeclass=homeclass & ' #attributes.firstClass# ';
							bHomeFirst = true;
						}				
						
						writeOutput("<li");
						if(attributes.sectionObjectID eq application.fapi.getNavID(attributes.homeAlias)){
							homeclass=homeclass & ' #attributes.ActiveClass# ';
						}
						writeOutput(" class="""&trim(homeclass)&"""");
						
						homeURL = application.fapi.getLink(alias=attributes.homeAlias);
						if (len(homeURL)){
							writeOutput("><a href=""#homeURL#"">");
						}
						else {
							writeOutput("><a href=""/"">");
						}
						if(attributes.bSpan) writeOutput("<span>");
						writeOutput("#homeNode.objectName#");
						if(attributes.bSpan) writeOutput("</span>");
						writeOutput("</a></li>");
					}
					ul=ul+1;
				}
				else if(currentlevel gt previouslevel){
					// if new level, open new list
					writeOutput("<ul>");
					ul=ul+1;
					bFirstNodeInLevel = true;
				}
				else if(currentlevel lt previouslevel){
					// if end of level, close current item
					writeOutput("</li>");
					// close lists until at correct level
					writeOutput(repeatString("</ul></li>",previousLevel-currentLevel));
					ul=ul-(previousLevel-currentLevel);
				}
				else{
					// close item
					writeOutput("</li>");
				}
				if(attributes.bFirst){
					if(previouslevel eq 0 AND bHomeFirst) {
						//top level and home link is first
					} else {
						if(bFirstNodeInLevel){
							itemclass=itemclass & 'first ';
							bFirstNodeInLevel=false;
						}
					}
					
				}
				// open a list item
				writeOutput("<li");
				if(len(trim(itemclass))){
					// add a class
					writeOutput(" class="""&trim(itemclass)&"""");
				}
				// write the link
				writeOutput("><a href="""&href&"""");
				if (structkeyexists(qNav,"target") and len(trim(qNav.target[i]))) writeOutput(' target="#qNav.target[i]#"');
				writeOutput(">");
				if(attributes.bSpan) writeOutput("<span>");
				writeOutput(trim(qNav.ObjectName[i]));
				if(attributes.bSpan) writeOutput("</span>");
				writeOutput("</a>");
			}
		}
	}
	// end of data, close open items and lists
	writeOutput(repeatString("</li></ul>",ul));
	

	if (attributes.bIncludeHome AND ul EQ 0)
		{
			writeOutput("<ul");
			
			// add id or class if specified
			if(len(attributes.id))
			{
				writeOutput(" id=""#attributes.id#""");
			}
			if(len(attributes.class))
			{
				writeOutput(" class=""#attributes.class#""");
			}
			writeOutput(">");
						
			writeOutput("<li");
			if(attributes.sectionObjectID eq application.fapi.getNavID('home'))
			{
				writeOutput(" class=""active""");
			}
			writeOutput("><a href=""#application.url.webroot#/"">#homeNode.objectName#</a></li></ul>");
		}
		
}	
</cfscript>
<cfsetting enablecfoutputonly="no" />
