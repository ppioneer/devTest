/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Locations/*')
global class RestPrmLocationController {

    @HttpGet
    global static List<RestPrmLocationController.Location> doGet() {        
        String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmLocationController.Location> response = new List<RestPrmLocationController.Location>();
        
            try {
                response.add(new RestPrmLocationController.Location(objectId));
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
            }
    
            return response;
        } else {
            return RestPrmLocationController.performGetSearch();
        }
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmLocationController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'phone' => 'HC4__Phone__c',
                'fax' => 'HC4__Fax__c',
                'email' => 'HC4__Email__c'
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

    private static List<RestPrmLocationController.Location> performGetSearch() {
        return RestPrmLocationController.performGetSearch(null);
    }
    
    public static List<RestPrmLocationController.Location> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmLocationController.propertyMap, 'HC4__Location__c'));
        
        Integer pageSize = uRestController.getPageSize(200);
        Integer offSet = uRestController.offset;
        
        List<HC4__Location__c> result = 
                    (List<HC4__Location__c>)Database.query(RestPrmLocationController.generateLocationSql(conditions));
        
        List<RestPrmLocationController.Location> response = new List<RestPrmLocationController.Location>();
        for(HC4__Location__c s : result) {
            response.add(new RestPrmLocationController.Location(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateLocationSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, HC4__Phone__c,HC4__Fax__c,HC4__Email__c, HC4__OtherStreet__c, HC4__OtherCity__c,' +
                     'HC4__OtherState__c, HC4__OtherPostalCode__c, HC4__OtherCountry__c, HC4__MailingStreet__c,' + 
                     'HC4__MailingCity__c, HC4__MailingState__c, HC4__MailingPostalCode__c, HC4__MailingCountry__c, ' +
                     'HC4__Practice__c, HC4__PracticeName__c,  CreatedDate, CreatedBy.Id, CreatedBy.Name,' +
                     'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name FROM HC4__Location__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmLocationController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
    
    global class Location {
        public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
        public String plid { get { return String.isBlank(this.plid) ? uString.EMPTY: this.plid; } set; }
        public String phone { get { return String.isBlank(this.phone) ? uString.EMPTY: this.phone; } set; }
        public String fax { get { return String.isBlank(this.fax) ? uString.EMPTY: this.fax; } set; }
        public String email { get { return String.isBlank(this.email) ? uString.EMPTY: this.email; } set; }
        public Boolean isPrimary { get { return this.isPrimary == null ? false : this.isPrimary; } set; }
        public RestPrmLocationController.Address billingAddress { get; set; }
        public RestPrmLocationController.Address mailingAddress { get; set; }
        public RestPrmPracticeController.PracticeLite practice { get; set; }
        public DateTime createdDate { get; private set; }
        public RestPrmUserController.RestUser createdBy { get; private set; }
        public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
        public Boolean territoryMapped { get { return this.territoryMapped == null ? false : this.territoryMapped; } set; }
        
        public Location(String locationId) {
            this([SELECT Id, 
                          HC4__Phone__c,
                          HC4__Fax__c,
                          HC4__Email__c, 
                          HC4__OtherStreet__c, 
                          HC4__OtherCity__c,
                          HC4__OtherState__c, 
                          HC4__OtherPostalCode__c, 
                          HC4__OtherCountry__c, 
                          HC4__MailingStreet__c, 
                          HC4__MailingCity__c,
                          HC4__MailingState__c,
                          HC4__MailingPostalCode__c,
                          HC4__MailingCountry__c,
                          HC4__Practice__c, 
                          HC4__PracticeName__c,
                          CreatedDate,
                          CreatedBy.Id,
                          CreatedBy.Name,
                          LastModifiedDate,
                          LastModifiedBy.Id,
                          LastModifiedBy.Name
                          FROM HC4__Location__c WHERE Id = :locationId LIMIT 1]);
        }
        
        public Location(HC4__Location__c l) {
            this.id = l.Id;
            this.phone = l.HC4__Phone__c;
            this.fax = l.HC4__Fax__c;
            this.email = l.HC4__Email__c;
            this.billingAddress = new RestPrmLocationController.Address(l.HC4__OtherStreet__c, l.HC4__OtherCity__c,
                l.HC4__OtherState__c, l.HC4__OtherPostalCode__c, l.HC4__OtherCountry__c, 0.0, 0.0);
            this.mailingAddress = new RestPrmLocationController.Address(l.HC4__MailingStreet__c, l.HC4__MailingCity__c,
                l.HC4__MailingState__c, l.HC4__MailingPostalCode__c, l.HC4__MailingCountry__c, 0.0, 0.0);
            this.practice = String.isBlank(l.HC4__Practice__c) ? null : new RestPrmPracticeController.PracticeLite(l.HC4__Practice__c, l.HC4__PracticeName__c);
            this.createdDate = l.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(l.CreatedBy.Id, l.CreatedBy.Name);
            this.lastModifiedDate = l.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(l.LastModifiedBy.Id, l.LastModifiedBy.Name);
        }
        
        public Location(String id, String phone, String fax, String email, RestPrmLocationController.Address billingAddress, RestPrmLocationController.Address mailingAddress) {
            this.id = id;
            this.phone = phone;
            this.fax = fax;
            this.email = email;
            this.billingAddress = billingAddress;
            this.mailingAddress = mailingAddress;
        }
        
        public Location(HC4__ProviderLocation__c pl) {
        	this.plid = pl.Id;
        	this.id = pl.HC4__Location__r.Id; 
            this.phone =  pl.HC4__Location__r.HC4__Phone__c;
            this.fax = pl.HC4__Location__r.HC4__Fax__c;
            this.email = pl.HC4__Location__r.HC4__Email__c;
            this.isPrimary = pl.HC4__IsPrimary__c;
            this.billingAddress = new RestPrmLocationController.Address(pl.HC4__Location__r.HC4__OtherStreet__c, 
                  pl.HC4__Location__r.HC4__OtherCity__c, pl.HC4__Location__r.HC4__OtherState__c, pl.HC4__Location__r.HC4__OtherPostalCode__c, pl.HC4__Location__r.HC4__OtherCountry__c, 0.0, 0.0);
            this.mailingAddress = new RestPrmLocationController.Address(pl.HC4__Location__r.HC4__MailingStreet__c, 
                  pl.HC4__Location__r.HC4__MailingCity__c, pl.HC4__Location__r.HC4__MailingState__c, pl.HC4__Location__r.HC4__MailingPostalCode__c, pl.HC4__Location__r.HC4__MailingCountry__c, 0.0, 0.0);
            this.practice = String.isBlank(pl.HC4__Location__r.HC4__Practice__c) ? null : new RestPrmPracticeController.PracticeLite(pl.HC4__Location__r.HC4__Practice__c, pl.HC4__Location__r.HC4__PracticeName__c);
        	this.createdDate = pl.HC4__Location__r.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(pl.HC4__Location__r.CreatedBy.Id, pl.HC4__Location__r.CreatedBy.Name);
            this.lastModifiedDate = pl.HC4__Location__r.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(pl.HC4__Location__r.LastModifiedBy.Id, pl.HC4__Location__r.LastModifiedBy.Name);
        }
        
        public Location(HC4__ProviderLocationTerritory__c plt) {
        	this.id = plt.HC4__ProviderLocation__r.HC4__Location__r.Id; 
            this.phone =  plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__Phone__c;
            this.fax = plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__Fax__c;
            this.email = plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__Email__c;
            this.isPrimary = plt.HC4__ProviderLocation__r.HC4__IsPrimary__c;
            this.billingAddress = new RestPrmLocationController.Address(plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherStreet__c, 
                  plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherCity__c, plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherState__c, plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherPostalCode__c, plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherCountry__c, 0.0, 0.0);
            this.mailingAddress = new RestPrmLocationController.Address(plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingStreet__c, 
                  plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingCity__c, plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingState__c, plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingPostalCode__c, plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingCountry__c, 0.0, 0.0);
            this.practice = String.isBlank(plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__Practice__c) ? null : 
                    new RestPrmPracticeController.PracticeLite(plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__Practice__c, plt.HC4__ProviderLocation__r.HC4__Location__r.HC4__PracticeName__c);
            this.createdDate = plt.HC4__ProviderLocation__r.HC4__Location__r.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(plt.HC4__ProviderLocation__r.HC4__Location__r.CreatedBy.Id, plt.HC4__ProviderLocation__r.HC4__Location__r.CreatedBy.Name);
            this.lastModifiedDate = plt.HC4__ProviderLocation__r.HC4__Location__r.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(plt.HC4__ProviderLocation__r.HC4__Location__r.LastModifiedBy.Id, plt.HC4__ProviderLocation__r.HC4__Location__r.LastModifiedBy.Name);
        }
    }
    
    global class Address {
        public String street { get { return String.isBlank(this.street) ? uString.EMPTY: this.street; } set; }
        public String city { get { return String.isBlank(this.city) ? uString.EMPTY: this.city; } set; }
        public string state { get { return String.isBlank(this.state) ? uString.EMPTY: this.state; } set; }
        public string postalCode { get { return String.isBlank(this.postalCode) ? uString.EMPTY: this.postalCode; } set; }
        public string country { get { return String.isBlank(this.country) ? uString.EMPTY: this.country; } set; }
        public Decimal longitude { get { return this.longitude == null ? 0.0: this.longitude; } set; }
        public Decimal latitude { get { return this.latitude == null ? 0.0: this.latitude; } set; }
        
        public Address(String street, String city, String state, String postalCode, String country,
        Decimal longitude, Decimal latitude) {
            this.street = street;
            this.city = city;
            this.state = state;
            this.postalCode = postalCode;
            this.country = country;
            this.longitude = longitude;
            this.latitude = latitude;
        }
    }
}