/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmPracticeNoteContoller {
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
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmNoteController.RestNote> notes = RestPrmPracticeNoteController.doGet();
        
        System.assertEquals(1, notes.size());
        System.assertEquals(n.ID, notes[0].id);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeNoteController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoTitle() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practics/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        
        RestPrmPracticeNoteController.doPost(n);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        n.title = '__TEST_TITLE__';
        n.parentId = practice.Id;
        
        RestPrmPracticeNoteController.doPost(n);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Note> notes = [Select Id From Note where Title = :n.Title and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, notes.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/*/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeNoteController.doPut(null);
        
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
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id;
        
        RestPrmPracticeNoteController.doPut(rn);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        n.title = '__TEST_TITLE__';
        n.parentId = practice.Id;
        
        RestPrmPracticeNoteController.doPut(n);
        
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
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id;
        rn.title = '__TEST_TITLE_CHANGED__';
        rn.parentId = n.ParentId;
        
        RestPrmPracticeNoteController.doPut(rn);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        n = [Select Id, Title from Note where Id = :n.Id];
        
        System.assertEquals(rn.title, n.Title);
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
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id + 'a';
        rn.title= '__TEST_TITLE__';
        rn.parentId = practice.Id;
        
        RestPrmPracticeNoteController.doPut(rn);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeNoteController.doDelete();
        
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
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Notes/' + n.Id;
        request.resourcePath = '/mobile/prm/v1/Practices/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeNoteController.doDelete();
        
        List<Note> notes = [Select Id From Note where Id = :n.Id];
        
        System.assertEquals(0, notes.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}