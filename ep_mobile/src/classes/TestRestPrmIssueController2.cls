/* Copyright (c) 2008-2014 Evariant */
@isTest
private class TestRestPrmIssueController2 {

    static testMethod void doGet_RetrievesObjectById() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Patient__c = patient.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues/' + i.Id;
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues = RestPrmIssueSearchController.doGet();
        
        System.assertEquals(1, issues.size());
        
    }
    
    static testMethod void doGet_IssueSchema() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Patient__c = patient.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        insert i;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues/';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();         
        List<uRestController.GenericGetResponse> issues = RestPrmIssueController2.doGet();  
               
        RestRequest requestWithId = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues/' + i.Id;
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();         
        List<uRestController.GenericGetResponse> issueWithId = RestPrmIssueController2.doGet();        
        System.assertEquals(1, issues.size());
        
        RestPrmIssueController2.createIssue(null, null); 
    }
    
    static testMethod void doGet_RetrievesAllWhenNoId() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST456__',
           HC4__Patient__c = patient.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low', 
           HC4__Type__c = 'Complaint',          
           OwnerId = UserInfo.getUserId()
        );
        insert i;
        
        HC4__Issue__c i1 = new HC4__Issue__c(
           HC4__Subject__c = '__TEST123__',
           HC4__Patient__c = patient.Id,
           HC4__Status__c = 'Working',           
           HC4__Priority__c = 'Low',
           HC4__Type__c = 'Compliment',            
           OwnerId = UserInfo.getUserId()
        );
        insert i1;
        
        HC4__Issue__c i2 = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Patient__c = patient.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'High',
           HC4__Type__c = 'Inquiry',               
           OwnerId = UserInfo.getUserId()
        );
        insert i2;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues/Search/';
        request.resourcePath = '/mobile/prm/v2/Issues/Search/*';
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues = RestPrmIssueSearchController.doGet();
        
        
        
        RestRequest request1 = new RestRequest();
        request1.requestURI = '/mobile/prm/v2/Issues/Search/';
        request1.resourcePath = '/mobile/prm/v2/Issues/Search/*';
        request1.addParameter('priority', 'High;Low');
        System.RestContext.request = request1;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues1 = RestPrmIssueSearchController.doGet();
        
        
        RestRequest requestStatus = new RestRequest();
        requestStatus.requestURI = '/mobile/prm/v2/Issues/Search/';
        requestStatus.resourcePath = '/mobile/prm/v2/Issues/Search/*';
        requestStatus.addParameter('status', 'New;Working');
        System.RestContext.request = requestStatus;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues2 = RestPrmIssueSearchController.doGet();
        
        RestRequest requestType = new RestRequest();
        requestType.requestURI = '/mobile/prm/v2/Issues/Search/';
        requestType.resourcePath = '/mobile/prm/v2/Issues/Search/*';
        requestType.addParameter('type', 'Complaint;Inquiry');
        System.RestContext.request = requestType;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues3 = RestPrmIssueSearchController.doGet();
        
        RestRequest requestSubject = new RestRequest();
        requestSubject.requestURI = '/mobile/prm/v2/Issues/Search/';
        requestSubject.resourcePath = '/mobile/prm/v2/Issues/Search/*';
        requestSubject.addParameter('q', 'TEST');
        System.RestContext.request = requestSubject;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues4 = RestPrmIssueSearchController.doGet();
        
        System.assert( issues.size() >= 1);
        
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
        request.requestURI = '/mobile/prm/v2/Issues/';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('startCreateDate', theDate);
        request.addParameter('endCreateDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues = RestPrmIssueSearchController.doGet();
        
        System.assert(issues.size() >= 0);
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
        request.requestURI = '/mobile/prm/v2/Issues/';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('createdDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues = RestPrmIssueSearchController.doGet();
        
        System.assert(issues.size() >= 0);
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
        request.requestURI = '/mobile/prm/v2/Issues/';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('pageSize', '3');
        request.addParameter('startCreateDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> issues = RestPrmIssueSearchController.doGet();
        
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
        request.requestURI = '/mobile/prm/v2/Issues/';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('pageSize', '3');
        request.addParameter('endCreateDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> issues = RestPrmIssueSearchController.doGet();
        
        System.assert(issues.size() >= 0);
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
        request.requestURI = '/mobile/prm/v2/Issues/';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('pageSize', '3');
        request.addParameter('startCreateDate', DateTime.now().format('yyyy-MM-dd'));
        request.addParameter('endCreateDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> issues = RestPrmIssueSearchController.doGet();
        
        System.assert(issues.size() >= 0);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse issue = new uRestController.GenericGetResponse();        
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Provider__c', provider.Id));
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Subject__c', '__A_TEST_SUBJECT__'));
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Status__c', 'New'));
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Priority__c', 'Low'));         
       
        RestPrmIssueController2.doPost(issue);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where HC4__Subject__c = :issue.fieldsInfo[1].value and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, issues.size());
        
        RestRequest requestWithType = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController2.doPost(issue, 'Provider', new String[] { provider.Id });
        
        RestPrmIssueController2.doPost(issue, 'Provider', null);
        
        RestPrmIssueController2.doPost(null, 'Provider', null); 
        
        issue.fieldsInfo[1].value = uString.EMPTY;
        
        RestPrmIssueController2.doPost(issue, 'Provider', new String[] { provider.Id });       
        
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController2.doPost(null, 'Provider', null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsCreated() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse issue = new uRestController.GenericGetResponse();
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Subject__c', '__A_TEST_SUBJECT__')); 
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Priority__c', 'Low'));
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Status__c', 'New'));
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Provider__c', provider.Id));
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__DateTimeOpened__c', '2015-02-09T23:44:14.000Z'));
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__IsEscalated__c', 'false'));
        
                
        RestPrmIssueController2.doPost(issue, 'Provider', new String[] { provider.Id });
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where HC4__Subject__c = :issue.fieldsInfo[0].value and OwnerId = :UserInfo.getUserId() and HC4__Provider__c = :provider.Id];
        
        System.assert(issues.size() >= 0);
        
        HC4__Issue__c i = new HC4__Issue__c();
        insert i; 
        
        RestPrmIssueController2.doPost(issue, 'Provider', new String[] { i.Id });
        
        issue.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Subject__c', ''));
        RestPrmIssueController2.doPost(issue, 'Provider', new String[] { i.Id });
        
        RestPrmIssueController2.createIssue(uRestController.getFSMembers(uRestController.getFieldSetName('HC4__Issue__c', Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label), 'HC4__Issue__c'), issue);
        RestPrmIssueController2.createIssue(null, issue);
        RestPrmIssueController2.createIssue(uRestController.getFSMembers(uRestController.getFieldSetName('HC4__Issue__c', Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label), 'HC4__Issue__c'), null);
        
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController2.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse i = new uRestController.GenericGetResponse();
        
        RestPrmIssueController2.doPut(i);
        
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
        request.requestURI = '/mobile/prm/v2/Issues';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        uRestController.GenericGetResponse ri = new uRestController.GenericGetResponse();        
        ri.id = i.Id;
        ri.fieldsInfo.add(new uRestController.FieldsDescribe('HC4__Subject__c', '__SUBJECT_HAS_CHANGED__'));
        RestPrmIssueController2.doPut(ri);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        i = [Select Id, HC4__Subject__c from HC4__Issue__c where Id = :i.Id];
        
        System.assertEquals(ri.fieldsInfo[0].value, i.HC4__Subject__c);
        ri.id= uString.EMPTY;
        
        RestPrmIssueController2.doPut(ri);
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
        request.requestURI = '/mobile/prm/v2/Issues';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse ri = new uRestController.GenericGetResponse();
        ri.id = i.Id + 'a';
        
        RestPrmIssueController2.doPut(ri);
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
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
        request.requestURI = '/mobile/prm/v2/Issues/' + i.Id;
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController2.doDelete();
        
        List<HC4__Issue__c> issues = [Select Id From HC4__Issue__c where Id = :i.Id];
        
        System.assertEquals(0, issues.size());
        System.assertEquals(200, RestContext.response.statusCode);
        
        RestRequest requestExcept = new RestRequest();
        requestExcept.requestURI = '/mobile/prm/v2/Issues/a' + i.Id;
        requestExcept.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = requestExcept;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController2.doDelete();
        
        HC4__Issue__c issue1 = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Patient__c = patient.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        
        insert issue1; 
        
        RestRequest requestWithMultiple = new RestRequest();
        requestWithMultiple.requestURI = '/mobile/prm/v2/Issues/a' + i.Id;
        requestWithMultiple.resourcePath = '/mobile/prm/v2/Issues/*';
        requestWithMultiple.addParameter('ids', issue1.id + ';' + i.id);
        System.RestContext.request = requestWithMultiple;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController2.doDelete();
    }
    
    static testMethod void doPatch_ClosesTasks() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Issue__c issue1 = new HC4__Issue__c();
        issue1.HC4__Priority__c = provider.id;
        issue1.HC4__Subject__c = '__A_TEST_SUBJECT__';         
        
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
        request.requestURI = '/mobile/prm/v2/Issues/';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmIssueController2.doPatch(new List<String> { i.Id });
        
        i = [Select Id, HC4__Status__c, HC4__DateTimeClosed__c from HC4__Issue__c where Id = :i.Id];
        
        System.assert(i.HC4__Status__c.toLowerCase().startsWith('closed'));
        
        RestPrmIssueController2.doPatch(null);
        
        RestPrmIssueController2.doPatch(new List<String> {});
        List<String> ids = new List<String>();
        ids.add('aaa' + i.id);
        ids.add('bbbb' + issue1.id);
        
        RestPrmIssueController2.doPatch(ids);
    }
    
    static testMethod void testMethods_uRestController() {
    	
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
        
        RestRequest requestTest = new RestRequest();
        requestTest.requestURI = '/mobile/prm/v2/Issues/';
        requestTest.resourcePath = '/mobile/prm/v2/Issues/*';
        requestTest.addParameter('pageSize', '1');		
        requestTest.addParameter('PracticeId', practice.Id);
        requestTest.addParameter('ProviderId', provider.Id);
        System.RestContext.request = requestTest;
        System.RestContext.response = new RestResponse();         
    	        
        uRestController.getView('Task', uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task');
        uRestController.getView('Task', uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditCall.Label), 'Call');
        uRestController.getView('HC4__Issue__c', uRestController.getFieldSetName('HC4__Issue__c', Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label), 'Issue'); 
        uRestController.getRequiredFields(uRestController.getFieldSetName('HC4__Issue__c', Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label), 'HC4__Issue__c'); 
        uRestController.getFieldSetMembers(uRestController.getFieldSetName('HC4__Issue__c', Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label), 'HC4__Issue__c');
        uRestController.getFSMembers(uRestController.getFieldSetName('HC4__Issue__c', Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label), 'HC4__Issue__c');
        uRestController.getFieldSetMembers(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task');
        uRestController.getFSMembers(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task'); 
        uRestController.GenericGetResponse obj = new uRestController.GenericGetResponse('Task');
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues/';
        request.resourcePath = '/mobile/prm/v2/Issues/*';
        request.addParameter('PracticeId', practice.Id);
        request.addParameter('ProviderId', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        RestPrmIssueController2.doGet();
        
        List<HC4__Issue__c> lst = [Select Id, HC4__IsClosed__c, HC4__DateTImeClosed__c, HC4__DateTimeOpened__c, HC4__isEscalated__c,HC4__InternalComments__c, HC4__LongDescription__c, HC4__Origin__c, HC4__Priority__c,HC4__Reason__c, HC4__Status__c, HC4__Subject__c, HC4__Type__c, HC4__Provider__r.Name, HC4__Provider__r.Id, HC4__Provider__c, HC4__Patient__r.Name, HC4__Patient__r.Id, HC4__Patient__c, CreatedDate, Owner.Id, Owner.Name, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name From HC4__Issue__c limit 1]; 
        
        Sobject objIssue = lst[0];
        uRestController.GenericGetResponse objIssue1 = new uRestController.GenericGetResponse(objIssue, uRestController.getFieldSetName('HC4__Issue__c', Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label), 'Issue');
        objIssue1.RecordItem(i.Id, uRestController.getFieldSetName('HC4__Issue__c', Schema.SObjectType.HC4__Issue__c.fieldSets.EditIssue.Label), 'Issue'); 
        
        Task t = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Status = 'Not Started',
           Type = 'Task'           
        );
        insert t;
        
         Task call = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Status = 'Not Started',
           Type = 'Call'           
        );
        insert call;
        
        Note nProvider = new Note(Title='__TEST__', Body='__Body_Comment__', ParentId=provider.Id);
        insert nProvider;
        
        Note nPractice = new Note(Title='__TEST__', Body='__Body_Comment__', ParentId=practice.Id);
        insert nPractice; 
        
        List<Note> notes = [SELECT Id, Owner.Id, Owner.Name, Parent.Type, Parent.Name, ParentId, Title, Body, IsPrivate, CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name FROM Note];
        
        List<Task> lstTask = [Select Id, WhoId, WhatId, Type, Subject, Status, Priority, IsClosed, Description, DateTimeOpened__c, CallType, ActivityDate, ReminderDateTime,IsReminderSet, OwnerId, Owner.Id, Owner.Name,CreatedDate,LastModifiedDate,LastModifiedBy.Name, LastModifiedBy.Id, LastModifiedById, CreatedBy.Name, CreatedBy.Id, CreatedById  FROM Task limit 1]; 
        
        objIssue = lstTask[0];
        uRestController.GenericGetResponse objTask = new uRestController.GenericGetResponse(objIssue, uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task');
        objTask.RecordItem(t.Id, uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task');
        
        objIssue = lstTask[0];
        uRestController.GenericGetResponse objCall = new uRestController.GenericGetResponse(objIssue, uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditCall.Label), 'Call');
        objCall.RecordItem(call.Id, uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditCall.Label), 'Call'); 
        
        uRestController.GenericGetListResponse objListTask = new uRestController.GenericGetListResponse(t, 'Task', 'Task');
        uRestController.GenericGetListResponse objListIssue = new uRestController.GenericGetListResponse(lst[0], 'HC4__Issue__c', 'Issue');
        uRestController.GenericGetListResponse objListNote = new uRestController.GenericGetListResponse(notes[0], 'Note', 'Note');
        uRestController.GenericGetListResponse objListNotePractice = new uRestController.GenericGetListResponse(notes[1], 'Note', 'Note');
        
        uRestController.FieldsDescribe fd = new uRestController.FieldsDescribe('Status', 'Status', 'Not Started', false, false, Schema.DisplayType.Picklist);
        uRestController.FieldsDescribe fdNameValue = new uRestController.FieldsDescribe('Status', 'Status');
        uRestController.FieldsDescribe fdObject = new uRestController.FieldsDescribe('Task');
        
        List<uRestController.FieldsDescribe> fieldValue = new List<uRestController.FieldsDescribe>();
    }
}