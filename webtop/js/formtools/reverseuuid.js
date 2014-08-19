$j(document).ready(function(){ 
	$j(document).on("click",".reverseuuid-add", function(e) {
		var $formtoolWrap = $j(this).parents('.reverseuuid-wrap');
		var $formtoolWrapTypename = $formtoolWrap.attr('formtoolWrapTypename');
		var $formtoolWrapObjectID = $formtoolWrap.attr('formtoolWrapObjectID');
		var $formtoolWrapProperty = $formtoolWrap.attr('formtoolWrapProperty');
		var $formtoolWrapJoinTypename = $formtoolWrap.attr('formtoolWrapJoinTypename');
		var $formtoolWrapJoinDisplayname = $formtoolWrap.attr('formtoolWrapJoinDisplayname');
		var $formtoolWrapEditView = $formtoolWrap.attr('formtoolWrapEditView');
		var $formtoolWrapEditBodyView = $formtoolWrap.attr('formtoolWrapEditBodyView');
		var $onHidden = function() {
			$fc.refreshProperty( $formtoolWrap.closest('span.propertyRefreshWrap') );
			return true;
		}

		$fc.openBootstrapModal({	title: 'Edit ' + $formtoolWrapJoinDisplayname, 
									onHidden:$onHidden, 
									url: '/index.cfm?type=' + $formtoolWrapTypename + '&objectid=' + $formtoolWrapObjectID + '&view=' + $formtoolWrapEditView + '&bodyView=editReverseUUIDObjectAdd&reverseUUIDProperty=' + $formtoolWrapProperty
		});

	});

	$j(document).on("click",".reverseuuid-edit", function(e) {
		var $objectid = $j(this).parents('[objectid]').attr('objectid');
		var $formtoolWrap = $j(this).parents('.reverseuuid-wrap');
		var $formtoolWrapTypename = $formtoolWrap.attr('formtoolWrapTypename');
		var $formtoolWrapObjectID = $formtoolWrap.attr('formtoolWrapObjectID');
		var $formtoolWrapProperty = $formtoolWrap.attr('formtoolWrapProperty');
		var $formtoolWrapJoinTypename = $formtoolWrap.attr('formtoolWrapJoinTypename');
		var $formtoolWrapJoinDisplayname = $formtoolWrap.attr('formtoolWrapJoinDisplayname');
		var $formtoolWrapEditView = $formtoolWrap.attr('formtoolWrapEditView');
		var $formtoolWrapEditBodyView = $formtoolWrap.attr('formtoolWrapEditBodyView');
		var $onHidden = function() {
			$fc.refreshProperty( $formtoolWrap.closest('span.propertyRefreshWrap') );
			return true;
		}

		$fc.openBootstrapModal({	title: 'Edit ' + $formtoolWrapJoinDisplayname, 
									onHidden:$onHidden, 
									url: '/index.cfm?type=' + $formtoolWrapJoinTypename + '&objectid=' + $objectid + '&view=' + $formtoolWrapEditView + '&bodyView=' + $formtoolWrapEditBodyView
		});

	});


	$j(document).on("click",".reverseuuid-delete", function(e) {
		var $row = $j(this).parents('[objectid]');
		var $objectid = $row.attr('objectid');
		var $formtoolWrap = $j(this).parents('.reverseuuid-wrap');
		var $formtoolWrapTypename = $formtoolWrap.attr('formtoolWrapTypename');
		var $formtoolWrapObjectID = $formtoolWrap.attr('formtoolWrapObjectID');
		var $formtoolWrapProperty = $formtoolWrap.attr('formtoolWrapProperty');
		var $formtoolWrapJoinTypename = $formtoolWrap.attr('formtoolWrapJoinTypename');
		var $formtoolWrapEditView = $formtoolWrap.attr('formtoolWrapEditView');
		var $formtoolWrapEditBodyView = $formtoolWrap.attr('formtoolWrapEditBodyView');
		var $formtoolWrapConfirmDeleteText = $formtoolWrap.attr('formtoolWrapConfirmDeleteText');

		if( !confirm( $formtoolWrapConfirmDeleteText ) ) {
			return false;
		}

	
		$j.ajax({
			cache: false,
			type: "POST",
 			url: '/index.cfm?ajaxmode=1&type=' + $formtoolWrapJoinTypename + '&objectid=' + $objectid + '&view=editReverseUUIDObjectDelete',
			data: {},
			dataType: "html",
			complete: function(data){
				$j($row).hide('fast');
			}
		});	
		
	});

	$j('.reverseuuid-sortable').sortable({
		items: 'tbody tr[objectid],li[objectid]',
		handle: '.reverseuuid-gripper',
		axis: 'y',
		stop: function(event,ui){
			var $formtoolWrap = $j(this).parents('.reverseuuid-wrap');
			var $formtoolWrapTypename = $formtoolWrap.attr('formtoolWrapTypename');
			var $formtoolWrapObjectID = $formtoolWrap.attr('formtoolWrapObjectID');
			var $formtoolWrapProperty = $formtoolWrap.attr('formtoolWrapProperty');

			var $lSortOrder = $j(this).sortable('toArray',{'attribute':'objectid'}).join(",") ;

			$j.ajax({
				cache: false,
				type: "POST",
	 			url: '/index.cfm?ajaxmode=1&type=' + $formtoolWrapTypename + '&objectid=' + $formtoolWrapObjectID + '&view=editReverseUUIDObjectSort&reverseUUIDProperty=' + $formtoolWrapProperty,
				data: {'lSortOrderIDs':$lSortOrder},
				dataType: "html",
				complete: function(data){
					
				}
			});
		},
		helper: function(e, tr) {
		    var $originals = tr.children();
		    var $helper = tr.clone();
		    $helper.children().each(function(index)
		    {
		      // Set helper cell sizes to match the original sizes
		      $j(this).width($originals.eq(index).width());
		    });
		    return $helper;
		}
	});
});