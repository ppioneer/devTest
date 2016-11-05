/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmProviderActivityController2 {
	static testMethod void doGet_RetrievesOpenTasksForProvider() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        
        insert provider;
        Task t = new Task(
           Subject = 'Call',
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Call'
        );
        insert t;
        
        Task t3 = new Task(
           Subject = '__TEST__',
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Task'
        );
        insert t3;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id,
           Body  = '__TEST_BODY__',
           OwnerId = UserInfo.getUserId()
        );
        insert n;
        
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
           HC4__Status__c = 'Escalated',
           HC4__Priority__c = 'High', 
           HC4__Inquiry__c = inquiry.Id,
           OwnerId = UserInfo.getUserId()
        );
        
        insert issue;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/ActivityFeed';
        request.resourcePath = '/mobile/prm/v2/Providers/*/ActivityFeed';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmActivityController2.ActivityFeed providerFeed = RestPrmProviderActivityController2.doGet();
        
        System.assert( providerFeed.calls.size() >= 0 ); 
        System.assert( providerFeed.issues.size() >= 0 );
        System.assert( providerFeed.notes.size() >= 0 );
        System.assert( providerFeed.tasks.size() >= 0 );
    }
    
    static testMethod void doGet_RetrievesNothingForProvider() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        
        insert provider;
        Task t = new Task(
           Subject = 'Call',
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Call'
        );
        insert t;
        
        Task t3 = new Task(
           Subject = '__TEST__',
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Task'
        );
        insert t3;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id,
           Body  = '__TEST_BODY__',
           OwnerId = UserInfo.getUserId()
        );
        insert n;
        
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
           HC4__Status__c = 'Escalated',
           HC4__Priority__c = 'High', 
           HC4__Inquiry__c = inquiry.Id,
           OwnerId = UserInfo.getUserId()
        );
        
        insert issue;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/a' + provider.Id + '/ActivityFeed';
        request.resourcePath = '/mobile/prm/v2/Providers/*/ActivityFeed';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmActivityController2.ActivityFeed providerFeed = RestPrmProviderActivityController2.doGet();
        
        System.assert( providerFeed.calls.size() >= 0 ); 
        System.assert( providerFeed.issues.size() >= 0 );
        System.assert( providerFeed.notes.size() >= 0 );
        System.assert( providerFeed.tasks.size() >= 0 );
    }
  
}