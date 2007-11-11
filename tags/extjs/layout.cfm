<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname:  --->
<!--- @@description:  This is the primary tag to generate extjs layouts. By nesting item tags <extjs:item> within a layout tag, allows the developer to build a rich application layout. --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">

<cfif thistag.executionMode eq "Start">

	<skin:htmlhead library="extJS" />
	
	<cfparam name="attributes.id" default="layout#randrange(1,9999999)#" /><!--- Generate unique javascript id if required --->
	<cfparam name="attributes.container" default="" />
	<cfparam name="attributes.layout" default="" />
	

	<cfparam name="request.extJS" default="#structNew()#" />
	
	<!--- Generic config properties --->
	<cfset stConfig = structNew() />
	<cfset stConfig.var = "var">
	
	
	<!--- tabPannel and inherited config properties --->
	<cfset stConfig.activeItem = "activeItem">
	<cfset stConfig.activeTab = "activeTab" />
	<cfset stConfig.allowDomMove = "allowDomMove" />
	<cfset stConfig.animCollapse = "animCollapse" />
	<cfset stConfig.animScroll = "animScroll" />
	<cfset stConfig.applyTo = "applyTo" />
	<cfset stConfig.autoDestroy = "autoDestroy" />
	<cfset stConfig.autoHeight = "autoHeight" />
	<cfset stConfig.autoLoad = "autoLoad" />
	<cfset stConfig.autoScroll = "autoScroll" />
	<cfset stConfig.autoShow = "autoShow" />
	<cfset stConfig.autoTabSelector = "autoTabSelector" />
	<cfset stConfig.autoTabs = "autoTabs" />
	<cfset stConfig.autoWidth = "autoWidth" />
	<cfset stConfig.baseCls = "baseCls" />
	<cfset stConfig.bbar = "bbar" />
	<cfset stConfig.bodyBorder = "bodyBorder" />
	<cfset stConfig.bodyStyle = "bodyStyle" />
	<cfset stConfig.border = "border" />
	<cfset stConfig.bufferResize = "bufferResize" />
	<cfset stConfig.buttonAlign = "buttonAlign" />
	<cfset stConfig.buttons = "buttons" />
	<cfset stConfig.cls = "cls" />
	<cfset stConfig.collapseFirst = "collapseFirst" />
	<cfset stConfig.collapsed = "collapsed" />
	<cfset stConfig.collapsedCls = "collapsedCls" />
	<cfset stConfig.collapsible = "collapsible" />
	<cfset stConfig.contentEl = "contentEl" />
	<cfset stConfig.ctCls = "ctCls" />
	<cfset stConfig.defaultType = "defaultType" />
	<cfset stConfig.defaults = "defaults" />
	<cfset stConfig.deferredRender = "deferredRender" />
	<cfset stConfig.disabledClass = "disabledClass" />
	<cfset stConfig.elements = "elements" />
	<cfset stConfig.enableTabScroll = "enableTabScroll" />
	<cfset stConfig.floating = "floating" />
	<cfset stConfig.footer = "footer" />
	<cfset stConfig.frame = "frame" />
	<cfset stConfig.header = "header" />
	<cfset stConfig.headerAsText = "headerAsText" />
	<cfset stConfig.height = "height" />
	<cfset stConfig.hideBorders = "hideBorders" />
	<cfset stConfig.hideCollapseTool = "hideCollapseTool" />
	<cfset stConfig.hideMode = "hideMode" />
	<cfset stConfig.hideParent = "hideParent" />
	<cfset stConfig.html = "html" />
	<cfset stConfig.iconCls = "iconCls" />
	<cfset stConfig.id = "id" />
	<cfset stConfig.items = "items" />
	<cfset stConfig.keys = "keys" />
	<cfset stConfig.layout = "layout" />
	<cfset stConfig.layoutConfig = "layoutConfig" />
	<cfset stConfig.listeners = "listeners">
	<cfset stConfig.maskDisabled = "maskDisabled" />
	<cfset stConfig.minButtonWidth = "minButtonWidth" />
	<cfset stConfig.minTabWidth = "minTabWidth" />
	<cfset stConfig.monitorResize = "monitorResize" />
	<cfset stConfig.plain = "plain" />
	<cfset stConfig.plugins = "plugins" />
	<cfset stConfig.renderTo = "renderTo" />
	<cfset stConfig.resizeTabs = "resizeTabs" />
	<cfset stConfig.scrollDuration = "scrollDuration" />
	<cfset stConfig.scrollIncrement = "scrollIncrement" />
	<cfset stConfig.scrollRepeatInterval = "scrollRepeatInterval" />
	<cfset stConfig.shadow = "shadow" />
	<cfset stConfig.shim = "shim" />
	<cfset stConfig.stateEvents = "stateEvents" />
	<cfset stConfig.stateId = "stateId" />
	<cfset stConfig.style = "style" />
	<cfset stConfig.tabMargin = "tabMargin" />
	<cfset stConfig.tabPosition = "tabPosition" />
	<cfset stConfig.tabWidth = "tabWidth" />
	<cfset stConfig.tbar = "tbar" />
	<cfset stConfig.title = "title" />
	<cfset stConfig.titleCollapse = "titleCollapse" />
	<cfset stConfig.tools =  "tools" />
	<cfset stConfig.width =  "width" />
	
	
	<!--- accordion config properties --->
	<cfset stConfig.activeOnTop = "activeOnTop" />
	<cfset stConfig.animate = "animate" />
	<cfset stConfig.autoWidth = "autoWidth" />
	<cfset stConfig.collapseFirst = "collapseFirst" />
	<cfset stConfig.fill = "fill" />
	<cfset stConfig.hideCollapseTool = "hideCollapseTool" />
	<cfset stConfig.titleCollapse = "titleCollapse" />	
	
	<!--- BorderLayout.Region config properties --->
	<cfset stConfig.region = "region" />
	<cfset stConfig.animFloat = "animFloat" />
	<cfset stConfig.autoHide = "autoHide" />
	<cfset stConfig.cmargins = "cmargins" />
	<cfset stConfig.collapseMode = "collapseMode" />
	<cfset stConfig.collapsible = "collapsible" />
	<cfset stConfig.floatable = "floatable" />
	<cfset stConfig.margins = "margins" />
	<cfset stConfig.minHeight = "minHeight" />
	<cfset stConfig.minWidth = "minWidth" />
	<cfset stConfig.minSize= "minSize" />
	<cfset stConfig.maxSize = "maxSize" />
	<cfset stConfig.split = "split" />
	
	<!--- Button config properties --->
	<cfset stConfig.text = "text" />
	<cfset stConfig.handler = "handler" />
	
	<!--- Portal config properties --->
	<cfset stConfig.xtype = "xtype" />
	<cfset stConfig.columnWidth = "columnWidth" />
	
	
	<cfset aItems = arrayNew(1) />
	<cfset aHTML = arrayNew(1) />
	
	<cfset variables.primaryLayout = false />
	
	<cfif not structKeyExists(request.extJS, "stLayout")>
		
		<cfset variables.primaryLayout = true />
	
		<cfset request.extJS.stLayout = structNew() />
		<cfset request.extJS.stLayout.aItems = arrayNew(1) />
		<cfset request.extJS.stLayout.aLayoutItems = arrayNew(1) />
	</cfif>
			
