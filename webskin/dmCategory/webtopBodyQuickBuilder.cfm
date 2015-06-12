<cfsetting enablecfoutputonly="true">
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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->

<cfprocessingdirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec">


<!--- character to indicate levels --->
<cfset levelToken = "-">
<cfset out = "">


<sec:CheckPermission error="true" permission="developer">
	<cfif isDefined("form.submit")>
	    <cfscript>
		    aliasDelimiter = "||";
	        startPoint = form.startPoint;
	        makenavaliases = isDefined("form.makenavaliases") and form.makenavaliases;
	        if (makenavaliases)navaliaseslevel = form.navaliaseslevel;
	
	        structure = form.structure;
	
	        lines = listToArray(structure, "#chr(13)##chr(10)#");
	
	        // setup items with their level and objectids
	        items = arrayNew(1);
	        lastlevel = 1;
	
	        for (i = 1; i lte arraylen(lines); i = i + 1) {
	            prefix = spanIncluding(lines[i], levelToken);
	            prefixLen = len(prefix);
	
	            line = lines[i];
	            lineLen = len(line);
	
	            level = prefixLen + 1;
	            if (level gt lastlevel)
	                level = lastlevel + 1;
	            title = trim(right(lines[i], lineLen - prefixLen));
	
	            if (len(title) gt 0) {
	                item = structNew();
	                //item.title = ReplaceNoCase(title, "'", "''", "ALL");
	                item.title = listFirst(title,aliasDelimiter);
	                if(listLen(title,aliasDelimiter) eq 2){
	                	item.navAlias = lcase(replace(trim(listLast(title,aliasDelimiter))," ","_","ALL"));
	                }
	                else item.navAlias = "";
	                item.level = level;
	                item.objectid = application.fc.utils.createJavaUUID();
	                item.parentid = '';
	                arrayAppend(items, item);
	                lastlevel = item.level;
	            }
	        }
	
	        parentstack = arrayNew(1);
	        navstack = arrayNew(1);
	        arrayAppend(parentstack, startPoint);
	
	        // now figure out each item's parent node
	        lastlevel = 0;
	        for (i = 1; i lte arraylen(items); i = i + 1) {
	            if (items[i].level lt lastlevel) {
	                diff = lastlevel - items[i].level;
	                for (j = 0; j lte diff; j = j + 1) {
	                    arrayDeleteAt(parentstack, arraylen(parentstack));
	                    arrayDeleteAt(navstack, arraylen(navstack));
	                }
	            }
	            else if (items[i].level eq lastlevel) {
	                arrayDeleteAt(parentstack, arraylen(parentstack));
	                arrayDeleteAt(navstack, arraylen(navstack));
	            }
	
	            items[i].parentid = parentstack[arraylen(parentstack)];
	
	            arrayAppend(parentstack, items[i].objectid);
	
	            navtitle = lcase(rereplacenocase(items[i].title, "\W+", "_", "all"));
	            arrayAppend(navstack, rereplace(navtitle, "_+", "_", "all"));
	
	            if (makenavaliases) {
	                if (navaliaseslevel eq 0 or items[i].level lte navaliaseslevel)
	                    items[i].lNavIDAlias = arrayToList(navstack, '_');
	                else
	                    items[i].lNavIDAlias = '';
	
	            }
	            else
	                items[i].lNavIDAlias = '';
	
	            lastlevel = items[i].level;
	        }
			
	        // now finish setting up the structure of each item
	        for (i = 1; i lte arraylen(items); i = i + 1) {
	            structDelete(items[i], "level");
	        }
	    </cfscript>
	
	    <cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">		
	    <cfscript>
	        o_farcrytree = createObject("component", "#application.packagepath#.farcry.tree");
	        oCat = createObject("component", "#application.packagepath#.farcry.category");
	
	        for (i = 1; i lte arraylen(items); i = i + 1) {
	            oCat.addCategory(dsn=application.dsn,parentID=items[i].parentID,categoryID=items[i].objectID,categoryLabel=items[i].title);
	            if (len(items[i].lNavIDAlias) and len(items[i].navAlias) eq 0){oCat.setAlias(categoryid=items[i].objectID,alias=lcase(replace(trim(items[i].title)," ","_","ALL")));}
	            else if(len(items[i].navAlias) GT 0){oCat.setAlias(categoryid=items[i].objectID, alias=items[i].navAlias);}
	        }
	    </cfscript>

		<cfsavecontent variable="out">
	    <cfoutput>
	        <div class="alert alert-info">
		        <p>#application.rb.getResource("quickbuilder.labels.followingItemsCreated@text","The following items have been created")#:</p>
		        <ul>
					<cfset subS=listToArray('#arrayLen(items)#,"Category"')>
					<li>#application.rb.formatRBString("quickbuilder.messages.objects@text",subS,"{1} <strong>{2}</strong> content items")#</li>
		        </ul>
	        </div>
	    </cfoutput>
		</cfsavecontent>	
	</cfif>
	
    <cfscript>
        o = createObject("component", "#application.packagepath#.farcry.tree");
        qNodes = o.getDescendants(dsn=application.dsn, objectid=application.fapi.getCatID("root"));
    </cfscript>
		
	<cfoutput>
	<script type="text/javascript">
	    function updateDisplayBox()
	    {
	        document.theForm.displayMethod.disabled = !document.theForm.makehtml.checked;
	    }
	
	    function updateNavTreeDepthBox()
	    {
	        document.theForm.navaliaseslevel.disabled = !document.theForm.makenavaliases.checked;
	    }
	</script>

	<h1>#application.rb.getResource("quickbuilder.headings.catTreeQuickBuilder@text","Category Tree Quick Builder")#</h1>

	#out#

	<form method="post" class="f-wrap-1 f-bg-long wider" action="" name="theForm">
	<fieldset>
	

		<div class="form-horizontal">
			<div class="control-group string">
				<label class="control-label">
					#application.rb.getResource("quickbuilder.labels.createStructureWithin@label","Create structure within")#
				</label>
				<div class="controls">
					<select name="startPoint" id="startPoint">
						<option value="#application.fapi.getCatID("root")#" selected>#application.rb.getResource("quickbuilder.labels.root@label","Root")#</option>
						<cfloop query="qNodes">
							<option value="#qNodes.objectId#">#RepeatString("&nbsp;&nbsp;|", qNodes.nlevel)#- #qNodes.objectName#</option>
						</cfloop>
					</select>
				</div>
			</div>	
		</div>
		<div class="form-horizontal">
			<div class="control-group string">
				<label class="control-label">
					#application.rb.getResource("quickbuilder.labels.navAliases@label","Nav Aliases")#
				</label>
				<div class="controls">
					<input type="checkbox" name="makenavaliases" id="makenavaliases" checked="checked" value="1" onclick="updateNavTreeDepthBox()" class="f-checkbox" />
					#application.rb.getResource("quickbuilder.labels.createNavAliases@label","Create nav aliases for category nodes down")#	
					<br>
					<select name="navaliaseslevel">
						<option value="0">#application.rb.getResource("quickbuilder.labels.all@label","All")#</option>
						<option value="1" selected >1</option>
						<option value="2">2</option>
						<option value="3">3</option>
						<option value="4">4</option>
						<option value="5">5</option>
						<option value="6">6</option>
					</select>
					#application.rb.getResource("quickbuilder.labels.levels@label","levels")#
					<script>updateNavTreeDepthBox()</script>
				</div>
			</div>	
		</div>
		<div class="form-horizontal">
			<div class="control-group string">
				<label class="control-label">
					#application.rb.getResource("quickbuilder.labels.levelToken@label","Level Token")#
				</label>
				<div class="controls">
					<select name="levelToken" id="levelToken">
						<option>#levelToken#</option>
					</select>
				</div>
			</div>	
		</div>
		<div class="form-horizontal">
			<div class="control-group string">
				<label class="control-label">
					#application.rb.getResource("quickbuilder.labels.structure@label","Structure")#
				</label>
				<div class="controls">
					<textarea name="structure" id="structure" rows="10" cols="40" class="f-comments"></textarea>
				</div>
			</div>	
		</div>

		<input type="submit" value="#application.rb.getResource('quickbuilder.labels.buildCategoryStructure@label','Build Category Structure')#" name="submit" class="btn btn-primary" /><br />

	</fieldset>
	</form>
	
	<hr />

	<h4>#application.rb.getResource("quickbuilder.headings.instructions@text","Instructions")#</h4>
	<admin:resource key="quickbuilder.messages.quicklyBuildFarCryCategoryBlurb@text">
		<p>To quickly build a FarCry category structure, enter each node title on a new line. The hierarchy is determined by the characters in front of an item.</p>
		<p>Hierarchy can either descend (1 or more levels), ascend (1 level at most), or stay the same. To ascend one level, increase the number of levelToken occurrences on the item by 1 compared to the previous item. To descend, keep the number of level token occurrences in front to be the same as a previous item on the same level you wish to go back to. To stay in the same level, keep the levelToken occurrences the same.</p>
	</admin:resource>
	
	<hr />
	
	<h4>#application.rb.getResource("quickbuilder.headings.example@text","Example")#</h4>
	<p>
<pre>
Item 1
-Item 1.2
--Item 1.2.1
-Item 1.3
Item 2
-Item 2.1
--Item 2.2
Item 3
</pre>
	</p>
	
	<admin:resource key="quickbuilder.messages.@text">
		<p>For visual purposes spaces can be included between the item and the levelToken. Example:</p>
	</admin:resource>
	
	<p>
<pre>
Item 1
- Item 1.2
-- Item 1.2.1
</pre>
	</p>
	
	</cfoutput>

</sec:CheckPermission>

<cfsetting enablecfoutputonly="false">