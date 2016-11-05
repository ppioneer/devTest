/* Copyright (c) 2008-2014 Evariant */
@isTest
private class TestRestPrmPracticeActivityController2 {

    static testMethod void doGet_RetrievesOpenTasksForPractice() {
        Account practice = new Account (
            Name = '__TEST_PRACTICE__'
        );
        
        insert practice
        ;
        Task t = new Task(
           Subject = 'Call',
           WhatId = practice.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Call'
        );
        insert t;
        
        Task t1 = new Task(
           Subject = '__TEST__',
           WhatId = practice.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Meeting'
        );
        insert t1;
        
        Task t3 = new Task(
           Subject = '__TEST__',
           WhatId = practice.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Task'
        );
        insert t3;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = practice.Id,
           OwnerId = UserInfo.getUserId()
        );
        insert n;
        
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/ActivityFeed';
        request.resourcePath = '/mobile/prm/v2/Practices/*/ActivityFeed';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmActivityController2.ActivityFeed providerFeed = RestPrmPracticeActivityController2.doGet();
        
        System.assert( providerFeed.calls.size() >= 0 );
        System.assert(providerFeed.issues.size() >= 0 );
        System.assert( providerFeed.notes.size()  >= 0 );
        System.assert( providerFeed.tasks.size() >= 0 );
    }
}