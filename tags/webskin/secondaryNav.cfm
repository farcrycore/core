<!--- 
secondary navigation tag
 - builds a query with 2nd nav info

Environment
request.navid

--->

<cfsetting enablecfoutputonly="Yes">

<cfparam name="attributes.navid" default="#request.navid#">
<cfparam name="attributes.bIncludeParent" default="true">
<cfparam name="attributes.r_navQuery" default="">
<cfparam name="attributes.bDisplay" default="false">

<cfscript>
// invoke tree component
o = createObject("component", "fourq.utils.tree.tree");
	qChildren = o.getChildren(objectid=attributes.navid);
	qAncestors = o.getAncestors(objectid=attributes.navid, bIncludeSelf=true);

// is location a leaf node?
if (qChildren.recordCount eq 0) {
	bLeaf = true;
	if (qAncestors.objectid[qAncestors.recordcount-2] eq application.navid.root)
		attributes.bIncludeParent = false;
} else {
	bLeaf = false;
	if (qAncestors.objectid[qAncestors.recordcount-1] eq application.navid.root)
		attributes.bIncludeParent = false;
}

// build navigation query
q2ndNav = queryNew("objectid, label, bHeld, bParent, bSibling, bChild, pos");
menupos = 1;

if (bLeaf) {
	if (attributes.bIncludeParent) {
		// include grandparent
		queryAddRow(q2ndNav, 1);
		querySetCell(q2ndNav, "objectid", qAncestors.objectid[qAncestors.recordcount-2]);
		querySetCell(q2ndNav, "label", qAncestors.objectname[qAncestors.recordcount-2]);
		querySetCell(q2ndNav, "bHeld", 0);
		querySetCell(q2ndNav, "bParent", 1);
		querySetCell(q2ndNav, "bSibling", 0);
		querySetCell(q2ndNav, "bChild", 0);
		querySetCell(q2ndNav, "pos", menupos);
		menupos = menupos+1;
	}
	// include parent as intermediary node
	queryAddRow(q2ndNav, 1);
	querySetCell(q2ndNav, "objectid", qAncestors.objectid[qAncestors.recordcount-1]);
	querySetCell(q2ndNav, "label", qAncestors.objectname[qAncestors.recordcount-1]);
	querySetCell(q2ndNav, "bHeld", 0);
	querySetCell(q2ndNav, "bParent", 0);
	querySetCell(q2ndNav, "bSibling", 1);
	querySetCell(q2ndNav, "bChild", 0);
	querySetCell(q2ndNav, "pos", menupos);
	menupos = menupos+1;
	
	// include self as child
	queryAddRow(q2ndNav, 1);
	querySetCell(q2ndNav, "objectid", qAncestors.objectid[qAncestors.recordcount]);
	querySetCell(q2ndNav, "label", qAncestors.objectname[qAncestors.recordcount]);
	querySetCell(q2ndNav, "bHeld", 1);
	querySetCell(q2ndNav, "bParent", 0);
	querySetCell(q2ndNav, "bSibling", 0);
	querySetCell(q2ndNav, "bChild", 1);
	querySetCell(q2ndNav, "pos", menupos);
	menupos = menupos+1;
	
	// include siblings as children
	qSiblings = o.getSiblings(objectid=qAncestors.objectid[qAncestors.recordcount]);
	
	for (i=1; i lte qSiblings.recordCount; i=i+1) {
	queryAddRow(q2ndNav, 1);
	querySetCell(q2ndNav, "objectid", qSiblings.objectid[i]);
	querySetCell(q2ndNav, "label", qSiblings.objectname[i]);
	querySetCell(q2ndNav, "bHeld", 0);
	querySetCell(q2ndNav, "bParent", 0);
	querySetCell(q2ndNav, "bSibling", 0);
	querySetCell(q2ndNav, "bChild", 1);
	querySetCell(q2ndNav, "pos", menupos);
	menupos = menupos+1;
	}

	// include siblings of parent as uncles
	//make sure parent is not home
	if (qAncestors.objectid[qAncestors.recordcount-1] neq application.navid.home) {
		qSiblings = o.getSiblings(objectid=qAncestors.objectid[qAncestors.recordcount-1]);
		
		for (i=1; i lte qSiblings.recordCount; i=i+1) {
		queryAddRow(q2ndNav, 1);
		querySetCell(q2ndNav, "objectid", qSiblings.objectid[i]);
		querySetCell(q2ndNav, "label", qSiblings.objectname[i]);
		querySetCell(q2ndNav, "bHeld", 0);
		querySetCell(q2ndNav, "bParent", 0);
		querySetCell(q2ndNav, "bSibling", 1);
		querySetCell(q2ndNav, "bChild", 0);
		querySetCell(q2ndNav, "pos", menupos);
		menupos = menupos+1;
		}
	}
	
} else {
	if (attributes.bIncludeParent) {
		// include parent
		queryAddRow(q2ndNav, 1);
		querySetCell(q2ndNav, "objectid", qAncestors.objectid[qAncestors.recordcount-1]);
		querySetCell(q2ndNav, "label", qAncestors.objectname[qAncestors.recordcount-1]);
		querySetCell(q2ndNav, "bHeld", 0);
		querySetCell(q2ndNav, "bParent", 1);
		querySetCell(q2ndNav, "bSibling", 0);
		querySetCell(q2ndNav, "bChild", 0);
		querySetCell(q2ndNav, "pos", menupos);
		menupos = menupos+1;
	}
	// include self at sibling level
	queryAddRow(q2ndNav, 1);
	querySetCell(q2ndNav, "objectid", qAncestors.objectid[qAncestors.recordcount]);
	querySetCell(q2ndNav, "label", qAncestors.objectname[qAncestors.recordcount]);
	querySetCell(q2ndNav, "bHeld", 1);
	querySetCell(q2ndNav, "bParent", 0);
	querySetCell(q2ndNav, "bSibling", 1);
	querySetCell(q2ndNav, "bChild", 0);
	querySetCell(q2ndNav, "pos", menupos);
	menupos = menupos+1;
	
	// include children
	for (i=1; i lte qChildren.recordCount; i=i+1) {
	queryAddRow(q2ndNav, 1);
	querySetCell(q2ndNav, "objectid", qChildren.objectid[i]);
	querySetCell(q2ndNav, "label", qChildren.objectname[i]);
	querySetCell(q2ndNav, "bHeld", 0);
	querySetCell(q2ndNav, "bParent", 0);
	querySetCell(q2ndNav, "bSibling", 0);
	querySetCell(q2ndNav, "bChild", 1);
	querySetCell(q2ndNav, "pos", menupos);
	menupos = menupos+1;
	}
	
	// include siblings
	qSiblings = o.getSiblings(objectid=attributes.navid);

	for (i=1; i lte qSiblings.recordCount; i=i+1) {
	queryAddRow(q2ndNav, 1);
	querySetCell(q2ndNav, "objectid", qSiblings.objectid[i]);
	querySetCell(q2ndNav, "label", qSiblings.objectname[i]);
	querySetCell(q2ndNav, "bHeld", 0);
	querySetCell(q2ndNav, "bParent", 0);
	querySetCell(q2ndNav, "bSibling", 1);
	querySetCell(q2ndNav, "bChild", 0);
	querySetCell(q2ndNav, "pos", menupos);
	menupos = menupos+1;
	}

}
</cfscript>

