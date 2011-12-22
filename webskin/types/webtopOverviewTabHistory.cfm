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
			<span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;">&nbsp;</span>
			
			<div class="comment">
				<cfset stProfile = oProfile.getProfile(username=qLog.userid[1]) />
				<span title="#dateformat(qLog.datetimecreated[1], 'dd/mm/yyyy hh:mm:ss')#">#application.fapi.prettyDate(qLog.datetimecreated[1])#</span> - #events[qLog.event[1]]#
				<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
					by #stProfile.firstname# #stProfile.lastname#
				<cfelse>
					by #listfirst(qLog.userid[1],'_')#
				</cfif>
				<cfif len(qLog.notes) and qLog.notes neq "Archive rolled back"><br>#qLog.notes#</cfif>
				<a href="##" onclick="$j(this).hide();$j('##comment-log').show();return false;">View All</a>
			</div>
			
			<div id="comment-log" style="display:none;">
				<cfloop query="qLog">
					<cfif qLog.currentRow neq 1>
						<div class="comment">
							<cfset stProfile = oProfile.getProfile(username=qLog.userid) />
							<span title="#dateformat(qLog.datetimecreated, 'dd/mm/yyyy hh:mm:ss')#">#application.fapi.prettyDate(qLog.datetimecreated)#</span> - #events[qLog.event]#
							<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
								by #stProfile.firstname# #stProfile.lastname#
							<cfelse>
								by #listfirst(qLog.userid,'_')#
							</cfif>
							<cfif len(qLog.notes) and qLog.notes neq "Archive rolled back"><br>#qLog.notes#</cfif>
						</div>
					</cfif>
				</cfloop>
			</div>
		</div>
	</cfoutput>
</cfif>


