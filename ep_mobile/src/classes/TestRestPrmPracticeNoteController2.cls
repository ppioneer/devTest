/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmPracticeNoteController2 {
	
	static testMethod void doGet_RetrievesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = practice.Id
        );
        insert n;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> notes = RestPrmPracticeNoteController2.doGet();
        
        System.assertEquals(1, notes.size());
        System.assertEquals(n.ID, notes[0].id);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeNoteController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoTitle() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practics/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();
        
        RestPrmPracticeNoteController2.doPost(n);
        
        System.assertEquals(409, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        request.addParameter('Practices', practice.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();
        n.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        n.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', practice.Id));
        n.fieldsInfo.add(new uRestController.FieldsDescribe('Body', '__TEST__DATA__BODY__'));        
        
        RestPrmNoteController2.doPost(n, '', new String[] { practice.Id });
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Note> notes = [Select Id From Note where Title = :n.fieldsInfo[0].value and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, notes.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/*/Notes';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeNoteController2.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNoTitle() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = practice.Id
        );
        insert n;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rn = new uRestController.GenericGetResponse();
        rn.id = n.Id;
        
        RestPrmPracticeNoteController2.doPut(rn);
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();        
        n.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        n.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', practice.Id));
        
        RestPrmPracticeNoteController2.doPut(n);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = practice.Id
        );
        insert n;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        uRestController.GenericGetResponse rn = new uRestController.GenericGetResponse();
        rn.id = n.Id;
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE_CHANGED__'));
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', n.ParentId));
        
        
        RestPrmPracticeNoteController2.doPut(rn);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = practice.Id
        );
        insert n;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rn = new uRestController.GenericGetResponse();
        rn.id = n.Id + 'a';
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', practice.Id));        
        
        RestPrmPracticeNoteController2.doPut(rn);
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeNoteController2.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = practice.Id
        );
        insert n;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Notes/' + n.Id;
        request.resourcePath = '/mobile/prm/v2/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeNoteController2.doDelete();
        
        List<Note> notes = [Select Id From Note where Id = :n.Id];
        
        System.assertEquals(0, notes.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
}