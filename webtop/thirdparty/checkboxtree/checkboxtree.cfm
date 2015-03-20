<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>Checkbox Tree</title>
<link rel="stylesheet" type="text/css" href="css/checkboxtree.css" charset="utf-8">

<script src="js/jquery-latest.js" type="text/javascript"></script>
<script src="js/jquery.checkboxtree.js" type="text/javascript"></script>
<script>
jQuery(document).ready(function(){
	jQuery("#checkchildren").checkboxTree({
			collapsedarrow: "images/checkboxtree/img-arrow-collapsed.gif",
			expandedarrow: "images/checkboxtree/img-arrow-expanded.gif",
			blankarrow: "images/checkboxtree/img-arrow-blank.gif",
			checkchildren: true
	});
	jQuery("#dontcheckchildren").checkboxTree({
			collapsedarrow: "images/checkboxtree/img-arrow-collapsed.gif",
			expandedarrow: "images/checkboxtree/img-arrow-expanded.gif",
			blankarrow: "images/checkboxtree/img-arrow-blank.gif",
			checkchildren: false
	});
	jQuery("#docheckchildren").checkboxTree({
			collapsedarrow: "images/checkboxtree/img-arrow-collapsed.gif",
			expandedarrow: "images/checkboxtree/img-arrow-expanded.gif",
			blankarrow: "images/checkboxtree/img-arrow-blank.gif",
			checkchildren: true,
			checkparents: false
	});
	jQuery("#dontcheckchildrenparents").checkboxTree({
			collapsedarrow: "images/checkboxtree/img-arrow-collapsed.gif",
			expandedarrow: "images/checkboxtree/img-arrow-expanded.gif",
			blankarrow: "images/checkboxtree/img-arrow-blank.gif",
			checkchildren: false,
			checkparents: false
	});
});
</script>
</head>
<body>
<!-- <h2>All parents of a child checkbox are selected (tristate: false, is the default)</h2> -->
<h2>Check Children and Parents</h2>

<ul class="unorderedlisttree" id="checkchildren">
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="6a7dc081-1b68-d347-3965-4a26ebdb707f">
    <label>Cars</label>
    <ul>
      <li>
        <input type="checkbox" name="checkboxtree_demo" value="cc77bc95-6702-e7fe-7429-6e9643c73cc6">
        <label>Ford</label>
      </li>
    </ul>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="b569502f-473b-890f-9fcf-c45b8a227baa">
    <label>Trucks</label>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="2e54dafc-ddf5-40fc-5a7b-36e486e01dc0">
    <label>Airplanes</label>
  </li>
  <li>
  <input type="checkbox" name="checkboxtree_demo" value="69516965-caa2-e105-770f-453ad70d0254">
  <label>Animals</label>
  <ul>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="ef16eb9a-d947-6987-857b-b5e38d3930a3">
      <label>Horses</label>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="f46655c3-06b2-bf5a-3879-d2136512e792">
      <label>Dogs</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="afa5bef8-7cbf-a32e-9c3a-53e56e79ecb0">
          <label>Daschund</label>
        </li>
      </ul>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="14ecb3e6-47f0-3472-4f0e-2d004c51d6f0">
      <label>Cats</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="d18f729e-aef2-d46a-f695-153e86ec8793">
          <label>Domestic Longhair</label>
        </li>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="f86292fa-9618-68f6-7ebe-9a3dbc218970">
          <label>Norwegian Forest Car</label>
		      <ul>
		        <li>
		          <input type="checkbox" name="checkboxtree_demo" value="d18f729e-aef2-d46a-f695-153e86ec8793">
		          <label>White</label>
		        </li>
		        <li>
		          <input type="checkbox" name="checkboxtree_demo" value="f86292fa-9618-68f6-7ebe-9a3dbc218970">
		          <label>Brown</label>
		        </li>
		        <li>
		          <input type="checkbox" name="checkboxtree_demo" value="d18f729e-aef2-d46a-f695-153e86ec8793">
		          <label>Ginger</label>
		        </li>
		        <li>
		          <input type="checkbox" name="checkboxtree_demo" value="f86292fa-9618-68f6-7ebe-9a3dbc218970">
		          <label>Black</label>
		        </li>
		      </ul>
        </li>
      </ul>
    </li>
  </ul>
  </li>
</ul>  

<h2>Dont Check Children Do Check Parents</h2>
<ul class="unorderedlisttree" id="dontcheckchildren">
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="6a7dc081-1b68-d347-3965-4a26ebdb707f">
    <label>Cars</label>
    <ul>
      <li>
        <input type="checkbox" name="checkboxtree_demo" value="cc77bc95-6702-e7fe-7429-6e9643c73cc6">
        <label>Ford</label>
      </li>
    </ul>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="b569502f-473b-890f-9fcf-c45b8a227baa">
    <label>Trucks</label>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="2e54dafc-ddf5-40fc-5a7b-36e486e01dc0">
    <label>Airplanes</label>
  </li>
  <li>
  <input type="checkbox" name="checkboxtree_demo" value="69516965-caa2-e105-770f-453ad70d0254">
  <label>Animals</label>
  <ul>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="ef16eb9a-d947-6987-857b-b5e38d3930a3">
      <label>Horses</label>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="f46655c3-06b2-bf5a-3879-d2136512e792">
      <label>Dogs</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="afa5bef8-7cbf-a32e-9c3a-53e56e79ecb0">
          <label>Daschund</label>
        </li>
      </ul>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="14ecb3e6-47f0-3472-4f0e-2d004c51d6f0">
      <label>Cats</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="d18f729e-aef2-d46a-f695-153e86ec8793">
          <label>Domestic Longhair</label>
        </li>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="f86292fa-9618-68f6-7ebe-9a3dbc218970">
          <label>Norwegian Forest Car</label>
        </li>
      </ul>
    </li>
  </ul>
  </li>
