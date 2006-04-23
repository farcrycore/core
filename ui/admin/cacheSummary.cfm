<cfsetting enablecfoutputonly="yes">
<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<!--- clean selected blocks --->
<cfif isdefined("form.cleanBlock")>
	<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheClean">
		<cfinvokeargument name="cacheBlockName" value="#form.cleanBlock#"/>
		<cfinvokeargument name="bShowResults" value="true"/>
	</cfinvoke>
</cfif>
<!--- flush selected blocks --->
<cfif isdefined("form.flushBlock")>
	<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheFlush">
		<cfinvokeargument name="cacheBlockName" value="#form.flushBlock#"/>
		<cfinvokeargument name="bShowResults" value="true"/>
	</cfinvoke>
</cfif>

<!--- display form --->
<cfoutput><span class="Formtitle">Content Cache Summary</span><p></p></cfoutput>

<!--- block caches --->
<!--- check a block cache exists --->
<cfif structkeyexists(server,"dm_cacheblock")>
	<!--- setup form and header --->
	<cfoutput>
	<form action="" method="post" name="BlockForm">
	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr class="dataheader">
		<td>Block</td>
		<td align="center">Number of Caches</td>
		<td align="center">Expired Caches</td>
		<td align="center">Clean</td>
		<td align="center">Flush</td>
	</tr>
	</cfoutput>
	
	<cflock timeout="10" throwontimeout="Yes" name="CacheBlockRead_#application.applicationname#" type="EXCLUSIVE">
		<cfset blockcache = structget("server.dm_CacheBlock.#application.applicationname#")>
		<!--- sort structure --->
		<cfset listofKeys = structKeyList(blockCache)>
		<cfset listofKeys = listsort(listofkeys,"textnocase")>
		<!--- loop over each block cache --->
		<cfloop list="#listofKeys#" index="blockName">
			<cfset cacheflushnum = 0>
			<!--- check block has a cache --->
			<cfif structkeyexists(blockcache, blockName)>
				<cflock timeout="10" throwontimeout="Yes" name="GeneratedContentCache_#application.applicationname#" type="EXCLUSIVE"><!--- possibility to get contention against cachewrite, but this is admin, so it'll throw and no probs... --->
					<cfoutput>
					<tr>
						<!--- display block cache name --->
						<td><a href="cacheDetail.cfm?block=#blockName#">#blockname#</a></td>
						<!--- display number of caches within block --->
						<td align="center">#listlen(blockCache[blockName])#</td>
					</cfoutput>
					<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
					<cfset cacheflushnum = 0>
					<!--- loop over each cache in block to see how many have timed out --->
					<cfloop index="element" list="#blockcache[blockName]#">
						<!--- concatinate blockName & cacheName (this is how caches are first named) --->
						<cfset element = blockName & element>
						<!--- check cache exists --->
						<cfif structkeyexists(contentcache, element)>
							<!--- check for timeout --->
							<cfif contentcache[element].cachetimeout neq 0 and contentcache[element].cachetimestamp lt now() - contentcache[element].cachetimeout>
								<cfset cacheflushnum = cacheflushnum + 1>
							</cfif>
						</cfif>
					</cfloop>
					
					<cfoutput>
							<!--- display number of caches that have timed out --->
							<td align="center">#cacheflushnum#</td>
							<td align="center"><input type="checkbox" value="#blockName#" name="cleanBlock"></td>
							<td align="center"><input type="checkbox" value="#blockName#" name="flushBlock"></td>
						</tr>
					</cfoutput>
				</cflock>
			</cfif>
		</cfloop>
	</cflock>
	<cfoutput>
	<tr style="border: none;">
		<!--- show form buttons, javascript to submit the form onClick of button --->
		<td style="border-right: none;" colspan="3"><input type="button" value="Refresh" name="refresh" class="normalbttnstyle" onClick="forms.BlockForm.submitButton.name='refresh';forms.BlockForm.submitButton.click()"></td>
		<td  style="border-right: none;border-left: none;" align="center"><input type="button" name"cleanBlock" value="Clean" class="normalbttnstyle" onClick="forms.BlockForm.submitButton.name='cleanBlock';forms.BlockForm.submitButton.click()"></td>
		<td  style="border-left: none;" align="center"><input type="button" value="Flush" name="flushBlock" class="normalbttnstyle" onClick="forms.BlockForm.submitButton.name='flushBlock';forms.BlockForm.submitButton.click()"></td>
	</tr>
	</table><p></p>
	<input type="submit" name="submitButton" style="visibility:hidden;width:28px;">	
	<input type="hidden" value="" name="dummyField">
	</form>
	</cfoutput>
<cfelse>
	<cfoutput>No block caches at this time.</cfoutput>
</cfif>

<admin:footer>
<cfsetting enablecfoutputonly="no">