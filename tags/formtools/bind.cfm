<cfsetting enablecfoutputonly="true" />

<cfparam name="attributes.field" />
<cfparam name="attributes.prefix" />
<cfparam name="attributes.binding" default="" />
<cfparam name="attributes.lRequiredFields" default="*" />

<cfif thisTag.ExecutionMode eq "End">
	<cfset request.inhead.jQueryJS = 1>
	
	<cfset lFields = "" />
	<cfset lVars = "" />
	<cfset jscode = trim(thisTag.generatedContent) />
	<cfset stSub = -1 />
	<cfset thisfield = "" />
	
	<cfif len(attributes.binding)>
		<cfset jscode = "newValue = " & attributes.binding />
	</cfif>
	
	<!--- Get fields that this field depends on --->
	<cfset stSub = refind("[{]![^}]+[}]",jscode,1,true) />
	<cfloop condition="#stSub.len[1]#">
		<cfset thisfield = mid(jscode,stSub.pos[1]+2,stSub.len[1]-3) />
		<cfset jscode = replacenocase(jscode,"{!" & thisfield & "}","bv['" & thisfield & "']","ALL") />
		<cfset lFields = listappend(lFields,thisfield) />
		<cfset stSub = refind("[{]![^}]+[}]",jscode,1,true) />
	</cfloop>
	<cfif attributes.lRequiredFields eq "*">
		<cfset attributes.lRequiredFields = lFields />
	</cfif>
	
	<!--- Get custom variables --->
	<cfset stSub = refind("[{][?][^}]+[}]",jscode,1,true) />
	<cfloop condition="#stSub.len[1]#">
		<cfset thisfield = mid(jscode,stSub.pos[1]+2,stSub.len[1]-3) />
		<cfset jscode = replacenocase(jscode,"{?" & thisfield & "}","cv['" & thisfield & "']","ALL") />
		<cfset lVars = listappend(lVars,thisfield) />
		<cfset stSub = refind("[{][?][^}]+[}]",jscode,1,true) />
	</cfloop>

	<cfsavecontent variable="jsOutput"><cfoutput>
		<script type="text/javascript">
			jQuery(document).ready(function($) {
				var $thisinput = $("###attributes.prefix##attributes.field#");
				var $thisdisplay = $("###attributes.prefix##attributes.field#_display");
				var $boundfields = {};
				<cfloop list="#lFields#" index="thisfield">
					$boundfields.#thisfield# = $("###attributes.prefix##thisfield#");
				</cfloop>
				var aRequiredFields = new String("#attributes.lRequiredFields#").split(",");
				
				function monthasstring(month) {
					var months = { 
						1:"January", 2:"February", 3:"March", 4:"April", 
						5:"May", 6:"June", 7:"July", 8:"August", 
						9:"September", 10:"October", 11:"November", 12:"December"
					};
					
					return months[month];
				};
				
				function createDate(day,month,year) {
					var today = new Date();
					day = (day || today.getDate() + 1).toString();
					month = monthasstring(month || today.getMonth() + 1);
					year = (year || today.getFullYear()).toString();
					
					return new Date(day & " " & month & " " & year);
				}
				
				function bindField() {
					var bv = {};
					var cv = {};
					var newValue = "";
					var update = true;
					
					for (f in $boundfields) bv[f] = $boundfields[f].val();
					for (var i=0; i<aRequiredFields.length; i++) update = update && (bv[aRequiredFields[i]] && bv[aRequiredFields[i]].length);
					
					if (update) {
						#jscode#
						
						$thisinput.val(newValue);
						$thisdisplay.html(newValue);
					}
				};
				
				for (f in $boundfields) $boundfields[f].bind("blur",bindField);
			});
		</script>
	</cfoutput></cfsavecontent>
	
	<cfset thisTag.generatedContent = jsOutput />
</cfif>

<cfsetting enablecfoutputonly="false" />