<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: History --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset oProfile = application.fapi.getContentType("dmProfile") />


<!--- Audit history --->
<cfset events = structnew() />
<cfset events.comment = "Comment" />
<cfset events.toapproved = "Approved" />
<cfset events.topending = "Requested approval" />
<cfset events.todraft = "Sent to draft" />
<cfset events.update = "Rolled back" />
<cfif structkeyexists(stObj,"versionid") and len(stObj.versionID)>
	<cfset qLog = application.fapi.getContentType(typename="farLog").filterLog(objectid=stObj.versionID,event='comment,topending,toapproved,todraft,update') />
<cfelse>
	<cfset qLog = application.fapi.getContentType(typename="farLog").filterLog(objectid=stObj.objectID,event='comment,topending,toapproved,todraft,update') />
</cfif>
<cfquery dbtype="query" name="qLog">
	select * from qLog where event in ('comment','topending','toapproved','todraft') or (event='update' and notes like 'Archive rolled back')
</cfquery>
<cfif qLog.recordcount>
	<cfoutput>
		<div id="OKMsg">
			<i class="fa fa-comments" style="float: left; margin-right: .3em;"></i>			
			<div class="comment">
				<blockquote>
					<strong>#events[qLog.event[1]]#</strong>: 
					<cfif len(qLog.notes) and qLog.notes neq "Archive rolled back">#qLog.notes#<cfelse><em>No comment.</em></cfif>	
					<cfset stProfile = oProfile.getProfile(username=qLog.userid[1]) />
					<small><span title="#dateformat(qLog.datetimecreated[1], 'dd/mm/yyyy')# #timeformat(qLog.datetimecreated[1], 'hh:mm:ss')#">#application.fapi.prettyDate(qLog.datetimecreated[1])#</span>
					<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
						| #stProfile.firstname# #stProfile.lastname#
					<cfelse>
						| #listfirst(qLog.userid[1],'_')#
					</cfif></small>
				</blockquote>
				<a href="##" onclick="$j(this).hide();$j('##comment-log').show();return false;">View All</a>
			</div>
			
			<div id="comment-log" style="display:none;">
				<cfloop query="qLog">
					<cfif qLog.currentRow neq 1>
						<div class="comment">
							<blockquote>
								<strong>#events[qLog.event]#</strong>: 
								<cfif len(qLog.notes) and qLog.notes neq "Archive rolled back">#qLog.notes#<cfelse><em>No comment.</em></cfif>	
								<cfset stProfile = oProfile.getProfile(username=qLog.userid) />
								<small><span title="#dateformat(qLog.datetimecreated, 'dd/mm/yyyy')# #timeformat(qLog.datetimecreated, 'hh:mm:ss')#">#application.fapi.prettyDate(qLog.datetimecreated)#</span>
								<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
									| #stProfile.firstname# #stProfile.lastname#
								<cfelse>
									| #listfirst(qLog.userid,'_')#
								</cfif></small>
							</blockquote>
						</div>
					</cfif>
				</cfloop>
			</div>
		</div>
	</cfoutput>
</cfif>


<cfset aVersions = arraynew(1) />

<!--- Live objects --->
<cfif structkeyexists(stObj,"versionid") and stObj.status eq "approved">
	<!--- Approved version --->
	<skin:view typename="dmArchive" webskin="displayTeaserStandard" liveObject="#stObj#" mode="select" r_html="selectHTML" />
	
	<cfset stVersion = structnew() />
	<cfset stVersion["objectid"] = stObj.objectid />
	<cfset stVersion["typename"] = stObj.typename />
	<cfset stVersion["select_html"] = selectHTML />
	<cfset arrayappend(aVersions,stVersion) />
	
	<!--- Find any draft / pending versions --->
	<cfset stLocal.q = application.fapi.getContentObjects(typename=stObj.typename,lProperties="*",versionid_eq=stObj.objectid) />
	<cfif stLocal.q.recordcount>
		<cfset stLocal.stObject = structnew() />
		<cfloop list="#stLocal.q.columnlist#" index="thiscol">
			<cfset stLocal.stObject[thiscol] = stLocal.q[thiscol][stLocal.qArchives.currentrow] />
		</cfloop>
		
		<skin:view typename="dmArchive" webskin="displayTeaserStandard" liveObject="#stLocal.stObject#" mode="select" r_html="selectHTML" />
		
		<cfset stVersion = structnew() />
		<cfset stVersion["objectid"] = stLocal.stObject.objectid />
		<cfset stVersion["typename"] = stLocal.stObject.typename />
		<cfset stVersion["select_html"] = selectHTML />
		<cfset arrayappend(aVersions,stVersion) />
	</cfif>
