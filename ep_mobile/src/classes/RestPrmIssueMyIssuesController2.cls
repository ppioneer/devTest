/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Issues/myIssues')
global with sharing class RestPrmIssueMyIssuesController2 {
	
	@HttpGet
    global static List<uRestController.GenericGetListResponse> doGet() {
    	List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('HC4__Issue__c', 'OwnerId', '=', UserInfo.getUserId()));
        
        if(String.isBlank(uRestController.getParameterValue('status'))) { 
        	additionalConditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Status__c', 'd', 'Closed')); 
        }
        
        return RestPrmIssueSearchController.performGetSearch(additionalConditions, null);        
    }
}