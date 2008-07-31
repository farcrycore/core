<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display HTML version of feed --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif fileexists("#application.path.project#/webskin/includes/dmHeader.cfm")>
	<cfmodule template="/farcry/projects/#application.applicationname#/webskin/includes/dmHeader.cfm" layoutClass="type-a" pageTitle="#stObj.title#" >
<cfelse>
	<skin:view stObject="#stObj#" webskin="displayHeader" alternateHTML="<html><body>" />
</cfif>

<skin:htmlHead><cfoutput>
	<link rel="alternate" type="application/rss+xml" title="RSS" href="#arguments.stParam.rsspath#" />
	<link rel="alternate" type="application/atom+xml" title="Atom" href="#arguments.stParam.atompath#" />
</cfoutput></skin:htmlHead>

<cfoutput>
	<div id="content">
		<h1>#stObj.title#</h1>
</cfoutput>

<cfif len(stObj.subtitle)>
	<cfoutput><h2>#stObj.subtitle#</h2></cfoutput>
</cfif>

<cfoutput>
		<p class="keywords">#stObj.keywords#</p>
		<ul class="feedlist">
			<li>
				<a href="#arguments.stParam.rsspath#">
					<img src="#application.url.farcry#/images/icons/rss.gif" /> RSS Feed
				</a>
			</li>
			<li>
				<a href="#arguments.stParam.atompath#">
					<img src="#application.url.farcry#/images/icons/atom.gif" /> Atom Feed
				</a>
			</li>
</cfoutput>

<cfif len(stObj.enclosurefileproperty)>
	<cfoutput>
		<li>
			<a href="#arguments.stParam.itunespath#">
				<img src="#application.url.farcry#/images/icons/podcast.gif" /> Subscribe in iTunes
			</a>
		</li>
	</cfoutput>
</cfif>

<cfoutput>
	</ul>
</cfoutput>

<cfif len(stObj.feedimage)>
	<cfoutput><img class="feedimage" src="#application.url.imageRoot##stobj.feedimage#" alt="#stObj.title#" /></cfoutput>
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
<cfloop query="arguments.stParam.qObjects">
	<skin:view objectid="#arguments.stParam.qObjects.objectid#" webskin="feedHTML" stParam="#stObjParam#" />
</cfloop>

<cfoutput>
	</div>
</cfoutput>

<cfif fileexists("#application.path.project#/webskin/includes/dmFooter.cfm")>
	<cfmodule template="/farcry/projects/#application.applicationname#/webskin/includes/dmFooter.cfm" >
<cfelse>
	<skin:view stObject="#stObj#" webskin="displayHeader" alternateHTML="<html><body>" />
</cfif>

<cfsetting enablecfoutputonly="false" />