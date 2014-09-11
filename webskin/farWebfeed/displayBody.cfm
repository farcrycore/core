<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: HTML body --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Get objects --->
<cfset qObjects = getFeedObjects(stObj=stObj) />

<!--- Get editor --->
<cfif len(stObj.editor)>
	<cfset stObj.editor = application.fapi.getConfig("general","sitetitle") />
</cfif>

<!--- Get last changed date --->
<cfquery dbtype="query" name="qLatest">
	select		max(datetimelastupdated) as latest
	from		qObjects
</cfquery>
<cfif qLatest.recordcount>
	<cfset builddate = qLatest.latest />
<cfelse>
	<cfset builddate = now() />
</cfif>
<cfset tz = getTimeZoneInfo() />
<cfset builddate = dateAdd('s',tz.utcTotalOffset,builddate) />

<!--- Get URL --->
<skin:buildLink objectid="#stObj.objectid#" r_url="feedurl" includeDomain="true" />
<cfif len(stObj.url)>
	<cfset linkbackurl = stObj.url />
<cfelse>
	<cfset linkbackurl = feedurl />
</cfif>

<!--- Get feed directory --->
<cfif not len(stObj.directory)>
	<cfset stObj.directory = "/feeds/#rereplace(stObj.title,'[^\w]+','-','ALL')#" />
</cfif>

<!--- Get feed paths --->
<cfif fileexists("#application.path.project#/www#stObj.directory#/rss.xml") or request.stObj.typename eq "dmCron">
	<cfset rsspath = "http://#cgi.http_host##stObj.directory#/rss.xml" />
	<cfset atompath = "http://#cgi.http_host##stObj.directory#/atom.xml" />
	<cfset itunespath = "itpc://#cgi.http_host##stObj.directory#/podcast.xml" />
<cfelse>
	<cfset rsspath = "#feedurl#&amp;view=feedRSS" />
	<cfset atompath = "#feedurl#&amp;view=feedAtom" />
	<cfset itunespath = replace("#feedurl#&amp;view=feedPodcast","http","itpc") />
</cfif>

<skin:view stObject="#stObj#" webskin="displayMetatags" />

<cfoutput>
	<h1>#stObj.title#</h1>
</cfoutput>

<cfif len(stObj.subtitle)>
	<cfoutput><h2>#stObj.subtitle#</h2></cfoutput>
</cfif>

<cfoutput>
		<p class="keywords">#stObj.keywords#</p>
		<ul class="feedlist">
			<li>
				<a href="#rsspath#">
					RSS Feed
				</a>
			</li>
			<li>
				<a href="#atompath#">
					Atom Feed
				</a>
			</li>
</cfoutput>

<cfif len(stObj.enclosurefileproperty)>
	<cfoutput>
		<li>
			<a href="#itunespath#">
				Subscribe in iTunes
			</a>
		</li>
	</cfoutput>
</cfif>

<cfoutput>
	</ul>
</cfoutput>

<cfif len(stObj.feedimage)>
	<cfoutput><img class="feedimage" src="#application.fapi.getImageWebRoot()##stobj.feedimage#" alt="#stObj.title#" /></cfoutput>
</cfif>
<cfif len(stObj.url)>
	<cfoutput><p>URL: <a href="#stObj.url#">#stObj.url#</a></p></cfoutput>
</cfif>
<cfif len(stObj.editor)>
	<cfoutput>
		<p>
			Editor: #stObj.editor#
			<cfif len(stObj.editoremail)>
				(<a href="mailto:#stObj.editoremail#">#stObj.editoremail#</a>)
			</cfif>
		</p>
	</cfoutput>
</cfif>

<cfoutput>
	<p>#stObj.description#</p>
</cfoutput>

<cfset stObjParam = structnew() />
<cfset stObjParam.directory = stObj.directory />
<cfset stObjParam.title = stObj.titleproperty />
<cfset stObjParam.content = stObj.contentproperty />
<cfset stObjParam.media = stObj.enclosurefileproperty />
<cfset stObjParam.date = stObj.dateproperty />
<cfset stObjParam.bAuthor = stObj.bAuthor />
<cfset stObjParam.keywords = stObj.keywordsproperty />
<cfset stObjParam.itunessubtitle = stObj.itunessubtitleproperty />
<cfset stObjParam.itunesduration = stObj.itunesdurationproperty />
<cfloop query="qObjects">
	<skin:view objectid="#qObjects.objectid#" webskin="feedHTML" stParam="#stObjParam#" />
</cfloop>

<cfsetting enablecfoutputonly="false" />