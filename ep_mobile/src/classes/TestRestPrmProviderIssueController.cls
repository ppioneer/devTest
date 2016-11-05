/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderIssueController {
    
    static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Provider__c = provider.Id
        );
        
        insert issue;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Issues';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmIssueController.Issue> issues = RestPrmProviderIssueController.doGet();
        
        System.assertEquals(1, issues.size());
        System.assertEquals(issue.ID, issues[0].id);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderIssueController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.Issue issue = new RestPrmIssueController.Issue();
        issue.subject = '__A_TEST_SUBJECT__';
        
        RestPrmProviderIssueController.doPost(issue);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where HC4__Subject__c = :issue.subject and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, issues.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderIssueController.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.Issue issue = new RestPrmIssueController.Issue();
        issue.provider = new RestPrmProviderController.ProviderLite();
        issue.provider.Id = provider.Id;
        
        RestPrmProviderIssueController.doPut(issue);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Provider__c = provider.Id
        );
        
        insert issue;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmIssueController.Issue ri = new RestPrmIssueController.Issue();
        ri.id = issue.Id;
        ri.subject = '__TEST_TITLE_CHANGED__';
        ri.provider = new RestPrmProviderController.ProviderLite();
        ri.provider.id = issue.HC4__Provider__c;
        
        RestPrmProviderIssueController.doPut(ri);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        issue = [Select Id, HC4__Subject__c from HC4__Issue__c where Id = :issue.Id];
        
        System.assertEquals(ri.subject, issue.HC4__Subject__c);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Provider__c = provider.Id
        );
        
        insert issue;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.Issue ri = new RestPrmIssueController.Issue();
        ri.id = issue.Id + 'a';
        
        RestPrmProviderIssueController.doPut(ri);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderIssueController.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Provider__c = provider.Id
        );
        
        insert issue;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Issues/' + issue.Id;
        request.resourcePath = '/mobile/prm/v1/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderIssueController.doDelete();
        
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where Id = :issue.Id];
        
        System.assertEquals(0, issues.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}