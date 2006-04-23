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
			st.editHandler = "/farcry/farcry_core/admin/config/overviewTree.cfm";
			application.config.overviewTree = duplicate(st);
		</cfscript>
		
	
		<cfinvoke component="#application.packagepath#.farcry.config" method="setConfig" returnvariable="setConfigRet">
			<cfinvokeargument name="configName" value="overviewTree"/>
			<cfinvokeargument name="stConfig" value="#st#"/>
		</cfinvoke>
		
		<cfdump var="#setConfigRet#">
		
	</cfif>
	<cfoutput>
	<p>These javascript snippets will be used when inserting content from the Site Tree into the HTML editor.</p>
	<ul>
		<li style="margin-bottom:0.5em;"><code>theNode</code> - an associate array of the selected object's properties. <em>(note: array keys are in uppercase)</em><br /> e.g. <code>theNode['LABEL']</code></li>
		<li style="margin-bottom:0.5em;"><code>lastSelectedId</code> - the objectid of the selected object</li>
	</ul>
	<form action="" method="post">
		<table>
			<tr>
				<td valign="top">
					dmHTML Insert
				</td>
				<td>
					<textarea  rows="2" cols="100" style="font-size:1.3em;width:90%;" name="insertJSdmHTML">#application.config.overviewTree.insertJSdmHTML#</textarea> 
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
					dmFile Insert
				</td>
				<td>
					<textarea  rows="2" cols="100" style="font-size:1.3em;width:90%;" name="insertJSdmFile">#application.config.overviewTree.insertJSdmFile#</textarea> 
				</td>
			</tr>
			<tr>
				<td valign="top">
					dmFlash Insert
				</td>
				<td>
					<textarea  rows="2" cols="100" style="font-size:1.3em;width:90%;" name="insertJSdmFlash">#application.config.overviewTree.insertJSdmFlash#</textarea> 
				</td>
			</tr>
			<tr>
				<td valign="top">
					dmImage Insert
				</td>
				<td>
					<textarea  rows="2" cols="100" style="font-size:1.3em;width:90%;" name="insertJSdmImage">#application.config.overviewTree.insertJSdmImage#</textarea> 
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input type="submit" name="submit" value="Update">
				</td>
			</tr>
			
		
		</table>
	</form>
	</cfoutput>


