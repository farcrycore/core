<cfcomponent displayname="Daemon Courses" extends="rules" hint="Provides links and summarys of daemon training courses">

<cfproperty name="dsn" type="string" hint="The DSN of the server that contains the regatron database" required="No" default="regatron">
<cfproperty name="displayMethod" type="string" hint="Note that the display methods are contained within the execute method of this CFC" required="yes" default="DisplayTeaserSidebar">
<cfproperty name="intro" type="string" hint="An introduction to this feed" required="no" default="">
<cfproperty name="lCourseIDs" type="string" hint="A list of courses to filer results by" required="no" default="">
<cfproperty name="maxItemsPerCourse" type="numeric" hint="The maximum number of future course dates to display per course" required="no" default="4">
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfimport taglib="/fourq/tags/" prefix="q4">
		<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
		<cfparam name="form.lCourseIDs" default="">
		<cfset stObj = this.getData(arguments.objectid)> 
				
		<cfif isDefined("form.updateRuleDaemonCourse")>
			
			<cfscript>
				stObj.lCourseIDs = form.lCourseIDs; 
				stObj.intro = form.intro;
				stObj.maxItemsPerCourse = form.maxItemsPerCourse;
				stObj.displayMethod = form.displayMethod;
			</cfscript>
			<q4:contentobjectdata typename="#application.packagepath#.rules.ruleDaemonCourses" stProperties="#stObj#" objectID="#stObj.objectID#">
			<cfset message = "Update Successful">
		</cfif>
		<cfif isDefined("message")>
			<div align="center"><strong>#message#</strong></div>
		</cfif>	
		<cfoutput>
		<form action="" method="post">
		<table width="100%" >
		<input type="hidden" name="ruleID" value="#stObj.objectID#">
		<tr>
			<td align="right">
				<b>Display Method</b>		
			</td>
			<td>
				<select name="displayMethod" class="field">
					<option name="displayMethod" value="DisplayTeaserSidebar"
					<cfif NOT comparenocase(stObj.DisplayMethod,"DisplayTeaserSidebar")>selected</cfif>>Display Teaser Sidebar
						<option name="displayMethod" value="DisplayFullInfo"
					<cfif NOT comparenocase(stObj.DisplayMethod,"DisplayFullInfo")>selected</cfif>>Display Full Info
				</select>
			</td>
		</tr>
		<tr>
			<td align="right">
				<strong>Intro</strong>
			</td>
			<td>
				<textarea rows="5" cols="50" class="field" name="intro">#stObj.intro#</textarea>
			</td>
		</tr>
		</cfoutput>		
		<tr>
			<td align="right">
				<b>Courses</b>
			</td>
			<td>
				<cfquery name="qCourses" datasource="Regatron" dbtype="ODBC">
					SELECT * FROM course
					WHERE courseDeleted=0
					ORDER BY courseName
				</cfquery>
				<select name="lCourseIds" class="field" size="5"  multiple>
					<option value="">all
					<cfoutput query="qCourses">
						<option value="#qCourses.courseid#"<cfif ListContainsNoCase(stObj.lCourseIds, qCourses.courseId )>selected</cfif>
		>#qCourses.coursename#
					</cfoutput>
				</select>
			</td>
		</tr>
		<tr>
			<td align="right">
				<strong>Max Number of items displayed per course</strong>
			</td>
			<td>
				<cfoutput>
				<select name="maxItemsPerCourse">
				<cfloop from="1" to="20" index="i">
					<option value="#i#" <cfif i EQ stObj.maxItemsPerCourse>Selected</cfif>>#i#</option>
				</cfloop>
				</select>
				</cfoutput>
			</td>
		</tr>

		<tr>
			<td colspan="2" align="center"><input class="normalbttnstyle" type="submit" value="go" name="updateRuleDaemonCourse"></td>
		</tr>
		</table>
		
		</form>
	</cffunction> 
	

	<cffunction access="public" name="execute" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		
		
		
		<cfset stObj = this.getData(arguments.objectid)> 
		
		<cfparam name="stObj.LCOURSEIDS" default="">
		<cfparam name="stObj.maxdisplay" default="6">
		<cfparam name="stObj.displayMethod" default="">

		<cfif len(trim(stObj.LCOURSEIDS)) gt 0>
			<cfset coursePart=" courseId in (#stObj.LCOURSEIDS#)">
		<cfelse>
			<cfset coursePart=" 1=1 ">
		</cfif>

		<cfquery name="qCourses" datasource="Regatron" dbtype="ODBC">
			SELECT * FROM course
			WHERE courseDeleted=0
			AND #coursePart#
			ORDER BY courseName
		</cfquery>

		<cfif comparenocase(stObj.displayMethod,"DisplayTeaserSidebar") eq 0>
		<cfoutput>
		<table border=0 cellpadding=0 cellspacing=2>
		<tr>
			<td >&nbsp;Course Dates</td>
		</tr>
		<tr>
			<td>
			<table class="sidebarBody">
				<tr>
				<td>
					<table border=0 cellpadding=0 cellspacing=0 class="side"></cfoutput>
						<cfloop query="qCourses">
						<cfoutput>
						<tr><td colspan=3 class="sidebarContentHeader">#qCourses.coursename#</td></tr>
						</cfoutput>
						<cfquery name="qEvents" datasource="Regatron" dbtype="ODBC">
						SELECT * FROM event, location
						WHERE eventDeleted=0
						AND event.courseid=#qCourses.courseid#
						AND location.locationId=event.locationId
						AND event.eventStartDate > getDate()
						ORDER BY eventStartDate
						</cfquery>
						<cfif stObj.MaxDisplay le 0>
							<cfset endrow=qEvents.recordCount>
						<cfelse>
							<cfset endrow=stObj.MaxDisplay>
						</cfif>
		
						<cfloop query="qEvents" startrow="1" endrow="#endrow#">
							<cfoutput>
								<tr>
								<td class="">
									#DateFormat(qEvents.eventStartDate,'DD')#&nbsp;#DateFormat(qEvents.eventStartDate,'MMM')#
								</td>
								<td class="">
									&nbsp;#qEvents.locationName#&nbsp;
								</td>
								<td>
									<a href="/regatron/registerStep1.cfm?eventid=#qEvents.eventId#">
									Register</a>
								</td>
								</tr>
							</cfoutput>
						</cfloop>
						<cfif qEvents.recordCount eq 0>
							<cfoutput>
								<tr>
									<td colspan=3 class="sidebarContentText">
										Course dates to be determined
									</td>
								</tr>
							</cfoutput>
						<cfelse>
							<!--- <cfoutput>
								<tr>
									<td colspan=3 class="sidebarContentText">
									<a href="display.cfm?objectid=#application.navid.coursedates###course#qCourses.courseId#" style="color: ##66CC00;">[All Dates]
									</td>
								</tr>
							</cfoutput> --->
						</cfif>
					<cfoutput><tr><td colspan=3 class="sidebarContentText">&nbsp;</td></tr></cfoutput>
					</cfloop>
					<cfoutput>
					</table>
					</td>
					</tr>
					</table>
				</td>
			</tr>
		</table> 
		</cfoutput>
		</cfif>
		<cfif comparenocase(stObj.displayMethod,"DisplayFullInfo") eq 0>
		<cfoutput><table border="0" cellspacing="3" width="70%" class="table"></cfoutput>

		<cfloop query="qCourses">
		<cfoutput>
			<tr>
				<td colspan="4" class="teaserHeader" bgcolor="cccccc">
				#qCourses.coursename#<A name="course#qCourses.courseid#"></a>
				</td>
			
			</tr>
		</cfoutput>
		<cfquery name="qEvents" datasource="Regatron" dbtype="ODBC">
		SELECT * FROM event, location, instructor
			WHERE eventDeleted=0
				AND event.courseid=#qCourses.courseid#
				AND location.locationId=event.locationId
				AND event.instructorid=instructor.instructorid
				AND event.eventStartDate > getDate()
			ORDER BY eventStartDate
		</cfquery>
		<cfoutput>
		<tr>
			<td><i>Date</i></td>
			<td><i>Location</i></td>
			<td><i>Instructor</i></td>
			<td><i>Register</i></td>
		</tr>
		</cfoutput>
		
		<cfif stObj.MaxDisplay le 0>
			<cfset endrow=qEvents.recordCount>
		<cfelse>
			<cfset endrow=stObj.MaxDisplay>
		</cfif>
		<cfloop query="qEvents" startrow="1" endrow="#endrow#">
		<cfoutput>
			<tr>
			<td class="teaserText">#DateFormat(qEvents.eventStartDate,'DDDD DD MMMM')#</td>
			<td class="teaserText">&nbsp;#qEvents.locationName#&nbsp;</td>
			<td class="teaserText">&nbsp;#qEvents.instructorfirstname#&nbsp;#qEvents.instructorlastname#&nbsp;</td>
			<td>
				<a href="/regatron/registerStep1.cfm?eventid=#qEvents.eventId#" class="teaserText">
				Register
				</a>
			</td>
			</tr>
			</cfoutput>
		</cfloop>
		<cfif qEvents.recordCount eq 0>
			<cfoutput><tr><td colspan=4 class="teaserText">Course dates to be determined</td></tr></cfoutput>
		</cfif>
		<cfoutput><tr><td colspan=4 class="teaserText">&nbsp;</td></tr></cfoutput>
		</cfloop>
		<cfoutput></table></cfoutput>
		</cfif>
	</cffunction>


</cfcomponent>
