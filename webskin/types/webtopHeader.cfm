<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="session.writingDir" default="ltr" />
<cfparam name="session.userLanguage" default="en" />

<cfset request.fc.inWebtop = 1>

<!--- get sections --->
<cfset stWebtop = application.factory.oWebtop.getAllItems() />

<!--- init user profile info --->
<cfset webtopUsername = "FarCry User">
<cfset webtopGravatarHash = "">
<cfset webtopAvatar = "">
<cfif structKeyExists(session.dmProfile,"firstname") AND len(session.dmProfile.firstname)>
	<cfset webtopUsername = session.dmProfile.firstname>
</cfif>
<cfif structKeyExists(session.dmProfile,"lastname") AND len(session.dmProfile.lastname)>
	<cfset webtopUsername = webtopUsername & " " & session.dmProfile.lastname>
</cfif>
<cfif structKeyExists(session.dmProfile, "emailAddress") AND len(session.dmProfile.emailAddress)>
	<cfset webtopGravatarHash = lcase(hash(lcase(trim(session.dmProfile.emailAddress))))>
</cfif>
<cfif structKeyExists(session.dmProfile, "avatar") AND len(session.dmProfile.avatar)>
	<cfset webtopAvatar = session.dmProfile.avatar>
</cfif>


<!--- temporary --->
<skin:loadCSS id="webtop" baseHREF="#application.url.webtop#/css" lFiles="webtop7.css,main7.css" />


