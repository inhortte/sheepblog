function li_to_block(li) {
    $(li).removeClass('none');
    $(li).addClass('block');
}

// Here, just the date portion is passed, without the initial tag.
function ajax_date_path(d) {
    return("/ajax/" + d.substr(0,4) + "/" + d.substr(4,2) + "/" + d.substr(6,2));
}

function ajax_hovno() {
    $('a[id^="day"]').click(function() {
	var path = ajax_date_path(this.id.substr(3));
	//	$("#content").load(path);
	$.ajax({
	    url: path,
	    cache: false,
	    success: function(html) {
		$("#content").html(html);
	    }
	});
	return false;
    });
    $('a[id^="del"]').click(function() {
	if(confirm("Are you sure, vole?")) {
	    var delete_path = '/smazat/' + this.id.substr(3,this.id.indexOf(';') - 3);
	    var refresh_path = ajax_date_path(this.id.substr(this.id.indexOf(';') + 1));
	    $.ajax({
		url: delete_path,
		cache: false,
		async: false
	    });
	    $("#content").load(refresh_path);
	}
	return false;
    });
    $('a[id^="edit"]').click(function() {
	var id = this.id.substr(4);
	$.ajax({
	    url: "/upravit/" + id,
	    cache: false,
	    success: function(data) {
		$("#content").html(data);
	    }
	});
	return false;
    });
    $('a[id^="show"]').click(function() {
	var id = this.id.substr(4);
	$("#content").load("/zobrazit/" + id);
	return false;
    });
    $('a[id^="page"]').click(function() {
	var page = this.id.substr(4);
	$("#content").load("/ajax/" + page);
	return false;
    });
    $('a[id^="expand"]').click(function() {
	var id = this.id.substr(6);
	$("#entry" + id).load("/expand/" + id);
	return false;
    });
    $('a[id^="contract"]').click(function() {
	var id = this.id.substr(8);
	$("#entry" + id).load("/contract/" + id);
	return false;
    });
}

$(document).ready(function() {
    // Calendar display block/none.
    $("li[id^='ent'] > a").click(function() {
	var li_id = $(this).parent().attr("id").substr(3);

	$("#sidebar > ul > li > ul").find("li").each(function() {
	    $(this).removeClass('block');
	    $(this).addClass('none');
	});

	// A year has been clicked.
	if(li_id.length == 4) {
	    $(this).siblings("ul").children("li").each(function() {
		li_to_block(this);
	    });
	} else {
	    // A month has been clicked.
	    li_to_block($(this).parent().get(0));
	    $(this).parent().siblings("li").each(function() {
		li_to_block(this);
	    });
	    $(this).siblings("ul").children("li").each(function() {
		li_to_block(this);
	    });
	}
    });
    
    ajax_hovno();
});
