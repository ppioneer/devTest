/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmProviderIssueController2 {

   static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        
        insert issue;
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST456__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low', 
           HC4__Type__c = 'Complaint',          
           OwnerId = UserInfo.getUserId()
        );
        insert i;
        
        HC4__Issue__c i1 = new HC4__Issue__c(
           HC4__Subject__c = '__TEST123__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'Working',           
           HC4__Priority__c = 'Low',
           HC4__Type__c = 'Compliment',            
           OwnerId = UserInfo.getUserId()
        );
        insert i1;
        
        HC4__Issue__c i2 = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'High',
           HC4__Type__c = 'Inquiry',               
           OwnerId = UserInfo.getUserId()
        );
        insert i2;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues = RestPrmProviderIssueController2.doGet();
        
        System.assertEquals(1, issues.size());
        
        RestRequest requestProviderStatus = new RestRequest();
        requestProviderStatus.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        requestProviderStatus.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        requestProviderStatus.addParameter('pageSize', '1');
        requestProviderStatus.addParameter('status', 'New');
        System.RestContext.request = requestProviderStatus;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues1 = RestPrmProviderIssueController2.doGet();
        
        RestRequest requestpriority = new RestRequest();
        requestpriority.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        requestpriority.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        requestpriority.addParameter('pageSize', '1');
        requestpriority.addParameter('priority', 'High;Low');
        System.RestContext.request = requestpriority;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues2 = RestPrmProviderIssueController2.doGet();
        
        RestRequest requestType = new RestRequest();
        requestType.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        requestType.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        requestType.addParameter('pageSize', '1');
        requestType.addParameter('type', 'Complaint;Inquiry');
        System.RestContext.request = requestType;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues3 = RestPrmProviderIssueController2.doGet();
        
        RestRequest requestSubject = new RestRequest();
        requestSubject.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        requestSubject.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        requestSubject.addParameter('pageSize', '1');
        requestSubject.addParameter('q', 'TEST');
        System.RestContext.request = requestSubject;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues4 = RestPrmProviderIssueController2.doGet();
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderIssueController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse issue = new uRestController.GenericGetResponse();
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Subject__c', '__A_TEST_SUBJECT__'));     
        
        RestPrmProviderIssueController2.doPost(issue);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where HC4__Subject__c = :issue.fieldsInfo[0].value and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, issues.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderIssueController2.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
                
        uRestController.GenericGetResponse issue = new uRestController.GenericGetResponse();        
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Provider__c', provider.Id));
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Subject__c', '__A_TEST_SUBJECT__')); 
        
        RestPrmProviderIssueController2.doPut(issue);
        
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
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        uRestController.GenericGetResponse ri = new uRestController.GenericGetResponse();
        ri.id = issue.Id;
        ri.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Provider__c', provider.Id));
        ri.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Subject__c', '__A_TEST_SUBJECT__'));
        
        RestPrmProviderIssueController2.doPut(ri);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        issue = [Select Id, HC4__Subject__c from HC4__Issue__c where Id = :issue.Id];
        
        System.assertEquals(ri.fieldsInfo[1].value, issue.HC4__Subject__c);
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
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse ri = new uRestController.GenericGetResponse();
        ri.id = issue.Id + 'a';
        
        RestPrmProviderIssueController2.doPut(ri);
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doPatch_ProviderIssues() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c issue1 = new HC4__Issue__c();
        issue1.HC4__Priority__c = provider.id;
        issue1.HC4__Subject__c = '__A_TEST_SUBJECT__';
        issue1.HC4__Status__c = 'New';
        issue1.HC4__Priority__c = 'Low';        
        
        insert issue1;
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        insert i;
        RestRequest request = new RestRequest();
         request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderIssueController2.doPatch(new List<String> { i.Id });
        
        i = [Select Id, HC4__Status__c, HC4__DateTimeClosed__c from HC4__Issue__c where Id = :i.Id];
        
        System.assert(i.HC4__Status__c.toLowerCase().startsWith('closed'));
        
        RestPrmProviderIssueController2.doPatch(null);
        
        RestPrmProviderIssueController2.doPatch(new List<String> {});
        List<String> ids = new List<String>();
        ids.add('aaa' + i.id);
        ids.add('bbbb' + issue1.id);
        
        RestPrmProviderIssueController2.doPatch(ids);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderIssueController2.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Provider__c = provider.Id,
           HC4__Subject__c = '__A_TEST_SUBJECT__'
        );
        
        insert issue;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Issues/' + issue.Id;
        request.resourcePath = '/mobile/prm/v2/Providers/*/Issues';
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderIssueController2.doDelete();
        
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where Id = :issue.Id];
        
        System.assertEquals(0, issues.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void otherMethods_uRestConroller() {
    	
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Provider__c = provider.Id,           
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues/';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('PracticeId', practice.Id);
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
    	uRestController.getDateTime('2015-06-15T19:03:13.000Z');
    	uRestController.getDate('2015-06-15T19:03:13.000Z');
    	uRestController.getFieldSetMembers(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.HC4__Expense.Label), 'Task');
    	uRestController.getFieldSetMembers('HC4__IssueClose', 'HC4__Issue__c');
    	uRestController.getView('Task', uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.HC4__Expense.Label), 'Task'); 
    	
    	Map<String, Schema.FieldSetMember> fsm = uRestController.getFSMembers(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.HC4__Expense.Label), 'Task');   
    	
    	uRestController.getRequiredFields(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task');     	
    	uRestController.getRequiredFields(uRestController.getFieldSetName('HC4__Issue__c', Schema.SObjectType.HC4__Issue__c.fieldSets.HC4__IssueClose.Label), 'HC4__Issue__c');
    	uRestController.getDefaultPicklistValue(Task.Status.getDescribe());
    	
    	System.assert( fsm.size() >= 0); 	
    }
}