<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="session.writingDir" default="ltr" />
<cfparam name="session.userLanguage" default="en" />

<cfset request.fcwebtopbootstrap = true>

<!--- get sections --->
<cfset stWebtop = application.factory.oWebtop.getAllItems() />

<!--- init user profile info --->
<cfset webtopUsername = "FarCry User">
<cfif structKeyExists(session.dmProfile,"firstname") AND len(session.dmProfile.firstname)>
	<cfset webtopUsername = session.dmProfile.firstname>
</cfif>
<cfif structKeyExists(session.dmProfile,"lastname") AND len(session.dmProfile.lastname)>
	<cfset webtopUsername = webtopUsername & " " & session.dmProfile.lastname>
</cfif>


<cfoutput>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<title>[#application.applicationname#] #application.config.general.sitetitle# - FarCry Webtop</title>

<!--- TODO: register --->
	<link href="css/icons.css" rel="stylesheet" media="screen">
	<!--- <link href="css/webtop7.css" rel="stylesheet" media="screen"> --->
<!--- /TODO: register --->
	
	<skin:loadCSS id="fc-bootstrap" />
	<skin:loadCSS id="webtop" baseHREF="#application.url.webtop#/css" lFiles="webtop7.css,main7.css" />
	<skin:loadJS id="fc-jquery" />

</head>
<body id="sec-#url.sec#" class="webtop">

	<div class="navbar navbar-fixed-top farcry-header">
		<div class="container-fluid farcry-header-top">
			<div class="farcry-header-top-row">
				<div class="farcry-header-brand">
					<a target="_blank" href="/">
						<img src="images/brand.png" alt="#application.config.general.sitetitle#"><!-- fit inside 150x60 -->
					</a>
				</div>
				<div class="farcry-header-tabs">
					<ul class="nav nav-tabs">

						<admin:loopwebtop parent="#stWebtop#" item="section" class="class">
							<li id="nav-#section.id#" class="#class#<cfif url.sec eq section.id> active</cfif>"><a href="?id=#lcase(section.id)#">#trim(section.label)#</a></li>
						</admin:loopwebtop>

					</ul>
<!--- 
					<div class="farcry-header-environment">
						STAGING SERVER (stage.daemon.com.au)
					</div>
 --->
				</div>
				<div class="farcry-header-utility">
					<div class="farcry-header-logo">
						<img src="images/farcry.png">
					</div>
					<div class="farcry-header-user dropdown">
						<div class="farcry-header-profile dropdown-toggle" data-toggle="dropdown">
							<span class="avatar">
								<!--- cfif avtar in profile then... --->
									<!--- <img src="images/avatar.png"> --->
								<!--- cfelse --->
									<i class="icon-user"></i>
								<!--- /cfif --->
							</span>
							<i class="cog"><b class="icon-cog"></b></i>

							<span>#webtopUsername# &nbsp;<b class="icon-caret-down"></b></span>
						</div>
						<ul class="dropdown-menu pull-right">
							<li><a href="#application.url.webtop#?id=home.overview&typename=dmProfile&objectid=#session.dmProfile.objectid#&bodyView=editOwn"><admin:resource key="coapi.dmProfile.general.editprofile">Edit Profile</admin:resource></a></li>
							<skin:view typename="dmProfile" objectid="#session.dmProfile.objectid#" webskin="displaySummaryOptions#application.security.getCurrentUD()#" alternateHTML="" />
							<li><a href="#application.url.webtop#?logout=1"><admin:resource key="coapi.dmProfile.general.logout">Logout</admin:resource></a></li>
							<li class="divider"></li>
							<li class="nav-header">Developer Tools</li>
							<li><a href="##">Webskin Tracer</a></li>
							<li><a href="##">Profiler</a></li>
							<li class="divider"></li>
							<li><a href="##">Update Application</a></li>
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
								<li class="#class#<cfif url.sub eq subsection.id> active</cfif>"><a href="?id=#lcase(url.sec)#.#lcase(subsection.id)#">#trim(subsection.label)#</a></li>
							<cfelse>
								<li id="nav-#subsection.id#" class="dropdown #class#<cfif url.sub eq subsection.id> active</cfif>">
									<a href="?id=#lcase(url.sec)#.#lcase(subsection.id)#">#trim(subsection.label)#</a>

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
											<li class="nav-header">#trim(menu.label)#</li>
											<cfset menuitemCount = menuitemCount + 1>
											<admin:loopwebtop parent="#stWebtop.children[url.sec].children[subsection.id].children[menu.id]#" item="menuitem" class="menuitemclass">
												<li class="#menuitemclass#<cfif url.menuitem eq menuitem.id AND url.menu eq menu.id> active</cfif>"><a href="?id=#lcase(url.sec)#.#lcase(subsection.id)#.#lcase(menu.id)#.#lcase(menuitem.id)#">#trim(menuitem.label)#</a></li>
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
						<li><a href="##"><i class="icon-star"></i> Favourites</a></li>
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