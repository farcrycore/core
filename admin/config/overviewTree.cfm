<cfprocessingDirective pageencoding="utf-8">
	<cfif isDefined("form.submit")>
		<cfscript>
			st = structNew();
			if(isDefined("form.bUseHiResInsert"))
				st.bUseHiResInsert = 1;
			else
				st.bUseHiResInsert = 0;	
			st.insertJSdmImageHiRes = form.insertJSdmImageHiRes;	
			st.insertJSdmHTML = form.insertJSdmHTML;
			st.insertJSdmFile = form.insertJSdmFile;
			st.insertJSdmImage = form.insertJSdmImage;
			st.insertJSdmFlash = form.insertJSdmFlash;
			st.bAllowDuplicateNavAlias = form.bAllowDuplicateNavAlias;

			st.editHandler = "/farcry/core/admin/config/overviewTree.cfm";
			application.config.overviewTree = duplicate(st);
		</cfscript>		
	
		<cfinvoke component="#application.packagepath#.farcry.config" method="setConfig" returnvariable="setConfigRet">
			<cfinvokeargument name="configName" value="overviewTree"/>
			<cfinvokeargument name="stConfig" value="#st#"/>
		</cfinvoke>
		
		<cfdump var="#setConfigRet#">
		
	</cfif>
	<cfoutput>
	<form action="" method="post">
		<table>
			<tr>
				<td valign="top">
					#application.adminBundle[session.dmProfile.locale].dmHTMLInsert#
				</td>
				<td>
					<textarea  rows="1" cols="100" style="font-size:0.98em;width:100%;" name="insertJSdmHTML">#application.config.overviewTree.insertJSdmHTML#</textarea> 
				</td>
			</tr>
			<tr>
				<td valign="top">
					Use High Res Image if Available?
				</td>
				<td>
					<input name="bUseHiResInsert" type="checkbox" value="1" onclick="if(this.checked)document.getElementById('hires').style.display='block';else document.getElementById('hires').style.display='none';" <cfif application.config.overviewTree.bUseHiResInsert>checked</cfif>> Yes
					<cfif application.config.overviewTree.bUseHiResInsert>
						<cfset style = "dislay:block;">
					<cfelse>
						<cfset style="display:none;">
					</cfif>	
					<div id="hires" style="#style#">
						<textarea  rows="2" cols="100" style="font-size:1.3em;width:90%;" name="insertJSdmImageHiRes">#application.config.overviewTree.insertJSdmImageHiRes#</textarea> 
					</div>
				</td>
			</tr>
			<tr>
				<td valign="top">
					#application.adminBundle[session.dmProfile.locale].dmFileInsert#
				</td>
				<td>
					<textarea  rows="1" cols="100" style="font-size:0.98em;width:100%;" name="insertJSdmFile">#application.config.overviewTree.insertJSdmFile#</textarea> 
				</td>
			</tr>
			<tr>
				<td valign="top">
					#application.adminBundle[session.dmProfile.locale].dmFlashInsert#
				</td>
				<td>
					<textarea  rows="1" cols="100" style="font-size:0.98em;width:100%;" name="insertJSdmFlash">#application.config.overviewTree.insertJSdmFlash#</textarea> 
				</td>
			</tr>
			<tr>
				<td valign="top">
					#application.adminBundle[session.dmProfile.locale].dmImageInsert#
				</td>
				<td>
					<textarea  rows="1" cols="100" style="font-size:0.98em;width:100%;" name="insertJSdmImage">#application.config.overviewTree.insertJSdmImage#</textarea> 
				</td>
			</tr>
			<tr>
				<td valign="top">Allow Duplicate Navigation Alias</td>
				<td><input type="text" name="bAllowDuplicateNavAlias" value="#application.config.overviewTree.bAllowDuplicateNavAlias#" maxlength="3"></td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input type="submit" name="submit" value="#application.adminBundle[session.dmProfile.locale].update#">
				</td>
			</tr>
					
		</table>
	</form>
	</cfoutput>

