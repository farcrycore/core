<cfsetting enablecfoutputonly="true" /> 
<!--- @@Copyright: Copyright (c) 2008 Rob Rohan. All rights reserved. --->
<!--- @@License:
	
--->
<!--- @@displayname: Utility: Show Defined Webfeed --->
<!--- @@description: Utility: Show Defined Webfeed --->
<!--- @@author: Rob Rohan on 2008-12-03 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- <cfdump var="#stObj#" /> --->

<cfloop from="1" to="#arrayLen(stObj.awebdisplayfeeds)#" index="q">
	<skin:view objectid="#stObj.awebdisplayfeeds[q]#" 
		webskin="displayTeaserStandard" />
</cfloop>

<cfsetting enablecfoutputonly="false" />