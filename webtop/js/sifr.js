/*=:project
		parseSelector 2.0
		
	=:description
		Provides an extensible way of parsing CSS selectors against a DOM in 
		JavaScript.

  =:file
  	Copyright: 2006 Mark Wubben.
  	Author: Mark Wubben, <http://novemberborn.net/>
   		
	=:license
		* This software is licensed and provided under the CC-GNU LGPL
		* See <http://creativecommons.org/licenses/LGPL/2.1/>
	
	=:notes
		* The parsing of CSS selectors as streams has been based on Dean Edwards
			excellent work with cssQuery. See <http://dean.edwards.name/my/cssQuery/>
			for more info.
*/

var parseSelector = (function() {
	var SEPERATOR = /\s*,\s*/
	
	function parseSelector(selector, node) {
		node = node || document.documentElement;
		var argSelectors = selector.split(SEPERATOR);
		var result = [];
		
		for(var i = 0; i < argSelectors.length; i++) {
			var nodes = [node];
			var stream = toStream(argSelectors[i]);
			for(var j = 0;j < stream.length;) {
				var token = stream[j++];
				var filter = stream[j++];
				var args = '';
				if(stream[j] == '(') {
					while(stream[j++] != ')' && j < stream.length) args += stream[j];
					args = args.slice(0, -1);
				}
				nodes = select(nodes, token, filter, args);
			}
			result = result.concat(nodes);
		}
		
		return result;
	}

	var WHITESPACE = /\s*([\s>+~(),]|^|$)\s*/g;
	var IMPLIED_ALL = /([\s>+~,]|[^(]\+|^)([#.:@])/g;
	var STANDARD_SELECT = /^[^\s>+~]/;
	var STREAM = /[\s#.:>+~()@]|[^\s#.:>+~()@]+/g;
		
	function toStream(selector) {
		var stream = selector.replace(WHITESPACE, '$1')
												 .replace(IMPLIED_ALL, '$1*$2');
		if(STANDARD_SELECT.test(stream)) stream = ' ' + stream;
    return stream.match(STREAM) || [];
	}
	
	function select(nodes, token, filter, args) {
		return (selectors[token]) ? selectors[token](nodes, filter, args) : [];
	}
	
	var util = {
		toArray: function(enumerable) {
			var a = [];
			for(var i = 0; i < enumerable.length; i++) util.push(a, enumerable[i]);
			return a;
		},
		
		push: function(arr) {
      for(var i = 1; i < arguments.length; i++) arr[arr.length] = arguments[i];
      return arr.length;
    }
	};
	
	var dom = {
		isTag: function(node, tag) {
			return (tag == '*') || (
				tag.toLowerCase() == node.nodeName.toLowerCase().replace(':html', '')
			);
		},
	
		previousSiblingElement: function(node) {
			do node = node.previousSibling; while(node && node.nodeType != 1);
			return node;
		},
	
		nextSiblingElement: function(node) {
			do node = node.nextSibling; while(node && node.nodeType != 1);
			return node;
		},
	
		hasClass: function(name, node) {
			return (node.className || '').match('(^|\\s)'+name+'(\\s|$)');
		},
	
		getByTag: function(tag, node) {
			/*	IE5.x does not support document.getElementsByTagName("*")
				therefore we're falling back to element.all */
			if(tag == '*') {
			  var nodes = node.getElementsByTagName(tag);
			  if(nodes.length == 0 && node.all != null) return node.all
			  return nodes;
		  }
			return node.getElementsByTagName(tag);
		}
	};

	var selectors = {
		'#': function(nodes, filter) {
			for(var i = 0; i < nodes.length; i++) {
				if(nodes[i].getAttribute('id') == filter) return [nodes[i]];
			}
			return [];
		},

		' ': function(nodes, filter) {
			var result = [];
			for(var i = 0; i < nodes.length; i++) {
				result = result.concat(util.toArray(dom.getByTag(filter, nodes[i])));
			}
			return result;
		},
		
		'>': function(nodes, filter) {
			var result = [];
			for(var i = 0, node; i < nodes.length; i++) {
				node = nodes[i];
				for(var j = 0, child; j < node.childNodes.length; j++) {
					child = node.childNodes[j];
					if(child.nodeType == 1 && dom.isTag(child, filter)) {
						util.push(result, child);
					}
				}
			}
			return result;
		},

		'.': function(nodes, filter) {
			var result = [];
			for(var i = 0, node; i < nodes.length; i++) {
				node = nodes[i];
				if(dom.hasClass([filter], node)) util.push(result, node);
			}
			return result;
		}, 
				
		':': function(nodes, filter, args) {
			return (pseudoClasses[filter]) ? pseudoClasses[filter](nodes, args) : [];
		}
		
	};

	parseSelector.selectors			= selectors;
	parseSelector.pseudoClasses = {};
	parseSelector.util 				  = util;
	parseSelector.dom 				  = dom;

	return parseSelector;
})();

/*=:project
    scalable Inman Flash Replacement (sIFR) version 3, revision 176

  =:file
    Copyright: 2006 Mark Wubben.
    Author: Mark Wubben, <http://novemberborn.net/>

  =:history
    * IFR: Shaun Inman
    * sIFR 1: Mike Davidson, Shaun Inman and Tomas Jogin
    * sIFR 2: Mike Davidson, Shaun Inman, Tomas Jogin and Mark Wubben

  =:license
    * This software is licensed and provided under the CC-GNU LGPL
    * See <http://creativecommons.org/licenses/LGPL/2.1/>    
*/

var sIFR = new function() {
  //=:private Constant reference to the Singleton instance
  var SIFR = this;

  var CSS_HASFLASH = 'sIFR-hasFlash';
  var CSS_REPLACED = 'sIFR-replaced';
  var CSS_FLASH = 'sIFR-flash';
  var CSS_IGNORE = 'sIFR-ignore';
  var CSS_ALTERNATE = 'sIFR-alternate';
  var CSS_CLASS = 'sIFR-class';
  var XHTML_NS = 'http://www.w3.org/1999/xhtml';
  var MIN_FONT_SIZE = 6;
  var MAX_FONT_SIZE = 126;
  var MIN_FLASH_VERSION = 8;
  var PREFETCH_COOKIE = 'SIFR-PREFETCHED';
  var SINGLE_WHITESPACE = ' ';

  this.isActive = false;
  this.isEnabled = true;
  this.hideElements = true;
  this.replaceNonDisplayed = false;
  this.preserveSingleWhitespace = false;
  this.fixWrap = true;
  this.registerEvents = true;
  this.waitForPrefetch = true;
  this.cookiePath = '/';
  this.domains = [];
  this.fromLocal = true;
  // In Gecko, preceding the sIFR element with a floated element, inside a fixed-width wrapper,
  // gives wrong dimensions. Set this property to `true` to force the temporary clearing of the
  // sIFR element, which works around the problem.
  this.forceClear = false;
  // Force the Flash movie to take it's calculated width, instead of 100%. This may solve
  // issues with the Flash movie being clipped or hidden. It may also have negative
  // side effects.
  this.forceWidth = false;
  // Let JavaScript force the text transformation. In the future, if Flash supports
  // this natively, you might want to change this property depending on the Flash version.
  this.forceTextTransform = true;
  this.useDomContentLoaded = true;
  this.debugMode = false;

  var elementCount = 0;
  var hasPrefetched = false;
  var useDomContentLoaded = true;

  var ua = new function() {
    var ua = navigator.userAgent.toLowerCase();
    var product = (navigator.product || '').toLowerCase();

    this.macintosh  = ua.indexOf('mac') > -1;
    this.windows    = ua.indexOf('windows') > -1;
    this.quicktime  = false;

    this.opera      = ua.indexOf('opera') > -1;
    this.konqueror  = product.indexOf('konqueror') > -1;
    this.ie         = ua.indexOf('ie') > -1 && !this.opera;
    this.ieWin      = this.ie && this.windows;
    this.ieMac      = this.ie && this.macintosh;
    this.safari     = ua.indexOf('safari') > -1;
    this.webkit     = ua.indexOf('applewebkit') > -1 && !this.konqueror;
    this.khtml      = this.webkit || this.konqueror;
    this.gecko      = !this.webkit && product == 'gecko';

    var $;
    this.operaVersion = this.webkitVersion  
                      = this.geckoBuildDate 
                      = this.konquerorVersion = 0;

    if(this.opera) {
      $ = ua.match(/.*opera(\s|\/)(\d+\.\d+)/);
      this.operaVersion = $.length > 1 ? parseInt(RegExp.$2) : 0;
    }

    if(this.webkit) {
      $ = ua.match(/.*applewebkit\/(\d+).*/);
      this.webkitVersion = $.length > 0 ? parseInt(RegExp.$2) : 0;
      useDomContentLoaded = false;
    }

    if(this.gecko) {
      $ = ua.match(/.*gecko\/(\d{8}).*/);
      this.geckoBuildDate = $.length > 0 ? parseInt($[1]) : 0;
    }

    if(this.konqueror) {
      $ = ua.match(/.*konqueror\/(\d\.\d).*/);
      this.konquerorVersion = $.length > 0 ? parseInt($[1]) : 0;
    }

    this.flashVersion = 0;

    if(this.ieWin) {
      try {
        this.flashVersion = parseFloat(
          /([\d,?]+)/.exec(
            new ActiveXObject('ShockwaveFlash.ShockwaveFlash.7').GetVariable('$version')
          )[1].replace(/,/g, '.')
        );
      } catch(e) {}
    } else if(navigator.plugins && navigator.plugins['Shockwave Flash']) {
      var flashPlugin = navigator.plugins['Shockwave Flash'];
      this.flashVersion = parseFloat(/(\d+\.?\d*)/.exec(flashPlugin.description)[1]);

      // Watch out for QuickTime, which could be stealing the Flash handling!
      var i = 0;
      while(this.flashVersion >= MIN_FLASH_VERSION && i < navigator.mimeTypes.length) {
        var mime = navigator.mimeTypes[i];
        if(mime.type == 'application/x-shockwave-flash' && mime.enabledPlugin.description.toLowerCase().indexOf('quicktime') > -1) {
          this.flashVersion = 0;
          this.quicktime = true;
        }
        i++;
      }
    }

    this.flash = this.flashVersion >= MIN_FLASH_VERSION;

    this.transparencySupport = true;
    if(!this.macintosh && !this.windows
    || this.opera && this.operaVersion < 7.6 
    || this.webkit && this.webkitVersion < 312
    || this.gecko && this.geckoBuildDate < 20020523) {
      this.transparencySupport = false;
    }

    this.computedStyleSupport = true;
    if(!this.ie && !this.gecko 
    && (!document.defaultView || !document.defaultView.getComputedStyle)
    //: Older Geckos have trouble with `getComputedStyle()`
    || this.gecko && this.geckoBuildDate < 20030624) {
      this.computedStyleSupport = false;  
    }

    this.css = true; // Verified later when the dom methods have initialized.

    this.zoomSupport = !!(this.opera && document.documentElement);
    this.geckoXml = this.gecko && (document.contentType || '').indexOf("xml") > -1;

    this.innerHtmlHack =  this.konqueror || (this.webkit && this.webkitVersion < 312) || this.ie;
    this.requiresPrefetch = this.ieWin || this.safari;

    this.supported = (!this.ie || this.ieWin) && (!this.macintosh || !this.opera || this.operaVersion >= 8) 
      && (!ua.webkit || ua.webkitVersion >= 100)  && this.computedStyleSupport
      && !!(Array.prototype.push && Array.prototype.pop && Array.prototype.splice);
  };
  this.ua = ua;

  var dom = new function() {
    this.getBody = function() {
      var nodes = document.getElementsByTagName('body');
      if(nodes.length == 1) return nodes[0];
    };

    this.addClass = function(name, node) {
      node.className = ((node.className || '') == '' ? '' : node.className + ' ') + name;
    };

    this.hasClass = function(name, node) {
      return new RegExp('(^|\\s)'+name+'(\\s|$)').test(node.className);
    };

    this.create = function(name) {
      if(document.createElementNS) return document.createElementNS(XHTML_NS, name);
      return document.createElement(name);
    }

    var useInnerHtml;
    try { 
      var n = this.create('span');
      if(!ua.ieMac) n.innerHTML = 'x';
      useInnerHtml = n.innerHTML == 'x';
    } catch (e) { useInnerHtml = false; }

    this.setInnerHtml = function(node, html) {
      if(useInnerHtml) node.innerHTML = html;
      else {
        html = ['<root xmlns="', XHTML_NS, '">', html, '</root>'].join('');
        var xml = (new DOMParser()).parseFromString(html, 'text/xml');
        xml = document.importNode(xml.documentElement, true);
        while(node.firstChild) node.removeChild(node.firstChild);
        while(xml.firstChild)  node.appendChild(xml.firstChild);
      }
    }

    this.appendNode = function(to, node) {
      to.appendChild(node);
      if(this.innerHtmlHack) to.innerHTML += '';
    }

    this.getComputedStyle = function(node, property) {
      if(document.defaultView && document.defaultView.getComputedStyle) {
        return document.defaultView.getComputedStyle(node, null)[property];
      } else if(node.currentStyle) return node.currentStyle[property];
    }

    this.getStyleAsInt = function(node, property, requirePx) {
      var value = this.getComputedStyle(node, property);
      if(requirePx && !/px$/.test(value)) return 0;
      
      value = parseInt(value);
      return isNaN(value) ? 0 : value;
    }

    this.getZoom = function() {
      return hacks.zoom.getLatest();
    }
  };
  this.dom = dom;

  // Verify CSS support, both ua and dom fields are needed.
  if(ua.computedStyleSupport) {
    try { // Not sure if there are user agents which will disallow this
      var node = document.getElementsByTagName('head')[0];
      node.style.backgroundColor = '#FF0000';
      ua.css = /\#F{2}0{4}|rgb\(255,\s?0,\s?0\)/i.test(dom.getComputedStyle(node, 'backgroundColor'));
      node = null;
      ua.supported = ua.supported && ua.css;
    } catch(e) {}
  }
  
  function __sifr_capitalize__($) {
    return $.toUpperCase();
  }

  var util = {
    normalize: function(str) {
      if(SIFR.preserveSingleWhitespace) return str.replace(/\s/g, SINGLE_WHITESPACE);
      return str.replace(/(\s)\s+/g, '$1');
    },
    
    textTransform: function(type, str) {
      switch(type) {
        case 'uppercase':
          str = str.toUpperCase();
          break;
        
        case 'lowercase':
          str = str.toLowerCase();
          break;
          
        case 'capitalize':
          var strCopy = str;
          str = str.replace(/^\w|\s\w/g, __sifr_capitalize__);
          if(str.indexOf('function __sifr_capitalize__') != -1) {
            var substrs = strCopy.replace(/(^|\s)(\w)/g, '$1$1$2$2').split(/^\w|\s\w/g);
            str = '';
            for(var i = 0; i < substrs.length; i++) str += substrs[i].charAt(0).toUpperCase() + substrs[i].substring(1);
          }
          break;
      }
      
      return str;
    },
    
    toHexString: function(str) {
      if(typeof(str) != 'string' || !str.charAt(0) == '#' || str.length != 4 && str.length != 7) return str;
      
      str = str.replace(/#/, '');
      if(str.length == 3) str = str.replace(/(.)(.)(.)/, '$1$1$2$2$3$3');

      return '0x' + str;
    },

    toJson: function(obj) {
      var json = '';

      switch(typeof(obj)) {
        case 'string':
          json = '"' + obj + '"';
          break;
        case 'number':
        case 'boolean':
          json = obj.toString();
          break;
        case 'object':
          json = [];
          for(var prop in obj) {
            if(obj[prop] == Object.prototype[prop]) continue;
            json.push('"' + prop + '":' + util.toJson(obj[prop]));
          }
          json = '{' + json.join(',') + '}';
          break;
      }

      return json;
    },
    
    cssToString: function(arg) {
      var css = [];
      for(var selector in arg) {
        var rule = arg[selector];
        if(rule == Object.prototype[selector]) continue;

        css.push(selector, '{');
        for(var property in rule) {
          if(rule[property] == Object.prototype[property]) continue;
          css.push(property, ':', rule[property], ';');
        }
        css.push('}');
      }

      return escape(css.join(''));
    },
    
    toArray: function(arrayLike) {
      var arr = [];
      for(var i = 0; i < arrayLike.length; i++) arr.push(arrayLike[i]);
      return arr;
    }
  };
  this.util = util;

  var hacks = {};
  hacks.fragmentIdentifier = new function() {
    this.fix = true;

    var cachedTitle;
    this.cache = function() {
      cachedTitle = document.title;
    };

    function doFix() {
      document.title = cachedTitle;
    }

    this.restore = function() {
      if(this.fix) setTimeout(doFix, 0);
    };
  };

  // The zoom hack needs to be run before replace(). The synchronizer can be
  // used to ensure this.
  hacks.synchronizer = new function() {
    this.isBlocked = false;

    this.block = function() {
      this.isBlocked = true;
    };

    this.unblock = function() {
      this.isBlocked = false;
      blockedReplaceKwargsStore.replaceAll();
    };
  };

  // Detect the page zoom in Opera. Adapted from <http://virtuelvis.com/archives/2005/05/opera-measure-zoom>.
  hacks.zoom = new function() {
    // Latest zoom, assume 100
    var latestZoom = 100;

    this.getLatest = function() {
      return latestZoom;
    }

    if(ua.zoomSupport && ua.opera) {
      // Create the DOM element used to calculate the zoom.
      var node = document.createElement('div');
      node.style.position = 'fixed';
      node.style.left = '-65536px';
      node.style.top = '0';
      node.style.height = '100%';
      node.style.width = '1px';
      node.style.zIndex = '-32';
      document.documentElement.appendChild(node);

      function updateZoom() {
        if(!node) return;

        var zoom = window.innerHeight / node.offsetHeight;

        var correction = Math.round(zoom * 100) % 10;
        if(correction > 5) zoom = Math.round(zoom * 100) + 10 - correction;
        else zoom = Math.round(zoom * 100) - correction;

        latestZoom = isNaN(zoom) ? 100 : zoom;
        hacks.synchronizer.unblock();

        document.documentElement.removeChild(node);
        node = null;
      }

      hacks.synchronizer.block();

      // We need to wait a few ms before Opera the offsetHeight of the node
      // becomes available.
      setTimeout(updateZoom, 54);
    }
  };
  this.hacks = hacks;

  var replaceKwargsStore = {
    kwargs: [],
    replaceAll:  function() {
      for(var i = 0; i < this.kwargs.length; i++) SIFR.replace(this.kwargs[i]);
      this.kwargs = [];
    }
  };

  var blockedReplaceKwargsStore = {
    kwargs: [],
    replaceAll: replaceKwargsStore.replaceAll
  };

  // The goal here is not to prevent usage of the Flash movie, but running sIFR on possibly translated pages
  function isValidDomain() {
    if(SIFR.domains.length == 0) return true;

    var domain = '';
    try { // When trying to access document.domain on a Google-translated page with Firebug, I got an exception.
      domain = document.domain;
    } catch(e) {};

    if(SIFR.fromLocal && sIFR.domains[0] != 'localhost') sIFR.domains.unshift('localhost');

    for(var i = 0; i < SIFR.domains.length; i++) {
      if(SIFR.domains[i] == '*' || SIFR.domains[i] == domain) return true;
    }

    return false;
  }

  this.activate = function() {
    if(!ua.flash || !this.isEnabled || this.isActive || !isValidDomain() || !ua.supported) {
      return;
    }

    this.isActive = true;

    if(this.hideElements) this.setFlashClass();

    if(ua.ieWin && hacks.fragmentIdentifier.fix && window.location.hash != '') {
      hacks.fragmentIdentifier.cache();
    } else hacks.fragmentIdentifier.fix = false;

    if(!this.registerEvents) return;

    function handler(evt) {
      SIFR.initialize(true);

      // Remove handlers to prevent memory leak in Firefox 1.5, but only after
      // onload.
      if(evt && evt.type == 'load') {
        if(document.removeEventListener) {
          document.removeEventListener('DOMContentLoaded', handler, false);
          document.removeEventListener('load', handler, false);
        }
        if(window.removeEventListener) window.removeEventListener('load', handler, false);
      }
    }
    
    useDomContentLoaded == useDomContentLoaded && SIFR.useDomContentLoaded;

    if((!ua.konqueror || ua.konquerorVersion < 3.5) 
    && (document.addEventListener || window.addEventListener)) {
      if(document.addEventListener) {
        // Whichever fires first
        if(useDomContentLoaded) document.addEventListener('DOMContentLoaded', handler, false);
        // Workaround carried over from sIFR 2 for when window.onload using DOM1
        // would not fire, probably in Safari.
        document.addEventListener('load', handler, false);
      }
      if(window.addEventListener) window.addEventListener('load', handler, false);
    } else if(window.attachEvent) {
        // Use onreadystatechange on the document as opposed to a <script> tag
        // hack, see <http://trac.dojotoolkit.org/ticket/1422>.
        if(useDomContentLoaded) {
          document.attachEvent('onreadystatechange', function() {
            // Use setTimeout() because of <http://peterjanes.ca/blog/2003/12/03/hulk-smash>.
            if(document.readyState == 'complete') setTimeout(handler, 0);
          });
        }
        window.attachEvent('onload', handler);
    } else {
      if(typeof window.onload == 'function'){
        var fOld = window.onload;
        window.onload = function(evt){ fOld(evt); handler(evt); };
      } else window.onload = handler;
    }
  };

  this.hasFlashClass = false;
  this.setFlashClass = function() {
    if(this.hasFlashClass) return;

    dom.addClass(CSS_HASFLASH, dom.getBody() || document.documentElement);
    this.hasFlashClass = true;
  };

  this.isInitialized = false;
  this.initialize = function(evt) {
    if(this.isInitialized || !this.isActive || !this.isEnabled 
    || !evt && (ua.requiresPrefetch && hasPrefetched && this.waitForPrefetch || !this.uaCompletedRendering())) {
      return;
    }

    this.isInitialized = true;
    replaceKwargsStore.replaceAll();
    clearPrefetch();
  };

  this.uaCompletedRendering = function() {
    return (this.isInitialized || !ua.khtml && !ua.geckoXml && !!dom.getBody());
  };

  function getSource(src) {
    if(typeof(src) != 'string') {
      // This is a niciety to allow you to create general configuration objects
      // for the prefetch as well as the replacement. You could create constructs
      // like `{src: {src: { /*....*/ }}}`, but that's not really a problem.
      if(src.src) src = src.src;

      // It might be a string now...
      if(typeof(src) != 'string') {
        var versions = [];
        for(var version in src) if(src[version] != Object.prototype[version]) versions.push(version);
        versions.sort().reverse();

        for(var i = 0; i < versions.length; i++) {
          if(parseFloat(versions[i]) <= ua.flashVersion) return src[versions[i]];
        }
      }
    }
    
    if(!src) throw new Error("sIFR: Could not determine appropriate source");
    
    // Some IE installs refuse to show the Flash unless it gets the really absolute
    // URI of the file. I haven't been able to reproduce this behavior but let's
    // ensure a full URI none the less.
    if(ua.ie && src.charAt(0) == '/') {
      src = window.location.toString().replace(/([^:]+)(:\/?\/?)([^\/]+).*/, '$1$2$3') + src;
    }
    
    return src;
  }

  this.prefetch = function() {
    if(!ua.requiresPrefetch || !ua.flash || !this.isEnabled || !isValidDomain()) return;
    if(this.waitForPrefetch && new RegExp(';?' + PREFETCH_COOKIE + '=true;?').test(document.cookie)) return;

    try { // We don't know which DOM actions the user agent will allow
      hasPrefetched = true;

      if(ua.ieWin) prefetchIexplore(arguments);
      else prefetchLight(arguments);

      if(this.waitForPrefetch) document.cookie = PREFETCH_COOKIE + '=true;path=' + this.cookiePath;
    } catch(e) {
      if(SIFR.debugMode) throw e;
    }
  };

  function prefetchIexplore(args) {
    for(var i = 0; i < args.length; i++) document.write('<embed src="' + getSource(args[i]) + '" sIFR-prefetch="true" style="display:none;">');
  }

  // Lightweight prefetch method
  function prefetchLight(args) {
    for(var i = 0; i < args.length; i++) new Image().src = getSource(args[i]);
  }

  function clearPrefetch() {
    if(!ua.ieWin || !hasPrefetched) return;

    try {
      var nodes = document.getElementsByTagName('embed');
      for(var i = nodes.length - 1; i >= 0; i--) {
        var node = nodes[i];
        if(node.getAttribute('sIFR-prefetch') == 'true') node.parentNode.removeChild(node);
      }
    } catch(e) {}
  }

  // Gives a font-size to required vertical space ratio
  // Tested with Verdana
  function getRatio(size) {
    if(size <= 10) return 1.55;
    if(size <= 19) return 1.45;
    if(size <= 32) return 1.35;
    if(size <= 71) return 1.30;
    return 1.25;
  }

  function convertCssArg(arg) {
    if(!arg) return {};
    if(typeof(arg) == 'object') {
      if(arg.constructor == Array) arg = arg.join('');
      else return arg;
    }

    var obj = {};
    var rules = arg.split('}');

    for(var i = 0; i < rules.length; i++) {
      var $ = rules[i].match(/([^\s{]+)\s*\{(.+)\s*;?\s*/);
      if(!$ || $.length != 3) continue;

      obj[$[1]] = {};

      var properties = $[2].split(';');
      for(var j = 0; j < properties.length; j++) {
        var $2 = properties[j].match(/\s*([^:\s]+)\s*\:\s*([^\s;]+)/);
        if(!$2 || $2.length != 3) continue;
        obj[$[1]][$2[1]] = $2[2];
      }
    }

    return obj;
  }

  function extractFromCss(css, selector, property, remove) {
    var value = null;

    if(css && css[selector] && css[selector][property]) {
      value = css[selector][property];
      if(remove) delete css[selector][property];
    }

    return value;
  }

  function getFilters(obj) {
    var filters = [];
    for(var filter in obj) {
      if(obj[filter] == Object.prototype[filter]) continue;

      var properties = obj[filter];
      filter = [filter.replace(/filter/i, '') + 'Filter'];

      for(var property in properties) {
        if(properties[property] == Object.prototype[property]) continue;
        filter.push(property + ':' + escape(util.toJson(util.toHexString(properties[property]))));
      }

      filters.push(filter.join(','));
    }

    return filters.join(';');
  }

  this.replace = function(kwargs, mergeKwargs) {
    if(!ua.supported) return;
    
    // This lets you specify to kwarg objects so you don't have to repeat common settings.
    // The first object will be merged with the second, while properties in the second 
    // object have priority over those in the first. The first object is unmodified
    // for further use, the resulting second object will be used in the replacement.
    if(mergeKwargs) {
      for(var property in kwargs) {
        if(typeof(mergeKwargs[property]) == 'undefined') mergeKwargs[property] = kwargs[property];
      }
      kwargs = mergeKwargs;
    }
    
    if(!this.isInitialized) return replaceKwargsStore.kwargs.push(kwargs);
    if(hacks.synchronizer.isBlocked) return blockedReplaceKwargsStore.kwargs.push(kwargs);

    var nodes = parseSelector(kwargs.selector);
    if(nodes.length == 0) return;

    this.setFlashClass();

    var src = getSource(kwargs.src);
    var css = convertCssArg(kwargs.css);
    var filters = getFilters(kwargs.filters);
    
    var forceClear = (kwargs.forceClear == null) ? SIFR.forceClear : kwargs.forceClear;
    var fitExactly = (kwargs.fitExactly == null) ? SIFR.fitExactly : kwargs.fitExactly;
    var forceWidth = fitExactly || (kwargs.forceWidth == null ? SIFR.forceWidth : kwargs.forceWidth);

    var leading = parseInt(extractFromCss(css, '.sIFR-root', 'leading')) || 0;
    var backgroundColor = extractFromCss(css, '.sIFR-root', 'background-color', true) || '#FFFFFF';
    var opacity = extractFromCss(css, '.sIFR-root', 'opacity', true) || '100';
    if(parseFloat(opacity) < 1) opacity = 100 * parseFloat(opacity); // Make sure to support percentages and decimals
    var blendMode = extractFromCss(css, '.sIFR-root', 'blend-mode', true) || 'normal';
    var gridFitType = kwargs.gridFitType || extractFromCss(kwargs.css, '.sIFR-root', 'text-align') != 'left' ? 'subpixel' : 'pixel';
    var textTransform = SIFR.forceTextTransform ? extractFromCss(css, '.sIFR-root', 'text-transform', true) || 'none' : 'none';

    var cssText = '';
    // Alignment is handled by the browser in this case.
    if(fitExactly) extractFromCss(css, '.sIFR-root', 'text-align', true);
    if(!kwargs.modifyCss) cssText = util.cssToString(css);

    var wmode = (backgroundColor == 'transparent') ? backgroundColor : kwargs.wmode || '';
    if(wmode == 'transparent') {
			if(!ua.transparencySupport)	wmode = 'opaque';
			else backgroundColor = 'transparent';
		}

    for(var i = 0; i < nodes.length; i++) {
      var node = nodes[i];

      if(dom.hasClass(CSS_REPLACED, node) || dom.hasClass(CSS_IGNORE, node)) {
        continue;
      }

      // Elements with no height (`0` in IE, `undefined` in Safari) are usually `display: none`.
      // Let's attempt to display them and replace them anyway.
      var resetDisplay = false;

      // Without a height, we can't function. Tring again with display:block…
      // See also <http://www.snook.ca/archives/javascript/safari2_display-none_getcomputedstyle/>.
      if(!node.offsetHeight) {
        if(!SIFR.replaceNonDisplayed) continue;

        node.style.display = 'block';
        if(!node.offsetHeight) { // If they are still without height, don't replace them.
          node.style.display = '';
          continue;
        }
        resetDisplay = true;
      }

      if(forceClear && ua.gecko) node.style.clear = 'both';

      // Determine lineHeight (the font-size used in the Flash) and the number 
      // of lines. We also need the dimensions to approximate the final size.
      // The height is directly approximated for IE, we only need it for non-IE
      // right now.
      var height = ua.ie ? 0 : dom.getStyleAsInt(node, 'height');

      // If the text doesn't wrap nicely, the width becomes too large and Flash
      // can't adjust for it. By setting the text to just "X" we can be sure
      // we get the correct width.
      var html = null;
      if(SIFR.fixWrap && ua.ie && dom.getComputedStyle(node, 'display') == 'block') {
        html = node.innerHTML;
        dom.setInnerHtml(node, 'X');
      }

      // Get the width (again to approximate the final size). The computed width
      // may not be a pixel unit in IE, in which case we try to calculate using
      // padding and borders and the offsetWidth.
      var width = dom.getStyleAsInt(node, 'width', ua.ie);
      if(ua.ie && width == 0) {
        var paddingRight  = dom.getStyleAsInt(node, 'paddingRight', true);
        var paddingLeft   = dom.getStyleAsInt(node, 'paddingLeft', true);
        var borderRight   = dom.getStyleAsInt(node, 'borderRightWidth', true);
        var borderLeft    = dom.getStyleAsInt(node, 'borderLeftWidth', true);
        width = node.offsetWidth - paddingLeft - paddingRight - borderLeft - borderRight;
      }
      
      if(html && SIFR.fixWrap && ua.ie) dom.setInnerHtml(node, html);
      
      var lineHeight, lines;
      if(!ua.ie) { //:=todo Only do once for each selector?
        lineHeight = dom.getStyleAsInt(node, 'lineHeight');
        lines = Math.floor(height / lineHeight);
      } else if(ua.ie) { // IE returs computed style in the original units, which is quite useless.
        var html = node.innerHTML;
        dom.setInnerHtml(node, 'X<br />X<br />X');

        // Without these settings, we won't be able to get the rects properly.
        node.style.visibility = 'visible';
        node.style.width      = 'auto';
        node.style.height     = 'auto';
        node.style.overflow   = 'visible';
        node.style.styleFloat = 'none';
        node.style.position   = 'static';

        var rects = node.getClientRects();

        lineHeight = rects[1].bottom - rects[1].top;

        // In IE, the lineHeight is about 1.25 times the height in other browsers.
        lineHeight = Math.ceil(lineHeight * 0.8);

        dom.setInnerHtml(node, html);
        rects = node.getClientRects();
        lines = rects.length;

        // By setting an empty string, the values will fall back to those in the (non-inline) CSS.
        // When that CSS changes, the changes are reflected here. Setting explicit values would break
        // that behaviour.
        node.style.visibility = '';
        node.style.width      = '';
        node.style.height     = '';
        node.style.overflow   = '';
        node.style.styleFloat = '';
        node.style.position   = '';
      }

      // We have all the info we need, reset the display setting now.
      if(resetDisplay) node.style.display = '';
      if(forceClear && ua.gecko) node.style.clear = '';

      lineHeight = Math.max(MIN_FONT_SIZE, lineHeight);
      lineHeight = Math.min(MAX_FONT_SIZE, lineHeight);

      if(isNaN(lines) || !isFinite(lines)) lines = 1;
      height = Math.round(lines * lineHeight);

      if(lines > 1 && leading) height += Math.round((lines - 1) * leading);

      // I wanted to use `noembed` here, but unfortunately FlashBlock only works with `span.sIFR-alternate`
      var alternate = dom.create('span');
      alternate.className = CSS_ALTERNATE;

      // Clone the original content to the alternate element.
      var contentNode = node.cloneNode(true);
      for(var j = 0, l = contentNode.childNodes.length; j < l; j++) {
        alternate.appendChild(contentNode.childNodes[j].cloneNode(true));
      }

      // Allow the sIFR content to be modified
      if(kwargs.modifyContent) kwargs.modifyContent(contentNode, kwargs.selector);
      if(kwargs.modifyCss) cssText = kwargs.modifyCss(css, contentNode, kwargs.selector);

      var content = handleContent(contentNode, textTransform);
      if(kwargs.modifyContentString) kwargs.modifyContentString(content, kwargs.selector);
      if(content == '') continue;
      var vars = ['content=' + content.replace(/\</g, '&lt;').replace(/>/g, '&gt;'),
                  'width=' + width, 'height=' + height, 'fitexactly=' + (fitExactly ? 'true' : ''),
                  'tunewidth=' + (kwargs.tuneWidth || ''), 'tuneheight=' + (kwargs.tuneHeight || ''),
                  'offsetleft=' + (kwargs.offsetLeft || ''), 'offsettop=' + (kwargs.offsetTop || ''),
                  'thickness=' + (kwargs.thickness || ''), 'sharpness=' + (kwargs.sharpness || ''), 
                  'kerning=' + (kwargs.kerning || ''), 'gridfittype=' + gridFitType, 
                  'zoomsupport=' + ua.zoomSupport, 'filters=' + filters, 'opacity=' + opacity,
                  'blendmode=' + blendMode, 'size=' + lineHeight, 'zoom=' + dom.getZoom(), 'css=' + cssText];
      vars = encodeURI(vars.join('&amp;'));

      var callbackName = 'sIFR_callback_' + elementCount++;
      var callbackInfo = {flashNode: null};
      window[callbackName + '_DoFSCommand'] = (function(callbackInfo) {
        return function(info, arg) {
/*if(info == 'log') console.log(arg);*/
          if(/(FSCommand\:)?resize/.test(info)) {
            var $ = arg.split(':');
            callbackInfo.flashNode.setAttribute($[0], $[1]);
            // Here comes another story!
            //
            // Good old Safari (saw this in 2.0.3) will *not* repaint the 
            // Flash movie with the new dimensions *until* the document
            // receives a UIEvent. I haven't tested this throroughly, so it
            // might respond to other events as well.
            //
            // The solution is to trick Safari into thinking that the `embed`
            // element has changed, this is done by adding an empty string
            // to it's `innerHTML`. Be aware though that adding this string
            // to `node` (the parent of the `embed` element) will immediately
            // crash Safari.
            //
            // Just to be sure this hack is applied to all browsers which
            // implement the KHTML engine.
            //
            /*:=todo Test this bug in older browsers to see if it occurs there
                      as well.
            */
            if(ua.khtml) callbackInfo.flashNode.innerHTML += '';
          }
        }
      })(callbackInfo);

      // Approach the final height to avoid annoying movements of the page
      height = Math.round(lines * getRatio(lineHeight) * lineHeight);

      var forcedWidth = forceWidth ? width : '100%';

      var flash;
      if(ua.ie) {
        flash = [
          '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" id="', callbackName,
           '" sifr="true" width="', forcedWidth, '" height="', height, '" class="', CSS_FLASH, '">',
            '<param name="movie" value="', src, '"></param>',
            '<param name="flashvars" value="', vars, '"></param>',
            '<param name="allowScriptAccess" value="always"></param>',
            '<param name="quality" value="best"></param>',
            '<param name="wmode" value="', wmode, '"></param>',
            '<param name="bgcolor" value="', backgroundColor, '"></param>',
            '<param name="name" value="', callbackName, '"></param>',
          '</object>',
          // Load in the callback code. Keep the <script> line exactly the same!!! (Yes, IE is that crappy)
          // Thanks to Tom Lee for the tip: <http://tom-lee.blogspot.com/2006/04/dynamically-inserting-fscommand.html>
          '<script event=FSCommand(info,args) for=', callbackName, '>', 
            callbackName, '_DoFSCommand(info, args);',
          '</', 'script>' // End like this to prevent syntax error in IE/Mac.
        ].join('');
      } else {
        flash = [
          '<embed class="', CSS_FLASH, '" type="application/x-shockwave-flash" src="', 
          src,'" quality="best" flashvars="', vars, '" width="', forcedWidth, '" height="', height,
          '" wmode="', wmode, '" bgcolor="', backgroundColor, '" name="', callbackName,
          '" allowScriptAccess="always" sifr="true"></embed>'
        ].join('');
      }

      dom.setInnerHtml(node, flash);
      callbackInfo.flashNode = node.firstChild;
      dom.appendNode(node, alternate);
      dom.addClass(CSS_REPLACED, node);
      
      if(kwargs.onReplacement) kwargs.onReplacement(callbackInfo.flashNode);
    }

    hacks.fragmentIdentifier.restore();
  };

  /*=:private
    Walks through the childNodes of `source`. Generates a text representation of these childNodes.

    Returns:
    * string: the text representation.

    Notes:
    * A number of items are still to do. See the individual comments for that.
    * This method does not recursion because it'll be necessary to keep a 
      count of all links and their URIs. This is easier without recursion.
  */
  function handleContent(source, textTransform) {
    //:=todo add filters
    var stack = [];
    var nodes = source.childNodes;
    //:=todo dojo string builder for speed?
    var content = [];

    var i = 0;
    while(i < nodes.length) {
      var node = nodes[i];

      if(node.nodeType == 3) {
        var text = util.normalize(node.nodeValue);
        text = util.textTransform(textTransform, text);
        // Escape reserved characters
        content.push(text.replace(/\%/g, '%25').replace(/\&/g, '%26').replace(/\,/g, '%2C').replace(/\+/g, '%2B'));
      }

      if(node.nodeType == 1) {
        var attributes = [];
        var nodeName = node.nodeName.toLowerCase();

        var className = node.className || '';
        // If there are multiple classes, look for the specified sIFR class
        if(/\s+/.test(className)) {
          if(className.indexOf(CSS_CLASS)) className = className.match('(\\s|^)' + CSS_CLASS + '-([^\\s$]*)(\\s|$)')[2];
          // or use the first class
          else className = className.match(/^([^\s]+)/)[1];
        }
        if(className != '') attributes.push('class="' + className + '"');

        if(nodeName == 'a') {
          var href = node.getAttribute('href') || '';
          var target = node.getAttribute('target') || '';
          attributes.push('href="' + href + '"', 'target="' + target + '"');
        }

        content.push(  
          '<' + nodeName 
          + (attributes.length > 0 ? ' ' : '') 
          + escape(attributes.join(' ')) + '>'
        );

        if(node.hasChildNodes()) {
          // Push the current index to the stack and prepare to iterate
          // over the childNodes.
          stack.push(i);
          i = 0;
          nodes = node.childNodes;
          continue;
        } else if(!/^(br|img)$/i.test(node.nodeName)) {
          content.push('</', node.nodeName.toLowerCase(), '>');
        }
      }

      if(stack.length > 0 && !node.nextSibling) {
        // Iterating the childNodes has been completed. Go back to the position
        // before we started the iteration. If that position was the last child,
        // go back even further.
        do {
          i = stack.pop();
          nodes = node.parentNode.parentNode.childNodes;
          node = nodes[i];
          if(node) content.push('</', node.nodeName.toLowerCase(), '>');
        } while(i < nodes.length && stack.length > 0);
      }

      i++;
    }
  
    return content.join('');
  }
};
