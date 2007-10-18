<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname:  --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<!------------------ 
START TAG
 ------------------>




<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.id" default="#createUUID()#">
	<cfparam name="attributes.title" default="">
	<cfparam name="attributes.icon" default="">
	<cfparam name="attributes.aPanels" default="#arrayNew(1)#"><!--- An array of Panels --->

		
	<skin:htmlhead id="extJS">
	<cfoutput>
	<link rel="stylesheet" type="text/css" href="/farcry/js/ext/resources/css/ext-all.css">
	<script type="text/javascript" src="/farcry/js/ext/adapter/yui/yui-utilities.js"></script>
	<script type="text/javascript" src="/farcry/js/ext/adapter/yui/ext-yui-adapter.js"></script>
	<script type="text/javascript" src="/farcry/js/ext/ext-all.js"></script>
	</cfoutput>
	</skin:htmlhead>
		
	<skin:htmlhead id="extAccordion">
	<cfoutput>	
	<link rel="stylesheet" type="text/css" href="/farcry/js/ext/extAccordion/accordion.css">
	<script type="text/javascript" src="/farcry/js/ext/extAccordion/Ext.ux.InfoPanel.js"></script>
	<script type="text/javascript" src="/farcry/js/ext/extAccordion/Ext.ux.Accordion.js"></script>
	</cfoutput>
	</skin:htmlhead>	
		
</cfif>

<cfif thistag.executionMode eq "End">

	<cfset thisTag.GeneratedContent = "" />
	

						

	<cfoutput><div id="#attributes.id#" style="border:1px solid ##98C0F4;"></cfoutput>
	<cfloop from="1" to="#arrayLen(attributes.aPanels)#" index="i">
		<cfoutput>
		<div id="menugroup-#attributes.aPanels[i].id#">
			<div>#attributes.aPanels[i].title#</div>
			<div>
				<div class="text-content" style="padding:5px;"><div>
					#attributes.aPanels[i].html#
				</div></div>
			</div>
		</div>
		</cfoutput>
	</cfloop>
	<cfoutput></div></cfoutput>
	



	<cfoutput>
	<script type="text/javascript">
	Ext.BLANK_IMAGE_URL = '/farcry/js/ext/resources/images/default/s.gif';
	
	Ext.onReady(function() {
		//var iconPath = '/extAccordion/img/silk/';

<!---  	  var acc = new Ext.ux.Accordion('#attributes.id#', {
		body: '#attributes.id#'
		, boxWrap: true
		, wrapEl: '#attributes.id#-wrap'
		, fitContainer: true 
		, fitToFrame: true 
		, useShadow: true
		, adjustments: [0, -26]
		
	    // ,fitHeight: true
	  }) --->
	  
	var acc = new Ext.ux.Accordion('#attributes.id#', {
		body: '#attributes.id#'
		, fitContainer: true 
		, fitToFrame: true 
		, useShadow: true
		, adjustments: [0, -26]
		, boxWrap: true
		, wrapEl: '#attributes.id#-wrap'
		,independent: true
//		, animate: false
	});	  
		  
		<cfloop from="1" to="#arrayLen(attributes.aPanels)#" index="i">

				acc.add(new Ext.ux.InfoPanel('menugroup-#attributes.aPanels[i].id#', {
					collapsed: #attributes.aPanels[i].collapsed#
					<cfif len(attributes.aPanels[i].icon)>
						<!--- ,icon: '#attributes.aPanels[i].icon#' --->
					</cfif>
					,autoScroll: false
				}));
				
	
  

		</cfloop>
		
		



	});
	</script>
	</cfoutput>
	
	



		<!--- Ext.example = function() {
		     var msgCt;
		 
		     function createBox(t, s){
		         return ['<div class="msg">',
		                 '<div class="x-box-tl"><div class="x-box-tr"><div class="x-box-tc"></div></div></div>',
		                 '<div class="x-box-ml"><div class="x-box-mr"><div class="x-box-mc"><h3>', t,
		                 '</h3>', s, '</div></div></div>',
		                 '<div class="x-box-bl"><div class="x-box-br"><div class="x-box-bc"></div></div></div>',
		                 '</div>'].join('');
		     }
		     return {
		         msg : function(title, format){
		             if(!msgCt){
		                 msgCt = Ext.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
		             }
		             msgCt.alignTo(document, 'bl-bl', [10, -90]);
		             var s = String.format.apply(String, Array.prototype.slice.call(arguments, 1));
		             var m = Ext.DomHelper.append(msgCt, {html:createBox(title, s)}, true);
		             m.slideIn('b').pause(1).ghost("b", {remove:true});
		         }
		     };
		 }();
		 
		 Ext.example.msg('title', 'message'); --->

	
<!--- 
<cfoutput>
<div id="a#attributes.id#" style="height:300px">
  <div id="a#attributes.id#panel-1">
    <div>My first panel</div>
    <div>
      <div class="text-content">#attributes.id#<br />My first panel content</div>
    </div>
  </div>
  <div id="a#attributes.id#panel-2">
    <div>My second panel</div>
    <div>
      <div class="text-content">#attributes.id#<br />My second panel content</div>
    </div>
  </div>
</div>

	<script type="text/javascript">
	Ext.BLANK_IMAGE_URL = '/extjs/resources/images/default/s.gif';
	
	Ext.onReady(function() {
		
	  // create accordion
	  var acc = new Ext.ux.Accordion('a#attributes.id#', {
	    
		title: 'Accordion' 
		, body: 'west-body'
		, fitContainer: true 
		, fitToFrame: true 
		, useShadow: true
		, adjustments: [0, -26]
			    
	  })
	
	  // create panel 1
	  var panel1 = acc.add(new Ext.ux.InfoPanel('a#attributes.id#panel-1', {
	  	collapsed: true
	  }));
	  
	  // create panel 2
	  var panel2 = acc.add(new Ext.ux.InfoPanel('a#attributes.id#panel-2', {
	  	collapsed: false
	  }));
	  
	});
	</script>
	</cfoutput> --->


</cfif>

<cfsetting enablecfoutputonly="false">

