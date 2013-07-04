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

$(function() {
   $(".logo-editbt").on("click", function(){
        var html_form = '<form action="#" class="edit_list_frm" remote="true"><input type="text" class="input-small" name="list[name]" id="list_name" />'+
                        '<input type="submit" value="Save" class="btn btn-small btn-success" />'+
                        '<input type="button" value="Cancel" class="btn btn-small canceleditlistbt" /></form>';
        var obj = $(this).parent("#logo").children(".list-name");
        url = obj.data("url");
        var list_cur_name = obj.text();
        obj.html(html_form);
        obj.children().children("#list_name").val(list_cur_name);
        obj.children(".edit_list_frm").attr("action", url);
        $('.edit_list_frm').on("submit", function(){
            var form = this;
            $.ajax({
                type: "post" , 
                url: $(this).attr("action"),
                data: $(this).serialize(),
                dataType: "json",
                success:function(data){
                    var success = data.success;
                    var list = data.list;
                    if(success === 1){
                        $(form).parent(".list-name").html(list.name);
                    }else
                    {
                        form.append("Can't be saved");
                    }
                }, error:function(){
                    alert("Error");
                }
            });
            return false;
        });
        $('.canceleditlistbt').on("click",function(){
                            $('.edit_list_frm').parent(".list-name").html(list_cur_name);
        });
        
    });
    $("form#new_task").submit(function() {
        var url = $(this).attr("action");
        $.post(
            url,
            $(this).serialize(),
            function(response) {
                $("form#new_task").children().children('.searchboxtodolist').val('');
                $("#list-items").html(response);
                $(function() {
                    $('.mark_comp').bind('change', function() {
                        var list_id = $(this).attr('data_target');
                        url = null;
                        $.ajax({
                            url: list_id+'/tasks/'+this.value+'/complete',
                            type: 'POST',
                            data: {"completed": this.checked}
                        });

                        if ($(this).is(':checked')) {
                            $(this).parent().parent().parent('.checkbox').children().children('.item-title').addClass('item-completed');
                        }
                        else{
                            $(this).parent().parent().parent('.checkbox').children().children('.item-title').removeClass('item-completed');
                        }

                    });

//                    $(".btn-delete").on("click",(function(){
//                    }));

                    var html_form_edit = '<form action="#" class="edit_task_frm" remote="true"><input type="text" class="input-small" name="task[description]" id="task_description" />'+
                        '<input type="submit" value="Update task name" class="btn btn-small" />'+
                        '<input type="button" value="Cancel" class="btn btn-small canceledittaskbt" /></form>';
                    $('.btn-edit').on("click", function() {
                        var obj_task_des = $(this).parent().parent(".items").children().children().children(".item-title");
                        var url = obj_task_des.data("url");
                        var task_des = obj_task_des.text();
                        obj_task_des.html(html_form_edit);
                        obj_task_des.children().children('#task_description').val(task_des);
                        obj_task_des.children(".edit_task_frm").attr("action", url);
                        $('.edit_task_frm').on("submit", function() {
                            var form = this;
                            $.ajax({
                                type: "post" ,
                                url: $(this).attr("action"),
                                data: $(this).serialize(),
                                dataType: "json",
                                success:function(data) {
                                    var success = data.success;
                                    var task = data.task;
                                    if(success === 1) {
                                        $(form).parent(".item-title").html(task.description);
                                    } else {
                                        form.append('<span class="error">Cannot be saved</span>');
                                    }
                                },
                                error:function() {
                                    alert("Error");
                                }
                            });
                            return false;
                        });
                        $('.canceledittaskbt').on("click",function(){
                            $('.edit_task_frm').parent(".item-title").html(task_des);
                        });
                    });


                    $('.items').on("mouseenter", function() {
                        $(this).children(".action").show();
                    }).on("mouseleave", function() {
                            $(this).children(".action").hide();
                        });

                    $('.logo-editbt').on("click" , function(){

                    });

                    $('#bt-invite-user').click(function() {
                        $('#frm_invite_user').show();
                        $(this).hide();
                    });

                    $('#bt-cancel-invite').click(function() {
                        $('#frm_invite_user').hide();
                        $('#bt-invite-user').show();
                    });
                    $(".task-hasduedate").bind('change', function(){
                        var list_id = $(this).attr('data_target');
                        url = null;
                        $.ajax({
                            url: list_id+'/tasks/'+this.value+'/hasduedate',
                            type: 'POST',
                            data: {"hasduedate": this.checked}
                        });

                        if ($(this).is(':checked')) {
                            $(this).parent().parent().parent('.taskduedate').children('.sp-duedate').removeClass('hidden');
                        }
                        else{
                            $(this).parent().parent().parent('.taskduedate').children('.sp-duedate').addClass('hidden');
                        }

                    });
                    $('.datepicker').datepicker({
                        dateFormat: "yy-mm-dd",
                        onSelect: function(dateText) {
                            $(this).val(dateText);
                            $(this).change();
                            $(this).parent().trigger('submit.rails');
                        }
                    });
                });
            }
        );
        return false;
    });
	$('.mark_comp').bind('change', function() {
    var list_id = $(this).attr('data_target');
                url = null;
                $.ajax({
                    url: list_id+'/tasks/'+this.value+'/complete',
                    type: 'POST',
                    data: {"completed": this.checked}
                });
          
          if ($(this).is(':checked')) {
            $(this).parent().parent().parent('.checkbox').children().children('.item-title').addClass('item-completed');
            }
            else{
            $(this).parent().parent().parent('.checkbox').children().children('.item-title').removeClass('item-completed');
            }    

	});

         $(".btn-delete").on("click",(function(){
             $('#list-items li').eq('task_<%= @task.id %>').remove();
         }));
        
        var html_form_edit = '<form action="#" class="edit_task_frm" remote="true"><input type="text" class="input-small" name="task[description]" id="task_description" />'+
                            '<input type="submit" value="Update task name" class="btn btn-small" />'+
                            '<input type="button" value="Cancel" class="btn btn-small canceledittaskbt" /></form>';
        $('.btn-edit').on("click", function(){
                        var obj_task_des = $(this).parent().parent(".items").children().children().children(".item-title");
                        var url = obj_task_des.data("url");
                        var task_des = obj_task_des.text();
                        obj_task_des.html(html_form_edit);
                        obj_task_des.children().children('#task_description').val(task_des);
                        obj_task_des.children(".edit_task_frm").attr("action", url);
                        $('.edit_task_frm').on("submit", function() {
                            var form = this;
                            $.ajax({
                                type: "post" ,
                                url: $(this).attr("action"),
                                data: $(this).serialize(),
                                dataType: "json",
                                success:function(data) {
                                    var success = data.success;
                                    var task = data.task;
                                    if(success === 1) {
                                        $(form).parent(".item-title").html(task.description);
                                    } else {
                                        form.append('<span class="error">Cannot be saved</span>');
                                    }
                                },
                                error:function() {
                                    alert("Error");
                                }
                            });
                            return false;
                        });
                        $('.canceledittaskbt').on("click",function(){
                            $('.edit_task_frm').parent(".item-title").html(task_des);
                        });
                    });

        
        $('.items').on("mouseenter", function() {
            $(this).children(".action").show();
        }).on("mouseleave", function() {
            $(this).children(".action").hide();
        });   

        $('.logo-editbt').on("click" , function(){
                      
        });

    $('#bt-invite-user').click(function() {
        $('#frm_invite_user').show();
        $(this).hide();
         });

    $('#bt-cancel-invite').click(function() {
        $('#frm_invite_user').hide();
        $('#bt-invite-user').show();
    });
    $(".task-hasduedate").bind('change', function(){
            var list_id = $(this).attr('data_target');
            url = null;
            $.ajax({
                url: list_id+'/tasks/'+this.value+'/hasduedate',
                type: 'POST',
                data: {"hasduedate": this.checked}
            });
        
      if ($(this).is(':checked')) {
            $(this).parent().parent().parent('.taskduedate').children('.sp-duedate').removeClass('hidden');
        }
        else{
            $(this).parent().parent().parent('.taskduedate').children('.sp-duedate').addClass('hidden');
        }    

    });
    $('.datepicker').datepicker({
        dateFormat: "yy-mm-dd",
        onSelect: function(dateText) {
            $(this).val(dateText);
            $(this).change();
            $(this).parent().trigger('submit.rails');
        }
    });
});