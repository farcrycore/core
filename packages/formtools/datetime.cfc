<!--- 	
	@@examples:
	<p>Basic</p>
	<code>
		<cfproperty
			name="basicDate" type="date" hint="something meaningful" required="no" default=""
			ftseq="1" ftfieldset="General" ftwizardStep="General Details"
			ftType="datetime" ftlabel="Basic Date" />
	</code>

	<p>Default to todays date</p>
	<code>
		<cfproperty
			name="someDate" type="date" hint="The start date of the event" required="no" default=""
			ftseq="2" ftfieldset="General" ftwizardStep="General Details"
			ftDefaultType="Evaluate" ftDefault="now()" ftType="datetime" ftlabel="Some Date" />
	</code>

	<p>Custom date and time format mask</p>
	<code>
		<cfproperty
			name="someDate" type="date" hint="The start date of the event" required="no" default=""
			ftseq="3" ftfieldset="General" ftwizardStep="General Details"
			ftType="datetime" ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" 
			ftlabel="Some Date" />
	</code>

	<p>Show date only</p>
	<code>
		<cfproperty
			name="dateOnly" type="date" hint="The start date of the event" required="no" default=""
			ftseq="4" ftfieldset="General" ftwizardStep="General Details"
			ftType="datetime" ftShowTime="false" ftlabel="Date Only" />
	</code>

	<p>Disable dateTime field by default</p>
	<code>
		<cfproperty
			name="someDate" type="date" hint="The start date of the event" required="no" default=""
			ftseq="5" ftfieldset="General" ftwizardStep="General Details"
			ftType="datetime" ftToggleOffDateTime="true" ftlabel="Some Date" />
	</code>
	
	<p>Datetime to be automatically set to the other field's date value.</p>
	<code>
		<cfproperty
			name="endDate" type="date" hint="The start date of the event" required="no" default=""
			ftseq="5" ftfieldset="General" ftwizardStep="General Details"
			ftType="datetime" ftlabel="Some Date" ftWatch="startDate"/>
	</code>
 --->

