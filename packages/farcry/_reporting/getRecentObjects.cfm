<cfif stArgs.objectType eq "dmHTML">
	<!--- Get recent objects and nav parent --->
	<cfquery name="qGetObjects" datasource="#application.dsn#" maxrows="#stArgs.numberOfObjects#">
	SELECT #stArgs.objectType#.objectID,
                #stArgs.objectType#.title,
                #stArgs.objectType#.createdby,
                #stArgs.objectType#.dateTimeCreated,
                dmNavigation_aObjectIDs.objectid as objectParent
	FROM #application.dbowner##stArgs.objectType#,
             #application.dbowner#dmNavigation_aObjectIDs 
	WHERE dmNavigation_aObjectIDs.data = #stArgs.objectType#.objectid
	ORDER BY #stArgs.objectType#.dateTimeCreated DESC
	</cfquery>
<cfelse>
	<!--- Get recent objects --->
	<cfquery name="qGetObjects" datasource="#application.dsn#" maxrows="#stArgs.numberOfObjects#">
	SELECT objectID, title, createdBy, dateTimeCreated
	FROM #application.dbowner##stArgs.objectType#
	ORDER BY dateTimeCreated DESC
	</cfquery>
</cfif>

<cfset stRecentObjects = structNew()>

<cfloop query="qGetObjects">
    <cfscript>
    stTemp = structNew();
    stTemp.objectID = qGetObjects.objectID;
    stTemp.title = qGetObjects.title;
    stTemp.createdBy = qGetObjects.createdBy;
    stTemp.dateTimeCreated = qGetObjects.dateTimeCreated;
    if (stArgs.objectType eq "dmHTML") stTemp.objectParent = qGetObjects.objectParent;

    o_profile = createObject("component", "#application.packagepath#.types.dmProfile");
    stProfile = o_profile.getProfile(userName=qGetObjects.createdBy);
    if (not structIsEmpty(stProfile)) stTemp.userEmail = stProfile.emailAddress; else stTemp.userEmail = "";

    stRecentObjects[qGetObjects.objectID] = stTemp;
    </cfscript>
</cfloop>