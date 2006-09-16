<cfsetting enablecfoutputonly="yes" />

<!--- allow developers to close custom tag by exiting on end --->
<cfif thistag.ExecutionMode eq "end">
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
<cfparam name="attributes.bLast" default="0">
<cfparam name="attributes.bActive" default="0">
<cfparam name="attributes.bIncludeHome" default="0">
<cfparam name="attributes.sectionObjectID" default="#request.navID#">
<cfparam name="attributes.functionMethod" default="getDescendants">
<cfparam name="attributes.functionArgs" default="depth=attributes.depth">
<cfparam name="attributes.bDump" default="0">
<cfparam name="attributes.class" default="">
<cfparam name="attributes.style" default="">
<cfparam name="request.sectionObjectID" default="#attributes.navID#">
<cfparam name="attributes.diplayStyle" default="unorderedList">
<cfparam name="attributes.bHideSecuredNodes" default="0"><!--- MJB: check if option to Hide Nav Node Items that user does't have permission to access: default to 0 for backward compatibility --->

<cfif application.config.plugins.fu>
	<cfset fu = createObject("component","#application.packagepath#.farcry.fu")>
</cfif>


		
<!--- // get navigation items --->
<cfset o = createObject("component", "#application.packagepath#.farcry.tree")>
<cfset navFilter=arrayNew(1)>
<cfset navfilter[1]="status IN (#listQualify(request.mode.lvalidstatus, '''')#)">
<cfset qNav = evaluate("o."&attributes.functionMethod&"(objectid=attributes.navID, lColumns='externallink', "&attributes.functionArgs&", afilter=navFilter)")>

<!--- // get ansestors of attributes.navID --->
<cfset qAncestors = o.getAncestors(attributes.sectionObjectID)>
<cfset lAncestors = valuelist(qAncestors.objectid)>


<cfif attributes.bLast>
	<!--- here we get the most right nav so we can add a last class to it if needed --->
	<cfquery name="qMaxRight" dbtype="query">
		select max(nRight) as maxRight from qNav
	</cfquery>
</cfif>
<cffunction name="dump">
	<cfargument name="arg">
	<cfdump var="#arg#">
	<cfabort/>
</cffunction>
<cfif attributes.diplayStyle EQ "aLink">
	<cfloop query="qNav">
		<cfif application.config.plugins.fu>
			<cfset strhref = fu.getFU(qNav.objectid)>
		<cfelse>
			<cfset strhref = application.url.conjurer & "?objectid=" & qNav.objectid>
		</cfif>
		<cfif qNav.currentRow GT 1>
			<cfoutput> | </cfoutput>		
		</cfif>
		<cfoutput><a href="#strhref#" title="#qNav.objectName#">#qNav.objectName#</a></cfoutput>
	</cfloop>
<cfelse>


<!--- determine the policy groups (or roles) this user belongs to --->
<cfif isDefined("session.dmsec.authentication.lPolicyGroupIDs") and listLen(session.dmsec.authentication.lPolicyGroupIDs)>
	<!--- concatenate logged in group permissions with anonymous group permissions --->
	<cfset lpolicyGroupIds = session.dmsec.authentication.lPolicyGroupIDs & "," & application.dmsec.ldefaultpolicygroups>
	
<cfelse>
	<!--- user not logged in, assume anonymous permissions --->
	<cfset lpolicyGroupIds = application.dmsec.ldefaultpolicygroups>
</cfif>


<cfscript>
	// initialise counters
	currentlevel=0; // nLevel counter
	ul=0; // nested list counter

	// build menu [bb: this relies on nLevels, starting from nLevel 2]
	for(i=1; i lt incrementvalue(qNav.recordcount); i=i+1){
		
		
		if (attributes.bHideSecuredNodes EQ 0) {
			iHasViewPermission = 1;
		}
		else{
			iHasViewPermission = request.dmsec.oAuthorisation.checkInheritedPermission(objectid=qNav.ObjectID[i],permissionName="View",lpolicyGroupIds=lpolicyGroupIds);
		}
		
		if (iHasViewPermission EQ 1)
		{
		
					
			if(qNav.nLevel[i] gte attributes.startLevel){
				//dump("test");
				//check external links
				if(structkeyexists(qNav,'externallink') and len(qNav.externallink[i])){
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
				//this means it is the last column in nav
				if(attributes.bLast and qNav.nRight[i] eq qMaxRight.maxRight){
					itemclass=itemclass & 'last ';
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
					if(len(attributes.style)){
						writeOutput(" style=""#attributes.style#""");
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
				writeOutput("><a href="""&href&""">"&trim(qNav.ObjectName[i]) & "</a>");
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
			if(request.sectionObjectID eq application.navid.home)
			{
				writeOutput(" class=""active""");
			}
			writeOutput("><a href=""#application.url.webroot#/"">Home</a></li></ul>");
		}
			
</cfscript>
</cfif>
<cfsetting enablecfoutputonly="no" />