global class WeatherAPICalloutMock implements HttpCalloutMock  {

    private static WeatherRepository.WeatherData weather;

    public WeatherAPICalloutMock(WeatherRepository.WeatherData incomeWeather) {
        weather = incomeWeather;
    }

    global HttpResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if (weather == null) {
            response.setStatusCode(400);
            return response;
        }
        response.setBody(JSON.serialize(weather));
        response.setStatusCode(200);                
        return response; 
    }
}
