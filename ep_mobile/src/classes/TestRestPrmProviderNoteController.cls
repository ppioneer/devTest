/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderNoteController {
    static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id
        );
        insert n;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmNoteController.RestNote> notes = RestPrmProviderNoteController.doGet();
        
        System.assertEquals(1, notes.size());
        System.assertEquals(n.ID, notes[0].id);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderNoteController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoTitle() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        
        RestPrmProviderNoteController.doPost(n);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        n.title = '__TEST_TITLE__';
        n.parentId = provider.Id;
        
        RestPrmProviderNoteController.doPost(n);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Note> notes = [Select Id From Note where Title = :n.Title and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, notes.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/*/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderNoteController.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNoTitle() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id
        );
        insert n;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id;
        
        RestPrmProviderNoteController.doPut(rn);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        n.title = '__TEST_TITLE__';
        n.parentId = provider.Id;
        
        RestPrmProviderNoteController.doPut(n);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id
        );
        insert n;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id;
        rn.title = '__TEST_TITLE_CHANGED__';
        rn.parentId = n.ParentId;
        
        RestPrmProviderNoteController.doPut(rn);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        n = [Select Id, Title from Note where Id = :n.Id];
        
        System.assertEquals(rn.title, n.Title);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id
        );
        insert n;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id + 'a';
        rn.title= '__TEST_TITLE__';
        rn.parentId = provider.Id;
        
        RestPrmProviderNoteController.doPut(rn);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderNoteController.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id
        );
        insert n;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Notes/' + n.Id;
        request.resourcePath = '/mobile/prm/v1/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderNoteController.doDelete();
        
        List<Note> notes = [Select Id From Note where Id = :n.Id];
        
        System.assertEquals(0, notes.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}