<cfoutput><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>[#application.applicationname#] #application.config.general.sitetitle# - FarCry Webtop</title>

<skin:loadCSS id="fc-bootstrap" />
<skin:loadCSS id="fc-fontawesome" />
<skin:loadCSS id="webtop7" />

<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadJS id="fc-bootstrap" />
<skin:loadJS id="jquery-tooltip" />
<skin:loadJS id="jquery-tooltip-auto" />
<skin:loadJS id="webtop7" />

</head>
<body id="sec-#url.sec#" class="webtop">

	<div class="navbar navbar-fixed-top farcry-header">
		<div class="container-fluid farcry-header-top">
			<div class="farcry-header-top-row">
				<div class="farcry-header-brand">
					<a target="_blank" href="/">
						<cfif len(application.fapi.getConfig("general", "webtoplogopath"))>
							<img src="#application.fapi.getConfig("general", "webtoplogopath")#" alt="#application.config.general.sitetitle#"><!--- fit inside 180x60 --->
						<cfelse>
							#application.fapi.getConfig("general", "sitetitle")#
						</cfif>
					</a>
				</div>
				<div class="farcry-header-tabs">
					<ul class="nav nav-tabs">

						<admin:loopwebtop parent="#stWebtop#" item="section" class="class">
							<li id="nav-#section.id#" class="#class#<cfif url.sec eq section.id> active</cfif>"><a href="?id=#lcase(section.id)#"><cfif isdefined("section.icon")><i class="#section.icon#"></i> </cfif>#trim(section.label)#</a></li>
						</admin:loopwebtop>

					</ul>

					<skin:view typename="configEnvironment" webskin="displayLabel" />

				</div>
				<div class="farcry-header-utility">
					<div class="farcry-header-logo">
						<img src="images/farcry.png">
					</div>
					<div class="farcry-header-user dropdown">
						<div class="farcry-header-profile dropdown-toggle" data-toggle="dropdown">
							<span class="avatar">
								<cfif len(webtopAvatar)>
									<img src="#webtopAvatar#" width="24" height="25" onerror="this.style.visibility='hidden';">
								<cfelseif webtopGravatarHash neq "">
									<img src="//www.gravatar.com/avatar/#webtopGravatarHash#?d=404" width="24" height="25" onerror="this.style.visibility='hidden';">
								</cfif>
								<i class="icon-user"></i>
							</span>
							<span class="cog"><i class="icon-cog"></i></span>

							<span>#webtopUsername# &nbsp;<b class="icon-caret-down"></b></span>
						</div>
						<ul class="dropdown-menu pull-right">
							<li><a href="#application.url.webtop#?id=home.overview&typename=dmProfile&objectid=#session.dmProfile.objectid#&bodyView=editOwn"><admin:resource key="coapi.dmProfile.general.editprofile">Edit Profile</admin:resource></a></li>
							<skin:view typename="dmProfile" objectid="#session.dmProfile.objectid#" webskin="displaySummaryOptions#application.security.getCurrentUD()#" alternateHTML="" />
							<!--- <li class="divider"></li>
							<li class="nav-header">Developer Tools</li>
							<li><a href="#application.fapi.fixURL(addvalues='tracewebskins=1')#">Webskin Tracer</a></li>
							<li><a href="#application.fapi.fixURL(addvalues='profile=1')#">Profiler</a></li> --->
							<cfif application.security.checkPermission(permission="developer")>
								<li class="divider"></li>
								<li><a href="#application.fapi.fixURL(addvalues='updateapp=1')#">Update Application</a></li>
							</cfif>
							<li class="divider"></li>
							<li><a href="#application.url.webtop#?logout=1"><admin:resource key="coapi.dmProfile.general.logout">Logout</admin:resource></a></li>
						</ul>
					</div>
				</div>
			</div>
		</div>

		<div class="farcry-secondary-nav">
			<div class="navbar-inner">
				<div class="container-fluid">
					<ul class="nav">

						<admin:loopwebtop parent="#stWebtop.children[url.sec]#" item="subsection" class="class">
							<cfif structIsEmpty(subsection.children)>
								<li class="#class#<cfif url.sub eq subsection.id> active</cfif>"><a href="?id=#lcase(url.sec)#.#lcase(subsection.id)#"><cfif isdefined("subsection.icon")><i class="#subsection.icon#"></i> </cfif>#trim(subsection.label)#</a></li>
							<cfelse>
								<li id="nav-#subsection.id#" class="dropdown #class#<cfif url.sub eq subsection.id> active</cfif>">
									<a href="?id=#lcase(url.sec)#.#lcase(subsection.id)#"><cfif isdefined("subsection.icon")><i class="#subsection.icon#"></i> </cfif>#trim(subsection.label)# <i class="icon-caret-down" style="opacity:0.5"></i></a>

									<cfset menuitemCount = 0>
									<cfset columnCount = 1>
									<cfsavecontent variable="megamenu">
										<admin:loopwebtop parent="#stWebtop.children[url.sec].children[subsection.id]#" item="menu" class="menuclass">
											<cfif menuitemCount gte 10>
												</ul>
												<ul>
												<cfset menuitemCount = 0>
												<cfset columnCount = columnCount + 1>
											</cfif>
											<li class="nav-header"><cfif isdefined("menu.icon")><i class="#menu.icon#"></i> </cfif>#trim(menu.label)#</li>
											<cfset menuitemCount = menuitemCount + 1>
											<admin:loopwebtop parent="#stWebtop.children[url.sec].children[subsection.id].children[menu.id]#" item="menuitem" class="menuitemclass">
												<li class="#menuitemclass#<cfif url.menuitem eq menuitem.id AND url.menu eq menu.id> active</cfif>"><a href="?id=#lcase(url.sec)#.#lcase(subsection.id)#.#lcase(menu.id)#.#lcase(menuitem.id)#<cfif isdefined("menuitem.urlparameters")>&#menuitem.urlparameters#</cfif>"><cfif isdefined("menuitem.icon")><i class="#menuitem.id#"></i> </cfif>#trim(menuitem.label)#</a></li>
												<cfset menuitemCount = menuitemCount + 1>
											</admin:loopwebtop>
										</admin:loopwebtop>											
									</cfsavecontent>

									<div class="dropdown-menu dropdown-mega-menu mega-#columnCount#">
										<ul>
											#megamenu#
										</ul>
									</div>
									</li>
						
							</cfif>
						</admin:loopwebtop>

					</ul>
					<ul class="nav pull-right">
						<li id="favourites" class="dropdown">
							<cfset active = false />
							<cfset aFavourites = application.fapi.getPersonalConfig("favourites",arraynew(1)) />
							<cfloop array="#aFavourites#" index="thisfavourite">
								<cfif application.fapi.fixURL() eq thisfavourite.url>
									<cfset active = true />
								</cfif>
							</cfloop>
							<a href="##" class="favourited <cfif active>active</cfif>" 
								title="#application.fapi.getResource('webtop.utilities.favourites.favourite@text','Add or remove this page from your favourites')#" 
								data-this="#application.fapi.fixURL()#" 
								data-add="#application.fapi.getLink(type='dmProfile',view='ajaxAddFavourite')#" 
								data-remove="#application.fapi.getLink(type='dmProfile',view='ajaxRemoveFavourite')#"><i class="<cfif active>icon-star<cfelse>icon-star-empty</cfif>"></i></a><a href="##" class="dropdown favourites-toggle" data-toggle="dropdown"><admin:resource key="webtop.utilties.favourites.favouritesmenu@text">Favourites</admin:resource> <i class="icon-caret-down" style="opacity:0.5"></i></a>
							<ul class="favourites-menu dropdown-menu">
								<cfloop array="#aFavourites#" index="thisfavourite">
									<li><a href="#thisfavourite.url#">#thisfavourite.label#</a></li>
								</cfloop>
								<li class="none" <cfif arraylen(aFavourites)>style="display:none;"</cfif>><admin:resource key="webtop.utilities.favourites.none@text">No favourites</admin:resource></li>
							</ul>
						</li>
						<li><a href="##"><i class="icon-question-sign"></i> Help</a></li>
					</ul>
				</div>
			</div>
		</div>
	</div>


	<div class="farcry-main container-fluid">
		<div class="row-fluid">
			<div class="span12">
				<div id="bubbles"></div>
</cfoutput>

<cfsetting enablecfoutputonly="false">