/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/Tasks')
global with sharing class RestPrmProviderTaskController {
    
    @HttpGet
    global static List<RestPrmTaskController.RestTask> doGet() {
        String providerId = uRestController.getParentObjectId('Providers/');

        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'WhoId', '=', providerId));        
        //T2109 - Fix
        if(String.isBlank(uRestController.getParameterValue('isClosed'))){        	        	
        	additionalConditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false'));        	
        }//T2109
        
        return RestPrmTaskController.performGetSearch(additionalConditions);  
    }
    
    @HttpPost
    global static RestPrmTaskController.RestTask doPost(RestPrmTaskController.RestTask data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.provider == null) {
            data.provider = new RestPrmProviderController.ProviderLite();
        }
        
        data.provider.id = uRestController.getParentObjectId('Providers/');
        
        return RestPrmTaskController.doPost(data);
    }
    
    @HttpPut
    global static RestPrmTaskController.RestTask doPut(RestPrmTaskController.RestTask data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.provider == null) {
            data.provider = new RestPrmProviderController.ProviderLite();
        }
        
        data.provider.id = uRestController.getParentObjectId('Providers/');
                
        return RestPrmTaskController.doPut(data);
    }
    
    @HttpPatch
    global static void doPatch(List<String> data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return;  
        }
                      
        RestPrmTaskController.doPatch(data);
    }
    
    @HttpDelete
    global static void doDelete() {
        RestPrmTaskController.doDelete();
    }
}