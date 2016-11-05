/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Practices/*/Notes')
global with sharing class RestPrmPracticeNoteController {
     @HttpGet
    global static List<RestPrmNoteController.RestNote> doGet() {
        String id = uRestController.getParentObjectId('Practices/');
        
        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Note', 'ParentId', '=', id));
        
        return RestPrmNoteController.performGetSearch(additionalConditions);
    }
    
    @HttpPost
    global static RestPrmNoteController.RestNote doPost(RestPrmNoteController.RestNote data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        data.parentId = uRestController.getParentObjectId('Practices/');
        
        return RestPrmNoteController.doPost(data);
    }
    
    @HttpPut
    global static RestPrmNoteController.RestNote doPut(RestPrmNoteController.RestNote data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        data.parentId = uRestController.getParentObjectId('Practices/');
                
        return RestPrmNoteController.doPut(data);
    }
    
    @HttpDelete
    global static void doDelete() {
        RestPrmNoteController.doDelete();
    }
}