<cfelseif structkeyexists(stObj,"versionid") and len(stObj.versionid)>
	<!--- Approved version of this draft --->
	<cfset stLocal.stObject = application.fapi.getContentObject(typename=stObj.typename,objectid=stObj.versionID) />
	<skin:view typename="dmArchive" webskin="displayTeaserStandard" liveObject="#stLocal.stObject#" mode="select" r_html="selectHTML" />
	
	<cfset stVersion = structnew() />
	<cfset stVersion["objectid"] = stLocal.stObject.objectid />
	<cfset stVersion["typename"] = stLocal.stObject.typename />
	<cfset stVersion["select_html"] = selectHTML />
	<cfset arrayappend(aVersions,stVersion) />
	
	<!--- This draft --->
	<skin:view typename="dmArchive" webskin="displayTeaserStandard" liveObject="#stObj#" mode="select" r_html="selectHTML" />
	
	<cfset stVersion = structnew() />
	<cfset stVersion["objectid"] = stObj.objectid />
	<cfset stVersion["typename"] = stObj.typename />
	<cfset stVersion["select_html"] = selectHTML />
	<cfset arrayappend(aVersions,stVersion) />
<cfelse>
	<!--- Either an ordinary object, or a draft with no approved version --->
	<skin:view typename="dmArchive" webskin="displayTeaserStandard" liveObject="#stObj#" mode="select" r_html="selectHTML" />
	
	<cfset stVersion = structnew() />
	<cfset stVersion["objectid"] = stObj.objectid />
	<cfset stVersion["typename"] = stObj.typename />
	<cfset stVersion["select_html"] = selectHTML />
	<cfset arrayappend(aVersions,stVersion) />
</cfif>

<cfif structkeyexists(stObj,"versionID") and len(stObj.versionID)>
	<cfset stLocal.qArchives = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=stObj.versionID,orderBy="datetimecreated desc") />
<cfelse>
	<cfset stLocal.qArchives = application.fapi.getContentObjects(typename="dmArchive",lProperties="*",archiveID_eq=stObj.objectid,orderBy="datetimecreated desc") />
</cfif>

<cfloop query="stLocal.qArchives">
	<cfset stLocal.stArchive = structnew() />
	
	<cfloop list="#stLocal.qArchives.columnlist#" index="thiscol">
		<cfset stLocal.stArchive[thiscol] = stLocal.qArchives[thiscol][stLocal.qArchives.currentrow] />
	</cfloop>
	
	<skin:view stObject="#stLocal.stArchive#" webskin="displayTeaserStandard" mode="select" r_html="selectHTML" />
	
	<cfset stVersion = structnew() />
	<cfset stVersion["objectid"] = stLocal.stArchive.objectid />
	<cfset stVersion["typename"] = "dmArchive" />
	<cfset stVersion["select_html"] = selectHTML />
	<cfset arrayappend(aVersions,stVersion) />
</cfloop>

