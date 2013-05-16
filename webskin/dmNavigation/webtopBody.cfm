<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Site Tree Webtop Body --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

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

	- zoom on a particular node / tree section
		- zoom to the users "home node" by default
		- how should we deal with utility navigation? use a different page / menu item?
		- files and images in the tree are gooooone?

	- options dropdown:
		- hook up existing functionality first
		- zoom to here
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



<cfparam name="url.alias" default="home">
<cfparam name="url.rootobjectid" default="#application.fapi.getNavId(url.alias)#">


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

<cfoutput>

	<h1><i class="icon-sitemap"></i> #navTitle#</h1>

	<p class="farcry-button-bar btn-group pull-left">
		<button class="btn btn-primary" type="button"><i class="icon-plus"></i> Add</button>
		<button class="btn" type="button"><i class="icon-move"></i> Move</button>
		<!--<button class="btn" type="button"><i class="icon-trash"></i> Delete</button>-->
		<button class="btn" type="button">More <i class="caret"></i></button>
	</p>

	<div class="input-prepend input-append pull-right">
		<input class="span2" type="text" placeholder="Search..." style="width: 240px;">
		<button class="btn" style="height: 30px; border-radius:0"><b class="icon-search only-icon"></b></button>
	</div>

	<table class="objectadmin table table-hover farcry-objectadmin">
	<thead>
		<tr>
			<th style="width: 1.5em"></th>
			<th style="width: 12em">Actions</th>
			<th>Title</th>
			<th style="width: 9em">Status</th>
			<th style="width: 11em">Last Updated</th>
		</tr>
	</thead>
	<tbody>
</cfoutput>


<skin:view objectid="#rootObjectID#" typename="dmNavigation" webskin="webtopTreeChildRows" />


<cfoutput>
	</tbody>
	</table>


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
			$j(".farcry-objectadmin").on("click", ".objectadmin-actions a.fc-preview", function(evt){
				//evt.preventDefault();
				var previewURL = $j(this).attr("href");
				showPreview(previewURL);
				return false;
			});

		});


		/* tree */

		function getParentId(o) {
			return o.data("parentid");
		}
		function getNodeType(o) {
			return o.data("nodetype");
		}

		function getRowById(id) {
			return $j(".objectadmin tr[data-objectid="+ id + "]");
		}

		function getDescendantsById(id) {
			var row = getRowById(id);
			var nlevel = row.data("nlevel");

			// get siblings until is nlevel less than or equal to the row nlevel
			var children = $j();
			var done = false;
			var next = row;
			while (done != true) {
				next = next.next();
				if (next.data("nlevel") > nlevel) {
					children = children.add(next);
				}
				else {
					if (!next.hasClass("ui-sortable-placeholder")) {
						done = true;
					}
				}
			}

			return children;
		}


		function getChildRows(id) {
			return $j(".objectadmin tr[data-parentid="+ id +"]");
		}


		function loadTreeChildRows(row) {

			var id = row.data("objectid");
			var relativenlevel = row.data("indentlevel");

			row.removeClass("fc-treestate-loadchildren").addClass("fc-treestate-loading");
			row.find(".fc-tree-title").append("<i class='icon-spinner icon-spin' style='margin-left:0.5em'></i>");

			$j.ajax({
				url: "/webtop/index.cfm?typename=dmNavigation&objectid=" + id + "&view=webtopTreeChildRows&responsetype=json",
				data: {
					"relativenlevel": relativenlevel
				},
				datatype: "json",
				success: function(response) {
					response.success = response.success || false;
					if (response.success) {
						$j(response.html).insertAfter(row);
						row.removeClass("fc-treestate-loading fc-treestate-expand").addClass("fc-treestate-collapse");
						row.find(".fc-tree-title .icon-folder-close").removeClass("icon-folder-close").addClass("icon-folder-open");
					}
					else {
// TODO: alert the user of an error with this request
					}
				},
				error: function() {
// TODO: alert the user of an error with this request
					row.removeClass("fc-treestate-loading").addClass("fc-treestate-loadchildren");
				},
				complete: function() {
					row.find(".fc-tree-title i.icon-spinner").remove();
				}
			});

			return;
		}

		function expandTreeRows(row) {
			var id = row.data("objectid");
			var children = getChildRows(id);

			row.removeClass("fc-treestate-expand").addClass("fc-treestate-collapse");
			row.find(".fc-tree-title .icon-folder-close").removeClass("icon-folder-close").addClass("icon-folder-open");

			children.each(function(){
				var childRow = $j(this);
				childRow.removeClass("fc-treestate-hidden").addClass("fc-treestate-visible");
				if (childRow.hasClass("fc-treestate-collapse")) {
					expandTreeRows(childRow);
				}
			});

		}


		function collapseTreeRow(row) {
			var id = row.data("objectid");
			var descendants = getDescendantsById(id);

			row.removeClass("fc-treestate-collapse").addClass("fc-treestate-expand");
			row.find(".fc-tree-title .icon-folder-open").removeClass("icon-folder-open").addClass("icon-folder-close");
			descendants.removeClass("fc-treestate-visible").addClass("fc-treestate-hidden");

		}


		/* objectadmin tree expand/collapse */
		$j(".objectadmin").on("click", ".fc-treestate-toggle", function(evt){
			var table = $j(this).closest(".objectadmin");
			var row = $j(this).closest("tr");

			if (row.hasClass("fc-treestate-loadchildren")) {
				loadTreeChildRows(row);
			}
			else if (row.hasClass("fc-treestate-expand")) {
				expandTreeRows(row);
			}
			else if (row.hasClass("fc-treestate-collapse")) {
				collapseTreeRow(row);
			}
			return false;
		});

		$j(".objectadmin").on("click", ".fc-tree-title", function(evt){
			$j(this).find(".fc-treestate-toggle").click();
		});

	</script>


</cfoutput>

<cfsetting enablecfoutputonly="false">