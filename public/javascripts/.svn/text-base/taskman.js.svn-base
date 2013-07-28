/*  Taskman Javascript functions
 *  (c) 2006-2007 Daniel Norton <dnorton@gmail.com>
 *
/*--------------------------------------------------------------------------*/

/*
 * global variables
 */
 var showingCompleteTasks = false;
 var newTaskPanel;
 var tasks;
 var YEvent = YAHOO.util.Event;
 var YDom = YAHOO.util.Dom;
 
/* function to retrieve the running time of a task and populate a 
 * container 
 */
function get_time(event, elId) {
	if (!elId) {
		alert("elId was null");
		return false;
	}
    var container = Builder.node('span', {className:'running_time', id:'running_time_' + elId});
    Position.absolutize(container);
    container.setStyle({
        top: Event.pointerY(event) - 16 + 'px',
        left: Event.pointerX(event) + 300 + 'px',
        width: '5em',
        height: '2em'
    });
    container.innerHTML = "<img src=\'/images/indicator.gif\'/>";
    $('running_task_name_' + elId).appendChild(container);
    new Ajax.Updater('running_time_' + elId, 
        '/task/running_time/' + elId, 
        {asynchronous:true, evalScripts:true, 
        onComplete:function(request){
            Element.show('running_time_' + elId)}});
    }

function new_task() {
	Element.show('new_task');
	Field.focus('task_name');
}

function task_updated(id) {
	var task = $('task_' + id);
	new Ajax.Updater('active_time', 
	                 '/project/active_time/' + id,
	                 {asynchronous:true, evalScripts:true});
}

function task_updated_sidebar(id) {
	var task = $('task_' + id);
	new Ajax.Updater('active_time', 
                 '/project/active_time/' + id,
                 {asynchronous:true, evalScripts:true});
	
	new Ajax.Updater('sidebar',
	                 '/task/details/' + id,
	                 {asynchronous:true, evalScripts:true,
	                 onComplete:function(request){new Effect.Highlight('sidebar',{});}});
	
}

function comment_added(id) {
	var task = $('task_' + id);
	new Ajax.Updater('comments_' + id,
	                 '/task/update_comment_count/' + id,
	                 {asynchronous:true, evalScripts:true,
	                 onComplete:function(request){new Effect.Highlight('sidebar',{});}});
	
}

function taskHover(event){
	
    var el = $(this);    
    el.setStyle({backgroundColor: '#FFFFCC'});
	var array = YDom.getElementsByClassName('task_details', 'span', el);
	if (array.length > 0) {
    	Element.show(YDom.getElementsByClassName('task_details', 'span', el)[0]);
	}
}

function taskHoverOff(event) {
    var el = $(this);
    el.setStyle({backgroundColor: '#FFFFFF'});
	var array = YDom.getElementsByClassName('task_details', 'span', el);
	if (array.length > 0) {
    	Element.hide(YDom.getElementsByClassName('task_details', 'span', el)[0]);
	}

}

function highlightNameOn(e){
	var el = $(this);
	YDom.addClass(el, 'highlight');
}

function highlightNameOff(e){
	var el = $(this);
	YDom.removeClass(el, 'highlight')	
}

function setName(e) {
	var el = $(this);
	var id = el.id
	var task = id.split("_");
	new Ajax.Updater(task[0] + '_' + task[2],
					 '/' + task[0] + '/edit_' + task[1] + '/' + task[2],
	                 {asynchronous:true, evalScripts:true});
	
}


function showDropDown(event) {
	var el = $(this);
	el.className = "tab_hover";
	var dropDownEl = el.getElementsByTagName('ul')[0];
	if (typeof dropDownEl  != 'undefined') {
		dropDownEl.className = "drop_down_over";
	}
}

function hideDropDown(event) {
	var el = $(this);
	el.className = "tab";
	var dropDownEl = el.getElementsByTagName('ul')[0];
	if (typeof dropDownEl != 'undefined'){
		dropDownEl.className = "drop_down";
	}
}

