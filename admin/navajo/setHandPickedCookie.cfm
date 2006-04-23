

<cfparam name="URL.objectID" default="">
<cfparam name="URL.cookiename" default="">
<cfparam name="cookie.hp_#URL.cookiename#" default="">
<cfparam name="URL.action" default="append">

<cfset lObjectIDs = evaluate("cookie.hp_"&URL.cookiename)>

<cfswitch expression="#URL.action#">
<cfcase value="append">
	<cfscript>
		if (listLen(lObjectIDs) is 0)
			lObjectIds = URL.objectID;
		else
			lObjectIDs = lObjectIDs & "," & URL.objectID;
	</cfscript>
</cfcase>
<cfcase value="remove">
	
	<cfscript>
		writeoutput('gape - ' & listFind(lObjectIDs,URL.objectID) & '<br>' );
		lObjectIDs = listDeleteAt(lObjectIDs,listFind(lObjectIDs,URL.objectID));
	</cfscript>
</cfcase>
</cfswitch>
<!--- <cfdump var="#lObjectIds#">
<cfdump var="#URL#"> --->
<cfset "cookie.hp_#URL.cookiename#" = lobjectIDs>

