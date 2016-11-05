/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/Issues')
global with sharing class RestPrmProviderIssueController {
    @HttpGet
    global static List<RestPrmIssueController.Issue> doGet() {
        String providerId = uRestController.getParentObjectId('Providers/');
        
        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Provider__c', '=', providerId));
        
        if(String.isBlank(uRestController.getParameterValue('status'))) {
        	additionalConditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Status__c', 'd', 'Closed')); //T2427
        }
        
        return RestPrmIssueController.performGetSearch(additionalConditions, null);
    }
    
    @HttpPost
    global static RestPrmIssueController.Issue doPost(RestPrmIssueController.Issue data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.provider == null) {
        	data.provider = new RestPrmProviderController.ProviderLite();
        }
        
        data.provider.id = uRestController.getParentObjectId('Providers/');
        
        return RestPrmIssueController.doPost(data);
    }
    
    @HttpPut
    global static RestPrmIssueController.Issue doPut(RestPrmIssueController.Issue data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.provider == null) {
            data.provider = new RestPrmProviderController.ProviderLite();
        }
        
        data.provider.id = uRestController.getParentObjectId('Providers/');
               
        return RestPrmIssueController.doPut(data);
    }
    
    @HttpPatch
    global static void doPatch(List<String> data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return;  
        }
               
        RestPrmIssueController.doPatch(data);
    }
    
    @HttpDelete
    global static void doDelete() {
        RestPrmIssueController.doDelete();
    }
}