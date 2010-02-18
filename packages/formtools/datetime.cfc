

<cfcomponent name="datetime" extends="field" displayname="datetime" hint="Field component to liase with all datetime types"> 
		
		
	<cfproperty name="ftRenderType" default="jquery" hint="This formtool offers a number of ways to render the input. (dropdown, jquery, dateJS)" />
	<cfproperty name="ftJQDateFormatMask" default="d M yy" hint="The format mask used by the jQuery UI when returning a date from the calendar. For a full list of the possible formats see http://docs.jquery.com/UI/Datepicker/formatDate" />
	<cfproperty name="ftCFDateFormatMask" default="d mmm yyyy" hint="The format mask used when first rendering the date. This should be a coldfusion dateformat mask." />
	<cfproperty name="ftToggleOffDateTime" default="false" hint="Provides an optional toggle to hide the date if its not required" />
					
	
	
	<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" >	
	<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" >		
		
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

		<cfset var fieldStyle = "">
		<cfset var ToggleOffDateTimeJS = "" />
		<cfset var html = "" />
		<cfset var bfieldvisible = "" />
		<cfset var fieldvisibletoggletext = "" />
		<cfset var locale = "">
		<cfset var localeMonths = "">
		<cfset var i = "">
		<cfset var step=1>
		
		
		<!--- If a required field, then the user will not have the option to toggle off the date time --->
		<cfif structkeyexists(arguments.stMetadata,"ftValidation") and listcontains(arguments.stMetadata.ftValidation,"required")>
			<cfset arguments.stMetadata.ftToggleOffDateTime = "0" />
		</cfif>
		
		<cfif isDate(arguments.stMetadata.value)>
			<cfset arguments.stMetadata.value = application.fapi.convertToApplicationTimezone(arguments.stMetadata.value) />
		</cfif>
		
			
		<cfif arguments.stMetadata.ftToggleOffDateTime>
			<!--- 			
			<cfif len(arguments.stMetadata.value) AND (not IsDate(arguments.stMetadata.value) OR DateDiff('yyyy', now(), arguments.stMetadata.value) GT 100 OR dateformat(arguments.stMetadata.value, 'dd/mm/yyyy') eq '01/01/2050') >
				<cfset bfieldvisible = 0>
				<cfset fieldStyle = "display:none;">
			<cfelse>
				<cfset bfieldvisible = 1>
				<cfset fieldStyle = "">
			</cfif>	 --->
			
			
			<skin:onReady>
			<cfoutput>	
			<cfif len(arguments.stMetadata.value) AND (not IsDate(arguments.stMetadata.value) OR DateDiff('yyyy', now(), arguments.stMetadata.value) GT 100 OR dateformat(arguments.stMetadata.value, 'dd/mm/yyyy') eq '01/01/2050') >
				$j("###arguments.fieldname#-wrap").hide();
				$j("###arguments.fieldname#").val('');
			<cfelse>				
				$j("###arguments.fieldname#include").attr('checked', true);
			</cfif>
			
			$j("###arguments.fieldname#include").click(function() {
				if ($j("###arguments.fieldname#include").attr('checked')) {	
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
			<cfparam name="arguments.stMetadata.ftDateFormatMask" default="dd mmmm yyyy">
			<cfparam name="arguments.stMetadata.ftStartYearShift" default="0">
			<cfparam name="arguments.stMetadata.ftEndYearShift" default="-100">
			<cfparam name="arguments.stMetadata.ftStartYear" default="#year(now()) + arguments.stMetadata.ftStartYearShift#">
			<cfparam name="arguments.stMetadata.ftEndYear" default="#year(now()) + arguments.stMetadata.ftEndYearShift#">
			
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
							<input type="checkbox" name="#arguments.fieldname#include" id="#arguments.fieldname#include" class="checkboxInput" style="float:left;" value="1" >
							<input type="hidden" name="#arguments.fieldname#include" value="0">
							Include Date
						</label>
						</cfoutput>
					</cfif>
					
					<div id="#arguments.fieldname#-wrap">
						
						
						<label class="blockLabel" for="#arguments.fieldname#Day">
							Day 
							<select name="#arguments.fieldname#Day" id="#arguments.fieldname#Day" class="selectInput">
							<option value="">--</option>
							<cfloop from="1" to="31" index="i">
								<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Day(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#i#</option>
								</cfloop>
							</select>	
						</label>
						
						<label class="blockLabel" for="#arguments.fieldname#Month">
							Month 
							<select name="#arguments.fieldname#Month" id="#arguments.fieldname#Month" class="selectInput">
								<option value="">--</option>
								<cfloop from="1" to="12" index="i">
									<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Month(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#localeMonths[i]#</option>
								</cfloop>
							</select>	
						</label>
						
						<label class="blockLabel" for="#arguments.fieldname#Year">
							Year 				
							<select name="#arguments.fieldname#Year" id="#arguments.fieldname#Year" class="selectInput">
								<option value="">--</option>
								<cfloop from="#arguments.stMetadata.ftStartYear#" to="#arguments.stMetadata.ftEndYear#" index="i" step="#step#">
									<option value="#i#"<cfif isDate(arguments.stMetadata.value) AND Year(arguments.stMetadata.value) EQ i> selected="selected"</cfif>>#i#</option>
								</cfloop>
							</select>
						</label>	
					</div>					
				</div>
				</cfoutput>
			</cfsavecontent>		
			
			<cfreturn html>
		</cfcase>
	
		<cfcase value="jquery">
			
			<cfparam name="arguments.stMetadata.ftShowTime" default="true">
			
			<skin:loadJS id="jquery-ui" />
			<skin:loadCSS id="jquery-ui" />
			
			<skin:onReady>
				<cfoutput>
				$j("###arguments.fieldname#").datepicker({dateFormat:'#arguments.stMetadata.ftJQDateFormatMask#',showOn: 'both', buttonImage: '#application.url.farcry#/js/dateTimePicker/cal.gif', buttonImageOnly: true});
				</cfoutput>
			</skin:onReady>
			
			<!--- Just in case the developer has included lowercase mmmm or mmm which is not valid, we are changing to uppercase MMMM and MMM respectively. --->
			
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
						<label class="inlineLabel" for="#arguments.fieldname#"></label>
						<input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftCFDateFormatMask)#" class="textInput" style="width:100px;" >
						<input type="hidden" name="#arguments.fieldname#rendertype" id="#arguments.fieldname#rendertype" value="#arguments.stMetadata.ftRenderType#">
						<cfif arguments.stMetadata.ftShowTime>
							<select name="#arguments.fieldname#Hour">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif isDate(arguments.stMetadata.value) AND TimeFormat(arguments.stMetadata.value,'h') EQ i>selected=selected</cfif>>#i#</option>
							</cfloop>
							</select>
							<select name="#arguments.fieldname#Minute">
								<option value="00">00</option>
								<cfloop from="1" to="60" index="i">
									<option value="#numberFormat(i, '00')#" <cfif isDate(arguments.stMetadata.value) AND TimeFormat(arguments.stMetadata.value,'m') EQ i>selected=selected</cfif>>#numberFormat(i, '00')#</option>
								</cfloop>
							</select>
							<select name="#arguments.fieldname#Period">
								<option value="AM" <cfif isDate(arguments.stMetadata.value) AND TimeFormat(arguments.stMetadata.value,'tt') EQ "AM">selected=selected</cfif>>AM</option>
								<option value="PM" <cfif isDate(arguments.stMetadata.value) AND TimeFormat(arguments.stMetadata.value,'tt') EQ "PM">selected=selected</cfif>>PM</option>
							</select>
						</cfif>
						&nbsp;
					</div>	
						
								
				</div>
				</cfoutput>
			</cfsavecontent>		
			
			<cfreturn html>
		</cfcase>	
		
		<cfdefaultcase>
			
			<cfparam name="arguments.stMetadata.ftStyle" default="width:160px;">
			<cfparam name="arguments.stMetadata.ftClass" default="">
			<cfparam name="arguments.stMetadata.ftDateFormatMask" default="dd MMMM yyyy">
			<cfparam name="arguments.stMetadata.ftTimeFormatMask" default="hh:mm tt">
			<cfparam name="arguments.stMetadata.ftShowTime" default="true">		
			<cfparam name="arguments.stMetadata.ftDateLocale" default="">		
			<cfparam name="arguments.stMetadata.ftShowCalendar" default="true">		
			<cfparam name="arguments.stMetadata.ftShowSuggestions" default="false">
			
			<!--- If no locale explicitly specified, set it to the dmProfile locale if available. Otherwise just use Australia. --->
			<cfif not len(arguments.stMetadata.ftDateLocale)>
				<cfif isDefined("session.dmProfile.locale") and len(session.dmProfile.locale)>
					<cfset arguments.stMetadata.ftDateLocale = replaceNoCase(session.dmProfile.locale,"_", "-", "all") />
				<cfelse>
					<cfset arguments.stMetadata.ftDateLocale = "en-AU" />
				</cfif>
			</cfif>

			<!--- Just in case the developer has included lowercase mmmm or mmm which is not valid, we are changing to uppercase MMMM and MMM respectively. --->
			<cfset arguments.stMetadata.ftDateFormatMask = replaceNoCase(arguments.stMetadata.ftDateFormatMask, "mmmm", "MMMM", "all") />
			<cfset arguments.stMetadata.ftDateFormatMask = replaceNoCase(arguments.stMetadata.ftDateFormatMask, "mmm", "MMM", "all") />			
			<cfset arguments.stMetadata.ftDateFormatMask = replaceNoCase(arguments.stMetadata.ftDateFormatMask, "mm", "MM", "all") />			

			<!--- 
			FormatSpecifiers   
			Format Specifiers are used to specify date formats for display and input.
			
			Format  Description                                                                  Example
			------  ---------------------------------------------------------------------------  -----------------------
			 s      The seconds of the minute between 0-59.                                      "0" to "59"
			 ss     The seconds of the minute with leading zero if required.                     "00" to "59"
			 
			 m      The minute of the hour between 0-59.                                         "0"  or "59"
			 mm     The minute of the hour with leading zero if required.                        "00" or "59"
			 
			 h      The hour of the day between 1-12.                                            "1"  to "12"
			 hh     The hour of the day with leading zero if required.                           "01" to "12"
			 
			 H      The hour of the day between 0-23.                                            "0"  to "23"
			 HH     The hour of the day with leading zero if required.                           "00" to "23"
			 
			 d      The day of the month between 1 and 31.                                       "1"  to "31"
			 dd     The day of the month with leading zero if required.                          "01" to "31"
			 ddd    Abbreviated day name. Date.CultureInfo.abbreviatedDayNames.                  "Mon" to "Sun" 
			 dddd   The full day name. Date.CultureInfo.dayNames.                                "Monday" to "Sunday"
			 
			 M      The month of the year between 1-12.                                          "1" to "12"
			 MM     The month of the year with leading zero if required.                         "01" to "12"
			 MMM    Abbreviated month name. Date.CultureInfo.abbreviatedMonthNames.              "Jan" to "Dec"
			 MMMM   The full month name. Date.CultureInfo.monthNames.                            "January" to "December"
			
			 yy     Displays the year as a two-digit number.                                     "99" or "07"
			 yyyy   Displays the full four digit year.                                           "1999" or "2007"
			 
			 t      Displays the first character of the A.M./P.M. designator.                    "A" or "P"
			        Date.CultureInfo.amDesignator or Date.CultureInfo.pmDesignator
			 tt     Displays the A.M./P.M. designator.                                           "AM" or "PM"
			        Date.CultureInfo.amDesignator or Date.CultureInfo.pmDesignator
			 --->						
					
			<skin:htmlHead library="extjs" />
			<skin:htmlHead id="dateJS">
				<cfoutput><script type="text/javascript" src="#application.url.webtop#/js/dateJS/date-#arguments.stMetadata.ftDateLocale#.js"></script></cfoutput>
				<cfoutput>
				<style type="text/css">
				.dateSuggestions {
					padding:0px 0px 0px 25px;
					background: ##efefef url('#application.url.webtop#/js/dateJS/images/information.png') top left no-repeat;
				}
				.dateJSHiddenValue {
					padding:0px 0px 0px 25px;
					
					float:left;
				}
				.dateEmpty {background: ##fff url('#application.url.webtop#/js/dateJS/images/star.png') top left no-repeat;}
				.dateAccept {background: ##fff url('#application.url.webtop#/js/dateJS/images/accept.png') top left no-repeat;}
				.dateError {
					background:##FFDFDF url('#application.url.webtop#/js/dateJS/images/exclamation.png') top left no-repeat;
					border-color:##DF7D7D;
					border-style:solid;
					border-width:1px 0;
				}
				</style>
				
				<script type="text/javascript">
					function updateDateJSField(fieldName, mask){
				    	var el = Ext.get(fieldName + "Info");
				    	var dateString = Ext.get(fieldName + "Input").dom.value;
	
					    	if (dateString.length > 0) {
					    	var parsedValue = Date.parse(dateString)
					    	if (parsedValue !== null) {
					    		el.removeClass('dateEmpty');
					    		el.removeClass('dateError');
								el.addClass('dateAccept');	
								Ext.get(fieldName + "Info").dom.innerHTML = parsedValue.toString(mask);
								Ext.get(fieldName).dom.value = parsedValue.toString('dd-MMM-yyyy hh:mm tt');
							} else {
								el.removeClass('dateEmpty');
								el.removeClass('dateAccept');
								el.addClass('dateError');	
								Ext.get(fieldName + "Info").dom.innerHTML = 'NOT A VALID DATE';
								Ext.get(fieldName).dom.value = '';
							}
						} else {

						}
					}
				</script>
				</cfoutput>				
			</skin:htmlHead>
			
			<extjs:onReady>
				<cfoutput>	
					Ext.get("#arguments.fieldname#Input").on('keyup', this.onClick, this, {
					    buffer: 200,
					    fn: function() { 
					    	updateDateJSField('#arguments.fieldname#', '#arguments.stMetadata.ftDateFormatMask# #arguments.stMetadata.ftTimeFormatMask#');
						 }
					});
					Ext.get("#arguments.fieldname#Input").on('focus', this.onClick, this, {
					    buffer: 200,
					    fn: function() { 
					    	if (Ext.get("#arguments.fieldname#Input").dom.value == 'Type in your date') {
					    		Ext.get("#arguments.fieldname#Input").dom.value = '';
					    	}
						 }
					});
				</cfoutput>			
			</extjs:onReady>	
			
						
			<cfsavecontent variable="html">

				<cfoutput>
				<div class="multiField">
					<cfif arguments.stMetadata.ftToggleOffDateTime>						
						<label class="inlineLabel" for="#arguments.fieldname#include">
							<input type="checkbox" name="#arguments.fieldname#include" id="#arguments.fieldname#include" value="1" class="checkboxInput" >
							<input type="hidden" name="#arguments.fieldname#include" value="0">
							Include Date
						</label>						
					</cfif>
					<div id="#arguments.fieldname#-wrap">
						<div id="#arguments.fieldname#Info" class="dateJSHiddenValue <cfif len(arguments.stMetadata.value)>dateAccept<cfelse>dateEmpty</cfif>">
							<cfif len(arguments.stMetadata.value)>
								#DateFormat(arguments.stMetadata.value,arguments.stMetadata.ftDateFormatMask)# 
								<cfif arguments.stMetadata.ftShowTime>#TimeFormat(arguments.stMetadata.value,arguments.stMetadata.ftTimeFormatMask)#</cfif>
							<cfelse>
								Type in your date
							</cfif>
						</div>	
						<a id="#arguments.fieldname#DatePicker"><img src="#application.url.farcry#/js/dateTimePicker/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a>

						<br class="clearer" />
						<input type="text" id="#arguments.fieldname#Input" name="#arguments.fieldname#Input" class="textInput" value="" style="font-size:0.8em;" />
						
						<cfif arguments.stMetadata.ftShowSuggestions><div class="dateSuggestions">Examples: tomorrow; next tues at 5am; +5days;</div></cfif>
						<cfif len(arguments.stMetadata.value)>
							<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#DateFormat(arguments.stMetadata.value,'dd-mmm-yyyy')# #TimeFormat(arguments.stMetadata.value, 'hh:mm tt')#" class="#arguments.stMetadata.ftClass#">
						<cfelse>
							<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="" class="#arguments.stMetadata.ftClass#">								
						</cfif> 
											
								
					</div>
				</cfoutput>
					
					
				<cfif arguments.stMetadata.ftShowCalendar>
					<skin:htmlHead library="calendar" />
					<cfoutput>
						<script type="text/javascript">
						  Calendar.setup(
						    {
							  inputField	: "#arguments.fieldname#",         // ID of the input field 
						      button		: "#arguments.fieldname#DatePicker",       // ID of the button
						      showsTime		: #arguments.stMetadata.ftShowTime#,
						      electric		: false,
						      ifFormat		: "%Y/%b/%d %I:%M %p",
						      onClose		: function(calendar) {	
						      	if (calendar.dateClicked) { 
							      	
						      		Ext.get("#arguments.fieldname#Input").dom.value = Date.parse(calendar.date).toString("#arguments.stMetadata.ftDateFormatMask# <cfif arguments.stMetadata.ftShowTime>#arguments.stMetadata.ftTimeFormatMask#</cfif>");
							      	updateDateJSField('#arguments.fieldname#', '#arguments.stMetadata.ftDateFormatMask# <cfif arguments.stMetadata.ftShowTime>#arguments.stMetadata.ftTimeFormatMask#</cfif>');	
							      	Ext.get("#arguments.fieldname#Input").dom.value = '';
						      	}
							    calendar.hide();					      						
						      }
						    }
						  );
						</script>
					</cfoutput>
				</cfif>
				
				<cfoutput>
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
					<cfoutput><span title="#renderDate#">#application.fapi.prettyDate(arguments.stMetadata.value)#</span></cfoutput>
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
							
					<cfset newDate = CreateODBCDateTime("#arguments.stFieldPost.Value# #newTime#") />
					<cfset stResult = passed(value="#newDate#") />
					<cfcatch type="any">
						<cfset stResult = failed(value="#arguments.stFieldPost.value#", message="You need to select a valid date.") />
					</cfcatch>
				</cftry>
				
			<cfelse>
				<cfset newDate = CreateODBCDateTime("#DateAdd('yyyy',200,now())#") />
				<cfset stResult = passed(value="#newDate#") />
			</cfif>
		
			<cfif stResult.bSuccess>
				<cfset arguments.stFieldPost.value = stResult.value />
				<cfset stResult = super.validate(objectid=arguments.objectid, typename=arguments.typename, stFieldPost=arguments.stFieldPost, stMetadata=arguments.stMetadata )>
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
	
</cfcomponent> 
