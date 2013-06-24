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
//= require jquery
//= require jquery_ujs
//= require_tree .

$(function() {
       
	$('.mark_comp').on('click', function() {
		if ($(this).is(':checked')) {
			$(this).parent().trigger('submit.rails');
		}
	});
	
	$('.mark_in_comp').on('click', function() {
		
            $(this).parent().trigger('submit.rails');
		
	});
        
        $("form#new_task").submit(function() {
           var url = $(this).attr("action");
            $.post(
                url,
                $(this).serialize(),
                function(response) {
                    $("#list-items").html(response);
                    $(this).val('');
                }
            ); 
            return false;
        }
        );
         $(".btn-delete").on("click",(function(){
             $('#list-items li').eq('task_<%= @task.id%>').remove();
         })
         );
        
        var html_form_edit = '<form action="#" class="edit_task_frm"><input type="text" class="small-text" name="task[description]" id="task_description" />'+
                            '<input type="submit" value="Save" class="btn btn-large btn-primary" />'+
                            '<input type="button" value="Cancel" class="btn btn-large btn-inverse/>\n\'</form>';
        $('.btn-edit').on("click", function() {
            var obj_task_des = $(this).parent().parent(".checkbox").children(".task-des");
            var url = obj_task_des.data("url");
            var task_des = obj_task_des.text();
            obj_task_des.html(html_form_edit);
            obj_task_des.children().children('#task_description').val(task_des);
            obj_task_des.children(".edit_task_frm").attr("action", url);
        });
        
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
                      $(form).parent(".task-des").html(task.description);
                      
                   } else {
                       form.append('<span class="error">Cannot be saved</span>');
                   }
               },
               error:function() {
                alert("error");
               }
            });
            return false; 
        });
        
        $('.checkbox').on("mouseenter", function() {
            $(this).children(".action").show();
        }).on("mouseleave", function() {
            $(this).children(".action").hide();
        });   
//         $('.checkbox').hover(
//            function() {
//                $(this).children(".action").show();
//            },
//            function() {
//                $(this).children(".action").hide();
//            }
//        );
        $('.logo-editbt').on("click" , function(){
                      
        });
});