/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Tasks/myTasks')
global with sharing class RestPrmTaskMyTasksController2 {
	
	@HttpGet
    global static List<uRestController.GenericGetListResponse> doGet() {
    	List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Task', 'OwnerId', '=', UserInfo.getUserId()));        
       
        if(String.isBlank(uRestController.getParameterValue('isClosed'))){        	        	
        	additionalConditions.add(new HC4.uCondition('Task', 'IsClosed', '=', 'false'));        	
        }
        
        return RestPrmTaskSearchController.performGetSearch(additionalConditions);
    }

}