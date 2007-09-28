// vim: ts=2:sw=2:nu:fdc=4:nospell
/**
	* Ext.ux.InfoPanel and Ext.ux.Accordion Example Application
	*
	* @author  Ing. Jozef Sakalos
	* @version $Id: accordion.js 61 2007-06-23 18:10:59Z jozo $
	*
	*/

// set blank image to local file
Ext.BLANK_IMAGE_URL = '../extjs/resources/images/default/s.gif';

// {{{
/**
	* Ext.example class
	*
	* To display sliding popup. Borrowed from ExtJS examples.
	* 
	* @class Ext.exammple
	* @singleton
	*
	*/
Ext.example = function() {
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
// }}}

// run this function when document becomes ready
Ext.onReady(function() {

	var iconPath = '/extAccordion/img/silk/';

	// {{{
	// function to remove loading mask
	var unmask = function() {
		var mask = Ext.get('loading-mask');
		var msg = Ext.get('loading-msg');
		if(mask && msg) {
			mask.shift({
				xy:msg.getXY()
				, width:msg.getWidth()
				, height:msg.getHeight()
				, remove: true
				, duration: 1.6
				, opacity: 0.3
				, easing: 'bounceOut'
				, callback: function(){Ext.fly(msg).remove();}
			});
		}
	};
	// }}}

	// install onclick handler to unmask body (for debugging)
	Ext.fly('loading-mask').on('click', unmask);

	// initialize state manager, we will use cookies
	Ext.state.Manager.setProvider(new Ext.state.CookieProvider());

	// initialize QuickTips
	Ext.QuickTips.init();
	Ext.apply(Ext.QuickTips, {interceptTitles: true});

	// {{{
	// create layout
	var layout = new Ext.BorderLayout(document.body, {
		hideOnLayout: true
		, north: { split: false, initialSize: 34, titlebar: false }
		, west: {
			split: true
			, initialSize: 220
			, minSize: 220
			, maxSize: 300
			, titlebar: false
			, collapsible: true
			, showPin: true
			, animate: true
		}
		, center: { 
			titlebar: true 
			, autoScroll: false 
		}
		, south: { 
			titlebar: true
			, split: true
			, initialSize: 56
			, collapsible: true
			, collapsed: true
			, hidden: false 
			, collapsedTitle: 'South'
			, animate: true
			, showPin: true
		}
		, east: {
			titlebar: true
			, split: false
			, initialSize: 142
			, collapsible: false
			, autoScroll: true
		}
	});
	// }}}
	// {{{
	// create accordion in west region
	var acc = new Ext.ux.Accordion('west', { 
		title: 'Accordion' 
		, body: 'west-body'
		, fitContainer: true 
		, fitToFrame: true 
		, useShadow: true
		, adjustments: [ 0, -26 ]
	});
	// }}}
	// {{{
	// create global toolbar
	acc.toolbar = new Ext.Toolbar('acc-tb-global', [

		// reset order
		{	tooltip: 'Reset order'
			, cls: 'x-btn-icon'
			, icon: iconPath + 'application_put.png'
			, scope: acc
			, handler: acc.resetOrder
		}

		// undockable mode
		, {	tooltip: 'Undockable mode'
			, cls: 'x-btn-icon'
			, enableToggle: true
			, id: 'btn-undockable'
			, icon: iconPath + 'layout_content.png'
			, scope: acc
			, handler: function(btn, e) {
				this.setUndockable(btn.pressed);
			}
		}

		// independent mode
		, {	tooltip: 'Independent mode'
			, cls: 'x-btn-icon'
			, enableToggle: true
			, id: 'btn-independent'
			, icon: iconPath + 'application_tile_vertical.png'
			, scope: acc
			, handler: function(btn, e) {
				if(!btn.pressed) {
					this.collapseAll(false);
				}
				this.setIndependent(btn.pressed);
			}
		}

		// collapse all
		, {	tooltip: 'Collapse all (also pinned)'
			, cls: 'x-btn-icon'
			, icon: iconPath + 'application_view_list.png'
			, scope: acc
			, handler: function(btn, e) {
			  this.collapseAll(true);
			}
		}

		// expand all
		, {	tooltip: 'Expand all (in independent mode)'
			, cls: 'x-btn-icon'
			, icon: iconPath + 'application_view_tile.png'
			, scope: acc
			, handler: function(btn, e) {
			  this.expandAll();
			}
		}

		// use shadows
		, {	tooltip: 'Use shadows for undocked panels'
			, id: 'btn-shadow'
			, cls: 'x-btn-icon'
			, enableToggle: true
			, icon: iconPath + 'contrast_low.png'
			, scope: acc
			, handler: function(btn, e) {
			  this.setShadow(btn.pressed);
			}
		}

		// separator
		, '-'

		// find text
		, 'Find:'

		// search text input field
		, new Ext.form.TextField({
			  id: 'find-field'
			, msgTarget:'side'
			, autoCreate: {
				  tag:'input'
				, type:'text'
				, qtip:'Try to type <b>&quot;acc&quot;</b> here.<br>'
						+ 'Then switch to independent mode and type <b>&quot;note&quot;</b> here.<br>'
						+ 'You can try also <b>&quot;dev&quot;</b> and <b>&quot;comp&quot;</b>'
				, size:3
			}
		})
	]);
	// }}}
	// {{{
	// add panels to west accordion

	// Introduction
	var panel1 = new Ext.ux.InfoPanel('panel-1', {
		trigger:'title', collapsed:true
		, icon: iconPath + 'lightbulb_off.png'
		, showPin: true
		, collapseOnUnpin: false
	});

	// example of installing custom panel event handlers
	acc.add(panel1);
	panel1.on('expand', function(panel) {
		Ext.example.msg('expand event handler', 'Panel: ' + panel.getTitle());
//		panel.setIcon(iconPath + 'lightbulb.png');
	});

	panel1.on('collapse', function(panel) {
		Ext.example.msg('collapse event handler', 'Panel: ' + panel.getTitle());
//		panel.setIcon(iconPath + 'lightbulb_off.png');
	});

	// extjs
	acc.add(new Ext.ux.InfoPanel('panel-2', {
		trigger:'title', collapsed:true
		, icon: iconPath + 'brick.png'
		, showPin: true
		, collapseOnUnpin: false
	}));

	// usage
	var panel3 = acc.add(new Ext.ux.InfoPanel('panel-3', {
		trigger:'title', collapsed:true
		, icon: iconPath + 'layout.png'
	}));

	// create toolbar for panel 3
	var toolbar3 = panel3.createToolbar();

	// add greedy spacer to align button right
	Ext.fly(toolbar3.addSpacer().getEl().parentNode).setStyle('width', '100%');
	toolbar3.add([{
		icon: iconPath + 'application_put.png'
		, cls: 'x-btn-text-icon'
		, text: 'Reset order'
		, scope: acc
		, handler: acc.resetOrder
	}]);

	// drag & drop
	var panel4 = acc.add(new Ext.ux.InfoPanel('panel-4', {
		trigger:'title', collapsed:true
		, icon: iconPath + 'mouse.png'
	}));

	// create bottom toolbar for panel 4
	var toolbar4 = panel4.createToolbar([], true);

	// add greedy spacer to align button right
	Ext.fly(toolbar4.addSpacer().getEl().parentNode).setStyle('width', '100%');
	toolbar4.add([{
		icon: iconPath + 'mouse.png'
		, cls: 'x-btn-text-icon'
		, text: 'Button'
		, scope: this
		, handler: function() {
			alert('You clicked me');
		}
	}]);

	// configuration options
	acc.add(new Ext.ux.InfoPanel('panel-5', {
		trigger:'title'
		, collapsed:true
		, icon: iconPath + 'wrench.png'
//		, autoScroll: true
	}));

	// custom functions
	var panel6 = acc.add(new Ext.ux.InfoPanel({
		title:'6. Custom functions'
		, icon: iconPath + 'script.png'
		, id:'panel-6'
		, autoCreate: {
			tag:'div'
		}
	}));

	// set content for panel 6
	panel6.update(
		'<div class="text-content">'
		+ '<p>Both Accordion and InfoPanel expose an Application Programming Interface (API) that makes'
		+ ' implementation of custom functions easy.</p>'
		+ '<p>The above Search function is one example of that. Try to'
		+ ' type three or more characters in the Find input.</p>'
		+ '</div>'
	);

	// theme selector
	var panel7 = acc.add(new Ext.ux.InfoPanel('panel-7', {
		icon: iconPath + 'palette.png'
		, showPin: true
		, minWidth: 200
		, minHeight: 100
	}));
	var ctheme = new Ext.form.ComboBox({
		typeAhead: true
		, triggerAction: 'all'
		, transform: 'theme-combo'
		, forceSelection: true
		, width: 140
		, listWidth: 158
	});

	// change theme on combo select
	ctheme.on('select', function() {
		Ext.util.CSS.swapStyleSheet('theme', '../extjs/resources/css/' + this.getValue());
	}, ctheme);

	// donate
	var panel8 = acc.add(new Ext.ux.InfoPanel('panel-8', {
		icon: iconPath + 'money.png'
	}));
	// {{{
	// add google search panel
	var pnGoogle = acc.add(new Ext.ux.InfoPanel.GoogleSearch('google-search', {
		icon: iconPath + 'magnifier.png'
		, searchBtnIcon: iconPath + 'magnifier.png'
		, searchTextSize: 25
		, searchResultIframe: 'center-result'
	}));
	pnGoogle.searchButton.on({
		click: {
			fn: function() {
			layout.getRegion('center').getTabs().getTab('center-result').activate();
		}}
	});

//	// create nicer Ext form
//	var gsForm = new Ext.BasicForm(pnGoogle.body.select('form').item(0), {});
//
//	// disable submit
//	gsForm.el.dom.onsubmit = function() { return false };
//
//	// beautify search text input
//	var gsText = new Ext.form.TextField({});
//	gsText.applyTo(gsForm.el.select('input[type=text]').item(0));
//	gsText.el.dom.size = 25;
//
//	// remove original google button
//	Ext.fly('sbb').remove();
//
//	// create new nicer button
//	var gsBtn = new Ext.Button(gsForm.el, {
//		text: "Search"
//		, icon: iconPath + 'magnifier.png'
//		, cls: 'x-btn-text-icon'
////		, name: 'sa'
//		, type: 'submit'
////		, id: 'sbb'
////		, value: 'Search'
//		, handler: function() {
//			// activate search results tab
//			layout.getRegion('center').getTabs().getTab('center-result').activate();
//
//			// create google search URL
//			var inputs = gsForm.el.select('input');
//			var getPars = [];
//			inputs.each(function(el) {
//				if('radio' === el.dom.type && !el.dom.checked) {
//					return;
//				}
//				getPars.push(el.dom.name + '=' + encodeURIComponent(el.dom.value));
//			});
//			var gsURL = 'http://www.google.com/custom?' + getPars.join('&');
//
//			// set iframe src attribute
//			Ext.get('center-result').dom.src = gsURL;
//
//		}
//	});
	// }}}

	// useful links
	var panel10 = acc.add(new Ext.ux.InfoPanel('panel-10', {
		icon: iconPath + 'world_link.png'
	}));
	panel10.body.on({
		click: {
			stopEvent: true
			, delegate: 'a'
			, scope: null
			, fn: function(e, target) {
				layout.getRegion('center').getTabs().getTab('center-result').activate();
				Ext.get('center-result').dom.src = target.href;
			}
		}
	});
	// }}}
	// {{{
	// create fitHeight accordion
	var acc2 = new Ext.ux.Accordion('acc2-body', {
		body: 'acc2-body'
		, boxWrap: true
		, wrapEl: 'acc2-wrap'
		, fitContainer: true
		, fitToFrame: true
		, fitHeight: true
		, initialHeight: 240
		, desktop: 'center-accordions'
//		, animate: false
	});
	// }}}
	// {{{
	// add panels to fitHeight accordion
	acc2.add(new Ext.ux.InfoPanel('panel2-1', {
		icon: iconPath + 'calendar_view_month.png'
//		, autoScroll: true
	}));

	acc2.add(new Ext.ux.InfoPanel('panel2-2', {
		icon: iconPath + 'database_table.png'
	}));

	acc2.add(new Ext.ux.InfoPanel('panel2-3', {
		icon: iconPath + 'cart.png'
	}));

	acc2.add(new Ext.ux.InfoPanel('panel2-4', {
		icon: iconPath + 'email.png'
	}));

	acc2.add(new Ext.ux.InfoPanel('panel2-5', {
		icon: iconPath + 'feed.png'
	}));
	// }}}
	// {{{
	// resizing of fitHeight accordion
	var acc2Ct = Ext.get('acc2-ct');
	var resizer = new Ext.Resizable(acc2Ct, {
		handles:'s e se'
		, transparent: true
		, minHeight: 180 //244
		, minWidth: 150 // 224
		, pinned: true
	});
	resizer.on({
		beforeresize: {
			scope:acc2
			, fn: function(r, e) {

				// save old sizes
				r.oldSize = acc2Ct.getSize();
				r.oldAccSize = this.body.getSize();
		}}
		, resize: {
			scope:acc2
			, fn: function(r, w, h, e) {

				// calculate deltas
				var dw, dh;
				dw = w - r.oldSize.width;
				dh = h - r.oldSize.height;

				// resize Accordion 
				this.setSize(r.oldAccSize.width + dw, r.oldAccSize.height + dh);

		}}
	});
	// }}}
	// {{{
	// Accordion in dialog 
	var accDlgShow = function(btn, e) {

		var dpanel4, stickyNote;

		// {{{
		// lazy create the dialog
		if(!this.dlg) {

			// create the BasicDialog
			this.dlg = new Ext.BasicDialog('acc-dialog', {
				width: 220
				, height: 220
				, x: 560
				, y: 144
				, modal: false
				, shadow: true
				, proxyDrag: true
			});

			// add hide on escape pressed handler
			this.dlg.addKeyListener(27, this.dlg.hide, this.dlg);

			// create the Accordion
			this.acc = new Ext.ux.Accordion(this.dlg.body, {
				fitHeight: true
				, fitToFrame: true
				, fitContainer: true
				, desktop: 'center-accordions'
				, autoScroll: false
			});

			// add panels
			this.acc.add(new Ext.ux.InfoPanel('dpanel-1', {
				icon: iconPath + 'application_home.png'
			}));

			this.acc.add(new Ext.ux.InfoPanel('dpanel-2', {
				icon: iconPath + 'emoticon_happy.png'
			}));

			this.acc.add(new Ext.ux.InfoPanel('dpanel-3', {
				icon: iconPath + 'mouse.png'
			}));

			// inform accordion of dialog resize
			this.dlg.on('resize', function(dlg, w, h) {
				this.setSize(dlg.body.getWidth(), dlg.body.getHeight());
			}, this.acc);

			// update text of show/hide button
			this.dlg.on('show', function() {
				btn.setText('Hide Accordion Dialog');
				this.setPanelHeight();

				// fix the firefox cursor bug
//				var dlgCt;
//				if(Ext.isGecko) {
//					dlgCt = Ext.get('acc-dialog');
//					dlgCt.setStyle('overflow','');
//					dlgCt.setStyle.defer(10, dlgCt, ['overflow','auto']);
//				}

			}, this.acc);
			this.dlg.on('hide', function() {btn.setText('Show Accordion Dialog');});

//			this.acc.restoreState();
//			if(!dpanel4.collapsed) {
//				stickyNote.fitToParent();
//			}

		} // end of dlg lazy creation
		// }}}

		// show/hide dialog on button click
		if(this.dlg.isVisible()) {
			this.dlg.hide(btn.el);
		}
		else {
			this.dlg.show(btn.el);
		}
	}; // end of function accDlgShow
	// }}}
	// {{{
	// create show/hide dialog button
	var btnDlg = new Ext.Button('btn-show-dlg', {
		icon: iconPath + 'application.png'
		, cls: 'x-btn-text-icon'
		, text: 'Show Accordion Dialog'
		, scope: accDlgShow
		, handler: accDlgShow
	});
	// }}}
// {{{
	// independent panels example
	var ipanel1 = new Ext.ux.InfoPanel('ipanel-1', {
		collapsed: false
	});
	var ipanel2 = new Ext.ux.InfoPanel('ipanel-2', {
		animate: false
	});
	var ipanel3 = new Ext.ux.InfoPanel('ipanel-3', {
		trigger: 'button'
	});
	var ipanel4 = new Ext.ux.InfoPanel('ipanel-4', {
		title:'4. Container from markup'
		, content: 
			'<div class="text-content">'
			+ '<h3>Container from markup, body from code</h3>'
//			+ '<p>&nbsp;</p>'
			+ '<p>Markup:<p>'
			+ '<pre class="code">'
			+ '&lt;div id="ipanel-4"&gt;&lt/div&gt;'
			+ '</pre>'
			+ '<p>Code:<p>'
			+ '<pre class="code">'
			+ 'new Ext.ux.InfoPanel(\'ipanel-4\', {\n'
			+ '  title:\'4. Container from...\'\n'
			+ '  , content:\'This text.\'\n'
			+ '  , useShadow:true\n'
			+ '  , easingCollapse: \'backIn\'\n'
			+ '  , easingExpand: \'backOut\'\n'
			+ '});'
			+ '</pre>'
			+ '</div>'
		, useShadow: true
		, easingCollapse: 'backIn'
		, easingExpand: 'backOut'
	});

	var ipanel5 = new Ext.ux.InfoPanel('ipanel-5', {
		useShadow: true
		, draggable: true
		, desktop:'panels-tab'
		, duration: 1.0
	});

	var ipanel6 = new Ext.ux.InfoPanel({
		title: '6. Auto-created panel, no markup'
		, id:'ipanel-6'
		, desktop: 'panels-tab'
		, draggable: true
		, useShadow: true
		, autoCreate: {
			tag:'div'
			, children:[{
				tag:'div'
				, cls:'text-content'
				, html: '<h3>No html markup, autoCreate object.</h3>'
				+ '<p>&nbsp;</p>'
				+ '<p>Code:</p>'
				+ '<pre class="code">'
				+ 'new Ext.ux.InfoPanel({\n'
				+ '    title: \'6. Auto-created...\'\n'
				+ '  , id: \'ipanel-6\'\n'
				+ '  , desktop: \'panels-tab\'\n'
				+ '  , draggable: true\n'
				+ '  , useShadow: true\n'
				+ '  , autoCreate: {\n'
				+ '      tag: \'div\'\n'
				+ '    , children:[{\n'
				+ '        tag: \'div\'\n'
				+ '      , cls: \'text-content\'\n'
				+ '      , html: \'This text.\'\n'
				+ '    }]\n'
				+ '  }\n'
				+ '});'
				+ '</pre>'
			}]
		}
	});

	var ipanel7 = new Ext.ux.InfoPanel({
		title: '7. Auto-created, body from markup'
		, id: 'ipanel-7'
		, desktop: 'panels-tab'
		, bodyEl: 'ipanel-7-body'
		, autoCreate: true
		, draggable: true
		, useShadow: true
		, resizable: true
	});

	if(showGrid) {
		var ipanel8 = new Ext.ux.InfoPanel({
			id: 'ipanel-8'
			, title: '8. Grid in the panel'
			, reiszable: true
			, collapsed: true
			, draggable: true
			, resizable: true
			, animate: false
			, useShadow: true
		//	, autoScroll: true
			, desktop: 'panels-tab'
			, autoCreate: {
				tag:'div'
				, style: 'position:absolute;width:600px;left:244px;top:130px'
				, children: [{
					tag: 'div'
					, style: 'height:300px;overflow:auto'
					, id: 'grid-ct'
				}]
			}
		});

        // some data yanked off the web
        var myData = [
			['3m Co',71.72,0.02,0.03,'9/1 12:00am'],
            ['Alcoa Inc',29.01,0.42,1.47,'9/1 12:00am'],
            ['Altria Group Inc',83.81,0.28,0.34,'9/1 12:00am'],
            ['American Express Company',52.55,0.01,0.02,'9/1 12:00am'],
            ['American International Group, Inc.',64.13,0.31,0.49,'9/1 12:00am'],
            ['AT&T Inc.',31.61,-0.48,-1.54,'9/1 12:00am'],
            ['Boeing Co.',75.43,0.53,0.71,'9/1 12:00am'],
            ['Caterpillar Inc.',67.27,0.92,1.39,'9/1 12:00am'],
            ['Citigroup, Inc.',49.37,0.02,0.04,'9/1 12:00am'],
            ['E.I. du Pont de Nemours and Company',40.48,0.51,1.28,'9/1 12:00am'],
            ['Exxon Mobil Corp',68.1,-0.43,-0.64,'9/1 12:00am'],
            ['General Electric Company',34.14,-0.08,-0.23,'9/1 12:00am'],
            ['General Motors Corporation',30.27,1.09,3.74,'9/1 12:00am'],
            ['Hewlett-Packard Co.',36.53,-0.03,-0.08,'9/1 12:00am'],
            ['Honeywell Intl Inc',38.77,0.05,0.13,'9/1 12:00am'],
            ['Intel Corporation',19.88,0.31,1.58,'9/1 12:00am'],
            ['International Business Machines',81.41,0.44,0.54,'9/1 12:00am'],
            ['Johnson & Johnson',64.72,0.06,0.09,'9/1 12:00am'],
            ['JP Morgan & Chase & Co',45.73,0.07,0.15,'9/1 12:00am'],
            ['McDonald\'s Corporation',36.76,0.86,2.40,'9/1 12:00am'],
            ['Merck & Co., Inc.',40.96,0.41,1.01,'9/1 12:00am'],
            ['Microsoft Corporation',25.84,0.14,0.54,'9/1 12:00am'],
            ['Pfizer Inc',27.96,0.4,1.45,'9/1 12:00am'],
            ['The Coca-Cola Company',45.07,0.26,0.58,'9/1 12:00am'],
            ['The Home Depot, Inc.',34.64,0.35,1.02,'9/1 12:00am'],
            ['The Procter & Gamble Company',61.91,0.01,0.02,'9/1 12:00am'],
            ['United Technologies Corporation',63.26,0.55,0.88,'9/1 12:00am'],
            ['Verizon Communications',35.57,0.39,1.11,'9/1 12:00am'],
            ['Wal-Mart Stores, Inc.',45.45,0.73,1.63,'9/1 12:00am'],
            ['Walt Disney Company (The) (Holding Company)',29.89,0.24,0.81,'9/1 12:00am']
		];

        var ds = new Ext.data.Store({
		        proxy: new Ext.data.MemoryProxy(myData),
		        reader: new Ext.data.ArrayReader({}, [
                       {name: 'company'},
                       {name: 'price', type: 'float'},
                       {name: 'change', type: 'float'},
                       {name: 'pctChange', type: 'float'},
                       {name: 'lastChange', type: 'date', dateFormat: 'n/j h:ia'}
                  ])
        });
        ds.load();

		// example of custom renderer function
        function italic(value){
            return '<i>' + value + '</i>';
        }

		// example of custom renderer function
        function change(val){
            if(val > 0){
                return '<span style="color:green;">' + val + '</span>';
            }else if(val < 0){
                return '<span style="color:red;">' + val + '</span>';
            }
            return val;
        }
		// example of custom renderer function
        function pctChange(val){
		    if(val > 0){
		        return '<span style="color:green;">' + val + '%</span>';
		    }else if(val < 0){
		        return '<span style="color:red;">' + val + '%</span>';
		    }
		    return val;
		}

		// the DefaultColumnModel expects this blob to define columns. It can be extended to provide
        // custom or reusable ColumnModels
        var colModel = new Ext.grid.ColumnModel([
			{id:'company',header: "Company", width: 160, sortable: true, locked:false, dataIndex: 'company'},
			{header: "Price", width: 75, sortable: true, renderer: Ext.util.Format.usMoney, dataIndex: 'price'},
			{header: "Change", width: 75, sortable: true, renderer: change, dataIndex: 'change'},
			{header: "% Change", width: 75, sortable: true, renderer: pctChange, dataIndex: 'pctChange'},
			{header: "Last Updated", width: 85, sortable: true, renderer: Ext.util.Format.dateRenderer('m/d/Y'), dataIndex: 'lastChange'}
		]);


		// create the Grid
		var grid = new Ext.grid.Grid('grid-ct', {
			ds: ds
			, cm: colModel
			, autoExpandColumn: 'company'
//			, enableColumnMove: false
		});
        
//        var gridLayout = Ext.BorderLayout.create({
//            center: {
//                margins:{left:3,top:3,right:3,bottom:3},
//                panels: [new Ext.GridPanel(grid)]
//            }
//        }, 'grid-panel-ct');

//		grid.render();
//		grid.getSelectionModel().selectFirstRow();

		ipanel8.on({
			expand: {
				scope: grid
				, single: true
				, fn: function(panel) {
					this.render();
					this.getSelectionModel().selectFirstRow();
			}}
			, resize: {
				scope: grid
				, fn: function() {
					Ext.get('grid-ct').fitToParent();
					grid.autoSize();
			}}
		});
} // if(showGrid) end

//	var ipanel9 = new Ext.ux.InfoPanel({
//		title: '9. Loaded by Ajax on expand'
//		, id:'ipanel-9'
//		, url: 'panel-content.php'
//		, desktop: 'panels-tab'
//		, draggable: true
//		, resizable: true
//		, useShadow: true
////		, loadOnce: true
//		, autoCreate: {
//			tag: 'div'
//			, style: 'position:absolute;width:200px;top:350px;left:20px'
//		}
//	});
// }}}
	// {{{
	// add panels to layout
	layout.beginUpdate();

	// east
	layout.add('east', new Ext.ContentPanel('east', {}));

	// page header (north)
	layout.add('north', new Ext.ContentPanel('north', {}));

	// south
	layout.add('south', new Ext.ContentPanel('south', "South"));

	// center - Introduction
	layout.add('center', new Ext.ContentPanel('center-intro', {
		title:"Introduction"
		, fitContainer:true
		, fitToFrame: true
		, autoScroll: true
	}));

	// center - How to
	layout.add('center', new Ext.ContentPanel('center-howto', {
		title:"Howto"
		, fitContainer:true
		, fitToFrame: true
		, autoScroll: true
	}));

	// center - Accordions
	layout.add('center', new Ext.ContentPanel('center-accordions', {
		title:"Accordions"
		, fitContainer:true
		, fitToFrame: true
		, autoScroll: true
	}));

	// center - Panels
	var panelsTab = new Ext.ContentPanel('panels-tab', {
		title: 'Panels'
		, fitToFrame:true
		, fitContainer:true
		, autoScroll: true
	});

	panelsTab.on('resize', ipanel5.moveToViewport, ipanel5);
	panelsTab.on('resize', ipanel6.moveToViewport, ipanel6);
	panelsTab.on('resize', ipanel7.moveToViewport, ipanel7);

	layout.add('center', panelsTab);

	// center - Search results iframe
	layout.add('center', new Ext.ContentPanel('center-result', {
		title:"Result"
		, fitToFrame: true
		, autoCreate: {
			tag: 'iframe'
			, id: 'center-result'
			, frameborder: 0
		}
	}));

	// accordion in west
	layout.add('west', acc);

	layout.restoreState();

	// {{{
	// restore state
	// get last selected tab
	var tabId = Ext.state.Manager.get("tab");

	// event handler that saves currently selected tab
	var center = layout.getRegion('center');
	center.on('panelactivated', function(region, panel) {
		var tabId = panel.el.id;
		Ext.state.Manager.set("tab", tabId);
	});

	// restore selected tab
	layout.getRegion('center').showPanel(tabId || 'center-intro');

	// restore dock state
	acc.restoreState();

	// update state of global toolbar buttons
	acc.toolbar.items.get('btn-independent').toggle(acc.independent);	
	acc.toolbar.items.get('btn-undockable').toggle(acc.undockable);	
	acc.toolbar.items.get('btn-shadow').toggle(acc.useShadow);

	// }}}

	layout.endUpdate();
	// }}}
	// {{{
	// searching within panel bodies example
	var find = acc.toolbar.items.get('find-field');
	Ext.fly(find.el).on('keyup', searchPanels, acc, {buffer:150});

	function searchPanels(e) {

		var re, found;
		// ignore special and navigation keys
		if(e.isSpecialKey() || e.isNavKeyPress()) {
			return;
		}

		var val = find.el.value;
		// ignore if length is 1 or 2
		if(val.length < 3 && val.length > 0) {
			return;
		}
		
		// show all panels collapsed when filter is cleared
		else if(0 === val.length) {
			this.showAll();
			this.collapseAll();
		}

		// find panels containing the entered text
		else {
			re = new RegExp('.*' + val + '.*', 'i');
			found = false;
			this.hideAll();
			this.items.each(function(panel) {
				if((found && !this.independent) || !panel.docked) {
					return;
				}
				if(panel.body.dom.innerHTML.match(re)) {
					panel.show();
					panel.expand();
					found = true;
				}
				else {
					panel.collapse();
					panel.hide();
					found = false;
				}
			}, this);
		}
	}
	// }}}

	// adjust east styles
	Ext.fly('east').applyStyles({top:'', left:'', position:'static'});

	Ext.fly('stumble').insertAfter('west-body');	

	// remove the loading mask
	unmask.defer(100);


}); // end of onReady

// end of file
