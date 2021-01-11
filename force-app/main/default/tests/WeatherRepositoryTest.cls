@isTest
private class WeatherRepositoryTest {
    private static final String LOCATION = 'Los Angeles';

    @testSetup 
    static void createAllData(){
        ApiKey__c api = new ApiKey__c();
        api.weatherKey__c = 'ec506f3266812fe420c4607db7617a03';
        insert api;
    }

    @isTest
    static void getCurrentWeatherPositiveTest() {
        Test.startTest();
        WeatherRepository.WeatherResponse expWeather = new WeatherRepository.WeatherResponse();
        expWeather.main = new WeatherRepository.WeatherData();
        expWeather.wind = new WeatherRepository.WeatherData();
        expWeather.main.temp = 25.5;
        expWeather.wind.speed = 3.3;
        expWeather.main.humidity = 75.0;
        Test.setMock(HttpCalloutMock.class, new WeatherAPICalloutMock(expWeather));
        WeatherRepository.WeatherResponse actWeather = WeatherRepository.getCurrentWeather(LOCATION);
        Test.stopTest();
        System.assertEquals(expWeather.main.temp, actWeather.main.temp, 'The temperature should be equals');            
        System.assertEquals(expWeather.wind.speed, actWeather.wind.speed, 'The wind speed should be equals');            
        System.assertEquals(expWeather.main.humidity, actWeather.main.humidity, 'The humidity should be equals');            
    }

    @isTest
    static void getCurrentWeatherNegativeTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WeatherAPICalloutMock(new WeatherRepository.WeatherResponse()));
        WeatherRepository.WeatherResponse weather = WeatherRepository.getCurrentWeather(null);
        Test.stopTest();
        System.assertEquals(null, weather, 'The null is expexted');            
    }
}