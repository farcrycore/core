<cfcomponent displayname="Diff Result" hint="Encapsulates all funcationality for diffs" output="false">
	
	
	<cfset this.nl = "
" />
	
	
	<cffunction name="init" output="false" access="public" returntype="Any">
		
		<cfset this.dmp = createobject('component','farcry.core.packages.lib.diff.diff_match_patch').init() />
		
		<cfreturn this>
	</cffunction>
	
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
			<cfset st = refindnocase("<table[^>]*>(.*?)</table>",result,st.pos[1]+len(newString)+3,true) />
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
	
	<cffunction name="getPropertyDiff" access="public" output="false" returntype="struct" hint="Performs diff on the property according to its type">
		<cfargument name="typename" required="true" />
		<cfargument name="left" required="true" />
		<cfargument name="right" required="true" />
		<cfargument name="stMetadata" required="true" />
		
		<cfset var stResult = structnew() />
		<cfset var stTemp = structnew() />
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var thistype = "" />
		
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
				<cfset stResult.different = compare(stResult.left,stResult.right) neq 0 />
				<cfif stResult.different>
					<cfset stResult.aDiff = getDiff(old=stResult.left,new=stResult.right) />
					<cfset structappend(stResult,convertDiffToHighlights(stResult.aDiff),true) />
				</cfif>
			</cfcase>
			<cfcase value="string,longchar" delimiters=",">
				<cfset stResult.different = compare(stResult.left,stResult.right) neq 0 />
				<cfif stResult.different>
					<cfset stResult.aDiff = getDiff(old=stResult.left,new=stResult.right) />
					<cfset structappend(stResult,convertDiffToHighlights(stResult.aDiff),true) />
				</cfif>
			</cfcase>
			<cfcase value="category">
				<cfset stTemp[arguments.stMetadata.name] = arguments.left />
				<cfset stResult.left = application.formtools.category.oFactory.display(typename=arguments.typename,fieldname=arguments.stMetadata.name,stMetadata=arguments.stMetadata,stObject=stTemp) />
				<cfset stTemp[arguments.stMetadata.name] = arguments.right />
				<cfset stResult.right = application.formtools.category.oFactory.display(typename=arguments.typename,fieldname=arguments.stMetadata.name,stMetadata=arguments.stMetadata,stObject=stTemp) />
				<cfset stResult.different = compare(stResult.left,stResult.right) neq 0 />
				<cfif stResult.different>
					<cfset stResult.aDiff = getDiff(old=stResult.left,new=stResult.right) />
					<cfset structappend(stResult,convertDiffToHighlights(stResult.aDiff),true) />
				</cfif>
			</cfcase>
			<cfcase value="datetime" delimiters=",">
				<cfset stTemp[arguments.stMetadata.name] = arguments.left />
				<cfset arguments.stMetadata.value = arguments.left />
				<cfset stResult.left = application.formtools[stResult.formtool].oFactory.display(typename=arguments.typename,fieldname=arguments.stMetadata.name,stMetadata=arguments.stMetadata,stObject=stTemp) />
				<cfset stResult.leftHighlighted = arguments.left />
				<cfset stTemp[arguments.stMetadata.name] = arguments.right />
				<cfset arguments.stMetadata.value = arguments.right />
				<cfset stResult.right = application.formtools[stResult.formtool].oFactory.display(typename=arguments.typename,fieldname=arguments.stMetadata.name,stMetadata=arguments.stMetadata,stObject=stTemp) />
				<cfset stResult.rightHighlighted = arguments.right />
				<cfset stResult.different = compare(stResult.left,stResult.right) neq 0 />
			</cfcase>
			<cfcase value="webskin">
				<cfset stResult.leftHighlighted = application.coapi.coapiadmin.getWebskinDisplayname(typename=arguments.typename, template=arguments.left) />
				<cfset stResult.rightHighlighted = application.coapi.coapiadmin.getWebskinDisplayname(typename=arguments.typename, template=arguments.right) />
				<cfset stResult.different = compare(stResult.left,stResult.right) neq 0 />
			</cfcase>
			<cfcase value="integer">
				<cfif len(stResult.left)>
					<cfset stResult.leftHighlighted = round(stResult.left) />
				<cfelse>
					<cfset stResult.leftHighlighted = stResult.left />
				</cfif>
				<cfif len(stResult.right)>
					<cfset stResult.rightHighlighted = round(stResult.right) />
				<cfelse>
					<cfset stResult.rightHighlighted = stResult.right />
				</cfif>
				
				<cfset stResult.different = compare(stResult.left,stResult.right) neq 0 />
			</cfcase>
			<cfcase value="uuid,navigation">
				<cfset stResult.leftHighlighted = "" />
				<cfif len(stResult.left) AND isValid("uuid", stResult.left)>
					<cfset stTemp = application.fapi.getContentObject(objectid=stResult.left) />
					<!--- check if related object no longer exists --->
					<cfif structIsEmpty(stTemp)>
						<cfset stTemp.label = "(Object No Longer Exists)">
						<cfset stTemp.typename = "farCOAPI">
					</cfif>
					<cfset stResult.leftHighlighted = stTemp.label & " [" & application.stCOAPI[stTemp.typename].displayName & "]" & this.nl />
				</cfif>
				<cfset stResult.rightHighlighted = "" />
				<cfif len(stResult.right) AND isValid("uuid", stResult.right)>
					<cfset stTemp = application.fapi.getContentObject(objectid=stResult.right) />
					<!--- check if related object no longer exists --->
					<cfif structIsEmpty(stTemp)>
						<cfset stTemp.label = "(Object No Longer Exists)">
						<cfset stTemp.typename = "farCOAPI">
					</cfif>
					<cfset stResult.rightHighlighted = stTemp.label & " [" & application.stCOAPI[stTemp.typename].displayName & "]" & this.nl />
				</cfif>
				<cfset stResult.different = compare(stResult.leftHighlighted,stResult.rightHighlighted) neq 0 />
				<cfif stResult.different>
					<cfset stResult.aDiff = getDiff(old=stResult.leftHighlighted,new=stResult.rightHighlighted) />
					<cfset structappend(stResult,convertDiffToHighlights(stResult.aDiff),true) />
				</cfif>
			</cfcase>
			<cfcase value="array">
				<cfif (arraylen(stResult.left) and isstruct(stResult.left[1])) or (arraylen(stResult.right) and isstruct(stResult.right[1]))>
					<cfset stResult.leftRemoved = 0 />
					<cfset stResult.rightAdded = 0 />
					<cfloop from="1" to="#arraylen(stResult.left)#" index="i">
						<cfif i gt arraylen(stResult.right)>
							<cfset stResult.leftRemoved = stResult.leftRemoved + 1 />
						<cfelseif serializeJSON(stResult.left[i]) neq serializeJSON(stResult.right[i])>
							<cfset stResult.leftRemoved = stResult.leftRemoved + 1 />
							<cfset stResult.rightAdded = stResult.rightAdded + 1 />
						</cfif>
					</cfloop>
					<cfif arraylen(stResult.left) lt arraylen(stResult.right)>
						<cfset stResult.rightAdded = stResult.rightAdded + arraylen(stResult.right) - arraylen(stResult.left) />
					</cfif>
					
					<cfif stResult.leftRemoved eq 1>
						<cfset stResult.leftHighlighted = "<span style='color:##CC2504;font-weight:bold;'>1 item removed</span>" />
					<cfelseif stResult.leftRemoved gt 1>
						<cfset stResult.leftHighlighted = "<span style='color:##CC2504;font-weight:bold;'>#stResult.leftRemoved# items removed</span>" />
					</cfif>
					
					<cfif stResult.rightAdded eq 1>
						<cfset stResult.rightHighlighted = "<span style='color:##00BF0D;font-weight:bold;'>1 item added</span>" />
					<cfelseif stResult.rightAdded gt 1>
						<cfset stResult.rightHighlighted = "<span style='color:##00BF0D;font-weight:bold;'>#stResult.rightAdded# items added</span>" />
					</cfif>
				<cfelse>
					<cfset stResult.leftHighlighted = "" />
					<cfloop from="1" to="#arraylen(stResult.left)#" index="i">
						<cfset thistype = application.fapi.findType(stResult.left[i]) />
						<cfif len(thistype) AND structKeyExists(application.stCOAPI, thistype)>
							<cfset stTemp = application.fapi.getContentObject(typename=thistype,objectid=stResult.left[i]) />
							<cfset stResult.leftHighlighted = stResult.leftHighlighted & "* " & stTemp.label & " [" & application.stCOAPI[stTemp.typename].displayName & "]" & this.nl />
						<cfelse>
							<cfset stResult.leftHighlighted = stResult.leftHighlighted & "* " & stResult.left[i] & " [Unknown Type]" & this.nl />
						</cfif>
					</cfloop>
					<cfset stResult.rightHighlighted = "" />
					<cfloop from="1" to="#arraylen(stResult.right)#" index="i">
						<cfset thistype = application.fapi.findType(stResult.right[i]) />
						<cfif len(thistype)>
							<cfset stTemp = application.fapi.getContentObject(typename=thistype,objectid=stResult.right[i]) />
							<cfset stResult.rightHighlighted = stResult.rightHighlighted & "* " & stTemp.label & " [" & application.stCOAPI[stTemp.typename].displayName & "]" & this.nl />
						<cfelse>
							<cfset stResult.rightHighlighted = stResult.rightHighlighted & "* " & stResult.right[i] & " [Unknown Type]" & this.nl />
						</cfif>
					</cfloop>
					<cfset stResult.different = compare(stResult.leftHighlighted,stResult.rightHighlighted) neq 0 />
					<cfif stResult.different>
						<cfset stResult.aDiff = getDiff(old=stResult.leftHighlighted,new=stResult.rightHighlighted) />
						<cfset structappend(stResult,convertDiffToHighlights(stResult.aDiff),true) />
					</cfif>
				</cfif>
			</cfcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getObjectDiff" access="public" output="false" returntype="struct" hint="Performs diff on all visible properties according to their type">
		<cfargument name="left" type="struct" required="true" />
		<cfargument name="right" type="struct" required="true" />
		<cfargument name="stMetadata" type="struct" required="false" default="#structnew()#" />
		<cfargument name="includeInvisibleProperties" type="boolean" required="false" default="false" hint="Set to true to include properties that aren't displayed in forms. Note that this will never include system properties, only content properties." />
		
		<cfset var stPropMetadata = structnew() />
		<cfset var prop = "" />
		<cfset var stResult = structnew() />
		
		<cfset stResult.countDifferent = 0 />
		
		<cfloop collection="#arguments.left#" item="prop">
			<cfif not prop eq "typename">
				<cfif structKeyExists(application.stCOAPI[arguments.left.typename].stProps, prop) 
					AND not refindnocase("^farcry\.core\.packages\.(types\.types|types\.versions|rules\.rules)",application.stCOAPI[arguments.left.typename].stProps[prop].origin)>
					
					<cfset stPropMetadata = duplicate(application.stCOAPI[arguments.left.typename].stProps[prop].metadata) />
					<cfif structkeyexists(arguments.stMetadata,prop)>
						<cfset structappend(stPropMetadata,arguments.stMetadata[prop],true) />
					</cfif>
					
					<cfif (
							not structkeyexists(stPropMetadata,"ftArchive")
							OR stPropMetadata.ftArchive eq true
						)
						AND (
							(structkeyexists(stPropMetadata,"ftSeq") AND len(stPropMetadata.ftSeq)) 
							OR arguments.includeInvisibleProperties 
						)>
						
						<cfset stResult[prop] = getPropertyDiff(typename=arguments.left.typename,left=arguments.left[prop],right=arguments.right[prop],stMetadata=stPropMetadata) />
						<cfif stResult[prop].different>
							<cfset stResult.countDifferent = stResult.countDifferent + 1 />
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn stResult />
	</cffunction>
	
	
	<cffunction name="getDiff" returntype="array" access="public" hint="Returns an array of diff structs">
		<cfargument name="old" type="string" required="true" hint="Original array of words to compare" />
		<cfargument name="new" type="string" required="true" hint="New array of words to compare" />
		
		<cfset var aDiffs = this.dmp.diff_main(arguments.old,arguments.new) />
		<cfset var i = 0 />
		<cfset var aResult = arraynew(1) />
		<cfset var st	= '' />
		
		<cfset this.dmp.diff_cleanupEfficiency(aDiffs) />
		
		<cfloop from="1" to="#arraylen(aDiffs)#" index="i">
			<cfswitch expression="#aDiffs[i].operation.toString()#">
				<cfcase value="INSERT">
					<cfset st = structCreate(
						diff="+", 
						oldvalue="", 
						newvalue=aDiffs[i].text
					) />
					<cfset arrayappend(aResult,st) />
				</cfcase>
				
				<cfcase value="EQUAL">
					<cfset st = structCreate(
						diff="=", 
						oldvalue=aDiffs[i].text, 
						newvalue=aDiffs[i].text
					) />
					<cfset arrayappend(aResult,st) />
				</cfcase>
				
				<cfcase value="DELETE">
					<cfset st = structCreate(
						diff="-", 
						oldvalue=aDiffs[i].text, 
						newvalue=""
					) />
					<cfset arrayappend(aResult,st) />
				</cfcase>
			</cfswitch>
		</cfloop>
		
		<cfreturn aResult />
	</cffunction>

	
	<cffunction name="structCreate" returntype="struct" output="false" access="public" hint="Creates and populates a struct with the provided arguments">
		
		<cfreturn duplicate(arguments) />
	</cffunction>
	
</cfcomponent>