<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Site Tree Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-underscore" />
<skin:loadJS id="fc-backbone" />
<skin:loadJS id="fc-handlebars" />

<skin:loadJS id="farcry-form" />
<skin:loadJS id="fc-farcry-devicetype" />


<!--- 

	TODO

	V load leaf nodes normally, deal with versioned objects
	V draft/approved/status
	V stacked draft pencil icon
	V edit URL for an approved/draft versioned object different to normaly types objects?
	V make edit button work properly (no dupes)
	V previews should refresh only when the device webskins change


	easy wins
	---------

	V zoom on a particular node / tree section
		- zoom to the users "home node" by default
		- move "up" button (one level) if within the users home node
		V how should we deal with utility navigation? use a different page / menu item

	- options dropdown:
		- hook up existing functionality first
			- create
			- status
			- permissions
			- properties
			- delete
		- move node to a new parent


	followed by
	-----------

	- add, move, more? toolbar buttons
		- context sensitive? delete, approve, send to draft, request approval
		- root/home/utility nodes MUST NOT be deleted

	- sorting...

	- search... ajax auto complete / select2
		- click on a result sets the zoomed node root 
		- or just expand the tree to that point and scroll to / highlight it?

	- permissions? derpa?


	nice to have, undecided
	-----------------------

	- can modals somehow make reloading the whole page optional? 
		- alternatively, reload the table body rows only?


	dead last
	---------
	
	- use resource bundles for all labels in this webtopBody AND webtopTreeChildRows
	- config: set up a config for device type widths


 --->


<!--- set the default "home" root node --->
<cfset userOverviewHome = "home">
<cfif isDefined("session.dmProfile.overviewHome") AND len(session.dmProfile.overviewHome)>
	<cfset userOverviewHome = session.dmProfile.overviewHome>
</cfif>

<cfparam name="url.alias" default="#userOverviewHome#">
<cfparam name="url.rootobjectid" default="#application.fapi.getNavId(url.alias)#">


<cfparam name="farcryRootObjectid" default="#application.fapi.getNavId("root")#">


<!--- find root node --->
<cfif isDefined("url.rootobjectid") AND isValid("uuid", url.rootobjectid)>
	<cfset rootObjectID = url.rootobjectid>
<cfelse>
	<cfset rootObjectID = application.fapi.getNavId("home")>
</cfif>

<!--- get device type preview widths --->
<cfset deviceWidth = structNew()>
<cfset deviceWidth["desktop"] = 1050>
<cfset deviceWidth["tablet"] = 768>
<cfset deviceWidth["mobile"] = 480>
<!--- get current device type --->
<cfset currentDevice = application.fc.lib.device.getDeviceType()>
<cfif NOT listFindNoCase("desktop,tablet,mobile", currentDevice)>
	<cfset currentDevice = "desktop">
</cfif>

<!--- navigation type --->
<cfset navTitle = "Site Navigation">
<!--- TODO: built-in "navigation types" with separate menu items? testing changing the page heading... --->
<cfif listLast(url.id, ".") eq "utility">
	<cfset navTitle = "Utility Navigation">
</cfif>



<!--- process forms --->
<ft:processform action="delete" url="refresh">
	<cfif isDefined("form.objectid") and len(form.objectID)>
		
		<cfloop list="#form.objectid#" index="i">
			<cfset stDeletingObject = application.fapi.getContentObject(objectid=i)>
			<cfset o = application.fapi.getContentType(stDeletingObject.typename)>
			<cfset stResult = o.delete(objectid=i)>
			
			<cfif isDefined("stResult.bSuccess") AND not stResult.bSuccess>
				<skin:bubble title="Error deleting - #stDeletingObject.label#" bAutoHide="true" tags="type,#attributes.typename#,error">
					<cfoutput>#stResult.message#</cfoutput>
				</skin:bubble>
			<cfelse>
				<skin:bubble title="Deleted - #stDeletingObject.label# <a href='?id=#url.id#&typename=dmArchive&bodyView=webtopBody&archivetype=#attributes.typename#' style='margin-left:10px;'>Undo</a>" bAutoHide="true" tags="type,#attributes.typename#,deleted,info" />
			</cfif>
		</cfloop>
	</cfif>