<!--- check the status of all the nav nodes --->
<cfquery datasource="#application.dsn#" name="qStatus">
SELECT 
	objectid, status
FROM
	dmNavigation
WHERE
	objectID IN (#QuotedValueList(q2ndNav.objectid)#)
</cfquery>


<cfquery dbtype="query" name="q2ndNavStatus">
SELECT 
	q2ndNav.BCHILD, 
	q2ndNav.BHELD, 
	q2ndNav.BPARENT, 
	q2ndNav.BSIBLING, 
	q2ndNav.LABEL, 
	q2ndNav.OBJECTID, 
	q2ndNav.POS, 
	qStatus.STATUS
FROM
	qStatus, q2ndNav
WHERE
	qStatus.objectID = q2ndNav.objectID
ORDER BY q2ndNav.pos
</cfquery>

<!--- <cfdump var="#q2ndNav#" label="q2ndNav"> --->
<!--- <cfdump var="#qancestors#" label="ancestors"> --->
<!--- <cfdump var="#q2ndNavStatus#" label="q2ndNavStatus"> --->

<cfif attributes.bDisplay>
	<cfloop query="q2ndNavStatus">
		<cfscript>
			if (request.mode.lvalidstatus contains q2ndNavStatus.status) {
				class="";
				if (q2ndNavStatus.bParent)
					class="secNavParent";
				
				if (q2ndNavStatus.bSibling)
					class="secNavSibling";
				
				if (q2ndNavStatus.bChild)
					class="secNavChild";
				
				if (q2ndNavStatus.bheld)
					class=class & "Held";
				writeoutput('<div class="#class#"><a href="#application.url.conjurer#?objectid=#q2ndNavStatus.objectid#">#q2ndNavStatus.label#</a></div>');
			}
		</cfscript>
	</cfloop>
</cfif>
   
<!--- return query object to calling page --->
<cfif len(attributes.r_navquery)>
	<cfset setVariable("caller.#attributes.r_navquery#", q2ndNav)>
</cfif>

<cfsetting enablecfoutputonly="No">