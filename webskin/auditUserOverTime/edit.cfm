<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="ReportingAuditTab">
	
	<ft:processform action="Filter">
		<ft:processformobjects typename="auditUserOverTime" r_stObject="stObj" />
	</ft:processform>

	<cfoutput>
		<h2>#application.rb.getResource("coapi.auditUserOverTime.general.useractivityovertime@heading","User activity over time")#</h2>
	</cfoutput>

	<ft:form>
		<ft:object typename="auditUserOverTime" stObject="#stObj#" />
		
		<ft:buttonPanel>
			<ft:button value="Filter" />
		</ft:buttonPanel>
	</ft:form>
	
	<cfset oLog = createObject("component", application.stcoapi["farLog"].packagePath)>
	
	<cfif stObj.period eq "day">		
		<cfchart 
			chartHeight="400" 
			chartWidth="600" 
			scaleFrom="0" 
			showXGridlines = "yes" 
			showYGridlines = "yes"
			seriesPlacement="default"
			showBorder = "no"
			fontsize="12"
			labelFormat = "number"
			xAxisTitle = "#application.rb.getResource('coapi.auditUserOverTime.general.hour@label','Hour')#" 
			yAxisTitle = "#application.rb.getResource('coapi.auditUserOverTime.general.activity@label','Activity')#" 
			show3D = "yes"
			rotated = "no" 
			showLegend = "yes" 
			tipStyle = "MouseOver">
			
			<cfloop from="1" to="#stObj.noperiods#" index="i">
				<cfif len(stObj.typeevent)>
					<cfset result = oLog.getUserActivityDaily(day=now()-(i-1),type=listfirst(stObj.typeevent,"."),event=listlast(stObj.typeevent,".")) />
				<cfelse>
					<cfset result = oLog.getUserActivityDaily(day=now()-(i-1)) />
				</cfif>
				<cfchartseries type="bar" query="result" itemcolumn="hour" valuecolumn="total" serieslabel="#lsdateformat(now()-(i-1))#" paintstyle="shade"></cfchartseries>
			</cfloop>

		</cfchart>
		
	<cfelse>
		<!--- i18n: get week starts for later use --->
		<cfset weekStartDay=application.thisCalendar.weekStarts(session.dmProfile.locale) />
		
		<cfchart 
			format="flash" 
			chartHeight="400" 
			chartWidth="600" 
			scaleFrom="0" 
			showXGridlines = "yes" 
			showYGridlines = "yes"
			seriesPlacement="default"
			showBorder = "no"
			fontsize="12"
			labelFormat = "number"
			xAxisTitle = "#application.rb.getResource('coapi.auditUserOverTime.general.hour@label','Day')#" 
			yAxisTitle = "#application.rb.getResource('coapi.auditUserOverTime.general.activity@label','Activity')#" 
			show3D = "yes"
			rotated = "no" 
			showLegend = "yes" 
			tipStyle = "MouseOver">
				
			<cfloop from="0" to="#stObj.noperiods-1#" index="i">
				<!--- loop over days in week --->
				<cfloop from="1" to="7" index="day">
					<!--- check if day is a sunday (ie start of week) --->
					<cfif dayofweek(dateadd("d",-day,dateadd("ww",-i,now()))) eq weekStartDay>
						<!--- if it is sunday, set startdate for that week --->
						<cfif len(stObj.typeevent)>
							<cfset result = oLog.getUserActivityWeekly(day=dateadd("d",-day,dateadd("ww",-i,now())),type=listfirst(stObj.typeevent,"."),event=listlast(stObj.typeevent,".")) />
						<cfelse>
							<cfset result = oLog.getUserActivityWeekly(day=dateadd("d",-day,dateadd("ww",-i,now()))) />
						</cfif>
						<cfchartseries type="bar" query="result" itemcolumn="name" valuecolumn="total" serieslabel="#application.rb.formatRBString('coapi.auditUserOverTime.general.weekbeginning@label',lsdateformat(dateadd('d',-day,dateadd('ww',-i,now()))),'Week beginning {1}')#" paintstyle="shade"></cfchartseries>
					</cfif>
				</cfloop>
			</cfloop>
			
		</cfchart>
		
	</cfif>
	
</sec:CheckPermission>

<admin:footer />

<cfsetting enablecfoutputonly="false" />