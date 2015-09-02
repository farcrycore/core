<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Application Lifecycle --->
<!--- @@seq: 10000 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfif isdefined("application.fcstats.updateapp")>
	<ft:field label="Last Restart" bMultiField="true" hint="The time of the most recent application restart">
		<cfoutput>#lcase(timeformat(application.fcstats.updateapp.when[application.fcstats.updateapp.recordcount],"h:mmtt"))#, #dateformat(application.fcstats.updateapp.when[application.fcstats.updateapp.recordcount],"dddd d mmmm yyyy")#</cfoutput>
	</ft:field>
</cfif>

<ft:field label="Total Restarts" bMultiField="true" hint="The number of times this application has been restarted since the CFML engine started">
	<cfif isdefined("application.fcstats.updateapp")><cfoutput>#application.fcstats.updateapp.recordcount#</cfoutput><cfelse>0</cfif>
</ft:field>

<cfif isdefined("application.fcstats.updateapp")>
	<ft:field label="Startup Performance" bMultiField="true" hint="How long the application took to start up on each updateapp">
		<cfoutput>
			<cfset chartAttributes = structNew()>
			<cfset chartAttributes.categoryLabelPositions = "vertical">
			<cfchart format="png" xaxistitle="Startup Date/Time" yaxistitle="Application Startup (ms)" chartwidth="500" chartheight="300" attributeCollection="#chartAttributes#">
				<cfchartseries type="line" query="application.fcstats.updateapp" itemcolumn="when" valuecolumn="howlong">
				</cfchartseries>
			</cfchart>
			<br>
			<strong>Average: #round(arrayAvg(listToArray(valueList(application.fcstats.updateapp.howlong))))#ms</strong>
			(Min: #round(arrayMin(listToArray(valueList(application.fcstats.updateapp.howlong))))#ms, 
			Max: #round(arrayMax(listToArray(valueList(application.fcstats.updateapp.howlong))))#ms)
		</cfoutput>
	</ft:field>
</cfif>

<cfsetting enablecfoutputonly="false">