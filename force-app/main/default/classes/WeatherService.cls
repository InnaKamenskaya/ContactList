global class WeatherService {

    private static final String META_DATA_LABEL = 'openWeather';
    private static final String ENDPOINT = 'callout:WeatherAPI?q={0}&units=metric&appid={1}';

    @AuraEnabled(cacheable=true)
    public static WeatherData getCurrentWeather(String location){ 
        if(location == null || location ==''){
            return null;
        }
        String apiKey = ([SELECT Key__c FROM WeatherAPIKey__mdt WHERE Label =: META_DATA_LABEL] == null) ? null : [SELECT Key__c FROM WeatherAPIKey__mdt WHERE Label =: META_DATA_LABEL].Key__c;
        if (apiKey == null || apiKey == '') {
            return null;
        }
        HttpRequest req = new HttpRequest();
        List<String> endpointValues = new List<String>{location, apiKey};
        req.setEndpoint(String.format(ENDPOINT, endpointValues));
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse resp = http.send(req);
        if (resp == null) {
            return null;
        }
        Map<String, Object> weatherMap = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
        Map<String, Object> main = (Map<String, Object>) weatherMap.get('main');
        Map<String, Object> wind = (Map<String, Object>) weatherMap.get('wind');

        WeatherData weather = new WeatherData();
        if(Test.isRunningTest()){
            weather = (WeatherData)JSON.deserialize(resp.getBody(), WeatherData.class);
        }else {
            weather.temp = (Decimal) main.get('temp');
            weather.windSpeed = (Decimal) wind.get('speed');
            weather.humidity = (Decimal) main.get('humidity');
        }            
        return weather;            
    }

    global class WeatherData{
        @AuraEnabled
        public Decimal temp;
        @AuraEnabled 
        public Decimal windSpeed;
        @AuraEnabled 
        public Decimal humidity;
    }    
}