</ft:processform>
<ft:processform action="unlock" url="refresh"> 
	<cfif isDefined("form.objectid") and len(form.objectID)>
		
		<cfloop list="#form.objectid#" index="i">
			<cfset stLockedObject = application.fapi.getContentObject(objectid=i)>
			<cfset o = application.fapi.getContentType(stLockedObject.typename)>
			<cfset o.setlock(objectid=i, locked=false)>
		</cfloop>
	
	</cfif>
	
</ft:processForm>



<cfoutput>

	<h1><i class="icon-sitemap"></i> #navTitle#</h1>

	<div class="farcry-button-bar btn-group pull-left">
		<button class="btn btn-primary" type="button" onclick="alert('Coming soon...');"><i class="icon-plus"></i> Add Page</button>
		<button class="btn" type="button"><i class="icon-move"></i> Move</button>
		<!--- <ft:button text="Delete" value="delete" title="Delete" icon="icon-trash" rbkey="objectadmin.buttons.delete" confirmText="Are you sure you want to delete the selected content item(s)?" /> --->

		<div class="btn-group">
			<button data-toggle="dropdown" class="btn btn-group dropdown-toggle" type="button">More <i class="caret"></i></button>
			<ul class="dropdown-menu">
				<li><a href="##" class="fc-btn-"><i class="icon-undo icon-fixed-width"></i> Undelete</a></li>
			</ul>
		</div>

	</div>

	<div class="input-prepend input-append pull-right">
		<input class="span2" type="text" placeholder="Search..." style="width: 240px;">
		<button class="btn" style="height: 30px; border-radius:0"><b class="icon-search only-icon"></b></button>
	</div>

	<ft:form name="farcrytree" style="clear:both">

	<table id="farcry-sitetree" class="objectadmin table table-hover farcry-objectadmin">
	<thead>
		<tr>
			<th class="fc-col-min fc-hidden-compact"></th>
			<th class="fc-col-actions">Actions</th>
			<th>Title</th>
			<th class="fc-visible-compact">URL</th>
			<th class="fc-col-status fc-hidden-compact">Status</th>
			<th class="fc-col-date fc-hidden-compact">Last Updated</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td></td>
			<td></td>
			<td><i class="icon-spinner icon-spin"></i> &nbsp;Loading...</td>
			<td></td>
			<td></td>
			<td></td>
		</tr>
	</tbody>
	</table>

	</ft:form>


	<div id="preview-container" class="" style="position: fixed; width:0; background: red; top: 74px; right: 0; bottom: 0; z-index: 120; overflow:visible;">
		<div id="preview" style="position: absolute; right: -#deviceWidth[currentDevice]#px; width: #deviceWidth[currentDevice]#px; max-width: #deviceWidth[currentDevice]#px; height: 100%; box-shadow: 0 0 16px rgba(0,0,0,0.32); background: ##fff;">

			<div class="modal-header">
				<button type="button" class="close" onclick="showPreview();" aria-hidden="true">&times;</button>
				<h4 style="margin:0; float:left; padding-top: 2px; margin-right: 20px; line-height: 24px"><i id="previewicon" class="icon-eye-open" style="display:inline-block; font-size: 16px; width: 16px; height: 16px;"></i> Preview</h4>
				<button style="margin-left: -2px" class="btn btn-edit" type="button" onclick="previewDevice('desktop', #deviceWidth["desktop"]#);"><i class="icon-desktop"></i>&nbsp;Desktop</button>
				<button style="margin-left: -2px" class="btn btn-edit" type="button" onclick="previewDevice('tablet', #deviceWidth["tablet"]#);"><i class="icon-tablet"></i>&nbsp;Tablet</button>
				<button style="margin-left: -2px" class="btn btn-edit" type="button" onclick="previewDevice('mobile', #deviceWidth["mobile"]#);"><i class="icon-mobile-phone"></i>&nbsp;Mobile</button>
			</div>

			<iframe id="previewiframe" src="http://#cgi.http_host#/" frameborder="0" border="0" width="100%" height="100%" style="position: absolute; top: 40;"></iframe>

		</div>
	</div>



	<div id="minitree-container" class="" style="display: none; position: fixed; width:400px; height: 500px; left: 50%; top: 50%; z-index: 120; overflow:visible;">
		<div id="minitree" style="position: absolute; top: -250px; left: -200px; width: 100%; height: 100%; border: 1px solid ##ccc; border-radius: 2px; box-shadow: 0 0 16px rgba(0,0,0,0.32); background: ##fff;">

			<div class="modal-header">
				<button type="button" class="close" aria-hidden="true">&times;</button>
				<h4 style="margin:0; padding-top: 2px; margin-right: 20px; line-height: 24px"><i class="icon-move" style="display:inline-block; font-size: 16px; width: 16px; height: 16px;"></i> Move</h4>
			</div>

			<div class="modal-body" style="overflow: auto; height: 368px; max-height: 368px;">

				<table class="objectadmin table table-hover farcry-objectadmin">
				<thead>
					<tr>
						<th>This folder</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td class="fc-tree-title fc-nowrap"><a href="##" class="fc-treestate-toggle"><i class="fc-icon-treestate"></i></a><span class="icon-stack"><i class="icon-folder-close"></i></span> <span>Getting Started</span></td>
					</tr>
				</tbody>
				</table>

				<table id="farcry-minitree" class="objectadmin table table-hover farcry-objectadmin">
				<thead>
					<tr>
						<th>Will be moved into the selected folder...</th>
					</tr>
				</thead>
				<tbody style="max-height: 200px; overflow: auto;">
					<tr>
						<td><i class="icon-spinner icon-spin"></i> &nbsp;Loading...</td>
					</tr>
				</tbody>
				</table>

			</div>

			<div class="modal-footer" style="border: none; border-radius: 0; -moz-border-radius: 0">
				<a href="##" class="btn btn-primary">Move</a>
				<a href="##" class="btn">Cancel</a>
			</div>


		</div>
	</div>




	<script type="text/javascript">

		/* preview */

		function showPreview(previewURL, bShow) {
			previewURL = previewURL || null;
			bShow = bShow || null;

			var w = $j("##preview").width();
			var maxWidth = $j("body").width();
			var h = $j("##preview").height();
			var $iframe = $j("##preview iframe").height(h - 45);
			var iframe = document.getElementById("previewiframe");

			if (w > maxWidth) {
				w = maxWidth;
			}

			previewMaxWidth(maxWidth);

			if ($j("##preview").hasClass("visible") || bShow === false || previewURL == null) {
				if (previewURL != null && $iframe.attr("src") != previewURL) {
					$iframe.attr("src", previewURL);
					previewLoading();
				}
				else {
					$j("##preview").removeClass("visible").animate({ right: w * -1 }, 250);
				}
			}
			else {
				$iframe.attr("src", previewURL);
				previewLoading();
				$j("##preview").addClass("visible").animate({ right: 0 }, 250);
			}


		}

		function previewDevice(targetDeviceType, width) {
			var enabledWebskins = {};
			// note: desktop should always be defaulted to false here 
			enabledWebskins["desktop"] = false;
			enabledWebskins["tablet"] = false;
			enabledWebskins["mobile"] = false;
			<cfif application.fc.lib.device.isTabletWebskinsEnabled()>
				enabledWebskins["tablet"] = true;
			</cfif>
			<cfif application.fc.lib.device.isMobileWebskinsEnabled()>
				enabledWebskins["mobile"] = true;
			</cfif>

			// get the previous device type
			var previousDeviceType = $fc.getDeviceType();

			// set the new target device type
			$fc.setDeviceTypeCookie(targetDeviceType);
			// set the new device width
			previewWidth(width);

			// reload if different webskins will be used
				// previous == target (do nothing)
				// desktop -> tablet (only if target enabled)
				// desktop -> mobile (only if target enabled)
				// tablet -> desktop (only if previous enabled)
				// mobile -> desktop (only if previous enabled)
				// tablet -> mobile (if either enabled)
				// mobile -> tablet (if either enabled)
			if (previousDeviceType == targetDeviceType) {
				// no reload
			}
			else if (previousDeviceType == "desktop" && enabledWebskins[targetDeviceType]) {
				previewReload();
			}
			else if (targetDeviceType == "desktop" && enabledWebskins[previousDeviceType]) {
				previewReload();
			}
			else if (enabledWebskins[previousDeviceType] || enabledWebskins[targetDeviceType]) {
				previewReload();
			}
		}

		function previewReload() {
			var iframe = document.getElementById("previewiframe");
			iframe.contentWindow.location.reload();
			previewLoading();
		}

		function previewLoading() {
			var iframe = document.getElementById("previewiframe");
			$j("##previewicon").attr("class", "icon-spinner icon-spin");
			iframe.onload = (function() {
				$j("##previewicon").attr("class", "icon-eye-open");
			});
		}

		function previewWidth(w) {
			$j("##preview").animate({ width: w }, 200);
		}

		function previewMaxWidth(w) {
			$j("##preview").css("max-width", w);
		}

		/* resize the preview when the browser changes */ 
		$j(window).resize(function resizePreview() {
			// update the max width
			var w = $j(document.body).width();
			previewMaxWidth(w);
			// keep the preview off screen
			if (!$j("##preview").hasClass("visible")) {
				$j("##preview").css("right", -w);
			}
		});

		$j(function() {

			/* bind preview buttons */
			$j(".farcry-objectadmin").on("click", ".objectadmin-actions a.fc-btn-preview", function(evt){
				//evt.preventDefault();
				var previewURL = $j(this).attr("href");
				showPreview(previewURL);
				return false;
			});

		});


	</script>


	<!--- get root tree data --->
	<cfsavecontent variable="jsonData">
		<skin:view objectid="#rootObjectID#" typename="dmNavigation" webskin="webtopTreeChildRows" responsetype="json" />
	</cfsavecontent>


	<skin:htmlHead><cfoutput>
		<script type="text/javascript">
			App = {};


			SiteTreeView = Backbone.View.extend({

				options: {
					bRenderTreeOnly: false,
					bIgnoreExpandedNodes: false,
					bLoadLeafNodes: true
				},


				initialize: function SiteTreeView_initialize(options){

					if (options.type == "mini") {
						this.options.bRenderTreeOnly = true;
						this.options.bIgnoreExpandedNodes = true;
						this.options.bLoadLeafNodes = false;
					}

					if (options.data) {
						this.data = options.data;
						this.render();
					}

					if (options.rootObjectID) {
						this.rootObjectID = options.rootObjectID;
						this.loadTree(this.rootObjectID);
					}

				},

				events: {
					"click .fc-treestate-toggle" : "clickToggle",
					"click .fc-tree-title" : "clickTitle",
					"click .fc-copyto" : "clickCopyTo",
					"click .fc-moveto" : "clickMoveTo",
					"click .fc-zoom" : "clickZoom"
				},

				
				render: function SiteTreeView_render(){

					var treeContent = $j("tbody", this.$el);

					// construct markup from data
					var aRowMarkup = [];
					for (i=0; i<this.data.rows.length; i++) {
						var rowhtml = this.getRowMarkup(this.data.rows[i]);
						aRowMarkup.push(rowhtml);
					}

					treeContent.html(aRowMarkup.join(""));

					this.loadExpandedAjaxNodes();

				},


				clickToggle: function clickToggle(evt){
					var table = $j(evt.currentTarget).closest(".objectadmin");
					var row = $j(evt.currentTarget).closest("tr");

					if (row.hasClass("fc-treestate-notloaded")) {
						this.loadTreeChildRows(row);
					}
					else if (row.hasClass("fc-treestate-expand")) {
						this.expandTreeRows(row);
						this.setExpandedNodesCookie();
					}
					else if (row.hasClass("fc-treestate-collapse")) {
						this.collapseTreeRow(row);
						this.setExpandedNodesCookie();
					}

					return false;
				},

				clickTitle: function clickTitle(evt){
					$j(evt.currentTarget).find(".fc-treestate-toggle").click();
				},


				clickCopyTo: function SiteTreeView_clickCopyTo(evt){
					var objectid = $j(evt.currentTarget).closest("tr").data("objectid");

					$j("##minitree-container").show();
				},

				clickMoveTo: function SiteTreeView_clickMoveTo(evt){
					this.clickCopyTo(evt);
				},


				clickZoom: function SiteTreeView_clickZoom(evt){
					var objectid = $j(evt.currentTarget).closest("tr").data("objectid");
					if (objectid.length) {
						window.location = "#application.fapi.fixURL(removevalues="alias,rootobjectid")#&rootobjectid=" + objectid;
					}
				},




				getParentId: function SiteTreeView_getParentId(o) {
					return o.data("parentid");
				},
				getNodeType: function SiteTreeView_getNodeType(o) {
					return o.data("nodetype");
				},

				getRowById: function SiteTreeView_getRowById(id) {
					return $j("tr[data-objectid="+ id + "]", this.$el);
				},

				getDescendantsById: function SiteTreeView_getDescendantsById(id, bIncludeSelf) {
					bIncludeSelf = bIncludeSelf || false;

					var row = this.getRowById(id);
					var nlevel = row.data("nlevel");

					// get siblings until is nlevel less than or equal to the row nlevel
					var children = $j();
					var done = false;
					var next = row;
					if (bIncludeSelf) {
						children = children.add(next);
					}
					while (done != true) {
						next = next.next();
						if (next.data("nlevel") > nlevel) {
							children = children.add(next);
						}
						else {
							done = true;
							if (next.hasClass("ui-sortable-placeholder")) {
								done = false;
							}
						}
					}

					return children;
				},


				getChildRows: function SiteTreeView_getChildRows(id) {
					return $j("tr[data-parentid="+ id +"]", this.$el);
				},


				getExpandedNodes: function SiteTreeView_getExpandedNodes() {
					var expandedNodes = $j("tr.fc-treestate-collapse", this.$el);
					var aExpandedNodes = [];
					expandedNodes.each(function(){
						var thisObjectid = $j(this).data("objectid");
						aExpandedNodes.push(thisObjectid);
					});

					return aExpandedNodes.join('|');
				},

				setExpandedNodesCookie: function SiteTreeView_setExpandedNodesCookie(lObjectid) {
					lObjectid = lObjectid || this.getExpandedNodes();
					// set session only cookie
					if (!this.bIgnoreExpandedNodes) {
						document.cookie = "FARCRYTREEEXPANDEDNODES=" + lObjectid + "; expires=0; path=/;";
					}
				},

				reloadTreeBranch: function SiteTreeView_reloadTreeBranch(id) {
					var row = this.getRowById(id);
					this.loadTreeChildRows(row, true);
				},




				loadExpandedAjaxNodes: function SiteTreeView_loadExpandedAjaxNodes(id) {

					var self = this;

					// default id to root node
					var root = $j("tbody tr:first", this.$el);
					id = id || root.data("objectid");

					var children = this.getChildRows(id);

					children.each(function(){
						var childRow = $j(this);
						if (childRow.hasClass("fc-treestate-collapse") && childRow.hasClass("fc-treestate-notloaded")) {

							self.loadTreeChildRows(childRow);
						}
						else {
							self.loadExpandedAjaxNodes(childRow.data("objectid"));
						}
					});

				},


				loadTreeData: function SiteTreeView_loadTreeData(data) {

					var treeContent = $j("tbody", this.$el);

					// construct markup from data
					var aRowMarkup = [];
					for (i=0; i<data.rows.length; i++) {
						var rowhtml = this.getRowMarkup(data.rows[i]);
						aRowMarkup.push(rowhtml);
					}

					treeContent.html(aRowMarkup.join(""));

					this.loadExpandedAjaxNodes();

				},


				loadTree: function SiteTreeView_loadTree(rootobjectid) {

					var self = this;
					var treeContent = $j("tbody", this.$el);

					var urlParams = ''
						+	'&bLoadLeafNodes=' + this.options.bLoadLeafNodes 
						+	'&bIgnoreExpandedNodes=' + this.options.bIgnoreExpandedNodes
						+	'&bRenderTreeOnly=' + this.options.bRenderTreeOnly
					;


					$j.ajax({
						url: "#application.url.webtop#/index.cfm?typename=dmNavigation&objectid=" + rootobjectid + "&view=webtopTreeChildRows&bLoadRoot=true&ajaxmode=1&responsetype=json" + urlParams,
						datatype: "json",
						success: function(response) {
							response.success = response.success || false;
							if (response.success) {

								// construct markup from response
								var aRowMarkup = [];
								for (i=0; i<response.rows.length; i++) {
									var rowhtml = self.getRowMarkup(response.rows[i]);
									aRowMarkup.push(rowhtml);
								}

								treeContent.html(aRowMarkup.join(""));


							}
							else {
		// TODO: alert the user of an error with this request
							}
						},
						error: function() {
		// TODO: alert the user of an error with this request

						},
						complete: function() {
							if (!self.bIgnoreExpandedNodes) {
								self.loadExpandedAjaxNodes();
							}
						}
					});

				},



				loadTreeChildRows: function SiteTreeView_loadTreeChildRows(row, bReloadBranch) {

					bReloadBranch = bReloadBranch || false;

					var self = this;

					var id = row.data("objectid");
					var relativenlevel = row.data("indentlevel");
					var descendants = $j();
					var loadCollapsed = false;

					var urlParams = ''
						+	'&bLoadLeafNodes=' + this.options.bLoadLeafNodes 
						+	'&bIgnoreExpandedNodes=' + this.options.bIgnoreExpandedNodes
						+	'&bRenderTreeOnly=' + this.options.bRenderTreeOnly
					;

					row.removeClass("fc-treestate-notloaded").addClass("fc-treestate-loading");
					row.find(".fc-tree-title").first().append("<i class='icon-spinner icon-spin' style='margin-left:0.5em'></i>");


					// if reloading a branch, find the deepest descendant nlevel in this branch so that an appropriate depth can be loaded
					if (bReloadBranch) {
						descendants = this.getDescendantsById(id, true);
						// maintain the collapsed state of the branch when loading
						if (row.hasClass("fc-treestate-expand")) {
							loadCollapsed = true;
						}
					}

					$j.ajax({
						url: "#application.url.webtop#/index.cfm?typename=dmNavigation&objectid=" + id + "&view=webtopTreeChildRows&bReloadBranch=" + bReloadBranch + "&loadCollapsed=" + loadCollapsed + "&ajaxmode=1&responsetype=json" + urlParams,
						data: {
							"relativenlevel": relativenlevel
						},
						datatype: "json",
						success: function(response) {
							response.success = response.success || false;
							if (response.success) {

								// construct markup from response
								var aRowMarkup = [];
								for (i=0; i<response.rows.length; i++) {
									var rowhtml = self.getRowMarkup(response.rows[i]);
									aRowMarkup.push(rowhtml);
									
								}

								if (bReloadBranch) {
									$j(aRowMarkup.join("")).insertAfter(descendants.last());
									descendants.remove();
								}
								else {
									$j(aRowMarkup.join("")).insertAfter(row);
									row.removeClass("fc-treestate-loading fc-treestate-expand").addClass("fc-treestate-collapse");
									row.find(".fc-tree-title .icon-folder-close").removeClass("icon-folder-close").addClass("icon-folder-open");
								}
							}
							else {
		// TODO: alert the user of an error with this request
							}
						},
						error: function() {
		// TODO: alert the user of an error with this request
							row.removeClass("fc-treestate-loading").addClass("fc-treestate-notloaded");
						},
						complete: function() {
							row.find(".fc-tree-title i.icon-spinner").remove();
							self.setExpandedNodesCookie();
							self.loadExpandedAjaxNodes(id);

						}
					});

					return;
				},


				expandTreeRows: function SiteTreeView_expandTreeRows(row) {

					var self = this;

					var id = row.data("objectid");
					var children = this.getChildRows(id);

					row.removeClass("fc-treestate-expand").addClass("fc-treestate-collapse");
					row.find(".fc-tree-title .icon-folder-close").removeClass("icon-folder-close").addClass("icon-folder-open");

					children.each(function(){
						var childRow = $j(this);
						childRow.removeClass("fc-treestate-hidden").addClass("fc-treestate-visible");
						if (childRow.hasClass("fc-treestate-collapse")) {
							self.expandTreeRows(childRow);
						}
					});

				},


				collapseTreeRow: function SiteTreeView_collapseTreeRow(row) {
					var id = row.data("objectid");
					var descendants = this.getDescendantsById(id);

					row.removeClass("fc-treestate-collapse").addClass("fc-treestate-expand");
					row.find(".fc-tree-title .icon-folder-open").removeClass("icon-folder-open").addClass("icon-folder-close");
					descendants.removeClass("fc-treestate-visible").addClass("fc-treestate-hidden");

				},


				getRowMarkup: function SiteTreeView_getRowMarkup(row) {

					var overviewURL = "#application.url.webtop#/edittabOverview.cfm?typename=" + row["typename"] + "&objectid=" + row["objectid"];
					var createURL = "#application.url.webtop#/conjuror/evocation.cfm?parenttype=dmNavigation&typename=dmNavigation&objectid=" + row["objectid"];
					var deleteURL = "#application.url.webtop#/navajo/delete.cfm?objectid=" + row["objectid"];

					var reloadTreeBranchObjectID = row["objectid"];
					if (row["nodetype"] == "leaf") {
						reloadTreeBranchObjectID = row["parentid"];
					}


					var locked = "";
					if (row["locked"] == true) {
						locked = "<img src='#application.url.webtop#/images/treeImages/customIcons/padlock.gif'>";
					}
					var colCheckbox = '';
					if (!this.options.bRenderTreeOnly) {
						colCheckbox = '<td class="fc-col-min fc-hidden-compact" nowrap="nowrap">' + locked + '</td> ';
					}

					var dropdown = "";
					if (row["nodetype"] == "folder") {
						dropdown = 
								'<li><a href="##" class="fc-add" onclick="$fc.objectAdminAction(\'Add Page\', \'' + createURL + '\', { onHidden: function(){ reloadTreeBranch(\'' + row["objectid"] + '\'); } }); return false;"><i class="icon-plus icon-fixed-width"></i> Add Page</a></li> '
							+	'<li><a href="##" class="fc-zoom"><i class="icon-zoom-in icon-fixed-width"></i> Zoom</a></li> '
							+	'<li class="divider"></li> '
							+	'<li><a href="##" class="fc-copyto"><i class="icon-copy icon-fixed-width"></i> Copy to...</a></li> '
							+	'<li><a href="##" class="fc-moveto"><i class="icon-move icon-fixed-width"></i> Move to...</a></li> '
							+	'<li class="divider"></li> '
							+	'<li><a href="##" class="" onclick="alert(\'Coming soon...\');"><i class="icon-trash icon-fixed-width"></i> Delete</a></li> '
						;
					}
					else if (row["nodetype"] == "leaf") {
						dropdown = 
								'<li><a href="##" class=""><i class="icon-trash icon-fixed-width"></i> Delete</a></li> '
						;
					}
					var colActions = '';
					if (!this.options.bRenderTreeOnly) {
						colActions = ''
							+	'<td class="objectadmin-actions"> '
							+		'<button class="btn fc-btn-overview fc-hidden-compact fc-tooltip" onclick="$fc.objectAdminAction(\'Overview\', \'' + overviewURL + '\', { onHidden: function(){ reloadTreeBranch(\'' + reloadTreeBranchObjectID + '\'); } }); return false;" title="" type="button" data-original-title="Object Overview"><i class="icon-th only-icon"></i></button> '
							+		'<button class="btn btn-edit fc-btn-edit fc-hidden-compact" type="button" onclick="$fc.objectAdminAction(\'Edit Page\', \'' + row["editURL"] + '\', { onHidden: function(){ reloadTreeBranch(\'' + reloadTreeBranchObjectID + '\'); } }); return false;"><i class="icon-pencil"></i> Edit</button> '
							+		'<a href="' + row["previewURL"] + '" class="btn fc-btn-preview fc-tooltip" title="" data-original-title="Preview"><i class="icon-eye-open only-icon"></i></a> '
							+		'<div class="btn-group"> '
							+			'<button data-toggle="dropdown" class="btn dropdown-toggle" type="button"><i class="icon-caret-down only-icon"></i></button> '
							+			'<div class="dropdown-menu"> '
							+				'<li class="fc-visible-compact"><a href="##" class="fc-btn-overview"><i class="icon-th icon-fixed-width"></i> Overview</a></li> '
							+				'<li class="fc-visible-compact"><a href="##" class="fc-btn-edit"><i class="icon-pencil icon-fixed-width"></i> Edit</a></li> '
							+				'<li class="fc-visible-compact"><a href="##" class="fc-btn-preview"><i class="icon-eye-open icon-fixed-width"></i> Preview</a></li> '
							+				'<li class="divider fc-visible-compact"></li> '
							+       		dropdown
							+			'</div> '
							+		'</div> '
							+	'</td> '
						;
					}

					var colURL = '';
					if (!this.options.bRenderTreeOnly) {
						colURL = '<td class="fc-nowrap-ellipsis fc-visible-compact">' + row["previewURL"] + '</td> ';
					}

					var colStatus = '';
					if (!this.options.bRenderTreeOnly) {
						colStatus = '<td class="fc-hidden-compact">' + row["statuslabel"] + '</td> ';
					}

					var colDateTime = '';
					if (!this.options.bRenderTreeOnly) {
						colDateTime = '<td class="fc-hidden-compact" title="' + row["datetimelastupdated"] + '">' + row["prettydatetimelastupdated"] + '</td> ';
					}


					var html = 
						'<tr class="' + row["class"] + '" data-objectid="' + row["objectid"] + '" data-typename="' + row["typename"] + '" data-nlevel="' + row["nlevel"] + '" data-expandable="' + row["expandable"] + '" data-indentlevel="' + row["indentlevel"] + '" data-nodetype="' + row["nodetype"] + '" data-parentid="' + row["parentid"] + '"> '
						+	colCheckbox
						+	colActions
						+	'<td class="fc-tree-title fc-nowrap">' + row["spacer"] + '<a class="fc-treestate-toggle" href="##"><i class="fc-icon-treestate"></i></a>' + row["nodeicon"] + ' <span>' + row["label"] + '</span></td> '
						+	colURL
						+	colStatus
						+	colDateTime
						+'</tr> '
					;

					return html;
				}


			});


			$j(function() {

				App.siteTreeView = new SiteTreeView({
					el: "##farcry-sitetree",
					data: #jsonData#
				});

				App.miniTreeView = new SiteTreeView({
					el: "##farcry-minitree",
					rootObjectID: "#farcryRootObjectid#",
					type: "mini"
				});


			});
		</script>
	</cfoutput></skin:htmlHead>




</cfoutput>

<cfsetting enablecfoutputonly="false">