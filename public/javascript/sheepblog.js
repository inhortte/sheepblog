function li_to_block(li) {
    $(li).removeClass('none');
    $(li).addClass('block');
}

function ajax_hovno() {
    $('a[id^="day"]').click(function() {
	var path = "/ajax/" + this.id.substr(3,4) + "/" + this.id.substr(7,2) + "/" + this.id.substr(9,2);
	//	$("#content").load(path);
	$.ajax({
	    url: path,
	    cache: false,
	    success: function(html) {
		$("#content").html(html);
	    }
	});
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
