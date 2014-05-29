<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Dashboard Clock --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-dashboard-card-small --->
<!--- @@cardHeight: 200px --->
<!--- @@seq: 1 --->

<cfset stJava = createObject("java", "java.lang.System").getProperties() />
<cfset utcNow = dateConvert("local2UTC", now()) />
<cfset utcDateTime = dateFormat(utcNow, "yyyy-mm-dd") & " " & timeFormat(utcNow, "hh:mm:ss") & " +0000" />

<!--- TODO: switch between server/user date time --->

<!--- 24 or 12 hour clock --->
<cfset b12Hour = false />
<cfset shortTime = lsTimeFormat(now(), "short") />
<cfif reFind("(AM|PM)", shortTime)>
	<cfset b12Hour = true />
	<cfset shortTime = timeFormat(shortTime, "H:MM") />
</cfif>

	
<cfoutput>

<div style="padding: 0 6px; color: ##999;">
	<i id="fc-clock-utc" class="fa fa-clock-o" data-serverdatetime="#utcDateTime#"></i>
	<span id="fc-clock-day">#dateFormat(now(), "dddd")#</span>,
	<span id="fc-clock-date">#dateFormat(now(), "d mmmm yyyy")#</span>
</div>
<cfif b12Hour>
	<div style="padding: 40px 4px 20px 4px; font-size: 56px; line-height: 1;">
		<span id="fc-clock-time">#shortTime#</span><span id="fc-clock-ampm" style="font-size: 40%; padding-left:5px">#timeFormat(shortTime,'tt')#</span>
	</div>
<cfelse>
	<div style="padding: 30px 4px 10px 4px; font-size: 74px; line-height: 1;">
		<span id="fc-clock-time">#shortTime#</span>
	</div>
</cfif>
<div style="padding: 20px 6px 0 6px; color: ##999; overflow:hidden; white-space:nowrap; text-overflow:ellipsis;">
	<i class="fa fa-globe"></i> <span style="font-size:11px; text-transform:uppercase">#stJava["user.timezone"]#</span>
</div>
<script type="text/javascript">
	(function(){
		var nextMinute = function() {
			return 60000 - (new Date().getTime() % 60000);
		};
		var updateClock = function() {
			moment.lang(['#session.dmProfile.locale#', 'en']);
			$j("##fc-clock-day").html(moment().format("dddd"));
			$j("##fc-clock-time").html(moment().startOf("minute").format("h:mm"));
			$j("##fc-clock-ampm").html(moment().format("A"));
			$j("##fc-clock-date").html(moment().format("D MMMM YYYY"));
			setTimeout(updateClock, nextMinute());
		};
		updateClock();
		var timeout = setTimeout(updateClock, nextMinute());
	})();
</script>
</cfoutput>

<cfsetting enablecfoutputonly="false" />