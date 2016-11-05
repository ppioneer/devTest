/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Practices/*/Notes')
global with sharing class RestPrmPracticeNoteController2 {
	
	@HttpGet
    global static List<uRestController.GenericGetListResponse> doGet() {
        String id = uRestController.getParentObjectId('Practices/');
        
        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('Note', 'ParentId', '=', id));
        
        return RestPrmNoteSearchController.performGetSearch(additionalConditions);
    }
    
    @HttpPost
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(!String.isBlank(uRestController.getParentObjectId('Practices/'))){
    		data = setParentId(data, uRestController.getParentObjectId('Practices/'));
    	}        
        
        return RestPrmNoteController2.doPost(data);
    }
    
    @HttpPut
    global static uRestController.GenericGetResponse doPut(uRestController.GenericGetResponse data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(!String.isBlank(uRestController.getParentObjectId('Practices/'))){
    		data = setParentId(data, uRestController.getParentObjectId('Practices/'));
    	}
                
        return RestPrmNoteController2.doPut(data);
    }
    
    @HttpDelete
    global static void doDelete() {
        RestPrmNoteController2.doDelete();
    }
	
	private static uRestController.GenericGetResponse setParentId(uRestController.GenericGetResponse data, String parentId) {
    	   		
		for(uRestController.FieldsDescribe describe : data.fieldsInfo){ 
	    		if(describe.name.toLowerCase() == 'ParentId'){
	    			describe.value = parentId;
					break;
	    		}
    	}    	
    	
    	return data;
    }
}