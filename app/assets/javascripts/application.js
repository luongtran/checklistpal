// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//

$(function () {
    $(".logo-editbt").on("click", function () {
        $(this).hide();
        var html_form = '<form action="#" class="edit_list_frm" remote="true">' +
            '<input type="text" class="input-small" name="list[name]" id="list_name" maxlength="30" placeholder="maximum 30 characters"/>' +
            '<input type="submit" value="Save" class="btn btn-small btn-success" />' +
            '<input type="button" value="Cancel" class="btn btn-small canceleditlistbt" /></form>';
        var obj = $(this).parent("#logo").children(".list-name");
        url = obj.data("url");
        var list_cur_name = obj.text();
        obj.html(html_form);
        obj.children().children("#list_name").val(list_cur_name);
        obj.children(".edit_list_frm").attr("action", url);
        $('.edit_list_frm').on("submit", function () {
            $(".logo-editbt").show();
            var form = this;
            $("#list_name").val($("#list_name").val().trim());
            if ($("#list_name").val() === "") {
                $(".editlb")._removeClass("hidden");
                $(".editlb").html("List name can't be blank !").fadeIn(300).delay(3000).fadeOut(300);
            }
            $.ajax({
                type: "post",
                url: $(this).attr("action"),
                data: $(this).serialize(),
                dataType: "json",
                success: function (data) {
                    var success = data.success;
                    var permission = data.permission;
                    var list = data.list;
                    if (permission === true) {
                        if (success === 1) {
                            $(form).parent(".list-name").html(list.name);
                        } else {
                            form.append("Can't be saved");
                        }
                    } else {
                        alert("You can't edit name of on invited list!");
                        $('.edit_list_frm').parent(".list-name").html(list_cur_name);
                    }
                }, error: function () {
                    alert("Error");
                }
            });
            return false;
        });
        $('.canceleditlistbt').on("click", function () {
            $('.edit_list_frm').parent(".list-name").html(list_cur_name);
            $(".logo-editbt").show();
        });

    });
    $("form#new_task").submit(function () {
        var task_description = $("form#new_task").find('input[type="text"]').val();
        if (task_description === null || task_description === "") {
            //alert('required');
            $('#error-message').text("Task Name is required").fadeIn(300).delay(1000).fadeOut(300);
            return false;
        }

        var url = $(this).attr("action");
        $.post(
            url,
            $(this).serialize(),
            function (response) {
                $("form#new_task").children().children('.searchboxtodolist').val('');
                $("#list-items").html(response);
                $(function () {
                    $('.mark_comp').bind('change', function () {
                        var list_id = $(this).attr('data_target');
                        url = null;
                        $.ajax({
                            url: list_id + '/tasks/' + this.value + '/complete',
                            type: 'POST',
                            data: {"completed": this.checked}
                        });

                        if ($(this).is(':checked')) {
                            $(this).parent().parent().parent('.checkbox').children().children('.item-title').addClass('item-completed');
                            $(this).parent().parent().parent('.checkbox').children().children().children('.task_name').addClass('item-completed');
                        }
                        else {
                            $(this).parent().parent().parent('.checkbox').children().children('.item-title').removeClass('item-completed');
                            $(this).parent().parent().parent('.checkbox').children().children().children('.task_name').removeClass('item-completed');
                        }

                    });

//                    $(".btn-delete").on("click",(function(){
//                    }));

                    var html_form_edit = '<form action="#" class="edit_task_frm" remote="true">' +
                        '<input type="text" class="input-small" name="task[description]" id="task_description" style="width:auto;"/>' +
                        '<input type="submit" value="Save" class="btn btn-small btn-success" />' +
                        '<input type="button" value="Cancel" class="btn btn-small canceledittaskbt" /></form>';
                    $('.btn-edit').on("click", function () {
                        var obj_task_des = $(this).parent().parent(".items").children().children().children(".item-title");
                        var url = obj_task_des.data("url");
                        var task_des = obj_task_des.text();
                        obj_task_des.html(html_form_edit);
                        obj_task_des.children().children('#task_description').val(task_des);
                        obj_task_des.children(".edit_task_frm").attr("action", url);
                        $('.edit_task_frm').on("submit", function () {
                            var form = this;
                            $.ajax({
                                type: "post",
                                url: $(this).attr("action"),
                                data: $(this).serialize(),
                                dataType: "json",
                                success: function (data) {
                                    var success = data.success;
                                    var task = data.task;
                                    if (success === 1) {
                                        $(function () {
                                            var urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
                                            $(form).parent(".item-title").html(task.description.replace(urlRegEx, "<a href='$1' target='_blank'>$1</a>"));
                                        });
//                       
                                    } else {
                                        form.append('<span class="error">Cannot be saved</span>');
                                    }
                                },
                                error: function () {
                                    alert("Error");
                                }
                            });
                            return false;
                        });
                        $('.canceledittaskbt').on("click", function () {
                            $('.edit_task_frm').parent(".item-title").html(task_des);
                        });
                    });

                    $('.show_comment_bt').on("click", function () {
                        $(this).parent().parent('.items').children(".comment-add").slideToggle("slow");
                    });
                    $('.number_comment').on("click", function () {
                        $(this).parent().parent('.items').children(".comment-add").slideToggle("slow");
                    });

                    $(".task-hasduedate").bind('change', function () {
                        var list_id = $(this).attr('data_target');
                        url = null;
                        $.ajax({
                            url: list_id + '/tasks/' + this.value + '/hasduedate',
                            type: 'POST',
                            data: {"hasduedate": this.checked}
                        });

                        if ($(this).is(':checked')) {
                            $(this).parent().parent().parent('.taskduedate').children('.sp-duedate').removeClass('hidden');
                        }
                        else {
                            $(this).parent().parent().parent('.taskduedate').children('.sp-duedate').addClass('hidden');
                        }

                    });
                    $('.datepicker').datepicker({
                        showOn: "button",
                        buttonImage: "/assets/calendar-small.png",
                        buttonImageOnly: true,
                        minDate: 0,
                        dateFormat: "mm-dd-yy",
                        onSelect: function (dateText) {
                            $(this).val(dateText);
                            $(this).change();
                            $(this).parent().trigger('submit.rails');
                            var form = '<span class="due_date_bt">Due ' + dateText + '</span>';
                            $(this).parent().parent().parent('.items').children().children('.due_date_show').html(form);
                            $(this).parent().parent().parent('.items').children().children('.due_date_show').removeClass('hidden');
                        }

                    });
                });
            }
        );
        return false;
    });
    $('.mark_comp').bind('change', function () {
        var list_id = $(this).attr('data_target');
        url = null;
        $.ajax({
            url: list_id + '/tasks/' + this.value + '/complete',
            type: 'POST',
            data: {"completed": this.checked}
        });

        if ($(this).is(':checked')) {
            $(this).parent().parent().parent('.checkbox').children().children('.item-title').addClass('item-completed');
            $(this).parent().parent().parent('.checkbox').children().children().children('.task_name').addClass('item-completed');
        }
        else {
            $(this).parent().parent().parent('.checkbox').children().children('.item-title').removeClass('item-completed');
            $(this).parent().parent().parent('.checkbox').children().children().children('.task_name').removeClass('item-completed');
        }

    });

    $(".btn-delete").on("click", (function () {
        $('#list-items li').eq('task_<%= @task.id %>').remove();
    }));

    var html_form_edit = '<form action="#" class="edit_task_frm" remote="true">' +
        '<input type="text" class="input-small" name="task[description]" id="task_description" style="width: auto;" maxlength="140" placeholder="maximum 140 characters"/>' +
        '<input type="submit" value="Save" class="btn btn-small btn-success" />' +
        '<input type="button" value="Cancel" class="btn btn-small canceledittaskbt" /></form>';
    $('.btn-edit').on("click", function () {
        var obj_task_des = $(this).parent().parent(".items").children().children().children(".item-title");
        var url = obj_task_des.data("url");
        var task_des = obj_task_des.text();
        obj_task_des.html(html_form_edit);
        obj_task_des.children().children('#task_description').val(task_des);
        obj_task_des.children(".edit_task_frm").attr("action", url);
        $('.edit_task_frm').on("submit", function () {
            var form = this;
            $.ajax({
                type: "post",
                url: $(this).attr("action"),
                data: $(this).serialize(),
                dataType: "json",
                success: function (data) {
                    var success = data.success;
                    var task = data.task;
                    if (success === 1) {
                        $(function () {
                            var urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
                            $(form).parent(".item-title").html(task.description.replace(urlRegEx, "<a href='$1' target='_blank'>$1</a>"));
                        });

//                        $(form).parent(".item-title").html(task.description);
                    } else {
                        form.append('<span class="error">Cannot be saved</span>');
                    }
                },
                error: function () {
                    alert("Error");
                }
            });
            return false;
        });
        $('.canceledittaskbt').on("click", function () {
            $('.edit_task_frm').parent(".item-title").html(task_des);
        });
    });

    $('.show_comment_bt').on("click", function () {
        $(this).parent().parent('.items').children(".comment-add").slideToggle("slow");
    });
    $('.number_comment').on("click", function () {
        $(this).parent().parent('.items').children(".comment-add").slideToggle("slow");
    });
    $(".task-hasduedate").bind('change', function () {
        var list_id = $(this).attr('data_target');
        url = null;
        $.ajax({
            url: list_id + '/tasks/' + this.value + '/hasduedate',
            type: 'POST',
            data: {"hasduedate": this.checked}
        });

        if ($(this).is(':checked')) {
            $(this).parent().parent().parent('.taskduedate').children('.sp-duedate').removeClass('hidden');
        }
        else {
            $(this).parent().parent().parent('.taskduedate').children('.sp-duedate').addClass('hidden');
        }

    });


    $('.datepicker').datepicker({
        showOn: "button",
        buttonImage: "/assets/calendar-small.png",
        buttonImageOnly: true,
        minDate: 0,
        dateFormat: "mm-dd-yy",
        onSelect: function (dateText) {
            $(this).val(dateText);
            $(this).change();
            $(this).parent().trigger('submit.rails');
            var form = '<span class="due_date_bt">Due ' + dateText + '</span>';
            $(this).parent().parent().parent('.items').children().children('.due_date_show').html(form);
            $(this).parent().parent().parent('.items').children().children('.due_date_show').removeClass('hidden');
        }
    });

    $("#mylist_search_field").bind("keyup", function (e) {
        if ($('#mylist_search_field').val().trim() !== "") {
            $("#search_loading").show();
            $('#my_lists_panel').hide();
            var url = "/mylists/search?keyword=" + $('#mylist_search_field').val();
            $.get(url, function () {
                $("#search_loading").hide();
                $('#my_list_seach_result').show();
            });
        }
        else {
            $('#mylist_search_field').val('');
            $('#my_lists_panel').show();
            $('#my_list_seach_result').hide();
        }
    });


});