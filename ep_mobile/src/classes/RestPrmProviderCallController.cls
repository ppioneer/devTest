/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/Calls')
global with sharing class RestPrmProviderCallController {
    @HttpGet
    global static List<RestPrmCallController.Call> doGet() {
        String providerId = uRestController.getParentObjectId('Providers/');

        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'WhoId', '=', providerId));
        //additionalConditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false')); //T2565
        
        return RestPrmCallController.performGetSearch(additionalConditions);  
    }
    
    @HttpPost
    global static RestPrmCallController.Call doPost(RestPrmCallController.Call data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.provider == null) {
        	data.provider = new RestPrmProviderController.ProviderLite();
        }
        
        data.provider.Id = uRestController.getParentObjectId('Providers/');
        
        return RestPrmCallController.doPost(data);
    }
    
    @HttpPut
    global static RestPrmCallController.Call doPut(RestPrmCallController.Call data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.provider == null) {
            data.provider = new RestPrmProviderController.ProviderLite();
        }
        
        data.provider.Id = uRestController.getParentObjectId('Providers/');
                
        return RestPrmCallController.doPut(data);
    }
    
    @HttpPatch
    global static void doPatch(List<String> data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return;  
        }

        RestPrmCallController.doPatch(data);
    }
    
    @HttpDelete
    global static void doDelete() {
        RestPrmCallController.doDelete();
    }
}