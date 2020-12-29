global class WeatherService {
    @AuraEnabled(cacheable=true)
    public static WeatherData getCurrentWeather(String location){ 
           
        WeatherAPIKey__mdt weaherApiKey = [SELECT Key__c FROM WeatherAPIKey__mdt LIMIT 1];  
        String apiKey = weaherApiKey.Key__c;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:WeatherAPI?q='+ location + '&units=metric' + '&appid=' + apiKey);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse resp = http.send(req);
       
        Map<String, Object> weatherMap = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
        Map<String, Object> main = (Map<String, Object>) weatherMap.get('main');
        Map<String, Object> wind = (Map<String, Object>) weatherMap.get('wind');

        WeatherData weather = new WeatherData();
        weather.temp = (Decimal) main.get('temp');
        weather.windSpeed = (Decimal) wind.get('speed');
        weather.humidity = (Decimal) main.get('humidity');
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
