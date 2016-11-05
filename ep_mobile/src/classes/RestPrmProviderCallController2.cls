/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Providers/*/Calls')
global with sharing class RestPrmProviderCallController2 {
	@HttpGet
    global static List<uRestController.GenericGetListResponse> doGet() {
        String providerId = uRestController.getParentObjectId('Providers/');

        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'WhoId', '=', providerId));        
        
        return RestPrmCallSearchController.performGetSearch(additionalConditions);  
    }
    
    @HttpPost
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        data = setProviderValue(data);
        
        return RestPrmCallController2.doPost(data);
    }
    
    @HttpPut
    global static uRestController.GenericGetResponse doPut(uRestController.GenericGetResponse data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        data = setProviderValue(data);
                
        return RestPrmCallController2.doPut(data);
    }
    
    @HttpPatch
    global static void doPatch(List<String> data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return;  
        }

        RestPrmCallController2.doPatch(data);
    }
    
    @HttpDelete
    global static void doDelete() {
        RestPrmCallController2.doDelete();
    }
    
    private static uRestController.GenericGetResponse setProviderValue(uRestController.GenericGetResponse data) {
    	
    	if(!String.isBlank(uRestController.getParentObjectId('Providers/'))){    		
    		for(uRestController.FieldsDescribe describe : data.fieldsInfo){ 
		    		if(describe.name.toLowerCase() == 'whoid'){
		    			describe.value = uRestController.getParentObjectId('Providers/');
						break;
		    		}
	    	}
    	}
    	
    	return data;
    }
}