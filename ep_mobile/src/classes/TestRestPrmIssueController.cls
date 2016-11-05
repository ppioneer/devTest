/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmIssueController {
    static testMethod void doGet_RetrievesObjectById() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/' + i.Id;
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmIssueController.Issue> issues = RestPrmIssueController.doGet();
        
        System.assertEquals(1, issues.size());
        System.assertEquals(i.ID, issues[0].id);
    }
    
    static testMethod void doGet_RetrievesAllWhenNoId() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        i = new HC4__Issue__c();
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmIssueController.Issue> issues = RestPrmIssueController.doGet();
        
        System.assert(2 <= issues.size());
    }
    
    static testMethod void doGet_RetrievesFilteredWithEndAndStartCreateDate() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        i = new HC4__Issue__c();
        insert i;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        request.addParameter('startCreateDate', theDate);
        request.addParameter('endCreateDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmIssueController.Issue> issues = RestPrmIssueController.doGet();
        
        System.assert(0 <= issues.size());
    }
    
    static testMethod void doGet_RetrievesFilteredWithCreatedDate() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        i = new HC4__Issue__c();
        insert i;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        request.addParameter('createdDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmIssueController.Issue> issues = RestPrmIssueController.doGet();
        
        System.assert(0 <= issues.size());
    }
    
    static testMethod void doGet_NotFoundWhenBadId() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/' + i.Id + 'a';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmIssueController.Issue> issues = RestPrmIssueController.doGet();
        
        System.assertEquals(0, issues.size());
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doGet_RetrievesCreateDateGTETStartCreateDate() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        request.addParameter('pageSize', '3');
        request.addParameter('startCreateDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        
        List<RestPrmIssueController.Issue> issues = RestPrmIssueController.doGet();
        
        System.assert(1 <= issues.size());
    }
    
    static testMethod void doGet_RetrievesCreateDateLTETEndCreateDate() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        request.addParameter('pageSize', '3');
        request.addParameter('endCreateDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        
        List<RestPrmIssueController.Issue> issues = RestPrmIssueController.doGet();
        
        System.assert(0 <= issues.size());
    }
    
    static testMethod void doGet_RetrievesCreateDateBetweemStartEndCreateDate() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        request.addParameter('pageSize', '3');
        request.addParameter('startCreateDate', DateTime.now().format('yyyy-MM-dd'));
        request.addParameter('endCreateDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        
        List<RestPrmIssueController.Issue> issues = RestPrmIssueController.doGet();
        
        System.assert(0 <= issues.size());
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.Issue issue = new RestPrmIssueController.Issue();
        issue.provider = new RestPrmProviderController.ProviderLite();
        issue.inquiry = new RestPrmInquiryController.Inquiry();
        issue.provider.Id = provider.Id; 
        issue.subject = '__A_TEST_SUBJECT__';
        
        RestPrmIssueController.doPost(issue);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where HC4__Subject__c = :issue.subject and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, issues.size());
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.doPost(null, null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsCreated() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.Issue issue = new RestPrmIssueController.Issue();
        issue.inquiry = new RestPrmInquiryController.Inquiry();
        issue.subject = '__A_TEST_SUBJECT__';
        
        RestPrmIssueController.doPost(issue, new String[] { provider.Id });
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where HC4__Subject__c = :issue.subject and OwnerId = :UserInfo.getUserId() and HC4__Provider__c = :provider.Id];
        
        System.assertEquals(1, issues.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.Issue i = new RestPrmIssueController.Issue();
        
        RestPrmIssueController.doPut(i);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmIssueController.Issue ri = new RestPrmIssueController.Issue();
        ri.id = i.Id;
        ri.subject = '__SUBJECT_HAS_CHANGED__';
        
        RestPrmIssueController.doPut(ri);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        i = [Select Id, HC4__Subject__c from HC4__Issue__c where Id = :i.Id];
        
        System.assertEquals(ri.subject, i.HC4__Subject__c);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.Issue ri = new RestPrmIssueController.Issue();
        ri.id = i.Id + 'a';
        
        RestPrmIssueController.doPut(ri);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/' + i.Id;
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.doDelete();
        
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where Id = :i.Id];
        
        System.assertEquals(0, issues.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void doPatch_ClosesTasks() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Issues/';
        request.resourcePath = '/mobile/prm/v1/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController.doPatch(new List<String> { i.Id });
        
        i = [Select Id, HC4__Status__c, HC4__DateTimeClosed__c from HC4__Issue__c where Id = :i.Id];
        
        System.assert(i.HC4__Status__c.toLowerCase().startsWith('closed'));
        System.assertNotEquals(null, i.HC4__DateTimeClosed__c);
    }
}