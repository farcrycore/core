<cfsetting enablecfoutputonly="true" /> 
<!--- @@Copyright: Copyright (c) 2008 Rob Rohan. All rights reserved. --->
<!--- @@License:
	
--->
<!--- @@displayname: --->
<!--- @@description: displayTeaserStandard --->
<!--- @@author: Rob Rohan on 2008-12-03 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:buildLink objectid="#stObj.objectid#" view="feedRSS" r_url="urlRSSFeed" includeDomain="true" />
<skin:buildLink objectid="#stObj.objectid#" view="feedAtom" r_url="urlAtomFeed" includeDomain="true" />


<cfsavecontent variable="linksText">
	<cfoutput>
	<link rel="alternate" type="application/rss+xml" title="RSS" href="#urlRSSFeed#" />
	<link rel="alternate" type="application/atom+xml" title="Atom" href="#urlAtomFeed#" />
	</cfoutput>
</cfsavecontent>

<skin:htmlhead text="#linksText#" />

<div class="feedRSSTeaser">
	<skin:buildLink objectid="#stObj.objectid#" view="feedRSS"  />
</div>

<div class="feedAtomTeaser">
	<skin:buildLink objectid="#stObj.objectid#" view="feedAtom"  />
</div>

<cfsetting enablecfoutputonly="false" />