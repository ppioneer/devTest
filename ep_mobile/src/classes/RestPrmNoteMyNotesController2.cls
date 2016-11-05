/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Notes/myNotes')
global with sharing class RestPrmNoteMyNotesController2 {
	
	@HttpGet
    global static List<uRestController.GenericGetListResponse> doGet() {               
        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Note', 'OwnerId', '=', UserInfo.getUserId()));
        
        return RestPrmNoteSearchController.performGetSearch(additionalConditions);
    }
}