/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Inquiries/*')
global with sharing class RestPrmInquiryController {
    global class Inquiry {
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
    	
    	public Inquiry(String id) {
    	   this.id = id;	
    	}
    	
    	public Inquiry() {
    		
    	}
    }
}