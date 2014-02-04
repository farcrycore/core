<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif isdefined("url.action") and url.action eq "getupdates">
	
	<cfparam name="url.jobID" />
	<cfparam name="url.resultStatus" />
	<cfparam name="url.tick" />
	
	<cfset aResults = application.fc.lib.tasks.getResults(jobID=url.jobID,previousTick=url.tick,clearResults=false) />
	
	<cfset stResult = structnew() />
	
	<cfset stDateTime = duplicate(application.stCOAPI.farQueueResult.stProps.resultTimestamp.metadata) />
	<cfset stOwnedBy = duplicate(application.stCOAPI.farQueueResult.stProps.taskOwnedBy.metadata) />
	
	<cfloop from="#arraylen(aResults)#" to="1" index="i" step="-1">
		<cfif url.resultStatus eq "all" 
			or (url.resultStatus eq "error" and structkeyexists(aResults[i],"result") and isstruct(aResults[i].result) and structkeyexists(aResults[i].result,"error"))
			or (url.resultStatus eq "success")>
			
			<cfset stOwnedBy.value = aResults[i].ownedBy  />
			<cfset aResults[i].ownedBy = application.formtools["uuid"].oFactory.display(typename="farQueueResult",stObject=structnew(),stMetadata=stOwnedBy,fieldname="") />
			
			<cfset stDatetime.value = aResults[i].timestamp  />
			<cfset aResults[i].timestamp = application.formtools["datetime"].oFactory.display(typename="farQueueResult",stObject=structnew(),stMetadata=stDatetime,fieldname="")/>
			
			<cfset aResults[i].result = application.fapi.formatJSON(serializeJSON(aResults[i].result)) />
		<cfelse>
			<cfset arraydelete(aResults,i) />
		</cfif>
	</cfloop>
	
	<cfset application.fapi.stream(type="json",content=aResults) />
	
<cfelse>
	
	<cfparam name="url.resultStatus" />
	
	<skin:loadJS id="formatjson" />
	<skin:loadCSS id="formatjson" />
	<skin:loadJS id="fc-moment" />
	
	<ft:form id="objectadmin">
		<cfset aResults = application.fc.lib.tasks.getResults(jobID=url.jobID,clearResults=false) />
		<cfset count = 0 />
		
		<cfoutput>
			<h1>Queue Result Administration</h1>
			<div class="results">
		</cfoutput>
		
		<cfset stDatetime = duplicate(application.stCOAPI.farQueueResult.stProps.resultTimestamp.metadata) />
		
		<cfloop from="1" to="#arraylen(aResults)#" index="i">
			<cfset stDatetime.value = aResults[i].timestamp  />
			
			<cfif (url.resultStatus eq "all" or url.resultStatus eq "error") and structkeyexists(aResults[i],"result") and structkeyexists(aResults[i].result,"error")>
				<cfset count = count + 1 />
				<cfoutput>
					<div class='alert alert-error'>
						<div class='pull-right'><i class='fa fa-info'></i></div>
						#application.formtools["datetime"].oFactory.display(typename="farQueueResult",stObject=structnew(),stMetadata=stDatetime,fieldname="")#
						&nbsp;&nbsp;
						<cfif structkeyexists(aResults[i],"result") and isstruct(aResults[i].result) and structkeyexists(aResults[i].result,"error")>#aResults[i].result.error.message#</cfif>
						<div class='info'><pre class="formatjson">#application.fapi.formatJSON(serializeJSON(aResults[i].result))#</pre></div>
					</div>
				</cfoutput>
			<cfelseif url.resultStatus eq "all" or url.resultStatus eq "success">
				<cfset count = count + 1 />
				<cfoutput>
					<div class='alert alert-success'>
						<div class='pull-right'><i class='fa fa-info'></i></div>
						#application.formtools["datetime"].oFactory.display(typename="farQueueResult",stObject=structnew(),stMetadata=stDatetime,fieldname="")#
						&nbsp;&nbsp;
						<cfif structkeyexists(aResults[i],"result") and isstruct(aResults[i].result) and structkeyexists(aResults[i].result,"message")>#aResults[i].result.message#</cfif>
						<div class='info'><pre class="formatjson">#application.fapi.formatJSON(serializeJSON(aResults[i].result))#</pre></div>
					</div>
				</cfoutput>
			</cfif>
		</cfloop>
		
		<cfif count eq 0>
			<cfoutput><div id="no-matching-results" class="alert alert-info">There are no matching results</div></cfoutput>
		</cfif>
		
		<cfoutput>
			</div>
		</cfoutput>
	</ft:form>
	
	<skin:onReady><cfoutput>
		var tick = <cfif arraylen(aResults)>#aResults[arraylen(aResults)].tick#<cfelse>0</cfif>;
		
		(function getUpdates(){
			$j.getJSON("#application.fapi.fixURL()#&action=getupdates&jobID=#url.jobID#&resultStatus=#url.resultStatus#&tick="+tick,function(results){
				newhtml = [];
				
				for (var i=0, ii=results.length; i<ii; i++){
					if (results[i].result.error)
						newhtml.unshift("<div class='alert alert-error'><div class='pull-right'><i class='fa fa-info'></i></div>" + results[i].timestamp + "&nbsp;&nbsp;" + results[i].result.error.message + "<div class='info'><pre>" + syntaxHighlight(results[i].result)+"</pre></div></div>");
					else
						newhtml.unshift("<div class='alert alert-success'><div class='pull-right'><i class='fa fa-info'></i></div>" + results[i].timestamp + "&nbsp;&nbsp;" + (results[i].result.message ? results[i].result.message : "")  + "<div class='info'><pre>" + syntaxHighlight(results[i].result)+"</pre></div></div>");
				}
				
				if (results.length){
					$j("##no-matching-results").remove();
					$j("div.results").preppend(newhtml.join(""));
					tick = results[results.length-1].tick;
				}
				
				setTimeout(getUpdates,500);
			});
		})();
		
		$j("div.results").on("click",".fa-info",function(){
			$j(this).closest(".alert").find(".info").toggle();
		});
	</cfoutput></skin:onReady>
	
</cfif>

<cfsetting enablecfoutputonly="false">