<cfcomponent displayname="Diff Result" hint="Encapsulates all funcationality for diffs" output="false">
	
	
	<cfset this.nl = "
" />

	<cffunction name="getHTMLAsText" returntype="string" access="private" output="false" hint="Converts html to plain text indented according to nesting">
		<cfargument name="html" type="string" required="true">
		
		<cfset var result = arguments.html />
		<cfset var st = structnew() />
		<cfset var i = 0 />
		<cfset var newstring = "" />
		<cfset var line = "" />
		<cfset var bEmptyLast = false />
		
		<!--- Headings --->
		<cfset result = rereplacenocase(result,"<(h\d)[^>]*>(.*?)</\1>","\1. \2#this.nl#","ALL") />
		
		<!--- Paragraphs --->
		<cfset result = rereplacenocase(result,"<p[^>]*>(.*?)</p>","\1#this.nl# #this.nl#","ALL") />
		
		<!--- New lines --->
		<cfset result = rereplacenocase(result,"<br\s?/?>",this.nl,"ALL") />
		
		<!--- Unordered lists --->
		<cfset st = refindnocase("<ul[^>]*>.*?</ul>",result,1,true) />
		<cfloop condition="arraylen(st.pos) gt 0 and st.pos[1] gt 0">
			<cfset newstring = mid(result,st.pos[1],st.len[1]) />
			<cfset newstring = rereplacenocase(newstring,"<li[^>]*>(.*?)</li>","* \1#this.nl#","ALL") />
			<cfset result = replace(result,mid(result,st.pos[1],st.len[1]),newString & this.nl) />
			<cfset st = refindnocase("<ul[^>]*>.*?</ul>",result,st.pos[1]+len(newString)+1,true) />
		</cfloop>
		
		<!--- Ordered lists --->
		<cfset st = refindnocase("<ol[^>]*>.*?</ol>",result,1,true) />
		<cfloop condition="arraylen(st.pos) gt 0 and st.pos[1] gt 0">
			<cfset newstring = mid(result,st.pos[1],st.len[1]) />
			<cfset newstring = rereplacenocase(newstring,"<li[^>]*>(.*?)</li>","## \1#this.nl#","ALL") />
			<cfset result = replace(result,mid(result,st.pos[1],st.len[1]),newString & this.nl) />
			<cfset st = refindnocase("<ol[^>]*>.*?</ol>",result,st.pos[1]+len(newString)+1,true) />
		</cfloop>
		
		<!--- Tables --->
		<cfset st = refindnocase("<table[^>]*>(.*?)</table>",result,1,true) />
		<cfloop condition="arraylen(st.pos) gt 0 and st.pos[1] gt 0">
			<cfset newstring = mid(result,st.pos[2],st.len[2]) />
			<cfset newstring = rereplacenocase(newstring,"\s*(<tbody[^>]*>|</tbody>|<thead[^>]*>|</thead>|<tfoot[^>]*>|</tfoot>)\s*","","ALL") />
			<cfset newstring = rereplacenocase(newstring,"(\s*(<td[^>]*>|</td>|<th[^>]*>|</th>)\s*)+","|","ALL") />
			<cfset newstring = rereplacenocase(newstring,"\s*<tr[^>]*>(.*?)</tr>\s*","\1#this.nl#","ALL") />
			<cfset result = replace(result,mid(result,st.pos[1],st.len[1]),newString & this.nl & " " & this.nl) />
			<cfset st = refindnocase("<table[^>]*>.*?</table>",result,st.pos[1]+len(newString)+3,true) />
		</cfloop>
		
		<!--- Images --->
		<cfset result = rereplacenocase(result,"<img[^>]*src=[""']([^""']*)[""'][^>]*>","[image:\1]","ALL") />
		
		<!--- Just remove other tags --->
		<cfset result = rereplace(result,"<[^>]*>"," ","ALL") />
		
		<!--- Trim each line --->
		<cfset newString = "" />
		<cfloop list="#result#" delimiters="#chr(10)##chr(13)#" index="line">
			<cfif len(trim(line)) or not bEmptyLast><!--- Ignore successive empty lines --->
				<cfset newString = newstring & trim(line) & this.nl />
				<cfset bEmptyLast = (len(trim(line)) eq 0) />
			</cfif>
		</cfloop>
		<cfset result = newstring />
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="convertDiffToHighlights" returntype="struct" access="private" output="false" hint="Takes a diff array and returns a left and right highlighted result">
		<cfargument name="aDiff" type="array" required="true" />
		
		<cfset var stResult = structnew() />
		<cfset var leftStatus = "" />
		<cfset var rightStatus = "" />
		<cfset var i = 0 />
		
		<cfset stResult.leftHighlighted = "" />
		<cfset stResult.rightHighlighted = "" />
		
		<cfloop from="1" to="#arraylen(arguments.aDiff)#" index="i">
			<cfif arguments.aDiff[i].diff neq leftStatus>
				<cfif arguments.aDiff[i].diff eq "-"><!--- Moving into deleted text --->
					<cfset stResult.leftHighlighted = stResult.leftHighlighted & "<span style='color:##CC2504;font-weight:bold;'>" />
				<cfelseif leftStatus eq "-"><!--- Moving out of deleted text --->
					<cfset stResult.leftHighlighted = stResult.leftHighlighted & "</span>" />
				</cfif>
				<cfset leftStatus = arguments.aDiff[i].diff />
			</cfif>
			<cfif arguments.aDiff[i].diff neq rightStatus>
				<cfif arguments.aDiff[i].diff eq "+"><!--- Moving into added text --->
					<cfset stResult.rightHighlighted = stResult.rightHighlighted & "<span style='color:##00BF0D;font-weight:bold;'>" />
				<cfelseif rightStatus eq "+"><!--- Moving out of added text --->
					<cfset stResult.rightHighlighted = stResult.rightHighlighted & "</span>" />
				</cfif>
				<cfset rightStatus = arguments.aDiff[i].diff />
			</cfif>
			<cfif listcontains("-,=",arguments.aDiff[i].diff)>
				<cfset stResult.leftHighlighted = stResult.leftHighlighted & arguments.aDiff[i].oldvalue />
			</cfif>
			<cfif listcontains("+,=",arguments.aDiff[i].diff)>
				<cfset stResult.rightHighlighted = stResult.rightHighlighted & arguments.aDiff[i].newvalue />
			</cfif>
		</cfloop>
		
		<cfif leftStatus eq "-"><!--- Moving out of deleted text --->
			<cfset stResult.leftHighlighted = stResult.leftHighlighted & "</span>" />
		</cfif>
		<cfif rightStatus eq "+"><!--- Moving out of added text --->
			<cfset stResult.rightHighlighted = stResult.rightHighlighted & "</span>" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="stringToArray" access="private" output="false" returntype="array" hint="Returns the string as an array of characters">
		<cfargument name="s" type="string" required="true" />
		
		<cfset var aResult = arraynew(1) />
		<cfset var i = 0 />
		
		<cfloop from="1" to="#len(arguments.s)#" index="i">
			<cfset aResult[i] = mid(arguments.s,i,1) />
		</cfloop>
		
		<cfreturn aResult />
	</cffunction>
	
	<cffunction name="performPropertyDiff" access="public" output="false" returntype="struct" hint="Performs diff on the property according to its type">
		<cfargument name="typename" required="true" />
		<cfargument name="left" required="true" />
		<cfargument name="right" required="true" />
		<cfargument name="stMetadata" required="true" />
		
		<cfset var stResult = structnew() />
		<cfset var stTemp = structnew() />
		<cfset var i = 0 />
		
		<cfset stResult.left = arguments.left />
		<cfset stResult.right = arguments.right />
		<cfset stResult.leftHighlighted = arguments.left />
		<cfset stResult.rightHighlighted = arguments.right />
		<cfset stResult.aDiff = arraynew(1) />
		<cfset stResult.different = false />
		<cfset stResult.formtool = arguments.stMetadata.type />
		<cfset stResult.label = arguments.stMetadata.name />
		
		<cfif structkeyexists(arguments.stMetadata,"ftType")>
			<cfset stResult.formtool = arguments.stMetadata.ftType />
		</cfif>
		<cfif structkeyexists(arguments.stMetadata,"ftLabel")>
			<cfset stResult.label = arguments.stMetadata.ftLabel />
		</cfif>
		
		<cfswitch expression="#stResult.formtool#">
			<cfcase value="richtext">
				<cfset stResult.left = getHTMLAsText(stResult.left) />
				<cfset stResult.right = getHTMLAsText(stResult.right) />
				<cfset stResult.different = (stResult.left neq stResult.right) />
				<cfif stResult.different>
					<cfset stResult.aDiff = getDiff(aOld=stringToArray(stResult.left),aNew=stringToArray(stResult.right)) />
					<cfset structappend(stResult,convertDiffToHighlights(stResult.aDiff),true) />
				</cfif>
			</cfcase>
			<cfcase value="string,longchar" delimiters=",">
				<cfset stResult.different = (stResult.left neq stResult.right) />
				<cfif stResult.different>
					<cfset stResult.aDiff = getDiff(aOld=stringToArray(stResult.left),aNew=stringToArray(stResult.right)) />
					<cfset structappend(stResult,convertDiffToHighlights(stResult.aDiff),true) />
				</cfif>
			</cfcase>
			<cfcase value="category">
				<cfset stTemp[arguments.stMetadata.name] = arguments.left />
				<cfset stResult.left = application.formtools.category.oFactory.display(typename=arguments.typename,fieldname=arguments.stMetadata.name,stMetadata=arguments.stMetadata,stObject=stTemp) />
				<cfset stTemp[arguments.stMetadata.name] = arguments.right />
				<cfset stResult.right = application.formtools.category.oFactory.display(typename=arguments.typename,fieldname=arguments.stMetadata.name,stMetadata=arguments.stMetadata,stObject=stTemp) />
				<cfset stResult.different = (stResult.left neq stResult.right) />
				<cfif stResult.different>
					<cfset stResult.aDiff = getDiff(aOld=stringToArray(stResult.left),aNew=stringToArray(stResult.right)) />
					<cfset structappend(stResult,convertDiffToHighlights(stResult.aDiff),true) />
				</cfif>
			</cfcase>
			<cfcase value="datetime,navigation,uuid" delimiters=",">
				<cfset stTemp[arguments.stMetadata.name] = arguments.left />
				<cfset arguments.stMetadata.value = arguments.left />
				<cfset stResult.left = application.formtools[stResult.formtool].oFactory.display(typename=arguments.typename,fieldname=arguments.stMetadata.name,stMetadata=arguments.stMetadata,stObject=stTemp) />
				<cfset stResult.leftHighlighted = arguments.left />
				<cfset stTemp[arguments.stMetadata.name] = arguments.right />
				<cfset arguments.stMetadata.value = arguments.right />
				<cfset stResult.right = application.formtools[stResult.formtool].oFactory.display(typename=arguments.typename,fieldname=arguments.stMetadata.name,stMetadata=arguments.stMetadata,stObject=stTemp) />
				<cfset stResult.rightHighlighted = arguments.right />
				<cfset stResult.different = (stResult.left neq stResult.right) />
			</cfcase>
			<cfcase value="webskin">
				<cfset stResult.leftHighlighted = application.coapi.coapiadmin.getWebskinDisplayname(typename=arguments.typename, template=arguments.left) />
				<cfset stResult.rightHighlighted = application.coapi.coapiadmin.getWebskinDisplayname(typename=arguments.typename, template=arguments.right) />
				<cfset stResult.different = (stResult.left neq stResult.right) />
			</cfcase>
			<cfcase value="integer">
				<cfset stResult.leftHighlighted = round(stResult.left) />
				<cfset stResult.rightHighlighted = round(stResult.right) />
				<cfset stResult.different = (stResult.left neq stResult.right) />
			</cfcase>
			<cfcase value="array">
				<cfset stResult.leftHighlighted = "" />
				<cfloop from="1" to="#arraylen(stResult.left)#" index="i">
					<cfset stTemp = application.fapi.getContentObject(objectid=stResult.left[i]) />
					<cfset stResult.leftHighlighted = stResult.leftHighlighted & "* " & stTemp.label & " [" & application.stCOAPI[stTemp.typename].displayName & "]" & this.nl />
				</cfloop>
				<cfset stResult.rightHighlighted = "" />
				<cfloop from="1" to="#arraylen(stResult.right)#" index="i">
					<cfset stTemp = application.fapi.getContentObject(objectid=stResult.right[i]) />
					<cfset stResult.rightHighlighted = stResult.rightHighlighted & "* " & stTemp.label & " [" & application.stCOAPI[stTemp.typename].displayName & "]" & this.nl />
				</cfloop>
				<cfset stResult.different = (stResult.leftHighlighted neq stResult.rightHighlighted) />
				<cfif stResult.different>
					<cfset stResult.aDiff = getDiff(aOld=stringToArray(stResult.leftHighlighted),aNew=stringToArray(stResult.rightHighlighted)) />
					<cfset structappend(stResult,convertDiffToHighlights(stResult.aDiff),true) />
				</cfif>
			</cfcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="performObjectDiff" access="public" output="false" returntype="struct" hint="Performs diff on all visible properties according to their type">
		<cfargument name="left" type="struct" required="true" />
		<cfargument name="right" type="struct" required="true" />
		<cfargument name="stMetadata" type="struct" required="false" default="#structnew()#" />
		
		<cfset var stPropMetadata = structnew() />
		<cfset var prop = "" />
		<cfset var stResult = structnew() />
		
		<cfset stResult.countDifferent = 0 />
		
		<cfloop collection="#arguments.left#" item="prop">
			<cfif not prop eq "typename">
				<cfset stPropMetadata = duplicate(application.stCOAPI[arguments.left.typename].stProps[prop].metadata) />
				<cfif structkeyexists(arguments.stMetadata,prop)>
					<cfset structappend(stPropMetadata,arguments.stMetadata[prop],true) />
				</cfif>
				<cfif structkeyexists(stPropMetadata,"ftSeq") and len(stPropMetadata.ftSeq)>
					<cfset stResult[prop] = performPropertyDiff(typename=arguments.left.typename,left=arguments.left[prop],right=arguments.right[prop],stMetadata=stPropMetadata) />
					<cfif stResult[prop].different>
						<cfset stResult.countDifferent = stResult.countDifferent + 1 />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	
	
	<cffunction name="getDiff" returntype="array" access="public" hint="Returns an array of diff structs">
		<cfargument name="aOld" type="array" required="true" hint="Original array of words to compare" />
		<cfargument name="aNew" type="array" required="true" hint="New array of words to compare" />
		<cfargument name="startOld" type="numeric" required="false" hint="Start position in old array" />
		<cfargument name="endOld" type="numeric" required="false" hint="End position in old array" />
		<cfargument name="startNew" type="numeric" required="false" hint="Start position in new array" />
		<cfargument name="endNew" type="numeric" required="false" hint="End position in new array" />
		
		<cfset var aResult = arraynew(1) />
		<cfset var aMatchingEnd = arraynew(1) />
		<cfset var num = arraynew(2) />
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var st = structnew() />
		
		<cfif not structkeyexists(arguments,"startOld") or not isnumeric(arguments.startOld)>
			<cfset arguments.startOld = 1 />
		</cfif>
		<cfif not structkeyexists(arguments,"endOld") or not isnumeric(arguments.endOld)>
			<cfset arguments.endOld = arraylen(arguments.aOld) />
		</cfif>
		<cfif not structkeyexists(arguments,"startNew") or not isnumeric(arguments.startNew)>
			<cfset arguments.startNew = 1 />
		</cfif>
		<cfif not structkeyexists(arguments,"endNew") or not isnumeric(arguments.endNew)>
			<cfset arguments.endNew = arraylen(arguments.aNew) />
		</cfif>
		
		<!--- Special case: old array is empty --->
		<cfif not arraylen(arguments.aOld)>
			<cfloop from="1" to="#arraylen(arguments.aNew)#" index="i">
				<cfset st = structCreate(diff="+", newindex=i, newvalue=arguments.aNew[i]) />
				<cfset arrayappend(aResult,st) />
			</cfloop>
			<cfreturn aResult />
		</cfif>
		
		<!--- Special case: new array is empty --->
		<cfif not arraylen(arguments.aNew)>
			<cfloop from="1" to="#arraylen(arguments.aOld)#" index="i">
				<cfset st = structCreate(diff="-", oldindex=i, oldvalue=arguments.aOld[i]) />
				<cfset arrayappend(aResult,st) />
			</cfloop>
			<cfreturn aResult />
		</cfif>
		
		<!--- trim off the matching items at the beginning --->
		<cfloop condition="arguments.startOld lte arguments.endOld and arguments.startNew lte arguments.endNew and arguments.aOld[arguments.startOld] eq arguments.aNew[arguments.startNew]">
			<cfset st = structCreate(oldindex=arguments.startOld, newindex=arguments.startNew, diff="=", oldvalue=arguments.aOld[arguments.startOld], newvalue=arguments.aNew[arguments.startNew]) />
			<cfset arrayappend(aResult,st) />
			<cfset arguments.startOld = arguments.startOld + 1 />
			<cfset arguments.startNew = arguments.startnew + 1 />
		</cfloop>
		
		<!--- trim off the matching items at the end --->
		<cfloop condition="arguments.startOld lte arguments.endOld and arguments.startNew lte arguments.endNew and arguments.aOld[arguments.endOld] eq arguments.aNew[arguments.endNew]">
			<cfset st = structCreate(oldindex=arguments.endOld, newindex=arguments.endNew, diff="=", oldvalue=arguments.aOld[arguments.endOld], newvalue=arguments.aNew[arguments.endNew]) />
			<cfset arrayprepend(aMatchingEnd,st) />
			<cfset arguments.endOld = arguments.endOld - 1 />
			<cfset arguments.endNew = arguments.endNew - 1 />
		</cfloop>
		
		<!--- create the subsequence matrix --->
		<cfloop from="#arguments.startOld#" to="#arguments.endOld+1#" index="i">
			<cfset num[i][arguments.startNew] = 0 />
		</cfloop>
		<cfloop from="#arguments.startNew#" to="#arguments.endNew+1#" index="j">
			<cfset num[arguments.startOld][j] = 0 />
		</cfloop>
		<cfloop from="#arguments.startOld+1#" to="#arguments.endOld+1#" index="i">
			<cfloop from="#arguments.startNew+1#" to="#arguments.endNew+1#" index="j">
				<cfif arguments.aOld[i-1] eq arguments.aNew[j-1]>
					<cfset num[i][j] = num[i-1][j-1] + 1 />
				<cfelse>
					<cfset num[i][j] = max(num[i-1][j],num[i][j-1]) />
				</cfif>
			</cfloop>
		</cfloop>
		
		<!--- backtrack the subsequence --->
		<cfset arguments.endOld = arguments.endOld + 1 />
		<cfset arguments.endNew = arguments.endNew + 1 />
		<cfloop condition="arguments.endOld gt arguments.startOld or arguments.endNew gt arguments.startNew">
			<cfif (arguments.endOld gt arguments.startOld and arguments.endNew gt arguments.startNew and arguments.aOld[arguments.endOld-1] eq arguments.aNew[arguments.endNew-1])>
				<cfset st = structCreate(oldindex=arguments.endOld-1, newindex=arguments.endNew-1, diff="=", oldvalue=arguments.aOld[arguments.endOld-1], newvalue=arguments.aNew[arguments.endNew-1]) />
				<cfset arrayprepend(aMatchingEnd,st) />
				<cfset arguments.endOld = arguments.endOld - 1 />
				<cfset arguments.endNew = arguments.endnew - 1 />
			<cfelseif arguments.endNew gt arguments.startNew and (arguments.endOld eq arguments.startOld or num[arguments.endOld][arguments.endNew-1] gte num[arguments.endOld-1][arguments.endNew])>
				<cfset st = structCreate(newindex=arguments.endNew-1, diff="+", newvalue=arguments.aNew[arguments.endNew-1]) />
				<cfset arrayprepend(aMatchingEnd,st) />
				<cfset arguments.endNew = arguments.endNew - 1 />
			<cfelseif arguments.endOld gt arguments.startOld and (arguments.endNew eq arguments.startNew or num[arguments.endOld][arguments.endNew-1] lt num[arguments.endOld-1][arguments.endNew])>
				<cfset st = structCreate(oldindex=arguments.endOld-1, diff="-", oldvalue=arguments.aOld[arguments.endOld-1]) />
				<cfset arrayprepend(aMatchingEnd,st) />
				<cfset arguments.endOld = arguments.endOld - 1 />
			</cfif>
		</cfloop>
		
		<cfloop from="1" to="#arraylen(aMatchingEnd)#" index="i">
			<cfset arrayappend(aResult,aMatchingEnd[i]) />
		</cfloop>
		
		<cfreturn aResult />
	</cffunction>

	
	<cffunction name="structCreate" returntype="struct" output="false" access="public" hint="Creates and populates a struct with the provided arguments">
		
		<cfreturn duplicate(arguments) />
	</cffunction>
	
</cfcomponent>