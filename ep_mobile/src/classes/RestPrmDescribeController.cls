/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Describes/*')
global with sharing class RestPrmDescribeController {
    
    @HttpGet
    global static Map<String, Map<String, List<uRestController.PicklistEntry>>> doGet() {
    	String objectName = uRestController.objectId.toLowerCase();
    	Map<String, Map<String, List<uRestController.PicklistEntry>>> response = 
            new Map<String, Map<String, List<uRestController.PicklistEntry>>>();
            
    	if(objectName == 'call') {
    		response.put(objectName, uRestController.getPickListValues(Task.getSObjectType(), RestPrmCallController.fieldMap));
    	}
    	else if(objectName == 'task') {
    		response.put(objectName, uRestController.getPickListValues(Task.getSObjectType(), RestPrmTaskController.fieldMap));
    	}
        else if(objectName == 'issue') {
            response.put(objectName, uRestController.getPickListValues(HC4__Issue__c.getSObjectType(), RestPrmIssueController.fieldMap));
        }
        else if(objectName == 'note') {
            response.put(objectName, uRestController.getPickListValues(Note.getSObjectType(), RestPrmNoteController.fieldMap));
        }
        else {
        	uRestController.setStatusCode(uRestController.BadRequest, 'Invalid Object Type');
        }
        
        return response;
    }
}