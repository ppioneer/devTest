/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Notes/*')
global with sharing class RestPrmNoteController {
	
	@HttpGet
    global static List<RestPrmNoteController.RestNote> doGet() {        
        String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmNoteController.RestNote> response = new List<RestPrmNoteController.RestNote>();
        
	        try {
	            response.add(new RestPrmNoteController.RestNote(objectId));
	        }
	        catch(Exception e) {
	            System.debug(LoggingLevel.ERROR, e);
	            uRestController.setStatusCode(uRestController.NotFound);
	        } 
	        
	        return response; 
        } else {
            return RestPrmNoteController.performGetSearch();
        }
    }
    
    @HttpPost
    global static List<RestPrmNoteController.RestNote> doPost(RestPrmNoteController.RestNote data, String[] providerIds) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        if(providerIds == null) {
            return new List<RestPrmNoteController.RestNote>{ RestPrmNoteController.doPost(data) };
        }       
        
        try {
            List<Note> notes = new List<Note>();
            
            for(String providerId : providerIds) {
                data.parentId = providerId;
                
                Note sfNote = RestPrmNoteController.createNote(data);
                if(sfNote == null) {
                    return null;
                }
                
                notes.add(sfNote);
            }
            
            insert notes;
            
            Set<Id> noteIds = new Set<Id>();
            for(Note n : notes) {
                noteIds.add(n.Id);
            }
            
            List<HC4.uCondition> conditions = new List<HC4.uCondition>();
            conditions.add(new HC4.uCondition('Note', 'Id', 'IN', HC4.uSet.joinForIn(noteIds)));
            
            uRestController.setStatusCode(uRestController.Created);
            return RestPrmNoteController.performGetSearch(conditions);
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
        }
        
        return null;
    }
        
    global static RestPrmNoteController.RestNote doPost(RestPrmNoteController.RestNote data) {
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        try {
        	Note sfNote = RestPrmNoteController.createNote(data);
	        if(sfNote == null) {
	            return null;
	        }
        
            insert sfNote;
            uRestController.setLocationHeader(sfNote.Id);
            uRestController.setStatusCode(uRestController.Created);
            
            return new RestPrmNoteController.RestNote(sfNote.Id);
            
        } catch(Exception e) {
        	System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
        }
        
        return null;
    }
    
    @HttpPut    
    global static RestPrmNoteController.RestNote doPut(RestPrmNoteController.RestNote data) {
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        if(String.isBlank(data.id)) {
            uRestController.setStatusCode(uRestController.PreconditionFailed, 'Id value is missing');
            return null;
        }
                
        try {
	        Note sfNote = RestPrmNoteController.createNote(data);
	        if(sfNote == null) {
	        	return null;
	        }
	        
	        try {
                Note original = [Select OwnerId from Note where Id = :data.id];
                
                if(data.owner != null && data.owner.id != null && data.owner.id != UserInfo.getUserId()) {
                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an note created by someone else.');
                    return null;
                }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                return null;
            }
            
        
            update sfNote;
            uRestController.setStatusCode(uRestController.OK);
            return new RestPrmNoteController.RestNote(sfNote.Id);
            
        } catch(Exception e) {
        	System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotModified, e.getMessage());
        }
        
        return null;
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
        
        delete notes;
        uRestController.setStatusCode(uRestController.OK); //T2371 - Fix 
    }
    
    private static Note createNote(RestPrmNoteController.RestNote n) {
        if(String.isBlank(n.Title)) {
            uRestController.setStatusCode(uRestController.BadRequest, 'Title value is required.');
            return null;
        }
        
        if(String.isBlank(n.parentId)) {
            uRestController.setStatusCode(uRestController.BadRequest, 'ParentId is required.');
            return null;
        }
        
        Note sfNote = new Note(
	        Title = n.title,
	        ownerId = (n.owner == null || String.isBlank(n.owner.id)) ? UserInfo.getUserId() : n.owner.Id,
	        parentId = n.parentId,
	        body = n.body,
	        IsPrivate = n.isPrivate
        );
        
        if(!String.isBlank(n.id)) {
            sfNote.Id = n.id;
        }
        return sfNote;
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmNoteController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'createdDate' => 'createddate',
                'ownerId' => 'ownerid', 
                'parentId' => 'parentid',
                'title' => 'title',
                'body' => 'body',
                'isPrivate' => 'isprivate',
                'createdDate' => 'CreatedDate'
            };
        }
    }
    
    public static Map<String, String> propertyMap {
        get {
            if(propertyMap == null) {
                propertyMap = localPropertyMap;
            }
            
            return propertyMap;
        }
        
        private set;
    }
    
    private static List<RestPrmNoteController.RestNote> performGetSearch() {
        return RestPrmNoteController.performGetSearch(null);
    }
    
    public static List<RestPrmNoteController.RestNote> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        if(!String.isBlank(uRestController.getParameterValue('startCreateDate'))) {
           conditions.add('DAY_ONLY(CreatedDate) >= ' + String.escapeSingleQuotes(uRestController.getParameterValue('startCreateDate')));
        }
        
        if(!String.isBlank(uRestController.getParameterValue('endCreateDate'))) {
           conditions.add('DAY_ONLY(CreatedDate) <= ' + String.escapeSingleQuotes(uRestController.getParameterValue('endCreateDate')));
        }
        
        if(!String.isBlank(uRestController.getParameterValue('createdDate'))) {
           conditions.add('DAY_ONLY(CreatedDate) = ' + String.escapeSingleQuotes(uRestController.getParameterValue('createdDate')));
        }
        
        if(!String.isBlank(uRestController.searchValue)) {
            conditions.add(new HC4.uCondition('Note', 'Title', 'c', uRestController.searchValue).toSql());
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmNoteController.propertyMap, 'Note', new Set<String> { 'createdDate' }));
        
        List<RestPrmNoteController.RestNote> response = new List<RestPrmNoteController.RestNote>();
        
        Integer pageSize = uRestController.getPageSize(200);
        Integer offset = uRestController.offset;
        
        List<Note> result = 
                    (List<Note>)Database.query(RestPrmNoteController.generateNoteSql(conditions));
        
        for(Note a : result) {
            response.add(new RestPrmNoteController.RestNote(a));
        }
        
        uRestController.setPagingHeaders(pageSize, offset, response.size());
        return response;
    }
    
    private static String generateNoteSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'SELECT Id, Owner.Id, Owner.Name, Parent.Type, Parent.Name, ParentId, Title, Body, IsPrivate, CreatedDate, CreatedBy.Id, CreatedBy.Name,' +
                     'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name FROM Note';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       
       sql += uRestController.decodeSortForSoql('createdDate', RestPrmNoteController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
        
    }
    
	global class RestNote {
		public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
		public RestPrmUserController.RestUser owner { get; set; }
		public String parentId { get { return String.isBlank(this.parentId) ? uString.EMPTY: this.parentId; } set; }
		public String parentName { get { return String.isBlank(this.parentName) ? uString.EMPTY: this.parentName; } set; }
		public String parentType { get { return String.isBlank(this.parentType) ? uString.EMPTY: this.parentType; } set; }
		public String title { get { return String.isBlank(this.title) ? uString.EMPTY: this.title; } set; }
		public String body { get { return String.isBlank(this.body) ? uString.EMPTY: this.body; } set; }
		public Boolean isPrivate { get { return isPrivate == null ? false : this.isPrivate; } set; }
		public DateTime createdDate { get; private set; }
		public RestPrmUserController.RestUser createdBy { get; private set; }
		public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
		public Boolean isReadOnly { get; private set; }
		
		public RestNote(Note n) {
			this.id = n.Id;
			this.owner = String.IsBlank(n.Owner.Id) ? null : new RestPrmUserController.RestUser(n);
			this.parentId = n.ParentId;
			this.parentName = n.Parent.Name; //T2023			
			Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{n.Parent.Type});			
			this.parentType = results[0].getLabel();					
			this.title = n.Title;
			this.body = n.Body;
			this.isPrivate = n.IsPrivate;
			this.createdDate = n.CreatedDate;
			this.createdBy = new RestPrmUserController.RestUser(n.CreatedBy.Id, n.CreatedBy.Name);
			this.lastModifiedDate = n.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(n.LastModifiedBy.Id, n.LastModifiedBy.Name);			
			this.isReadOnly = (n.OwnerId != UserInfo.getUserId());
		}
		
		public RestNote(String id) {
			this([SELECT Id, Owner.Id, Parent.Type, Parent.Name, ParentId, Title, Body, IsPrivate, CreatedDate, Owner.Name, CreatedBy.Id, CreatedBy.Name,
			LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name FROM Note Where Id = :id]);
		}
		
		public RestNote() {
			this.isReadOnly = false;
		}
	}

}