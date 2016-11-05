/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Users/myPermissions/*')
global with sharing class RestPrmUserMyPermissionController {
	
	/* 
		Return the object permissions for a User based on the request. If request parameter is empty then retun all, else retun only specific object related
	*/
	 @HttpGet
    global static Map<String,RestPrmUserMyPermissionController.UserPermissions> doGet() {
    	
    	Map<String,RestPrmUserMyPermissionController.UserPermissions> response = new Map<String,RestPrmUserMyPermissionController.UserPermissions>();
    	        
        String objectName = uRestController.objectId.toLowerCase();
        if(!String.isBlank(objectName)) {
	    	if(objectName == 'task' || objectName == 'call') {
	    		 Schema.DescribeSObjectResult dsr = Task.sObjectType.getDescribe();
	    		 response.put(objectName,new RestPrmUserMyPermissionController.UserPermissions(dsr.getLabel(),String.valueOf(dsr.isDeletable())));
	    	}
	        else if(objectName == 'issue') {
	        	 Schema.DescribeSObjectResult dsr = HC4__Issue__c.sObjectType.getDescribe();
	    		 response.put(objectName,new RestPrmUserMyPermissionController.UserPermissions(dsr.getLabel(),String.valueOf(dsr.isDeletable())));            
	        }
	        else if(objectName == 'note') {            
	            Schema.DescribeSObjectResult dsr = Note.sObjectType.getDescribe();
	    		response.put(objectName,new RestPrmUserMyPermissionController.UserPermissions(dsr.getLabel(),String.valueOf(dsr.isDeletable())));
	        }
	        else {
	        	uRestController.setStatusCode(uRestController.BadRequest, 'Invalid Object Type');
	        }
        }
        else
        {
        	Schema.DescribeSObjectResult dsrTask = Task.sObjectType.getDescribe();
	    	response.put('Task',new RestPrmUserMyPermissionController.UserPermissions('Task',String.valueOf(dsrTask.isDeletable())));
	        
	        Schema.DescribeSObjectResult dsrCall = Task.sObjectType.getDescribe();
	    	response.put('Call',new RestPrmUserMyPermissionController.UserPermissions('Call',String.valueOf(dsrCall.isDeletable())));
	        
	        Schema.DescribeSObjectResult dsrIssue = HC4__Issue__c.sObjectType.getDescribe();
	    	response.put('Issue',new RestPrmUserMyPermissionController.UserPermissions('Issue',String.valueOf(dsrIssue.isDeletable())));
	    		 
	    	Schema.DescribeSObjectResult dsrNote = Note.sObjectType.getDescribe();
	    	response.put('Note',new RestPrmUserMyPermissionController.UserPermissions('Note',String.valueOf(dsrNote.isDeletable())));
        }
        
        return response;
    }
    
    
    global class UserPermissions{   
    	 
    	public String objectName {get;set;}
    	public String isDeletable {get;set;}   	
    	    	
    	   	
    	public UserPermissions(String sobjectName,String deletableFlag) {
             this.objectName = sobjectName;            
             this.isDeletable  = deletableFlag;
             
        }    	
    }
}