<cfoutput>
	<div id="diff-results" style="margin-top:20px;"></div>
	
	<script type="text/javascript">
		window.diff = {
			versions : #serializeJSON(aVersions)#,
			urls : {
				diff : function(left,right){
					var leftversion = diff.versions[left], rightversion = diff.versions[right];
					
					return [ "#application.url.webroot#/index.cfm?type=#stObj.typename#&view=webtopDiffResult&ajaxmode=1",
						"&left=", leftversion.objectid,
						"&lefttype=", leftversion.typename,
						"&leftseq=", left.toString(),
						"&right=", rightversion.objectid,
						"&righttype=", rightversion.typename,
						"&rightseq=", right.toString() ].join("");
				},
				discard : function(object){
					return "navajo/delete.cfm?ObjectId=" + object + "&returnto=" + encodeURIComponent(window.location.href) + "&ref=" + window.location.href.replace(/.*[&\?]ref=([^&]*).*/,"$1");
				},
				rollback : function(archive){
					return window.location.href.replace(/&rollback=[^>]+/,'') + "&rollback=" + archive;
				}
			},
			enforceMaximumHeight : function enforceMaximumHeight(){
				$j("table.diff-items tr").each(function(){
					var maxHeight = 0;
					
					if ($j(this).find(".view-property").size() !== 0)
						return;
					
					var props = $j("td.diff-item-value",this).each(function(){
						maxHeight = Math.max(maxHeight,$j(this).height());
					});
					
					if (maxHeight>100){
						props.data("full-height",maxHeight)
							.wrapInner("<div class='view-property' style='height:100px;overflow:hidden;'></div>")
							.append("<div class='view-control showalltext' style='text-align:center;font-weight:bold;cursor:pointer;'>...</div>");
					}
				});
			},
			
			// update dom
			updateResults : function updateResults(left,right){
				$j("##diff-results").load(this.urls.diff(left,right),function(){
					$j("table.diff-items tr",this).each(diff.enforceMaximumHeight);
				});
			},
			createItemList : function createItemList(current){
				var html = [ "<div class='item-list'>" ];
				
				for (var i=0; i<this.versions.length; i++){
					html.push("<div class='selectable-item");
					if (this.versions[i].objectid === current){
						html.push(" selected");
					}
					html.push("' rel='");
					html.push(i.toString());
					html.push("'>");
					html.push(this.versions[i].select_html);
					html.push("</div>")
				}
				
				html.push("</div>");
				
				return html.join("");
			},
			removeItemlist : function removeItemList(){
				if (this.$itemlist){
					this.$itemlist.remove();
					delete this.$itemlist;
				}
			},
			
			// events
			discardDraft : function discardDraft(){
				var self = $j(this);
				self.attr("href",discardURL.replace("DISCARDID",self.attr("rel")));
				
				if (!confirm('Are you sure you wish to discard this draft version? The approved version will remain.')) return false;
			},
			rollbackToArchive : function rollbackToArchive(){
				var self = $j(this);
				self.attr("href",window.location.href.replace(/&rollback=[^>]+/,'') + "&rollback=" + self.attr("rel"));
				
				if (!confirm('Are you sure you want to rollback to this version? Any existing drafts will be discarded.')) return false;
			},
			showAllText : function showAllText(){
				var texts = $j(this).parents("tr:first").find("div.view-property");
				
				if (texts.hasClass("full-view"))
					texts.css("height",100).removeClass("full-view");
				else
					texts.css("height",$j(this).parents(".diff-item-value").data("full-height")).addClass("full-view");
				console.log($j(this).parents(".diff-item-value").data("full-height"));
				return false;
			},
			overShowAllText : function overShowAllText(){
				$j(this).parents("tr:first").find(".showalltext").css("background-color","##CBDAEF");
			},
			outShowAllText : function outShowAllText(){
				$j(this).parents("tr:first").find(".showalltext").css("background-color","transparent");
			},
			showItemList : function showItemList(){
				var changing = $j(this).is(".diff-item-left") ? "left" : "right", self = $j("th.diff-item-teaser.diff-item-"+changing);
				
				if (diff.changing !== changing){
					if (diff.changing){
						diff.removeItemlist();
					}
					
					var $list = $j(diff.createItemList(self.attr("rel"))), parentPos = self.offset();
					
					$j("body").append($list);
					diff.$itemlist = $list;
					diff.changing = changing;
					
					$list.width(self.width()).css({
						"top" : parentPos.top,
						"left" : parentPos.left
					});
					$list.scrollTop($list.find(".selected").position().top);
				}
			},
			selectItem : function selectItem(){
				var self = $j(this);
				
				if (diff.changing === "left")
					diff.updateResults(parseInt(self.attr("rel")),diff.right);
				else if (diff.changing === "right")
					diff.updateResults(diff.left,parseInt(self.attr("rel")));
				
				diff.removeItemlist();
				delete diff.changing;
			},
			clickAnywhere : function clickAnywhere(e){
				var self = $j(e.target).parents().andSelf();
				
				if (diff.$itemlist && self.filter(".item-list").size() === 0 && self.filter("th").size() === 0){
					diff.removeItemlist();
					delete diff.changing;
				}
			},
			
			init : function init(){
				if (!window.diffinitialized){
					window.diffinitialized = true;
					
					$j(document)
						.delegate("a.discarddraft","click",diff.discardDraft)
						.delegate("a.rollback","click",diff.rollbackToArchive)
						.delegate("div.showalltext",{
							"click" : diff.showAllText,
							"mouseover" : diff.overShowAllText,
							"mouseout" : diff.outShowAllText
						})
						.delegate("th.diff-item-teaser","click",diff.showItemList)
						.delegate("th.diff-label","click",diff.showItemList)
						.delegate(".selectable-item","click",diff.selectItem)
						.on("click",diff.clickAnywhere);
				}
				
				if (this.versions.length > 1){					
					this.updateResults(0,1);
				}
			}
		};
		
		diff.init();
	</script>
	<style type="text/css">
		table.diff-items th, table.diff-items td { vertical-align:top; padding:5px; }
		.diff-label { text-transform:uppercase; font-weight:bold; font-size:20px; color:##666666; cursor:pointer; }
		.diff-item-teaser { cursor:pointer; }
		.diff-item-left { text-align:right; }
		.diff-item-label { width:19%; font-weight:bold; }
		.diff-item-value { width:40%; }
		td.diff-item-value { font-size:12px; white-space:pre-wrap; }
		.diff-item-divider { width:1%; }
		.diff-items .alt { background-color:##f8f8f8; }
		.item-list { position:absolute; overflow-y:scroll; height:200px; background-color:##FFFFFF; border:1px solid ##CCCCCC; }
		.selectable-item { padding:5px; }
		.selectable-item:hover { background-color:##F9F9F9; }
		.selectable-item.selected { background-color:##ffffbf ; }
	</style>
	
</cfoutput>

<cfsetting enablecfoutputonly="false" />