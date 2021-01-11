global class WeatherRepository {

    public class NullResponseException extends Exception {}
    private static final String META_DATA_LABEL = 'openWeather';
    private static final String ENDPOINT = 'callout:WeatherAPI?q={0}&units=metric&appid={1}';

    @AuraEnabled(cacheable=true)
    public static WeatherResponse getCurrentWeather(String location){ 
        if(String.isBlank(location)){
            return null;
        }
        String apiKey = (ApiKey__c.getOrgDefaults() == null) ? null : ApiKey__c.getOrgDefaults().weatherKey__c;
        if (String.isBlank(apiKey)) {
            return null;
        }
        HttpRequest req = new HttpRequest();
        List<String> endpointValues = new List<String>{location, apiKey};
        req.setEndpoint(String.format(ENDPOINT, endpointValues));
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse resp = http.send(req);
        if (resp == null) {
            throw new NullResponseException(resp.getStatus());
        }                
        return (WeatherResponse)JSON.deserialize(resp.getBody(), WeatherResponse.class);            
    }

    global class WeatherResponse{
        @AuraEnabled
        public WeatherData main;
        @AuraEnabled
        public WeatherData wind; 
    }  
    
    global class WeatherData{
        @AuraEnabled
        public Decimal temp;
        @AuraEnabled 
        public Decimal speed;
        @AuraEnabled 
        public Decimal humidity;
    }
}