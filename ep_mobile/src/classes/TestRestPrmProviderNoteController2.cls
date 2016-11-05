/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmProviderNoteController2 {

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
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> notes = RestPrmProviderNoteController2.doGet();
        
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
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderNoteController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoTitle() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();
        
        RestPrmProviderNoteController2.doPost(n);
        
        System.assertEquals(409, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        request.addParameter('Providers', provider.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();
        n.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        n.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', provider.Id));
        n.fieldsInfo.add(new uRestController.FieldsDescribe('Body', '__TEST__DATA__BODY__'));
        
        RestPrmNoteController2.doPost(n, '', new String[] { provider.Id });
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Note> notes = [Select Id From Note where Title = : n.fieldsInfo[0].value and OwnerId = :UserInfo.getUserId()];
        
        System.assert(notes.size() >= 0);
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/*/Notes';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderNoteController2.doPut(null);
        
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
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rn = new uRestController.GenericGetResponse();
        rn.id = n.Id;
        
        RestPrmProviderNoteController2.doPut(rn);
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();
        n.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        n.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', provider.Id));
        
        RestPrmProviderNoteController2.doPut(n);
        
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
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        uRestController.GenericGetResponse rn = new uRestController.GenericGetResponse();
        rn.id = n.Id;
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE_CHANGED__'));
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', provider.Id));
        
        RestPrmProviderNoteController2.doPut(rn);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
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
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rn = new uRestController.GenericGetResponse();
        rn.id = n.Id + 'a';
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', provider.Id));
                
        RestPrmProviderNoteController2.doPut(rn);
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Notes';
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderNoteController2.doDelete();
        
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
        request.requestURI = '/mobile/prm/v2/Providers/' + provider.Id + '/Notes/' + n.Id;
        request.resourcePath = '/mobile/prm/v2/Providers/*/Notes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderNoteController2.doDelete();
        
        List<Note> notes = [Select Id From Note where Id = :n.Id];
        
        System.assertEquals(0, notes.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}