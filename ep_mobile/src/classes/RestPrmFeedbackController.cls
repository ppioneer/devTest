/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Feedback')
global with sharing class RestPrmFeedbackController {
    @HttpPost    
    global static RestPrmFeedbackController.Feedback doPost(RestPrmFeedbackController.Feedback data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        try {
            return RestPrmFeedbackController.LogFeedback(data);
            
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
        }
        
        return null;
    }
    
    private static RestPrmFeedbackController.Feedback LogFeedback(RestPrmFeedbackController.Feedback data) {
    	if(String.isBlank(data.comments)) {
            uRestController.setStatusCode(uRestController.PreconditionFailed, 'Comments is required');
            return null;
        }
        
        String[] toAddresses = new String[] { 'GoFeedback@evariant.com' }; //mobiledev@evariant.com
        
        String body = 'About the user: \n';
        body += 'User Name: ' + UserInfo.getName() + '\n';
        body += 'User Id: ' + UserInfo.getUserId() + '\n';
        body += 'User Login Name: ' + UserInfo.getUserName() + '\n';
        body += 'User Profile: ' + [Select Name from Profile where Id = :UserInfo.getProfileId()].Name + '\n';
        body += 'User Email: ' + UserInfo.getUserEmail() + '\n';
        body += 'User Type: ' + UserInfo.getUserType() + '\n';
        body += 'User Organization Name: ' + UserInfo.getOrganizationName() + '\n';
        body += 'User Organization Id: ' + UserInfo.getOrganizationId() + ' \n';
        
        body += '\n';
        body += 'Comments:\n';
        body += data.comments;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject('Feedback provided for Prm Mobile');
        mail.setPlainTextBody(body);
        
        try{
        	if(!Test.isRunningTest()) {
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	        }
        }
        catch(EmailException ex){
        	System.debug(LoggingLevel.ERROR, ex.getMessage());
        	uRestController.setStatusCode(uRestController.InternalServerError, ex.getMessage());         	
        }
        
        return data;
    }
    
    global class Feedback {
        public String comments { get; set; }
    }
}