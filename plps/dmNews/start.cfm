<!--- 
dmnews PLP
 - start (start.cfm)
--->
<cfimport taglib="/farcry/tags" prefix="tags">
<cfimport taglib="/farcry/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/tags/display/" prefix="display">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>
<cfimport taglib="/farcry/tags" prefix="tags">
<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfif isDefined("FORM.submit")>
<cfscript>
	publishDate = '#form.publishYear#-#form.publishMonth#-#form.publishDay# #form.publishHour#:#form.publishMinutes#';
	expiryDate = '#form.expiryYear#-#form.expiryMonth#-#form.expiryDay# #form.expiryHour#:#form.expiryMinutes#';
	output.expiryDate = createODBCDatetime(expiryDate);
	output.publishDate = createODBCDatetime(publishDate);
	//output.title = FORM.title;
	</cfscript>
</cfif>

<tags:plpNavigationMove>
<cftrace inline="true" text="Completed plpNavigationMove">
<cfif len(output.publishDate ) eq 0>
	<cfset output.publishDate = now()>
</cfif>
<cfif len(output.expiryDate ) eq 0>
	<cfset output.expiryDate = now()>
</cfif>

<cfif NOT thisstep.isComplete>
<cfform action="#cgi.script_name#?#cgi.query_string#" name="editform">
	<cfoutput>

	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">General Info</div>
	<div class="FormTable">
	<table class="BorderTable" width="400" align="center">
	<tr>
		<td nowrap class="FormLabel">Title: </span></td>
		<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">Publish Date:(go live)</td>
		<td >
			<table>
				<tr>
					<td>
						<select name="publishDay" class="formfield">
							<cfloop from="1" to="31" index="i">
								<option value="#i#" <cfif i IS day(output.publishDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="publishMonth" class="formfield">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif i IS month(output.publishDate)>selected</cfif>>#monthAsString(i)#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfscript>
							thisYear = year(now());
							startYear = 2000;
							endYear = year(dateadd("yyyy",7,now()));	
						</cfscript>
						<select name="publishYear" class="formfield">
							<cfloop from="#startYear#" to="#endYear#" index="i">
								<option value="#i#" <cfif i IS year(output.publishDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishHour" class="formfield">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif hour(output.publishDate) IS i>selected</cfif>>#i# hrs</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishMinutes" class="formfield">
							<cfloop from="0" to="45" index="i" step="15">
								<option value="#i#" <cfif minute(output.publishDate) IS i>selected</cfif>>#i# mins</option>						
							</cfloop>
						</select>
					</td>	
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td nowrap><span class="FormLabel">Expiry Date:</span></td>
		<td >
			<table>
				<tr>
					<td>
						<select name="expiryDay" class="formfield">
							<cfloop from="1" to="31" index="i">
								<option value="#i#" <cfif i IS day(output.expiryDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="expiryMonth" class="formfield">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif i IS month(output.expiryDate)>selected</cfif>>#monthAsString(i)#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfscript>
							thisYear = year(now());
							startYear = 2000;
							endYear = year(dateadd("yyyy",7,now()));	
						</cfscript>
						<select name="expiryYear" class="formfield">
							<cfloop from="#startYear#" to="#endYear#" index="i">
								<option value="#i#" <cfif i IS year(output.expiryDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>
					</td>	
					<td>
						<select name="expiryHour" class="formfield">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif hour(output.expiryDate) IS i>selected</cfif>>#i# hrs</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="expiryMinutes" class="formfield">
							<cfloop from="0" to="45" index="i" step="15">
								<option value="#i#" <cfif minute(output.expiryDate) IS i>selected</cfif>>#i# mins</option>						
							</cfloop>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<!--- get the templates for this type --->
	<nj:listTemplates typename="dmNews" prefix="displayPage" r_qMethods="qMethods">
	<tr>
		<td nowrap><span class="FormLabel">Display Method:</span></td>
		<td width="100%"><span class="FormLabel">
		<select name="DisplayMethod" size="1" class="formfield">
		</cfoutput>
		<cfoutput query="qMethods">
			<option value="#qMethods.methodname#" <cfif qMethods.methodname eq output.displayMethod>SELECTED</cfif>>#qMethods.displayname#</option>
		</cfoutput>
		<cfoutput>
		</select>
		</span></td>
	</tr>
	<tr>
		<td colspan="2"><span class="FormLabel">Teaser</span><br><tags:countertext formname="editform" fieldname="teaser" fieldvalue="#output.teaser#" counter="256"></td>
	</tr>
</table>
</div>
	</cfoutput>	
	
		
	<cfoutput>
	<div class="FormTableClear">
	<cftrace inline="true" text="Form complete">
	
		<tags:PLPNavigationButtons>
	<cftrace inline="true" text="PLP NAvigation buttons rendered">
	</div>
	</cfoutput>
	
</cfform>
	
<cfelse>
	
	<tags:plpUpdateOutput>
</cfif>