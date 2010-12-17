$(document).ready(function() {
    $("li[id^='ent'] > a").click(function() {
	var li_id = $(this).parent().attr("id").substr(3);

	$("#sidebar > ul > li > ul > li").each(function() {
	    $(this).removeClass('block');
	    $(this).addClass('none');
	    $(this).find("ul > li").each(function() {
		$(this).removeClass('block');
		$(this).addClass('none');
	    });
	});

	// A year has been clicked.
	if(li_id.length == 4) {
	    $(this).siblings("ul").children("li").each(function() {
		$(this).removeClass('none');
		$(this).addClass('block');
	    });
	} else {
	    // A month has been clicked.
	    $(this).parent().removeClass('none');
	    $(this).parent().addClass('block');
	    $(this).parent().siblings("li").each(function() {
		$(this).removeClass('none');
		$(this).addClass('block');
	    });
	    $(this).siblings("ul").children("li").each(function() {
		$(this).removeClass('none');
		$(this).addClass('block');
	    });
	}
    });
});
