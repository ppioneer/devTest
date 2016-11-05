/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Providers/*/Notes')
global with sharing class RestPrmProviderNoteController2 {
	
	@HttpGet
    global static List<uRestController.GenericGetListResponse> doGet() {
        String id = uRestController.getParentObjectId('Providers/');
        
        try{
        	List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
	        additionalConditions.add(new HC4.uCondition('Note', 'ParentId', '=', id));
	        
	        return RestPrmNoteSearchController.performGetSearch(additionalConditions);
        }
        catch(Exception ex){
        	System.debug(LoggingLevel.ERROR, ex);
            uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
            return null;
        }
    }
    
    @HttpPost
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data) {
    	if(data == null) {
    	   uRestController.setStatusCode(uRestController.BadRequest);
    	   return null;	
    	}
    	
    	if(!String.isBlank(uRestController.getParentObjectId('Providers/'))){
    		data = setParentId(data, uRestController.getParentObjectId('Providers/'));
    	}
    	
    	
        return RestPrmNoteController2.doPost(data);
    }
    
    @HttpPut
    global static uRestController.GenericGetResponse doPut(uRestController.GenericGetResponse data) {
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           return null;  
        }
        
        if(!String.isBlank(uRestController.getParentObjectId('Providers/'))){
    		data = setParentId(data, uRestController.getParentObjectId('Providers/'));
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