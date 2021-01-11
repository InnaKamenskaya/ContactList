@isTest
private class TestWeatherRepository {
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
        WeatherRepository.WeatherData expWeather = new WeatherRepository.WeatherData();
        expWeather.temp = 25.5;
        expWeather.windSpeed = 3.3;
        expWeather.humidity = 75.0;
        Test.setMock(HttpCalloutMock.class, new WeatherAPICalloutMock(expWeather));
        WeatherRepository.WeatherData actWeather = WeatherRepository.getCurrentWeather(LOCATION);
        Test.stopTest();
        System.assertEquals(expWeather.temp, actWeather.temp, 'The temperature should be equals');            
        System.assertEquals(expWeather.windSpeed, actWeather.windSpeed, 'The wind speed should be equals');            
        System.assertEquals(expWeather.humidity, actWeather.humidity, 'The humidity should be equals');            
    }

    @isTest
    static void getCurrentWeatherNegativeTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WeatherAPICalloutMock(new WeatherRepository.WeatherData()));
        WeatherRepository.WeatherData weather = WeatherRepository.getCurrentWeather(null);
        Test.stopTest();
        System.assertEquals(null, weather, 'The null is expexted');            
    }
}