<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: extjs IFrame Dialog --->
<!--- @@description: Places a nice curved border around content.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfparam name="attributes.url" type="string" default="" />
<cfparam name="attributes.id" type="string" default="" />
<cfparam name="attributes.event" type="string" default="click" />
<cfparam name="attributes.width" type="integer" default="500" />
<cfparam name="attributes.height" type="integer" default="500" />
<cfparam name="attributes.title" type="string" default="" />
<cfparam name="attributes.resizable" type="boolean" default="false" />

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
	
	
<cfif thistag.executionMode eq "start">
	
	
	<skin:htmlHead library="extJS" />

	<skin:htmlHead id="iFrameDialogJS">
	<cfoutput>
		<script language="javascript">
			Ext.ux.IFrameComponent = Ext.extend(Ext.BoxComponent, {
			     onRender : function(ct, position){
			          this.el = ct.createChild({tag: 'iframe', id: 'iframe-'+ this.id, frameBorder: 0, src: this.url });
			     }
			});
			
			var iFrameDialog;
			function openScaffoldDialog(url,title,width,height,resizable,onclose) {
		        iFrameDialog = new Ext.Window({
		        	
					height:		height,
					width:		width,
					resizable:	resizable,
					layout:		"fit",
					title:		title,
					collapsible: false,
		            plain:		true,
		            modal:		false,
		            autoScroll:	false,
		            id:			"iframedialog",
		            items: 		[ new Ext.ux.IFrameComponent({ id: "iframedialog", url: url, width:'100%', height:'100%' }) ]
		        });
				if (onclose) iFrameDialog.on("close",onclose);
		        iFrameDialog.show('');
		        iFrameDialog.alignTo(Ext.getBody(), 't-t');
				Ext.select("##iframedialog .x-window-body").setStyle("overflow","auto");
			}
			function closeDialog() {
				iFrameDialog.close();
			}
		</script>
	</cfoutput>
	</skin:htmlHead>
		

	
	
	<!--- If the user has passed an id, attach the event. --->
	<cfif len(attributes.id) and len(attributes.url)>	
			
		<cfif find("?",attributes.url)>
			<cfset attributes.url = attributes.url & "&iframe" />
		<cfelse>
			<cfset attributes.url = attributes.url & "?iframe" />
		</cfif>
		
		<cfoutput>
			<script language="javascript">
				Ext.addBehaviors({ 
					'###attributes.id#@#attributes.event#' : function(e,t){
						openScaffoldDialog('#attributes.url#','#attributes.title#',#attributes.width#,#attributes.height#,#attributes.resizable#);
						e.preventDefault();
					}
				});
			</script>
		</cfoutput>
	</cfif>
</cfif>