/* Copyright (c) 2008-2014 Evariant */
global with sharing class uRestController {
    public static final StatusCode OK = new StatusCode(200, 'OK');
    public static final StatusCode Created = new StatusCode(201, 'Created');
    public static final StatusCode Accepted = new StatusCode(202, 'Accepted');
    public static final StatusCode NoContent = new StatusCode(204, 'No Content');
    public static final StatusCode PartialContent = new StatusCode(206, 'Partial Content');
    public static final StatusCode MultipleChoices = new StatusCode(300, 'Multiple Choices');
    public static final StatusCode MovedPermanently = new StatusCode(301, 'Moved Permenantly');
    public static final StatusCode Found = new StatusCode(302, 'Found');
    public static final StatusCode NotModified = new StatusCode(304, 'Not Modified');
    public static final StatusCode BadRequest = new StatusCode(400, 'Bad Request');
    public static final StatusCode Unauthorized = new StatusCode(401, 'Unauthorized');
    public static final StatusCode Forbidden = new StatusCode(403, 'Forbidden');
    public static final StatusCode NotFound = new StatusCode(404, 'Not Found');
    public static final StatusCode MethodNotAllowed = new StatusCode(405, 'Method, Not Allowed');
    public static final StatusCode NotAcceptable = new StatusCode(406, 'Not Acceptable');
    public static final StatusCode Conflict = new StatusCode(409, 'Conflict');
    public static final StatusCode Gone = new StatusCode(410, 'Gone');
    public static final StatusCode PreconditionFailed = new StatusCode(412, 'Precondition Failed');
    public static final StatusCode RequestEntityTooLarge = new StatusCode(413, 'Request Entity Too Large');
    public static final StatusCode RequestUriTooLarge = new StatusCode(414, 'Request Uri Too Large');
    public static final StatusCode UnsupportedMediaType = new StatusCode(415, 'Unsupported Media Type');
    public static final StatusCode ExpectationFailed = new StatusCode(417, 'Expectation Failed');
    public static final StatusCode InternalServerError = new StatusCode(500, 'Internal Server Error');
    public static final StatusCode ServerUnavailable = new StatusCode(503, 'Server Unavailable');
    
    private static final String ErrorResponseTemplate = '{"status":{0}, "message":"{1}"}';  
    
    public enum UserType { ModifiedBy, CreatedBy, Owner }
    
    private static final Map<String, Map<String,Schema.SObjectField>> sObjectFieldMapping = new Map<String, Map<String,Schema.SObjectField>>();
    
    public static RestRequest request {
        get {
            return RestContext.request;
        }
    }
    
    public static RestResponse response {
        get {
            return RestContext.response;
        }
    }
    
    public static String objectId {
        get {
        	String id = uRestController.request.requestURI.substring(uRestController.request.requestURI.lastIndexOf('/') + 1);
            return uRestController.request.resourcePath.toLowerCase().contains(id.toLowerCase()) ? uString.EMPTY : id;
        }
    }
    
    public static String getParentObjectId(String objectName) {
        if(!objectName.endsWith('/')) {
        	objectName += '/';
        }
        
        Integer subStringStart = uRestController.request.requestURI.lastIndexOf(objectName) + objectName.length();
        Integer subStringEnd = uRestController.request.requestURI.indexOf('/', subStringStart);
        
        return uRestController.request.requestURI.substring(subStringStart, subStringEnd);
    }
    
    public static String getParameterValue(String key) {
        if(uRestController.request.params.containsKey(key)) {
            return uRestController.request.params.get(key);
        }
        
        return uString.EMPTY;
    }
    
    public static void setStatusCode(StatusCode c) {
        uRestController.setStatusCode(c, c.message);
    }
    
    public static void setStatusCode(StatusCode c, String message) {
    	uRestController.response.statusCode = c.code;
    	
    	String errorBody = uRestController.ErrorResponseTemplate.replace('{0}', String.valueOf(c.code)).replace('{1}', message);
    	uRestController.response.responseBody = Blob.valueOf(errorBody);
    }
    
    public static String searchValue {
        get {
            return uRestController.getParameterValue('q');
        }
    }
    
    public static Integer offset {
        get {
            String s = uRestController.getParameterValue('offset');
            if(String.IsBlank(s)) {
                return 0;
            }
            
            return Integer.valueOf(s);
        }
    }
    
    public static String sortBy {
    	get {
    		return uRestController.getParameterValue('sort');
    	}
    }
    
    public static void putSortBy(string value) {
    	if(String.isBlank(uRestController.sortBy)) {
    		RestContext.request.params.put('sort', value);
    	}
    }
    
    public static Integer pageSize {
        get {
            return uRestController.getPageSize(1000);
        }
    }
    
    public static Integer getPageSize(Integer defaultValue) {
    	String s = uRestController.getParameterValue('pageSize');
        if(String.IsBlank(s)) {
            return defaultValue;
        }
        
        return Integer.valueOf(s);
    }
    
    public static void setLocationHeader(String id) {
    	String sUrl = uRestController.request.requestURI;
    	if(!sUrl.endsWith('/')) {
    		sUrl += '/';
    	}
    	
    	sUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest' + sUrl + id;
    	uRestController.response.addHeader('Location', sUrl);
    }
    
    public static void setPagingHeaders(Integer iPageSize, Integer iOffset, Integer collectionSize) {
    	if((collectionSize == 0 || collectionSize < iPageSize)) {
    		return;
    	}
    	
    	String sPageSize ='pageSize=' + iPageSize;
    	String sOffset = 'offset=' + (iOffset + collectionSize);
    	
		String urlBase = uRestController.request.requestURI;
		
        urlBase = urlBase + '?' + sOffset + '&' + sPageSize;
        
        Map<String, String> paramsCopy = new Map<String, String>(uRestController.request.params); 
        paramsCopy.remove('pageSize');
        paramsCopy.remove('offset');
        
        Set<String> queryParams = new Set<String>();
        for(String key : paramsCopy.keySet()) {
        	queryParams.add(key + '=' +  paramsCopy.get(key));
        }
        
        urlBase = urlBase + ((queryParams.size() > 0) ? ('&' + HC4.uSet.join(queryParams, '&')) : uString.EMPTY);
        String testUrl = URL.getSalesforceBaseUrl().toExternalForm();
        testUrl += ('/services/apexrest' + urlBase);
		uRestController.response.addHeader('Next', testUrl);
		uRestController.setStatusCode(uRestController.PartialContent);
    }
    
    public static String getPRMActivityAPIName(String objectName) {
        String fieldAPIName = uString.EMPTY;        
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName});
		String objectLabel = describeSobjectsResult[0].getLabel();
		Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();		
        for(Schema.SObjectField field : allFields.values()){
            String name = String.valueOf(field);
            if(name.contains('PRMGoActivity__c')){
            	if(name.contains('HC4M__')){
            		fieldAPIName = name;	
            	}
            	else{
            		fieldAPIName = 'PRMGoActivity__c';
            	}
                break;
            }        	
        }    	
    	return fieldAPIName;	
    }
    
    public static Map<String,String> remapFields(Map<String, String> propertyMap) {
        Map<String, String> remappedFields = new Map<String, String>();
        for(String key : propertyMap.keySet()) {
            remappedFields.put(propertyMap.get(key), key);
        }
        
        return remappedFields;	
    }
    
    public static Map<String, List<uRestController.PicklistEntry>> getPickListValues(SObjectType objectType, Map<String, String> fieldMap) {
        Map<String, List<uRestController.PicklistEntry>> theValues = new Map<String, List<uRestController.PicklistEntry>>();
    	Schema.DescribeSObjectResult describe = objectType.getDescribe();
    	
		Map<String, Schema.SObjectField> objectFields = describe.fields.getMap();
		for(String fieldName : objectFields.keySet()) {
			Schema.SObjectField field = objectFields.get( fieldName );
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if(fieldDescribe.getType() == DisplayType.Picklist && fieldMap.containsKey(fieldName)) {
            	List<uRestController.PicklistEntry> pickListValues = new List<uRestController.PicklistEntry>();
            	theValues.put(fieldMap.get(fieldName), pickListValues);
            	
            	for(Schema.PicklistEntry e : fieldDescribe.getPicklistValues()) {
	                pickListValues.add(new uRestController.PicklistEntry(e));
	            }
            }
		}
    	
    	return theValues;	
    }
    
    /* **************************** Dependent Picklist values ************************************************
    *  Reference : http://titancronus.com/blog/2014/05/01/salesforce-acquiring-dependent-picklists-in-apex/
    *  ***************************** *********************** ***********************************************
    */
    
     /*
     * @Summary: Entity to represent a json version of a picklist entry
     * so that the validFor property becomes exposed
    */
    public class TPicklistEntry{
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
        public TPicklistEntry(){
            
        }
    }
    
    public class Bitset{
        public Map<String,Integer> AlphaNumCharCodes {get;set;}
        public Map<String, Integer> Base64CharCodes { get; set; }
        public Bitset(){
            LoadCharCodes();
        }
        //Method loads the char codes
        private void LoadCharCodes(){
            AlphaNumCharCodes = new Map<String,Integer>{
                'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
                'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
                'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90    
            };
			
			//chars - PRM-546
            Base64CharCodes = new Map<String, Integer>{
            '/' =>63, ' ' =>32, '!' =>33, '"' =>34, '#' =>35, '$' =>36, '%' =>37, '&' =>38, '\'' =>39, '(' =>40,
            ')' =>41, '*' =>42, '+' =>43, ',' =>44, '-' =>45, '.' =>46, '/' =>47, ':' =>58, ';' =>59, '<' =>60,
            '=' =>61, '>' =>62, '?' =>63, '@' =>64, '[' =>91, '\\' =>92, ']' =>93, '^' =>94, '_' =>95, ' ' =>96,
            '{' =>123, '|' =>124, '}' =>125, '~' =>126
            };
			
            //lower case
            Set<String> pUpperCase = AlphaNumCharCodes.keySet();
            for(String pKey : pUpperCase){
                //the difference between upper case and lower case is 32
                AlphaNumCharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey)+32);
                //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
                Base64CharCodes.put(pKey,AlphaNumCharCodes.get(pKey) - 65);
                Base64CharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey) - (65) + 26);
            }
            //numerics
            for (Integer i=0; i<=9; i++){
                AlphaNumCharCodes.put(string.valueOf(i),i+48);
                //base 64 numeric starts from 52
                Base64CharCodes.put(string.valueOf(i), i + 52);
            }
        }
        /*
        	Effect: Method takes a validFor string and tests it against a set of controlling indexes
        	Postcondition: Returns a list of all controlling indexes for which the validFor string test True
        */
        public List<Integer> testBits(String pValidFor,List<Integer> nList){
        	List<Integer> results = new List<Integer>();
			//the list of bytes (not derived from n)
            List<Integer> pBytes = new List<Integer>();
            //multiply by 6 since base 64 uses 6 bits (not derived form n)
            Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
            //will be used to hold the full decimal value (not derived from n)
            Integer pFullValue = 0;
            //must be more than 1 byte
            if (bytesBeingUsed <= 1)
                return results;
            //get the base64bytes
            for(Integer i=0;i<pValidFor.length();i++){
                //get currenct character value
                pBytes.Add((Base64CharCodes.get((pValidFor.Substring(i, i+1)))));
            }   
            //calculate the full decimal value
            for (Integer i = 0; i < pBytes.size(); i++)
            {
                Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value
                pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
            }
            //now we don't want to always be declaring memory, so let's set the initial 
            //variables
            Integer bit;
            Integer targetOctet;
            Integer shiftBits;
            Integer tBitVal;
            Integer n;
            Integer nListSize = nList.size();
            for(Integer i=0; i<nListSize; i++){
            	n = nList[i];
	            //calculate the target bit for comparison
	            bit = 7 - (Math.mod(n,8)); 
	            //calculate the octet that has in the target bit
	            targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed); 
	            //the number of bits to shift by until we find the bit to compare for true or false
	            shiftBits = (targetOctet * 8) + bit;
	            //& is to set the same set of bits for testing
				//shift to the bit which will dictate true or false
				//Math.Pow(2, shiftBits) == 2 << (shiftBits+1)
	            tBitVal = ((Integer)(2 << (shiftBits-1)) & pFullValue) >> shiftBits;
	            if (tBitVal==1)
	            	results.add(n);
            }
            return results;
        }
        
    }
    
    public static Map<String,List<String>> getDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName){
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!Schema.getGlobalDescribe().containsKey(pObjName))
            return objResults;
        //get the type being dealt with
        Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
        return getDependentOptionsImpl(pType,pControllingFieldName,pDependentFieldName);        
    }
    
    public static Map<String,List<String>> getDependentOptionsImpl(Schema.SObjectType pType, String pControllingFieldName, String pDependentFieldName){
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        if (pType==null)
            return objResults;
        uRestController.Bitset BitSetInstance = new uRestController.Bitset();
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName))
            return objResults;     
        //get the control values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        //get the dependent values
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> lstControllingIndexes = new List<Integer>();
        //iterate through the values and get the ones valid for the controlling field name
        //set up the results
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){        	
            //get the pointer to the entry
            Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
            //get the label
            String pControllingLabel = ctrl_entry.getLabel();
            //create the entry with the label
            objResults.put(pControllingLabel,new List<String>());
            //keep track of the controlling indexes
            lstControllingIndexes.add(pControllingIndex);
        }        
        //load all dep entries
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<uRestController.TPicklistEntry> objDS_Entries = new List<uRestController.TPicklistEntry>();
        //add all entries
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){        	
            //get the pointer to the dependent index
           	Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
           	objEntries.add(dep_entry);
           	
        } 
        //serialize once        
        objDS_Entries = (List<uRestController.TPicklistEntry>)JSON.deserialize(JSON.serialize(objEntries), List<uRestController.TPicklistEntry>.class);
        List<Integer> validIndexes;
        for (uRestController.TPicklistEntry objDepPLE : objDS_Entries){
        	//if valid for is empty, skip    
            if (objDepPLE.validFor==null || objDepPLE.validFor==''){
                continue;
            }
            //get the test for the controlling indexes
            validIndexes = BitSetInstance.testBits(objDepPLE.validFor,lstControllingIndexes);
            for (Integer validIndex : validIndexes){            	
	            //get the label
	            String pControllingLabel = ctrl_ple[validIndex].getLabel();
                objResults.get(pControllingLabel).add(objDepPLE.label);
            }
        }
        objEntries = null;
        objDS_Entries = null;        
        return objResults;
    }
    
    /* ********************************
       ****Dependent Picklist values*****
       ********************************
    */
    
    
    /*
      Parse the Datetime to GMT from the JSON input
    */    
    public static DateTime getDateTime(String jsonDatetime)
    {   
        DateTime dt;        
        if(!String.isBlank(jsonDatetime)){
            /*String sTemp = (jsonDatetime.replace('Z', '')).replace('T',' ');
            dt = DateTime.valueOf(sTemp);
            dt = Datetime.newInstance(dt.year(), dt.month(), dt.day(), dt.hour(), dt.minute(), dt.second()); */   
            dt = (DateTime) JSON.deserialize('"' + jsonDatetime + '"', DateTime.class);        
        }
        
        return dt;
    }
    /*
      Parse the Date to GMT from the JSON input
    */
    public static Date getDate(String jsonDatetime)
    {   
        Date dt;        
        if(!String.isBlank(jsonDatetime)){        	
            String sTemp = (jsonDatetime.replace('Z', '')).replace('T',' ');
            dt = Date.valueOf(sTemp);
        }       
        return dt;
    }
    
    /*
     * Create the object fields for a specified fieldset and object 
    */
    public static uRestController.GenericGetResponse getView(String sobjectName, String fs, String objectLabel) {
    	    	
    	uRestController.GenericGetResponse result = new uRestController.GenericGetResponse();
    	
    	result.fieldsInfo = new List<uRestController.FieldsDescribe>(); 
    	
    	Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(sobjectName);
	    if(SObjectTypeObj != null){
	    	Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
		    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fs); 	       	    	
	    	result.name = String.valueOf(DescribeSObjectResultObj.getName()); 
	    	result.label = objectLabel; 	
	    	result.isReadOnly = !(DescribeSObjectResultObj.isAccessible() && DescribeSObjectResultObj.isCreateable());
	    	//Adding OwnerId as default to logged in user
	    	result.Owner  = new RestPrmUserController.RestUser(UserInfo.getUserId(), UserInfo.getName());  	    	
	    	
	    	for(Schema.FieldSetMember fsm : fieldSetObj.getFields()){    		 
	 			result.fieldsInfo.add(new uRestController.FieldsDescribe(fsm, null, sobjectName));   			
	    	}
	    }
	    else{	    	
	    	uRestController.setStatusCode(uRestController.Forbidden, 'You do not have the permission to access this object.');
            return null;
	    }
		
    	return result;
   }
   
    public static String getFieldSetName(String objectName, String fieldSetLabel){
    	String fieldsetName = uString.Empty;	
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
		Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
		Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
		
		for(Schema.FieldSet fs : DescribeSObjectResultObj.FieldSets.getMap().values()){
			if(!String.isBlank(fs.getNameSpace()) && fs.getLabel() == fieldSetLabel){
			   fieldsetName = fs.getNameSpace() + '__' + fs.getName(); 
			   break;
			}
			else{
				if(fs.getLabel() == fieldSetLabel){
					fieldsetName = fs.getName();
					break;
				}
			}
		}
		return fieldsetName; 			       
	}
	
    /*
     * Read the fieldset memebers for object and a specified fieldset 
    */
    public static List<Schema.FieldSetMember> getFieldSetMembers(String fieldSetName, String objectName) {	
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
	    if(SObjectTypeObj != null){
	    	Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
		    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
		    return fieldSetObj.getFields(); 
	    }
	    else{
	    	uRestController.setStatusCode(uRestController.Forbidden, 'You do not have the permission to access this object.');
            return null;
	    }	    
	}
	
	/*
     * Read the fieldset memebers for object and a specified fieldset 
    */
    public static Map<String, Schema.FieldSetMember> getFSMembers(String fieldSetName, String objectName) {	
	    Map<String, Schema.FieldSetMember> fsm = new Map<String, Schema.FieldSetMember>();  
	    
	    for(Schema.FieldSetMember field : uRestController.getFieldSetMembers(fieldSetName, objectName)){
	    	fsm.put(field.getFieldPath(),field);
	    }
	    
	    return fsm; 
	}
	
	/*
     * Read the fieldset memebers for object and a specified fieldset 
    */
    public static Map<String, Schema.FieldSetMember> getRequiredFields(String fieldSetName, String ObjectName) { 	
	    	Map<String, Schema.FieldSetMember> requiredFields = new Map<String, Schema.FieldSetMember>();
        	Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
		    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
		    if(SObjectTypeObj != null){
		    	Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
			    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);  
			    	
		    	for(Schema.FieldSetMember fsm : fieldSetObj.getFields()){	    		
		    		if(fsm.getDbRequired() || fsm.getRequired()){
		    			requiredFields.put(fsm.getFieldPath(), fsm);
		    		}
		    	}
		    }
		    else{
		    	uRestController.setStatusCode(uRestController.Forbidden, 'You do not have the permission to access this object.');
            	return null;
		    }		    
	    	
	    	return requiredFields;
	}  
    
    public static String getDefaultPicklistValue(Schema.DescribeFieldResult fieldDescribe) {
    	if(fieldDescribe.getType() == DisplayType.Picklist || fieldDescribe.getType() == DisplayType.Combobox) {
    		for(Schema.PicklistEntry e : fieldDescribe.getPicklistValues()) {
    			if(e.isDefaultValue()) {
    				return e.getValue();
    			}
    		}
    	}
    	
    	return uString.EMPTY;
    }
    
    //Phab Fix - T1820 - Added New Overloaded method for sorting
    public static String decodeSortForSoql(String defaultValue, Map<String, String> propertyMap) {    
   		return uRestController.decodeSortForSoql(defaultValue, propertyMap, new Map<String,String>());
    }
        
    public static String decodeSortForSoql(String defaultValue, Map<String, String> propertyMap, Map<String,String> objectToSF) {    
    	String sortOrder = uRestController.sortBy;

    	if(String.isBlank(sortOrder)) {
    		sortOrder = defaultValue;
    	}
    	
		propertyMap.putAll(objectToSF);
		
    	List<String> soqlInstructions = new List<String>();
    	
    	List<String> sortInstructions = sortOrder.split(';');
    	for(String s : sortInstructions) {
    		String direction = ' ASC';
	        if(s.startsWith('-')) {
	            direction = ' DESC';
	            s = s.replaceFirst('-', uString.EMPTY);
	        }

	        if(propertyMap.containsKey(s)) {
	           soqlInstructions.add(propertyMap.get(s) + direction);
	        }
    	}
    	
    	if(soqlInstructions.size() > 0) {
    		return ' ORDER BY ' + HC4.uList.join(soqlInstructions, ',');
    	}
    	
    	return uString.EMPTY;
    }
   
   public static List<String> propertyMapToSoql(Map<String, String> propertyMap, String objectName) {
   	    return uRestController.propertyMaptoSoql(propertyMap, objectName, new Set<String>()); 
   }
   
   public static List<String> propertyMapToSoql(Map<String, String> propertyMap, String objectName, Set<String> ignoredProperties) {
   	   List<String> conditions = new List<String>();
       for(String fieldName : propertyMap.keySet()) {
           String paramValue = uRestController.getParameterValue(fieldName);
           if(!String.isBlank(paramValue) && !ignoredProperties.contains(fieldName)) {
              conditions.add(new HC4.uCondition(objectName, propertyMap.get(fieldName), '=', paramValue).toSql());
           }
       }
       
       return conditions;
   }   
      
   public class StatusCode {
        public Integer code { get;  set; }
        public String message { get;  set; }
        
        private StatusCode(Integer value, String message) {
            this.code = value;
            this.message = message;
        }
    }
    
    global class PicklistEntry {
    	public String label { get; private set; }
    	public String value { get; private set; }
    	public Boolean isDefault { get; private set; }
    	
    	public PicklistEntry(Schema.PicklistEntry e) {
    		this.label = e.getLabel();
    		this.value = e.getValue();
    		this.isDefault = e.isDefaultValue();
    	}
    }
    
    
    /**
     * Generic response class for Records
     *
     *
     **/
     
    global class GenericGetResponse {    	
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY : this.id; } set; }
    	public String name { get { return String.isBlank(this.name) ? uString.EMPTY : this.name; } set; }
    	public String label { get { return String.isBlank(this.label) ? uString.EMPTY : this.label; } set; }
    	public RestPrmUserController.RestUser owner { get; set; }
    	public DateTime createdDate { get; set; }
	    public RestPrmUserController.RestUser createdBy { get; set; }
    	public DateTime lastModifiedDate { get; set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; set; }
        public Boolean isReadOnly { get; set; }
    	public List<FieldsDescribe> fieldsInfo { get; set; }
    	public uRestController.StatusCode responseCode { get; set; }
    	public String responseMessage { get { return String.isBlank(this.responseMessage) ? uString.EMPTY : this.responseMessage; } set; }    	
    	
    	public GenericGetResponse(){
    		fieldsInfo = new List<FieldsDescribe>();
    	}
    	    	
    	public GenericGetResponse(String objectName){
    		String[] types = new String[]{ objectName };
    		Schema.DescribeSobjectResult[] dsr = Schema.describeSObjects(types);
    		this.name = dsr[0].getName();
    		this.label = dsr[0].getLabel(); 
    	}
    	
    	public GenericGetResponse(Sobject obj, String fsName, String label){ 
    		this.id = obj.Id;     		
    		List<ID> objIds = new List<ID>();
    		objIds.add(obj.Id);    		
    		Schema.SObjectType objectype = objIds[0].getSObjectType();
    		Schema.DescribeSObjectResult dsr = objectype.getDescribe();     		 
    		this.name = dsr.getName();
    		this.label = label;     		    		 
    		this.owner = (obj.get('OwnerId') != null)? new RestPrmUserController.RestUser(obj, uRestController.UserType.Owner.name()) : null; 
    		this.createdDate = DateTime.valueOf(obj.get('CreatedDate'));
    		this.lastModifiedBy = new RestPrmUserController.RestUser(obj, uRestController.UserType.ModifiedBy.name());
    		this.createdBy = new RestPrmUserController.RestUser(obj, uRestController.UserType.CreatedBy.name()); 
            this.lastModifiedDate = DateTime.valueOf(obj.get('LastModifiedDate'));            
            this.isReadOnly = (obj.get('OwnerId') != UserInfo.getUserId());
            List<String> options = new List<String>();
            List<FieldsDescribe> fieldValue = new List<FieldsDescribe>();
            
	    	for(Schema.FieldSetMember fsm : getFieldSetMembers(fsName,this.name)){	    			 			
	    		fieldValue.add(new FieldsDescribe(fsm, String.valueOf(obj.get(fsm.getFieldPath())),this.name));
	    	}    
             
            if(fieldValue.size()> 0){
            	this.fieldsInfo = fieldValue; 
            } 		
    	}
    	
    	public GenericGetResponse RecordItem(String recordId, String fsName, String label){
    		GenericGetResponse rt;
    		List<ID> objIds = new List<ID>();
    		objIds.add(recordId);
    		
    		Schema.SObjectType objectype = objIds[0].getSObjectType();
    		Schema.DescribeSObjectResult dsr = objectype.getDescribe();     		
    		
    		String sql = 'Select Id';
	    	for(Schema.FieldSetMember fsm : getFieldSetMembers(fsName, dsr.getName())){
	 			sql += ',' + fsm.getFieldPath();  		 
	    	}
	    	
	    	if(dsr.getName() == 'Task'){ // Include these fileds only for Task/Call
	    		sql += ', Who.Id, Who.Name, What.Id, What.Name, IsClosed';
	    		
	    		if(!sql.contains('ActivityDate')){
	    			sql += ', ActivityDate ';
	    		}
	    	}
	    		    	
	    	sql += ', Owner.Id, Owner.Name, CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from ' + dsr.getName();  
	    	
	    	if(!String.isBlank(recordId)) {
	    		sql += ' WHERE Id = :recordId';
	    	}
	    	
        	sql += ' LIMIT :pageSize OFFSET :offset';
	    	
	    	List<sObject> result = Database.query(sql);	    	
	    	if(result != null && !result.isEmpty()){	    		
	    		rt = new GenericGetResponse(result[0], fsName, label);	    		
	    	}
	    		    	
            return rt;	
    	}
    	
    	public List<GenericGetResponse> RecordItem(List<Sobject> tasks, String fsName, String label) {
    		List<GenericGetResponse> lstTask = new List<GenericGetResponse>(); 
    		GenericGetResponse rt;
	    	if(tasks != null && tasks.size() > 0){
	    		for(Sobject t : tasks){
		    		lstTask.add(new GenericGetResponse(t, fsName, label)); 
	    		}
	    	}	    		    	    	
            return lstTask;	
    	}
    	
    }
    
    /*
     * This Response class will be used for Listview display for Tasks/Calls/Issues/Notes
     * Search filters, Paging will be supported as is
     */
    global class GenericGetListResponse {
    	    	
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY : this.id; } set; }
    	public String title { get { return String.isBlank(this.title) ? uString.EMPTY : this.title; } set; }
    	public String name { get { return String.isBlank(this.name) ? uString.EMPTY : this.name; } set; }
    	public String description { get { return String.isBlank(this.description) ? uString.EMPTY : this.description; } set; }
    	public String parentType { get { return String.isBlank(this.parentType) ? uString.EMPTY: this.parentType; } set; }
    	public String parentObject { get { return String.isBlank(this.parentObject) ? uString.EMPTY: this.parentObject; } set; }    	
		public String parentName { get { return String.isBlank(this.parentName) ? uString.EMPTY: this.parentName; } set; }		
    	public RestPrmUserController.RestUser owner { get; set; }
    	public RestPrmUserController.RestUser createdBy { get; private set; }
    	public DateTime createdDate { get; private set; }
    	public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
    	public Boolean flag { get { return (this.flag == null) ? false: this.flag; } set; }
    	public Boolean isEscalated  { get { return (this.isEscalated  == null) ? false: this.isEscalated; } set; }
    	public Boolean isClosed { get { return (this.isClosed == null) ? false: this.isClosed; } set; }
    	public Boolean isReadOnly { get; private set; } 
    	public String alertDate { get;  set; }
    	public GenericGetListResponse(){
    		
    	}
    	
    	public GenericGetListResponse(Task t, String name, String label){
    		this.id = t.Id;
    		this.title = t.Subject;
    		this.name = label;
    		this.description = t.Description; 
    		this.owner = String.IsBlank(t.Owner.Id) ? null : new RestPrmUserController.RestUser(t);
    		this.createdBy = new RestPrmUserController.RestUser(t.CreatedBy.Id, t.CreatedBy.Name);
    		this.createdDate = t.CreatedDate;
    		this.lastModifiedBy = new RestPrmUserController.RestUser(t.LastModifiedBy.Id, t.LastModifiedBy.Name);
    		this.lastModifiedDate = t.LastModifiedDate;
    		this.flag  = (t.Priority == 'High')? true: false;
    		this.isClosed = t.IsClosed;
    		this.isReadOnly = (t.OwnerId != UserInfo.getUserId());
    		this.alertDate = (t.ActivityDate == null ? uString.Empty : String.valueOf(t.ActivityDate)); 
    		if(!String.isBlank(t.WhoId)){
    			ID recId = t.WhoId;					
				Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{recId.getSObjectType().getDescribe().getName()});			
				this.parentType = results[0].getLabel();
				this.parentName = t.Who.Name; 
				this.parentObject = results[0].getName();
    		}
    		
    		if(!String.isBlank(t.WhatId)){
    			ID recId = t.WhatId;					
				Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{recId.getSObjectType().getDescribe().getName()});			
				this.parentType = results[0].getLabel();
				this.parentName = t.What.Name; 
				this.parentObject = results[0].getName();
    		}   		
    		
    		
    	}
    	
    	public GenericGetListResponse(HC4__Issue__c i, String name, String label){
    		this.id = i.Id;
    		this.name = label;
    		this.title = i.HC4__Subject__c;
    		this.description = i.HC4__LongDescription__c; 
    		this.owner = String.IsBlank(i.Owner.Id) ? null : new RestPrmUserController.RestUser(i);
    		this.createdBy = new RestPrmUserController.RestUser(i.CreatedBy.Id, i.CreatedBy.Name);
    		this.createdDate = i.CreatedDate;
    		this.flag  = (i.HC4__Priority__c == 'High')? true: false;
    		this.isEscalated = (i.HC4__Status__c == 'Escalated')? true: false;
    		this.isClosed = i.HC4__IsClosed__c;            
            this.isReadOnly = (i.OwnerId != UserInfo.getUserId());
            this.lastModifiedBy = new RestPrmUserController.RestUser(i.LastModifiedBy.Id, i.LastModifiedBy.Name);
    		this.lastModifiedDate = i.LastModifiedDate;
    		this.alertDate = (i.CreatedDate).formatLong(); 
            if(!String.isBlank(i.HC4__Patient__c)){
    			ID recId = i.HC4__Patient__c;					
				Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{recId.getSObjectType().getDescribe().getName()});			
				this.parentType = results[0].getLabel();
				this.parentName = i.HC4__Patient__r.Name; 
				this.parentObject = results[0].getName();
    		}
    		
    		if(!String.isBlank(i.HC4__Provider__c)){
    			ID recId = i.HC4__Provider__c;					
				Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{recId.getSObjectType().getDescribe().getName()});			
				this.parentType = results[0].getLabel();
				this.parentName = i.HC4__Provider__r.Name;
				this.parentObject = results[0].getName(); 
    		}    		
    	}
    	
    	public GenericGetListResponse(Note n, String name, String label){
    		this.id = n.Id;
    		this.name = label;
			this.owner = String.IsBlank(n.Owner.Id) ? null : new RestPrmUserController.RestUser(n);
			this.parentName = n.Parent.Name; 			
			Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{n.Parent.Type});			
			this.parentType = results[0].getLabel();
			this.parentObject = results[0].getName();					
			this.title = n.Title;
			this.description = n.Body;
			this.flag = false;
			this.createdDate = n.CreatedDate;
			this.createdBy = new RestPrmUserController.RestUser(n.CreatedBy.Id, n.CreatedBy.Name);
			this.lastModifiedBy = new RestPrmUserController.RestUser(n.LastModifiedBy.Id, n.LastModifiedBy.Name);
    		this.lastModifiedDate = n.LastModifiedDate;
			this.isReadOnly = (n.OwnerId != UserInfo.getUserId());
    	}    		    
    }
    
    /*
     * Generic RestReponse class for Detail Record level    
    */
    global class FieldsDescribe {
    	public String name { get { return String.isBlank(this.name) ? uString.EMPTY : this.name; } set; }  
    	public String label { get { return String.isBlank(this.label) ? uString.EMPTY : this.label; } set; }
    	public String fieldType { get { return String.isBlank(this.fieldType) ? uString.EMPTY : this.fieldType; } set; }
    	public String value { get { return String.isBlank(this.value) ? uString.EMPTY : this.value; } set; } 
    	public List<String> options { get; set; }
    	public Boolean dependentPicklist { get { return (this.dependentPicklist == null) ? false: this.dependentPicklist; } set; }
    	public String controllingFieldName { get { return (this.controllingFieldName == null) ? uString.EMPTY: this.controllingFieldName; } set; }
    	public String controllingFieldLabel { get { return (this.controllingFieldLabel == null) ? uString.EMPTY: this.controllingFieldLabel; } set; }
    	public Map<String,List<String>> dependentListOptions { get { return (this.dependentListOptions == null) ? new Map<String,List<String>>() : this.dependentListOptions; } set; }  	
    	public String defaultVal { get { return String.isBlank(this.defaultVal) ? uString.EMPTY : this.defaultVal; } set; }
    	public Boolean isRequired { get; private set; }
    	public Boolean isReadOnly { get; private set; }
    	public String parentId { get { return String.isBlank(this.parentId) ? uString.EMPTY: this.parentId; } set; }
		public String parentName { get { return String.isBlank(this.parentName) ? uString.EMPTY: this.parentName; } set; }
		public String parentType { get { return String.isBlank(this.parentType) ? uString.EMPTY: this.parentType; } set; }
		public String parentObject { get { return String.isBlank(this.parentObject) ? uString.EMPTY: this.parentObject; } set; }
    	
    	public FieldsDescribe(){
    		
    	}
    	

    	public FieldsDescribe(String fieldName, String fieldLabel, String value, Boolean isReadonly, Boolean isRequired, Schema.DisplayType dt){
    		this.name = fieldName;
    		this.label = fieldLabel;
    		this.value = value;
    		this.isReadOnly = isReadonly; 
    		this.isRequired = isRequired; 
    		this.fieldType =  String.valueOf(dt);
    	}
    	
    	public FieldsDescribe(String fieldName, String value){
    		this.name = fieldName;
    		this.value = value;    		
    	}
    	
    	
    	public FieldsDescribe(String  objectName){
    		String[] types = new String[]{ objectName };
    		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
    		this.name = results[0].getName();
    		this.label = results[0].getLabel();
    		this.parentObject = results[0].getName();
    	}
    	
    	public FieldsDescribe(Schema.FieldSetMember fsm, String value, String objectName){
    		
    		Map<String,Schema.SObjectField> objectFields = null;
    		
    		String fieldPath = (fsm.getFieldPath() != null)? fsm.getFieldPath() : uString.Empty; 
    		
    		if(!String.isBlank(fieldPath)){
    			fieldPath = fieldPath.replace('HC4M__',uString.EMPTY); //PRM-439
    		}
    		
    		if(uRestController.sObjectFieldMapping.containsKey(objectName)) {
    			objectFields = uRestController.sObjectFieldMapping.get(objectName);
    		} else {
    			SObjectType describe = Schema.getGlobalDescribe().get(objectName);
                objectFields = describe.getDescribe().fields.getMap();
                uRestController.sObjectFieldMapping.put(objectName, objectFields);
            }
            
                if(objectFields.get(fieldPath) != null){ // If field is Accessible then Proceed,else filed is read only  
                    Schema.SObjectField field = objectFields.get(fieldPath);
                    
                    if(field != null){
                        Schema.DescribeFieldResult fieldDescribe = field.getDescribe(); 
                        this.isReadOnly = false;                            
                        this.name = fsm.getFieldPath();
                        this.label = fsm.getLabel();
                        //PRM-443
                        if(this.name == 'ActivityDate' && objectName == Schema.SObjectType.Task.getName()){
                            this.label = 'Due Date';
                        } else if(this.name == 'Description' && objectName == Schema.SObjectType.Task.getName()){
                            this.label = 'Comments';
                        } else if(this.name == 'ReminderDateTime' && objectName == Schema.SObjectType.Task.getName()){
                            this.label = 'Reminder';
                        } else if(this.name == 'OwnerId' && objectName == Schema.SObjectType.Task.getName()){
                            this.label = 'Assigned To';
                        } else if(this.name == 'OwnerId' && objectName == Schema.SObjectType.Task.getName()){
                            this.label = 'Assigned To';
                        } else if(this.name == 'WhoId' && objectName == Schema.SObjectType.Task.getName()){
                            this.label = 'Name';
                        } else if(this.name == 'WhatId' && objectName == Schema.SObjectType.Task.getName()){
                            this.label = 'Related To';
                        }
                    
                        this.fieldType =  String.valueOf(fsm.getType()); 
                        this.value =  value; 
                                    
                        if(fsm.getType() == Schema.DisplayType.MultiPicklist || fsm.getType() == Schema.DisplayType.Picklist || fsm.getType() == Schema.DisplayType.Combobox) {
                            for(String fieldName : objectFields.keySet()) {                 
                                if(fsm.getFieldPath() == this.name && ( fieldDescribe.getType() == DisplayType.Picklist || fieldDescribe.getType() == DisplayType.MultiPicklist || fsm.getType() == DisplayType.Combobox)) {
                                    
                                    List<uRestController.PicklistEntry> pickListValues = new List<uRestController.PicklistEntry>();
                                    options = new List<String>();
                                    
                                    for(Schema.PicklistEntry e : fieldDescribe.getPicklistValues()) {
                                       options.add(e.getValue());
                                       if(e.isDefaultValue()){
                                            this.defaultVal = e.getValue(); 
                                       }                       
                                    }
                                    //PRM-446
                                    if(fieldDescribe.isDependentPicklist()){
                                        this.dependentPicklist = fieldDescribe.isDependentPicklist(); 
                                        this.controllingFieldName = String.valueOf(fieldDescribe.getController()); 
                                        Schema.SObjectField controlField = objectFields.get(this.controllingFieldName.replace('HC4M__',uString.EMPTY));
                                        Schema.DescribeFieldResult describecontrolField = controlField.getDescribe(); 
                                        this.controllingFieldLabel = describecontrolField.getLabel();
                                        this.dependentListOptions = getDependentOptions(objectName, controllingFieldName, this.name);
                                    }
                                }
                            }
                        }
                        
                        if(fsm.getType() == DisplayType.REFERENCE){ 
                            
                            if(!String.isBlank(value)){
                                ID recId = value;                   
                                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{recId.getSObjectType().getDescribe().getName()});         
                                this.parentType = results[0].getLabel();                        
                                this.parentId = value;
                                this.parentObject = results[0].getName();
                                String soql = 'Select Id, Name from ' + results[0].getName() + ' WHERE Id = :value  LIMIT 1';                       
                                List<sObject> parent = Database.query(soql);
                                
                                if(parent != null && !parent.isEmpty()){
                                    this.parentName = String.valueOf((parent[0]).get('Name'));
                                }
                            }
                            else {  // Address the default Values for Reference Types
                                if(fsm.getFieldPath() == 'WhatId'){                             
                                    this.name = 'WhatId'; 
                                    this.value = (!String.isBlank(uRestController.getParameterValue('PracticeId')))? uRestController.getParameterValue('PracticeId') : uString.EMPTY;
                                    String recId = this.value;  
                                    Schema.DescribeSObjectResult dsrAccount = Account.sObjectType.getDescribe();                                
                                    this.parentType = dsrAccount.getLabel();
                                    this.name = dsrAccount.getName();
                                    this.parentObject = dsrAccount.getName();
                                    this.parentId = (!String.isBlank(uRestController.getParameterValue('PracticeId')))? uRestController.getParameterValue('PracticeId') : uString.EMPTY;
                                    
                                    if(!String.isBlank(recId)){
                                        String soql = 'Select Id, Name from Account WHERE Id =: recId  LIMIT 1';                        
                                        List<sObject> parent = Database.query(soql);
                                        
                                        if(parent != null && !parent.isEmpty()){
                                            this.parentName = String.valueOf((parent[0]).get('Name'));
                                        }   
                                    }                               
                                }
                                else if(fsm.getFieldPath() == 'WhoId'){
                                    this.name = 'WhoId'; 
                                    this.value = (!String.isBlank(uRestController.getParameterValue('ProviderId')))? uRestController.getParameterValue('ProviderId') : uString.EMPTY;
                                    String recId = this.value; 
                                    Schema.DescribeSObjectResult dsrContact = Contact.sObjectType.getDescribe();                                
                                    this.parentType = dsrContact.getLabel();
                                    this.name = dsrContact.getName();
                                    this.parentObject = dsrContact.getName(); 
                                    this.parentId = (!String.isBlank(uRestController.getParameterValue('ProviderId')))? uRestController.getParameterValue('ProviderId') : uString.EMPTY;
                                    if(!String.isBlank(recId)){
                                        String soql = 'Select Id, Name from Contact WHERE Id =: recId  LIMIT 1';                        
                                        List<sObject> parent = Database.query(soql);
                                        
                                        if(parent != null && !parent.isEmpty()){
                                            this.parentName = String.valueOf((parent[0]).get('Name'));
                                        }   
                                    }
                                }
                                else if(fsm.getFieldPath() == 'OwnerId'){
                                    this.name = 'OwnerId'; 
                                    this.value = UserInfo.getUserId();
                                    Schema.DescribeSObjectResult dsrUser = User.sObjectType.getDescribe();
                                    ID recId = value;
                                    this.parentType = dsrUser.getLabel();
                                    this.name = 'OwnerId';                      
                                    this.parentId = this.value;
                                    this.parentObject = dsrUser.getName();
                                    this.parentName = UserInfo.getName();
                                }
                                else {
                                    this.value = uString.EMPTY;
                                    this.parentId = uString.EMPTY;
                                    this.parentName = uString.EMPTY;                            
                                    this.parentType = fsm.getLabel(); 
                                        
                                    if(fsm.getLabel() == 'Provider'){                           
                                        this.parentObject = 'Contact';
                                        this.value = (!String.isBlank(uRestController.getParameterValue('ProviderId')))? uRestController.getParameterValue('ProviderId') : uString.EMPTY;
                                        String recId = this.value; 
                                        if(!String.isBlank(recId)){
                                            String soql = 'Select Id, Name from Contact WHERE Id =: recId  LIMIT 1';                        
                                            List<sObject> parent = Database.query(soql);
                                            
                                            if(parent != null && !parent.isEmpty()){
                                                this.parentName = String.valueOf((parent[0]).get('Name'));
                                            }   
                                        }
                                    }
                                    
                                    if(!String.isBlank(fsm.getLabel())){
                                        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
                                        for(Schema.SObjectType f : gd){
                                            if(f.getDescribe().getLabel() == fsm.getLabel()){
                                                this.parentObject = f.getDescribe().getName();
                                                break; 
                                            }
                                        }
                                    }                                   
                                } 
                            }
                        }
                        
                        Restrequest req = RestContext.request;
                        String tz = uString.Empty;
                        if(!String.isBlank(req.headers.get('timezone'))){
                            tz = req.headers.get('timezone');   
                        }
                        
                        if(fsm.getType() == DisplayType.DateTime && !String.isBlank(value)){
                            if(String.isBlank(tz)){
                                this.value = JSON.serialize(DateTime.valueOf(value));
                            }
                            else{                                
                                DateTime dt = formatUserTimezone(value, tz);
                                this.value = JSON.serialize(formatUserTimezone(value, tz));
                            }
                            this.value = this.value.replace('"','');                            
                        }
                        if(fsm.getType() == DisplayType.Date && !String.isBlank(value)){
                        		this.value = DateTime.valueOf(value).format('yyyy-MM-dd');
                        }
                        
                        this.isReadOnly = !(fieldDescribe.isAccessible() && fieldDescribe.isUpdateable());
                        this.isRequired = fsm.getDbRequired() || fsm.getRequired();
                    }                                
                }
                else
                    this.isReadOnly = true;
        }
        
        public DateTime formatUserTimezone(String userDateTime, String userTimeZone){           
            string sfRecordDateTime = userDateTime;
            DateTime mobileDateTime = DateTime.valueofGmt(sfRecordDateTime);
            //system.debug(mobileDateTime);  // sfdc in gmt         
            TimeZone mobileTimeZone = TimeZone.getTimeZone(userTimeZone);           
            //system.debug(mobileTimeZone);            
            integer offsetToMobileTimeZone = mobileTimeZone.getOffset(mobileDateTime);
            TimeZone tz = UserInfo.getTimeZone();
            //system.debug(tz);            
            integer offsetToUserTimeZone = tz.getOffset(mobileDateTime);                     
            
            //integer correction = /*offsetToUserTimeZone -*/ offsetToMobileTimeZone;
            integer correction = 0;                      
            
            DateTime correctedDateTime = mobileDateTime;//.addMinutes;(correction / (1000 * 60));
            System.debug('correctedDateTime: ' + correctedDateTime);
            
            return correctedDateTime;
    }
     
    }
}