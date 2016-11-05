/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Practices/*/Alerts')
global with sharing class RestPrmPracticeAlertController {
    @HttpGet
    global static RestPrmAlertController.AlertFeed doGet() {
        String practiceId = uRestController.getParentObjectId('Practices/');
        
        RestPrmAlertController.AlertFeed response = new RestPrmAlertController.AlertFeed();
        
        List<HC4.uCondition> conditions = new List<HC4.uCondition>();
        //T2645
        if(String.isBlank(uRestController.sortBy)){
        	uRestController.request.params.put('sort','dueDate');
        }
        conditions.add(new HC4.uCondition('Task', 'WhatId', '=', practiceId));
        conditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false'));
        conditions.add(new HC4.uCondition('Task', 'ActivityDate', '<', DateTime.now().format('yyyy-MM-dd'))); 
        response.overdueTasks.addAll(RestPrmTaskController.performGetSearch(conditions));
        
        return response;
    }
}