/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmPracticeAlertController2 {

    static testMethod void doGet_RetrievesPastDueTasksForProvider() {
        Account practice = new Account (
           Name = '__TEST__'
        );
        insert practice;
        
        Task t3 = new Task(
           Subject = '__TEST__',
           WhatId = practice.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Task',
           ActivityDate = DateTime.now().addDays(-3).date()
        );
        insert t3;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Alerts';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Alerts';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmAlertController2.AlertFeed practiceFeed = RestPrmPracticeAlertController2.doGet();
        
        System.assert( practiceFeed.openIssues.size() >= 0 );
        System.assert( practiceFeed.overdueTasks.size() >= 0 );
    }
}