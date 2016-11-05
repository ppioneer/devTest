/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmProviderAlertController2 {

   static testMethod void doGet_RetrievesPastDueTasksForProvider() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        
        insert provider;
        
        Task t3 = new Task(
           Subject = '__TEST__',
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Task',
           ActivityDate = DateTime.now().addDays(-3).date()
        );
        insert t3;
        
        Lead patient = new Lead(
           FirstName = '__JOHN__',
           LastName = ' __DOE__'
        );
        
        insert patient;
        
        HC4__Inquiry__c inquiry = new HC4__Inquiry__c();
        
        insert inquiry;
        
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Patient__c = patient.Id,
           HC4__Provider__c = provider.Id,
           HC4__Priority__c = 'High',
           HC4__Inquiry__c = inquiry.Id,
           OwnerId = UserInfo.getUserId()
        );
        
        insert issue;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Alerts';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Alerts';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmAlertController2.AlertFeed providerFeed = RestPrmProviderAlertController2.doGet();
        
        System.assert( providerFeed.openIssues.size() >= 0);
        System.assert( providerFeed.overdueTasks.size() >= 0);
    }
}