<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif isdefined("url.action") and url.action eq "getupdates">
	
	<cfparam name="url.jobs" default="" />
	
	<cfset qJobs = application.fc.lib.tasks.getResultJobs() />
	<cfset oProfile = application.fapi.getContentType(typename="dmProfile") />
	
	<cfset stResult = structnew() />
	<cfset stResult["jobs"] = arraynew(1) />
	
	<cfloop query="qJobs">
		<cfset st = structnew() />
		<cfset st["jobType"] = qJobs.jobType />
		<cfset st["jobID"] = qJobs.jobID />
		<cfset st["taskOwnedBy"] = qJobs.taskOwnedBy />
		<cfif len(st["taskOwnedBy"])>
			<cfset stProfile = oProfile.getProfile(username=st["taskOwnedBy"]) />
			<cfif len(stProfile.firstname) or len(stProfile.lastname)>
				<cfset st["ownedBy"] = "#stProfile.firstname# #stProfile.lastname#" />
			<cfelse>
				<cfset st["ownedBy"] = st["taskOwnedBy"] />
			</cfif>
		</cfif>
		<cfset st["datetimeLatest"] = qJobs.datetimeLatest />
		<cfset st["tasks"] = application.fc.lib.tasks.getTaskCount(jobID=qJobs.jobID) />
		<cfset st["results"] = qJobs.resultCount />
		<cfset st["colourHash"] = getColourHash(id=qJobs.jobID) />
		<cfif find(qJobs.jobID,url.jobs)>
			<cfset st["latestTick"] = rereplace(url.jobs,".*#qJobs.jobID#:(-?\d+).*","\1") />
			
			<cfif st.latestTick lt 0>
				<cfset st.latestTick = abs(st.latestTick) />
				<cfset application.fc.lib.tasks.clearTaskResults(jobID=qJobs.jobID,before=st.latestTick) />
				<cfset st["results"] = 0 />
				<cfset st["optionLabel"] = "#timeformat(qJobs.datetimeLatest,'h:mmtt')#, #dateformat(qJobs.datetimeLatest,'d mmm yy')# (0 results)" />
				<cfset st["latestTick"] = 0 />
			</cfif>
			
			<cfset st["newresults"] = application.fc.lib.tasks.getResults(jobID=qJobs.jobID,previousTick=st.latestTick,clearResults=false) />
			<cfif arraylen(st.newresults)>
				<cfset st["latestTick"] = st.newresults[arraylen(st.newresults)].tick />
			</cfif>
		<cfelse>
			<cfset st["newresults"] = arraynew(1) />
			<cfset st["latestTick"] = 0 />
		</cfif>
		<cfset arrayappend(stResult.jobs,st) />
	</cfloop>
	
	<cfset application.fapi.stream(type="json",content=stResult) />
	
