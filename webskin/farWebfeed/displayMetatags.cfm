<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Adds metatags to HTML head --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Get feed paths --->
<skin:buildLink objectid="#stObj.objectid#" r_url="feedurl" includeDomain="true" />
<cfif fileexists("#application.path.project#/www#stObj.directory#/rss.xml") or request.stObj.typename eq "dmCron">
	<cfset rsspath = "http://#cgi.http_host##stObj.directory#/rss.xml" />
	<cfset atompath = "http://#cgi.http_host##stObj.directory#/atom.xml" />
	<cfset itunespath = "itpc://#cgi.http_host##stObj.directory#/podcast.xml" />
<cfelse>
	<cfset rsspath = "#feedurl#&amp;view=feedRSS" />
	<cfset atompath = "#feedurl#&amp;view=feedAtom" />
	<cfset itunespath = replace("#feedurl#&amp;view=feedPodcast","http","itpc") />
</cfif>

<skin:htmlHead><cfoutput>
	<link rel="alternate" type="application/rss+xml" title="RSS" href="#rsspath#" />
	<link rel="alternate" type="application/atom+xml" title="Atom" href="#atompath#" />
</cfoutput></skin:htmlHead>

<cfsetting enablecfoutputonly="false" />