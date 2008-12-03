<cfsetting enablecfoutputonly="true" /> 
<!--- @@Copyright: Copyright (c) 2008 Rob Rohan. All rights reserved. --->
<!--- @@License:
	
--->
<!--- @@displayname: --->
<!--- @@description: displayTeaserStandard --->
<!--- @@author: Rob Rohan on 2008-12-03 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<div class="feedRSSTeaser">
	<skin:buildlink objectid="#stObj.objectid#" view="feedRSS"  />
</div>

<div class="feedAtomTeaser">
	<skin:buildlink objectid="#stObj.objectid#" view="feedAtom"  />
</div>

<cfsetting enablecfoutputonly="false" />