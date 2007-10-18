<cfsetting enablecfoutputonly="yes" />
<!---

ABOUT:  Provides links to Next, Previous, and page numbers (All as Links)

EXAMPLES:  Result Page:  « Previous (1 2 3 4 5) Next »
           Page: «   1 |... 4 | 5 | 6 | 7 | 8 | 9 ...| 11   »
           Page: ( 1 2 3 4 5 ... 11 ) Next »
           Page: 1 | 2 | 3 | 4 | 5 ...| 11 »
           « 1 |... 4 5 6 [7] 8 9 ...| 11 »

NOTE FROM THE AUTHOR:  I don't encrypt my files because I believe in sharing
                       knowledge. Please feel free to make whatever changes you
                       like (And by all means Email the update to me! :) 
                         - If you have suggestions for improving this tag please
                           send them to me and I'll check them out for possible
                           inclusion in upcoming versions of
                           CF_Search_NextPrevious.
                         - If I use your code in a future version of
                           CF_Search_NextPrevious then I will include your name,
                           email, and website address in the credit section of
                           this file.
==========================================
	
NAME:  <CF_Search_NextPrevious>

VERSION:  v1.10

AUTHOR:  Jeff Coughlin (Jeff@JeffCoughlin.com)
         http://www.JeffCoughlin.com/
	
DATE:  July 10, 2002
	
DATE REVISED:  September 13, 2005

MINIMUM CF VERSION:  v4.01

CF VER TESTED TO DATE:  v4.01 - v7.01
	