</cfif>


<cfif thistag.executionMode eq "End">
	
	 <cfif variables.primaryLayout>
		<cfoutput>
			<script type="text/javascript">
			Ext.onReady(function(){
				var #attributes.id# = new Ext.#attributes.container#({
					dummysothatcommaswork:'x'
		</cfoutput>
					<cfif len(attributes.layout)>
						<cfoutput>,layout:'#attributes.layout#'
						</cfoutput>
					</cfif>
					<cfloop list="#structKeyList(attributes)#" index="i">
						<cfif not listContainsNoCase("id,container,layout",i)>
							<cfoutput>,#stConfig[i]#:<cfif isNumeric(attributes[i])>#attributes[i]#<cfelse>'#attributes[i]#'</cfif>
							</cfoutput>
						</cfif>
					</cfloop>
					
					<cfif arrayLen(request.extJS.stLayout.aLayoutItems)>
						<cfoutput>,items:
						</cfoutput>
						<cfif arrayLen(request.extJS.stLayout.aLayoutItems) GT 1><cfoutput>[</cfoutput></cfif>
						
						<cfset firstItem = true />
						<cfloop from="1" to="#arrayLen(request.extJS.stLayout.aLayoutItems)#" index="i">
							<cfif firstItem>
								<cfset firstItem = false />
							<cfelse>
								<cfoutput>,
								</cfoutput>
							</cfif>
							<cfset itemHTML = renderItem(stProperties=request.extJS.stLayout.aLayoutItems[i]) />
							<cfoutput>#itemHTML#
							</cfoutput>
						</cfloop>		
						
						<cfif arrayLen(request.extJS.stLayout.aLayoutItems) GT 1><cfoutput>]</cfoutput></cfif>
					</cfif>
		<cfoutput>
				})
			})
			</script>
		</cfoutput>
		
	<cfelse>
	
	</cfif>
	
	
	<cfif arrayLen(aHTML)>
		<cfloop from="1" to="#arrayLen(aHTML)#" index="i">
			<cfoutput>#aHTML[i]#</cfoutput>
		</cfloop>
	</cfif>
	
	<cfif structKeyExists(attributes, "renderTo") AND len(attributes.renderTo)>
		<cfoutput><div id="#attributes.renderTo#"></div></cfoutput>
	</cfif>
	
	<cfif structKeyExists(attributes, "applyTo") AND len(attributes.applyTo)>
		<cfoutput><div id="#attributes.applyTo#"></div></cfoutput>
	</cfif>
	
	 <!--- Remove the struct once it is complete --->
	<cfset structDelete(request.extJS, "stLayout") />

	
