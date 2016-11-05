/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Practices/*/Alerts')
global with sharing class RestPrmPracticeAlertController2 {
	
	@HttpGet
    global static RestPrmAlertController2.AlertFeed doGet() {
        String practiceId = uRestController.getParentObjectId('Practices/');
        
        RestPrmAlertController2.AlertFeed response = new RestPrmAlertController2.AlertFeed();
        
        List<HC4.uCondition> conditions = new List<HC4.uCondition>();
        
        if(String.isBlank(uRestController.sortBy)){
        	uRestController.request.params.put('sort','dueDate');
        }
        conditions.add(new HC4.uCondition('Task', 'WhatId', '=', practiceId));
        conditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false'));
        conditions.add(new HC4.uCondition('Task', 'ActivityDate', '<', DateTime.now().format('yyyy-MM-dd'))); 
        response.overdueTasks.addAll(RestPrmTaskSearchController.performGetSearch(conditions));
        
        return response;
    }

}