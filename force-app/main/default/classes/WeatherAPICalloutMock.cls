global class WeatherAPICalloutMock implements HttpCalloutMock  {

    private static WeatherService.WeatherData weather;

    public WeatherAPICalloutMock(String location) {
        if (location == null || location == '') {
            weather = null;
        }else { 
            weather = new WeatherService.WeatherData();
            weather.temp = 25.5;
            weather.windSpeed = 3.3;
            weather.humidity = 75.0;
        }
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if (weather == null) {
            response.setStatusCode(400);
        }else {
            response.setBody(JSON.serialize(weather));
            response.setStatusCode(200);
        }        
        return response; 
    }
}
