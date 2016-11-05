/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmNoteController {
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
        request.requestURI = '/mobile/prm/v1/Notes/' + n.Id;
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmNoteController.RestNote> notes = RestPrmNoteController.doGet();
        
        System.assertEquals(1, notes.size());
        System.assertEquals(n.ID, notes[0].id);
    }
    
    static testMethod void doGet_RetrievesAllWhenNoId() {
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
        
        n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id
        );
        insert n;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes/';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<RestPrmNoteController.RestNote> notes = RestPrmNoteController.doGet();
        
        System.assert(1 <= notes.size());
    }
    
    static testMethod void doGet_RetrievesFilteredWithEndAndStartCreateDate() {
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
        
        n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id
        );
        insert n;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes/';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        request.addParameter('startCreateDate', theDate);
        request.addParameter('endCreateDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<RestPrmNoteController.RestNote> notes = RestPrmNoteController.doGet();
        
        System.assert(2 >= notes.size());
    }
    
    static testMethod void doGet_RetrievesFilteredWithCreatedDate() {
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
        
        n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = provider.Id
        );
        insert n;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes/';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        request.addParameter('createdeDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<RestPrmNoteController.RestNote> notes = RestPrmNoteController.doGet();
        
        System.assert(2 <= notes.size());
    }
    
    static testMethod void doGet_NotFoundWhenBadId() {
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
        request.requestURI = '/mobile/prm/v1/Notes/' + n.Id + 'a';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmNoteController.RestNote> notes = RestPrmNoteController.doGet();
        
        System.assertEquals(0, notes.size());
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.doPost(null, null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNoTitle() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        
        RestPrmNoteController.doPost(n, new String[] { provider.Id });
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNoParentId() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        n.title = '__TEST_TITLE__';
        
        RestPrmNoteController.doPost(n, null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsCreated() {
        Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        n.title = '__TEST_TITLE__';
        n.parentId = patient.Id;
        
        RestPrmNoteController.doPost(n, new String[] { provider.Id });
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Note> notes = [Select Id From Note where Title = :n.Title and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, notes.size());
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoTitle() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        
        RestPrmNoteController.doPost(n);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoParentId() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        n.title = '__TEST_TITLE__';
        
        RestPrmNoteController.doPost(n);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {
    	Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        n.title = '__TEST_TITLE__';
        n.parentId = patient.Id;
        
        RestPrmNoteController.doPost(n);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Note> notes = [Select Id From Note where Title = :n.Title and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, notes.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNoTitle() {
    	Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = patient.Id
        );
        insert n;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id;
        
        RestPrmNoteController.doPut(rn);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNoParentId() {
    	Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = patient.Id
        );
        insert n;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id;
        rn.title = '__TEST_TITLE__';
        
        RestPrmNoteController.doPut(rn);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
    	Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote n = new RestPrmNoteController.RestNote();
        n.title = '__TEST_TITLE__';
        n.parentId = patient.Id;
        
        RestPrmNoteController.doPut(n);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
    	Lead patient = new Lead (
    	   FirstName = '__JOHN__',
    	   LastName = '__DOE__'
    	);
    	insert patient;
    	
    	Note n = new Note(
    	   Title = '__TEMP_TITLE__',
    	   ParentId = patient.Id
    	);
    	insert n;
    	        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id;
        rn.title = '__TEST_TITLE_CHANGED__';
        rn.parentId = n.ParentId;
        
        RestPrmNoteController.doPut(rn);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        n = [Select Id, Title from Note where Id = :n.Id];
        
        System.assertEquals(rn.title, n.Title);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
    	Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = patient.Id
        );
        insert n;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.RestNote rn = new RestPrmNoteController.RestNote();
        rn.id = n.Id + 'a';
        rn.title= '__TEST_TITLE__';
        rn.parentId = patient.Id;
        
        RestPrmNoteController.doPut(rn);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v1/Notes/*';
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
        
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = patient.Id
        );
        insert n;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes/' + n.Id;
        request.resourcePath = '/mobile/prm/v1/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController.doDelete();
        
        List<Note> notes = [Select Id From Note where Id = :n.Id];
        
        System.assertEquals(0, notes.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}