</ul>  
<h2>Do Check Children Dont Check Parents</h2>
<ul class="unorderedlisttree" id="docheckchildren">
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="6a7dc081-1b68-d347-3965-4a26ebdb707f">
    <label>Cars</label>
    <ul>
      <li>
        <input type="checkbox" name="checkboxtree_demo" value="cc77bc95-6702-e7fe-7429-6e9643c73cc6">
        <label>Ford</label>
      </li>
    </ul>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="b569502f-473b-890f-9fcf-c45b8a227baa">
    <label>Trucks</label>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="2e54dafc-ddf5-40fc-5a7b-36e486e01dc0">
    <label>Airplanes</label>
  </li>
  <li>
  <input type="checkbox" name="checkboxtree_demo" value="69516965-caa2-e105-770f-453ad70d0254">
  <label>Animals</label>
  <ul>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="ef16eb9a-d947-6987-857b-b5e38d3930a3">
      <label>Horses</label>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="f46655c3-06b2-bf5a-3879-d2136512e792">
      <label>Dogs</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="afa5bef8-7cbf-a32e-9c3a-53e56e79ecb0">
          <label>Daschund</label>
        </li>
      </ul>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="14ecb3e6-47f0-3472-4f0e-2d004c51d6f0">
      <label>Cats</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="d18f729e-aef2-d46a-f695-153e86ec8793">
          <label>Domestic Longhair</label>
        </li>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="f86292fa-9618-68f6-7ebe-9a3dbc218970">
          <label>Norwegian Forest Car</label>
        </li>
      </ul>
    </li>
  </ul>
  </li>
</ul>  
<h2>Dont Check Parents or Children</h2>
<ul class="unorderedlisttree" id="dontcheckchildrenparents">
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="6a7dc081-1b68-d347-3965-4a26ebdb707f">
    <label>Cars</label>
    <ul>
      <li>
        <input type="checkbox" name="checkboxtree_demo" value="cc77bc95-6702-e7fe-7429-6e9643c73cc6">
        <label>Ford</label>
      </li>
    </ul>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="b569502f-473b-890f-9fcf-c45b8a227baa">
    <label>Trucks</label>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="2e54dafc-ddf5-40fc-5a7b-36e486e01dc0">
    <label>Airplanes</label>
  </li>
  <li>
  <input type="checkbox" name="checkboxtree_demo" value="69516965-caa2-e105-770f-453ad70d0254">
  <label>Animals</label>
  <ul>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="ef16eb9a-d947-6987-857b-b5e38d3930a3">
      <label>Horses</label>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="f46655c3-06b2-bf5a-3879-d2136512e792">
      <label>Dogs</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="afa5bef8-7cbf-a32e-9c3a-53e56e79ecb0">
          <label>Daschund</label>
        </li>
      </ul>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="14ecb3e6-47f0-3472-4f0e-2d004c51d6f0">
      <label>Cats</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="d18f729e-aef2-d46a-f695-153e86ec8793">
          <label>Domestic Longhair</label>
        </li>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="f86292fa-9618-68f6-7ebe-9a3dbc218970">
          <label>Norwegian Forest Car</label>
        </li>
      </ul>
    </li>
  </ul>
  </li>
</ul>  

<!-- <h2>Parents with selected children are show grey, means parent is not selected, selecting a parent selects all children (tristate: true)</h2>
<ul class="unorderedlisttree2">
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="6a7dc081-1b68-d347-3965-4a26ebdb707f">
    <label>Cars</label>
    <ul>
      <li>
        <input type="checkbox" name="checkboxtree_demo" value="cc77bc95-6702-e7fe-7429-6e9643c73cc6">
        <label>Ford</label>
      </li>
    </ul>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="b569502f-473b-890f-9fcf-c45b8a227baa">
    <label>Trucks</label>
  </li>
  <li>
    <input type="checkbox" name="checkboxtree_demo" value="2e54dafc-ddf5-40fc-5a7b-36e486e01dc0">
    <label>Airplanes</label>
  </li>
  <li>
  <input type="checkbox" name="checkboxtree_demo" value="69516965-caa2-e105-770f-453ad70d0254">
  <label>Animals</label>
  <ul>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="ef16eb9a-d947-6987-857b-b5e38d3930a3">
      <label>Horses</label>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="f46655c3-06b2-bf5a-3879-d2136512e792">
      <label>Dogs</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="afa5bef8-7cbf-a32e-9c3a-53e56e79ecb0">
          <label>Daschund</label>
        </li>
      </ul>
    </li>
    <li>
      <input type="checkbox" name="checkboxtree_demo" value="14ecb3e6-47f0-3472-4f0e-2d004c51d6f0">
      <label>Cats</label>
      <ul>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="d18f729e-aef2-d46a-f695-153e86ec8793">
          <label>Domestic Longhair</label>
        </li>
        <li>
          <input type="checkbox" name="checkboxtree_demo" value="f86292fa-9618-68f6-7ebe-9a3dbc218970">
          <label>Norwegian Forest Car</label>
        </li>
      </ul>
    </li>
  </ul>
  </li>
</ul>  -->
</body>
</html>
