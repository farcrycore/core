<cfcomponent displayname="Site Tree" hint="Interface for browsing the site tree" extends="forms" output="false">
	<cfproperty ftSeq="1" name="context" type="uuid" ftLabel="Context" ftType="navigation" ftDefault="application.navid.root" ftDefaultType="evaluate" ftRenderType="dropdown" ftIncludeRoot="true" ftSelectMultiple="false" />
	<cfproperty ftSeq="2" name="sitetree" type="uuid" ftLabel="SiteTree" ftType="navigation" ftRenderType="jquery" ftContextMenu="getContextMenu" ftEnableDragDrop="true" ftDragDropRules="getDragDropRules" ftOnChange="getOnChange" ftOnMove="" />
	
	<cffunction name="getContextMenu" access="public" output="false" returntype="string" hint="Returns the context menu configuration">
		<cfset var contextmenu = "" />
		<cfset var label = "" />
		<cfset var thistype = "" />
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<cfsavecontent variable="contextmenu"><cfoutput>
			[
			    {
			        id      : "copy",
			        label   : "Copy",
			        visible : function (NODE, TREE_OBJ) {
			            return NODE.hasClass("copyable");
			        },
			        action  : function (NODE, TREE_OBJ) {
			            console.log("Copy",NODE);
			        }
			    },
			    {
			        id      : "paste",
			        label   : "Paste",
			        visible : function (NODE, TREE_OBJ) {
			            return NODE.hasClass("addnodes");
			        },
			        action  : function (NODE, TREE_OBJ) {
			            console.log("Paste",NODE);
			        }
			    },
			    {
			        id      : "preview",
			        label   : "Preview",
			        visible : function (NODE, TREE_OBJ) {
			            return NODE.hasClass("viewable");
			        },
			        action  : function (NODE, TREE_OBJ) {
			            console.log("Preview",NODE);
			        }
			    },
			    {
			        id      : "zoom",
			        label   : "Zoom",
			        visible : function (NODE, TREE_OBJ) {
			            return true;
			        },
			        action  : function (NODE, TREE_OBJ) {
			            console.log("Zoom",NODE);
			        }
			    },
			    "separator"</cfoutput>
			    <cfloop collection="#application.stCOAPI#" item="thistype">
				    <cfif structkeyexists(application.stCOAPI[thistype],"bUseInTree") and application.stCOAPI[thistype].bUseInTree>
				    	<sec:CheckPermission type="#thistype#" typepermission="Create">
						    <cfif structkeyexists(application.stCOAPI[thistype],"displayname")>
							    <cfset label = application.stCOAPI[thistype].displayname />
							<cfelse>
							    <cfset label = thistype />
							</cfif>
						   
						    <cfoutput>
							,{
								id      : "create#thistype#",
								label   : "Create #label#",
								visible : function (NODE, TREE_OBJ) {
									return NODE.hasClass("addnodes");
								},
								icon	: '#application.url.webtop#/facade/icon.cfm?icon=#thistype#&size=16',
								action  : function (NODE, TREE_OBJ) {
									if (NODE.length) window.open('#application.url.webtop#/conjuror/evocation.cfm?parenttype='+NODE[0].getAttribute("rel")+'&objectId='+NODE[0].id+'&typename=#thistype#',"content");
								}
							}</cfoutput>
						</sec:CheckPermission>
					</cfif>
				</cfloop>
			<cfoutput>]</cfoutput>
		</cfsavecontent>
		
		<cfreturn contextmenu />
	</cffunction>

	<cffunction name="getDragDropRules" access="public" output="false" returntype="string" hint="Returns the drag drop rules for the tree">
	    <cfset var contenttypes = "" />
	    <cfset var thistype = "" />
		<cfset var dragrules = "'dmNavigation * dmNavigation'" />
		
	    <cfloop collection="#application.stCOAPI#" item="thistype">
		    <cfif thistype neq "dmNavigation" and structkeyexists(application.stCOAPI[thistype],"bUseInTree") and application.stCOAPI[thistype].bUseInTree>
		    	<cfset dragrules = listappend(dragrules,"'!#thistype# after dmNavigation'") />
		    	<cfset dragrules = listappend(dragrules,"'!dmNavigation before #thistype#'") />
		    	<cfset dragrules = listappend(dragrules,"'#thistype# before *'") />
			</cfif>
		</cfloop>
		
	    <cfreturn "[ #dragrules# ]" />
	</cffunction>
	
	<cffunction name="getOnChange" access="public" output="false" returntype="string" hint="Returns the on-selection-change javascript for the tree">
		
		<cfreturn "window.open('#application.url.webtop#/edittabOverview.cfm?objectid='+NODE.id,'content');" />
	</cffunction>
	
	
</cfcomponent>