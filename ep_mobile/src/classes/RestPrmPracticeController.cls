/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Practices/*')
global with sharing class RestPrmPracticeController {
    @HttpGet
    global static List<RestPrmPracticeController.Practice> doGet() {
    	String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmPracticeController.Practice> response = new List<RestPrmPracticeController.Practice>();
        
            try {
                response.add(new RestPrmPracticeController.Practice(objectId));
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
            }
    
            return response;
        } else {
            return RestPrmPracticeController.performGetSearch();
        }
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmPracticeController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'name' => 'Name',
                'phone' => 'Phone',
                'fax' => 'Fax',
                'affiliation' => 'HC4__Affiliation__c',
                'isInNetwork' => 'HC4__IsInNetwork__c',
                'lastViewedDate' => 'LastViewedDate',
                'website' => 'WebSite',
                'type' => 'Type'
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

    private static List<RestPrmPracticeController.Practice> performGetSearch() {
        return RestPrmPracticeController.performGetSearch(null);
    }
    
    public static List<RestPrmPracticeController.Practice> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        Set<Id> locationProviders = new Set<Id>();
        
        if(!String.isBlank(uRestController.searchValue)) {
            conditions.add(new HC4.uCondition('Account', 'Name', 'c', uRestController.searchValue).toSql());
        }
        
        if(!String.isBlank(uRestController.getParameterValue('zipCode'))) {
            String zipCode = uRestController.getParameterValue('zipCode');
            List<HC4__Location__c> locations = [Select HC4__Practice__c from HC4__Location__c where HC4__MailingPostalCode__c = :zipCode]; //T2567
            for(HC4__Location__c location : locations) {
                locationProviders.add(location.HC4__Practice__c);
            }
            conditions.add(new HC4.uCondition('Account', 'ID', 'IN', ':locationProviders').toSql());
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmPracticeController.propertyMap, 'Account'));
        
        Integer pageSize = uRestController.getPageSize(50); 
        Integer offSet = uRestController.offset;
        
        List<Account> result = 
                    (List<Account>)Database.query(RestPrmPracticeController.generatePracticeSql(conditions));
        
        List<RestPrmPracticeController.Practice> response = new List<RestPrmPracticeController.Practice>();
        for(Account a : result) {
            response.add(new RestPrmPracticeController.Practice(a));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generatePracticeSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Name, BillingStreet, BillingCity, BillingState, ' +
                     'BillingPostalCode, BillingCountry, BillingLongitude, BillingLatitude, ' +
                     'ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ' +
                     'ShippingCountry, ShippingLongitude, ShippingLatitude, Phone, Fax, ' +
                     'HC4__DoNotUpdateFromPrimaryLocation__c, HC4__PrimaryLocation__c,' +
                     'HC4__Affiliation__c, HC4__IsInNetwork__c, WebSite, Type, Parent.Id, Parent.Name,' +
                     'CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name From Account';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmProviderController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
        
    }
    
    global class PracticeLite {
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
        public String name { get { return String.isBlank(this.name) ? uString.EMPTY: this.name; } set; }
        
        public PracticeLite() {
        	
        }
        
        public PracticeLite(Task t) {
        	this.id = t.What.Id;
        	this.name = t.What.Name;
        }
        
        public PracticeLite(String id, String name) {
            this.id = id;
            this.name = name;
        }
    }
    
    global class Practice {
        public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
        public String name { get { return String.isBlank(this.name) ? uString.EMPTY: this.name; } set; }
        public RestPrmLocationController.Address billingAddress { get; set; }
        public RestPrmLocationController.Address shippingAddress { get; set; }
        public String phone { get { return String.isBlank(this.phone) ? uString.EMPTY: this.phone; } set; }
        public String fax { get { return String.isBlank(this.fax) ? uString.EMPTY: this.fax; } set; }
        public Boolean doNotUpdateFromPrimaryLocation { get { return this.doNotUpdateFromPrimaryLocation == null ? false : this.doNotUpdateFromPrimaryLocation; } set; }
        public RestPrmLocationController.Location primaryLocation { get; set; }
        public Boolean isPrimary { get { return this.isPrimary == null ? false : this.isPrimary; } set; }
        public Boolean isInNetwork { get { return this.isInNetwork == null ? false : this.isInNetwork; } set; }
        public String affiliation { get { return String.isBlank(this.affiliation) ? uString.EMPTY: this.affiliation; } set; }
        public String website { get { return String.isBlank(this.website) ? uString.EMPTY : this.website; } set; }
        public String type { get { return String.isBlank(this.type) ? uString.EMPTY : this.type; } set; }
        public RestPrmPracticeController.PracticeLite parentPractice { get; set; }
        public DateTime createdDate { get; private set; }
        public RestPrmUserController.RestUser createdBy { get; private set; }
        public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
          
        public Practice(String practiceId) {
            this([Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLongitude, BillingLatitude,
                 ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLongitude, ShippingLatitude, 
                 Phone, Fax, HC4__DoNotUpdateFromPrimaryLocation__c, HC4__PrimaryLocation__c, HC4__Affiliation__c, HC4__IsInNetwork__c, WebSite,
                 Type, Parent.Id, Parent.Name, CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name
                  From Account WHERE Id = :practiceId Limit 1 FOR VIEW]);
        }
                
        public Practice(Account a) {
            this.id = a.id;
            this.name = a.Name;
            this.billingAddress = new RestPrmLocationController.Address(a.BillingStreet, a.BillingCity,
                a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingLongitude, a.BillingLatitude);
            this.shippingAddress = new RestPrmLocationController.Address(a.ShippingStreet, a.ShippingCity,
                a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingLongitude, a.ShippingLatitude);
            this.phone = a.Phone;
            this.fax = a.Fax;
            this.doNotUpdateFromPrimaryLocation = a.HC4__DoNotUpdateFromPrimaryLocation__c;
            
            if(!String.IsBlank(a.HC4__PrimaryLocation__c)){
            	try{
            		this.primaryLocation =  new RestPrmLocationController.Location(a.HC4__PrimaryLocation__c);
            	}
            	catch(Exception ex){
            		System.debug(LoggingLevel.ERROR, ex);
            		this.primaryLocation = null;
            	}            	
            }            
            this.affiliation = a.HC4__Affiliation__c;
            this.isInNetwork = a.HC4__IsInNetwork__c;
            this.webSite = a.Website;
            this.type = a.Type;
            
            if(!String.IsBlank(a.Parent.Id)){
            	try{
            		this.parentPractice = new RestPrmPracticeController.PracticeLite(a.Parent.Id, a.Parent.Name);
            	}
            	catch(Exception ex){
            		System.debug(LoggingLevel.ERROR, ex);
            		this.parentPractice = null;
            	}            	
            }            
            this.createdDate = a.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(a.CreatedBy.Id, a.CreatedBy.Name);
            this.lastModifiedDate = a.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(a.LastModifiedBy.Id, a.LastModifiedBy.Name);
        }
        
        public Practice(HC4__ProviderPractice__c p) {
            this.id = p.HC4__Practice__r.Id;
            this.name = p.HC4__Practice__r.Name; 
            this.phone = p.HC4__Practice__r.Phone;
            this.fax = p.HC4__Practice__r.Fax;
            this.billingAddress = new RestPrmLocationController.Address(p.HC4__Practice__r.BillingStreet, 
            p.HC4__Practice__r.BillingCity,
            p.HC4__Practice__r.BillingState, 
            p.HC4__Practice__r.BillingPostalCode, 
            p.HC4__Practice__r.BillingCountry,
            p.HC4__Practice__r.BillingLongitude,
            p.HC4__Practice__r.BillingLatitude); 
            this.shippingAddress = new RestPrmLocationController.Address(p.HC4__Practice__r.ShippingStreet, 
            p.HC4__Practice__r.ShippingCity,
            p.HC4__Practice__r.ShippingState,
            p.HC4__Practice__r.ShippingPostalCode,
            p.HC4__Practice__r.ShippingCountry,
            p.HC4__Practice__r.ShippingLongitude,
            p.HC4__Practice__r.ShippingLatitude);
            this.doNotUpdateFromPrimaryLocation = p.HC4__Practice__r.HC4__DoNotUpdateFromPrimaryLocation__c;
            if(!String.IsBlank(p.HC4__Practice__r.HC4__PrimaryLocation__c)){
            	try{
            		this.primaryLocation = new RestPrmLocationController.Location(p.HC4__Practice__r.HC4__PrimaryLocation__c);
            	}
            	catch(Exception ex){
            		System.debug(LoggingLevel.ERROR, ex);
            		this.primaryLocation = null;
            	}            	
            }            
            this.isPrimary = p.HC4__IsPrimary__c;
            this.affiliation = p.HC4__Practice__r.HC4__Affiliation__c;
            this.isInNetwork = p.HC4__Practice__r.HC4__IsInNetwork__c;
            this.website = p.HC4__Practice__r.Website;
            this.type = p.HC4__Practice__r.Type;
            if(!String.IsBlank(p.HC4__Practice__r.Parent.Id)){
            	try{
            		this.parentPractice = new RestPrmPracticeController.PracticeLite(p.HC4__Practice__r.Parent.Id, p.HC4__Practice__r.Parent.Name);
            	}
            	catch(Exception ex){
            		System.debug(LoggingLevel.ERROR, ex);
            		this.parentPractice = null;
            	}            	
            }
            this.createdDate = p.HC4__Practice__r.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(p.HC4__Practice__r.CreatedBy.Id, p.HC4__Practice__r.CreatedBy.Name);
            this.lastModifiedDate = p.HC4__Practice__r.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(p.HC4__Practice__r.LastModifiedBy.Id, p.HC4__Practice__r.LastModifiedBy.Name);
        }
        
        public Practice(RecentlyViewed t) {
            this([Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLongitude, BillingLatitude,
                 ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLongitude, ShippingLatitude, 
                 Phone, Fax, HC4__DoNotUpdateFromPrimaryLocation__c, HC4__PrimaryLocation__c, HC4__Affiliation__c, HC4__IsInNetwork__c, WebSite,
                 Type, Parent.Id, Parent.Name, CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name
                  From Account WHERE Id = :t.Id Limit 1]);
        }
    }
}