<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display web feed --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.format" default="html" />

<cfset stObjParam = structnew() />

<!--- Get objects --->
<cfif len(stObj.catFilter)>
	<cfset stObjParam.qObjects = application.factory.oCategory.getObjectByCategory(lCategories=stObj.catFilter,typename=stObj.itemtype,bHasAny=true) />
	
	<cfquery dbtype="query" name="stObjParam.qObjects">
		select		objectid,datetimelastupdated
		from		stObjParam.qObjects
		<cfif url.format eq "podcast" and len(stObj.enclosurefileproperty)>
			where	#stObj.enclosurefileproperty# like '%.mp3' or #stObj.enclosurefileproperty# like '%.m4v'
		</cfif>
		order by	#stObj.dateproperty# desc
	</cfquery>
<cfelse>
	<cfquery datasource="#application.dsn#" name="stObjParam.qObjects">
		select		objectid,datetimelastupdated
		from		#application.dbowner##stObj.itemtype#
		<cfif url.format eq "podcast" and len(stObj.enclosurefileproperty)>
			where	#stObj.enclosurefileproperty# like '%.mp3' or #stObj.enclosurefileproperty# like '%.m4v'
		</cfif>
		order by	#stObj.dateproperty# desc
	</cfquery>
</cfif>

<!--- Get editor --->
<cfif len(stObj.editor)>
	<cfset stObj.editor = application.config.general.sitetitle />
</cfif>

<!--- Get last changed date --->
<cfquery dbtype="query" name="qLatest">
	select		max(datetimelastupdated) as latest
	from		stObjParam.qObjects
</cfquery>
<cfif qLatest.recordcount>
	<cfset stObjParam.builddate = qLatest.latest />
<cfelse>
	<cfset stObjParam.builddate = now() />
</cfif>
<cfset tz = getTimeZoneInfo() />
<cfset stObjParam.builddate = dateAdd('s',tz.utcTotalOffset,stObjParam.builddate) />

<!--- Get URL --->
<skin:buildLink objectid="#stObj.objectid#" r_url="stObjParam.feedurl" includeDomain="true" />
<cfif len(stObj.url)>
	<cfset stObjParam.url = stObj.url />
<cfelse>
	<cfset stObjParam.url = stObjParam.feedurl />
</cfif>

<!--- Get feed directory --->
<cfif not len(stObj.directory)>
	<cfset stObj.directory = "/feeds/#rereplace(stObj.title,'[^\w]+','-','ALL')#" />
</cfif>

<!--- Get feed paths --->
<cfif fileexists("#application.path.project#/www#stObj.directory#/rss.xml") or request.stObj.typename eq "dmCron">
	<cfset stObjParam.rsspath = "http://#cgi.http_host##stObj.directory#/rss.xml" />
	<cfset stObjParam.atompath = "http://#cgi.http_host##stObj.directory#/atom.xml" />
	<cfset stObjParam.itunespath = "itpc://#cgi.http_host##stObj.directory#/podcast.xml" />
<cfelse>
	<cfset stObjParam.rsspath = "#stObjParam.feedurl#&format=rss" />
	<cfset stObjParam.atompath = "#stObjParam.feedurl#&format=atom" />
	<cfset stObjParam.itunespath = replace("#stObjParam.feedurl#&format=podcast","http","itpc") />
</cfif>

<cfswitch expression="#url.format#">
	<cfcase value="atom">
		<skin:view stObject="#stObj#" webskin="feedAtom" stParam="#stObjParam#" />
	</cfcase>
	<cfcase value="podcast">
		<skin:view stObject="#stObj#" webskin="feedPodcast" stParam="#stObjParam#" />
	</cfcase>
	<cfcase value="rss">
		<skin:view stObject="#stObj#" webskin="feedRSS" stParam="#stObjParam#" />
	</cfcase>
	<cfcase value="html">
		<skin:view stObject="#stObj#" webskin="feedHTML" stParam="#stObjParam#" />
	</cfcase>
</cfswitch>

<cfsetting enablecfoutputonly="false" />