DESCRIPTION:  Search_NextPrevious Returns NEXT and PREVIOUS links (useful for 
              search results). But I didn't stop there... You will also get
              clickable page numbers (Google-style).

              Out of the box this tag is ready to go and only requires one
              attribute (an integer telling the tag how many results you have).
              Then the tag goes to work. However, there are a slew of additional
              options (attributes) you can use to manipulate the output of the
              tag. From how many page numbers you'd like displayed to the look and
              appearance of the output using stylesheets.  You even have the
              option to use preset stylesheets if you like or use your own.

              This tag supports XHTML in its output and most whitespace is
              removed.

              Here's a simple example. Lets say your search results returned 30
              pages. Currently you are viewing page 9. You've told the tag to only
              display five page numbers at a time. The result may look something
              like one of the following:
              "« Previous ( 7 8 9 10 11 ) Next »"
              "« 1|... 7 8 [9] 10 11 ...|30 »"

              There are more examples of how you might choose to output your
              results on my website (http://www.jeffcoughlin.com/). They are just
              a few examples of what your final display can look like.

WANT TO GET IT RUNNING QUICK?:
              If you'd prefer to skip all of the documentation and extra features
              and get this running quickly, no problem. Only a few simple
              steps are required. Choose either "Option A" or "Option B"

              "OPTION A" (Uses two URL variables)

                  1. Place this code anywhere above the code used in steps 2-3.

                         <cfparam name="url.strt" default="1" />
                         <cfparam name="url.show" default="10" />

                     If you'd like to use different URL names, please see info on
                     "StartrowURLName" and "MaxrowsURLName" below.

                     Note: It is suggested that you verify that the url.strt and
                     url.show variables are positive whole integers. Starting in
                     CF7 you can now do this right inside the <cfparam> tag,
                     otherwise you'll have to validate this on your own (see the
                     demo for an example).

                  2. Place this code anywhere in your page to display the
                     Prev/Next links.
                     (Note: Place the name of your 'query' and 'filename'
                     accordingly)

                          <CF_Search_NextPrevious
                              QueryRecordCount="#getSearchItems.RecordCount#"
                              FileName="yourfilename.cfm">

                     If using CF 6.0 or greater you are welcome to use the
                     <cfimport> tag. CF4/5 must use the above example.

                  3. To output the info you are requesting from the database use
                     a CFOUTPUT tag with the maxrows attribute and the startrow
                     attribute (I've also used these values in a <cfloop> tag as
                     well):
					
                         <cfoutput query="YourQueryName" startrow="#url.strt#"
                           maxrows="#url.show#">
                                 #Your_Variable_Name#
                         </cfoutput>

              "OPTION B" (Uses a single URL variable)

                  1. Place this code anywhere above the code used in steps 2-3.

                         <cfparam name="url.pg" default="1" />
                         <cfset variables.maxrows = 10 />
                         <cfset variables.startrow =
                           (url.pg * variables.maxRows) - variables.maxRows +1 />

                     If you'd like to use a different URL name, please see info on
                     "PageNumberURLName" below.
					 
                     Note: It is suggested that you verify that the url.pg
                     variable is a positive whole integer. Starting in CF7 you can
                     now do this right inside the <cfparam> tag, otherwise you'll
                     have to validate this on your own (see the demo for an
                     example).

                  2. Place this code anywhere in your page to display the
                     Prev/Next links.
                     (Note: Place the name of your 'query' and 'filename'
                     accordingly)

                          <CF_Search_NextPrevious
                              QueryRecordCount="#getSearchItems.RecordCount#"
                              bEnablePagenumber="true"
                              MaxRowsAllowed="#variables.maxrows#"
                              FileName="yourfilename.cfm">

                     If using CF 6.0 or greater you are welcome to use the
                     <cfimport> tag. CF4/5 must use the above example.

                  3. To output the info you are requesting from the database use
                     a CFOUTPUT tag with the maxrows attribute and the startrow
                     attribute (This one you may want to handle differently, but
                     here's my way to output the data :):
					
                         <cfoutput query="YourQueryName"
                           startrow="#variables.startrow#"
                           maxrows="#variables.maxrows#">
                                 #Your_Variable_Name#
                         </cfoutput>

                  For a better example, please see the demo that came with the
                  custom tag.

FARCRY SUPPORT:
          What is Farcry? To sum it up I'll post a quote from the Farcry homepage:

               "FarCry is an open source Content Management System (CMS),
               originally developed by Daemon. It's fully functional, and
               runs in a host of Enterprise environments today."

          To keep consistant with other Farcry custom tags there is an attribute
          called "objectID".  Although it doesn't do anything special in this
          custom tag it allows the user to send the UUID used in Farcry with any
          links provided in this tag. It does this in the format similar to other
          Farcry custom tags (which is to have an attribute called "objectID").

          For more information on Farcry, please visit their website at
          http://farcry.daemon.com.au/

XHTML and WHITESPACE:
          Whitespace is now properly removed from the HTML output when using this
          tag. To take advantage of this feature you may need to verify that
          whitespace management is turned on in the CF Administrator (In CF
          Administrator click on "settings". In CF4/5 make sure "Suppress
          whitespace by default" is checked. In CFMX make sure "Enable Whitespace
          Management" is checked. When calling the tag, make sure its NOT
          nested within a <cfoutput> tag. If it needs to be, you can just end the
          cfoutput tag like so:
          </cfoutput><CF_Search_NextPrevious ...><cfoutput>

          To take full advantage of XHTML you will have to declare your page as
          XHTML (Note: It is not required in order to use this tag). For more info
          on XHTML please refer to the World Wide Web Consortium
          (http://www.w3.org/TR/xhtml1/).

UPGRADE:  "PageText" attribute...
            As of v1.10 the default value for the attribute "PageText" has been
            changed to a blank value (it used to be set to the string
            "Result Page: ").

          "Linkstyle2" attribute...
            Beginning in v1.09 the attribute "LinkStyle2" has been removed. When
            this attribute was used the HTML output was simply too messy. Instead
            I suggest using CSS inheritance. Other than "Linkstyle1", the
            remaining style class attributes have not changed and still allow the
            user to over-ride any styles they may inherit. For an example, please
            try one of the pre-set style sheets provided with this tag using the
            attribute "PresetStyles".

          "Linkstyle1" attribute...
            As of v1.09 the attribute "Linkstyle1" is now being referenced as an
            id (instead of a class) in a <div> tag to help support inheritance.
            For an example, please try one of the pre-set style sheets provided
            with this tag using the attribute "PresetStyles".

          <table> tag...
            To better support web standards I have removed the unnecessary <table>
            tag from the HTML output starting in v1.09. Please keep this in mind
            when upgrading (the old table's width was set to 100%. It is suggested
            to use styles to properly format the HTML layout).

          Other than the above mentioned changes to watch out for no other work is
          required to upgrade and you may simply overwrite your existing tag
          (if using v1.00-1.02 please note below).

          Due to a major code revision in v1.03 all users still using v1.00-1.02
          should consider reviewing installation notes before upgrading.

REQUIRED:  The one attribute required is "QueryRecordCount".  Because it is just 
           an integer value that you are sending to the tag, the value does not
           actually have to be from a query record count.  Some people have used
           this tag to send their own custom values to the tag. I have not renamed 
           the attribute in order to assist people overwriting their older
           versions of this tag.

           In order for the links to work properly URL variables must be passed
           along.  You have the option of either using two variables ("url.strt"
           and "url.show") which allow you to have some control over the view in
           the url string, or you can use a single variable ("url.pg") which is
           used to determine which page result we are currently viewing.

     URL.SHOW     [Whole Integer] How many results you'd currently like to be
                  viewing.  Because this custom tag will default this URL string
                  for you, use of the variable is not required in your code.
                  However you do have the option to rename this variable (Refer
                  to "MaxrowsURLName" for more info).

                  If this variable is not available the custom tag will set it's
                  value to the one set in the "MaxRowsAllowed" attribute (default
                  is 25).

                  * Note: As of v1.10 this variable is no longer required if the
                  attribute "bEnablePageNumber" is set to true.  Please refer to
                  "bEnablePageNumber" and "PageNumberURLName" for more info).

    -- AND --

     URL.STRT     [Whole Integer] Which record (row returned) to start displaying. 
                  Because this custom tag will default this URL string for you,
                  use of the variable is not required in your code.  However you
                  do have the option to rename this variable (Refer to
                  "StartrowURLName" for more info).

                  If this variable is not available the custom tag will set it's
                  value to 1 (Assuming its the first record returned from the
                  query).

                  * Note: As of v1.10 this variable is no longer required if the
                  attribute "bEnablePageNumber" is set to true.  Please refer to
                  "bEnablePageNumber" and "PageNumberURLName" for more info).

     -- OR THE SINGLE VARIABLE --

     URL.PG       [Whole Integer] You may choose to use this instead of "url.strt"
                  and "url.show".  This determines which page number of results to
                  return.  Because this custom tag will default this URL string
                  for you, use of the variable is not required in your code.
                  However you do have the option to rename this variable (Refer to
                  "PageNumberURLName" for more info).

     (Tip) <cfoutput>
                  When you output your results it is suggested to have your code
                  look similar to this (change the QueryName to be your own
                  Query):

                  (note: it is suggested to set a <cfparam> at the top of your
                  code for the URLs you chose to use...
                  be it ("url.show" and "url.show") OR ("url.pg")
                  If you'd like to use different URL names, please see info on
                  "StartrowURLName", "MaxrowsURLName", and "PageNumberURLName").

                  "OPTION A" (uses two URL variables)

                      <cfparam name="url.strt" default="1" />
                      <cfparam name="url.show" default="10" />

                      <cfoutput query="YourQueryName" startrow="#url.strt#"
                       maxrows="#url.show#">

                  "OPTION B" (Uses a single URL varable. You must set
                              "bEnablePagenumber" to true in custom tag)

                       <cfparam name="url.pg" default="1" />
                       <cfset variables.maxrows = 10 />
                       <cfset variables.startrow =
                         (url.pg * variables.maxRows) - variables.maxRows +1 />

                       <cfoutput query="YourQueryName"
                         startrow="#variables.startrow#"
                         maxrows="#variables.maxrows#">

                  When you're ready to output . . .

                       USAGE:
                           <CF_Search_NextPrevious
                               QueryRecordCount = "#YourQueryName.RecordCount#"
                               FileName = "index.cfm"
                               objectID = "#url.objectID#"
                               bEnablePageNumber = "false"
                               PageNumberURLName = "pg"
                               MaxresultPages = "10"
                               MaxRowsAllowed = "25"
                               StartrowURLName = "strt"
                               MaxrowsURLName = "show"
                               Bookmark = "myBookmark"
                               ExtraURLString = "Status=#URL.Status#
                                  &Category=#URL.Category#
                                  &Sort=#URL.Sort#
                                  &Direction=#URL.Direction#"
                               DivStyle = "Style"
                               PresetStyle = "0"
                               LinkStyle1 = "Style1"
                               TextStyle1 = "TextStyle1"
                               ThisPageStyle = "MyPageStyle"
                               LayoutNumber = "1"
                               FirstLastPage = "numeric"
                               CenterPageOffset = "1"
                               PageText = "Page:&nbsp;"
                               Layout_prePrevious='<span class="previousLink">'
                               Layout_postPrevious="</span>"
                               Layout_preNext='<span class="nextLink">'
                               Layout_postNext="</span>"
                               Layout_Previous = "&laquo;&nbsp;Previous"
                               Layout_Next = "Next&nbsp;&raquo;"
                               Layout_Start = "(&nbsp;"
                               Layout_End = "&nbsp;)"
                               Separator_mid = "&nbsp;&nbsp;|&nbsp;&nbsp;"
                               Separator_start = "&nbsp;|&nbsp;...&nbsp;&nbsp;"
                               Separator_end = "&nbsp;&nbsp;...&nbsp;|&nbsp;"
                               CurrentPageWrapper_start = "&nbsp;&nbsp;[&nbsp;"
                               CurrentPageWrapper_end = "&nbsp;]&nbsp;&nbsp;">


ATTRIBUTES:
============

  ||---===== ( "General Use" ) =====---||

  QUERYRECORDCOUNT  (Required)  [Whole Integer] Tells the custom tag the entire
                                record count of your query.
                                Set it to #YOURQUERYNAME.RecordCount#".

  FILENAME          (optional)  [Ascii/Unicode/text] Which file the link should
                                go to (ie. "index.cfm"). Setting it to index.cfm
                                would have the link look like
                                <a href="index.cfm?URLinfo".
                                Default = "index.cfm"

  OBJECTID          (optional)  [UUID] Used for Farcry support. All this attribute
                                does is allow the user to submit a UUID.  When the
                                url string is returned to the user's client, the
                                variable objectID will appear first.

  BENABLEPAGENUMBER (optional)  [boolean] When enabled it allows you to use a
                                single URL variable to control what page the user
                                is currently viewing.  When enabled the two
                                variables "url.strt" and "url.show" are disabled.
                                Example:      index.cfm?pg=7
                                  instead of  index.cfm?strt=71&show=10
                                (Please also see: "PageNumberURLName")
                                Default="false".

  PAGENUMBERURLNAME (Optional)  [Ascii/Unicode/text] When "bEnablePageNumber" is
                                set to true a single URL variable (url.pg) is
                                passed along in each link in order for the custom
                                tag to know which results to display.  Using this
                                attribute you have the option to override the name
                                of this url variable (instead of having it called
                                "url.pg").
                                Example: "page" or "pg"
                                Default = "pg"

  MAXRESULTPAGES    (Optional)  [Whole Integer] This number defines how many page
                                numbers we want to display.
                                Default = 5

  MAXROWSALLOWED    (Optional)  [Whole Integer] How many records you'd like to
                                have displayed per page (e.g. "15").
                                Default = "25".

  STARTROWURLNAME   (Optional)  [Ascii/Unicode/text] In order for each page to
                                work properly two URL variables must be sent.
                                There is a default set already, however you may
                                wish to use a different URL name for whatever
                                reason.  If so, just enter the URL Name you'd
                                like to have.
                                (note: If bEnablePageNumber is activated then
                                this variable is ignored)
                                Example: "startrow" or "strt"
                                Default = "strt".

  MAXROWSURLNAME    (Optional)  [Ascii/Unicode/text] In order for each page to
                                work properly two URL variables must be sent.
                                There is a default set already, however you may
                                wish to use a different URL name for whatever
                                reason.  If so, just enter the URL Name you'd
                                like to have.
                                (note: If bEnablePageNumber is activated then
                                this variable is ignored)
                                Example: "maxrows" or "maxr"
                                Default = "show".

  BOOKMARK          (Optional)  [Ascii/Unicode/text] Optional named anchor target
                                for the generated links.
                                e.g. If you set the value to "ThisSpot" each link
                                     would end with the string #ThisSpot

  EXTRAURLSTRING    (Optional)  [Ascii/Unicode/text] (Strongly Recomended) Almost
                                everyone coding today uses their own URL
                                variables. So why should I deny them? If you have
                                any other URL Variables you'd like to have passed
                                along, this is where you'd put that string. My
                                example above shows some extra URL variables I was 
                                carrying which determined certain WHERE Clause
                                filters the client wanted.
                                default = "".

  ||---===== ( "Styles" ) =====---||

  DIVSTYLE          (Optional)  [Ascii/Unicode/text] If using stylesheets you can
                                tell the custom tag to use a specific division
                                <div> tag that you've preset. The value you send
                                here will go into the id field
                                (e.g. <div id="MyDivStyle">). Of course you can
                                always wrap the custom tag in your own <div> tag
                                anyway, however someone requested this feature
                                stating that it would still benefit them. So I
                                added it. If not used you will not see it in the
                                HTML output.
                                default = "".

  PRESETSTYLE       (Optional)  [Whole Integer] Options are "0,1,2,3". If you'd
                                like, I've put together some quick stylesheets
                                that I've used on and off. By selecting one of
                                these numbers you will be choosing one of the
                                pre-set style sheets I've input. NONE = "0".
                                Feel free to add more for yourself, just remember
                                to keep a copy of them after implimenting newer
                                versions of this tag.
                                default = "0".

  LINKSTYLE1        (Optional)  [Ascii/Unicode/text] Use this attribute to add a
                                style to the attributes "Layout_Next" and
                                "Layout_Previous".  Will be displayed using an id.
                                Example: <span id="MyStyleName">Next</span>
                                You can combine this attribute with the "DivStyle"
                                attribute. For a useful example, please try one of
                                the preset styles.
                                default = "".

  LINKSTYLE2      (Deprecated)  As of version 1.09 of this Custom tag, this
                                attribute is no longer supported. It was making
                                the HTML output too messy. It is suggested to use
                                a <div> tag instead. If you like you can use one
                                of the preset styles as an example.

  TEXTSTYLE1        (Optional)  [Ascii/Unicode/text] Use this attribute to add a
                                style to the attributes "PageText",
                                "Layout_Start", and "Layout_End". It will be
                                displayed using a class.
                                Example: <span class="MyStyleName">Next</span>
                                You can combine this attribute with the "DivStyle"
                                attribute. For a useful example, please try one of
                                the preset styles.
                                default = "".

  THISPAGESTYLE     (Optional)  [Ascii/Unicode/text] Use this attribute to add a
                                style for the page number currently displayed.
                                You can combine this attribute with the "DivStyle"
                                attribute.
                                Default = "".

  ||=====--- ( "Visual Layout" ) =====---||

  LAYOUTNUMBER      (Optional)  [Whole Integer] Options are "1,2,3". You have the
                                option to select different ways the layout
                                can appear.
                                
                                default = "1". 
                                   Option 1 might look like
                                     "Page: ( 1 2 3 4 5 ... 11 ) Next »"
                                   Option 2 might look like
                                     "Page: 1 | 2 | 3 | 4 | 5 ...| 11 »"
                                   Option 3 might look like
                                     "Page: 1 2 [ 3 ] 4 5 ...| 11 »"

                                   Note:  The "11" above is the same as last page.
                                      Also the attribute FirstLastPage was set to
                                      "numeric". All layout settings can be
                                      overridden using anyone of the "Layout
                                      Attributes"
                                        (see: "Layout Attbutes" in the Attributes
                                        section below. You can also look at
                                        example #5 in the demo provided with this
                                        custom tag.)

  FIRSTLASTPAGE     (Optional)  [Ascii/Unicode/text] Options are 
                                "none,numeric,text". If more page numbers are
                                returned than what is set in the attribute
                                MAXRESULTPAGES, you have the option to have the
                                "First" and "Last" page links appear. They can
                                appear as the text strings "First,Last" or as the
                                page numbers themselves. In the example below, our
                                result returned 58 pages, but I have
                                MAXRESULTPAGES set to 5, and I am currently
                                viewing page 16.
                                Page: (1 ... 14 15 16 17 18 ... 58 )
                                default = "none"

  CENTERPAGEOFFSET  (Optional)  [Whole Integer] This is an advanced feature that
                                you likely not wish to adjust.  It is impossible
                                for the current page number to be centered in the
                                list of links when the MaxresultPages attribute is
                                set to an even number.
                                However, this attribute allows you to decide where 
                                you'd like the current page number to be offset
                                from the center. Valid values are whole integers
                                only.
                                   e.g. "« Previous ( 7 8 9 10 11 12 ) Next »"
                                In the example above there are six pages returned
                                (7-12). There is no way to have the current page
                                number be centered. Since the default for this
                                attrbute is set to "1" the current page number in
                                the example above would be "10".
                                  The default is "1" so...
                                      "0" would move it once to the left.
                                      "-1" would move it twice to the left.
                                      "2" would move it once to the right
                                      (I think you get the idea).
                                Note: This attrbute is ignored if the
                                MaxresultPages attribute is an odd number.
                                default = "1".

  ||---===== ( "Visable Text" ) =====---||

  PAGETEXT          (Optional)  [Ascii/Unicode/text] The text displayed just
                                before the page numbers are shown. If we were to
                                use the string "Page Numbers: " the result might
                                look something like this
                                "Page Numbers: (1 2 3 4)".
                                You may opt to leave this blank.
                                default = "".

  ||---===== ( "Layout Attributes" Text/Ascii ) =====---||
        Note:  All of these are pre-defined using the attribute "LayoutNumber"
               (default = 1).  However, you have the option to override any of
               these by using any of the attributes below.

  LAYOUT_PREPREVIOUS            [Ascii/Unicode/text] Anything you'd like displayed
                    (Optional)  BEFORE the "Previous" link appears.  Useful for
                                applying a custom style to the "Previous" link.
                                Example: '<span class="previousLink">'
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  LAYOUT_POSTPREVIOUS           [Ascii/Unicode/text] Anything you'd like displayed
                    (Optional)  AFTER the "Previous" link appears.  Useful for
                                applying a custom style to the "Previous" link.
                                Example: "</span>"
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  LAYOUT_PRENEXT    (Optional)  [Ascii/Unicode/text] Anything you'd like displayed
                                BEFORE the "Next" link appears.  Useful for
                                applying a custom style to the "Next" link.
                                Example: '<span class="nextLink">'
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  LAYOUT_POSTNEXT   (Optional)  [Ascii/Unicode/text] Anything you'd like displayed
                                AFTER the "Next" link appears.  Useful for
                                applying a custom style to the "Next" link.
                                Example: "</span>"
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  LAYOUT_PREVIOUS   (Optional)  [Ascii/Unicode/text] What you'd like displayed for
                                the "previous" link.
                                Example: If you set it to "&laquo;&nbsp;Prev" the
                                result may look somthing like "« Prev ( 3 4 5 )".
                                You could for example use an <img> tag here:
                                Layout_Previous="<img src="..." />".
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  LAYOUT_NEXT       (Optional)  [Ascii/Unicode/text] What you'd like displayed for
                                the "next" link.
                                Example: If you set it to "Next&nbsp;&raquo;" the
                                result may look somthing like "( 3 4 5 ) Next »".
                                You could for example use an <img> tag here:
                                Layout_Next="<img src="..." />".
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  LAYOUT_START      (Optional)  [Ascii/Unicode/text] Set this value to a character
                                you'd like displayed before the first page number
                                link.
                                Example: If you set it to "(&nbsp;" the result
                                might look something like "( 3 4 5 )" where if you
                                set it to "((&nbsp;" it might look like
                                "(( 3 4 5 ))" (Please also refer to Layout_End).
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  LAYOUT_END        (Optional)  [Ascii/Unicode/text] Set this value to a character
                                you'd like displayed after the last page number
                                link.
                                Example: If you set it to "&nbsp;)" the result
                                might look something like "( 3 4 5 )" where if you
                                set it to "&nbsp;))" it might look like
                                "(( 3 4 5 ))" (Please also refer to Layout_Start).
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  SEPARATOR_MID     (Optional)  [Ascii/Unicode/text] Set this value to override
                                the separator between the page numbers.
                                Example: If I set the value to "&nbsp;|&nbsp;" the
                                result might look something like "3 | 4 | 5"
                                whereas if I set the value to "&nbsp;*&nbsp;"the
                                result may look something like "3 * 4 * 5".
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  SEPARATOR_START   (Optional)  [Ascii/Unicode/text] Set this value to override
                                the separator displayed between the "first" link
                                (link that brings you to the first page of
                                results) and the page number just after it.
                                Example: If I set the value to
                                "&nbsp;|&nbsp;...&nbsp;" the result might look
                                something like "1 | ... 8 | 9 | 10", whereas if I
                                set it to "&nbsp;&lt;-&nbsp;" the result might
                                look something like "1 <- 8 | 9 | 10".
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  SEPARATOR_END     (Optional)  [Ascii/Unicode/text] Set this value to override
                                the separator displayed between the "last" link
                                (link that brings you to the last page of results)
                                and the page number just before it.
                                Example: If I set the value to
                                "&nbsp;...&nbsp;|&nbsp;" the result might look
                                something like "8 | 9 | 10 ... | 40", whereas if I
                                set it to "&nbsp;-&gt;&nbsp;" the result might
                                look something like "8 | 9 | 10 -> 40".
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  CURRENTPAGEWRAPPER_START      [Ascii/Unicode/text] Set this to any value you'd 
                    (Optional)  like to have appear BEFORE the current page number
                                displayed.
                                Example: If you set the start to "&nbsp;[&nbsp;"
                                and the end to "&nbsp;]&nbsp;" the result may look
                                something like: « 1 |... 4 5 6 [ 7 ] 8 9 ...| 11 »
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.

  CURRENTPAGEWRAPPER_END        [Ascii/Unicode/text] Set this to any value you'd 
                    (Optional)  like to have appear AFTER the current page number
                                displayed.
                                Example: If you set the start to "&nbsp;[&nbsp;"
                                and the end to "&nbsp;]&nbsp;" the result may look
                                something like: « 1 |... 4 5 6 [ 7 ] 8 9 ...| 11 »
                                * Default is set by the LayoutNumber attribute,
                                  but will be overridden if a value is set here.
                                  You "can" set this to blank and it will not be
                                  used in the HTML output.


If you have any trouble implementing this tag, send an e-mail to
Jeff@JeffCoughlin.com or look for examples on http://www.JeffCoughlin.com. A demo
is included with this tag. If you did not receive the demo, please go to the above 
URL and download another copy of the tag.

Feel free to customize the look and feel of the output to fit in with your
own site.  I just tried to keep the basic look as simple as possible.  One thing
you could do for example is use images for the NEXT and PREVIOUS links.

I had a difficult time knowing which version of this tag I had on different
CF servers. So I added a URL Variable called URL.GetVersion. To use it, display
your results page as normal. Then add the following characters to your URL string
"&GetVersion=" (without quotes).

This tag is provided free of charge and without any warranty (even implied) as to
merchantability, or usability.  The author assumes no responsibility for any
damage that implementation of this tag may cause on users' systems.

AUTHOR:
Jeff Coughlin	(Jeff@JeffCoughlin.com)
http://www.JeffCoughlin.com/
If you like this tag please send me an Email and let me know.  Keep those requests
coming in for updates and features.  Your ideas fuel my talent :)

