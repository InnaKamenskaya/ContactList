global class WeatherAPICalloutMock implements HttpCalloutMock  {

    private static WeatherService.WeatherData weather;

    public WeatherAPICalloutMock(WeatherService.WeatherData incomeWeather) {
        weather = incomeWeather;
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
