<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/webskin/secondaryNav.cfm,v 1.11 2003/12/09 03:14:18 brendan Exp $
$Author: brendan $
$Date: 2003/12/09 03:14:18 $
$Name: milestone_3-0-1 $
$Revision: 1.11 $

|| DESCRIPTION || 
Builds a query with secondary navigation info

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
	navid (uuid of current object)
	bInclueParent (do you want to show the parent?)
	r_navQuery (name of variable to return to)
	bDisplay (display basic navigation or have you got custom code?)
out:

|| END DAEMONDOC||
--->

<cfparam name="attributes.navid" default="#request.navid#">
<cfparam name="attributes.bIncludeParent" default="true">
<cfparam name="attributes.r_navQuery" default="">
<cfparam name="attributes.bDisplay" default="false">

<cfscript>
	qSecondaryNav = application.factory.oTree.getSecondaryNav(objectid=attributes.navid);
</cfscript>

<!--- Get status of Nav Items --->
<cfquery datasource="#application.dsn#" name="qStatus">
SELECT objectid, status FROM #application.dbowner#dmNavigation
WHERE objectID IN (#QuotedValueList(qSecondaryNav.objectid)#)
</cfquery>

<!--- Add status of Nav Items to Secondary Nav query--->
<cfquery dbtype="query" name="q2ndNavStatus">
SELECT qSecondaryNav.NLEFT, 
	qSecondaryNav.NLEVEL, 
	qSecondaryNav.OBJECTNAME, 
	qSecondaryNav.OBJECTID, 
	qStatus.STATUS
FROM qStatus, qSecondaryNav
WHERE qStatus.objectID = qSecondaryNav.objectID
ORDER BY qSecondaryNav.nLeft
</cfquery>



<!--- Get Level of Current Object --->
<cfquery dbtype="query" name="qCurrentLevel">
SELECT qSecondaryNav.NLEVEL
FROM qSecondaryNav
WHERE qSecondaryNav.ObjectID = '#attributes.navID#'
</cfquery>

<!--- Find out if Leaf Node or not --->
<cfquery dbtype="query" name="qLeaf">
SELECT qSecondaryNav.NLEVEL
FROM qSecondaryNav
WHERE qSecondaryNav.NLEVEL > #qCurrentLevel.NLEVEL#
</cfquery>

<!--- show basic secondary nav --->
<cfif attributes.bDisplay>
	<!--- loop over each nav item and display appropriately --->
	<cfloop query="q2ndNavStatus">
		<cfscript>
			class="";
			bShow="yes";
			if (request.mode.lvalidstatus contains q2ndNavStatus.status AND q2ndNavStatus.NLEVEL NEQ 0) {
				// Not Leaf
				if (qLeaf.recordcount GT 0) {	
					// parent
					if (q2ndNavStatus.NLEVEL EQ (qCurrentLevel.nlevel - 1) AND (attributes.bIncludeParent)) {
						class="secNavParent";
					// siblings
					} else if (q2ndNavStatus.NLEVEL EQ qCurrentLevel.nlevel) {
						class="secNavSibling";
					// Children
					} else if (q2ndNavStatus.NLEVEL EQ qCurrentLevel.nlevel + 1) {
						class="secNavChild";
					}
					// self
					if (q2ndNavStatus.ObjectID EQ attributes.navID) {
						class=class & "Held";
					}
				// Leaf
				} else {
					if (qCurrentLevel.NLEVEL GT 2) {
						// self as child
						if (q2ndNavStatus.ObjectID EQ attributes.navID) {
							class="secNavChildHeld";
						// grandparent
						} else if (q2ndNavStatus.NLEVEL EQ (qCurrentLevel.nlevel - 2) AND (attributes.bIncludeParent)) {
							class="secNavParent";
						// parent as intermediary node
						} else if (q2ndNavStatus.NLEVEL EQ (qCurrentLevel.nlevel - 1)) {
							class="secNavSibling";
						// siblings as children
						} else if (q2ndNavStatus.NLEVEL EQ qCurrentLevel.nlevel) {
							class="secNavChild";
						}
					} else {
						// Top Level Navigation (Under Home level)
						// If same level as home and not home, don't show
						if (q2ndNavStatus.NLEVEL EQ (qCurrentLevel.nlevel - 1) AND (q2ndNavStatus.ObjectID NEQ application.navID.home)) {
							bShow = "no";
						// show home as parent
						} else if (q2ndNavStatus.ObjectID EQ application.navID.home) {
							class="secNavParent";
						} else {
							class="secNavSibling";
						}
						if (q2ndNavStatus.ObjectID EQ attributes.navID) {
							class=class & "Held";
						}
					}
				}
				if (bShow EQ "yes") {
					writeoutput('<div class="#class#"><a href="#application.url.conjurer#?objectid=#q2ndNavStatus.objectid#">#q2ndNavStatus.objectName#</a></div>');	
				}
			}
		</cfscript>
	</cfloop>
</cfif>

<!--- return query object to calling page --->
<cfif len(attributes.r_navquery)>
	<cfset "caller.#attributes.r_navquery#" = q2ndNavStatus>
    <cfset caller.r_CurrentLevel = qCurrentLevel>
	<cfset caller.r_Leaf = qLeaf>
</cfif>

<cfsetting enablecfoutputonly="No">
