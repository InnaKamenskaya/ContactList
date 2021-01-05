@isTest
private class TestWeatherService {
    private static String location = 'Los Angeles';

    @isTest
    static void getCurrentWeatherPositiveTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WeatherAPICalloutMock(location));
        WeatherService.WeatherData weather = WeatherService.getCurrentWeather(location);
        Test.stopTest();
        System.assertEquals(25.5, weather.temp, 'The temperature should be equals');            
        System.assertEquals(3.3, weather.windSpeed, 'The wind speed should be equals');            
        System.assertEquals(75.0, weather.humidity, 'The humidity should be equals');            
    }

    @isTest
    static void getCurrentWeatherNegativeTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WeatherAPICalloutMock(location));
        WeatherService.WeatherData weather = WeatherService.getCurrentWeather(null);
        Test.stopTest();
        System.assertEquals(null, weather, 'The null is expexted');            
    }
}
