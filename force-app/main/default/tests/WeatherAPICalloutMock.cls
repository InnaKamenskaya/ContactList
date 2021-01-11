global class WeatherAPICalloutMock implements HttpCalloutMock  {

    private static WeatherRepository.WeatherResponse weather;

    public WeatherAPICalloutMock(WeatherRepository.WeatherResponse incomeWeather) {
        weather = incomeWeather;
    }

    global HttpResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if (weather == null) {
            response.setStatusCode(400);
            return response;
        }
        response.setBody(JSON.serialize(weather, true));
        response.setStatusCode(200);                
        return response; 
    }
}
