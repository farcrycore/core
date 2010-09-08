<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Webtop overview --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<admin:header title="" />

<cfoutput>
	<h1>Welcome to FarCry</h1>
	<ul class="inlinedocs">
			<li><a href="#application.url.webtop#/overview/home.cfm">
				<skin:icon icon="overview" class="overviewicon" style="border:none;float:left;" alt="" />
			</a>
			<a href="#application.url.webtop#/overview/home.cfm">Overview</a><br/>
			<p>Review content you have in draft or pending approval.</p>
		</li>
</cfoutput>

<admin:loopwebtop item="section">
	<!--- If a related type is specified, use that to fill description and icon attributes --->
	<cfif len(section.relatedType)>
		<cfif structkeyexists(application.stCOAPI,section.relatedtype)>
			<cfset o = createobject("component",application.stCOAPI[section.relatedType].packagepath) />
			<cfif structkeyexists(application.stCOAPI[section.relatedType],"description")>
				<cfset section.description = application.rb.getResource("coapi.#section.relatedtype#@description",application.stCOAPI[section.relatedType].description) />
			<cfelseif structkeyexists(application.stCOAPI[section.relatedType],"hint")>
				<cfset section.description = application.rb.getResource("coapi.#section.relatedtype#@description",application.stCOAPI[section.relatedType].hint) />
			</cfif>
			<cfset section.icon = section.relatedType />
		<cfelse>
			<cfthrow message="Related type attribute for '#section.id#' menu item does not specify a valid type" />
		</cfif>
	</cfif>

	<cfif len(section.description)>
		<cfoutput><li></cfoutput>
		
		<cfif len(section.icon)>
			<cfoutput>
				<a href="#application.url.webtop#/index.cfm?sec=#section.id#" target="_top">
					<skin:icon icon="#section.icon#" class="overviewicon" style="border:none;float:left;" alt="" />
				</a>
			</cfoutput>
		</cfif>
		
		<cfsavecontent variable="subsections">
			<admin:loopwebtop parent="#section#" item="subsection">
				<cfif len(subsection.description)>
					<cfoutput><li></cfoutput>
					
					<cfif len(subsection.icon)>
						<cfoutput>
							<a href="#application.url.webtop#/index.cfm?sec=#section.id#&subsection=#subsection.id#" target="_top">
								<img src="#subsection.icon#" class="overviewicon" border="0" style="float:left;" alt="" />
							</a>
						</cfoutput>
					</cfif>
					
					<cfoutput>
							<a href="#application.url.webtop#/index.cfm?sec=#section.id#&subsection=#subsection.id#" target="_top">#subsection.label#</a><br/>
							<p>#subsection.description#</p>
						</li>
					</cfoutput>
				</cfif>
			</admin:loopwebtop>
		</cfsavecontent>
		
		<cfoutput>
			<a href="#application.url.webtop#/index.cfm?sec=#section.id#" target="_top">#section.label#</a><br/>
			<p>#section.description#</p>
		</cfoutput>
		
		<cfif len(trim(subsections))>
			<cfoutput><ul class="inlinedocs">#subsections#</ul></cfoutput>
		</cfif>
				
		<cfoutput>
			</li>
		</cfoutput>
	</cfif>
</admin:loopwebtop>

<cfoutput>
	</ul>
</cfoutput>

<admin:footer />

<cfsetting enablecfoutputonly="false" />