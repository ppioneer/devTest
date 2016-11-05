/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private with sharing class TestRestPrmPracticeActivityController {
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
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/ActivityFeed';
        request.resourcePath = '/mobile/prm/v1/Practices/*/ActivityFeed';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmActivityController.ActivityFeed providerFeed = RestPrmPracticeActivityController.doGet();
        
        System.assert( 1 <= providerFeed.calls.size());
        System.assertEquals(0, providerFeed.issues.size());
        System.assert( 1 <= providerFeed.notes.size());
        System.assert( 1 <= providerFeed.tasks.size());
    }
}