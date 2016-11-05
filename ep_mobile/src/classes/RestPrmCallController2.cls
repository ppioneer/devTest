/* Copyright (c) 2008-2014 Evariant */ 
@RestResource(urlMapping='/mobile/prm/v2/Calls/*')
global with sharing class RestPrmCallController2 {
	
	
    public static final String objectName = 'Task';
    public static final String fsCall = uRestController.getFieldSetName(objectName, Schema.SObjectType.Task.fieldSets.EditCall.Label);
    public static final String objectLabel = 'Call';
    global static string validationMsg {get;set;}
    
    @HttpGet
    global static List<uRestController.GenericGetResponse> doGet() {
    	String objectId = uRestController.objectId;
    	uRestController.GenericGetResponse obj = new uRestController.GenericGetResponse(objectName);
    	List<uRestController.GenericGetResponse> response = new List<uRestController.GenericGetResponse>();
    	if(!String.isBlank(objectId)){
    		response.add(obj.RecordItem(objectId, fsCall, objectLabel));
    	}
    	else{    		 
    		response.add(uRestController.getView(objectName, fsCall, objectLabel));  
    	}
    	
        return response; 
    }
    
    @HttpPost
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data, String objectType, String[] ids) {
    	String relationName = uString.EMPTY; 
    	    	
    	if(objectType == 'Provider'){
    		relationName = 'WhoId'; 
    	} 
    	else if(objectType == 'Practice'){
    		relationName = 'WhatId'; 
    	}
    	
    	return RestPrmCallController2.doPost(data, ids, relationName);	
    }
    
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data, String[] Ids, String relationType) {    	
    	uRestController.GenericGetResponse response = new uRestController.GenericGetResponse();
    	
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           response.responseCode = uRestController.BadRequest;   
           return response;
        }
        
        if(Ids == null) {
            return RestPrmCallController2.doPost(data);
        }  
        
        try {
            List<Task> tasks = new List<Task>();
            
            for(String providerId : Ids) {
            	            					               
                Task sfTask = createTask(uRestController.getFSMembers(fsCall, objectName), data);
                
                sfTask.put(relationType, providerId); //Adding providers to the data object
                
                if(String.isBlank(validationMsg) && sfTask == null) {
                    return null;
                }
                
                tasks.add(sfTask);
            }
            
            insert tasks;
            
            Set<Id> taskIds = new Set<Id>();
            for(Task t : tasks) {
                taskIds.add(t.Id);
            }
            
            uRestController.setStatusCode(uRestController.Created);
            response.responseCode = uRestController.Created;            
        }
        catch (System.DmlException ex) {
	        	System.debug(LoggingLevel.ERROR, ex);
	            uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
	            response.responseCode = uRestController.BadRequest; 
	            response.responseMessage = ex.getDmlMessage(0);  
	    }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
            response.responseCode = uRestController.Conflict; 
            response.responseMessage = e.getMessage();
        }
        
        return response;
    }
    
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data) {    	
    	uRestController.GenericGetResponse response = new uRestController.GenericGetResponse();
    	uRestController.GenericGetResponse obj = new uRestController.GenericGetResponse(objectName);
    	
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           response.responseCode = uRestController.BadRequest;   
           return response;
        }        
        try {        	
        	Task oTask = null;
	    		
	    	oTask = createTask(uRestController.getFSMembers(fsCall, objectName), data); 
			if(oTask != null && String.isBlank(validationMsg)){ 
    			insert oTask;	    			      	        	                
		        uRestController.setStatusCode(uRestController.Created);
		        response.responseCode = uRestController.Created; 
		        response  = obj.RecordItem(oTask.Id, fsCall, objectLabel);
			}
			else{
				uRestController.setStatusCode(uRestController.BadRequest, validationMsg);
				response.responseCode = uRestController.BadRequest; 
				response.responseMessage = validationMsg;
				return response;
			}
        }
        catch (System.DmlException ex) {
	        	System.debug(LoggingLevel.ERROR, ex);
	            uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
	            response.responseCode = uRestController.BadRequest; 
	            response.responseMessage = ex.getDmlMessage(0);  
	    }
        catch (Exception e) {
        	System.debug(LoggingLevel.INFO,  e.getMessage());
            uRestController.setStatusCode(uRestController.BadRequest, e.getMessage());
            response.responseCode = uRestController.BadRequest; 
    		response.responseMessage = e.getMessage(); 
        }        
        return response;
    }
    
    /*
     * Dynamically Assign the Task Fields Information to Task sObect    
    */
    public static Task createTask(Map<String, Schema.FieldSetMember> fsMap, uRestController.GenericGetResponse data){
    		Task sfTask = new Task();
    		sfTask.put('Type', 'Call');
    		sfTask.put('Subject', 'Call');
    		String prmActivity = uRestController.getPRMActivityAPIName('Task');
    		sfTask.put(prmActivity, true);	    		
    		try{
    			
    			if(data == null) {
		           uRestController.setStatusCode(uRestController.BadRequest);   
		           return null;
		        }
    			
    			if(!String.isBlank(data.id)) {
	            	sfTask.put('Id', data.id);
	        	} 
    			
    			if(isTaskValidated(uRestController.getRequiredFields(fsCall, objectName), data)){    				
	    			for(uRestController.FieldsDescribe describe : data.fieldsInfo){ 
			    			if(fsMap.get(describe.name) != null){		    				
			    				if((fsMap.get(describe.name)).getType() == Schema.DisplayType.Double || (fsMap.get(describe.name)).getType() == Schema.DisplayType.Percent || (fsMap.get(describe.name)).getType() == Schema.DisplayType.CURRENCY){
			    					if(!String.isBlank(describe.value)){
				    					Decimal dclValue = Decimal.valueOf(describe.value);
				    					sfTask.put(describe.name,dclValue);
			    					}
			    				}
			    				else if((fsMap.get(describe.name)).getType() == Schema.DisplayType.Integer){
			    					if(!String.isBlank(describe.value)){
				    					Integer iValue = Integer.valueOf(describe.value);
				    					sfTask.put(describe.name, iValue);
			    					}
			    				}
			    				else if((fsMap.get(describe.name)).getType() == Schema.DisplayType.DateTime){
			    					    if(!String.isBlank(describe.value)){			    					    				    					    	
			    					    	if(describe.name == 'ReminderDateTime'){ 
			    					    		sfTask.put('IsReminderSet', true); // Task is having Reminder date time, set the flag
			    					    	}
			    					    	sfTask.put(describe.name, uRestController.getDateTime(describe.value)); 
			    					    }
			    					    else{
		    					    	   if(!describe.name.contains('DateTimeOpened__c')){ 
                                            	sfTask.put(describe.name, null);
                                           }
			    					    }			    									    						
			    				}
			    				else if((fsMap.get(describe.name)).getType() == Schema.DisplayType.Date){			    						
			    					    if(!String.isBlank(describe.value)){			    					    	
			    					    	sfTask.put(describe.name, uRestController.getDate(describe.value));
			    					    }
			    					    else{
			    					    	sfTask.put(describe.name, null);
			    					    }			    									    						
			    				}
			    				else if((fsMap.get(describe.name)).getType() == Schema.DisplayType.Boolean){	
			    					sfTask.put(describe.name, Boolean.valueOf(describe.value));
								}
			    				else			    				
			    					sfTask.put(describe.name, describe.value);
			    			}
			    	}
			    	
			    	// Assgin the default value to Completed - Desktop functionality
			    	sfTask.put('Status', 'Completed');			    							    
	    		}
	    		else
	    			return new Task();  		
    		}
    		catch(Exception ex){
    			System.debug(LoggingLevel.Error,  ex.getMessage());
    			validationMsg = ex.getMessage(); 
    			uRestController.setStatusCode(uRestController.BadRequest, validationMsg);
    			throw ex;
    		}		         	
        	return sfTask;
    }
    
    /*
     * Validate Task & filedset required fileds    
    */
    public static Boolean isTaskValidated(Map<String, Schema.FieldSetMember> requiredFields, uRestController.GenericGetResponse data){
    		Boolean isValidated = true;
    		String sMsg = uString.EMPTY;
    		validationMsg = uString.EMPTY;
    		Map<String, String> datafileds = new Map<String, String>();	
    		
	    	try{
	    		for(uRestController.FieldsDescribe describe : data.fieldsInfo){ 		    				    		
		    		if(requiredFields.get(describe.name) != null && String.isBlank(describe.value)){
		    			isValidated = false;
		    			validationMsg = (requiredFields.get(describe.name)).getLabel() + ' is required.';
		    			sMsg = validationMsg; 
		    			System.debug(LoggingLevel.INFO,  sMsg);					      						
						uRestController.setStatusCode(uRestController.BadRequest, sMsg);						
						return isValidated;
						break;
		    		}
	    		} 
	    	} 
	    	catch(Exception ex){
	    		validationMsg = ex.getMessage();
	    		System.debug(LoggingLevel.INFO,  ex.getMessage());
	    		isValidated = false;
	    	}
        	
        	return isValidated;
    }
    
    @HttpPut
    global static uRestController.GenericGetResponse doPut(uRestController.GenericGetResponse data) {    	
    	uRestController.GenericGetResponse obj = new uRestController.GenericGetResponse();
    	
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           obj.responseCode = uRestController.BadRequest;   
           return obj;
        }
        
        if(String.isBlank(data.id)) {
            uRestController.setStatusCode(uRestController.PreconditionFailed, 'Id value is missing');
            obj.responseCode = uRestController.PreconditionFailed; 
			obj.responseMessage = 'Id value is missing';
            return obj;
        }
                
        try {
            Task sfTask = createTask(uRestController.getFSMembers(fsCall, objectName), data); 
            if(sfTask == null) {
                return null;
            }
            
            try {
                Task original = [Select OwnerId from Task where Id = :data.id];
                
                if(data.owner != null && data.owner.id != null && data.owner.id != UserInfo.getUserId()) {
                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an call created by someone else.');
                    obj.responseCode = uRestController.PreconditionFailed; 
					obj.responseMessage = 'You are not have the permission to edit an task created by someone else.';
                    return obj;
                }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                obj.responseCode = uRestController.NotFound;
                return obj;
            }
        
            update sfTask;
            uRestController.setStatusCode(uRestController.OK);
            obj.responseCode = uRestController.OK;
            return obj.RecordItem(sfTask.Id, fsCall, objectLabel);
            
        } catch (System.DmlException ex) {
	        	System.debug(LoggingLevel.ERROR, ex);
	            uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
	            obj.responseCode = uRestController.BadRequest; 
	            obj.responseMessage = ex.getDmlMessage(0);  
	    } 
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotModified, e.getMessage());
            obj.responseCode = uRestController.NotModified; 
			obj.responseMessage = e.getMessage();
        }
        
        return obj;
    }
        
     /**
    * Patch is designed as an auto close shortcut mechinism for the Task object.  When a Task is sent VIA
    * http patch the client assumes they want to set the object to a closed status using the business logic
    * rather than using http put.
    */
    @HttpPatch
    global static void doPatch(List<String> data) {
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return;
        }
        
        Set<String> taskIds = new Set<String>(data);
        
        try {
            List<Task> sfTasks = [Select Id, OwnerId, Status from Task where Id in :taskIds];
            if(sfTasks.size() < 1) {
                return;
            }
            
            try {
                for(Task t : sfTasks) {
	                if(t.OwnerId != UserInfo.getUserId()) {
	                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an call created by someone else.');
	                    return;
	                }
                }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                return;
            }
            
            TaskStatus closedStatus = [Select MasterLabel, IsClosed from TaskStatus where IsClosed = true limit 1];
            for(Task sfTask: sfTasks) {
                sfTask.Status = closedStatus.MasterLabel;
            }
            
            update sfTasks;
                        
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotModified, e.getMessage());
        }
    }
    
    @HttpDelete
    global static void doDelete() {
    	Set<String> taskIds = new Set<String>();
    	
    	if(!String.IsBlank(uRestController.getParameterValue('ids'))) {
    		taskIds.addAll(uRestController.getParameterValue('ids').split(';'));
    	}
    	
        taskIds.add(uRestController.objectId);
        
        List<Task> tasks = [Select Id, OwnerId from Task where Id in :taskIds];
        
        if(tasks.size() < 1) {
            uRestController.setStatusCode(uRestController.NotFound);
            return;
        }
        
        for(Task t : tasks) {
            if(t.OwnerId != UserInfo.getUserId()) {
                uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an call created by someone else.');
                return;
            }
        }
        
        delete tasks;
        uRestController.setStatusCode(uRestController.OK);
    }

}