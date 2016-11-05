/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Notes/*')
global with sharing class RestPrmNoteController2 {
	
	
    public static final String objectName = 'Note';
    public static final String objectLabel = 'Note';
    global static string validationMsg {get;set;} 
	
	@HttpGet
    global static List<uRestController.GenericGetResponse> doGet() {        
        String objectId = uRestController.objectId;    	 
    	List<uRestController.GenericGetResponse> response = new List<uRestController.GenericGetResponse>();
    	
    	try{
    		if(!String.isBlank(objectId)){
	    		response.add(recordItem(objectId));
	    	}
	    	else{    		 
	    		response.add(getView());
	    	}
    	}
    	catch(Exception ex){
    		System.debug(LoggingLevel.ERROR, ex);
            uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
    	}
    	
        return response; 
    }
    
    @HttpPost
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data, String objectType, String[] ids) {
    	String relationName = 'ParentId'; 
    	
    	return RestPrmNoteController2.doPost(data, ids, relationName);	
    }
    
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data, String[] Ids, String relationType) {
        uRestController.GenericGetResponse response = new uRestController.GenericGetResponse();
        
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           response.responseCode = uRestController.BadRequest;   
           return response;
        }
        
        if(Ids == null) {
            return RestPrmNoteController2.doPost(data);
        }       
        
        try {
            List<Note> notes = new List<Note>();
            
            for(String providerId : Ids) {
            	
                Note sfNote = createNote(data);
                
                if(!String.isBlank(validationMsg)) {
                	uRestController.setStatusCode(uRestController.BadRequest);
                    return null;
                }
                
                sfNote.put(relationType, providerId); //Adding ParentId to the data object
                
                notes.add(sfNote);
            }
            
            insert notes;
            
            Set<Id> noteIds = new Set<Id>();
            for(Note n : notes) {
                noteIds.add(n.Id);
            }
            
            uRestController.setStatusCode(uRestController.Created);
            response.responseCode = uRestController.Created;             
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
            response.responseCode = uRestController.Conflict; 
            response.responseMessage = e.getMessage();
        }
        
        return response;
    }
    
    global static uRestController.GenericGetResponse doPost(uRestController.GenericGetResponse data) {
    	uRestController.GenericGetResponse response = new uRestController.GenericGetResponse();
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           response.responseCode = uRestController.BadRequest;   
           return response;
        }
        
        
    	Note sfNote = createNote(data);
    	
        if(!String.isBlank(validationMsg)) {
        	uRestController.setStatusCode(uRestController.BadRequest, validationMsg);
        	response.responseCode = uRestController.BadRequest;
        	response.responseMessage = validationMsg;
            return response;
        }
            
       try {        	
            insert sfNote;
            uRestController.setLocationHeader(sfNote.Id);
            uRestController.setStatusCode(uRestController.Created);             
            return recordItem(sfNote.Id);
                        
        } catch(Exception e) {
        	System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
            response.responseCode = uRestController.Conflict;
        	response.responseMessage = e.getMessage();
        }
        
        return response;
    }
    
    @HttpPut    
    global static uRestController.GenericGetResponse doPut(uRestController.GenericGetResponse data) {
    	uRestController.GenericGetResponse response = new uRestController.GenericGetResponse();
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);
           response.responseCode = uRestController.BadRequest;    
           return response;
        }
        
        if(String.isBlank(data.id)) {
            uRestController.setStatusCode(uRestController.PreconditionFailed, 'Id value is missing');
            response.responseCode = uRestController.PreconditionFailed;
            response.responseMessage =  'Id value is missing';
            return response;
        }
                
        try {
	        Note sfNote = createNote(data);
	        
	        if(!String.isBlank(validationMsg)) {
            	uRestController.setStatusCode(uRestController.BadRequest, validationMsg);
            	response.responseCode = uRestController.BadRequest;
            	response.responseMessage =  validationMsg;
                return response;
            }
	        
	        try {
                Note original = [Select OwnerId from Note where Id = :data.id];
                
                if(data.owner != null && data.owner.id != null && data.owner.id != UserInfo.getUserId()) {
                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an note created by someone else.');
                    response.responseCode = uRestController.Forbidden;
            		response.responseMessage =  'You are not have the permission to edit an note created by someone else.';
                    return response;
                }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                response.responseCode = uRestController.NotFound;
                return response;
            }
            
        
            update sfNote;
            uRestController.setStatusCode(uRestController.OK);
            response.responseCode = uRestController.OK;
            return recordItem(sfNote.Id);
            
        } catch(Exception e) {
        	System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotModified, e.getMessage());
            response.responseCode = uRestController.NotModified;
            response.responseMessage =  e.getMessage();
        }
        
        return response;
    }
    
    @HttpDelete
    global static void doDelete() {
    	Set<String> noteIds = new Set<String>();
        
        if(!String.IsBlank(uRestController.getParameterValue('ids'))) {
            noteIds.addAll(uRestController.getParameterValue('ids').split(';'));
        }
        
        noteIds.add(uRestController.objectId);
                
        List<Note> notes = [Select Id, OwnerId from Note where Id in :noteIds];
        
        if(notes.size() < 1) {
            uRestController.setStatusCode(uRestController.NotFound);
            return;
        }
        
        for(Note n : notes) {
            if(n.OwnerId != UserInfo.getUserId()) {
                uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an note created by someone else.');
                return;
            }
        }
        
        try{
        	delete notes;
        	uRestController.setStatusCode(uRestController.OK);
        }
        catch(Exception ex){
        	System.debug(LoggingLevel.ERROR, ex);
        	uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
        } 
    }
        
    
    
    /*
     * Dynamically Assign the Note Fields Information to Task sObect    
    */
    private static Note createNote(uRestController.GenericGetResponse data) {
    	
    	Note sfNote = new Note();
    	
    	if(data == null) {
           	uRestController.setStatusCode(uRestController.BadRequest);   
           	return null;
		}    	
    	
    	if(!String.isBlank(data.id)) {
	        sfNote.put('Id', data.id);
	    }
	    
	    for(uRestController.FieldsDescribe describe : data.fieldsInfo){
	    	if(describe.name == 'Title') {
	    		if(String.isBlank(describe.value)){
	    			validationMsg = 'Title value is required.'; 
		            uRestController.setStatusCode(uRestController.BadRequest, 'Title value is required.');
		            return null;
	    		}
	    		else{
	    			sfNote.put('Title', describe.value);
	    		}
	        }
	        else if(describe.name == 'IsPrivate'){
	        	sfNote.put(describe.name, Boolean.valueOf(describe.value));
	        }
	        else if(describe.name == 'Body'){
	        	sfNote.put(describe.name, describe.value);
	        }
	    }
        
        return sfNote;
    }
    
    public static uRestController.GenericGetResponse getView() {
    	    	
    	uRestController.GenericGetResponse result = new uRestController.GenericGetResponse();    	
    	result.fieldsInfo = new List<uRestController.FieldsDescribe>(); 
    	Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
	    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();	           	    	
    	result.name = String.valueOf(DescribeSObjectResultObj.getName()); 
    	result.label = String.valueOf(DescribeSObjectResultObj.getLabel());    	    	
    	result.owner = new RestPrmUserController.RestUser(UserInfo.getUserId(), UserInfo.getName());
    	
    	Schema.DescribeSObjectResult noteDSR = Note.sObjectType.getDescribe();
    	result.isReadOnly = !noteDSR.accessible;
    	
    	result.fieldsInfo.add(new uRestController.FieldsDescribe('Title', 'Title', uString.EMPTY, false, true, Schema.DisplayType.String));
    	result.fieldsInfo.add(new uRestController.FieldsDescribe('Body', 'Comments', uString.EMPTY, false, false, Schema.DisplayType.TEXTAREA));
    	result.fieldsInfo.add(new uRestController.FieldsDescribe('IsPrivate', 'Private', uString.EMPTY, false, false, Schema.DisplayType.Boolean)); 
    	
    	return result;
   }
   
   public static uRestController.GenericGetResponse recordItem(String recordId){
   	
    		uRestController.GenericGetResponse rt;
    		List<ID> objIds = new List<ID>();
    		objIds.add(recordId);
    		
    		Schema.SObjectType objectype = objIds[0].getSObjectType();
    		Schema.DescribeSObjectResult dsr = objectype.getDescribe();
    		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    		Map <String, Schema.SObjectField> fieldMap = GlobalDescribeMap.get(objectName).getDescribe().fields.getMap();    		
    		
    		String sql = 'SELECT Id, Owner.Id, Owner.Name, Parent.Type, Parent.Name, ParentId, Title, Body, IsPrivate, CreatedDate, CreatedBy.Id, CreatedBy.Name,' +
                     'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name FROM Note';  
	    	
	    	Integer pageSize = uRestController.getPageSize(200);
        	Integer offset = uRestController.offset;
	    	
	    	if(!String.isBlank(recordId)) {
	    		sql += ' WHERE Id = :recordId';
	    	}
	    	
        	sql += ' LIMIT :pageSize OFFSET :offset';
	    	
	    	List<Note> result = Database.query(sql);	    	
	    	if(result != null && !result.isEmpty()){
	    		Note n = result[0]; 	    		
	    		rt = new uRestController.GenericGetResponse();
	    		rt.id = n.Id;
	    		rt.name = dsr.getName();
				rt.owner = String.IsBlank(n.Owner.Id) ? null : new RestPrmUserController.RestUser(n);				
				rt.createdDate = n.CreatedDate;
				rt.createdBy = new RestPrmUserController.RestUser(n.CreatedBy.Id, n.CreatedBy.Name);
				rt.lastModifiedBy = new RestPrmUserController.RestUser(n.LastModifiedBy.Id, n.LastModifiedBy.Name);
				rt.lastModifiedDate = n.LastModifiedDate; 
				rt.isReadOnly = (n.OwnerId != UserInfo.getUserId());				
																			
				rt.fieldsInfo.add(new uRestController.FieldsDescribe('Title', 'Title', n.Title, false, true, Schema.DisplayType.String));
				rt.fieldsInfo.add(new uRestController.FieldsDescribe('Body', 'Comments', n.Body, false, false, Schema.DisplayType.TEXTAREA));
				rt.fieldsInfo.add(new uRestController.FieldsDescribe('IsPrivate', 'Private', (n.IsPrivate)? 'true' : 'false', false, false, Schema.DisplayType.BOOLEAN)); 			    		
	    	}
	    		    	
            return rt;	
    	}
    
}