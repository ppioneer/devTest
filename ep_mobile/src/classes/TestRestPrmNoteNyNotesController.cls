/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmNoteNyNotesController {
    static testMethod void doGet_RetrievesObjectById() {
    	Contact c = new Contact (
    	   FirstName = '__JOHN__',
    	   LastName = '__DOE__'
    	);
    	insert c;
    	
        Note n = new Note(
           Title = '__TEMP_TITLE__',
           ParentId = c.Id,
           OwnerId = UserInfo.getUserId()
        );
        
        Note n2 = new Note(
           Title = '__TEMP_TITLE2__',
           ParentId = c.Id,
           OwnerId = UserInfo.getUserId()
        );
        insert new List<Note> { n, n2 };
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Notes/myNotes';
        request.resourcePath = '/mobile/prm/v1/Notes/myNotes';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmNoteController.RestNote> notes = RestPrmNoteMyNotesController.doGet();
        
        System.assert( 2 <= notes.size());
    }
}