/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Tasks/myTasks')
global with sharing class RestPrmTaskMyTasksController {
    
    @HttpGet
    global static List<RestPrmTaskController.RestTask> doGet() {
    	List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'OwnerId', '=', UserInfo.getUserId()));        
       //T2109 - Fix
        if(String.isBlank(uRestController.getParameterValue('isClosed'))){        	        	
        	additionalConditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false'));        	
        }//T2109
        
        return RestPrmTaskController.performGetSearch(additionalConditions);
    }
}