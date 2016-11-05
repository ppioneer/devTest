/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Practices/*/Tasks')
global with sharing class RestPrmPracticeTaskController {
    @HttpGet
    global static List<RestPrmTaskController.RestTask> doGet() {
        String practiceId = uRestController.getParentObjectId('Practices/');

        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'WhatId', '=', practiceId));
         //T2109 - Fix 
        if(String.isBlank(uRestController.getParameterValue('isClosed'))){        	        	
        	additionalConditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false'));        	
        }
        
        return RestPrmTaskController.performGetSearch(additionalConditions);  
    }
    
    @HttpPost
    global static RestPrmTaskController.RestTask doPost(RestPrmTaskController.RestTask data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.practice == null) {
        	data.practice = new RestPrmPracticeController.PracticeLite();
        }
        
        data.practice.id = uRestController.getParentObjectId('Practices/');
        
        return RestPrmTaskController.doPost(data);
    }
    
    @HttpPut
    global static RestPrmTaskController.RestTask doPut(RestPrmTaskController.RestTask data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.practice == null) {
            data.practice = new RestPrmPracticeController.PracticeLite();
        }
        
        data.practice.id = uRestController.getParentObjectId('Practices/');
                
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