ACKNOWLEDGEMENTS:
Spike Milligan
http://www.spike.org.uk/
In version 1.10 Spike added the attribute "bookmark"

Revision Information (Changelog):

2005-09-13    v1.10
     - Added attribute "bEnablePageNumber"
     - Added attribute "PageNumberURLName"
     - Added attribute "bookmark"
     - Added attribute "Layout_prePrevious"
     - Added attribute "Layout_postPrevious"
     - Added attribute "Layout_preNext"
     - Added attribute "Layout_postNext"
     - Added LayoutNumber "4"
     - Added example 6 to demo
     - Prefixing url names with "url." is no longer required.
     - default value for attribute "PageText" set to blank.
     - Fixed a minor bug where the current page number might not display correctly

2004-10-06    v1.09
     - Added attribute "objectID" (for Farcry Support)
     - Added attribute "layout_previous"
     - Added attribute "layout_next"
     - Added attribute "layout_start"
     - Added attribute "layout_end"
     - Added LayoutNumber "3"
     - Changed default filename from "./" to "index.cfm"
     - Removed unnecessary <table> tag from output to support people wishing to
       use a tableless presentation.
     - Removed attribute "EnableClasses" (now autochecking for styles).
     - Removed attribute "LinkStyle2" (now using <div> tag for style inheritance).
     - Changed attribute "LinkStyle1" to be used as an id (instead of a class).
     - If you are upgrading to this tag from an older version and you
       are currently using the above attribute (for custom styles),
       please see upgrade documentation.
     - Moved url.strt and url.show after ExtraURLString in <a> anchor tags
     - ExtraURLString does not have to begin with an ampersand now
     - When using ExtraURLString, the ampersand can be written as "&"
       and will be converted to "&amp;" for the <a> anchor tags.
     - Fixed some formatting issues with
       "CurrentPageWrapper_start" and "CurrentPageWrapper_end"
     - Now all layout attributes have the option to be set to blank.
     - Updated documentation (also grouped attributes in documentation).
     - Minor bug fixes

