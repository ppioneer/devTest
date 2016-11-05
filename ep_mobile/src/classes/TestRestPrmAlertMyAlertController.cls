/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmAlertMyAlertController {

    static testMethod void doGet_RetrievesMyAlerts() {
		
		Contact provider = new Contact(
           FirstName = '__JOHN__',
           LastName = ' __DOE__'
        );
        
        insert provider;
        
        Lead patient = new Lead(
           FirstName = '__JOHN__',
           LastName = ' __DOE__'
        );
        
        insert patient;
        
        Task t = new Task(
           Subject = 'Call',
           OwnerId = UserInfo.getUserId(),
           Type = 'Call',
           ActivityDate = Date.today().addDays(-2)
        );
        insert t;
        
        Task t3 = new Task(
           Subject = '__TEST__',
           OwnerId = UserInfo.getUserId(),
           Type = 'Task'
        );
        insert t3;
        
        HC4__Inquiry__c inquiry = new HC4__Inquiry__c();
        
        insert inquiry;
        
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Patient__c = patient.Id,
           HC4__Provider__c = provider.Id,
           HC4__Inquiry__c = inquiry.Id,
           OwnerId = UserInfo.getUserId(),
           HC4__Priority__c = 'High'
        );
        
        insert issue;
        
        HC4__Issue__c issue1 = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Patient__c = patient.Id,
           HC4__Provider__c = provider.Id,
           HC4__Inquiry__c = inquiry.Id,
           OwnerId = UserInfo.getUserId(),
           HC4__Status__c = 'Escalated'
        );
        
        insert issue1; 
        
        RestPrmAlertController.AlertFeed alerts = new RestPrmAlertController.AlertFeed();       
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Alerts/myAlerts';
        request.resourcePath = '/mobile/prm/v2/Alerts/myAlerts';
        request.addParameter('pageSize', '1');
        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
          
        alerts = RestPrmAlertMyAlertController.doGet();        
        
        System.assert( alerts.overdueTasks.size() >= 0);
        System.assert( alerts.openIssues.size() >= 0); 
	}
}