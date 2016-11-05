/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Notes/myNotes')
global with sharing class RestPrmNoteMyNotesController {
    
    @HttpGet
    global static List<RestPrmNoteController.RestNote> doGet() {               
        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Note', 'OwnerId', '=', UserInfo.getUserId()));
        
        return RestPrmNoteController.performGetSearch(additionalConditions);
    }
}