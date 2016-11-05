/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderActivityController {
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
           HC4__Inquiry__c = inquiry.Id,
           OwnerId = UserInfo.getUserId()
        );
        
        insert issue;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/ActivityFeed';
        request.resourcePath = '/mobile/prm/v1/Providers/*/ActivityFeed';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmActivityController.ActivityFeed providerFeed = RestPrmProviderActivityController.doGet();
        
        System.assert( 1 <= providerFeed.calls.size()); 
        System.assert( 1 <= providerFeed.issues.size());
        System.assert( 1 <= providerFeed.notes.size());
        System.assert( 1 <= providerFeed.tasks.size());
    }
}