2004-09-01    v1.08
     - XHTML 1.0 support
     - Removed most whitespace from output
     - Added attribute "DivStyle"
     - Added attribute "EnableClasses"
     - Added attribute "Separator_mid"
     - Added attribute "Separator_start"
     - Added attribute "Separator_end"
     - Added attribute "CurrentPageWrapper_start"
     - Added attribute "CurrentPageWrapper_end"
     - Added example 5 to demo
     - Minor bug fixes

2004-07-08    v1.07
     - Current page number now centers properly (Google-style)
     - Optimized code.
     - Added attribute "CenterPageOffset"
     - Minor fixes

2004-06-18    v1.06
     - Added Demo.cfm (and areacodes.mdb)
     - Added attribute "ThisPageStyle" 
     - Added PresetStyle "3" for dark backgrounds.
     - Fixed attribute StartrowURLname not rendering properly.
     - Updated documentation.

2003-06-11    v1.05
     - Added attribute "PageText"
     - Added attribute "LayoutNumber"
     - Added attribute "PresetStyle"
     - Added attribute "FirstLastPage"

2003-01-02    v1.04
     - Added attribute "StartrowURLName"
     - Added attribute "MaxrowsURLName"
     - Added URL Variable "URL.GetVersion"

2002-12-16    v1.03
     - Added attribute "TextStyle1"
     - Added attribute "FileName"
     - Fixed an error with some versions of Netscape 4.x
     - Fixed an error where the first page number would sometimes link
       incorrectly.

2002-10-21    v1.02
     - Cleaned up tag so that it doesn't have to be called more than
       once to function properly

2002-07-11    v1.01
     - Added attribute "LinkStyle1"
     - Added attribute "LinkStyle2"

2002-07-10    v1.00
     - Initial Release
==========================================
--->


<!--- START Custom Tag Variable verification --->
  <cfif not IsDefined("attributes.QueryRecordCount")>
    <cfoutput><br /><span style="background-color: ##fff; color: ##000;"><strong>Error in Custom Tag CF_Search_NextPrevious:</strong> The attribute <strong><em>QueryRecordCount</em></strong> is required.</span></cfoutput>
    <cfexit />
  </cfif>
  <cfif IsDefined("attributes.FirstLastPage")>
    <cfif ListFindNoCase("none,text,numeric", attributes.FirstLastPage) EQ 0>
      <cfoutput><br /><span style="background-color: ##fff; color: ##000;"><strong>Error in Custom Tag CF_Search_NextPrevious:</strong> The attribute <strong><em>FirstLastPage</em></strong> can only be one of the following "none,text,numeric"<br />However, the Attribute is not required (default = "none")</span></cfoutput>
      <cfexit />
    </cfif>
  </cfif>
<!--- END Custom Tag Variable verification --->


<!---==============[ START Custom Tag for DISPLAY ]==============--->

<!--- START - Declare local variables --->

<cfparam name="variables.Search_NextPrevious_VersionNumber" default="v1.10" />
<cfparam name="variables.Search_NextPrevious_Update_Date" default="{ts '2005-09-13 11:37:00'}" />
<!--- "General Use" --->
<cfparam name="attributes.FileName" default="index.cfm" />
<cfparam name="attributes.objectID" default="" />
<cfparam name="attributes.MaxResultPages" default="5" />
<cfparam name="attributes.MaxRowsAllowed" default="25" />
<cfparam name="attributes.StartrowURLName" default="url.strt" />
<cfparam name="attributes.MaxrowsURLName" default="url.show" />
<cfparam name="#attributes.StartrowURLName#" default="1" />
<cfparam name="#attributes.MaxrowsURLName#" default="#attributes.MaxRowsAllowed#" />
<cfparam name="attributes.ExtraURLString" default="" />
<cfparam name="attributes.bookmark" default="" />
<cfparam name="attributes.bEnablePageNumber" default="0" />
<cfparam name="attributes.PageNumberURLName" default="url.pg" />
<cfparam name="#attributes.PageNumberURLName#" default="1" />
<!--- "Styles" --->
<cfparam name="attributes.DivStyle" default="" />
<cfparam name="attributes.PresetStyle" default="0" />
<cfparam name="attributes.LinkStyle1" default="" />
<cfparam name="attributes.TextStyle1" default="" />
<cfparam name="attributes.ThisPageStyle" default="" />
<!--- "Visual Layout" --->
<cfparam name="attributes.LayoutNumber" default="1" />
<cfparam name="attributes.FirstLastPage" default="none" />
<cfparam name="attributes.CenterPageOffset" default="1" /> <!--- Default for "even" --->
<cfparam name="attributes.showCurrentPageDetails" default="false" /> <!--- Show Page [x] of [y] --->
<!--- "Layout attributes" Text/Ascii (All have the option to be set to blank) --->
<cfscript>
  // Using IsDefined() allows the user to send "" (blank) for a value
  // I abberviated "boolean Is Pre-defined VariableName" as "blPreDef_Variable"
  // sorry, I couldn't think of a cleaner way to write this part of the code and still support CF4.x
  // It will not hinder performance, but just looks messier than I'd like =\
  if (IsDefined("attributes.Layout_previous")){ // Display for "previous" link
    variables.blPreDef_Layout_previous=true;
  }else{
    variables.blPreDef_Layout_previous=false;
    attributes.Layout_previous='';
  }
  if (IsDefined("attributes.Layout_next")){ // Display for "next" link.
    variables.blPreDef_Layout_next=true;
  }else{
    variables.blPreDef_Layout_next=false;
    attributes.Layout_next='';
  }
  if (IsDefined("attributes.Layout_prePrevious")){ // Ascii before "previous" link.
    variables.blPreDef_Layout_prePrevious=true;
  }else{
    variables.blPreDef_Layout_prePrevious=false;
    attributes.Layout_prePrevious='';
  }
  if (IsDefined("attributes.Layout_postPrevious")){ // Ascii after "previous" link.
    variables.blPreDef_Layout_postPrevious=true;
  }else{
    variables.blPreDef_Layout_postPrevious=false;
    attributes.Layout_postPrevious='';
  }
  if (IsDefined("attributes.Layout_preNext")){ // Ascii before "next" link.
    variables.blPreDef_Layout_preNext=true;
  }else{
    variables.blPreDef_Layout_preNext=false;
    attributes.Layout_preNext='';
  }
  if (IsDefined("attributes.Layout_postNext")){ // Ascii after "next" link.
    variables.blPreDef_Layout_postNext=true;
  }else{
    variables.blPreDef_Layout_postNext=false;
    attributes.Layout_postNext='';
  }
  if (IsDefined("attributes.Layout_Start")){ // Display for starting text before page numbers.
    variables.blPreDef_Layout_Start=true;
  }else{
    variables.blPreDef_Layout_Start=false;
    attributes.Layout_Start='';
  }
  if (IsDefined("attributes.Layout_End")){ // Display for starting text after page numbers.
    variables.blPreDef_Layout_End=true;
  }else{
    variables.blPreDef_Layout_End=false;
    attributes.Layout_End='';
  }
  if (IsDefined("attributes.Separator_mid")){ // Display for "separators" between page numbers.
    variables.blPreDef_Layout_separator_mid=true;
  }else{
    variables.blPreDef_Layout_separator_mid=false;
    attributes.Separator_mid='';
  }
  if (IsDefined("attributes.Separator_start")){ // (Please see Attribute info above).
    variables.blPreDef_Layout_Separator_start=true;
  }else{
    variables.blPreDef_Layout_Separator_start=false;
    attributes.Separator_start='';
  }
  if (IsDefined("attributes.Separator_end")){ // (Please see Attribute info above).
    variables.blPreDef_Layout_Separator_end=true;
  }else{
    variables.blPreDef_Layout_Separator_end=false;
    attributes.Separator_end='';
  }
  if (IsDefined("attributes.CurrentPageWrapper_start")){ // (Please see Attribute info above).
    variables.blPreDef_CurrentPageWrapper_start=true;
  }else{
    variables.blPreDef_CurrentPageWrapper_start=false;
    attributes.CurrentPageWrapper_start='';
  }
  if (IsDefined("attributes.CurrentPageWrapper_end")){ // (Please see Attribute info above).
    variables.blPreDef_CurrentPageWrapper_end=true;
  }else{
    variables.blPreDef_CurrentPageWrapper_end=false;
    attributes.CurrentPageWrapper_end='';
  }
  if (IsDefined("attributes.PageText")){ // Ascii text displayed before everthing else
    variables.blPreDef_PageText=true;
  }else{
    variables.blPreDef_PageText=false;
    attributes.PageText='';
  }
