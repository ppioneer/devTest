/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*')
global with sharing class RestPrmProviderController {
    
    @HttpGet
    global static List<RestPrmProviderController.Provider> doGet() {
        String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmProviderController.Provider> response = new List<RestPrmProviderController.Provider>();
        
            try {
                response.add(new RestPrmProviderController.Provider(objectId));
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
            }
    
            return response;
        } else {
            return RestPrmProviderController.performGetSearch(false);
        }
    }

    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmProviderController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'title' => 'Title',
                'name' => 'Name',
                'salutation' => 'salutation',
                'firstName' => 'FirstName',
                'lastName' => 'LastName',
                'middleName' => 'HC4__middleName__c',
                'lastName' => 'LastName',
                'primaryAreaOfExpertise' => 'HC4__PrimaryAreaOfExpertise__c',
                'age' => 'HC4__Age__c',
                'gender' => 'HC4__Gender__c',
                'email' => 'Email',
                'phone' => 'HomePhone',
                'mobile' => 'MobilePhone',
                'fax' => 'Fax',
                'suffix' => 'HC4__Suffix__c',
                'professionalSuffix' => 'HC4__ProfessionalSuffix__c',
                'doNotCall' => 'DoNotCall',
                'emailOptOut' => 'HasOptedOutOfEmail',
                'faxOptOut' => 'HasOptedOUtOfFax',
                'department' => 'Department',
                'type' => 'RecordType.Name',
                'lastViewedDate' => 'LastViewedDate',
                'affiliation' => 'HC4__Affiliation__c'
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

    private static List<RestPrmProviderController.Provider> performGetSearch(boolean includePrimaryPractice) {
        return RestPrmProviderController.performGetSearch(null, includePrimaryPractice);
    }
    
    public static List<RestPrmProviderController.Provider> performGetSearch(List<HC4.uCondition> additionalConditions, boolean includePrimaryPractice) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        Set<Id> specialtyProviders = new Set<Id>();
        Set<Id> aoeProviders = new Set<Id>();
        Set<Id> practiceProviders = new Set<Id>();
        Set<Id> territoryProviders = new Set<Id>();
        Set<Id> zipCodeProviders = new Set<Id>();
        Set<Id> locationProviders = new Set<Id>();
        Set<Id> providers = null;
		//T2050 - Fix -- All 
        if(!String.isBlank(uRestController.getParameterValue('specialtyIds'))) {
            List<String> ids = uRestController.getParameterValue('specialtyIds').split(';');
            List<AggregateResult> sps = 
            [Select HC4__Provider__c, COUNT(HC4__Specialty__c) from HC4__ProviderSpecialty__c 
            where HC4__Specialty__c in :ids GROUP BY  HC4__Provider__c];
            
            for(AggregateResult sp : sps) {
                specialtyProviders.add((Id)sp.get('HC4__Provider__c'));
            }
            
            conditions.add(new HC4.uCondition('Contact', 'ID', 'IN', ':specialtyProviders').toSql());
        }
            
        if(!String.isBlank(uRestController.getParameterValue('aoeIds'))) {
            List<String> ids = uRestController.getParameterValue('aoeIds').split(';');
            List<AggregateResult> aoes = 
            [Select HC4__Provider__c, COUNT(HC4__AreaOfExpertise__c) from HC4__ProviderAreaOfExpertise__c 
            where HC4__AreaOfExpertise__c in :ids GROUP BY  HC4__Provider__c];
            
            for(AggregateResult aoe : aoes) {
                aoeProviders.add((Id)aoe.get('HC4__Provider__c'));
            }
            conditions.add(new HC4.uCondition('Contact', 'ID', 'IN', ':aoeProviders').toSql());
        }
            
        if(!String.isBlank(uRestController.getParameterValue('practiceIds'))) {
            List<String> ids = uRestController.getParameterValue('practiceIds').split(';');
            List<AggregateResult> practices =
            [Select HC4__Provider__c, COUNT(HC4__Practice__c) from HC4__ProviderPractice__c 
           where HC4__Practice__c in :ids GROUP BY  HC4__Provider__c];
            
            for(AggregateResult practice : practices) {
                practiceProviders.add((Id)practice.get('HC4__Provider__c'));
            }
            conditions.add(new HC4.uCondition('Contact', 'ID', 'IN', ':practiceProviders').toSql());
        }
            
        if(!String.isBlank(uRestController.getParameterValue('territoryIds'))) {
            List<String> ids = uRestController.getParameterValue('territoryIds').split(';');
            List<AggregateResult> practices = 
            [Select HC4__ProviderLocation__r.HC4__Provider__c pid, COUNT(HC4__Territory__c) from HC4__ProviderLocationTerritory__c 
            where HC4__Territory__c in :ids GROUP BY  HC4__ProviderLocation__r.HC4__Provider__c];
            
            for(AggregateResult practice : practices) {
                territoryProviders.add((Id)practice.get('pid'));
            }
            conditions.add(new HC4.uCondition('Contact', 'ID', 'IN', ':territoryProviders').toSql());
        }
        
        if(!String.isBlank(uRestController.getParameterValue('locationIds'))) {
            List<String> ids = uRestController.getParameterValue('locationIds').split(';');
            List<AggregateResult> locations = 
            [Select HC4__Provider__c, COUNT(HC4__Location__c) from HC4__ProviderLocation__c 
            where HC4__Location__c in :ids GROUP BY HC4__Provider__c];
            
            for(AggregateResult location : locations) {
                locationProviders.add((Id)location.get('HC4__Provider__c'));
            }
            conditions.add(new HC4.uCondition('Contact', 'ID', 'IN', ':locationProviders').toSql());
        }
        
        if(!String.isBlank(uRestController.getParameterValue('mailingCity'))) {
            String mailingCity = uRestController.getParameterValue('mailingCity');
            List<String> cities = uRestController.getParameterValue('mailingCity').split(';');
            providers = new Set<Id>();
            List<HC4__ProviderLocation__c> locations = [Select HC4__Provider__c from HC4__ProviderLocation__c where HC4__Location__r.HC4__MailingCity__c IN :cities];
            for(HC4__ProviderLocation__c location : locations) {
                providers.add(location.HC4__Provider__c);
            }
            conditions.add(new HC4.uCondition('Contact', 'ID', 'IN', ':providers').toSql());
        }
        
        if(!String.isBlank(uRestController.getParameterValue('mailingState'))) {
            String mailingState = uRestController.getParameterValue('mailingState');
            List<String> states = uRestController.getParameterValue('mailingState').split(';');
            providers = new Set<Id>();
            List<HC4__ProviderLocation__c> locations = [Select HC4__Provider__c from HC4__ProviderLocation__c where HC4__Location__r.HC4__MailingState__c IN :states];
            for(HC4__ProviderLocation__c location : locations) {
                providers.add(location.HC4__Provider__c);
            }
            conditions.add(new HC4.uCondition('Contact', 'ID', 'IN', ':providers').toSql());
        }
            
        if(!String.isBlank(uRestController.getParameterValue('zipCode'))) {
            String zipCode = uRestController.getParameterValue('zipCode');
            List<String> zipcodes = uRestController.getParameterValue('zipCode').split(';');
            List<HC4__ProviderLocation__c> locations = [Select HC4__Provider__c from HC4__ProviderLocation__c where HC4__Location__r.HC4__MailingPostalCode__c IN :zipcodes];
            for(HC4__ProviderLocation__c location : locations) {
                zipCodeProviders.add(location.HC4__Provider__c);
            }
            conditions.add(new HC4.uCondition('Contact', 'ID', 'IN', ':zipCodeProviders').toSql());
        }
        
        if(!String.isBlank(uRestController.searchValue)) {
            conditions.add(new HC4.uCondition('Contact', 'Name', 'c', uRestController.searchValue).toSql());
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmProviderController.propertyMap, 'Contact'));
        
        List<RestPrmProviderController.Provider> response = new List<RestPrmProviderController.Provider>();
        
        Integer pageSize = uRestController.getPageSize(50);
        Integer offSet = uRestController.offset;
        
        List<Contact> result = 
                    (List<Contact>)Database.query(RestPrmProviderController.generateProviderSql(conditions));
        
        for(Contact a : result) {
            String practiceId = uString.EMPTY;
            
            if(includePrimaryPractice) {
               List<HC4__ProviderPractice__c> practices = [select HC4__Practice__c from HC4__ProviderPractice__c where HC4__Provider__c = :a.Id and HC4__IsPrimary__c = true and HC4__Practice__c != null limit 1];
               practiceId = ((practices.size() == 1) ? String.valueOf(practices[0].HC4__Practice__c) : '');
            }
            
            response.add(new RestPrmProviderController.Provider(a, practiceId));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateProviderSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'SELECT Id, Title, Name, Salutation, FirstName, HC4__MiddleName__c,' +
                     'LastName, HC4__PrimaryAreaOfExpertise__c, Department, HC4__Gender__c,' +
                     'Email, HomePhone, MobilePhone, Fax, HC4__PrimaryLocation__c,' +
                     'HC4__Suffix__c, HC4__ProfessionalSuffix__c, HC4__DoNotUpdateFromPrimaryLocation__c, HC4__Age__c,' +
                     'DoNotCall, HasOptedOutOfEmail, HasOptedOUtOfFax,' +
                     'MailingStreet, MailingCity, MailingState, MailingPostalCode,' +
                     'MailingCountry, MailingLongitude, MailingLatitude, OtherStreet,' + 
                     'OtherCity, OtherState, OtherPostalCode, OtherCountry, ' +
                     'OtherLongitude, OtherLatitude, RecordType.Name, HC4__Affiliation__c,' +
                     'CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name FROM Contact';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('lastName', RestPrmProviderController.propertyMap);
       sql += ' ,FirstName LIMIT :pageSize OFFSET :offset'; //PRM-511
       
       System.debug(LoggingLevel.ERROR, sql);
       
       return sql;
    }
    
    global class ProviderLite {
        public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
        public String name { get { return String.isBlank(this.name) ? uString.EMPTY: this.name; } set; }
        
        public ProviderLite() {
            
        }
        
        public ProviderLite(Task t) {
            this.id = t.Who.Id;
            this.name = t.Who.Name;
        }
        
        public ProviderLite(HC4__Issue__c i) {
            this.id = i.HC4__Provider__r.Id;
            this.name = i.HC4__Provider__r.Name;
        }
    }
    
    global class Provider {
        public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
        public String title { get { return String.isBlank(this.title) ? uString.EMPTY: this.title; } set; }
        public String salutation { get { return String.isBlank(this.salutation) ? uString.EMPTY: this.salutation; } set; }
        public String name { get { return String.isBlank(this.name) ? uString.EMPTY: this.name; } set; }
        public String firstName { get { return String.isBlank(this.firstName) ? uString.EMPTY: this.firstName; } set; }
        public String middleName {get { return String.isBlank(this.middleName) ? uString.EMPTY: this.middleName; } set; }
        public String lastName { get { return String.isBlank(this.lastName) ? uString.EMPTY: this.lastName; } set; }
        public String suffix { get { return String.isBlank(this.suffix) ? uString.EMPTY: this.suffix; } set; }
        public String professionalSuffix { get { return String.isBlank(this.professionalSuffix) ? uString.EMPTY: this.professionalSuffix; } set; }
        public String primaryAreaOfExpertise { get { return String.isBlank(this.primaryAreaOfExpertise) ? uString.EMPTY: this.primaryAreaOfExpertise; } set; }
        public String department { get { return String.isBlank(this.department) ? uString.EMPTY: this.department; } set; }
        public String gender { get { return String.isBlank(this.gender) ? uString.EMPTY: this.gender; } set; }
        public String email { get { return String.isBlank(this.email) ? uString.EMPTY: this.email; } set; }
        public String mobile { get { return String.isBlank(this.mobile) ? uString.EMPTY: this.mobile; } set; }
        public String phone { get { return String.isBlank(this.phone) ? uString.EMPTY: this.phone; } set; }
        public String fax { get { return String.isBlank(this.fax) ? uString.EMPTY: this.fax; } set; }
        public Integer age { get { return this.age == null ? 0 : this.age; } set; }
        public Boolean doNotCall { get { return this.doNotCall == null ? false : this.doNotCall; } set; }
        public Boolean emailOptOut { get { return this.emailOptOut == null ? false : this.emailOptOut; } set; }
        public Boolean faxOptOut { get { return this.faxOptOut == null ? false : this.faxOptOut; } set; }
        public String type { get { return String.isBlank(this.type) ? uString.EMPTY : this.type; } set; }
        public String affiliation { get { return String.isBlank(this.affiliation) ? uString.EMPTY : this.affiliation; } set; }
        public DateTime createdDate { get; private set; }
        public RestPrmUserController.RestUser createdBy { get; private set; }
        public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
        
        public RestPrmLocationController.Location primaryLocation { get; set; }
        public RestPrmPracticeController.Practice primaryPractice { get; set; }
        
        public Provider(String providerId) {
            Contact c = [SELECT Id, Title, Name, salutation, FirstName, HC4__middleName__c, lastName, HC4__PrimaryAreaOfExpertise__c,
            Department, HC4__Gender__c, Email, HomePhone, MobilePhone, Fax, HC4__PrimaryLocation__c, HC4__Suffix__c, HC4__ProfessionalSuffix__c, HC4__Age__c, HC4__DoNotUpdateFromPrimaryLocation__c,
             DoNotCall, HasOptedOutOfEmail, HasOptedOUtOfFax, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLongitude, MailingLatitude,
             OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLongitude, OtherLatitude, RecordType.Name, HC4__Affiliation__c,
             CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name FROM Contact WHERE Id = :providerId FOR VIEW];
           List<HC4__ProviderPractice__c> practices = [select HC4__Practice__c from HC4__ProviderPractice__c where HC4__Provider__c = :c.Id and HC4__IsPrimary__c = true and HC4__Practice__c != null limit 1];
            String practiceId = ((practices.size() == 1) ? String.valueOf(practices[0].HC4__Practice__c) : '');
            
            this.init(c, practiceId);
        }
        
        public Provider(Contact c, String practiceId) {
            this.init(c, practiceId);
        }
        
        private void init(Contact c, String practiceId) {
            this.id = c.Id;
            this.title = c.Title;
            this.name = c.lastName + ', ' + c.FirstName; //c.name;
            this.salutation = c.salutation;
            this.firstName = c.FirstName;
            this.middleName = c.HC4__middleName__c;
            this.lastName = c.lastName;
            this.suffix = c.HC4__Suffix__c;
            this.professionalSuffix = c.HC4__ProfessionalSuffix__c;
            this.primaryAreaOfExpertise = c.HC4__PrimaryAreaOfExpertise__c;
            this.department = c.Department;
            this.gender = c.HC4__Gender__c;
            this.email = c.Email;
            this.phone = c.HomePhone;
            this.fax = c.Fax;
            this.mobile = c.MobilePhone;
            this.age = (c.HC4__Age__c == null ? 0 : c.HC4__Age__c.intValue());
            this.doNotCall = c.DoNotCall;
            this.emailOptOut = c.HasOptedOutOfEmail;
            this.faxOptOut = c.HasOptedOUtOfFax;
            this.type = c.RecordType.Name;
            this.affiliation = c.HC4__Affiliation__c;
            this.createdDate = c.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(c.CreatedBy.Id, c.CreatedBy.Name);
            this.lastModifiedDate = c.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(c.LastModifiedBy.Id, c.LastModifiedBy.Name);
        
            try{
	            	if(true == c.HC4__DoNotUpdateFromPrimaryLocation__c || String.isBlank(c.HC4__PrimaryLocation__c)) {
	                this.primaryLocation = new RestPrmLocationController.Location(uString.EMPTY, 
	                c.HomePhone, c.Fax, c.Email, new RestPrmLocationController.Address(c.OtherStreet, c.OtherCity, c.OtherState, c.OtherPostalCode, c.OtherCountry,
	                c.OtherLongitude, c.OtherLatitude), new RestPrmLocationController.Address(c.MailingStreet, c.MailingCity, c.MailingState, c.MailingPostalCode, 
	                c.MailingCountry, c.MailingLongitude, c.MailingLatitude));
	            } else {
	            		if(!String.isBlank( c.HC4__PrimaryLocation__c ) ){
	                    	this.primaryLocation = new RestPrmLocationController.Location(c.HC4__PrimaryLocation__c);
	            		}
	            }
            }
            catch(Exception ex) {
            	System.debug(LoggingLevel.ERROR, ex);
            	this.primaryLocation = null;
            }
            
            if(!String.IsBlank(practiceId)) {
                try{
                	this.primaryPractice = new RestPrmPracticeController.Practice(practiceId);
                }
                catch(Exception ex) {
	            	System.debug(LoggingLevel.ERROR, ex);
	            	this.primaryPractice = null;
            	}
            }   
        }
    }
}