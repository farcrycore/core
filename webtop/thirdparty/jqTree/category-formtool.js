jQuery.fn.block = function(){
	var thispos = this.offset(), blocker = "";
	
	if (this.data("blocker"))
		blocker = this.data("blocker");
	else
		blocker = jQuery("<div style='position:absolute;background-color:#333333;padding:10px 20px;border:1px solid #000000;'><img src='/webtop/images/loading-dark.gif' alt='Loading...' width='54' height='55'></div>");
	
	blocker.css({
		top : thispos.top,
		left : thispos.left,
		width : this.width(),
		height : this.height(),
		opacity : 0.5
	})
		.find("img").css({
			position : "absolute",
			top : 150,
			left : thispos.left + (this.width()-54) / 2
		}).end()
		.appendTo(jQuery("body"));
	
	this.data("blocker",blocker);
	
	return blocker;
};
jQuery.fn.unblock = function(){
	if (this.data("blocker")){
		this.data("blocker").remove();
		this.data("blocker",null);
	}
	
	return this;
};

(function($){
	function CustomError(message,code) {
		this.message = message;
		this.code = code;
	}
	CustomError.prototype = new Error();
	CustomError.prototype.constructor = CustomError;
	
	$fc = window.$fc || {};
	$fc.tree = {
		newid : "",
		entered : false,
		
		CustomError : CustomError,
		
		reloadBranch : function reloadBranch($tree,objectid,includechildren){
			var entered = !$fc.tree.entered, promise = "";
			
			if (entered)
				$fc.tree.entered = true;
			
			$tree.trigger("treeupdate-start");
			
			promise = $.getJSON($tree.data("url")+'&node='+objectid).pipe(function(data){
				if (data.error){
					var deferred = $.Deferred();
					deferred.reject(new $fc.tree.CustomError(data.error,data.code));
					return deferred.promise();
				}
				
				var node = $tree.tree("getNodeById",objectid), children = data.children;
				
				if (data.roothash)
					$tree.data("roothash",data.roothash);
					
				if (data.newid)
					$fc.tree.newid = data.newid;
				
				delete data.children;
				
				$tree.tree('updateNode', node, data)
				
				if (includechildren);
					$tree.tree('loadData', children, node);
				
				return data;
			});
			
			if (entered) {
				$fc.tree.closePromise($tree, promise);
				$fc.tree.entered = false;
			}
			
			return promise;
		},
		
		moveBranch : function moveBranch($tree,objectid,to,position){
			var entered = !$fc.tree.entered, promise = "";
			
			if (entered)
				$fc.tree.entered = true;
				
			$tree.trigger("treeupdate-start");
			
			promise = $.getJSON($tree.data("url")+'&move='+objectid+'&to='+to+'&position='+(position+1)+'&hash='+$tree.data("roothash")).pipe(function(data){
				if (data.error){
					var deferred = $.Deferred();
					deferred.reject(new $fc.tree.CustomError(data.error,data.code));
					return deferred.promise();
				}
				
				$tree.data("roothash",data.roothash);
				return data;
			});
			
			if (entered) {
				$fc.tree.closePromise($tree, promise);
				$fc.tree.entered = false;
			}
			
			return promise;
		},
		
		removeBranch : function removeBranch($tree,objectid){
			var entered = !$fc.tree.entered, promise = "";
			
			if (entered)
				$fc.tree.entered = true;
				
			$tree.trigger("treeupdate-start");
			
			promise = $.getJSON($tree.data("url")+'&remove='+objectid+'&hash='+$tree.data("roothash")).pipe(function(data){
				if (data.error){
					var deferred = $.Deferred();
					deferred.reject(new $fc.tree.CustomError(data.error,data.code));
					return deferred.promise();
				}
				
				$tree.data("roothash",data.roothash);
				$tree.tree("removeNode",$tree.tree('getNodeById',objectid));
				
				return data;
			});
			
			if (entered) {
				$fc.tree.closePromise($tree, promise);
				$fc.tree.entered = false;
			}
			
			return promise;
		},
		
		addChild : function addChild($tree,objectid,parentid){
			var entered = !$fc.tree.entered, promise = "";
			
			if (entered)
				$fc.tree.entered = true;
				
			$tree.trigger("treeupdate-start");
			$fc.tree.newid = "";
			
			promise = $.getJSON($tree.data("url")+'&add='+objectid+'&to='+parentid).pipe(function(data){
				if (data.error){
					var deferred = $.Deferred();
					deferred.reject(new $fc.tree.CustomError(data.error,data.code));
					return deferred.promise();
				}
				
				$tree.data("roothash",data.roothash);
				return $fc.tree.reloadBranch($tree,parentid,true);
			});
			
			if (entered) {
				$fc.tree.closePromise($tree, promise);
				$fc.tree.entered = false;
			}
			
			return promise;
		},
		
		updateObject : function updateObject($tree,objectid,includechildren){
			var entered = !$fc.tree.entered, promise = "";
			
			if (entered)
				$fc.tree.entered = true;
				
			$tree.trigger("treeupdate-start");
			
			if (objectid === $fc.tree.newid)
				promise = $fc.tree.addChild($tree,objectid,$tree.tree("getSelectedNode").id);
			else
				promise = $fc.tree.reloadBranch($tree,objectid,includechildren);
			
			if (entered) {
				$fc.tree.closePromise($tree, promise);
				$fc.tree.entered = false;
			}
			
			return promise;
		},
		
		editObject : function editObject($tree,objectid){
			var entered = !$fc.tree.entered, promise = "";
			
			if (entered)
				$fc.tree.entered = true;
				
			$tree.trigger("treeupdate-start");
			
			promise = $.getJSON($tree.data("url")+"&edit="+objectid).pipe(function(data){
				if (data.error){
					var deferred = $.Deferred();
					deferred.reject(new $fc.tree.CustomError(data.error,data.code));
					return deferred.promise();
				}
				
				$fc.tree.currenttree = $tree;
				$fc.openModal(data.html,"auto","auto",true);
			});
			
			if (entered) {
				$fc.tree.closePromise($tree, promise);
				$fc.tree.entered = false;
			}
			
			return promise;
		},
		
		saveObject : function saveObject($tree,objectid,data){
			var entered = !$fc.tree.entered, promise = "";
			
			if (entered)
				$fc.tree.entered = true;
				
			var selfClose = false, result = "", newdata = {};
			
			if (data===undefined){
				data = objectid;
				objectid = $tree;
				$tree = $fc.tree.currenttree;
				delete $fc.tree.currenttree;
				selfClose = true;
			}
			
			$tree.trigger("treeupdate-start");
			
			for (var k in data)
				newdata["_"+k] = data[k];
			
			promise = $.ajax({
				dataType: "json",
				url: $tree.data("url")+'&update='+objectid,
				type: "POST",
				data: newdata
			}).pipe(function(data){
				if (data.error){
					var deferred = $.Deferred();
					deferred.reject(new $fc.tree.CustomError(data.error,data.code));
					return deferred.promise();
				}
				
				return $fc.tree.updateObject($tree,objectid);
			});
			
			if (entered) {
				$fc.tree.closePromise($tree, promise);
				$fc.tree.entered = false;
			}
			
			return promise;
		},
		
		closePromise : function closePromise($tree,promise){
			promise.pipe(null,function(error){
				$tree.trigger("treeupdate-error",[ error.message,error.code || "general" ]);
				
				return error;
			}).always(function(data){
				$tree.trigger("treeupdate-finish");
			});
		}
	};
})(jQuery);