<cfif structkeyexists(stObj,"status") and structkeyexists(stObj,"versionid")>
	<!--- Create query of comparable versions --->
	<cfset stLocal.qVersions = querynew("objectid,typename,seq,label","varchar,varchar,integer,varchar") />
	<cfif len(stObj.versionID)>
		<cfset stLocal.qArchives = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,datetimecreated,createdby",archiveID_eq=stObj.versionID,orderBy="datetimecreated desc") />
	<cfelse>
		<cfset stLocal.qArchives = application.fapi.getContentObjects(typename="dmArchive",lProperties="objectid,datetimecreated,createdby",archiveID_eq=stObj.objectid,orderBy="datetimecreated desc") />
	</cfif>
	<!--- Process archives --->
	<cfloop query="stLocal.qArchives">
		<cfset queryaddrow(stLocal.qVersions) />
		<cfset querysetcell(stLocal.qVersions,"objectid",stLocal.qArchives.objectid) />
		<cfset querysetcell(stLocal.qVersions,"typename","dmArchive") />
		<cfset querysetcell(stLocal.qVersions,"seq",2+stLocal.qArchives.currentrow) />
		<cfset stProfile = oProfile.getProfile(username=stLocal.qArchives.createdby) />
		<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
			<cfset querysetcell(stLocal.qVersions,"label","#dateformat(stLocal.qArchives.datetimecreated,'d mmm yyyy')#, #timeformat(stLocal.qArchives.datetimecreated,'h:mmtt')# - #stProfile.firstname# #stProfile.lastname#") />
		<cfelse>
			<cfset querysetcell(stLocal.qVersions,"label","#dateformat(stLocal.qArchives.datetimecreated,'d mmm yyyy')#, #timeformat(stLocal.qArchives.datetimecreated,'h:mmtt')# - #listfirst(stLocal.qArchives.createdby,'_')#") />
		</cfif>
	</cfloop>
	<!--- Add alternate approved version --->
	<cfif len(stObj.versionID)>
		<cfset stLocal.stApproved = getData(objectid=stObj.versionID) />
		
		<cfset queryaddrow(stLocal.qVersions) />
		<cfset querysetcell(stLocal.qVersions,"objectid",stObj.versionID) />
		<cfset querysetcell(stLocal.qVersions,"typename",stObj.typename) />
		<cfset querysetcell(stLocal.qVersions,"seq",2) />
		<cfset stProfile = oProfile.getProfile(username=stLocal.stApproved.lastupdatedby) />
		<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
			<cfset querysetcell(stLocal.qVersions,"label","Approved - #stProfile.firstname# #stProfile.lastname#") />
		<cfelse>
			<cfset querysetcell(stLocal.qVersions,"label","Approved - #listfirst(qLog.userid[1],'_')#") />
		</cfif>
	<cfelseif stObj.status eq "approved">
		<!--- Add this as approved version --->
		<cfset stLocal.stApproved = stObj />
		
		<cfset queryaddrow(stLocal.qVersions) />
		<cfset querysetcell(stLocal.qVersions,"objectid",stObj.objectid) />
		<cfset querysetcell(stLocal.qVersions,"typename",stObj.typename) />
		<cfset querysetcell(stLocal.qVersions,"seq",2) />
		<cfset stProfile = oProfile.getProfile(username=stLocal.stApproved.lastupdatedby) />
		<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
			<cfset querysetcell(stLocal.qVersions,"label","Approved - #stProfile.firstname# #stProfile.lastname#") />
		<cfelse>
			<cfset querysetcell(stLocal.qVersions,"label","Approved - #listfirst(qLog.userid[1],'_')#") />
		</cfif>
	</cfif>
	<!--- Add draft version --->
	<cfif stObj.status eq "draft">
		<cfset queryaddrow(stLocal.qVersions) />
		<cfset querysetcell(stLocal.qVersions,"objectid",stObj.objectid) />
		<cfset querysetcell(stLocal.qVersions,"typename",stObj.typename) />
		<cfset querysetcell(stLocal.qVersions,"seq",1) />
		<cfset stProfile = oProfile.getProfile(username=stObj.lastupdatedby) />
		<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
			<cfset querysetcell(stLocal.qVersions,"label","Draft - #stProfile.firstname# #stProfile.lastname#") />
		<cfelse>
			<cfset querysetcell(stLocal.qVersions,"label","Draft - #listfirst(qLog.userid[1],'_')#") />
		</cfif>
	</cfif>
	
	<cfif stLocal.qVersions.recordcount gt 1>
		<!--- Update order --->
		<cfquery dbtype="query" name="stLocal.qVersions">
			select * from stLocal.qVersions order by seq
		</cfquery>
		
		<skin:onReady><script type="text/javascript"><cfoutput>
			var diffURL = "#application.fapi.getLink(type='#stObj.typename#',view='webtopDiffResult',urlParameters='left=NEWLEFT&right=NEWRIGHT&ajaxmode=1')#";
			var discardURL = "navajo/delete.cfm?ObjectId=DISCARDID&returnto=" + encodeURIComponent(window.location.href) + "&ref=" + window.location.href.replace(/.*[&\?]ref=([^&]*).*/,"$1");
			
			function updateResults(left,right){
				$j("##diff-results").load(diffURL.replace("NEWLEFT",left).replace("NEWRIGHT",right),function(){
					$j("table.diff-items tr",this).each(function(){
						var maxHeight = 0;
						var props = $j("td.property-value",this).each(function(){
							maxHeight = Math.max(maxHeight,$j(this).height());
						});
						if (maxHeight>100){
							props.data("full-height",maxHeight)
								.wrapInner("<div class='view-property' style='height:100px;overflow:hidden;'></div>")
								.append("<div class='view-control showalltext' style='text-align:center;font-weight:bold;cursor:pointer;'>...</div>");
						}
					});
				});
			};
			
			$j("##diff-left-label,##diff-right-label").bind("click",function(){
				var self = $j(this);
				
				self.hide();
				$j('##'+self.attr("rel")).show();
				
				return false;
			});
			
			$j("##diff-left,##diff-right").bind("change",function(){
				var self = $j(this);
				
				self.hide();
				$j("##"+self.attr("rel")).text($j("option:selected",this).html()).show();
				
				updateResults($j("##diff-left").val(),$j("##diff-right").val());
			});
			
			$j("a.discarddraft").live("click",function(){
				var self = $j(this);
				self.attr("href",discardURL.replace("DISCARDID",self.attr("rel")));
				
				if (!confirm('Are you sure you wish to discard this draft version? The approved version will remain.')) return false;
			});
			
			$j("a.rollback").live("click",function(){
				var self = $j(this);
				self.attr("href",window.location.href.replace(/&rollback=[^>]+/,'') + "&rollback=" + self.attr("rel"));
				
				if (!confirm('Are you sure you want to rollback to this version? Any existing drafts will be discarded.')) return false;
			});
			
			$j("div.showalltext").live("click",function(){
				var texts = $(this).parents("tr:first div.view-property");
				if (texts.hasClass("full-view"))
					texts.css("height",100).removeClass("full-view");
				else
					texts.css("height",$(this).parents(".property-value").data("full-height")).addClass("full-view");
				return false;
			}).live("mouseover",function(){
				$j(this).parents("tr:first").find(".showalltext").css("background-color","##CBDAEF");
			}).live("mouseout",function(){
				$j(this).parents("tr:first").find(".showalltext").css("background-color","transparent");
			});
			
			<cfif stLocal.qVersions.recordcount gt 1>
				updateResults("#stLocal.qVersions.objectid[2]#","#stLocal.qVersions.objectid[1]#");
			</cfif>
		</cfoutput></script></skin:onReady>
		
		<!--- History comparison - select items --->
		<cfoutput>
			Changes between
			<a id="diff-left-label" rel="diff-left">#stLocal.qVersions.label[2]#</a>
			<select name="left" id="diff-left" style="display:none;" rel="diff-left-label">
				<cfloop query="stLocal.qVersions">
					<cfif stLocal.qVersions.currentrow neq 1>
						<option value="#stLocal.qVersions.objectid#">#stLocal.qVersions.label#</option>
					</cfif>
				</cfloop>
			</select>
			and 
			<a id="diff-right-label" rel="diff-right">#stLocal.qVersions.label[1]#</a>
			<select name="left" id="diff-right" style="display:none;" rel="diff-right-label">
				<cfloop query="stLocal.qVersions">
					<cfif stLocal.qVersions.currentrow neq stLocal.qVersions.recordcount>
						<option value="#stLocal.qVersions.objectid#">#stLocal.qVersions.label#</option>
					</cfif>
				</cfloop>
			</select>
		</cfoutput>
		
		<cfoutput><div id="diff-results" style="margin-top:20px;"></div></cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />