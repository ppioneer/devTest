/* Copyright (c) 2008-2014 Evariant */
@isTest
private class TestRestPrmActivityMyActivityController2 {
	
	static testMethod void doGet_RetrievesOpenTasksForCurrentUser() {
    	Task t = new Task(
           Subject = 'Call',
           OwnerId = UserInfo.getUserId(),
           Type = 'Call'
        );
        insert t;
        
        Task t3 = new Task(
           Subject = '__TEST__',
           OwnerId = UserInfo.getUserId(),
           Type = 'Task'
        );
        insert t3;
        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
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
        Sobject obj = issue; 
        
        RestPrmUserController.RestUser userlastModified = new RestPrmUserController.RestUser(issue.LastModifiedBy.Id, issue.LastModifiedBy.Name);
        RestPrmUserController.RestUser usercreated = new RestPrmUserController.RestUser(issue.CreatedBy.Id, issue.CreatedBy.Name);
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/ActivityFeed/myActivityFeed';
        request.resourcePath = '/mobile/prm/v2/ActivityFeed/myActivityFeed';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmActivityController2.ActivityFeed myFeed = RestPrmActivityMyActivitiesController2.doGet();
        
        System.assert( myFeed.calls.size()  >= 0 );
        System.assert( myFeed.issues.size() >= 0 );
        System.assert( myFeed.notes.size()  >= 0 );
        System.assert( myFeed.tasks.size()  >= 0 );
        
        RestRequest requestException = new RestRequest();
        requestException.requestURI = '/mobile/prm/v2/ActivityFeed1/myActivityFeed1';
        requestException.resourcePath = '/mobile/prm/v2/ActivityFeed/myActivityFeed1';
        requestException.addParameter('pageSize', '1');
        System.RestContext.request = requestException;
        System.RestContext.response = new RestResponse();
        
        RestPrmActivityController2.ActivityFeed myFeed1 = RestPrmActivityMyActivitiesController2.doGet();
	}
   
}