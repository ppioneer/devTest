/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Practices/*/Calls')
global with sharing class RestPrmPracticeCallController {
    @HttpGet
    global static List<RestPrmCallController.Call> doGet() {
        String practiceId = uRestController.getParentObjectId('Practices/');

        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'WhatId', '=', practiceId));
        //additionalConditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false')); //T2565
        
        return RestPrmCallController.performGetSearch(additionalConditions);   
    }
    
    @HttpPost
    global static RestPrmCallController.Call doPost(RestPrmCallController.Call data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.practice == null) {
            data.practice = new RestPrmPracticeController.PracticeLite();
        }
        
        data.practice.id = uRestController.getParentObjectId('Practices/');
        
        return RestPrmCallController.doPost(data);
    }
    
    @HttpPut
    global static RestPrmCallController.Call doPut(RestPrmCallController.Call data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(data.practice == null) {
        	data.practice = new RestPrmPracticeController.PracticeLite();
        }
        
        data.practice.id = uRestController.getParentObjectId('Practices/');
                
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