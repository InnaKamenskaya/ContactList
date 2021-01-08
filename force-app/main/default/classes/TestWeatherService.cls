@isTest
private class TestWeatherService {
    private static final String LOCATION = 'Los Angeles';

    @isTest
    static void getCurrentWeatherPositiveTest() {
        Test.startTest();
        WeatherService.WeatherData expWeather = new WeatherService.WeatherData();
        expWeather.temp = 25.5;
        expWeather.windSpeed = 3.3;
        expWeather.humidity = 75.0;
        Test.setMock(HttpCalloutMock.class, new WeatherAPICalloutMock(expWeather));
        WeatherService.WeatherData actWeather = WeatherService.getCurrentWeather(LOCATION);
        Test.stopTest();
        System.assertEquals(expWeather.temp, actWeather.temp, 'The temperature should be equals');            
        System.assertEquals(expWeather.windSpeed, actWeather.windSpeed, 'The wind speed should be equals');            
        System.assertEquals(expWeather.humidity, actWeather.humidity, 'The humidity should be equals');            
    }

    @isTest
    static void getCurrentWeatherNegativeTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WeatherAPICalloutMock(new WeatherService.WeatherData()));
        WeatherService.WeatherData weather = WeatherService.getCurrentWeather(null);
        Test.stopTest();
        System.assertEquals(null, weather, 'The null is expexted');            
    }
}
