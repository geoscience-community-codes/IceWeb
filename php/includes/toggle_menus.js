    //var visibleMenuID = '';
    function toggle_menus(id) {
       	//visibleMenuID = id;
       	var e = document.getElementById(id);
       	if(e.style.display == 'block'){
          	//e.style.display = 'none';
		document.getElementById('menu_hoursago').style.display = 'none';
		document.getElementById('menu_absolutetime').style.display = 'none';
       	}else{
		document.getElementById('menu_hoursago').style.display = 'none';
		document.getElementById('menu_absolutetime').style.display = 'none';
          	e.style.display = 'block';
      	}
    }

