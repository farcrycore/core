<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Webtop overview --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header title="" />

<cfoutput>
	<h1>Welcome to FarCry</h1>
	<ul class="inlinedocs">
		<li>
			<a href="#application.url.webtop#/overview/home.cfm" target="content">Overview</a><br/>
			<p>Review content you have in draft or pending approval.</p>
		</li>
</cfoutput>

<admin:loopwebtop item="section">
	<!--- If an icon was specified, convert it to the icon facade --->
	<cfif len(section.icon)>
		<cfset section.icon="#application.url.webtop#/facade/icon.cfm?icon=#section.icon#" />
	</cfif>

	<!--- If a related type is specified, use that to fill description and icon attributes --->
	<cfif len(section.relatedType)>
		<cfif structkeyexists(application.stCOAPI,section.relatedtype)>
			<cfset o = createobject("component",application.stCOAPI[section.relatedType].packagepath) />
			<cfif structkeyexists(application.stCOAPI[section.relatedType],"description")>
				<cfset section.description = application.rb.getResource("coapi.#section.relatedtype#@description",application.stCOAPI[section.relatedType].description) />
			<cfelseif structkeyexists(application.stCOAPI[section.relatedType],"hint")>
				<cfset section.description = application.rb.getResource("coapi.#section.relatedtype#@description",application.stCOAPI[section.relatedType].hint) />
			</cfif>
			<cfset section.icon="#application.url.webtop#/facade/icon.cfm?type=#section.relatedType#" />
		<cfelse>
			<cfthrow message="Related type attribute for '#section.id#' menu item does not specify a valid type" />
		</cfif>
	</cfif>

	<cfif len(section.description)>
		<cfoutput><li></cfoutput>
		
		<cfif len(section.icon)>
			<cfoutput>
				<a href="#application.url.webtop#/index.cfm?sec=#section.id#" target="content">
					<img src="#section.icon#" class="overviewicon" border="0" style="float:left;" />
				</a>
			</cfoutput>
		</cfif>
		
		<cfoutput>
			<a href="#application.url.webtop#/index.cfm?sec=#section.id#" target="content">#section.label#</a><br/>
			<p>#section.description#</p>
			<ul class="inlinedocs">
		</cfoutput>
		
		<admin:loopwebtop parent="#section#" item="subsection">
			<cfif len(subsection.description)>
				<cfoutput><li></cfoutput>
				
				<cfif len(subsection.icon)>
					<cfoutput>
						<a href="#application.url.webtop#/index.cfm?sec=#section.id#&subsection=#subsection.id#" target="content">
							<img src="#subsection.icon#" class="overviewicon" border="0" style="float:left;" />
						</a>
					</cfoutput>
				</cfif>
				
				<cfoutput>
						<a href="#application.url.webtop#/index.cfm?sec=#section.id#&subsection=#subsection.id#" target="content">#subsection.label#</a><br/>
						<p>#subsection.description#</p>
					</li>
				</cfoutput>
			</cfif>
		</admin:loopwebtop>
				
		<cfoutput>
				</ul>
			</li>
		</cfoutput>
	</cfif>
</admin:loopwebtop>

<cfoutput>
	</ul>
</cfoutput>

<admin:footer />

<cfsetting enablecfoutputonly="false" />