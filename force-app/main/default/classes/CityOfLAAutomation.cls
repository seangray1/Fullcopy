global class CityOfLAAutomation{
   
    public static void CountySearch(Map<id, ATI_Job__c> oldMap, list<ATI_Job__c> newValues){
        
        if (oldMap == null)
        {
            oldMap = new Map<Id, ATI_Job__c>();
        }
  
        List<ID> oppsToUpdate = new List<ID>();
        
        //go through the query to save the id
        for(ATI_Job__c opp: [SELECT Id,Project_Site_Address__c,Project_Site_Address_2__c, Project_Site_City__c, Project_Site_State__c, Project_Site_Zipcode__c, City_of_LA__c FROM ATI_Job__c WHERE Id IN :newValues]){
            
            //check for address. If true, add to the list. 
            if(getFullAddress(opp) != getFullAddress(oldMap.get(opp.Id)))
            {
                OppsToUpdate.add(opp.id);
            }  
        }
        
        //pass the id to the future method to update
        if(!OppsToUpdate.isEmpty()){
            UpdateCityOfLA(OppsToUpdate);
        }
        
    }
    
    private static string getFullAddress (ATI_Job__c opp)
    {
        if (opp == null)
        {
            return null;
        }
        
        return 
            StringBlankIfNull(opp.Project_Site_Address__c) 
            + ' ' + StringBlankIfNull(opp.Project_Site_Address_2__c) 
            + ' ' + StringBlankIfNull(opp.Project_Site_City__c) 
            + ' ' + StringBlankIfNull(opp.Project_Site_State__c) 
            + ' ' + StringBlankIfNull(opp.Project_Site_Zipcode__c);     
    }
    
    private static string StringBlankIfNull(string val)
    {
        return val == null ? '' : val.toLowerCase();
    }
    
    @future(callout = true)
    public static void UpdateCityOfLA(List<id> ID){
    
        List<ATI_Job__c> UpdateOpp = new list<ATI_Job__c>();
        
        for(ATI_Job__c opp: [select Id,Project_Site_Address__c, ZIPcodecheck_cityofLA__c FROM ATI_Job__c WHERE Id IN :ID]){
            
            opp.City_of_LA__c = 'No';
            if(opp.ZIPcodecheck_cityofLA__c == true && opp.Project_Site_Address__c != null){
                system.debug('THIS IS THE ADDRES BEFORE:' + opp.Project_Site_Address__c);
                opp.City_of_LA__c = AddressIsInLA(opp.Project_Site_Address__c);               
            }
            UpdateOpp.add(opp);
        }
        
        update updateOpp;
    }
    
    public Static String AddressIsInLA(String opp){
        system.debug('THIS IS THE ADDRES After:' + opp);
        String Par = opp; 
        String param = Par.remove('.');
        String param2 = Param.remove(',');
        string param3 = Param2.replace(' ', '+');
        string Parameter = 'streetAddress='+Param3+'&fuseaction=processAddress';

        try
        {
            Http http = new Http();
            HttpResponse response = getResponse(parameter);
            if(response.getBody().containsIgnoreCase('We were not able to locate the address:')){
                system.debug('Not Found');
                return 'No';
            }
            else if(response.getBody().containsIgnoreCase('Elected Officials')){
                system.debug('Found!');
                return 'Yes';
            }
            else {
                return 'ERROR. ' + response.getBody().left(100);
            }
            
        }
        catch (Exception ex)
        {
            System.debug('ERROR:' + ex);
            return 'ERROR. ' + ex.getMessage().left(100);
        }
    } 
    
    public static HttpResponse getResponse(String param){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('http://neighborhoodinfo.lacity.org/index.cfm?streetAddress=210+w+baywood+ave&fuseaction=processAddress');
        String Endpoint = 'http://neighborhoodinfo.lacity.org/index.cfm?'+param;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            system.debug(response.getBody());
        }
        else{
            system.debug('This is the HTTP Error:' + response.getStatusCode());
        }
        
        return response;   
    }
    

}