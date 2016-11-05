/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Issues/*')
global with sharing class RestPrmIssueController2 {
	
	
    public static final String objectName = 'HC4__Issue__c';
    public static final String fsIssue = uRestController.getFieldSetName(objectName, Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label); 
    public static final String objectLabel = 'Issue';
    global static string validationMsg {get;set;}
	
	@HttpGet
    global static List<uRestController.GenericGetResponse> doGet() {    	
    	String objectId = uRestController.objectId;
    	uRestController.GenericGetResponse obj = new uRestController.GenericGetResponse(objectName); 
    	List<uRestController.GenericGetResponse> response = new List<uRestController.GenericGetResponse>();
    	
    	if(!String.isBlank(objectId)){
    		response.add(obj.RecordItem(objectId, fsIssue, objectLabel));
    	}
    	else{    		 
    		response.add(uRestController.getView(objectName, fsIssue, objectLabel)); 
    	}
    	
        return response; 
    }
    
    @HttpPost
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data, String objectType, String[] ids) {
    	String relationName = 'HC4__Provider__c'; //Adding issue is to Practice not supported. Need changes if scope of adding Issues to Practice. 
    	
    	return RestPrmIssueController2.doPost(data, ids, relationName);	
    }
    
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data, String[] Ids, String relationType) {
    	uRestController.GenericGetResponse response = new uRestController.GenericGetResponse();    	
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           response.responseCode =  uRestController.BadRequest;  
           return response;
        }
        
        if(Ids == null) {
            return RestPrmIssueController2.doPost(data);
        } 
                
        try {
            List<HC4__Issue__c> issues = new List<HC4__Issue__c>();
            
            for(String providerId : Ids) {            	                
                HC4__Issue__c sfIssue = createIssue(uRestController.getFSMembers(fsIssue, objectName), data);
                
                if(String.isBlank(validationMsg) && sfIssue == null) {
                    return null;
                }
                
                sfIssue.put(relationType, providerId); //Adding providers to the data object
                
                if(sfIssue == null) {
                    return null;
                }
                
                issues.add(sfIssue);
            }
            
            insert issues;            
            uRestController.setStatusCode(uRestController.Created);            
        }
        catch (System.DmlException ex) {
	        	System.debug(LoggingLevel.ERROR, ex);
	            uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
	            response.responseCode = uRestController.BadRequest; 
	            response.responseMessage = formatException(ex.getDmlMessage(0));  
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
        
        HC4__Issue__c sfIssue = createIssue(uRestController.getFSMembers(fsIssue, objectName), data);
        if(sfIssue == null) {
            return null;
        }
        
        try {
	            if(sfIssue != null && String.isBlank(validationMsg)){
	    			insert sfIssue;		        	        	                
			        uRestController.setStatusCode(uRestController.Created);
			        response  = obj.RecordItem(sfIssue.Id, fsIssue, objectLabel);
				}
				else{
					uRestController.setStatusCode(uRestController.BadRequest, validationMsg);
					response.responseCode = uRestController.BadRequest;
					response.responseMessage = validationMsg; 
					return response;
				}
	            uRestController.setLocationHeader(sfIssue.Id);
	            uRestController.setStatusCode(uRestController.Created);
            
        }
        catch (System.DmlException ex) {
	        	System.debug(LoggingLevel.ERROR, ex);
	            uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
	            response.responseCode = uRestController.BadRequest; 
	            response.responseMessage = formatException(ex.getDmlMessage(0));  
	    } 
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
            response.responseCode = uRestController.Conflict;
			response.responseMessage = e.getMessage();
        }
                
        
        return response;
    }
    
        
    /*
     * Dynamically Assign the Issue Fields Information to Task sObect    
    */
    public static HC4__Issue__c createIssue(Map<String, Schema.FieldSetMember> fsMap, uRestController.GenericGetResponse data){    		
	    	uRestController.GenericGetResponse response = new uRestController.GenericGetResponse();
	    	uRestController.GenericGetResponse obj = new uRestController.GenericGetResponse(objectName);
    	
    		HC4__Issue__c sfIssue = new HC4__Issue__c();
    		String prmActivity = uRestController.getPRMActivityAPIName('HC4__Issue__c');
    		sfIssue.put(prmActivity, true);   		
    		try{
    			
    			if(data == null) {
		           uRestController.setStatusCode(uRestController.BadRequest);   
		           return null;
		        }
    			
    			if(!String.isBlank(data.id)) {
	            	sfIssue.put('Id', data.id);
	        	} 
    			
    			if(isIssueValidated(uRestController.getRequiredFields(fsIssue, objectName), data)){    				
	    			for(uRestController.FieldsDescribe describe : data.fieldsInfo){ 
			    			if(fsMap.get(describe.name) != null){		    				
			    				if((fsMap.get(describe.name)).getType() == Schema.DisplayType.Double || (fsMap.get(describe.name)).getType() == Schema.DisplayType.Percent || (fsMap.get(describe.name)).getType() == Schema.DisplayType.CURRENCY){
			    					if(!String.isBlank(describe.value)){
				    					Decimal dclValue = Decimal.valueOf(describe.value);
				    					sfIssue.put(describe.name,dclValue);
			    					}
			    				}
			    				else if((fsMap.get(describe.name)).getType() == Schema.DisplayType.Integer){
			    					if(!String.isBlank(describe.value)){
				    					Integer dclValue = Integer.valueOf(describe.value);
				    					sfIssue.put(describe.name, dclValue);
			    					}
			    				}
			    				else if((fsMap.get(describe.name)).getType() == Schema.DisplayType.DateTime){
			    					    if(!String.isBlank(describe.value)){
			    					    	sfIssue.put(describe.name, uRestController.getDateTime(describe.value)); 
			    					    }
			    					    else{
			    					    	if(!describe.name.contains('DateTimeOpened__c')){ 
                                            	sfIssue.put(describe.name, null);
                                            }
			    					    }			    									    						
			    				}
			    				else if((fsMap.get(describe.name)).getType() == Schema.DisplayType.Date){			    						
			    					    if(!String.isBlank(describe.value)){			    					    	
			    					    	sfIssue.put(describe.name, uRestController.getDate(describe.value));
			    					    }
			    					    else{
			    					    	sfIssue.put(describe.name, null);
			    					    }			    									    						
			    				}
			    				else if((fsMap.get(describe.name)).getType() == Schema.DisplayType.Boolean){	
			    					sfIssue.put(describe.name, Boolean.valueOf(describe.value));
								}
			    				else
			    					sfIssue.put(describe.name,describe.value);
			    			}
			    	}			    
	    		}
	    		else 
	    			return new HC4__Issue__c();  		
    		}
    		catch(Exception ex){
    			System.debug(LoggingLevel.Error,  ex.getMessage());
    			validationMsg = ex.getMessage(); 
    			uRestController.setStatusCode(uRestController.BadRequest, validationMsg);
    			throw ex;
    		}		         	
        	return sfIssue;
    }
    
    /*
     * Validate Issue & filedset required fileds    
    */
    public static Boolean isIssueValidated(Map<String, Schema.FieldSetMember> requiredFields, uRestController.GenericGetResponse data){
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
    	uRestController.GenericGetResponse obj = new uRestController.GenericGetResponse(objectName);
    	
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
            HC4__Issue__c sfIssue = createIssue(uRestController.getFSMembers(fsIssue, objectName), data);
            if(sfIssue == null) {
                return null;
            }
            
            try {
                HC4__Issue__c original = [Select OwnerId from HC4__Issue__c where Id = :data.id];
                
                if(data.owner != null && data.owner.id != null && data.owner.id != UserInfo.getUserId()) {
                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an issue created by someone else.');
                    obj.responseCode = uRestController.Forbidden; 
            		obj.responseMessage = 'You are not have the permission to edit an issue created by someone else.';
                    return obj;
                }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                obj.responseCode = uRestController.NotFound; 
            	obj.responseMessage = e.getMessage();
                return obj;
            }
                    
            update sfIssue;
            uRestController.setStatusCode(uRestController.OK);
            return obj.RecordItem(sfIssue.Id, fsIssue, objectLabel);
            
        }
        catch (System.DmlException ex) {
	        	System.debug(LoggingLevel.ERROR, ex);
	            uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
	            obj.responseCode = uRestController.BadRequest; 
	            obj.responseMessage = formatException(ex.getDmlMessage(0));  
	    } 
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotModified, e.getMessage());
            obj.responseCode = uRestController.NotFound; 
            obj.responseMessage = e.getMessage();
        }
        
        
        return obj;
    }
    
    @HttpPatch
    global static void doPatch(List<String> data) {
    	
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return;
        }
        
        Set<String> issueIds = new Set<String>(data);                
        try {
            List<HC4__Issue__c> sfIssues = [Select Id, OwnerId, HC4__Status__c, HC4__DateTimeClosed__c From HC4__Issue__c where Id in :issueIds];
            if(sfIssues.size() < 1) {
                return;
            }
            
            try {
               for(HC4__Issue__c i : sfIssues) {
               	    if(i.OwnerId != UserInfo.getUserId()) {
	                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an issue created by someone else.');
	                    return;
	                }
               }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                return;
            }
            
            /** *******************
            * The following code block is copied from IssueClosedExtension class from HC4 package so the business
            * logic is the same.  HC4 package should be reconfigured to be global so the logic can stay there and be reused
            * by PRM mobile.
            ** *******************/
            List<String> closedStatusOptions = new List<String>();
            for(String s : HC4.uDescribe.getPicklistValues('HC4__Issue__c', 'HC4__Status__c')) {
                if(s.toLowerCase().startsWith('closed')) {
                    closedStatusOptions.add(s);
                }
            }
            
            if(closedStatusOptions.isEmpty()) {
                closedStatusOptions.add(uString.EMPTY);
            }
            for(HC4__Issue__c sfIssue : sfIssues) {         
	            if(sfIssue.HC4__DateTimeClosed__c == null) {
	                sfIssue.HC4__DateTimeClosed__c = DateTime.now();
	            }
	            if(sfIssue.HC4__Status__c != null && !sfIssue.HC4__Status__c.toLowerCase().startsWith('closed')) {
	                sfIssue.HC4__Status__c = 'Closed - Resolved'; 
	            }
            }
            /** -- End copied Code -- **/
            
            update sfIssues;
            
        }
        catch (System.DmlException ex) {
	        	System.debug(LoggingLevel.ERROR, ex);
            	uRestController.setStatusCode(uRestController.BadRequest, formatException(ex.getDmlMessage(0))); 
	    } 
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.BadRequest, e.getMessage());
        }
    }
    
    @HttpDelete
    global static void doDelete() {
        Set<String> issueIds = new Set<String>();
        
        if(!String.IsBlank(uRestController.getParameterValue('ids'))) {
            issueIds.addAll(uRestController.getParameterValue('ids').split(';'));
        }
        
        issueIds.add(uRestController.objectId);
        
        List<HC4__Issue__c> issues = [Select Id, OwnerId from HC4__Issue__c where Id in :issueIds];
        
        if(issues.size() < 1) {
            uRestController.setStatusCode(uRestController.NotFound);
            return;
        }
        
        for(HC4__Issue__c i : issues) {
            if(i.OwnerId != UserInfo.getUserId()) {
                uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an issue created by someone else.');
                return;
            }
        }
        
        delete issues;
        uRestController.setStatusCode(uRestController.OK);
    }
    
    public static String formatException(String exMessage){
    	String result = exMessage; 
		String sTemp = uString.Empty; 
		try{
			if(result.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
				sTemp = result.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
				return sTemp.split(':')[0];
			}
			else
				return result;
		}
		catch(Exception ex){
			return result;
		}
    }
}