(function($){
	var nodePressed = "";
	var pressTimer = 0;
	
	function getPosition(child,parent){
		parent = parent || child.parent;
		
		for (var i=0; i<parent.children.length; i++){
			if (parent.children[i].id === child.id)
				return i;
		}
		
		return -1;
	};
	
	jQuery.fn.farcryTree = function(options){
		var $this = $(this);
		
		// check the passed in options for the required settings
		if (!options.data)
			throw new Error("farcryTree requires 'data' to be included in the options");
		if (!options.rootid)
			throw new Error("farcryTree requires 'rootid' to be included in the options");
		if (!options.dataUrl)
			throw new Error("farcryTree requires 'dataUrl' to be included in the options");
		if (!options.fieldName)
			throw new Error("farcryTree requires 'fieldName' to be included in the options");
		
		// update the passed in options with the defaults
		options = $.extend({
			// farcry options
			allowEdit : false,
			allowRemove : false,
			allowAdd : false,
			allowMove : false,
			allowSelect : false,
			selectMultiple : false,
			visibleInputs : false,
			selected : [],
			openNodes : [],
			quickEdit : false,
			
			onEditNode : function onEditNode(node){
				$fc.tree.editObject($this,node.id);
			},
			onAddNode : function onAddNode(node,newid){
				$fc.tree.editObject($this,newid);
			},
			onRemoveNode : function onRemoveNode(node){
				if (window.confirm("Are you sure you want to delete the '"+node.name+"' category?"))
					$fc.tree.removeBranch($this,node.id);
			},
			onMoveNode : function onMoveNode(node,parent,position,finishMove){
				$fc.tree.moveBranch($this,node.id,parent.id,position).pipe(function(){
					finishMove();
				});
			},
			onSelectNode : function onSelectNode(node,selected){
				
			},
			onUpdateStart : function onTreeUpdateStart(){
				$this.block();
			},
			onUpdateFinish : function onTreeUpdateFinish(){
				$this.unblock();
			},
			onUpdateError : function onTreeUpdateError(event,message,code){
				if (code === "treechanged")
					$this.before("<div class='error'>"+message+" <a href='##' class='refresh-tree'>Refresh tree?</a></div>");
				else
					$this.before("<div class='error'>"+message+"</div>");
			},
			
			// jqTree options
			autoOpen : 0,
			dragAndDrop : true,
			onCanMove : function(node){
				return node.parent ? true : false;
			},
			onCanMoveTo: function(moved_node, target_node, position) {
				return target_node.id !== options.rootid || position == 'inside';
		    },
		    onCanSelectNode: function(node) {
				return node && (node.id === nodePressed || options.quickEdit);
			},
			onCreateLi: function(node, $li) {
				var html = ["<span class='node-options'>"];
				
				if (node.id !== options.rootid && options.allowEdit)
					html.push("<i class='fa fa-pencil'></i>");
				if (options.allowAdd)
					html.push("<i class='fa fa-plus'></i>");
				if (node.id !== options.rootid && options.allowRemove)
					html.push("<i class='fa fa-trash-o'></i>");
				
				html.push("</span>");
				
				$li.find('> .jqtree-element').append(html.join(""));
				
				if (options.allowSelect){
					html = [ "<input name='", options.fieldName, "' value='", node.id, "'" ];
					
					if (options.selectMultiple)
						html.push(" type='checkbox'");
					else
						html.push(" type='radio'");
					
					if (!options.visibleInputs)
						html.push(" style='display:none;'");
						
					if (options.selected.indexOf(node.id)>-1)
						html.push(" checked");
					
					html.push(">");
					
					$li.find('> .jqtree-element').prepend(html.join(""));
				}
			},
		   	delay:1500
		},options);
		
		$this.tree(options);
		$this.on("treeupdate-start",options.onUpdateStart);
		$this.on("treeupdate-finish",options.onUpdateFinish);
		$this.on("treeupdate-error",options.onUpdateError);
		
		for (var i=0; i<options.openNodes.length; i++)
			$this.tree("openNode",$this.tree("getNodeById",options.openNodes[i]));
		
		// data
		$this.data("url",options.dataUrl);
		$this.data("roothash",options.data[0].roothash);
		if (options.newid)
			$fc.tree.newid = options.newid;
		
		// events
		$this.parent().delegate("a.refresh-tree","click",function(){
			$fc.tree.reloadBranch($this,options.rootid,true);
			$(this).closest(".error").remove();
			
			return false;
		});
		if (options.allowMove){
			$this.on("tree.move",function(event) {
				var targetpos = getPosition(event.move_info.target_node), movedpos = getPosition(event.move_info.moved_node,event.move_info.previous_parent), parent="", newpos = -1;
				
				switch(event.move_info.position){
					case "before":
						parent = event.move_info.target_node.parent;
						newpos = targetpos;
						
						break;
					case "after":
						newpos = targetpos + 1;
						parent = event.move_info.target_node.parent;
						if (event.move_info.target_node.parent === event.move_info.previous_parent && movedpos < targetpos)
							newpos--;
						
						break;
					case "inside":
						newpos = 0;
						parent = event.move_info.target_node;
						
						break;
				};
				
				event.preventDefault();
				
				options.onMoveNode.call($this.get(0),event.move_info.moved_node,parent,newpos,event.move_info.do_move);
			});
		}
		if (!options.quickEdit && (options.allowEdit || options.allowAdd || options.allowRemove)) {
			$this.on("tree.select", function(event){
				nodePressed = "";
			});
			$this.delegate(".jqtree-element", "mousedown", function(){
				var node = $(this).parents("li").first().data("node");
				
				nodePressed = "";
				if (pressTimer) 
					clearTimeout(pressTimer);
				
				pressTimer = setTimeout(function(){
					nodePressed = node.id;
				}, 1000);
			});
			$this.delegate(".jqtree-element", "mouseup", function(){
				clearTimeout(pressTimer);
			});
			$this.delegate(".jqtree-element", "mouseout", function(){
				clearTimeout(pressTimer);
			});
		}
		if (options.allowEdit) {
			$this.on("click", ".fa-pencil",  function(event){
				options.onEditNode.call($this.get(0),$(this).parents("li").first().data("node"));
			});
		}
		if (options.allowAdd) {
			$this.delegate(".fa-plus", "click", function(event){
				if ($fc.tree.newid === "") 
					return;
				
				options.onAddNode.call($this.get(0), $(this).parents("li").first().data("node"), $fc.tree.newid);
			});
		}
		if (options.allowRemove) {
			$this.delegate(".fa-trash-o", "click", function(event){
				options.onRemoveNode.call($this.get(0), $(this).parents("li").first().data("node"));
			});
		}
		if (options.allowSelect || options.quickEdit) {
			$this.delegate("li > .jqtree-element", "click", function(event){
				var el = $(event.target).parent(), target = $(event.target);
				
				// skip clicks on the actual checkbox / radio elements, or the action icons
				if (target.is("input") || target.is("i") || target.is("a")) {
					if (target.is("input") || target.is("i"))
						event.stopPropagation();
					return;
				}
					
				// skip clicks, if the user is holding the mouse button down
				if (nodePressed.length)
					return;
				
				el = el.closest("li");
				
				var checkbox = el.find("> .jqtree-element input");
				
				if (checkbox.attr("checked")!=="checked") {
					checkbox.attr("checked","checked");
					el.addClass("selected");
					options.onSelectNode.call($this.get(0), $this.tree("getNodeById", checkbox.val()), true);
					
					$this.find("li.selected > .jqtree-element input[type=radio]:not([value=" + checkbox.val() + "])").each(function(){
						var self = $(this).closest("li");
						
						self.removeClass("selected");
						options.onSelectNode.call($this.get(0), self.data("node"), false);
					});
				}
				else {
					checkbox.removeAttr("checked");
					el.removeClass("selected");
					options.onSelectNode.call($this.get(0), $this.tree("getNodeById", checkbox.val()), false);
				}
			});
		}
		if (options.allowSelect){
			$this.delegate("input[type=checkbox],input[type=radio]","click",function(event){
				var el = $(event.currentTarget).closest("li");
				var checkbox = $(event.currentTarget);
				
				if (checkbox.attr("checked")==="checked") {
					el.addClass("selected");
					options.onSelectNode.call($this.get(0), $this.tree("getNodeById", this.value), true);
					
					$this.find("li.selected > .jqtree-element input[type=radio]:not([value=" + checkbox.val() + "])").each(function(){
						var self = $(this).closest("li");
						
						self.removeClass("selected");
						options.onSelectNode.call($this.get(0), self.data("node"), false);
					});
				}
				else{
					el.removeClass("selected");
					options.onSelectNode.call($this.get(0), $this.tree("getNodeById", this.value), false);
				}
			});
		}
	};
})(jQuery);