<cfcomponent name="datetime" extends="field" displayname="datetime" bDocument="true" hint="Field component to liase with all datetime types"> 

	<!--- edit handler options --->
	<cfproperty name="ftRenderType" default="jquery" hint="This formtool offers a number of ways to render the input. (dropdown, jquery, input)" />
	<cfproperty name="ftToggleOffDateTime" default="false" hint="Provides an optional toggle to hide the date if its not required" />
	<cfproperty name="ftDateFormatMask" default="d mmm yyyy" hint="Coldfusion mask for date for edit handler" />
	<cfproperty name="ftStartYearShift" default="0" hint="Used when ftRenderType is set to dropDown, sets start of year range in select list." />
	<cfproperty name="ftEndYearShift" default="-100" hint="Used when ftRenderType is set to dropDown, sets end of year range in select list." />
	<cfproperty name="ftStartYear" default="" hint="Used when ftRenderType is set to dropDown, sets the value of the first year in year range." />
	<cfproperty name="ftEndYear" default="" hint="Used when ftRenderType is set to dropDown,, sets the value of the last year in year range. " />
	<cfproperty name="ftShowTime" default="true" hint="Display time portion of dateTime field." />

	<!--- display handler options --->
	<cfproperty name="ftDateMask" default="d-mmm-yy" hint="Coldfusion date mask for display handler." />
	<cfproperty name="ftTimeMask" default="short" hint="Coldfusion time mask for display handler." />

	<cfproperty name="ftDisplayPrettyDate" default="true" hint="Converts SQL dateTime value to human readable string" />
				

	<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" >	
		
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.datetime" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="reParse" access="public" output="false" returntype="any" hint="Uses regular expression back references to parse values out of a string">
		<cfargument name="pattern" type="string" required="true" hint="The regular expression to use" />
		<cfargument name="haystack" type="string" required="true" hint="The string to search" />
		<cfargument name="fields" type="string" required="true" hint="The names of the fields defined in the pattern, in order" />
		<cfargument name="returnall" type="boolean" required="false" default="false" hint="Set to true to process every instance of the pattern" />
		
		<cfset var aMatches = arraynew(1) />
		<cfset var stResult = structnew() />
		<cfset var aResult = arraynew(1) /><!--- Only used if returnall is true --->
		<cfset var i = 0 />
		
		<cfset aMatches = refindnocase(arguments.regex,arguments.haystack,1,true) />
		<cfif arraylen(aMatches)>
			<cfset stResult = structnew() />
			<cfloop from="2" to="#aMatches.pos#" index="i">
				<cfset stResult[listgetat(arguments.fields,i-1)] = mid(arguments.haystack,aMatches.pos[i],aMatches.len[i]) />
			</cfloop>
			<cfset arrayappend(aResult,stResult) />
		</cfif>
		
		<cfif arguments.returnall>
			<cfloop condition="arraylen(aMatches)">
				<cfset aMatches = refindnocase(arguments.regex,arguments.haystack,aMatches.pos[1]+aMatches.len[1],true) />
				<cfif arraylen(aMatches)>
					<cfset stResult = structnew() />
					<cfloop from="2" to="#aMatches.pos#" index="i">
						<cfset stResult[listgetat(arguments.fields,i-1)] = mid(arguments.haystack,aMatches[i].pos,aMatches[i].len) />
					</cfloop>
				</cfif>
				<cfset arrayappend(aResult,stResult) />
			</cfloop>
		</cfif>
		
		<cfif arguments.returnall>
			<cfreturn aResult />
		<cfelse>
			<cfreturn stResult />
		</cfif>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var fieldStyle = "">
		<cfset var ToggleOffDateTimeJS = "" />
		<cfset var html = "" />
		<cfset var bfieldvisible = "" />
		<cfset var fieldvisibletoggletext = "" />
		<cfset var locale = "">
		<cfset var localeMonths = "">
		<cfset var i = "">
		<cfset var step=1>
		<cfset var jsDateFormatMask = "">
		
		<cfif structkeyexists(arguments.stMetadata,"ftWatch") and len(arguments.stMetadata.ftWatch) and isDate(arguments.stObject[arguments.stMetadata.ftWatch]) and isDate(arguments.stMetadata.value)>
			<cfif DateCompare(arguments.stObject[arguments.stMetadata.ftWatch], arguments.stMetadata.value) eq 1>
				<cfset arguments.stMetadata.value = arguments.stObject[arguments.stMetadata.ftWatch]>
			</cfif>
		</cfif>

		<!--- If a required field, then the user will not have the option to toggle off the date time --->
		<cfif structkeyexists(arguments.stMetadata,"ftValidation") and listcontains(arguments.stMetadata.ftValidation,"required")>
			<cfset arguments.stMetadata.ftToggleOffDateTime = "0" />
		</cfif>
		
		<cfif isDate(arguments.stMetadata.value)>
			<cfset arguments.stMetadata.value = application.fapi.convertToApplicationTimezone(arguments.stMetadata.value) />
		</cfif>
		
			
		<cfif arguments.stMetadata.ftToggleOffDateTime>
			
			<skin:onReady>
			<cfoutput>	
			<cfif application.fapi.showFarcryDate(arguments.stMetadata.value) >
				$j("###arguments.fieldname#include").prop('checked', true);
			<cfelse>
				$j("###arguments.fieldname#-wrap").hide();
				$j("###arguments.fieldname#").val('');
			</cfif>
			
			$j("###arguments.fieldname#include").on("click", function() {
				if ($j("###arguments.fieldname#include").prop('checked')) {	
					$j("###arguments.fieldname#-wrap").show("slow");				
				} else {					
					$j("###arguments.fieldname#-wrap").hide("slow");
				}				
			});
			</cfoutput>
			</skin:onReady>
		</cfif>		
		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
		
		<cfcase value="dropdown">
			<cfif not isdefined("arguments.stMetadata.ftStartYear") or not len(arguments.stMetadata.ftStartYear)>
				<cfset arguments.stMetadata.ftStartYear = year(now()) + arguments.stMetadata.ftStartYearShift />
			</cfif>
			<cfif not isdefined("arguments.stMetadata.ftEndYear") or not len(arguments.stMetadata.ftEndYear)>
				<cfset arguments.stMetadata.ftEndYear = year(now()) + arguments.stMetadata.ftEndYearShift />
			</cfif>
			
			<cfif arguments.stMetadata.ftStartYear gt arguments.stMetadata.ftEndYear>
				<cfset step=-1 />
			</cfif>
			
			<cfif isDefined("session.dmProfile.locale") AND len(session.dmProfile.locale)>
				<cfset locale = session.dmProfile.locale>
			<cfelse>
				<cfset locale = "en_AU">
			</cfif>			
			
			<cfset localeMonths = createObject("component", "/farcry/core/packages/farcry/gregorianCalendar").getMonths(locale) />
	
			<cfsavecontent variable="html">
				<cfoutput>
				<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateFormatMask)#" />
				<input type="hidden" name="#arguments.fieldname#rendertype" id="#arguments.fieldname#rendertype" value="#arguments.stMetadata.ftRenderType#">
				
				<div class="multiField">
					<cfif arguments.stMetadata.ftToggleOffDateTime>
						<cfoutput>
						<label class="inlineLabel" for="#arguments.fieldname#include">
							<input type="checkbox" name="#arguments.fieldname#include" id="#arguments.fieldname#include" class="checkboxInput" value="1" >
							<input type="hidden" name="#arguments.fieldname#include" value="0">
							Include Date
						</label>
						</cfoutput>
					</cfif>
					
					<div id="#arguments.fieldname#-wrap">
							Day 
						<select name="#arguments.fieldname#Day" id="#arguments.fieldname#Day" class="selectInput <cfif structkeyexists(arguments.stMetadata,"ftValidation") and listcontains(arguments.stMetadata.ftValidation,"required")>required</cfif>" style="float:none;width:auto;">
							<option value="">--</option>
							<cfloop from="1" to="31" index="i">
								<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Day(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#i#</option>
								</cfloop>
						</select>
						
							Month 
						<select name="#arguments.fieldname#Month" id="#arguments.fieldname#Month" class="selectInput <cfif structkeyexists(arguments.stMetadata,"ftValidation") and listcontains(arguments.stMetadata.ftValidation,"required")>required</cfif>" style="float:none;width:auto;">
								<option value="">--</option>
								<cfloop from="1" to="12" index="i">
									<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Month(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#localeMonths[i]#</option>
								</cfloop>
							</select>	
						
							Year 				
						<select name="#arguments.fieldname#Year" id="#arguments.fieldname#Year" class="selectInput <cfif structkeyexists(arguments.stMetadata,"ftValidation") and listcontains(arguments.stMetadata.ftValidation,"required")>required</cfif>" style="float:none;width:auto;">
								<option value="">--</option>
								<cfloop from="#arguments.stMetadata.ftStartYear#" to="#arguments.stMetadata.ftEndYear#" index="i" step="#step#">
									<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Year(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#i#</option>
								</cfloop>
							</select>
					</div>					
				</div>
				</cfoutput>
			</cfsavecontent>		
			
			<cfreturn html>
		</cfcase>
	
		<cfdefaultcase>
			
			<cfparam name="arguments.stMetadata.ftShowTime" default="true">
			<cfparam name="arguments.stMetadata.ftMaxDate" default="" />
			<cfparam name="arguments.stMetadata.ftMinDate" default="" />
			
			<cfif arguments.stMetadata.ftRenderType neq "input">
				<!--- load jquery-ui before bootstrap-datepicker so that bootstrap-datepicker overwrites it --->
				<skin:loadJS id="fc-jquery" />
				<skin:loadJS id="fc-jquery-ui" />
				<skin:loadJS id="fc-bootstrap" />
				<skin:loadJS id="bootstrap-datepicker" />
				<skin:loadCSS id="bootstrap-datepicker" />
			</cfif>
			
			
			<cfif isDefined("session.dmProfile.locale") AND len(session.dmProfile.locale)>
				<cfset locale = session.dmProfile.locale>
			<cfelse>
				<cfset locale = "en_AU">
			</cfif>			
			
			
			<cfsavecontent variable="html">

				<cfoutput>
				
				
				<div class="multiField">
					<cfif arguments.stMetadata.ftToggleOffDateTime>
						<cfoutput>
						<label class="inlineLabel" for="#arguments.fieldname#include">
						
							<input type="checkbox" name="#arguments.fieldname#include" id="#arguments.fieldname#include" value="1" class="checkboxInput">
							<input type="hidden" name="#arguments.fieldname#include" value="0">
							Include
						</label>	
						</cfoutput>
					</cfif>
					
					<div id="#arguments.fieldname#-wrap">

<!--- TODO: rip out. hard coded stuff is bad --->
						<cfif application.fapi.getDefaultFormTheme() eq "bootstrap">
							<div class="input-prepend">
								<span class="add-on"><i class="fa fa-calendar-o"></i></span>
								<input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateFormatMask)#" class="datepicker fc-datepicker #arguments.inputClass# #arguments.stMetadata.ftClass#" style="#arguments.stMetadata.ftStyle#" >
							</div>
						<cfelse>
							<input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateFormatMask)#" class="datepicker fc-datepicker #arguments.inputClass# #arguments.stMetadata.ftClass#" style="#arguments.stMetadata.ftStyle#" >
						</cfif>

						<input type="hidden" name="#arguments.fieldname#rendertype" id="#arguments.fieldname#rendertype" value="#arguments.stMetadata.ftRenderType#">

						<cfif arguments.stMetadata.ftRenderType neq "input">
							<!--- convert CF date masks into masks that will work with bootstrap-datepicker --->
							<cfset jsDateFormatMask = arguments.stMetadata.ftDateFormatMask>
							<cfset jsDateFormatMask = replace(jsDateFormatMask, "dddd", "DD")>
							<cfset jsDateFormatMask = replace(jsDateFormatMask, "ddd", "D")>
							<cfset jsDateFormatMask = replace(jsDateFormatMask, "mmmm", "MM")>
							<cfset jsDateFormatMask = replace(jsDateFormatMask, "mmm", "M")>

							<skin:onReady>
								<cfoutput>
									$j('###arguments.fieldname#').datepicker({
									    format: '#jsDateFormatMask#',
									    autoclose: true
									});
								</cfoutput>
							</skin:onReady>
						</cfif>

						<cfif arguments.stMetadata.ftShowTime>
							<select class="fc-time" name="#arguments.fieldname#Hour">
							<cfloop from="1" to="12" index="i">
								<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND TimeFormat(arguments.stMetadata.value,'h') EQ i> selected="selected"</cfif>>#i#</option>
							</cfloop>
							</select>
							<select class="fc-time" name="#arguments.fieldname#Minute">
								<option value="00">00</option>
								<cfloop from="1" to="60" index="i">
									<option value="#numberFormat(i, '00')#"<cfif isDate(arguments.stMetadata.value) AND TimeFormat(arguments.stMetadata.value,'m') EQ i> selected="selected"</cfif>>#numberFormat(i, '00')#</option>
								</cfloop>
							</select>
							<select class="fc-time" name="#arguments.fieldname#Period">
								<option value="AM"<cfif isDate(arguments.stMetadata.value) AND TimeFormat(arguments.stMetadata.value,'tt') EQ "AM"> selected="selected"</cfif>>AM</option>
								<option value="PM"<cfif isDate(arguments.stMetadata.value) AND TimeFormat(arguments.stMetadata.value,'tt') EQ "PM"> selected="selected"</cfif>>PM</option>
							</select>
						</cfif>
						&nbsp;
					</div>	
						
								
				</div>
				</cfoutput>
			</cfsavecontent>		
			
			<cfreturn html>
		</cfdefaultcase>	
		

		</cfswitch>
		

	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var renderDate = "" />
		
		
		
		<cfif isDate(arguments.stMetadata.value)>
			<cfset arguments.stMetadata.value = application.fapi.convertToApplicationTimezone(arguments.stMetadata.value) />
		</cfif>
		
		
		<cfparam name="arguments.stMetadata.ftDateMask" default="d-mmm-yy">
		<cfparam name="arguments.stMetadata.ftTimeMask" default="short">
		<cfparam name="arguments.stMetadata.ftShowTime" default="true">
		<cfparam name="arguments.stMetadata.ftDisplayPrettyDate" default="true">
		
		
		<cfif len(arguments.stMetadata.value) and application.fapi.showFarcryDate(arguments.stMetadata.value)>
			
			<cfsavecontent variable="renderDate">
				<cfoutput>#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateMask)#</cfoutput>
				<cfif arguments.stMetadata.ftShowTime>
					<cfoutput> #TimeFormat(arguments.stMetadata.value,arguments.stMetadata.ftTimeMask)# </cfoutput>
				</cfif>
			</cfsavecontent>
			
			<cfsavecontent variable="html">
				<cfif arguments.stMetadata.ftDisplayPrettyDate>
					<cfoutput><span class="fc-prettydate" title="#renderDate#" data-datetime="#dateFormat(arguments.stMetadata.value,"yyyy-mm-dd")# #timeFormat(arguments.stMetadata.value,"HH:mm:ss")#">#application.fapi.prettyDate(arguments.stMetadata.value)#</span></cfoutput>
				<cfelse>
					<cfoutput>#renderDate#</cfoutput>
				</cfif>
				
			</cfsavecontent>				
		</cfif>
		
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		

		<cfset var stResult = passed(value="") />
		<cfset var newDate = "" />
		<cfset var newTime = "" />
		
		<cfparam name="arguments.stFieldPost.stSupporting.renderType" default="calendar">
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		
		
		
		<cfswitch expression="#arguments.stFieldPost.stSupporting.renderType#">
		
		<cfcase value="dropdown">
			
			<!--- --------------------------- --->
			<!--- Perform any validation here --->
			<!--- --------------------------- --->
			
		
			<cfif structKeyExists(arguments.stFieldPost.stSupporting,"day")
				AND structKeyExists(arguments.stFieldPost.stSupporting,"month")
				AND structKeyExists(arguments.stFieldPost.stSupporting,"year")>
				
				<cfif len(arguments.stFieldPost.stSupporting.day) OR len(arguments.stFieldPost.stSupporting.month) OR len(arguments.stFieldPost.stSupporting.year)>
					<cftry>
					
						<cfif structKeyExists(arguments.stFieldPost.stSupporting,"hour")
							AND structKeyExists(arguments.stFieldPost.stSupporting,"minute")
							AND structKeyExists(arguments.stFieldPost.stSupporting,"period")>
									
							<cfif arguments.stFieldPost.stSupporting.period EQ "PM">
								<cfset arguments.stFieldPost.stSupporting.hour = arguments.stFieldPost.stSupporting.hour + 12 />
							</cfif>
							<cfif arguments.stFieldPost.stSupporting.hour GT 24>
								<cfset arguments.stFieldPost.stSupporting.hour = 0 />
							</cfif>
							<cfset newDate = createDateTime(arguments.stFieldPost.stSupporting.year, arguments.stFieldPost.stSupporting.month, arguments.stFieldPost.stSupporting.day, arguments.stFieldPost.stSupporting.hour, arguments.stFieldPost.stSupporting.minute, 0) />

						<cfelse>					
							<cfset newDate = createDate(arguments.stFieldPost.stSupporting.year, arguments.stFieldPost.stSupporting.month, arguments.stFieldPost.stSupporting.day) />
						</cfif>
						
						<cfset stResult = passed(value="#newDate#") />
						<cfcatch type="any">
							<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="You need to select a valid date.") />
						</cfcatch>
					</cftry>
				<cfelseif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required")>
					<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is a required field") />
				</cfif>
			<cfelseif structKeyExists(arguments.stMetadata, "ftValidation") AND listFindNoCase(arguments.stMetadata.ftValidation, "required")>
				<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="This is a required field") />
			</cfif>
					
			<cfif stResult.bSuccess>
				<cfset arguments.stFieldPost.value = stResult.value />
				<cfset stResult = super.validate(objectid=arguments.objectid, typename=arguments.typename, stFieldPost=arguments.stFieldPost, stMetadata=arguments.stMetadata )>
			</cfif>	
		</cfcase>
		
		<cfdefaultcase>
			<cfparam name="arguments.stFieldPost.stSupporting.Include" default="true">
			
			<cfif ListGetAt(arguments.stFieldPost.stSupporting.Include,1) AND isDate(arguments.stFieldPost.Value)>
			
				<cftry>
					<cfif structKeyExists(arguments.stFieldPost.stSupporting,"hour")
						AND structKeyExists(arguments.stFieldPost.stSupporting,"minute")
						AND structKeyExists(arguments.stFieldPost.stSupporting,"period")>
								
						<cfif arguments.stFieldPost.stSupporting.period EQ "PM">
							<cfif arguments.stFieldPost.stSupporting.hour LT 12>
								<cfset arguments.stFieldPost.stSupporting.hour = arguments.stFieldPost.stSupporting.hour + 12 />
							</cfif>
						<cfelseif arguments.stFieldPost.stSupporting.hour EQ 12>
							<cfset arguments.stFieldPost.stSupporting.hour = 0 />
						</cfif>
						<cfif arguments.stFieldPost.stSupporting.hour GTE 24>
							<cfset arguments.stFieldPost.stSupporting.hour = 0 />
						</cfif>
						<cfset newTime = timeFormat(createTime(arguments.stFieldPost.stSupporting.hour, arguments.stFieldPost.stSupporting.minute, 0), 'hh:mm:ss tt') />
					</cfif>
							
					<cfset newDate = CreateODBCDateTime("#DateFormat(arguments.stFieldPost.Value,arguments.stMetadata.ftDateFormatMask)# #newTime#") />
					<cfset stResult = passed(value="#newDate#") />
					<cfcatch type="any">
						<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="You need to select a valid date.") />
					</cfcatch>
				</cftry>
				
			<cfif stResult.bSuccess>
				<cfset arguments.stFieldPost.value = stResult.value />
				<cfset stResult = super.validate(objectid=arguments.objectid, typename=arguments.typename, stFieldPost=arguments.stFieldPost, stMetadata=arguments.stMetadata )>
			</cfif>
				
			<cfelse>
				<cfset newDate = "" />
				<cfset stResult = passed(value="#newDate#") />
			</cfif>
		</cfdefaultcase>
		</cfswitch>
				
		<!--- If we have a valid date, convert it to the system date. --->
		<cfif isDate(stResult.value)>
			<cfset stResult.value = application.fapi.convertToSystemTimezone(stResult.value) />
		</cfif>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>

		
	</cffunction>


	<cffunction name="getFilterUIOptions">
		<cfreturn "before,after,between,more than,less than,is within" />
	</cffunction>
	
	<cffunction name="editFilterUI">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="false" type="struct" hint="Contains the metadata for the all fields for the current typename.">
				
		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="before">
					<cfparam name="arguments.stFilterProps.before" default="" />
					<cfoutput>
					<input type="string" name="#arguments.fieldname#before" value="#dateFormat(arguments.stFilterProps.before)#" />
					</cfoutput>
				</cfcase>
				
				<cfcase value="after">
					<cfparam name="arguments.stFilterProps.after" default="" />
					<cfoutput>
					<input type="string" name="#arguments.fieldname#after" value="#dateFormat(arguments.stFilterProps.after)#" />
					</cfoutput>
				</cfcase>
				
				<cfcase value="between">
					<cfparam name="arguments.stFilterProps.from" default="" />
					<cfparam name="arguments.stFilterProps.to" default="" />
					<cfoutput>
					<input type="string" name="#arguments.fieldname#from" value="#dateFormat(arguments.stFilterProps.from)#" />
					<input type="string" name="#arguments.fieldname#to" value="#dateFormat(arguments.stFilterProps.to)#" />
					</cfoutput>
				</cfcase>
				

				
				<cfcase value="more than,less than">
					<cfparam name="arguments.stFilterProps.datepart" default="1:d" />
					<cfoutput>
					<select name="#arguments.fieldname#datepart">
						<option value="1:d" <cfif arguments.stFilterProps.datepart EQ "1:d">selected="selected"</cfif>>1 day</option>
						<option value="2:d" <cfif arguments.stFilterProps.datepart EQ "2:d">selected="selected"</cfif>>2 days</option>
						<option value="3:d" <cfif arguments.stFilterProps.datepart EQ "3:d">selected="selected"</cfif>>3 days</option>
						<option value="4:d" <cfif arguments.stFilterProps.datepart EQ "4:d">selected="selected"</cfif>>4 days</option>
						<option value="5:d" <cfif arguments.stFilterProps.datepart EQ "5:d">selected="selected"</cfif>>5 days</option>
						<option value="6:d" <cfif arguments.stFilterProps.datepart EQ "6:d">selected="selected"</cfif>>6 days</option>
						<option value="1:ww" <cfif arguments.stFilterProps.datepart EQ "1:ww">selected="selected"</cfif>>1 week</option>
						<option value="2:ww" <cfif arguments.stFilterProps.datepart EQ "2:ww">selected="selected"</cfif>>2 weeks</option>
						<option value="3:ww" <cfif arguments.stFilterProps.datepart EQ "3:ww">selected="selected"</cfif>>3 weeks</option>
						<option value="1:m" <cfif arguments.stFilterProps.datepart EQ "1:m">selected="selected"</cfif>>1 month</option>
						<option value="2:m" <cfif arguments.stFilterProps.datepart EQ "2:m">selected="selected"</cfif>>2 months</option>
						<option value="3:m" <cfif arguments.stFilterProps.datepart EQ "3:m">selected="selected"</cfif>>3 months</option>
						<option value="4:m" <cfif arguments.stFilterProps.datepart EQ "4:m">selected="selected"</cfif>>4 months</option>
						<option value="5:m" <cfif arguments.stFilterProps.datepart EQ "5:m">selected="selected"</cfif>>5 months</option>
						<option value="6:m" <cfif arguments.stFilterProps.datepart EQ "6:m">selected="selected"</cfif>>6 months</option>
						<option value="7:m" <cfif arguments.stFilterProps.datepart EQ "7:m">selected="selected"</cfif>>7 months</option>
						<option value="8:m" <cfif arguments.stFilterProps.datepart EQ "8:m">selected="selected"</cfif>>8 months</option>
						<option value="9:m" <cfif arguments.stFilterProps.datepart EQ "9:m">selected="selected"</cfif>>9 months</option>
						<option value="10:m" <cfif arguments.stFilterProps.datepart EQ "10:m">selected="selected"</cfif>>10 months</option>
						<option value="11:m" <cfif arguments.stFilterProps.datepart EQ "11:m">selected="selected"</cfif>>11 months</option>
						<option value="1:yyyy" <cfif arguments.stFilterProps.datepart EQ "1:yyyy">selected="selected"</cfif>>1 year</option>
					</select>
					ago
					</cfoutput>
				</cfcase>	
				
				<cfcase value="is within">
					<cfparam name="arguments.stFilterProps.datepart" default="1:d" />
					<cfoutput>
					<select name="#arguments.fieldname#datepart">
						<option value="1:d" <cfif arguments.stFilterProps.datepart EQ "1:d">selected="selected"</cfif>>1 days</option>
						<option value="2:d" <cfif arguments.stFilterProps.datepart EQ "2:d">selected="selected"</cfif>>2 days</option>
						<option value="3:d" <cfif arguments.stFilterProps.datepart EQ "3:d">selected="selected"</cfif>>3 days</option>
						<option value="4:d" <cfif arguments.stFilterProps.datepart EQ "4:d">selected="selected"</cfif>>4 days</option>
						<option value="5:d" <cfif arguments.stFilterProps.datepart EQ "5:d">selected="selected"</cfif>>5 days</option>
						<option value="6:d" <cfif arguments.stFilterProps.datepart EQ "6:d">selected="selected"</cfif>>6 days</option>
						<option value="1:ww" <cfif arguments.stFilterProps.datepart EQ "1:ww">selected="selected"</cfif>>1 weeks</option>
						<option value="2:ww" <cfif arguments.stFilterProps.datepart EQ "2:ww">selected="selected"</cfif>>2 weeks</option>
						<option value="3:ww" <cfif arguments.stFilterProps.datepart EQ "3:ww">selected="selected"</cfif>>3 weeks</option>
						<option value="1:m" <cfif arguments.stFilterProps.datepart EQ "1:m">selected="selected"</cfif>>1 months</option>
						<option value="2:m" <cfif arguments.stFilterProps.datepart EQ "2:m">selected="selected"</cfif>>2 months</option>
						<option value="3:m" <cfif arguments.stFilterProps.datepart EQ "3:m">selected="selected"</cfif>>3 months</option>
						<option value="4:m" <cfif arguments.stFilterProps.datepart EQ "4:m">selected="selected"</cfif>>4 months</option>
						<option value="5:m" <cfif arguments.stFilterProps.datepart EQ "5:m">selected="selected"</cfif>>5 months</option>
						<option value="6:m" <cfif arguments.stFilterProps.datepart EQ "6:m">selected="selected"</cfif>>6 months</option>
						<option value="7:m" <cfif arguments.stFilterProps.datepart EQ "7:m">selected="selected"</cfif>>7 months</option>
						<option value="8:m" <cfif arguments.stFilterProps.datepart EQ "8:m">selected="selected"</cfif>>8 months</option>
						<option value="9:m" <cfif arguments.stFilterProps.datepart EQ "9:m">selected="selected"</cfif>>9 months</option>
						<option value="10:m" <cfif arguments.stFilterProps.datepart EQ "10:m">selected="selected"</cfif>>10 months</option>
						<option value="11:m" <cfif arguments.stFilterProps.datepart EQ "11:m">selected="selected"</cfif>>11 months</option>
						<option value="1:yyyy" <cfif arguments.stFilterProps.datepart EQ "1:yyyy">selected="selected"</cfif>>1 years</option>
					</select>
					time
					</cfoutput>
				</cfcase>		
					
			
			</cfswitch>
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
	
	<cffunction name="displayFilterUI">
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		<cfset var suffix = "" />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="before">
					<cfparam name="arguments.stFilterProps.before" default="" />
					<cfoutput>#arguments.stFilterProps.before#</cfoutput>
				</cfcase>
				
				<cfcase value="after">
					<cfparam name="arguments.stFilterProps.after" default="" />
					<cfoutput>#arguments.stFilterProps.after#</cfoutput>
				</cfcase>
				
				<cfcase value="between">
					<cfparam name="arguments.stFilterProps.from" default="" />
					<cfparam name="arguments.stFilterProps.to" default="" />
					
					<cfif isValid("date", arguments.stFilterProps.from) AND  isValid("date", arguments.stFilterProps.to)>
						<cfoutput>
							#dateFormat(arguments.stFilterProps.from)# and #dateFormat(arguments.stFilterProps.to)#
						</cfoutput>
					</cfif>
				</cfcase>
			
				
				<cfcase value="more than,less than">
					<cfparam name="arguments.stFilterProps.datepart" default="" />
					<cfif listFirst(arguments.stFilterProps.datepart, ":") GT 1>
						<cfset suffix = "s" />
					</cfif>
					
					<cfoutput>
					#listFirst(arguments.stFilterProps.datepart, ":")#
					<cfswitch expression="#listLast(arguments.stFilterProps.datepart, ":")#">
						<cfcase value="d">day#suffix#</cfcase>
						<cfcase value="ww">week#suffix#</cfcase>
						<cfcase value="m">month#suffix#</cfcase>
						<cfcase value="yyyy">year#suffix#</cfcase>
					</cfswitch>
					ago
					</cfoutput>
				</cfcase>
			
				
				<cfcase value="is within">
					<cfparam name="arguments.stFilterProps.datepart" default="" />
					
					<cfoutput>
					#listFirst(arguments.stFilterProps.datepart, ":")#
					<cfswitch expression="#listLast(arguments.stFilterProps.datepart, ":")#">
						<cfcase value="d">days</cfcase>
						<cfcase value="ww">weeks</cfcase>
						<cfcase value="m">months</cfcase>
						<cfcase value="yyyy">years</cfcase>
					</cfswitch>
					time
					</cfoutput>
				</cfcase>
			</cfswitch>
		</cfsavecontent>
		
		<cfreturn resultHTML />
	</cffunction>
	
	<cffunction name="getFilterSQL">

		<cfargument name="filterTypename" />
		<cfargument name="filterProperty" />
		<cfargument name="filterType" />
		<cfargument name="stFilterProps" />
		
		<cfset var resultHTML = "" />
		
		<cfsavecontent variable="resultHTML">
			
			<cfswitch expression="#arguments.filterType#">
				
				<cfcase value="before">
					<cfparam name="arguments.stFilterProps.before" default="" />
					<cfif isValid("date", arguments.stFilterProps.before)>
						<cfoutput>#arguments.filterProperty# < #createODBCDate(arguments.stFilterProps.before)#</cfoutput>
					</cfif>
				</cfcase>
				
				<cfcase value="after">
					<cfparam name="arguments.stFilterProps.after" default="" />
					<cfif isValid("date", arguments.stFilterProps.after)>
						<cfoutput>#arguments.filterProperty# > #createODBCDate(arguments.stFilterProps.after)#</cfoutput>
					</cfif>
				</cfcase>
				
				<cfcase value="between">
					<cfparam name="arguments.stFilterProps.from" default="" />
					<cfparam name="arguments.stFilterProps.to" default="" />
					
					<cfif isValid("date", arguments.stFilterProps.from) AND  isValid("date", arguments.stFilterProps.to)>
						<cfoutput>
							(
								#arguments.filterProperty# 
								BETWEEN
								#createODBCDate(arguments.stFilterProps.from)#
								AND 
								#createODBCDate(arguments.stFilterProps.to)#
							)
						</cfoutput>
					</cfif>
				</cfcase>
			
				
				<cfcase value="less than">
					<cfparam name="arguments.stFilterProps.datepart" default="" />
					<cfif len(arguments.stFilterProps.datepart)>
						<cfoutput>#arguments.filterProperty# > #createODBCDate(dateAdd(listLast(arguments.stFilterProps.datepart, ":"), listFirst(arguments.stFilterProps.datepart, ":") * -1, now()) )#</cfoutput>
					</cfif>
				</cfcase>
			
				
				<cfcase value="more than">
					<cfparam name="arguments.stFilterProps.datepart" default="" />
					<cfif len(arguments.stFilterProps.datepart)>
						<cfoutput>#arguments.filterProperty# < #createODBCDate(dateAdd(listLast(arguments.stFilterProps.datepart, ":"), listFirst(arguments.stFilterProps.datepart, ":") * -1, now()) )#</cfoutput>
					</cfif>
				</cfcase>
				
				<cfcase value="is within">
					<cfparam name="arguments.stFilterProps.datepart" default="" />
					<cfif len(arguments.stFilterProps.datepart)>
						<cfoutput>
						(
						#arguments.filterProperty# > #createODBCDate(now())#
						AND #arguments.filterProperty# < #createODBCDate(dateAdd(listLast(arguments.stFilterProps.datepart, ":"), listFirst(arguments.stFilterProps.datepart, ":"), now()) )#
						)
						</cfoutput>
					</cfif>
					
				</cfcase>
			</cfswitch>
		</cfsavecontent>

		<cfreturn resultHTML />
	</cffunction>
	
	<cffunction name="cf2jsDate" access="private" output="false" returnType="string" hint="converts a cf date object to a js date object">
		<cfargument name="cfDate" required="true" default="#now()#" type="string" />
		
		<cfset var jsDate = "" />
		
		<cfif (isDate(arguments.cfDate))>
			<cfset jsDate = "new Date(#year(arguments.cfDate)#, #(month(arguments.cfDate)-1)#, #day(arguments.cfDate)#, #hour(arguments.cfDate)#, #minute(arguments.cfDate)#, #second(arguments.cfDate)#)" />
		</cfif>
		
		<cfreturn jsDate />
	</cffunction>
	
</cfcomponent> 
