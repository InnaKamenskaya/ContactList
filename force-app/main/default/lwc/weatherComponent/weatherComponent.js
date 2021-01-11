import { api, wire, track, LightningElement } from 'lwc';
import SHIPPING_CITY_FIELD from '@salesforce/schema/Account.ShippingCity'
import WHEATHER_KEY_FIELD from '@salesforce/schema/Account.WeatherKey__c'
import IS_BACK_IMPL_FIELD from '@salesforce/schema/Account.IsBackimplementation__c'
import getCurrentWeather from '@salesforce/apex/WeatherRepository.getCurrentWeather';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import weather from '@salesforce/resourceUrl/weather';

const fields = [SHIPPING_CITY_FIELD, WHEATHER_KEY_FIELD, IS_BACK_IMPL_FIELD];

export default class WeatherComponent extends LightningElement {
    @api recordId;
    celsiusSign = '\u2103';
    @track weather = {
        temp: 0,
        wind: 0,
        humidity: 0
    }
    @wire(getRecord, {recordId: '$recordId', fields})
    account(result){
        if(result.data){
            if(getFieldValue(result.data, IS_BACK_IMPL_FIELD)){
                getCurrentWeather({location: getFieldValue(result.data, SHIPPING_CITY_FIELD)})
                .then(value => {
                    this.weather.temp = value.temp;
                    this.weather.wind = value.windSpeed;
                    this.weather.humidity = value.humidity;
                }).catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                               title: 'Error!', 
                               message: error.body.message, 
                               variant: 'error'
                           }),
                      );
                })                
            }else{
                fetch("https://api.openweathermap.org/data/2.5/weather?q=" + getFieldValue(result.data, SHIPPING_CITY_FIELD) + "&units=metric"  + "&appid=" + getFieldValue(result.data, WHEATHER_KEY_FIELD),
                {
                    method:"GET",
                    headers:{
                        "Accept":"application/json"
                    }
                })
                .then (response => {
                    if(response.ok){                
                        return response.json();
                    }
                })
                .then(jsonResponse => {
                    this.weather.temp = (jsonResponse['main'].temp);
                    this.weather.wind = jsonResponse['wind'].speed;
                    this.weather.humidity = jsonResponse['main'].humidity;
                    return this.weather;
                }).catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                               title: 'Error!', 
                               message: error.message, 
                               variant: 'error'
                           }),
                      );   
                });
            }            
            loadStyle(this, weather);
        }else if(result.error){
            this.dispatchEvent(
                new ShowToastEvent({
                       title: 'Error!', 
                       message: error.message, 
                       variant: 'error'
                   }),
              );   
        }
    }   

    get currentTemp(){
        return Math.round(this.weather.temp) +  this.celsiusSign;
    }

    get currentWindSpeed(){
        return Math.round(this.weather.wind) + "m/s";
    }

    get currentHumidity(){
        return this.weather.humidity + "%";
    }
}