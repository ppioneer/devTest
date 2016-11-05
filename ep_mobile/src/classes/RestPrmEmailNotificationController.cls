/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/EmailNotification/*')
global with sharing class RestPrmEmailNotificationController {
	
	@HttpGet
    global static RestPrmEmailNotificationController.EmailNotification doGet() {    	 
    	String objectId = uRestController.objectId;
    	RestPrmEmailNotificationController.EmailNotification response = new RestPrmEmailNotificationController.EmailNotification(); 
    	uRestController.GenericGetResponse obj = new uRestController.GenericGetResponse(); 
    	   	
    	if(!String.isBlank(objectId)){
    		ID recId = objectId;					
			Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{recId.getSObjectType().getDescribe().getName()});	
			String objectName = results[0].getName();
			String objectLabel = uString.EMPTY;
			response.id = objectId;
			
			if(!String.isBlank(uRestController.getParameterValue('objectType'))){
				objectLabel = uRestController.getParameterValue('objectType'); 
			}
			
			String subject = 'New ' + objectLabel.toUpperCase() + ' created';
			
			if(objectLabel.toLowerCase() == 'issue'){
				HC4__Issue__c issue = [Select HC4__Provider__r.Name, HC4__Provider__c From HC4__Issue__c WHERE ID =: objectId];
				response.providerName =  issue.HC4__Provider__r.Name;
				response.providerId = issue.HC4__Provider__c; 
				subject += ' for Provider ' + response.providerName;    
			}
			if(objectLabel.toLowerCase() == 'task' || objectLabel.toLowerCase() == 'call'){
				Task task = [Select Who.Name, WhoId, What.Name, WhatId From Task WHERE ID =: objectId];
				
				if(!String.isBlank(task.WhoId)){
					response.providerId = task.WhoId; 
					response.providerName = task.Who.Name;
					subject += ' for Provider ' + response.providerName;    
				}
				
				if(!String.isBlank(task.WhatId)){
					response.practiceId = task.WhatId; 
					response.practiceName = task.What.Name;
					subject += ' for Practice ' + response.practiceName;   
				}
			}
			response.comments = emailBodyContent(objectId, objectName); 
			response.objectType = objectName;
			response.objectLabel = objectLabel;
			response.subject = subject;  	
			response.responseCode =  uRestController.OK;
    	}
    	else{
    		response.responseCode =  uRestController.NotFound;
    	}
    	
        return response; 
    }
	
	
	@HttpPost    
    global static RestPrmEmailNotificationController.EmailNotification doPost(RestPrmEmailNotificationController.EmailNotification data) {
    	RestPrmEmailNotificationController.EmailNotification response = new RestPrmEmailNotificationController.EmailNotification();
        
        try {
            return RestPrmEmailNotificationController.NotifyEmail(data);
            
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            uRestController.setStatusCode(uRestController.BadRequest, formatException(e.getMessage()));
            response.responseMessage = formatException(e.getMessage()); 
			response.responseCode = uRestController.BadRequest;
        }
        
        return response;
    }
    
    public static RestPrmEmailNotificationController.EmailNotification NotifyEmail(RestPrmEmailNotificationController.EmailNotification data) {
    	
    	RestPrmEmailNotificationController.EmailNotification response = new RestPrmEmailNotificationController.EmailNotification();
    	String[] toAddress = new String[] {};
        List<String> toCCAddress = new List<String>();
        String[] sendAddress = new String[] {};
        String subject = uString.EMPTY;
		String additionalToEmail = uString.EMPTY;
		String additionalCCEmail = uString.EMPTY;
		
		subject = 'New ' + data.objectLabel.toUpperCase() + ' created';
		
        for(String toEmail :  data.toAddresses){
        	if(!String.isBlank(toEmail)){
        		additionalToEmail += toEmail + ';'; 
	        	toAddress.add(toEmail);
	        	sendAddress.add(toEmail);
        	}
        }
        
        for(String ccEmail :  data.ccAddresses){
        	if(!String.isBlank(ccEmail)){
        		additionalCCEmail +=  ccEmail + ';';
        		toCCAddress.add(ccEmail);
        		sendAddress.add(ccEmail);
        	}
        }
        
        response.toAddresses = data.toAddresses;
        response.ccAddresses = data.ccAddresses;
        response.subject =  subject; 
        response.providerId = data.providerId;
        response.practiceId = data.practiceId; 
        response.objectType = data.objectLabel;
        response.providerName = (!String.isBlank(data.providerName)? data.providerName : uString.EMPTY); 
        response.practiceName = (!String.isBlank(data.practiceName)? data.practiceName : uString.EMPTY);   
        response.id = data.id;
        
        if(sendAddress.isEmpty()){
        	response.responseMessage = 'To/CC Address is required'; 
			response.responseCode = uRestController.PreconditionFailed;
			uRestController.setStatusCode(uRestController.PreconditionFailed);
            return response;
        }
        
        //Get Email Domain
        String emailDomain = uString.Empty; 
        List<sObject> config = new List<sObject>();
        Boolean isDevOrg = false; 
        try{
        	config = Database.query('SELECT Name, HC4M__EmailNotifyDomain__c From HC4M__PRMConfig__c');	 
        }
        catch(System.QueryException ex){
        		isDevOrg = true;
        		config = Database.query('SELECT Name, EmailNotifyDomain__c From PRMConfig__c');
        }
        
        if(config != null && !config.isEmpty()){
        		if(isDevOrg){
        			emailDomain = String.valueOf(config[0].get('EmailNotifyDomain__c'));	
        		}
        		else{
        			emailDomain = String.valueOf(config[0].get('HC4M__EmailNotifyDomain__c'));
        		} 
        }
        if(!sendAddress.isEmpty()){
        	if(!String.isBlank(emailDomain) &&  emailDomain.toLowerCase() != 'all'){
        		for(String validEmail : sendAddress){ 
        			if(isValidEmailDomain(validEmail, emailDomain.split(','))){
        				response.responseMessage = 'Sending email to ' + validEmail + ' is restricted. Please contact System Administrator. '; 
						response.responseCode = uRestController.Forbidden;
						uRestController.setStatusCode(uRestController.Forbidden);
	            		return response;
        			}
	        	}
        	}
        }
        
        //String[] toAddresses = new String[] {}; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Task oTask = new Task();
        mail.setToAddresses(sendAddress);        
        mail.setSaveAsActivity(false);
        try{
	        if(!String.isEmpty(data.providerId)){
	        	oTask.WhoId = data.providerId; 
	        	subject += ' for Provider ' + data.providerName; 
	        }
	        
	        if(!String.isEmpty(data.practiceId)){
	        	oTask.WhatId = data.practiceId; 	        	
	        	subject += ' for Practice ' + data.practiceName;
	        }         
			
			mail.setSenderDisplayName(UserInfo.getName());
	        mail.setSubject(subject); 
	        mail.setPlainTextBody(data.comments);
	        Messaging.SendEmailResult[] results; 
        	if(!Test.isRunningTest()) {
	            results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
	            if (results.get(0).isSuccess()) {
	            	response.responseCode = uRestController.OK;
					uRestController.setStatusCode(uRestController.OK);
					
					//Create A Task with status completed
					String taskDesc = 'Additional To: ' + additionalToEmail + '\n'; 
					taskDesc += 'CC: '+ additionalCCEmail + '\n'; 
					taskDesc += 'BCC: '+ '\n'; 
					taskDesc += 'Attachment' + '\n\n';  
					taskDesc += 'Subject: ' + subject + '\n\n'; 
					taskDesc += 'Body:' + data.comments + '\n\n';
					
					User  oUser = [select id, Signature From User u where id =: UserInfo.getUserId() ];
		
					if(!String.isBlank(oUser.Signature)){
						taskDesc += oUser.Signature; 
					}
					  					
					oTask.Description = taskDesc; 
					oTask.Subject = 'Email: ' + subject ;
					String prmActivity = uRestController.getPRMActivityAPIName('Task');
    				oTask.put(prmActivity, true); 
    				oTask.Status = 'Completed';
    				oTask.Priority = 'Normal';
    				oTask.ActivityDate = Date.today();
    				
    				insert oTask;
				}
				else{
				    response.responseCode = uRestController.BadRequest;
				    response.responseMessage = formatException(results.get(0).getErrors()[0].getMessage());
					uRestController.setStatusCode(uRestController.BadRequest);
				}
	        }
        }
        catch(EmailException ex){
        	System.debug(LoggingLevel.ERROR, ex.getMessage());
        	uRestController.setStatusCode(uRestController.InternalServerError, formatException(ex.getMessage())); 
        	response.responseMessage = formatException(ex.getMessage()); 
			response.responseCode = uRestController.InternalServerError; 
			throw ex;        	
        }
        catch(Exception ex){
        	System.debug(LoggingLevel.ERROR, ex.getMessage());
        	uRestController.setStatusCode(uRestController.BadRequest, formatException(ex.getMessage())); 
        	response.responseMessage = formatException(ex.getMessage()); 
			response.responseCode = uRestController.BadRequest; 
			throw ex;        	
        }
        
        return response;
    }
    
    public static Boolean isValidEmailDomain(String emailId, List<String> domains) {    	
    	Boolean flag = false;
    	Integer iCount = 0; 
    	for(String domain : Domains){
    		if(emailId.contains(domain)){
    			iCount++;			
    		}
    	} 
    	   	
    	if(iCount == 0) flag = true;
    	
    	return flag;
    } 
    
    public static String emailBodyContent(String Id, String objectName) {
    	    	
		uRestController.GenericGetResponse obj = new uRestController.GenericGetResponse();
		uRestController.GenericGetResponse data = null;  
		String body = uString.EMPTY; 
		String objectLabel = uString.EMPTY;
		Sobject dynamicObject = null;  
		
		if(!String.IsBlank(uRestController.getParameterValue('objectType'))) {
			objectLabel = uRestController.getParameterValue('objectType'); 
		}
		
		if(objectLabel == 'issue'){
			data = obj.RecordItem(Id, uRestController.getFieldSetName(objectName, Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label), objectLabel);	
		}
		if(objectLabel == 'task'){
			data = obj.RecordItem(Id, uRestController.getFieldSetName(objectName, Schema.SObjectType.Task.fieldSets.EditTask.Label), objectLabel);
		}
		if(objectLabel == 'call'){
			data = obj.RecordItem(Id, uRestController.getFieldSetName(objectName, Schema.SObjectType.Task.fieldSets.EditCall.Label), objectLabel);
		}
		
		String SobjectApiName = objectName;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
 
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
 		
        String query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE ID =: Id';
 
        Sobject emailobject = Database.query(query); 
		
		body += '\n';
		 
		for(uRestController.FieldsDescribe describe : data.fieldsInfo){
			if(describe.fieldType.ToUpperCase() == 'REFERENCE'){
				body += describe.label + ' : ' + ((describe.parentName != null)? describe.parentName : uString.EMPTY) + ' \n\n' ;  
			}
			else if(describe.fieldType.ToUpperCase() == 'BOOLEAN'){
				if(Boolean.valueOf(describe.value)){
					body += describe.label + ' : ' + 'Yes' + ' \n\n' ;
				}
				else{
					body += describe.label + ' : ' + 'No' + ' \n\n' ;
				}				   
			}
			else if(describe.fieldType.ToUpperCase() == 'DATE' || describe.fieldType.ToUpperCase() == 'DATETIME'){			
				body += describe.label + ' : ';
				String dateFormat = uString.Empty;
				if(describe.value != null && !String.isBlank(describe.value)){
					if(describe.fieldType.ToUpperCase() == 'DATETIME'){
						DateTime dt = (DateTime)(emailobject.get(describe.name));
						dateFormat = dt.formatLong();	
					}
					else{
						Date dt1 = 	uRestController.getDate(describe.value);					
						dateFormat = dt1.month() + '/' + dt1.day() + '/' + dt1.year();
					}
				}
				body += dateFormat + '\n\n';
			}
			else{
				body += describe.label + ' : ' + ((describe.value != null)? describe.value : uString.EMPTY) + ' \n\n' ;
			}
		}
		
		return body; 
    }
    
    public static String formatException(String exMessage){
    	String sTemp = exMessage; 
		String result = uString.Empty; 
		try{
			if(sTemp.contains('LIMIT_EXCEEDED,')){
				result = 'Sending email limit exceeded. Please contact System Administrator.';
			}
			else if(sTemp.contains('INVALID_EMAIL_ADDRESS')){
				result = 'Please enter a valid email address.';
			}
			else if(sTemp.contains('NO_MASS_MAIL_PERMISSION')){
				result = 'The email functionality is not enabled. Please contact your System Administrator.';
			}
			else
				result = sTemp;
		}
		catch(Exception ex){
			return result;
		}
		return result;
    }    
    
    global class EmailNotification {
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY : this.id; } set; }
    	public String providerId { get { return String.isBlank(this.providerId) ? uString.EMPTY : this.providerId; } set; }
    	public String providerName { get { return String.isBlank(this.providerName) ? uString.EMPTY : this.providerName; } set; }
    	public String practiceId { get { return String.isBlank(this.practiceId) ? uString.EMPTY : this.practiceId; } set; }
    	public String practiceName { get { return String.isBlank(this.practiceName) ? uString.EMPTY : this.practiceName; } set; }
    	public String objectType { get { return String.isBlank(this.objectType) ? uString.EMPTY : this.objectType; } set; }
    	public String objectLabel { get { return String.isBlank(this.objectLabel) ? uString.EMPTY : this.objectLabel; } set; }
    	public String subject { get { return String.isBlank(this.subject) ? uString.EMPTY : this.subject; } set; }
    	public List<String> toAddresses { get; set; }
    	public List<String> ccAddresses { get; set; }
        public String comments { get { return String.isBlank(this.comments) ? uString.EMPTY : this.comments; } set; }
        public uRestController.StatusCode responseCode { get; set; }
    	public String responseMessage { get { return String.isBlank(this.responseMessage) ? uString.EMPTY : this.responseMessage; } set; }
    }

}