</cfscript>
<!--- END - Declare local variables --->


<cfscript>
  // General Use
  variables.QueryRecordCount   = attributes.QueryRecordCount;
  variables.FileName           = attributes.FileName;
  variables.objectID           = attributes.objectID;
  variables.MaxResultPages     = attributes.MaxResultPages;
  variables.ExtraURLString     = attributes.ExtraURLString;
  variables.show_string        = attributes.MaxrowsURLName;
  variables.strt_string        = attributes.StartrowURLName;
  variables.show               = evaluate(variables.show_string);
  variables.strt               = evaluate(variables.strt_string);
  variables.bEnablePageNumber  = attributes.bEnablePageNumber;
  variables.PageNumber_string  = attributes.PageNumberURLName;
  // Styles
  variables.DivStyle           = attributes.DivStyle; // Use instead of (or with) classes
  variables.PresetStyle        = attributes.PresetStyle;
  variables.LinkStyle1         = attributes.LinkStyle1;
  variables.TextStyle1         = attributes.TextStyle1;
  variables.ThisPageStyle      = attributes.ThisPageStyle;
  // Visual Layout
  variables.LayoutNumber       = attributes.LayoutNumber;
  variables.FirstLastPage      = attributes.FirstLastPage;
  // Visable Text
  variables.PageText           = attributes.PageText;
  // Layout Text/Ascii
  variables.layout_previous                 = attributes.layout_previous;
  variables.layout_next                     = attributes.layout_next;
  variables.Layout_Start                    = attributes.Layout_Start;
  variables.Layout_prePrevious              = attributes.Layout_prePrevious;
  variables.Layout_postPrevious             = attributes.Layout_postPrevious;
  variables.Layout_preNext                  = attributes.Layout_preNext;
  variables.Layout_postNext                 = attributes.Layout_postNext;
  variables.Layout_End                      = attributes.Layout_End;
  variables.Layout_separator_mid            = attributes.Separator_mid;
  variables.Layout_separator_start          = attributes.Separator_start;
  variables.Layout_separator_end            = attributes.Separator_end;
  variables.Layout_CurrentPageWrapper_start = attributes.CurrentPageWrapper_start;
  variables.Layout_CurrentPageWrapper_end   = attributes.CurrentPageWrapper_end;

  // Prefix a pound symbol (#) to the Bookmark if it doesn't already exist
  if (left(attributes.bookmark,1) neq "##" and attributes.bookmark neq ''){
    attributes.bookmark = "##" & attributes.bookmark;
  }

  // Prefix URL-Named attribute values with "url." if it doesn't already exist
  if (left(variables.strt_string, 4) eq "url."){
    variables.strt_string = RemoveChars(variables.strt_string, 1, 4);}
  if (left(variables.show_string, 4) eq "url."){
    variables.show_string = RemoveChars(variables.show_string, 1, 4);}
  if (left(variables.PageNumber_string, 4) eq "url."){
    variables.PageNumber_string = RemoveChars(variables.PageNumber_string, 1, 4);}

  // Allow attribute CenterPageOffset if MaxResultPages is an even number
  if (variables.MaxResultPages mod 2 eq 0) { //if even
    variables.CenterPageOffset = attributes.CenterPageOffset;
  }else{ // else set to default
    variables.CenterPageOffset = 0; // default for "odd"
  }

// Prepare Page Math

  // This page number
  if (variables.bEnablePageNumber){
  	// Only Valid if bEnablePageNumber is true
    variables.thisPageNumber = evaluate(variables.PageNumber_string);
  }else{
    variables.ThisPageNumber = ceiling(variables.strt/variables.show);
  }

  // Page numbers for This, Next, and Previous (Only Valid if bEnablePageNumber is true)
  variables.previousPageNumber = variables.thisPageNumber -1;
  variables.nextPageNumber     = variables.thisPageNumber +1;

  // If bEnablePageNumber is true, override the strt value
  if (variables.bEnablePageNumber){
    variables.strt = variables.ThisPageNumber * variables.show;
  }

  // Highest Possible Page Number
    variables.Last_PageNumber = ceiling(variables.QueryRecordCount/variables.show);

  // Calculate for CenterPage Offset if MaxResultPages is an even number
  variables.CenterNumberCountBefore = ceiling(variables.MaxResultPages/2) + variables.CenterPageOffset -1;
  variables.CenterNumberCountAfter = variables.MaxResultPages - variables.CenterNumberCountBefore -1;

  // If total page count is greater than the MaxPage limit set.
  if (variables.Last_PageNumber GT variables.MaxResultPages){
    // Loop variables
    variables.FROM_PageNumber = variables.ThisPageNumber;
    variables.TO_PageNumber = variables.FROM_PageNumber + variables.MaxResultPages -1;
    variables.PageCounter = variables.FROM_PageNumber;

    // Query result to start from should the user click on the next button
    variables.StartCounter = variables.strt + variables.show;

    // The StartCounter equivalent for the last page (Used for last page link)
    variables.LastPageStartRecordNumber = variables.show * (variables.Last_PageNumber -1) +1;

    // Center Page number
    if (variables.ThisPageNumber LTE variables.CenterNumberCountBefore){
      variables.FROM_PageNumber = 1;
      variables.TO_PageNumber = variables.MaxResultPages;
      variables.StartCounter = 1;
    }else if (variables.ThisPageNumber GT variables.CenterNumberCountBefore AND variables.ThisPageNumber LT variables.Last_PageNumber - variables.CenterNumberCountAfter){
      variables.FROM_PageNumber = variables.FROM_PageNumber - variables.CenterNumberCountBefore;
      variables.TO_PageNumber = variables.FROM_PageNumber + variables.MaxResultPages -1;
      variables.StartCounter = variables.StartCounter - (variables.show * (variables.CenterNumberCountBefore +1));
    }else{
      variables.FROM_PageNumber = variables.Last_PageNumber - variables.MaxResultPages +1;
      variables.TO_PageNumber = variables.Last_PageNumber;
      variables.StartCounter = variables.LastPageStartRecordNumber - (variables.show * (variables.MaxResultPages -1));
    }
  }else{
  // If total page count is less than (or equalt to) the MaxPage limit set.
    variables.FROM_PageNumber = 1;
    variables.TO_PageNumber = variables.Last_PageNumber;
    variables.PageCounter = variables.show;
  }

