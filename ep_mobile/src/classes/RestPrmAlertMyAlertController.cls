/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Alerts/myAlerts')
global with sharing class RestPrmAlertMyAlertController {
    @HttpGet
    global static RestPrmAlertController.AlertFeed doGet() {       
        RestPrmAlertController.AlertFeed response = new RestPrmAlertController.AlertFeed();
        
        //T2645
        if(String.isBlank(uRestController.sortBy)){
        	uRestController.request.params.put('sort','dueDate;-createdDate');
        }
                
        List<HC4.uCondition> conditions = new List<HC4.uCondition>();
        conditions.add(new HC4.uCondition('Task', 'OwnerId', '=', UserInfo.GetUserId())); //T2415
        conditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false'));
        conditions.add(new HC4.uCondition('Task', 'ActivityDate', '<', DateTime.now().format('yyyy-MM-dd'))); 
        response.overdueTasks.addAll(RestPrmTaskController.performGetSearch(conditions));
        
        conditions = new List<HC4.uCondition>();
       
        conditions.add(new HC4.uCondition('HC4__Issue__c', 'OwnerId', '=', UserInfo.GetUserId()));
        // Issues with Status High and Not Closed - T2415
        List<String> complexConditions = new List<String>(); 
        complexConditions.add('(' + new HC4.uCondition('HC4__Issue__c', 'HC4__Status__c', '=', 'Escalated').toSql() + ' OR (' +
        	new HC4.uCondition('HC4__Issue__c', 'HC4__Priority__c', '=', 'High').toSql() + ' AND ' +
         	new HC4.uCondition('HC4__Issue__c', 'HC4__Status__c', 'd', 'Closed').toSql() + '))');
        
        response.openIssues.addAll(RestPrmIssueController.performGetSearch(conditions, complexConditions));
        
        return response;
    }
}