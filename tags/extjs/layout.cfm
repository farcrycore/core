<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname:  --->
<!--- @@description:  This is the primary tag to generate extjs layouts. By nesting item tags <extjs:item> within a layout tag, allows the developer to build a rich application layout. --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">

<cfset oExtJS = createObject("component", "farcry.core.packages.farcry.extjs") />

<cfif thistag.executionMode eq "Start">

	<skin:htmlHead library="extJS" />
	
	<cfparam name="attributes.id" default="layout#randrange(1,9999999)#" /><!--- Generate unique javascript id if required --->
	<cfparam name="attributes.container" default="" />
	<cfparam name="attributes.layout" default="" />
	<cfparam name="attributes.bGlobalVar" default="false" />
	

	<cfparam name="request.extJS" default="#structNew()#" />
	

	<cfset aItems = arrayNew(1) />
	<cfset aHTML = arrayNew(1) />
	
	<cfset variables.primaryLayout = false />
	
	<cfif not structKeyExists(request.extJS, "stLayout")>
		
		<cfset variables.primaryLayout = true />
	
		<cfset request.extJS.stLayout = structNew() />
		<cfset request.extJS.stLayout.aItems = arrayNew(1) />
		<cfset request.extJS.stLayout.aHTML = arrayNew(1) />
		<cfset request.extJS.stLayout.aLayoutItems = arrayNew(1) />
	
	
		<!--- Generic config properties --->
		<cfset request.extJS.stLayout.stConfig = structNew() />
		<cfset request.extJS.stLayout.stConfig.var = "var">
		
		<!--- tabPannel and inherited config properties --->
		<cfset request.extJS.stLayout.stConfig.activeItem = "activeItem">
		<cfset request.extJS.stLayout.stConfig.activeTab = "activeTab" />
		<cfset request.extJS.stLayout.stConfig.allowDomMove = "allowDomMove" />
		<cfset request.extJS.stLayout.stConfig.animCollapse = "animCollapse" />
		<cfset request.extJS.stLayout.stConfig.animScroll = "animScroll" />
		<cfset request.extJS.stLayout.stConfig.applyTo = "applyTo" />
		<cfset request.extJS.stLayout.stConfig.autoDestroy = "autoDestroy" />
		<cfset request.extJS.stLayout.stConfig.autoHeight = "autoHeight" />
		<cfset request.extJS.stLayout.stConfig.autoLoad = "autoLoad" />
		<cfset request.extJS.stLayout.stConfig.autoScroll = "autoScroll" />
		<cfset request.extJS.stLayout.stConfig.autoShow = "autoShow" />
		<cfset request.extJS.stLayout.stConfig.autoTabSelector = "autoTabSelector" />
		<cfset request.extJS.stLayout.stConfig.autoTabs = "autoTabs" />
		<cfset request.extJS.stLayout.stConfig.autoWidth = "autoWidth" />
		<cfset request.extJS.stLayout.stConfig.baseCls = "baseCls" />
		<cfset request.extJS.stLayout.stConfig.bbar = "bbar" />
		<cfset request.extJS.stLayout.stConfig.bGlobalVar = "bGlobalVar" />
		<cfset request.extJS.stLayout.stConfig.bodyBorder = "bodyBorder" />
		<cfset request.extJS.stLayout.stConfig.bodyStyle = "bodyStyle" />
		<cfset request.extJS.stLayout.stConfig.border = "border" />
		<cfset request.extJS.stLayout.stConfig.bufferResize = "bufferResize" />
		<cfset request.extJS.stLayout.stConfig.buttonAlign = "buttonAlign" />
		<cfset request.extJS.stLayout.stConfig.buttons = "buttons" />
		<cfset request.extJS.stLayout.stConfig.checked = "checked" />
		<cfset request.extJS.stLayout.stConfig.checkHandler = "checkHandler" />
		<cfset request.extJS.stLayout.stConfig.cls = "cls" />
		<cfset request.extJS.stLayout.stConfig.collapseFirst = "collapseFirst" />
		<cfset request.extJS.stLayout.stConfig.collapsed = "collapsed" />
		<cfset request.extJS.stLayout.stConfig.collapsedCls = "collapsedCls" />
		<cfset request.extJS.stLayout.stConfig.collapsible = "collapsible" />
		<cfset request.extJS.stLayout.stConfig.contentEl = "contentEl" />
		<cfset request.extJS.stLayout.stConfig.ctCls = "ctCls" />
		<cfset request.extJS.stLayout.stConfig.defaultType = "defaultType" />
		<cfset request.extJS.stLayout.stConfig.defaults = "defaults" />
		<cfset request.extJS.stLayout.stConfig.deferredRender = "deferredRender" />
		<cfset request.extJS.stLayout.stConfig.disabledClass = "disabledClass" />
		<cfset request.extJS.stLayout.stConfig.elements = "elements" />
		<cfset request.extJS.stLayout.stConfig.enableTabScroll = "enableTabScroll" />
		<cfset request.extJS.stLayout.stConfig.enableToggle = "enableToggle" />	
		<cfset request.extJS.stLayout.stConfig.extraCls = "extraCls" />	
		<cfset request.extJS.stLayout.stConfig.floating = "floating" />
		<cfset request.extJS.stLayout.stConfig.footer = "footer" />
		<cfset request.extJS.stLayout.stConfig.frame = "frame" />
		<cfset request.extJS.stLayout.stConfig.header = "header" />
		<cfset request.extJS.stLayout.stConfig.headerAsText = "headerAsText" />
		<cfset request.extJS.stLayout.stConfig.height = "height" />
		<cfset request.extJS.stLayout.stConfig.hideBorders = "hideBorders" />
		<cfset request.extJS.stLayout.stConfig.hideCollapseTool = "hideCollapseTool" />
		<cfset request.extJS.stLayout.stConfig.hideMode = "hideMode" />
		<cfset request.extJS.stLayout.stConfig.hideParent = "hideParent" />
		<cfset request.extJS.stLayout.stConfig.html = "html" />
		<cfset request.extJS.stLayout.stConfig.iconCls = "iconCls" />
		<cfset request.extJS.stLayout.stConfig.id = "id" />
		<cfset request.extJS.stLayout.stConfig.items = "items" />
		<cfset request.extJS.stLayout.stConfig.keys = "keys" />
		<cfset request.extJS.stLayout.stConfig.layout = "layout" />
		<cfset request.extJS.stLayout.stConfig.layoutConfig = "layoutConfig" />
		<cfset request.extJS.stLayout.stConfig.listeners = "listeners">
		<cfset request.extJS.stLayout.stConfig.maskDisabled = "maskDisabled" />
		<cfset request.extJS.stLayout.stConfig.minButtonWidth = "minButtonWidth" />
		<cfset request.extJS.stLayout.stConfig.minTabWidth = "minTabWidth" />
		<cfset request.extJS.stLayout.stConfig.monitorResize = "monitorResize" />
		<cfset request.extJS.stLayout.stConfig.onTriggerClick = "onTriggerClick" />	
		<cfset request.extJS.stLayout.stConfig.plain = "plain" />
		<cfset request.extJS.stLayout.stConfig.plugins = "plugins" />
		<cfset request.extJS.stLayout.stConfig.renderTo = "renderTo" />
		<cfset request.extJS.stLayout.stConfig.resizeTabs = "resizeTabs" />
		<cfset request.extJS.stLayout.stConfig.scrollDuration = "scrollDuration" />
		<cfset request.extJS.stLayout.stConfig.scrollIncrement = "scrollIncrement" />
		<cfset request.extJS.stLayout.stConfig.scrollRepeatInterval = "scrollRepeatInterval" />
		<cfset request.extJS.stLayout.stConfig.stateEvents = "stateEvents" />
		<cfset request.extJS.stLayout.stConfig.shadow = "shadow" />
		<cfset request.extJS.stLayout.stConfig.shim = "shim" />
		<cfset request.extJS.stLayout.stConfig.stateEvents = "stateEvents" />
		<cfset request.extJS.stLayout.stConfig.stateId = "stateId" />
		<cfset request.extJS.stLayout.stConfig.style = "style" />
		<cfset request.extJS.stLayout.stConfig.tabMargin = "tabMargin" />
		<cfset request.extJS.stLayout.stConfig.tabPosition = "tabPosition" />
		<cfset request.extJS.stLayout.stConfig.tabWidth = "tabWidth" />
		<cfset request.extJS.stLayout.stConfig.tbar = "tbar" />
		<cfset request.extJS.stLayout.stConfig.title = "title" />
		<cfset request.extJS.stLayout.stConfig.titleCollapse = "titleCollapse" />
		<cfset request.extJS.stLayout.stConfig.toggleGroup = "toggleGroup" />
		<cfset request.extJS.stLayout.stConfig.tools =  "tools" />
		<cfset request.extJS.stLayout.stConfig.triggerClass = "triggerClass" /> 
		<cfset request.extJS.stLayout.stConfig.width =  "width" />
		
		
		<!--- accordion config properties --->
		<cfset request.extJS.stLayout.stConfig.activeOnTop = "activeOnTop" />
		<cfset request.extJS.stLayout.stConfig.animate = "animate" />
		<cfset request.extJS.stLayout.stConfig.autoWidth = "autoWidth" />
		<cfset request.extJS.stLayout.stConfig.collapseFirst = "collapseFirst" />
		<cfset request.extJS.stLayout.stConfig.fill = "fill" />
		<cfset request.extJS.stLayout.stConfig.hideCollapseTool = "hideCollapseTool" />
		<cfset request.extJS.stLayout.stConfig.titleCollapse = "titleCollapse" />	
		
		<!--- BorderLayout.Region config properties --->
		<cfset request.extJS.stLayout.stConfig.region = "region" />
		<cfset request.extJS.stLayout.stConfig.animFloat = "animFloat" />
		<cfset request.extJS.stLayout.stConfig.autoHide = "autoHide" />
		<cfset request.extJS.stLayout.stConfig.cmargins = "cmargins" />
		<cfset request.extJS.stLayout.stConfig.collapseMode = "collapseMode" />
		<cfset request.extJS.stLayout.stConfig.collapsible = "collapsible" />
		<cfset request.extJS.stLayout.stConfig.floatable = "floatable" />
		<cfset request.extJS.stLayout.stConfig.margins = "margins" />
		<cfset request.extJS.stLayout.stConfig.minHeight = "minHeight" />
		<cfset request.extJS.stLayout.stConfig.minWidth = "minWidth" />
		<cfset request.extJS.stLayout.stConfig.minSize= "minSize" />
		<cfset request.extJS.stLayout.stConfig.maxSize = "maxSize" />
		<cfset request.extJS.stLayout.stConfig.split = "split" />
		
		<!--- Button config properties --->
		<cfset request.extJS.stLayout.stConfig.text = "text" />
		<cfset request.extJS.stLayout.stConfig.handler = "handler" />
		
		<!--- Portal config properties --->
		<cfset request.extJS.stLayout.stConfig.xtype = "xtype" />
		<cfset request.extJS.stLayout.stConfig.columnWidth = "columnWidth" />
	
	</cfif>	
			