</cfif>


<cffunction name="renderItem" access="private" returntype="string">
	<cfargument name="stProperties" type="struct" required="true" />
	
	<cfset var returnHTML = "">
	<cfset var firstConfigProperty = true />
	<cfset var firstItem = true />
	<cfset var itemHTML = "">

	<cfsavecontent variable="returnHTML">
		<cfif structKeyExists(arguments.stProperties, "var") AND len(arguments.stProperties.var)>
			<cfoutput>var #arguments.stProperties.var# =</cfoutput>
		</cfif>
		<cfif structKeyExists(arguments.stProperties, "container") AND len(arguments.stProperties.container)>
			<cfoutput>new Ext.#arguments.stProperties.container#(</cfoutput>
		</cfif>
	
	
		<cfif structKeyExists(arguments.stProperties, "html") AND len(arguments.stProperties.html)>
			<cfset arrayAppend(aHTML, arguments.stProperties.html) />
		</cfif>
	
	
		<cfoutput>{</cfoutput>
		<cfloop list="#structKeyList(arguments.stProperties)#" index="i">
			<cfif NOT listFindNoCase("container,aItems,html,listeners,var", i) >
				<cfif firstConfigProperty>
					<cfset firstConfigProperty = false />
				<cfelse>
					<cfoutput>,</cfoutput>
				</cfif>
				<cfoutput>#stConfig[i]#:'#arguments.stProperties[i]#'
				</cfoutput>
				
			</cfif>
		</cfloop>
		
		<cfif structKeyExists(arguments.stProperties, "listeners") and len(arguments.stProperties.listeners)>
			<cfoutput>,listeners:#arguments.stProperties.listeners#
			</cfoutput>
		</cfif>
		
		<cfif structKeyExists(arguments.stProperties, "aItems") and arrayLen(arguments.stProperties.aItems)>
			<cfoutput>,items:
			</cfoutput>
			<cfif arrayLen(arguments.stProperties.aItems) GT 1><cfoutput>[</cfoutput></cfif>
			<cfset firstItem = true />
			<cfloop from="1" to="#arrayLen(arguments.stProperties.aItems)#" index="i">
				<cfif firstItem>
					<cfset firstItem = false />
				<cfelse>
					<cfoutput>,
					</cfoutput>
				</cfif>
				<cfset itemHTML = renderItem(stProperties=arguments.stProperties.aItems[i]) />
				<cfoutput>#itemHTML#</cfoutput>
			</cfloop>
			
			<cfif arrayLen(arguments.stProperties.aItems) GT 1><cfoutput>]</cfoutput></cfif>
		</cfif>
		<cfoutput>}</cfoutput>
		<cfif structKeyExists(arguments.stProperties, "container") AND len(arguments.stProperties.container)>
			<cfoutput>)</cfoutput>
		</cfif>
	</cfsavecontent>
	
	<cfreturn returnHTML /> 
</cffunction>
