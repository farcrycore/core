<cfsetting enablecfoutputonly="true" /> 
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
	
--->
<!--- @@displayname: Utility: Show Defined Webfeed --->
<!--- @@author: Rob Rohan on 2008-12-03 --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- <cfdump var="#stObj#" /> --->

<cfloop from="1" to="#arrayLen(stObj.awebdisplayfeeds)#" index="q">
	<skin:view objectid="#stObj.awebdisplayfeeds[q]#" typename="farWebfeed"
		webskin="displayTeaserStandard" />
</cfloop>

<cfsetting enablecfoutputonly="false" />