function check_reminders() {
	new Ajax.Updater('status',
	                 '/reminders/check_past_due',
	                 {asynchronous:true, evalScripts:true});
    
}

function get_completed_tasks(id) {
    new Ajax.Updater('completed_tasks',
                     '/project/completed_tasks/' + id,
                     {asynchronous:true, evalScripts:true});
}

function highlightTime(e, elId) {
    var el = $(elId);
    el.setStyle({'border-bottom': '2px dotted #A80000'});
}

function unhighlightTime(e, elId) {
    var el = $(elId);
    el.setStyle({'border-bottom':'none'});
}

function updateProjectActiveTime(e, id) {
        var timeEl = $('active_time');
        timeEl.innerHTML = "<img src=\'/images/indicator.gif\'/>";
    	new Ajax.Updater('active_time', 
                 '/project/project_active_time/' + id,
                 {asynchronous:true, evalScripts:true});
    
}

/**
execute ajax call to get the total time
**/
function updateTime(event, id) {
    var time = $('task_time_' + id);
    time.innerHTML = "<img src=\'/images/indicator.gif\'/>";
    new Ajax.Updater('task_time_' + id,
                     '/task/total_time/' + id,
                     {asynchronous:true, evalScripts:true});
}

/**
load element
**/
function loading(id) {
	$(id).innerHTML= "<img src=\'/images/indicator.gif\'/>";
	Element.show(id);
}

function task_loading() {
	$('form-submit-button').disabled = true;
	$('form-submit-button').value='Adding...';	
	$('action_status').innerHTML= "<div id=\"inner_action_status\">\n" + 
		"Adding Task <img src=\'/images/indicator.gif\'/>\n" +
		"</div>";
}

function task_added() {
	$('task_name').value = '';
	$('form-submit-button').disabled = false;
	$('form-submit-button').value = 'Add';
	if (typeof newTaskPanel != 'undefined') {
		newTaskPanel.hide();
	}
	new Ajax.Updater('action_status', 
        '/task/action_status', 
        {asynchronous:true, evalScripts:true});
		window.setTimeout('Effect.Fade(\'action_status\', {duration:1})', 10000);
	if (! Element.visible('active_tasks_table')) {
		Element.show('active_tasks_table');
	}
	var noTaskMessage = $('no_task_message');
	if (noTaskMessage != undefined && typeof noTaskMessage != 'undefined') {
		Element.hide('no_task_message');
	}
	// reload the listener for hover on the task rows
	YEvent.removeListener(tasks, 'mouseover', taskHover);
	YEvent.removeListener(tasks, 'mouseout', taskHoverOff);
	tasks = YDom.getElementsByClassName('task', 'tr');
	YEvent.addListener(tasks, 'mouseover', taskHover);
	YEvent.addListener(tasks, 'mouseout', taskHoverOff);	
}

function showNewTask() {
	Element.show('new_task_panel');
	newTaskPanel.show();
	$('task_name').focus();
}

function fadeStatusMessage() {
	if (typeof console != "undefined") {
		console.warn("fade");
	}
}

/*
YUI function to create panel for generating new tasks
The declarations for the YUI js files must come before this file 
*/
YAHOO.namespace('task');
YAHOO.task.panels = function () {
	newTaskPanel = new YAHOO.widget.Panel('new_task_panel', { 
		    close:true,  
		    visible:false,  
		    draggable:true,
                    widh:'300px',
                    fixedcenter:true});
	newTaskPanel.render();
};

taskinit = function () {
	
	var dropDowns = YDom.getElementsByClassName("tab", "li", document);
	YEvent.addListener(dropDowns, 'mouseover', showDropDown);
	YEvent.addListener(dropDowns, 'mouseout', hideDropDown);
	tasks = YDom.getElementsByClassName('task', 'tr', document);
	YEvent.addListener(tasks, 'mouseover', taskHover);
	YEvent.addListener(tasks, 'mouseout', taskHoverOff);
	
}
