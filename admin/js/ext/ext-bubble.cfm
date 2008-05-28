<cfoutput>
Ext.example = function(){
var msgCt;

function createBox(t, s, c){
    return ['<div class="msg">',
            '<div class="x-box-tl"><div class="x-box-tr"><div class="x-box-tc"></div></div></div>',
            '<div class="x-box-ml"><div class="x-box-mr"><div class="x-box-mc">', c, '<h3>', t, '</h3>', s, '</div></div></div>',
            '<div class="x-box-bl"><div class="x-box-br"><div class="x-box-bc"></div></div></div>',
            '</div>'].join('');
}
return {
    msg : function(title, format, pause, autoHide){
        if(!msgCt){
            msgCt = Ext.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
        }
        msgCt.alignTo(document, 't-t');
        var s = String.format.apply(String, Array.prototype.slice.call(arguments, 1));
        
        if(autoHide){
        	var m = Ext.DomHelper.append(msgCt, {html:createBox(title, s, '')}, true);
       		m.slideIn('t').pause(pause).ghost("t", {remove:true});

        }
       	else {
       		var closer = '<img src="#application.url.webtop#/js/ext/resources/images/default/qtip/close.gif" width="15" height="15" style="float:right;" />';
           		var m = Ext.DomHelper.append(msgCt, {html:createBox(title, s, closer)}, true);
           		m.slideIn('t');
			    m.on('click', function(){
	                m.ghost("t", {remove:true});
	            });
           	}
        },

        init : function(){
            var t = Ext.get('exttheme');
            if(!t){ // run locally?
                return;
            }
            var theme = Cookies.get('exttheme') || 'aero';
            if(theme){
                t.dom.value = theme;
                Ext.getBody().addClass('x-'+theme);
            }
            t.on('change', function(){
                Cookies.set('exttheme', t.getValue());
                setTimeout(function(){
                    window.location.reload();
                }, 250);
            });

            var lb = Ext.get('lib-bar');
            if(lb){
                lb.show();
            }
        }
    };
}();

</cfoutput>