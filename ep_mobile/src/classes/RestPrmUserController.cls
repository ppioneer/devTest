/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Users/*')
global with sharing class RestPrmUserController {
    
    @HttpGet
    global static List<RestPrmUserController.RestUser> doGet() {
       String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmUserController.RestUser> response = new List<RestPrmUserController.RestUser>();
        
            try {
                response.add(new RestPrmUserController.RestUser(objectId));
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
            }
    
            return response;
        } else {
            return RestPrmUserController.performGetSearch();
        }
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmUserController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'name' => 'Name'
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

    private static List<RestPrmUserController.RestUser> performGetSearch() {
        return RestPrmUserController.performGetSearch(null);
    }
    
    public static List<RestPrmUserController.RestUser> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmUserController.propertyMap, 'User'));
        
        Integer pageSize = uRestController.pageSize;
        Integer offSet = uRestController.offset;
        
        List<User> result = 
                    (List<User>)Database.query(RestPrmUserController.generateUserSql(conditions));
        
        List<RestPrmUserController.RestUser> response = new List<RestPrmUserController.RestUser>();
        for(User s : result) {
            response.add(new RestPrmUserController.RestUser(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateUserSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Name from User';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmUserController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }

    global class RestUser {
    	public String id { get; set; }
    	public String name { get; set; }
    	public String organizationId { get { return organizationId = UserInfo.getOrganizationId(); } set; }
    	public String organizationName { get { return organizationName = UserInfo.getOrganizationName(); } set; }
    	
    	public RestUser(String id) {
    		this([Select Id, Name from User where Id = :id]);
    	}
    	
    	public RestUser(String id, String name) {
            this.id = id;
            this.name = name;
        }
    	
    	public RestUser (User u) {
    		this.id = u.Id;
    		this.name = u.Name;
    	}
    	
    	public RestUser(Task t) {
    		this.id = t.Owner.Id;
    		this.Name = t.Owner.Name;
    	}
    	
    	public RestUser(HC4__Issue__c i) {
    		this.id = i.Owner.Id;
            this.Name = i.Owner.Name;
    	}
    	
    	public RestUser(Note n) {
    		this.id = n.Owner.Id; 
    		this.name = n.Owner.Name;
    	}
    	
    	public RestUser(Sobject obj, String UserType) { 
    		     		
    		if( UserType == uRestController.UserType.ModifiedBy.name()){
    			this.id = (String) (obj.getSobject('LastModifiedBy')).get('Id');
    			this.Name = (String) (obj.getSobject('LastModifiedBy')).get('Name');    			
    		}
    		else if (UserType == uRestController.UserType.CreatedBy.name()){
    			this.id = (String) (obj.getSobject('CreatedBy')).get('Id');
    			this.Name = (String) (obj.getSobject('CreatedBy')).get('Name');
    		}
    		else if (UserType == uRestController.UserType.Owner.name()){
    			if(obj.getSobject('Owner') != null){
	    			this.id = (String) (obj.getSobject('Owner')).get('Id');
	    			this.Name = (String) (obj.getSobject('Owner')).get('Name');
    			}
    		}
    		
    	}    	
    	
    }
}