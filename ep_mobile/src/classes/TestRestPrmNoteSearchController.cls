/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmNoteSearchController {
	
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
        request.requestURI = '/mobile/prm/v2/Notes/' + n.Id;
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> notes = RestPrmNoteSearchController.doGet(); 
        
        RestPrmNoteSearchController.performGetSearch(null);
        
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
        request.requestURI = '/mobile/prm/v2/Notes/Search';
        request.resourcePath = '/mobile/prm/v2/Notes/Search/*';
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> notes = RestPrmNoteSearchController.doGet();
        
        System.assert(1 <= notes.size());
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest requestNote = new RestRequest();
        requestNote.requestURI = '/mobile/prm/v2/Notes/Search';
        requestNote.resourcePath = '/mobile/prm/v2/Notes/Search/*';
        requestNote.addParameter('q', 'TEMP');
        requestNote.addParameter('pageSize', '3');
        System.RestContext.request = requestNote; 
        
        List<uRestController.GenericGetListResponse> notes1 = RestPrmNoteSearchController.doGet();
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
        request.requestURI = '/mobile/prm/v2/Notes/Search';
        request.resourcePath = '/mobile/prm/v2/Notes/Search/*';
        request.addParameter('startCreateDate', theDate);
        request.addParameter('endCreateDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> notes = RestPrmNoteSearchController.doGet();
        
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
        request.requestURI = '/mobile/prm/v2/Notes/Search';
        request.resourcePath = '/mobile/prm/v2/Notes/Search/*';
        request.addParameter('createdeDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> notes = RestPrmNoteSearchController.doGet();
        
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
        request.requestURI = '/mobile/prm/v2/Notes/' + n.Id + 'a';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetResponse> notes = RestPrmNoteController2.doGet();
        
        System.assertEquals(0, notes.size());
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController2.doPost(null, 'Provider', null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNoTitle() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();
        
        RestPrmNoteController2.doPost(n, 'Practice', new String[] { provider.Id });
        
        System.assertEquals(409, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNoParentId() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();
        
        n.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        
        RestPrmNoteController2.doPost(n, 'Provider' , null);
        
        System.assertEquals(409, RestContext.response.statusCode);
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
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();
        n.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        n.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', patient.Id));
        
        
        RestPrmNoteController2.doPost(n, 'Provider', new String[] { provider.Id });
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Note> notes = [Select Id From Note where Title = :n.fieldsInfo[0].value and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, notes.size());
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController2.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
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
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rn = new uRestController.GenericGetResponse();
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__')); 
        rn.id = n.Id;        
        
        RestPrmNoteController2.doPut(rn);
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
    	Lead patient = new Lead (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert patient;
              
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse n = new uRestController.GenericGetResponse();       
        n.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        n.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', patient.Id));
        
        RestPrmNoteController2.doPut(n);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsContentOnUpdate() {
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
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        request.addParameter('PracticeId', patient.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        uRestController.GenericGetResponse rn = new uRestController.GenericGetResponse();
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE_CHANGED__'));        
        rn.id = n.Id;
                
        RestPrmNoteController2.doPut(rn);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        Note nn = [Select Id, Title from Note where Id = :n.Id];
        
        System.assertEquals(rn.fieldsInfo[0].value, nn.Title);
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
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rn = new uRestController.GenericGetResponse();
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('Title', '__TEST_TITLE__'));
        rn.fieldsInfo.add(new uRestController.FieldsDescribe('ParentId', patient.Id));
        rn.id = n.Id + 'a';
        
        RestPrmNoteController2.doPut(rn);
        
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
        request.requestURI = '/mobile/prm/v2/Notes/' + n.Id;
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmNoteController2.doDelete();
        
        List<Note> notes = [Select Id From Note where Id = :n.Id];
        
        System.assertEquals(0, notes.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void doGet_Schema() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        List<uRestController.GenericGetResponse> response = RestPrmNoteController2.doGet();
        System.assert(response.size() >= 0);
    }
    
    static testMethod void doGet_SchemaWithProvider() {
    	Contact c = new Contact(LastName='__TEST___');
    	insert c; 
    	
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        request.addParameter('ProviderId', c.Id);
        System.RestContext.response = new RestResponse();
                
        List<uRestController.GenericGetResponse> response = RestPrmNoteController2.doGet();
        System.assert(response.size() >= 0);
    }
    
    static testMethod void doGet_SchemaWithPractice() {
    	Account a = new Account(Name='__TEST___');
    	insert a; 
    	
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes';
        request.resourcePath = '/mobile/prm/v2/Notes/*';
        System.RestContext.request = request;
        request.addParameter('PracticeId', a.Id);
        System.RestContext.response = new RestResponse();
                
        List<uRestController.GenericGetResponse> response = RestPrmNoteController2.doGet();
        System.assert(response.size() >= 0);
    }
    
    static testMethod void doGet_MyNotes() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Notes/myNotes';
        request.resourcePath = '/mobile/prm/v2/Notes/myNotes';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
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
                
        RestPrmNoteMyNotesController2.doGet();         
        
        System.assertEquals(null, RestContext.response.statusCode);
    }
    
    
}