</cfif>


<cfif thistag.executionMode eq "End">
	
	 <cfif variables.primaryLayout>

	 	<extjs:onReady>

		<cfif NOT attributes.bGlobalVar>
			<cfoutput>var </cfoutput>
		</cfif>
		
		<cfif len(attributes.container)>
			<cfoutput>#attributes.id# = new Ext.#attributes.container#({
			</cfoutput>
		<cfelse>
			<cfoutput>#attributes.id# = {
			</cfoutput>
		</cfif>
		
		<cfoutput>dummysothatcommaswork:'x'
		</cfoutput>
		
					<cfif len(attributes.layout)>
						<cfoutput>,layout:'#attributes.layout#'
						</cfoutput>
					</cfif>
					<cfif structKeyExists(attributes,"plugins") AND len(attributes.plugins)>
						<cfoutput>,plugins:#attributes.plugins#
						</cfoutput>
					</cfif>
					<cfloop list="#structKeyList(attributes)#" index="i">
						<cfif not listFindNoCase("id,container,layout,plugins,bGlobalVar",i) AND structKeyExists(request.extJS.stLayout.stConfig, i)>
							<cfoutput>,#request.extJS.stLayout.stConfig[i]#:<cfif isNumeric(attributes[i]) 
														OR left(trim(attributes[i]),1) EQ "{"
									 					OR left(trim(attributes[i]),1) EQ "[" 
									 					OR left(trim(attributes[i]),9) EQ "function(" 
									 					OR left(trim(attributes[i]),8) EQ "new Ext." 
									 					OR left(trim(attributes[i]),4) EQ "Ext." 
									 					OR  isBoolean(attributes[i])>
									 					#attributes[i]#
										 			<cfelse>
										 				'#attributes[i]#'
													</cfif>
							</cfoutput>
						</cfif>
					</cfloop>
					
					<cfif arrayLen(request.extJS.stLayout.aLayoutItems)>
						<cfoutput>,items:
						</cfoutput>
						<cfoutput>[</cfoutput>
						<cfset firstItem = true />
						<cfloop from="1" to="#arrayLen(request.extJS.stLayout.aLayoutItems)#" index="i">
							<cfif firstItem>
								<cfset firstItem = false />
							<cfelse>
								<cfoutput>,
								</cfoutput>
							</cfif>
							<cfset itemHTML = oExtJS.renderItem(stProperties="#request.extJS.stLayout.aLayoutItems[i]#") />
							<cfoutput>#itemHTML#
							</cfoutput>
						</cfloop>		
						<cfoutput>]</cfoutput>
					</cfif>
		<cfoutput>
				}
		</cfoutput>

		<cfif len(attributes.container)>
			<cfoutput>)
			</cfoutput>
		<cfelse>
		</cfif>
				
		</extjs:onReady>
	<cfelse>
	
	</cfif>
	
	
	<cfif arrayLen(request.extJS.stLayout.aHTML)>
		<cfloop from="1" to="#arrayLen(request.extJS.stLayout.aHTML)#" index="i">
			<cfoutput>#request.extJS.stLayout.aHTML[i]#</cfoutput>
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