// Move Extra URL before url.strt and url.show (new for v1.09!)
// To support older versions we need to strip off any trailing ampersands or begnning ampersands (may be in the form of "&" or "&amp;" or "&#38;")

  // Change any "&amp;" or "&#38;" to "&" --->
  variables.ExtraURLString = replaceNoCase(variables.ExtraURLString,"&amp;","&","all");
  variables.ExtraURLString = replace(variables.ExtraURLString,"&##38;","&","all");
 
  // Remove any "&" at the beginning of the string
  if (left(variables.ExtraURLString, 1) eq "&"){
    variables.ExtraURLString = right(variables.ExtraURLString, len(variables.ExtraURLString)-1);}

  // Remove any "&" at the end of the string
  if (right(variables.ExtraURLString, 1) eq "&"){
    variables.ExtraURLString = left(variables.ExtraURLString, len(variables.ExtraURLString)-1);}

  // Replace all "&" with "&amp;"
  variables.ExtraURLString = replace(variables.ExtraURLString,"&","&amp;","all");

  // replace any spaces with "%20" --->
  variables.ExtraURLString = replace(variables.ExtraURLString,"#chr(32)#","%20","all");

// Check for objectID attribute (for Farcry support)
  if (variables.objectID neq ''){
    if (variables.ExtraURLString eq ''){
      variables.ExtraURLString = "objectID=#variables.ObjectID#";
    }else{
      variables.ExtraURLString = "objectID=#variables.ObjectID#&amp;#variables.ExtraURLString#";
    }
  }
</cfscript>

<!---==[ START - Prepare Layout and style ]==--->