<cfelse>

	<skin:htmlHead><cfoutput>
		<style type="text/css">
			.listing .results .alert {
			    border-color: -moz-use-text-color;
			    border-style: none solid;
			    border-width: 0 1px;
			    margin-bottom: 0;
			    margin-top: 0;
			    padding: 4px 8px;
			}
			.listing .results .alert:first-child {
				border-top: 1px solid;
			}
			.listing .results .alert:last-child {
				border-bottom: 1px solid;
			}
			.alert .icon-info {
				cursor:pointer;
			}
			.info {
				display:none;
			}
				.info .key {
					color:##a020f0;
				}
				.info .number {
					color:##ff0000;
				}
				.info .string {
					color:##000000;
				}
				.info .boolean {
					color:##ffa500;
				}
				.info .null {
					color:##0000ff;
				}
			.remove-results {
				cursor: pointer;
			}
		</style>
	</cfoutput></skin:htmlHead>
	
	<skin:onReady><cfoutput>
		var jobs = {};
		
		$j("##getresults-btn").click(function(){
			var jobID = $j("##select-job").val();
			
			if (!jobID.length)
				return false;
			
			jobs[jobID] = 0;
			
			$j("<div id='listing-"+jobID+"' class='listing' style='display:none;'><div class='actions'><button class='btn clear-btn' data-jobid='"+jobID+"'>Clear Results</button> <span class='job-type'>?</span> created by <span class='job-owner'>?</span>, <span class='job-tasks'>?</span> tasks queued</div><div class='results'></div>").appendTo($j("##job-results-listing"));
			$j("<li id='tab-"+jobID+"' data-jobid='"+jobID+"'><a href='##'><span class='job-label'><i class='icon-spinner icon-spin'></i></span> <span class='badge badge-success job-new-good' style='display:none;'>?</span><span class='badge badge-important job-new-bad' style='display:none;'>?</span> &nbsp;&nbsp;<i class='icon-remove remove-results'></i></a></li>").data("countgood",0).data("countbad",0).appendTo($j("##job-result-tabs")).trigger("click");
			
			return false;
		});
		
		$j("##job-result-tabs").on("click",".remove-results",function(e){
			var jobID = $j(this).closest("li").data("jobid");
			
			delete jobs[jobID];
			$j("##listing-"+jobID+",##tab-"+jobID).remove();
			$j("##job-result-tabs li:first").trigger("click");
			
			e.stopPropagation();
			e.preventDefault();
			
			return false();
		});
		
		$j("##job-result-tabs").on("click","li",function(e){
			$j(this).siblings(".active").removeClass("active");
			$j("##job-results-listing .listing").hide();
			$j("##listing-"+$j(this).data("jobid")).show();
			$j(this).addClass("active").data("countgood",0).data("countbad",0)
				.find(".job-new-good").hide().end()
				.find(".job-new-bad").hide().end()
				.blur();
				
			return false;
		});
		
		$j("##job-results-listing").on("click",".clear-btn",function(){
			var jobID = $j(this).data("jobid");
			
			$j("##listing-"+jobID+" .results").html("");
			jobs[jobID] = 0 - jobs[jobID];
			
			return false;
		});
		
		$j("##job-results-listing").on("click",".icon-info",function(e){
			$j(e.currentTarget).parent().siblings(".info").toggle();
		});
		
		var months = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
		function formatDate(d){
			if (typeof(d)==="string" || typeof(d)==="number")
				d = new Date(d);
			else if (!d)
				d = newDate();
			
			var mont
			
			return d.getHours() + ":" + (d.getMinutes()<10 ? "0" : "") + d.getMinutes() + ", " + d.getDate() + " " + months[d.getMonth()] + " " + d.getFullYear();
		};
		
		function syntaxHighlight(json) {
		    if (typeof json != 'string') {
		         json = JSON.stringify(json, undefined, 2);
		    }
		    json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
		    return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
		        var cls = 'number';
		        if (/^"/.test(match)) {
		            if (/:$/.test(match)) {
		                cls = 'key';
		            } else {
		                cls = 'string';
		            }
		        } else if (/true|false/.test(match)) {
		            cls = 'boolean';
		        } else if (/null/.test(match)) {
		            cls = 'null';
		        }
		        return '<span class="' + cls + '">' + match + '</span>';
		    });
		}
		
		(function getUpdates(){
			var jobsparam = [], jobupdates = {};
			for (var k in jobs){
				jobsparam.push(k+":"+jobs[k]);
				jobupdates[k] = jobs[k];
			}
			
			$j.getJSON("#application.fapi.fixURL()#&action=getupdates&jobs="+jobsparam.join(),function(results){
				var newoptions = [], tab = "", listing = "", badge = "", newhtml = [], countgood = 0, countbad = 0, updated = [];
				
				for (var i=0, ii=results.jobs.length; i<ii; i++){
					newoptions.push({
						id : results.jobs[i].jobID,
						text : results.jobs[i].jobType + ", created by " + results.jobs[i].ownedBy + " (" + formatDate(results.jobs[i].datetimeLatest) + ")",
						librarySelected : results.jobs[i].jobType + ", created by " + results.jobs[i].ownedBy + " (" + formatDate(results.jobs[i].datetimeLatest) + ") <div class='pull-right'>" + results.jobs[i].colourHash + "</div>"
					});
					
					// update label if necessary
					if ($j("##tab-"+results.jobs[i].jobID).size()){
						tab = $j("##tab-"+results.jobs[i].jobID);
						listing = $j("##listing-"+results.jobs[i].jobID+" .results");
						
						$j("##listing-"+results.jobs[i].jobID+" .job-type").html(results.jobs[i].jobType);
						$j("##listing-"+results.jobs[i].jobID+" .job-owner").html(results.jobs[i].ownedBy);
						$j("##listing-"+results.jobs[i].jobID+" .job-tasks").html(results.jobs[i].tasks);
						
						newhtml = [];
						countgood = 0;
						countbad = 0;
						for (var j=0, jj=results.jobs[i].newresults.length; j<jj; j++){
							if (results.jobs[i].newresults[j].result.error){
								countbad += 1;
								newhtml.unshift("<div class='alert alert-error'><div class='pull-right'><i class='icon-info'></i></div>" + formatDate(results.jobs[i].newresults[j].tick) + "&nbsp;&nbsp;" + (results.jobs[i].newresults[j].result.error ? results.jobs[i].newresults[j].result.error.message : "") + "<div class='info'><pre>" + syntaxHighlight(results.jobs[i].newresults[j].result)+"</pre></div></div>");
							}
							else{
								countgood += 1;
								newhtml.unshift("<div class='alert alert-success'><div class='pull-right'><i class='icon-info'></i></div>" + formatDate(results.jobs[i].newresults[j].tick) + "&nbsp;&nbsp;" + (results.jobs[i].newresults[j].result.message ? results.jobs[i].newresults[j].result.message : "")  + "<div class='info'><pre>" + syntaxHighlight(results.jobs[i].newresults[j].result)+"</pre></div></div>");
							}
						}
						listing.prepend(newhtml.join(""));
						
						tab.find(".job-label:has(.icon-spinner)").html(results.jobs[i].colourHash);
						if (!tab.is(".active")){
							tab.data("countgood",tab.data("countgood")+countgood);
							tab.data("countbad",tab.data("countbad")+countbad);
							
							if (tab.data("countgood"))
								tab.find(".job-new-good").html(tab.data("countgood")).show();
							else
								tab.find(".job-new-good").hide();
							
							if (tab.data("countbad"))
								tab.find(".job-new-bad").html(tab.data("countbad")).show();
							else
								tab.find(".job-new-bad").hide();
						}
						
						if (jobupdates[results.jobs[i].jobID]===jobs[results.jobs[i].jobID])
							jobs[results.jobs[i].jobID] = results.jobs[i].latestTick;
					}
				}
				
				(function updateOptions(){
					if ($j("##select-job").siblings(".select2-container").is(".select2-dropdown-open")){
						setTimeout(updateOptions,500);
					}
					else{
						var s2 = $j("##select-job"), val = s2.select2("val"), selected = newoptions.filter(function(o){ return o.id===val; });
						s2.select2({
							minimumInputLength: 0,
							multiple: false,
							allowClear: false,
							placeholder: "Job",
							formatResult: function(object,container,query){
								return object.librarySelected || object.text;
							},
							query: function(options){
								var result = {
									results : [],
									more : false,
									context : null
								}
								
								for (var i=0; i<newoptions.length; i++)
									if (newoptions[i].text.toString().toLowerCase().indexOf(options.term.toLowerCase()) > -1) result.results.push(newoptions[i]);
								
								if (result.results.length > options.page * 10)
									result.more = true;
								
								result.results = result.results.slice((options.page-1) * 10,options.page * 10)
								
								options.callback(result);
							}
						}).select2("data",selected.length ? selected[0] : undefined);
						
						setTimeout(getUpdates,500);
					};
				})();
			});
		})();
	</cfoutput></skin:onReady>
	
	<ft:form id="objectadmin">
		<cfset qJobs = application.fc.lib.tasks.getResultJobs() />
		
		<cfoutput><h1>Queue Result Administration</h1></cfoutput>
		
		<ft:field label="Current Jobs" multiField="true">
			<skin:loadJS id="fc-jquery" />
			<skin:loadJS id="typeahead" />
			<skin:loadCSS id="typeahead" />
			
			<cfoutput>
				<input	type="hidden" class="typeahead" style="width:500px;" id="select-job" name="job" 
						data-typename="" 
						data-allowcreate="false" 
						data-prefix="" 
						data-objectid="" 
						data-multiple="false" 
						data-watch="" 
						data-placeholder="Job" 
						data-value="" 
						data-minimuminputlength="0"
						
						data-data="[]"
						data-createoptions='{}'
						
						value="" />
				
				<button id="getresults-btn" class="btn" style="margin-top:-20px;">Get Results</button>
			</cfoutput>
		</ft:field>
		
		<cfoutput>
			<ul class="nav nav-tabs" id="job-result-tabs"></ul>
			<div id="job-results-listing"></div>
		</cfoutput>
		
	</ft:form>
	
</cfif>

<cfsetting enablecfoutputonly="false">