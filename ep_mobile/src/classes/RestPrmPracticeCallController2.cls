/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Practices/*/Calls')
global with sharing class RestPrmPracticeCallController2 {
	@HttpGet
    global static List<uRestController.GenericGetListResponse> doGet() {
        String practiceId = uRestController.getParentObjectId('Practices/');

        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'WhatId', '=', practiceId));        
        
        return RestPrmCallSearchController.performGetSearch(additionalConditions);   
    }
    
    @HttpPost
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        data = setPracticeValue(data);
        
        return RestPrmCallController2.doPost(data);
    }
    
    @HttpPut
    global static uRestController.GenericGetResponse doPut(uRestController.GenericGetResponse data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        data = setPracticeValue(data);
                
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
    
    private static uRestController.GenericGetResponse setPracticeValue(uRestController.GenericGetResponse data) {
    	
    	if(!String.isBlank(uRestController.getParentObjectId('Practices/'))){    		
    		for(uRestController.FieldsDescribe describe : data.fieldsInfo){ 
		    		if(describe.name.toLowerCase() == 'whatId'){
		    			describe.value = uRestController.getParentObjectId('Practices/');
						break;
		    		}
	    	}
    	}
    	
    	return data;
    }
}