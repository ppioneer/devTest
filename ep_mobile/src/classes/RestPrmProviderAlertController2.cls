/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Providers/*/Alerts')
global with sharing class RestPrmProviderAlertController2 {
	
	@HttpGet
    global static RestPrmAlertController2.AlertFeed doGet() {
    	String providerId = uRestController.getParentObjectId('Providers/');
    	
    	RestPrmAlertController2.AlertFeed response = new RestPrmAlertController2.AlertFeed();
    	
    	if(String.isBlank(uRestController.sortBy)){
        	uRestController.request.params.put('sort','dueDate;-createdDate');
        }
    	List<HC4.uCondition> conditions = new List<HC4.uCondition>();
    	conditions.add(new HC4.uCondition('Task', 'WhoId', '=', providerId));
    	conditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false'));
    	conditions.add(new HC4.uCondition('Task', 'ActivityDate', '<', DateTime.now().format('yyyy-MM-dd'))); 
    	response.overdueTasks.addAll(RestPrmTaskSearchController.performGetSearch(conditions));
    	
    	conditions = new List<HC4.uCondition>();    	
        
    	conditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Provider__c', '=', providerId));
    	
        List<String> complexConditions = new List<String>(); 
        complexConditions.add('(' + new HC4.uCondition('HC4__Issue__c', 'HC4__Status__c', '=', 'Escalated').toSql() + ' OR (' +
        	new HC4.uCondition('HC4__Issue__c', 'HC4__Priority__c', '=', 'High').toSql() + ' AND ' +
         	new HC4.uCondition('HC4__Issue__c', 'HC4__Status__c', 'd', 'Closed').toSql() + '))');
        
        response.openIssues.addAll(RestPrmIssueSearchController.performGetSearch(conditions, complexConditions));
    	
    	return response;
    }

}