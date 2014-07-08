<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Site Tree Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadJS id="fc-underscore" />
<skin:loadJS id="fc-backbone" />
<skin:loadJS id="fc-handlebars" />
<skin:loadJS id="fc-moment" />

<skin:loadJS id="farcry-form" />
<skin:loadJS id="fc-farcry-devicetype" />

<!--- load handlebars templates --->
<skin:hbs template="preview-dialog">
<skin:hbs template="tree-dialog">
<skin:hbs template="tree-sort">


<!--- 
	TODO

	V load leaf nodes normally, deal with versioned objects
	V draft/approved/status
	V stacked draft pencil icon
	V edit URL for an approved/draft versioned object different to normaly types objects?
	V make edit button work properly (no dupes)
	V previews should refresh only when the device webskins change
	V root/home/utility nodes MUST NOT be used in destructive operations
	V reload row / branch after closing overview/edit modal
	V disable the source node when choosing the destination node for copy to / move to

	V zoom on a particular node / tree section
		V zoom to the users "home node" by default
		V how should we deal with utility navigation? use a different page / menu item
		- move "up" button (one level) if within the users home node

	V drag drop sorting

	V options dropdown:
		V hook up existing functionality first
			V create
			V status
			X permissions
			X properties
			V delete
		V move node to a new parent


	finally
	---------
	
	V backbone preview view (separate, reusable for objectadmin), pass preview view into tree view for use
	V config: set up a config for device type widths

	- use resource bundles for all labels in this webtopBody AND webtopTreeChildRows
	- search... ajax auto complete / select2
		- click on a result sets the zoomed node root 
		- or just expand the tree to that point and scroll to / highlight it?


 --->


<!--- set the default "home" root node --->
<cfparam name="url.alias" default="">
<cfif isDefined("session.dmProfile.overviewHome") AND len(session.dmProfile.overviewHome)>
	<cfif NOT len(url.alias)>
		<cfif isValid("uuid", session.dmProfile.overviewHome)>
			<cfparam name="url.rootobjectid" default="#session.dmProfile.overviewHome#">
		<cfelse>
			<cfset url.alias = session.dmProfile.overviewHome>
		</cfif>
	</cfif>
</cfif>
<cfparam name="url.rootobjectid" default="#application.fapi.getNavId(url.alias)#">


<cfparam name="farcryRootObjectid" default="#application.fapi.getNavId("root")#">


<!--- find root node --->
<cfif isDefined("url.rootobjectid") AND isValid("uuid", url.rootobjectid)>
	<cfset rootObjectID = url.rootobjectid>
<cfelse>
	<cfset rootObjectID = application.fapi.getNavId("home")>
</cfif>

<!--- navigation type --->
<cfset navTitle = application.rb.getResource("webtop.sitenavigation@label", "Site Navigation") />
<!--- TODO: built-in "navigation types" with separate menu items? testing changing the page heading... --->
<cfif listLast(url.id, ".") eq "utility">
	<cfset navTitle = application.rb.getResource("webtop.utilitynavigation@label", "Utility Navigation") />
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
				<skin:bubble title="Deleted - #stDeletingObject.label# <a class='undo-delete' href='#application.url.webtop#/index.cfm?typename=dmArchive&bodyView=webtopBody&archivetype=#attributes.typename#' style='margin-left:10px;'>Undo</a>" bAutoHide="true" tags="type,#attributes.typename#,deleted,info" />
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

	<h1><i class="fa fa-sitemap"></i> #navTitle#</h1>

	<div class="farcry-button-bar btn-group pull-left" style="margin-bottom: 5px">
		<button class="btn btn-primary fc-btn-addpage" type="button"><i class="fa fa-plus"></i> #application.rb.getResource('objectadmin.buttons.addpage@label', 'Add Page')#</button>
		<!--- <button class="btn" type="button"><i class="fa fa-level-up"></i> Up a Level</button> --->
		<!--- <button class="btn" type="button"><i class="fa fa-reorder"></i> Sort Order</button> --->

		<!--- <ft:button text="Delete" value="delete" title="Delete" icon="fa fa-trash" rbkey="objectadmin.buttons.delete" confirmText="Are you sure you want to delete the selected content item(s)?" /> --->

		<div class="btn-group">
			<button data-toggle="dropdown" class="btn btn-group dropdown-toggle" type="button">#application.rb.getResource("objectadmin.buttons.more@label", "More")# &nbsp;<i class="fa fa-caret-down"></i></button>
			<ul class="dropdown-menu">
				<li><a href="##" class="fc-btn-undelete" onclick="$fc.objectAdminAction('Undelete', '#application.url.webtop#/index.cfm?typename=dmArchive&view=webtopPageModal&bodyView=webtopBody&archivetype=dmNavigation'); return false;"><i class="fa fa-undo fa-fw"></i> #application.rb.getResource("objectadmin.buttons.undelete@label", "Undelete")#</a></li>
			</ul>
		</div>

	</div>

<!---
	<div class="input-prepend input-append pull-right">
		<input class="span2" type="text" placeholder="Search..." style="width: 240px;">
		<button class="btn" style="height: 30px; border-radius:0"><b class="fa fa-search"></b></button>
	</div>
