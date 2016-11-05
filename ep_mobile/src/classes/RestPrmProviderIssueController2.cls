/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Providers/*/Issues')
global with sharing class RestPrmProviderIssueController2 {
	@HttpGet
    global static List<uRestController.GenericGetListResponse> doGet() {
        String providerId = uRestController.getParentObjectId('Providers/');
        
        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Provider__c', '=', providerId));
        
        if(String.isBlank(uRestController.getParameterValue('status'))) {
        	additionalConditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Status__c', 'd', 'Closed')); 
        }
        
        return RestPrmIssueSearchController.performGetSearch(additionalConditions, null);
    }
    
    @HttpPost
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        data = setProviderValue(data);
        
        return RestPrmIssueController2.doPost(data);
    }
    
    @HttpPut
    global static uRestController.GenericGetResponse doPut(uRestController.GenericGetResponse data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        data = setProviderValue(data);
               
        return RestPrmIssueController2.doPut(data);
    }
    
    @HttpPatch
    global static void doPatch(List<String> data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return;  
        }
               
        RestPrmIssueController2.doPatch(data);
    }
    
    @HttpDelete
    global static void doDelete() {
        RestPrmIssueController2.doDelete();
    }
    
    private static uRestController.GenericGetResponse setProviderValue(uRestController.GenericGetResponse data) {
    	
    	if(!String.isBlank(uRestController.getParentObjectId('Providers/'))){    		
    		for(uRestController.FieldsDescribe describe : data.fieldsInfo){ 
		    		if(describe.name.toLowerCase() == 'HC4__Provider__c'){
		    			describe.value = uRestController.getParentObjectId('Providers/');
						break;
		    		}
	    	}
    	}
    	
    	return data;
    }
}