<cfscript>
  /* START - Layout variables */
  // Check for valid numbers (layout)
  list_ValidLayoutNumbers = "1,2,3,4";
  if (NOT IsNumeric(variables.LayoutNumber)){
    variables.LayoutNumber = 1;}
  if (ListFind(list_ValidLayoutNumbers, variables.LayoutNumber) EQ 0){
    variables.LayoutNumber = 1;}
  // Set Layout Values (layout)
  if (variables.LayoutNumber EQ 1){
    /* Default Layout */
    if (variables.blPreDef_Layout_previous eq false){
      variables.Layout_previous = "&laquo;&nbsp;Previous";}
    if (variables.blPreDef_Layout_next eq false){
      variables.Layout_next = "Next&nbsp;&raquo;";}
    if (variables.blPreDef_Layout_prePrevious eq false){
      variables.Layout_prePrevious = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_postPrevious eq false){
      variables.Layout_postPrevious = "&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_preNext eq false){
      variables.Layout_preNext = "&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_postNext eq false){
      variables.Layout_postNext = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_start eq false){
      variables.Layout_start = "(&nbsp;";}
    if (variables.blPreDef_Layout_end eq false){
      variables.Layout_end = "&nbsp;)";}
    if (variables.blPreDef_Layout_separator_mid eq false){
      variables.Layout_separator_mid = "&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_separator_start eq false){
      variables.Layout_separator_start = "&nbsp;...&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_separator_end eq false){
      variables.Layout_separator_end = "&nbsp;&nbsp;...&nbsp;";}
    if (variables.blPreDef_CurrentPageWrapper_start eq false){
      variables.Layout_CurrentPageWrapper_start = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_CurrentPageWrapper_end eq false){
      variables.Layout_CurrentPageWrapper_end = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_PageText eq false){
      variables.PageText = "";} // Value is still blank. Leave code for consistancy
  }
  if (variables.LayoutNumber EQ 2){
    if (variables.blPreDef_Layout_previous eq false){
      variables.Layout_previous = "&laquo;";}
    if (variables.blPreDef_Layout_next eq false){
      variables.Layout_next = "&raquo;";}
    if (variables.blPreDef_Layout_start eq false){
      variables.Layout_start = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_prePrevious eq false){
      variables.Layout_prePrevious = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_postPrevious eq false){
      variables.Layout_postPrevious = "&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_preNext eq false){
      variables.Layout_preNext = "&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_postNext eq false){
      variables.Layout_postNext = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_end eq false){
      variables.Layout_end = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_separator_mid eq false){
      variables.Layout_separator_mid = "&nbsp;|&nbsp;";}
    if (variables.blPreDef_Layout_separator_start eq false){
      variables.Layout_separator_start = "&nbsp;|&nbsp;...&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_separator_end eq false){
      variables.Layout_separator_end = "&nbsp;&nbsp;...&nbsp;|&nbsp;";}
    if (variables.blPreDef_CurrentPageWrapper_start eq false){
      variables.Layout_CurrentPageWrapper_start = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_CurrentPageWrapper_end eq false){
      variables.Layout_CurrentPageWrapper_end = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_PageText eq false){
      variables.PageText = "";} // Value is still blank. Leave code for consistancy
  }
  if (variables.LayoutNumber EQ 3){
    if (variables.blPreDef_Layout_previous eq false){
      variables.Layout_previous = "&laquo;";}
    if (variables.blPreDef_Layout_next eq false){
      variables.Layout_next = "&raquo;";}
    if (variables.blPreDef_Layout_start eq false){
      variables.Layout_start = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_prePrevious eq false){
      variables.Layout_prePrevious = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_postPrevious eq false){
      variables.Layout_postPrevious = "&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_preNext eq false){
      variables.Layout_preNext = "&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_postNext eq false){
      variables.Layout_postNext = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_end eq false){
      variables.Layout_end = "";} // Value is still blank. Leave code for consistancy
    if (variables.blPreDef_Layout_separator_mid eq false){
      variables.Layout_separator_mid = "&nbsp;";}
    if (variables.blPreDef_Layout_separator_start eq false){
      variables.Layout_separator_start = "&nbsp;|&nbsp;...&nbsp;&nbsp;";}
    if (variables.blPreDef_Layout_separator_end eq false){
      variables.Layout_separator_end = "&nbsp;&nbsp;...&nbsp;|&nbsp;";}
    if (variables.blPreDef_CurrentPageWrapper_start eq false){
      variables.Layout_CurrentPageWrapper_start = "&nbsp;[";}
    if (variables.blPreDef_CurrentPageWrapper_end eq false){
      variables.Layout_CurrentPageWrapper_end = "]&nbsp;";}
    if (variables.blPreDef_PageText eq false){
      variables.PageText = "";} // Value is still blank. Leave code for consistancy
  }
  if (variables.LayoutNumber EQ 4){
    // Set evertything to blank (allowing user to control outlook using their own stylesheets)
    if (variables.blPreDef_Layout_previous eq false){
      variables.Layout_previous = "";}
    if (variables.blPreDef_Layout_next eq false){
      variables.Layout_next = "";}
    if (variables.blPreDef_Layout_start eq false){
      variables.Layout_start = "";}
    if (variables.blPreDef_Layout_prePrevious eq false){
      variables.Layout_prePrevious = "";}
    if (variables.blPreDef_Layout_postPrevious eq false){
      variables.Layout_postPrevious = "";}
    if (variables.blPreDef_Layout_preNext eq false){
      variables.Layout_preNext = "";}
    if (variables.blPreDef_Layout_postNext eq false){
      variables.Layout_postNext = "";}
    if (variables.blPreDef_Layout_end eq false){
      variables.Layout_end = "";}
    if (variables.blPreDef_Layout_separator_mid eq false){
      variables.Layout_separator_mid = "";}
    if (variables.blPreDef_Layout_separator_start eq false){
      variables.Layout_separator_start = "";}
    if (variables.blPreDef_Layout_separator_end eq false){
      variables.Layout_separator_end = "";}
    if (variables.blPreDef_CurrentPageWrapper_start eq false){
      variables.Layout_CurrentPageWrapper_start = "";}
    if (variables.blPreDef_CurrentPageWrapper_end eq false){
      variables.Layout_CurrentPageWrapper_end = "";}
    if (variables.blPreDef_PageText eq false){
      variables.PageText = "";} // Value is still blank. Leave code for consistancy
  }
  /* END - Layout variables */

  /* START - Style variables */
  // Check for valid Preset Stylesheet Numbers (styles)
  list_ValidPresetStyles = "0,1,2,3";
  if (NOT IsNumeric(variables.LayoutNumber)){
    variables.PresetStyle = 0;}
  if (ListFind(list_ValidPresetStyles, variables.PresetStyle) EQ 0){
    variables.PresetStyle = 0;}
  // Set Preset Stylesheets (styles)
  if (variables.PresetStyle NEQ 0){
    if (variables.DivStyle EQ ''){
      variables.DivStyle = "search_PageNumbers";}
    if (variables.LinkStyle1 EQ ''){
      variables.LinkStyle1 = "search_LinkStyle1";}
    if (variables.ThisPageStyle EQ ''){
      variables.ThisPageStyle = "search_ThisPageStyle";}
    if (variables.PresetStyle EQ 1){
      search_stylesheet = '
<style type="text/css" media="screen">
  ##search_PageNumbers {font-size: 11px; font-family: arial,verdana,sans-serif,helvetica; font-weight: none; text-decoration: none; color: ##000;}
  ##search_PageNumbers a {font-size: 11px; color: ##000; text-decoration: none;}
  ##search_LinkStyle1 a {font-size: 11px; font-weight: bold; color: ##0000ff;}
  .search_ThisPageStyle {font-weight: bold;}
</style>';
    }else if (variables.PresetStyle EQ 2){
      search_stylesheet = '
<style type="text/css" media="screen">
  ##search_PageNumbers {font-size: 13px; font-family: arial,verdana,sans-serif,helvetica; font-weight: none; text-decoration: none; color: ##000;}
  ##search_PageNumbers a {font-size: 13px; color: ##000; text-decoration: none;}
  ##search_LinkStyle1 a {font-size: 13px; font-weight: bold; color: ##0000ff;}
  .search_ThisPageStyle {font-weight: bold;}
</style>';
    }else if (variables.PresetStyle EQ 3){
      search_stylesheet = '
<style type="text/css" media="screen">
  ##search_PageNumbers {font-size: 11px; font-family: arial,verdana,sans-serif,helvetica; font-weight: none; text-decoration: none; color: ##fff;}
  ##search_PageNumbers a {font-size: 11px; color: ##fff; text-decoration: underline;}
  ##search_LinkStyle1 a {font-size: 11px; font-weight: bold; text-decoration: none; color: ##ffff00;}
  .search_ThisPageStyle {color: ##dbdbdb;}
</style>';
    }
  }
  /* END - Style variables */
</cfscript>

<cfif variables.PresetStyle neq 0>
  <cfhtmlhead text="#search_stylesheet#" />
</cfif>
<!---==[ END - Prepare Layout ]==--->

<cfif variables.show LT variables.QueryRecordCount>

<cfoutput><cfif variables.DivStyle neq ''><div id="#variables.DivStyle#"></cfif><cfif variables.PageText neq ''><cfif variables.TextStyle1 neq ''><span class="#variables.TextStyle1#"></cfif>#variables.PageText#<cfif variables.TextStyle1 neq ''></span></cfif></cfif></cfoutput>


  <cfif attributes.showCurrentPageDetails>
	  <cfoutput>
	  <h4>Page #variables.ThisPageNumber# of #variables.Last_PageNumber#</h4>
	  </cfoutput>  
  </cfif>


  <!--- START - Previous link --->
  <cfif variables.ThisPageNumber NEQ 1>
    <!--- Note: I've left this code in here since v1.00.  If you'd like to use it remember to remark the other code below it instead.
    <cfif variables.strt LTE variables.show>
      <cfoutput>#Layout_prePrevious#<cfif variables.LinkStyle1 neq ''><span class="#variables.LinkStyle1#"></cfif><a<cfif variables.LinkStyle1 neq ''> class="#variables.LinkStyle1#"</cfif> href="#variables.FileName#?#variables.ExtraURLString#&amp;#variables.strt_string#=1&amp;#variables.show_string#=#variables.show##attributes.bookmark#">&laquo; Start at First Record</a><cfif variables.LinkStyle1 neq ''></span></cfif>#Layout_postPrevious#</cfoutput>
    <cfelse>
      <cfoutput>#Layout_prePrevious#<cfif variables.LinkStyle1 neq ''><span class="#variables.LinkStyle1#"></cfif><a<cfif variables.LinkStyle1 neq ''> class="#variables.LinkStyle1#"</cfif> href="#variables.FileName#?#variables.ExtraURLString#&amp;#variables.strt_string#=#Evaluate(variables.strt - variables.show)#&amp;#variables.show_string#=#variables.show##attributes.bookmark#">&laquo; Last #Evaluate(variables.LastCount)# Record<cfif variables.LastCount NEQ 1>s</cfif></a><cfif variables.LinkStyle1 neq ''></span></cfif>#Layout_postPrevious#</cfoutput>
    </cfif>---> 
    <cfif variables.strt LTE variables.show>
      <cfoutput>#Layout_prePrevious#<cfif variables.LinkStyle1 neq ''><span id="#variables.LinkStyle1#"></cfif><a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=1<cfelse>&amp;#variables.strt_string#=1&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">#variables.layout_previous#</a><cfif variables.LinkStyle1 neq ''></span></cfif>#Layout_postPrevious#</cfoutput>
    <cfelse>
      <cfoutput>#Layout_prePrevious#<cfif variables.LinkStyle1 neq ''><span id="#variables.LinkStyle1#"></cfif><a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=#variables.previousPageNumber#<cfelse>&amp;#variables.strt_string#=#Evaluate(variables.strt - variables.show)#&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">#variables.layout_previous#</a><cfif variables.LinkStyle1 neq ''></span></cfif>#Layout_postPrevious#</cfoutput>
    </cfif>
  </cfif>
  <!--- END - Previous link --->


  <!--- START - Result Page Numbers --->
  <!--- START - Result Page Numbers --->
  <!--- START - Result Page Numbers --->


  <cfif variables.QueryRecordCount GT variables.show>
    <cfif variables.Last_PageNumber GT variables.MaxResultPages>

      <cfif variables.layout_start neq ''><cfoutput>#variables.layout_start#</cfoutput></cfif>

      <!--- START - Output First/Last Link --->
      <cfif variables.FirstLastPage NEQ "none" AND variables.ThisPageNumber GT 1 + variables.CenterNumberCountBefore>
        <cfif variables.FirstLastPage EQ "numeric">
          <cfoutput><a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=1<cfelse>&amp;#variables.strt_string#=1&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">1</a>#variables.layout_separator_start#</cfoutput>
        <cfelseif variables.FirstLastPage EQ "text">
          <cfoutput><a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=1<cfelse>&amp;#variables.strt_string#=1&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">First</a>#variables.layout_separator_start#</cfoutput>
        </cfif>
      </cfif>
      <!--- END - Output First/Last Link --->

      <!--- START - Display Number links --->
      <cfloop index="p" from="#variables.FROM_PageNumber#" to="#variables.TO_PageNumber#">
        <cfif p gt 0 and p lte variables.Last_PageNumber>
          <cfif p LT variables.ThisPageNumber AND p GT 0>
            <!--- Display any page numbers BEFORE current page --->
            <cfoutput><a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=#p#<cfelse>&amp;#variables.strt_string#=#Evaluate(variables.StartCounter)#&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">#p#</a><cfif variables.Layout_CurrentPageWrapper_start EQ '' OR (variables.Layout_CurrentPageWrapper_start NEQ '' AND Evaluate(variables.ThisPageNumber-p) NEQ 1)>#variables.layout_separator_mid#</cfif></cfoutput>
          <cfelseif p eq variables.ThisPageNumber>
            <!--- Display current Page number --->
            <cfif variables.ThisPageStyle neq ''><cfoutput><span class="#variables.ThisPageStyle#"></cfoutput></cfif>
            <cfoutput><cfif variables.Layout_CurrentPageWrapper_start NEQ ''><cfif p EQ variables.FROM_PageNumber AND left(variables.Layout_CurrentPageWrapper_start, 1) eq " ">#right(variables.Layout_CurrentPageWrapper_start, Len(variables.Layout_CurrentPageWrapper_start)-1)#<cfelseif p EQ variables.FROM_PageNumber AND left(variables.Layout_CurrentPageWrapper_start, 6) eq "&nbsp;">#right(variables.Layout_CurrentPageWrapper_start, Len(variables.Layout_CurrentPageWrapper_start)-6)#<cfelse>#variables.Layout_CurrentPageWrapper_start#</cfif></cfif>#p#<cfif variables.Layout_CurrentPageWrapper_end NEQ ''><cfif p EQ variables.TO_PageNumber AND right(variables.Layout_CurrentPageWrapper_end, 1) eq " ">#left(variables.Layout_CurrentPageWrapper_end, Len(variables.Layout_CurrentPageWrapper_end)-1)#<cfelseif p EQ variables.TO_PageNumber AND right(variables.Layout_CurrentPageWrapper_end, 6) eq "&nbsp;">#left(variables.Layout_CurrentPageWrapper_end, Len(variables.Layout_CurrentPageWrapper_end)-6)#<cfelse>#variables.Layout_CurrentPageWrapper_end#</cfif></cfif></cfoutput>
            <cfif variables.ThisPageStyle neq ''><cfoutput></span></cfoutput></cfif>
          <cfelse>
            <!--- Display any page numbers AFTER current page --->
            <cfoutput><cfif variables.Layout_CurrentPageWrapper_end EQ '' OR (variables.Layout_CurrentPageWrapper_end NEQ '' AND Evaluate(p-variables.ThisPageNumber) NEQ 1)>#variables.layout_separator_mid#</cfif><a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=#p#<cfelse>&amp;#variables.strt_string#=#Evaluate(variables.StartCounter)#&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">#p#</a></cfoutput>
          </cfif>
          <cfset variables.StartCounter = variables.StartCounter + variables.show />
        </cfif>
      </cfloop>
      <!--- END - Display Number links --->


      <!--- START - Output First/Last Link --->
      <cfif variables.FirstLastPage NEQ "none" AND variables.ThisPageNumber LT variables.Last_PageNumber - variables.CenterNumberCountAfter>
        <cfif variables.FirstLastPage EQ "numeric">
          <cfoutput>#variables.layout_separator_end#<a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=#variables.Last_PageNumber#<cfelse>&amp;#variables.strt_string#=#variables.LastPageStartRecordNumber#&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">#variables.Last_PageNumber#</a></cfoutput>
        <cfelseif variables.FirstLastPage EQ "text">
          <cfoutput>#variables.layout_separator_end#<a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=#variables.Last_PageNumber#<cfelse>&amp;#variables.strt_string#=#variables.LastPageStartRecordNumber#&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">Last</a></cfoutput>
        </cfif>
      </cfif>
      <!--- END - Output First/Last Link --->

      <cfif variables.layout_end neq ''><cfoutput>#variables.layout_end#</cfoutput></cfif>

    <cfelse>
      <!--- If the number of result pages returned is LTE the variables.MaxResultPages then show the next part --->
      <cfif variables.layout_start neq ''><cfoutput>#variables.layout_start#</cfoutput></cfif>
      <cfloop index="p" from="#variables.FROM_PageNumber#" to="#variables.TO_PageNumber#">
        <cfif p NEQ 1 AND p-1 NEQ variables.ThisPageNumber AND p NEQ variables.ThisPageNumber OR (p EQ variables.ThisPageNumber AND variables.Layout_CurrentPageWrapper_start EQ '') OR (p-1 EQ variables.ThisPageNumber AND variables.Layout_CurrentPageWrapper_start EQ '')><cfoutput>#variables.layout_separator_mid#</cfoutput></cfif>
        <cfif p eq variables.ThisPageNumber>
          <!--- Display current Page number --->
          <cfoutput><cfif variables.ThisPageStyle neq ''><span class="#variables.ThisPageStyle#"></cfif><cfif variables.Layout_CurrentPageWrapper_start NEQ ''><cfif p EQ variables.FROM_PageNumber AND left(variables.Layout_CurrentPageWrapper_start, 1) eq " ">#right(variables.Layout_CurrentPageWrapper_start, Len(variables.Layout_CurrentPageWrapper_start)-1)#<cfelseif p EQ variables.FROM_PageNumber AND left(variables.Layout_CurrentPageWrapper_start, 6) eq "&nbsp;">#right(variables.Layout_CurrentPageWrapper_start, Len(variables.Layout_CurrentPageWrapper_start)-6)#<cfelse>#variables.Layout_CurrentPageWrapper_start#</cfif></cfif>#p#<cfif variables.Layout_CurrentPageWrapper_end NEQ ''><cfif p EQ variables.TO_PageNumber AND right(variables.Layout_CurrentPageWrapper_end, 1) eq " ">#left(variables.Layout_CurrentPageWrapper_end, Len(variables.Layout_CurrentPageWrapper_end)-1)#<cfelseif p EQ variables.TO_PageNumber AND right(variables.Layout_CurrentPageWrapper_end, 6) eq "&nbsp;">#left(variables.Layout_CurrentPageWrapper_end, Len(variables.Layout_CurrentPageWrapper_end)-6)#<cfelse>#variables.Layout_CurrentPageWrapper_end#</cfif></cfif><cfif variables.ThisPageStyle neq ''></span></cfif></cfoutput>
        <cfelse>
          <!--- Display other page numbers as links --->
          <cfoutput><a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=#p#<cfelse>&amp;#variables.strt_string#=#Evaluate(variables.PageCounter - variables.show + 1)#&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">#p#</a></cfoutput>
        </cfif>
        <cfset variables.PageCounter = variables.PageCounter + variables.show />
      </cfloop>
      <cfif variables.layout_end neq ''><cfoutput>#variables.layout_end#</cfoutput></cfif>
    </cfif>
  </cfif>
  <!--- END - Result Page Numbers --->
  <!--- END - Result Page Numbers --->
  <!--- END - Result Page Numbers --->


  <!--- START - Next records --->
  <cfif variables.ThisPageNumber NEQ variables.Last_PageNumber>
    <!--- Note: I've left this code in here since v1.00.  If you'd like to use it remember to remark the other code below it instead.
    <cfif Evaluate(variables.show - variables.strt) LTE variables.show>
      <cfoutput>#Layout_preNext#<cfif variables.LinkStyle1 neq ''><span class="#variables.LinkStyle1#"></cfif><a<cfif variables.LinkStyle1 neq ''> class="#variables.LinkStyle1#"</cfif> href="#variables.FileName#?#variables.ExtraURLString#&amp;#variables.strt_string#=#Evaluate(variables.strt + variables.show)#&amp;#variables.show_string#=#variables.show##attributes.bookmark#">Final #Evaluate(variables.show - variables.strt)# Record<cfif variables.show NEQ 1>s</cfif> &raquo;</a><cfif variables.LinkStyle1 neq ''></span></cfif>#Layout_postNext#</cfoutput>
    <cfelse>
      <cfoutput>#Layout_preNext#<cfif variables.LinkStyle1 neq ''><span class="#variables.LinkStyle1#"></cfif><a<cfif variables.LinkStyle1 neq ''> class="#variables.LinkStyle1#"</cfif> href="#variables.FileName#?#variables.ExtraURLString#&amp;#variables.strt_string#=#Evaluate(variables.strt + variables.show)#&amp;#variables.show_string#=#variables.show##attributes.bookmark#">Next #variables.show# Record<cfif variables.show NEQ 1>s</cfif> &raquo;</a><cfif variables.LinkStyle1 neq ''></span></cfif>#Layout_postNext#</cfoutput>
    </cfif>--->
    <cfif Evaluate(variables.show - variables.strt) LTE variables.show>
      <cfoutput>#Layout_preNext#<cfif variables.LinkStyle1 neq ''><span id="#variables.LinkStyle1#"></cfif><a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=#variables.nextPageNumber#<cfelse>&amp;#variables.strt_string#=#Evaluate(variables.strt + variables.show)#&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">#variables.layout_next#</a><cfif variables.LinkStyle1 neq ''></span></cfif>#Layout_postNext#</cfoutput>
    <cfelse>
      <cfoutput>#Layout_preNext#<cfif variables.LinkStyle1 neq ''><span id="#variables.LinkStyle1#"></cfif><a href="#variables.FileName#?#variables.ExtraURLString#<cfif variables.bEnablePageNumber>&amp;#variables.PageNumber_string#=#variables.nextPageNumber#<cfelse>&amp;#variables.strt_string#=#Evaluate(variables.strt + variables.show)#&amp;#variables.show_string#=#variables.show#</cfif>#attributes.bookmark#">#variables.layout_next#</a><cfif variables.LinkStyle1 neq ''></span></cfif>#Layout_postNext#</cfoutput>
    </cfif>
  </cfif>

  <!--- END - Next records --->

  <!--- Display Version Info --->
  <cfif IsDefined("url.GetVersion")>
    <cfoutput>
      <br /><br />
      <div style="border: 1px dashed ##8184ff; background-color: ##EBEBFF; padding: 5px; color: ##000">
      <small>
        <strong><u>ColdFusion Custom Tag</u></strong><br />
        <strong>Author:</strong> Jeff Coughlin<br />
        <strong>Website:</strong> <a style="color: ##0000ff;" href="http://www.JeffCoughlin.com/"><small>www.JeffCoughlin.com</small></a><br />
        <strong>Email:</strong> <a style="color: ##0000ff;" href="mailto:Jeff@JeffCoughlin.com"><small>Jeff@JeffCoughlin.com</small></a><br />
        <strong>Tag Name:</strong> CF_Search_NextPrevious<br />
        <strong>CF Version Required:</strong> 4.01+<br />
        <strong>CF Version Used:</strong> #Server.ColdFusion.ProductVersion#<br />
        <strong>CF Tag Version:</strong> #variables.Search_NextPrevious_VersionNumber#<br />
        <strong>CF Tag Last Update:</strong> #DateFormat(variables.Search_NextPrevious_Update_Date, "mmmm dd, yyyy")# #TimeFormat(variables.Search_NextPrevious_Update_Date, "h:mm tt")# EST<br />
      </small>
      </div>
    </cfoutput>
  </cfif><cfoutput><cfif variables.DivStyle neq ''></div></cfif></cfoutput>
</cfif>
<!---==============[ END Custom Tag for DISPLAY ]==============--->
<cfsetting enablecfoutputonly="no" />