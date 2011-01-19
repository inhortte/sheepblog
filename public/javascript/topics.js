function notBlank(s) {
    return s.trim().length > 0;
}

function ajax_topics() {
    $("a[id^='topic']").click(function() {
	return modify_entry_topics($(this).html().toLowerCase(), false);
    });
    $("#add_new_topic").submit(function (e) {
	var topic = $(this).children("input").attr("value");
	$(this).children("input").attr("value","");
	return modify_entry_topics(topic, false);
    });
    $("a[id^='rmtopic']").click(function() {
	return modify_entry_topics(this.id.substr(7), true);
    });
}

function modify_entry_topics(topic, del) {
    var topics = $("#entry_topics").children("input").attr("value").split(",");
    topic = topic.toLowerCase().trim();
    if(topics.indexOf(topic) == -1) {
	topics.push(topic);
	topics.sort();
	topics = topics.filter(function(s) { return s.trim().length > 0; });
    }
    if(del) {
	topics = topics.filter(function(s) { return s != topic; });
    }
    html_topics = topics.map(function(s) {
	return "<a href=\"#\" id=\"rmtopic" + s + "\">" + s + "</a>";
    }).join(", ");
    $("#entry_topics").children("input").attr("value", topics.join(","));
    $("#entry_topics").children("span").html(html_topics);
    ajax_topics();
    return false;
}


$(document).ready(function() {
    ajax_topics();
});