--->

	<ft:form name="farcrytree" style="clear:both">

	<table id="farcry-sitetree" class="objectadmin table table-hover farcry-objectadmin">
	<thead>
		<tr>
			<th class="fc-col-min fc-hidden-compact"></th>
			<th class="fc-col-actions">#application.rb.getResource("objectadmin.columns.action@label", "Actions")#</th>
			<th>#application.rb.getResource("objectadmin.columns.label@heading", "Title")#</th>
			<th class="fc-visible-compact">URL</th>
			<th class="fc-col-status fc-hidden-compact">#application.rb.getResource("objectadmin.columns.status@heading", "Status")#</th>
			<th class="fc-col-date fc-hidden-compact">#application.rb.getResource("objectadmin.columns.datetimelastupdated@heading", "Last Updated")#</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td></td>
			<td></td>
			<td><i class="fa fa-spinner fa-spin"></i> &nbsp;Loading...</td>
			<td></td>
			<td></td>
			<td></td>
		</tr>
	</tbody>
	</table>

	</ft:form>


	<!--- get root tree data --->
	<cfsavecontent variable="jsonData">
		<skin:view objectid="#rootObjectID#" typename="dmNavigation" webskin="webtopTreeChildRows" bLoadRoot="true" responsetype="json" />
	</cfsavecontent>


	<skin:htmlHead>
		<script src="#application.url.webtop#/app/views/PreviewView.js" type="text/javascript"></script>
		<script type="text/javascript">
			App = {};


			TreeDialogView = Backbone.View.extend({

				options: {
					primaryTreeView: null,

					action: null,
					actionURL: null,
					title: "",
					submitLabel: "Submit",
					sourceObjectID: null,
					sourceName: null,
					sourceNodeIsFolder: null,
					sourceText: "Source folder...",
					targetObjectID: null,
					targetText: "Destination folder..."

				},

				initialize: function TreeDialogView_initialize(options){
					this.template = Handlebars.compile(Backbone.$("##tree-dialog").html());

				},

				events: {
					"click .modal-header .close, .btn-cancel": "close",
					"click .btn-submit": "submit"

				},


				render: function TreeDialogView_render(){
					this.$el.html(this.template(this.options));
					Backbone.$("body").append(this.$el);   

					this.treeView = new SiteTreeView({
						el: "##farcry-minitree",
						rootObjectID: "#farcryRootObjectid#",
						type: "mini",
						expandTo: this.options.sourceObjectID
					});
					this.treeView.render();

				},


				close: function close(evt){
					this.remove();
				},

				submit: function submit(evt){

					// get selected nav item
					this.options.targetObjectID = this.treeView.getSelectedObjectID();
					if (this.options.targetObjectID.length) {

						// get the treeview that will perform the operations
						var treeview = this.treeView;
						if (this.options.primaryTreeView) {
							treeview = this.options.primaryTreeView;
						}


						if (typeof this.options.action == "function") {
							this.options.action(this.options.sourceObjectID, this.options.targetObjectID);
							this.close();
						}
						else if (this.options.action == "copy") {
							treeview.doCopyTo(this.options.sourceObjectID, this.options.targetObjectID);
							this.close();
						}
						else if (this.options.action == "move") {
							treeview.doMoveTo(this.options.sourceObjectID, this.options.targetObjectID);
							this.close();
						}

					}
					else {
						alert("Please select a destination folder");
					}
				}

			});



			TreeSortView = Backbone.View.extend({

				options: {
					primaryTreeView: null,

					title: "",
					submitLabel: "Submit",
					sourceParentID: null,
					nodetype: null,
					targetText: "",

					nodes: []

				},

				initialize: function TreeSortView_initialize(options){
					this.template = Handlebars.compile(Backbone.$("##tree-sort").html());

				},

				events: {
					"click .modal-header .close, .btn-cancel": "close",
					"click .btn-submit": "submit"

				},


				render: function TreeSortView_render(){

					var self = this;
					var i = 0;

					this.$el.html(this.template(this.options));
					Backbone.$("body").append(this.$el);   

					var treeContent = Backbone.$("tbody", this.$el);


					Backbone.$.ajax({
						url: "#application.url.webtop#/index.cfm",
						data: {
							"typename": "dmNavigation",
							"objectid": this.options.sourceParentID,
							"view": "webtopTreeChildRows",
							"ajaxmode": 1,
							"responsetype": "json",
							"bLoadRoot": true,
							"depth": 1,
							"bRenderRoot": false,
							"bIgnoreExpandedNodes": true
						},
						datatype: "json",
						success: function(response) {
							response.success = response.success || false;
							if (response.success) {

								self.options.nodes = [];

								// get rows with the same nodetype and parentid
								for (i=0; i<response.rows.length; i++) {
									if (response.rows[i].nodetype == self.options.nodetype && response.rows[i].parentid == self.options.sourceParentID) {

										self.options.nodes.push(response.rows[i]);

									}
								}

								// render the rows
								var aRowMarkup = [];

								for (i=0; i<self.options.nodes.length; i++) {
									var row = self.options.nodes[i];
									// change spacer indent level by node type
									row["spacers"] -= self.options.nodetype == "leaf" ? 2 : 1;
									var spacer = '<i class="fc-icon-spacer-' + row["spacers"] + '"></i>';

									var html = 
										'<tr class="' + row["class"] + '" data-objectid="' + row["objectid"] + '" data-typename="' + row["typename"] + '" data-nlevel="' + row["nlevel"] + '" data-spacers="' + row["spacers"] + '" data-expandable="' + row["expandable"] + '" data-nodetype="' + row["nodetype"] + '" data-parentid="' + row["parentid"] + '"> '
										+	'<td class="fc-tree-title fc-nowrap">' + spacer + '<a class="fc-treestate-toggle" href="javascript:void(0);"><i class="fc-icon-treestate"></i></a>' + row["nodeicon"] + ' <span>' + row["label"] + '</span></td> '
										+'</tr> '
									;

									aRowMarkup.push(html);
								}

								treeContent.html(aRowMarkup.join(""));

								// make sortable
								treeContent.sortable({
									axis: "y",
									cursor: "move",
									tolerance: "pointer"
								});

							}
							else {
		// TODO: alert the user of an error with this request
console.log("200 success=false");
console.log(response);
alert(response.message);
							}
						},
						error: function(response) {
		// TODO: alert the user of an error with this request
console.log("Non-200 error");
console.log(response);
alert(response.message);
						},
						complete: function() {
							
						}
					});

				},


				close: function close(evt){
					this.remove();
				},

				submit: function submit(evt){

					var self = this;

					var sortedRows = Backbone.$("tbody", this.$el).find("tr");
					var aNodes = [];

					// add the sorted objectids to the array
					sortedRows.each(function(){
						var row = Backbone.$(this);
						var objectid = row.data("objectid");
						aNodes.push(objectid);

					});

					if (aNodes.length) {
						this.options.primaryTreeView.doSort(this.options.sourceParentID, this.options.nodetype, aNodes);
						this.close();
					}

				}

			});



			SiteTreeView = Backbone.View.extend({

				options: {
					bRenderTreeOnly: false,
					bSaveExpandedNodes: true,
					bLoadLeafNodes: true,
					bExpandOnTitleCellClick: true,
					bSelectOnTitleCellClick: false,

					data: null,
					rootObjectID: null,
					expandTo: null
				},


				initialize: function SiteTreeView_initialize(options){

					_.bindAll(this, 'doMoveTo', 'doCopyTo', 'doSort');

					if (options.type == "mini") {
						this.options.bRenderTreeOnly = true;
						this.options.bSaveExpandedNodes = false;
						this.options.bLoadLeafNodes = false;
						this.options.bExpandOnTitleCellClick = false;
						this.options.bSelectOnTitleCellClick = true;
					}

				},

				events: {
					"click .fc-treestate-toggle" : "clickToggle",
					"click .fc-tree-title" : "clickTitle",
					"dblclick .fc-tree-title" : "clickTitle",
					"click .fc-btn-overview" : "clickOverview",
					"click .fc-btn-edit" : "clickEdit",
					"click .fc-add" : "clickAdd",
					"click .fc-zoom" : "clickZoom",
					"click .fc-changestatus" : "clickStatus",
					"click .fc-sort" : "clickSort",
					"click .fc-copyto" : "clickCopyTo",
					"click .fc-moveto" : "clickMoveTo",
					"click .fc-delete" : "clickDelete"
				},


				render: function SiteTreeView_render(){

					var treeContent = Backbone.$("tbody", this.$el);

					if (this.options.data) {
						// construct markup from inline data
						var aRowMarkup = [];
						for (i=0; i<this.options.data.rows.length; i++) {
							var rowhtml = this.getRowMarkup(this.options.data.rows[i]);
							aRowMarkup.push(rowhtml);
						}
						treeContent.html(aRowMarkup.join(""));
						this.loadExpandedAjaxNodes();
					}
					else {
						// load tree via ajax
						this.loadTree(this.options.rootObjectID);
					}

				},


				clickToggle: function clickToggle(evt){
					var table = Backbone.$(evt.currentTarget).closest(".objectadmin");
					var row = Backbone.$(evt.currentTarget).closest("tr");

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
					if (this.options.bExpandOnTitleCellClick) {
						Backbone.$(evt.currentTarget).find(".fc-treestate-toggle").click();
					}
					else {
						if (this.options.bSelectOnTitleCellClick) {
							var clickedRow = Backbone.$(evt.currentTarget).closest("tr");
							if (!clickedRow.hasClass("fc-treestate-disabled")) {
								this.selectRow(clickedRow);
							}
						}
						if (evt.type == "dblclick") {
							Backbone.$(evt.currentTarget).find(".fc-treestate-toggle").click();
						}
					}
				},


				clickOverview: function clickOverview(evt){

					var self = this;
					var clickedRow = Backbone.$(evt.currentTarget).closest("tr");

					var typename = clickedRow.data("typename");
					var objectid = clickedRow.data("objectid");
					var nodetype = clickedRow.data("nodetype");
					var parentid = clickedRow.data("parentid");

					var overviewURL = "#application.url.webtop#/edittabOverview.cfm?typename=" + typename + "&objectid=" + objectid;

					// node to reload
					var reloadid = objectid;
					if (nodetype == "leaf") {
						reloadid = parentid;
					}


					$fc.objectAdminAction('#application.rb.getResource("webtop.home.overview@label", "Overview")#', overviewURL, { 
						onHidden: function(){ 
							self.reloadTreeBranch(reloadid);
						} 
					}); 

					return false;
				},

				clickEdit: function clickEdit(evt){

					var self = this;
					var clickedRow = Backbone.$(evt.currentTarget).closest("tr");

					var typename = clickedRow.data("typename");
					var objectid = clickedRow.data("objectid");
					var nodetype = clickedRow.data("nodetype");
					var parentid = clickedRow.data("parentid");

					var editURL = clickedRow.data("editurl");

					// node to reload
					var reloadid = objectid;
					if (nodetype == "leaf") {
						reloadid = parentid;
					}

					$fc.objectAdminAction('Edit Page', editURL, {
						onHidden: function(){ 
							self.reloadTreeBranch(reloadid);
						}
					});

					return false;
				},


				clickAdd: function SiteTreeView_clickAdd(evt){

					var self = this;
					var clickedRow = Backbone.$(evt.currentTarget).closest("tr");

					var objectid = clickedRow.data("objectid");
					var createURL = clickedRow.data("createurl");

					$fc.objectAdminAction('#application.rb.getResource('objectadmin.buttons.addpage@label', 'Add Page')#', createURL, { 
						onHidden: function(){ 
							self.reloadTreeBranch(objectid);
						} 
					});

					return false;
				},

				clickZoom: function SiteTreeView_clickZoom(evt){
					var objectid = Backbone.$(evt.currentTarget).closest("tr").data("objectid");
					if (objectid.length) {
						window.location = "#application.fapi.fixURL(removevalues="alias,rootobjectid")#&rootobjectid=" + objectid;
					}
					return true;
				},


				clickStatus: function SiteTreeView_clickStatus(evt){

					var objectid = Backbone.$(evt.currentTarget).closest("tr").data("objectid");
					var status = Backbone.$(evt.currentTarget).data("status");
					var versionobjectid = Backbone.$(evt.currentTarget).data("versionobjectid") || "";

					var params = "";

					if (status == "approve" || status == "approvebranch") {
						params = "status=approved";
						if (versionobjectid.length) {
							params += "&objectid=" + versionobjectid;
						}
						else {
							params += "&objectid=" + objectid;
						}
						if (status == "approvebranch") {
							params += "&approvebranch=1";
						}
					}
					else if (status == "draft" || status == "draftbranch") {
						params = "status=draft";
						if (versionobjectid.length) {
							params += "&objectid=" + versionobjectid;
						}
						else {
							params += "&objectid=" + objectid;
						}
						if (status == "draftbranch") {
							params += "&approvebranch=1";
						}
					}
					else {
						console.log("Warning: unsupported status change");
					}


					$fc.objectAdminAction('Status', '#application.url.farcry#/navajo/approve.cfm?' + params);

					return true;
				},



				clickSort: function SiteTreeView_clickSort(evt){

					var self = this;
					var row = Backbone.$(evt.currentTarget).closest("tr");
					var objectid = row.data("objectid");
					var nodetype = row.data("nodetype");
					var parentid = row.data("parentid");


					// get sibling rows of the same type
					var siblings = this.$el.find("tr[data-parentid="+ parentid +"][data-nodetype=" + nodetype + "]");

					// show the sort ui
					if (siblings.length > 1) {

						this.treeSortView = new TreeSortView({
							primaryTreeView: self,
							sourceParentID: parentid,
							nodetype: nodetype,
							title: "Sort Order...",
							submitLabel: "Save",
							targetText: "Drag and drop the items to sort them..."

						});
						this.treeSortView.render();

					}


					return true;
				},

				doSort: function SiteTreeView_doSort(sourceparentid, nodetype, aNodes){

					var self = this;

					var sourceRow = this.getRowById(sourceparentid);
					this.showLoadingIndicator(sourceRow);

					Backbone.$.ajax({
						url: "#application.url.webtop#/index.cfm",
						data: {
							"typename": "dmNavigation",
							"view": "webtopAjaxTreeAction",
							"action": "sort",
							"ajaxmode": 1,
							"responsetype": "json",
							"sourceobjectid": sourceparentid,
							"nodetype": nodetype,
							"nodes": aNodes.join(",")
						},
						datatype: "json",
						success: function(response) {
							response.success = response.success || false;
							if (response.success) {

								// reload tree parent branch
								self.reloadTreeBranch(sourceparentid);

							}
							else {
	// TODO: alert the user of an error with this request
console.log("200 success=false");
console.log(response);
alert(response.message);
							}
						},
						error: function(response) {
	// TODO: alert the user of an error with this request
console.log("Non-200 error");
console.log(response);
alert(response.message);
						},
						complete: function() {
						}
					});


					return true;
				},



				clickCopyTo: function SiteTreeView_clickCopyTo(evt){

					var self = this;

					var row = Backbone.$(evt.currentTarget).closest("tr");
					var objectid = row.data("objectid");
					var nodetype = row.data("nodetype");
					var sourceName = row.find(".fc-tree-title").text();
					var sourceText = "This folder";
					if (nodetype == "leaf") {
						sourceText = "This item";
					}

					this.treeDialogView = new TreeDialogView({
						primaryTreeView: self,
						action: "copy",
						title: "Copy to...",
						submitLabel: "Copy",
						sourceText: sourceText,
						sourceObjectID: objectid,
						sourceName: sourceName,
						sourceNodeIsFolder: nodetype == "folder",
						targetText: "Will be copied into the selected folder..."

					});
					this.treeDialogView.render();

					return true;
				},


				doCopyTo: function SiteTreeView_doCopyTo(sourceobjectid, targetobjectid){

					var self = this;
					var sourceRow = this.getRowById(sourceobjectid);
					this.showLoadingIndicator(sourceRow);

					Backbone.$.ajax({
						url: "#application.url.webtop#/index.cfm",
						data: {
							"typename": "dmNavigation",
							"view": "webtopAjaxTreeAction",
							"action": "copy",
							"ajaxmode": 1,
							"responsetype": "json",

							"sourceobjectid": sourceobjectid,
							"targetobjectid": targetobjectid
						},
						datatype: "json",
						success: function(response) {
							response.success = response.success || false;
							if (response.success) {

								// reload tree target branch
								var parentid = self.getParentId(self.getRowById(targetobjectid));
								self.reloadTreeBranch(parentid);

							}
							else {
	// TODO: alert the user of an error with this request
console.log("200 success=false");
console.log(response);
alert(response.message);
							}
						},
						error: function(response) {
	// TODO: alert the user of an error with this request
console.log("Non-200 error");
console.log(response);
alert(response.message);
						},
						complete: function() {
							self.removeLoadingIndicator(sourceRow);
						}
					});




					return true;
				},


				clickMoveTo: function SiteTreeView_clickMoveTo(evt){

					var self = this;

					var row = Backbone.$(evt.currentTarget).closest("tr");
					var objectid = row.data("objectid");
					var nodetype = row.data("nodetype");
					var sourceName = row.find(".fc-tree-title").text();
					var sourceText = "This folder";
					if (nodetype == "leaf") {
						sourceText = "This item";
					}

					this.treeDialogView = new TreeDialogView({
						primaryTreeView: self,
						action: "move",
						title: "Move to...",
						submitLabel: "Move",
						sourceText: sourceText,
						sourceObjectID: objectid,
						sourceName: sourceName,
						sourceNodeIsFolder: nodetype == "folder",
						targetText: "Will be moved into the selected folder..."
					});
					this.treeDialogView.render();

					return true;
				},

				doMoveTo: function SiteTreeView_doMoveTo(sourceobjectid, targetobjectid){

					var self = this;

					var sourceRow = this.getRowById(sourceobjectid);
					var parentid = this.getParentId(sourceRow);
					this.showDisabled(sourceRow);
					this.showLoadingIndicator(sourceRow);

					Backbone.$.ajax({
						url: "#application.url.webtop#/index.cfm",
						data: {
							"typename": "dmNavigation",
							"view": "webtopAjaxTreeAction",
							"ajaxmode": 1,
							"responsetype": "json",
							"action": "move",
							"sourceobjectid": sourceobjectid,
							"targetobjectid": targetobjectid
						},
						datatype: "json",
						success: function(response) {
							response.success = response.success || false;
							if (response.success) {

								// reload tree source parent branch and target branch
								self.reloadTreeBranch(parentid);
								self.reloadTreeBranch(targetobjectid);

							}
							else {
	// TODO: alert the user of an error with this request
console.log("200 success=false");
console.log(response);
alert(response.message);
							}
						},
						error: function(response) {
	// TODO: alert the user of an error with this request
console.log("Non-200 error");
console.log(response);
alert(response.message);
						},
						complete: function() {
							self.removeDisabled(sourceRow);
						}
					});



					return true;
				},

				clickDelete: function SiteTreeView_clickDelete(evt){

					var self = this;

					var row = Backbone.$(evt.currentTarget).closest("tr")
					var objectid = row.data("objectid");
					var parentid = row.data("parentid");
					var sourceName = row.find(".fc-tree-title").text().replace(/^\s+|\s+$/g, "");
					var nodetype = row.data("nodetype");

					this.showDisabled(row);

					// node to reload
					var reloadid = parentid;

					if (confirm("Are you sure you want to delete '" + sourceName + "'?")) {

						Backbone.$.ajax({
							url: "#application.url.webtop#/index.cfm",
							data: {
								"typename": "dmNavigation",
								"view": "webtopAjaxTreeAction",
								"ajaxmode": 1,
								"responsetype": "json",
								"action": "delete",
								"sourceobjectid": objectid
							},
							datatype: "json",
							success: function(response) {
								response.success = response.success || false;
								if (response.success) {

									// reload tree branch
									self.reloadTreeBranch(reloadid);

								}
								else {
		// TODO: alert the user of an error with this request
console.log("200 success=false");
console.log(response);
alert(response.message);
								}
							},
							error: function(response) {
		// TODO: alert the user of an error with this request
console.log("Non-200 error");
console.log(response);
alert(response.message);
							},
							complete: function() {
								//self.loadExpandedAjaxNodes();
							}
						});

					}

					return true;
				},



				getParentId: function SiteTreeView_getParentId(o) {
					return o.data("parentid");
				},
				getNodeType: function SiteTreeView_getNodeType(o) {
					return o.data("nodetype");
				},

				getRowById: function SiteTreeView_getRowById(id) {
					return Backbone.$("tr[data-objectid="+ id + "]", this.$el);
				},

				getDescendantsById: function SiteTreeView_getDescendantsById(id, bIncludeSelf) {
					bIncludeSelf = bIncludeSelf || false;

					var row = this.getRowById(id);
					var nlevel = row.data("nlevel");

					// get siblings until is nlevel less than or equal to the row nlevel
					var children = Backbone.$();
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
					return Backbone.$("tr[data-parentid="+ id +"]", this.$el);
				},


				getExpandedNodes: function SiteTreeView_getExpandedNodes() {
					var expandedNodes = Backbone.$("tr.fc-treestate-collapse", this.$el);
					var aExpandedNodes = [];
					expandedNodes.each(function(){
						var thisObjectid = Backbone.$(this).data("objectid");
						aExpandedNodes.push(thisObjectid);
					});

					return aExpandedNodes.join('|');
				},

				setExpandedNodesCookie: function SiteTreeView_setExpandedNodesCookie(lObjectid) {
					lObjectid = lObjectid || this.getExpandedNodes();
					// set session only cookie
					if (this.options.bSaveExpandedNodes) {
						// set expanded nodes cookie to expire 8 hours from now
						var date = new Date();
						date.setTime(date.getTime()+(8*60*60*1000));
						document.cookie = "FARCRYTREEEXPANDEDNODES=" + lObjectid + "; expires=" + date.toGMTString() + "; path=/;";
					}
				},

				reloadTreeBranch: function SiteTreeView_reloadTreeBranch(id) {
					var row = this.getRowById(id);
					this.loadTreeChildRows(row, true);
				},


				loadExpandedAjaxNodes: function SiteTreeView_loadExpandedAjaxNodes(id) {

					var self = this;

					// default id to root node
					var root = Backbone.$("tbody tr:first", this.$el);
					id = id || root.data("objectid");

					var children = this.getChildRows(id);

					children.each(function(){
						var childRow = Backbone.$(this);
						if (childRow.hasClass("fc-treestate-collapse") && childRow.hasClass("fc-treestate-notloaded")) {

							self.loadTreeChildRows(childRow);
						}
						else {
							self.loadExpandedAjaxNodes(childRow.data("objectid"));
						}
					});

				},


				loadTreeData: function SiteTreeView_loadTreeData(data) {

					var treeContent = Backbone.$("tbody", this.$el);

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
					var treeContent = Backbone.$("tbody", this.$el);

					Backbone.$.ajax({
						url: "#application.url.webtop#/index.cfm",
						data: {
							"typename": "dmNavigation",
							"objectid": rootobjectid,
							"view": "webtopTreeChildRows",
							"ajaxmode": 1,
							"responsetype": "json",
							"bLoadRoot": true,
							"bLoadLeafNodes": this.options.bLoadLeafNodes,
							"bRenderTreeOnly": this.options.bRenderTreeOnly,
							"expandTo": this.options.expandTo
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

								treeContent.html(aRowMarkup.join(""));


							}
							else {
		// TODO: alert the user of an error with this request
console.log("200 success=false");
console.log(response);
alert(response.message);
							}
						},
						error: function(response) {
		// TODO: alert the user of an error with this request
console.log("Non-200 error");
console.log(response);
alert(response.message);
						},
						complete: function() {
							self.loadExpandedAjaxNodes();
						}
					});

				},


				showDisabled: function SiteTreeView_showDisabled(row) {
					row.addClass("fc-treestate-disabled");
				},

				removeDisabled: function SiteTreeView_removeDisabled(row) {
					row.removeClass("fc-treestate-disabled");
				},


				showLoadingIndicator: function SiteTreeView_showLoadingIndicator(row) {
					var titleCell = row.find(".fc-tree-title").first();
					row.removeClass("fc-treestate-notloaded").addClass("fc-treestate-loading");
					if (!titleCell.find("i.fa-spinner").length) {
						titleCell.append("<i class='fa fa-spinner fa-spin' style='margin-left:0.5em'></i>");
					}
				},

				removeLoadingIndicator: function SiteTreeView_removeLoadingIndicator(row) {
					row.find(".fc-tree-title i.fa-spinner").remove()
				},


				loadTreeChildRows: function SiteTreeView_loadTreeChildRows(row, bReloadBranch) {

					bReloadBranch = bReloadBranch || false;

					var self = this;

					var id = row.data("objectid");
					var relativenlevel = row.data("spacers");
					// check for reloading the root node
					var bLoadRoot = (id == this.options.rootObjectID);
					// correct the relativenlevel for non-expandable folder nodes
					if (row.data("nodetype") == "folder" && row.data("expandable") == 0) {
						relativenlevel -= 1;
					}

					var descendants = Backbone.$();
					var loadCollapsed = false;

					row.removeClass("fc-treestate-notloaded");
					this.showLoadingIndicator(row);


					// if reloading a branch, find the deepest descendant nlevel in this branch so that an appropriate depth can be loaded
					if (bReloadBranch) {
						descendants = this.getDescendantsById(id, true);
						// maintain the collapsed state of the branch when loading, except on root nodes
						if (!bLoadRoot && row.hasClass("fc-treestate-expand")) {
							loadCollapsed = true;
						}
					}

					Backbone.$.ajax({
						url: "#application.url.webtop#/index.cfm",
						data: {
							"typename": "dmNavigation",
							"objectid": id,
							"view": "webtopTreeChildRows",
							"ajaxmode": 1,
							"responsetype": "json",
							"relativenlevel": relativenlevel,
							"bReloadBranch": bReloadBranch,
							"bLoadRoot": bLoadRoot,
							"bLoadCollapsed": loadCollapsed,
							"bLoadLeafNodes": this.options.bLoadLeafNodes,
							"bRenderTreeOnly": this.options.bRenderTreeOnly,
							"expandTo": this.options.expandTo
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
									Backbone.$(aRowMarkup.join("")).insertAfter(descendants.last());
									descendants.remove();
								}
								else {
									Backbone.$(aRowMarkup.join("")).insertAfter(row);
									row.removeClass("fc-treestate-loading fc-treestate-expand").addClass("fc-treestate-collapse");
									row.find(".fc-tree-title .fa-folder").removeClass("fa-folder").addClass("fa-folder-open");
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
							self.removeLoadingIndicator(row);
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
					row.find(".fc-tree-title .fa-folder").removeClass("fa-folder").addClass("fa-folder-open");

					children.each(function(){
						var childRow = Backbone.$(this);
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
					row.find(".fc-tree-title .fa-folder-open").removeClass("fa-folder-open").addClass("fa-folder");
					descendants.removeClass("fc-treestate-visible").addClass("fc-treestate-hidden");

				},


				selectRow: function SiteTreeView_selectRow(row) {
					var id = row.data("objectid");

					row.closest("tbody").find("tr").removeClass("selected");
					row.addClass("selected");

				},

				getSelectedRow: function SiteTreeView_getSelectedRow() {
					var row = Backbone.$("tbody tr.selected", this.$el).eq(0);
					return row;
				},

				getSelectedObjectID: function SiteTreeView_getSelectedObjectID() {
					var row = this.getSelectedRow();
					var objectid = row.data("objectid") || "";
					return objectid;
				},


				getRowMarkup: function SiteTreeView_getRowMarkup(row) {

					var overviewURL = "#application.url.webtop#/edittabOverview.cfm?typename=" + row["typename"] + "&objectid=" + row["objectid"];
					var createURL = "#application.url.webtop#/conjuror/evocation.cfm?parenttype=dmNavigation&typename=dmNavigation&objectid=" + row["objectid"];
					var deleteURL = "#application.url.webtop#/navajo/delete.cfm?objectid=" + row["objectid"];


					var reloadTreeBranchObjectID = row["objectid"];
					var versionObjectID = "";

					if (row["nodetype"] == "leaf") {
						reloadTreeBranchObjectID = row["parentid"];
						versionObjectID = row["versionobjectid"];
					}


					var locked = "";
					if (row["locked"] == true) {
						locked = '<i class="fa fa-lock fa-lg"></i>';
					}
					var colCheckbox = '';
					if (!this.options.bRenderTreeOnly) {
						colCheckbox = '<td class="fc-col-min fc-hidden-compact" nowrap="nowrap">' + locked + '</td> ';
					}

					var dropdown = "";
					if (row["nodetype"] == "folder") {
						dropdown = 
								'<li><a class="fc-add"><i class="fa fa-plus fa-fw"></i> #application.rb.getResource('objectadmin.buttons.addpage@label', 'Add Page')#</a></li> '
							+	'<li><a class="fc-zoom"><i class="fa fa-search-plus fa-fw"></i> Zoom</a></li> '
							+	'<li class="dropdown-submenu"><a class=""><i class="fa fa-fw"></i> Status</a><ul class="dropdown-menu"> '
							+		'<li><a class="fc-changestatus" data-status="approve">Approve</a></li> '
							+		'<li><a class="fc-changestatus" data-status="approvebranch">Approve Branch</a></li> '
							+		'<li><a class="fc-changestatus" data-status="draft">Send To Draft</a></li> '
							+		'<li><a class="fc-changestatus" data-status="draftbranch">Send Branch To Draft</a></li> '
							+	'</ul></li> '
						;

						// destructive operations only allowed on nodes that are not protected
						if (row["protectednode"] == false) {
							dropdown = dropdown
								+	'<li class="divider"></li> '
								+	'<li><a class="fc-sort"><i class="fa fa-reorder fa-fw"></i> Sort Order...</a></li> '
								+	'<li><a class="fc-copyto"><i class="fa fa-copy fa-fw"></i> Copy to...</a></li> '
								+	'<li><a class="fc-moveto"><i class="fa fa-move fa-fw"></i> Move to...</a></li> '
							;
						}
/*
						dropdown = dropdown
							+	'<li class="divider"></li> '
							+	'<li><a class="fc-permissions"><i class="fa fa-key fa-fw"></i> Permissions</a></li> '
						;
*/
						// destructive operations only allowed on nodes that are not protected
						if (row["protectednode"] == false) {
							dropdown = dropdown
								+	'<li class="divider"></li> '
								+	'<li><a class="fc-delete"><i class="fa fa-trash-o fa-fw"></i> Delete</a></li> '
							;
						}
					}
					else if (row["nodetype"] == "leaf") {
						dropdown = 
								'<li class="dropdown-submenu"><a class=""><i class="fa fa-fw"></i> Status</a><ul class="dropdown-menu"> '
							+		'<li><a class="fc-changestatus" data-status="approve">Approve</a></li> '
							+		'<li><a class="fc-changestatus" data-status="draft">Send To Draft</a></li> '
							+	'</ul></li> '
							+	'<li class="divider"></li> '
							+	'<li><a class="fc-sort"><i class="fa fa-reorder fa-fw"></i> Sort Order...</a></li> '
							+	'<li><a class="fc-copyto"><i class="fa fa-copy fa-fw"></i> Copy to...</a></li> '
							+	'<li><a class="fc-moveto"><i class="fa fa-move fa-fw"></i> Move to...</a></li> '
							+	'<li class="divider"></li> '
							+	'<li><a class="fc-delete"><i class="fa fa-trash-o fa-fw"></i> Delete</a></li> '
						;
					}

					var colActions = '';
					if (!this.options.bRenderTreeOnly) {
						colActions = ''
							+	'<td class="objectadmin-actions"> '
							+		'<button class="btn fc-btn-overview fc-hidden-compact fc-tooltip" title="" type="button" data-original-title="Object Overview"><i class="fa fa-th only-icon"></i></button> '
							+		'<button class="btn btn-edit fc-btn-edit fc-hidden-compact" type="button"><i class="fa fa-pencil"></i> #application.rb.getResource('objectadmin.buttons.edit@label', 'Edit')#</button> '
							+		'<a href="' + row["previewURL"] + '" class="btn fc-btn-preview fc-tooltip" title="Preview"><i class="fa fa-eye only-icon"></i></a> '
							+		'<div class="btn-group"> '
							+			'<button data-toggle="dropdown" class="btn dropdown-toggle" type="button"><i class="fa fa-caret-down only-icon"></i></button> '
							+			'<div class="dropdown-menu"> '
							+				'<li class="fc-visible-compact"><a class="fc-btn-overview"><i class="fa fa-th fa-fw"></i> Overview</a></li> '
							+				'<li class="fc-visible-compact"><a class="fc-btn-edit"><i class="fa fa-pencil fa-fw"></i> #application.rb.getResource('objectadmin.buttons.edit@label', 'Edit')#</a></li> '
							+				'<li class="fc-visible-compact"><a class="fc-btn-preview"><i class="fa fa-eye fa-fw"></i> Preview</a></li> '
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
						colDateTime = '<td class="fc-hidden-compact fc-prettydate" title="' + row["datetimelastupdated"] + '" data-datetime="' + row["datetimelastupdated"] + '">' + row["prettydatetimelastupdated"] + '</td> ';
					}

					var spacer = '<i class="fc-icon-spacer-' + row["spacers"] + '"></i>';

					var html = 
						'<tr class="' + row["class"] + '" data-objectid="' + row["objectid"] + '" data-typename="' + row["typename"] + '" data-nlevel="' + row["nlevel"] + '" data-spacers="' + row["spacers"] + '" data-expandable="' + row["expandable"] + '" data-nodetype="' + row["nodetype"] + '" data-parentid="' + row["parentid"] + '" data-versionobjectid="' + versionObjectID + '" data-createurl="' + createURL + '" data-editurl="' + row["editURL"] + '"> '
						+	colCheckbox
						+	colActions
						+	'<td class="fc-tree-title fc-nowrap">' + spacer + '<a class="fc-treestate-toggle" href="##"><i class="fc-icon-treestate"></i></a>' + row["nodeicon"] + ' <span>' + row["label"] + '</span></td> '
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
					rootObjectID: '#rootObjectID#',
					data: #jsonData#
				});
				App.siteTreeView.render();

				App.previewView = new PreviewView({
					attachTo: "##farcry-sitetree",
					previewURL: "http://#cgi.http_host#/",
					currentDevice: "#application.fc.lib.device.getDeviceType()#",
					bUseTabletWebskins: #application.fc.lib.device.isTabletWebskinsEnabled()#,
					bUseMobileWebskins: #application.fc.lib.device.isMobileWebskinsEnabled()#,
					deviceWidth: {
						desktop: #application.fapi.getConfig("device", "desktopWidth")#,
						tablet: #application.fapi.getConfig("device", "tabletWidth")#,
						mobile: #application.fapi.getConfig("device", "mobileWidth")#
					}
				});
				App.previewView.render();



				$j(".farcry-button-bar .fc-btn-addpage").on("click", function(){

					addPageDialogView = new TreeDialogView({
						action: function(sourceObjectID, targetObjectID){
							var createURL = "#application.url.webtop#/conjuror/evocation.cfm?parenttype=dmNavigation&typename=dmNavigation&objectid=" + targetObjectID;
							$fc.objectAdminAction('#application.rb.getResource('objectadmin.buttons.addpage@label', 'Add Page')#', createURL, { 
								onHidden: function(){ 
									App.siteTreeView.loadTree("#rootObjectID#"); 
								}
							});

						},
						title: "#application.rb.getResource('objectadmin.buttons.addpage@label', 'Add Page')#...",
						submitLabel: "Create",
						targetText: "Add a page in the selected folder..."

					});
					addPageDialogView.render();					

				});


			});
		</script>
	</skin:htmlHead>


</cfoutput>

<cfsetting enablecfoutputonly="false">
