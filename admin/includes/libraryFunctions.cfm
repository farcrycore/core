<cffunction name="fDisplayPagination" output="true">
	<cfargument name="stPageination" type="struct" required="true">
	<cfparam name="arguments.stPageination.currentPage" default="1">
	<cfparam name="arguments.stPageination.startRow" default="1">
	<cfparam name="arguments.stPageination.maxRow" default="10">
	<cfparam name="arguments.stPageination.maxPageDisplay" default="5">
	<cfparam name="arguments.stPageination.urlParameters" default="">
	<cfparam name="arguments.stPageination.numberOfRecords" default="#arguments.stPageination.qList.recordCount#">
	<cfset stLocal.noPages = Ceiling(arguments.stPageination.numberOfRecords/arguments.stPageination.maxRow)>
	<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets" />
	<widgets:paginationDisplay
        QueryRecordCount="#arguments.stPageination.numberOfRecords#"
        FileName="#cgi.script_name#"
        MaxresultPages="5"
        MaxRowsAllowed="#arguments.stPageination.maxRow#"
        bEnablePageNumber="true"
        LayoutNumber="4"
        FirstLastPage="numeric"
        Layout_Previous="Previous"
        Layout_Next="Next"
		CurrentPageWrapper_Start="<span>"
		CurrentPageWrapper_End="</span>"		
        ExtraURLString="#arguments.stPageination.urlParameters#">
		<cfset arguments.stPageination.startRow = (arguments.stPageination.currentPage - 1) * arguments.stPageination.maxRow + 1>
<!--- paging calculation --->
<!--- 
<cfset pageOffsetDisplay = Ceiling(arguments.stPageination.maxPageDisplay/2)>
<cfset leftOffsetDisplay = pageOffsetDisplay>
<cfset rightOffsetDisplay = stLocal.noPages - pageOffsetDisplay + 1>
<cfif arguments.stPageination.currentPage LTE leftOffsetDisplay>
	<cfset startPageDisplay = 1>
	<cfset endPageDisplay = arguments.stPageination.maxPageDisplay>
<cfelseif arguments.stPageination.currentPage GTE rightOffsetDisplay>
	<cfset startPageDisplay = stLocal.noPages - arguments.stPageination.maxPageDisplay + 1>
	<cfset endPageDisplay = stLocal.noPages>
<cfelse>
	<cfset startPageDisplay = arguments.stPageination.currentPage - (pageOffsetDisplay - 1)>
	<cfset endPageDisplay = arguments.stPageination.currentPage + (pageOffsetDisplay - 1)>
</cfif>
	<cfoutput>
<cfif arguments.stPageination.numberOfRecords GT arguments.stPageination.maxRow>
<div class="utilBar">
	<h5><cfif arguments.stPageination.currentPage EQ 1>
	<span>Previous</span><cfelse>
	<a href="#listLast(cgi.script_name,'/')#?currentPage=#arguments.stPageination.currentPage-1#&#arguments.stPageination.urlParameters#">Previous</a>
	</cfif><cfif arguments.stPageination.currentPage*arguments.stPageination.maxRow GTE arguments.stPageination.numberOfRecords>
	<span>Next</span><cfelse>
	<a href="#listLast(cgi.script_name,'/')#?currentPage=#arguments.stPageination.currentPage+1#&#arguments.stPageination.urlParameters#">Next</a>
	</cfif>
	</h5>
	<span>Page</span>
	<cfloop index="i" from="#startPageDisplay#" to="#endPageDisplay#">
<cfif arguments.stPageination.currentPage EQ i>
	<span>#i#</span>
<cfelse>
<a href="#listLast(cgi.script_name,'/')#?currentPage=#i#&#arguments.stPageination.urlParameters#">#i#</a>
</cfif>
	</cfloop>
</div>
</cfif>
	</cfoutput>

	<!--- if paging then the start row is always one (as the query is a subset of the overrall query) --->
	<cfif arguments.stPageination.numberOfRecords NEQ arguments.stPageination.qList.recordCount>
		<cfset arguments.stPageination.startRow = 1>
	<cfelse>
		<cfset arguments.stPageination.startRow = (arguments.stPageination.currentPage * arguments.stPageination.maxRow) - arguments.stPageination.maxRow + 1>
	</cfif>
 --->
</cffunction>

<cfscript>
function fDisplayCategory(qListCategory,qstring,selectedcategoryID)
{		
	qNav = qListCategory;
    // initialise counters
    currentlevel=0; // nLevel counter
    ul=0; // nested list counter
	startLevel = 0;

    // build menu [bb: this relies on nLevels, starting from nLevel 2]
    for(i=1; i lt incrementvalue(qNav.recordcount); i=i+1)
    {
        if(qNav.nLevel[i] gte startLevel)
        {
            // update counters
            previouslevel=currentlevel;
            currentlevel=qNav.nLevel[i];
            
            // build nested list
            if(previouslevel eq 0) // if first item, open first list
            {
                writeOutput("<ul>");

                ul=ul+1;
            }
            else if(currentlevel gt previouslevel)
            {
                // if new level, open new list
                writeOutput("<ul>");
                ul=ul+1;
            }
            else if(currentlevel lt previouslevel)
            {
                // if end of level, close items and lists until at correct level
              
				writeOutput(repeatString("</li></ul></li>",previousLevel-currentLevel));
                ul=ul-(previousLevel-currentLevel);
            }
            else
            {
                // close item
                writeOutput("</li>");
            }
            
            // write item
            if(selectedcategoryID EQ qNav.ObjectID[i])
				writeOutput("<li>"&trim(qNav.ObjectName[i]));            
            else
            	writeOutput("<li><a href=""#cgi.script_name#?#qstring#&categoryID=#qNav.ObjectID[i]#"">"&trim(qNav.ObjectName[i])&"</a>");
        }
    }
     
    // end of data, close open items and lists
    writeOutput(repeatString("</li></ul>",ul));
}
</cfscript>