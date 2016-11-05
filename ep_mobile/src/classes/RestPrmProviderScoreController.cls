/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/Scores')
global with sharing class RestPrmProviderScoreController {
     @HttpGet
    global static List<RestPrmProviderScoreController.ProviderScore> doGet() {
        return RestPrmProviderScoreController.performGetSearch();
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmProviderScoreController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'name' => 'Name',
                'direction' => 'HC4__Direction__c',
                'referralCalculatedCount' => 'HC4__ReferralCalculatedCount__c',
                'referralClaimCount' => 'HC4__ReferralClaimCount__c',
                'referralLoyaltyScore' => 'HC4__ReferralLoyaltyScore__c',
                'referralVolumeScore' => 'HC4__ReferralVolumeScore__c'
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

    private static List<RestPrmProviderScoreController.ProviderScore> performGetSearch() {
        return RestPrmProviderScoreController.performGetSearch(null);
    }
    
    public static List<RestPrmProviderScoreController.ProviderScore> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        String providerId = uRestController.getParentObjectId('Providers/');
        conditions.add(new HC4.uCondition('HC4__ProviderScore__c', 'HC4__Provider__c', '=', providerId).toSql());
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
                
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmProviderScoreController.propertyMap, 'HC4__ProviderScore__c'));
        
        List<RestPrmProviderScoreController.ProviderScore> response = new List<RestPrmProviderScoreController.ProviderScore>();
        
        Integer pageSize = uRestController.getPageSize(20);
        Integer offSet = uRestController.offset;
        
        List<HC4__ProviderScore__c> result = 
                    (List<HC4__ProviderScore__c>)Database.query(RestPrmProviderScoreController.generateProviderScoreSql(conditions));
        
        for(HC4__ProviderScore__c s : result) {
            response.add(new RestPrmProviderScoreController.ProviderScore(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateProviderScoreSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Name, HC4__Direction__c, HC4__ReferralCalculatedCount__c, ' +
                      'HC4__ReferralClaimCount__c,  HC4__ReferralLoyaltyScore__c, HC4__ReferralVolumeScore__c, ' +
                      'HC4__ServiceLine__r.Id, HC4__ServiceLine__r.Name, HC4__ServiceLine__r.HC4__Code__c, ' +
                      'HC4__ServiceLine__r.HC4__Subgroup__c, CreatedDate, CreatedBy.Id, CreatedBy.Name,' +
                      'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, ' +
                      'HC4__ServiceLine__r.CreatedDate, HC4__ServiceLine__r.CreatedBy.Id, HC4__ServiceLine__r.CreatedBy.Name,' +
                      'HC4__ServiceLine__r.LastModifiedDate, HC4__ServiceLine__r.LastModifiedBy.Id, HC4__ServiceLine__r.LastModifiedBy.Name From HC4__ProviderScore__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmProviderScoreController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       
       return sql;
    }
    
    global class ProviderScore {
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY : this.id; } set; }
    	public String name { get { return String.isBlank(this.name) ? uString.EMPTY : this.name; } set; }
    	public String direction { get { return String.isBlank(this.direction) ? uString.EMPTY : this.direction; } set; }
    	public Decimal referralCalculatedCount { get { return this.referralCalculatedCount == null ? 0.0 : this.referralCalculatedCount; } set; }
    	public Decimal referralClaimCount { get { return this.referralClaimCount == null ? 0.0 : this.referralClaimCount; } set; }
    	public String referralLoyaltyScore { get { return String.isBlank(this.referralLoyaltyScore) ? uString.EMPTY : this.referralLoyaltyScore; } set; }
    	public String referralVolumeScore { get { return String.isBlank(this.referralVolumeScore) ? uString.EMPTY : this.referralVolumeScore; } set; }
    	public RestPrmServiceLineController.ServiceLine serviceLine { get; set; }
    	public DateTime createdDate { get; private set; }
    	public RestPrmUserController.RestUser createdBy { get; private set; }
    	public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
    	
    	public ProviderScore(HC4__ProviderScore__c p) {
    		this.id = p.Id;
    		this.name = p.Name;
    		this.direction = p.HC4__Direction__c;
    		this.referralCalculatedCount = p.HC4__ReferralCalculatedCount__c;
    		this.referralClaimCount = p.HC4__ReferralClaimCount__c;
    		this.referralLoyaltyScore = p.HC4__ReferralLoyaltyScore__c;
    		this.referralVolumeScore = p.HC4__ReferralVolumeScore__c;
    		this.serviceLine = String.IsBlank(p.HC4__ServiceLine__r.Id) ? null : new RestPrmServiceLineController.ServiceLine(p);
    		this.createdDate = p.CreatedDate;
    		this.createdBy = new RestPrmUserController.RestUser(p.CreatedBy.Id, p.CreatedBy.Name);
    		this.createdDate = p.LastModifiedDate;
            this.createdBy = new RestPrmUserController.RestUser(p.LastModifiedBy.Id, p.LastModifiedBy.Name);
    	}
    }
}