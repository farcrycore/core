<cfparam name="url.type" default="" />
<cfparam name="url.icon" default="" />
<cfparam name="url.usecustom" default="false" />

<cfif not len(url.type) and not len(url.icon)>
	<cfthrow message="The icon facade requires either type or icon to be passed in">
</cfif>

<cfif not len(url.icon)>
	<cfset url.icon = url.type />
</cfif>

<cfif fileexists("#application.path.project#/www/wsimages/icons/#url.icon#.png")>
	<cfcontent file="#application.path.project#/www/wsimages/icons/#url.icon#.png" />
</cfif>

<cfloop list="#application.factory.oUtils.listReverse(application.plugins)#" index="plugin">
	<cfif fileexists("#application.path.plugins#/#plugin#/www/wsimages/icons/#url.icon#.png")>
		<cfcontent file="#application.path.plugins#/#plugin#/www/wsimages/icons/#url.icon#.png" />
	</cfif>
</cfloop>

<cfif fileexists("#application.path.core#/webtop/images/icons/#url.icon#.png")>
	<cfcontent file="#application.path.core#/webtop/images/icons/#url.icon#.png" />
</cfif>

<cfif url.usecustom and fileexists("#application.path.core#/webtop/images/icons/custom.png")>
	<cfcontent file="#application.path.core#/webtop/images/icons/custom.png" />
</cfif>