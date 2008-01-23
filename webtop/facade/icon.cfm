<cfparam name="url.type" default="" />
<cfparam name="url.icon" default="" />
<cfparam name="url.usecustom" default="false" />

<cfif not len(url.type) and not len(url.icon)>
	<cfthrow message="The icon facade requires either type or icon to be passed in">
</cfif>

<cfif not len(url.icon)>
	<cfset url.icon = LCase(Right(url.type,len(url.type)-2)) />
</cfif>

<cfif fileexists("#application.path.project#/www/images/icons/#url.icon#.png")>
	<cfcontent file="#application.path.project#/www/images/icons/#url.icon#.png" />
</cfif>

<cfloop list="#application.factory.oUtils.listReverse(application.plugins)#" index="plugin">
	<cfif fileexists("#application.path.plugins#/#plugin#/www/images/icon/#url.type#.png")>
		<cfcontent file="#application.path.plugins#/#plugin#/www/images/icon/#url.type#.png" />
	</cfif>
</cfloop>

<cfif fileexists("#application.path.core#/admin/images/icons/#url.icon#.png")>
	<cfcontent file="#application.path.core#/admin/images/icons/#url.icon#.png" />
</cfif>

<cfif url.usecustom and fileexists("#application.path.core#/admin/images/icons/custom.png")>
	<cfcontent file="#application.path.core#/admin/images/icons/custom.png" />
</cfif>