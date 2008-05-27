<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

<cfsetting enablecfoutputonly="yes">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmEvent/plpEdit/start.cfm,v 1.19 2005/09/06 22:30:41 daniela Exp $
$Author: daniela $
$Date: 2005/09/06 22:30:41 $
$Name:  $
$Revision: 1.19 $

|| DESCRIPTION || 
$Description: dmEvent Edit PLP - Start Step $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="errormessage" default="">

<cfset localeMonths=application.thisCalendar.getMonths(session.dmProfile.locale)>

<cfimport taglib="/farcry/core/tags/farcry" prefix="tags">
<!--- <cfimport taglib="/farcry/core/tags/display/" prefix="display"> --->
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfif isDefined("form.plpAction")>
<!--- 	<!--- publish/expiry dates --->
	<cfset publishDate = createDateTime(form.publishYear,form.publishMonth,form.publishDay,form.publishHour,form.publishMinutes,0)>
	<cfset output.publishDate = createODBCDatetime(publishDate)>
	<!--- hack for no expiry. sets expiry year to 2050...the y2050 bug :) --->
<!--- 	<cfif form.noExpiry EQ 1>
		<cfset expiryDate = createDateTime('2050',form.expiryMonth,form.expiryDay,form.expiryHour,form.expiryMinutes,0)>
	<cfelse>
		<cfset expiryDate = createDateTime(form.expiryYear,form.expiryMonth,form.expiryDay,form.expiryHour,form.expiryMinutes,0)>
	</cfif>	 --->
	<cfset expiryDate = createDateTime(form.expiryYear,form.expiryMonth,form.expiryDay,form.expiryHour,form.expiryMinutes,0)>
	<cfset output.expiryDate = createODBCDatetime(expiryDate)> --->
<!--- 	<cfset output.PublishDate = CreateODBCDateTime(form.PublishDate, "dd/mm/yyyy hh:mm:ss tt")>
	<cfset output.expiryDate = "2005-12-16 21:35:55"> --->
	
	
			
			<ft:processFormObjects insidePLP="true" typename="#output.typename#" />

			
	
	<cfif errormessage EQ "">
		<widgets:plpAction>
	</cfif>

</cfif>

<cfif NOT thisstep.isComplete>
	<widgets:plpWrapper>
	<cfoutput>
	
	
	<script language="javascript" type="text/javascript" src="/js/datetimepicker/datetimepicker.js">
	
	//Date Time Picker script- by TengYong Ng of http://www.rainforestnet.com
	//Script featured on JavaScript Kit (http://www.javascriptkit.com)
	//For this script, visit http://www.javascriptkit.com
	
	</script>


	<cfif errormessage NEQ "">
		<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
	</cfif>
	
	<ft:form name="editform">

	
	
			<ft:object objectid="#output.objectid#" lFields="#lFields#" insidePLP="true" inTable=1 Legend="" />

			
			<input type="hidden" name="plpAction" value="" />
			<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
		
	
	


	
</ft:form>



<!--- 	<form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post">
		<table>
		<tr>
			<th style="width:150px;">Building Depreciation Rate</th>
			<td><input type="text" name="BuildingDepreciationRate" id="BuildingDepreciationRate" value="#output.BuildingDepreciationRate#" maxlength="255" style="width:300px;" /></td>
		</tr>
		<tr>
			<th>Building Depreciation</th>
			<td><input type="text" name="BuildingDepreciation" id="BuildingDepreciation" value="#output.BuildingDepreciation#" /></td>
		</tr>
		<tr>
			<th>Equipment Depreciation</th>
			<td><input type="text" name="EquipmentDepreciation" id="EquipmentDepreciation" value="#output.EquipmentDepreciation#"  /></td>
		</tr>
		<tr>
			<th valign="top">Depreciation Schedule</th>
			<td><textarea name="DepreciationSchedule" id="DepreciationSchedule" style="width:350px;height:70px;">#output.DepreciationSchedule#</textarea></td>
		</tr>
		</table>
				
	
		<input type="hidden" name="plpAction" value="" />
		<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
	</form>
	<cfinclude template="/farcry/core/webtop/includes/QFormValidationJS.cfm"> --->
	</cfoutput>
	</widgets:plpWrapper>
<cfelse>
	<widgets:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">