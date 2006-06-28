<cfif thistag.executionMode eq "Start">
	<cfset Request.inHead.Scriptaculous = 1>
	
	
	<cfdirectory action="list" directory="#getDirectoryFromPath(expandPath('typeA.cfm'))#\images\gallery\thumbnails" name="qImages" filter="">
	
	
	<cf_paginate Query="#qImages#" PageLinksShown=10 RecordsPerPage=10>
	
	
	
	<div class="pagination pagination-categories">
	<p><span>Category 1</span> <a href="devtodo">Category 2</a> <a href="devtodo">Category 3</a> </p>
	<h4>Categories</h4>
	</div>
	
		
	<cfif isDefined("attributes.pagination") AND ListContains(attributes.pagination,"top")>
		<cf_paginateScroll />
	</cfif>
	

	
	<cfoutput>
	<div id="gallery">
		<cfset counter = 0>
		<ul class="thumbNailsWrap">
			
				<cf_paginateRecords r_stRecord="stImage">
					<cfset counter = counter + 1>
					<li>
						<a href="images/gallery/optimised/#stImage.Name#" rel="lightbox[Collections]" detail="<h5>Title of image</h5><p>Description of image drawn from alt property.</p>">
							<div><img id="thumbnail#counter#"  style="margin:0px;padding:0px;"
									src="images/gallery/thumbnails/#stImage.Name#" width="120px" 
									<!--- onclick="showFrame(#counter#);"  
									onmouseover="new Effect.Opacity(this,{from:.3,to:1});" 
									onmouseout="new Effect.Opacity(this,{from:1,to:.3});" ---> /></div>
						</a>
					</li>
				</cf_paginateRecords>
			
		</ul>
		<br style="clear:left;" />
	</div>	
	</cfoutput>
	
	<cfif isDefined("attributes.pagination") AND ListContains(attributes.pagination,"bottom")>
		<cf_paginateScroll />
	</cfif>
	
	</cf_paginate>
</cfif>