//
//  Vedurstofan.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 27/01/2019.
//  Copyright © 2019 Bergþór Þrastarson. All rights reserved.
//

import Foundation

class Vedurstofan {
    static func getTemperatureFor(station:Int, handler:@escaping (_ observation:WeatherObservation?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://apis.is/weather/observations/is?stations=" + String(describing: station))!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard let data = data else {
                return
            }
            if error != nil {
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? Dictionary<String, Array<AnyObject>> else {
                    return handler(nil)
                }
                let observation = Vedurstofan.WeatherObservation(response: json)
                return handler(observation)
            } catch {
                print("error")
            }
            return handler(nil)
        })
        
        task.resume()
    }
    
    class WeatherObservation {
        var stationName:String?
        var time:Date?
        var err:String?
        var link:String?
        var windSpeed:Double?
        var topWindSpeed:Double?
        var topWindGust:Double?
        var windDirection:String?
        var temperature:Double?
        var weatherDescription:String?
        var visibility:Double?
        var cloudCover:Double?
        var airPressure:Double?
        var humidity:Double?
        var snowDescription:String?
        var snowDepth:Double?
        var snowType:String?
        var roadTemperature:Double?
        var dewPoint:Double?
        var cumulativePrecipitation:Double?
        var id:Int64?
        var valid:Bool?
        
        init(response:Dictionary<String, Array<AnyObject>>) {
            let fields = WeatherFields()
            
            guard let result = parseResult(response: response) else {
                return
            }
            
            self.stationName = result[fields.STATION_NAME] as? String
            self.time = Date().formatVedurstofan("yyyy-MM-dd HH:mm:ss", ((result[fields.TIME] as? String)!))
            self.err = result[fields.ERROR] as? String
            self.link = result[fields.LINK] as? String
            self.windSpeed = result[fields.WIND_SPEED]?.doubleValue
            self.topWindSpeed = result[fields.TOP_WIND_SPEED]?.doubleValue
            self.topWindGust = result[fields.TOP_WIND_GUST]?.doubleValue
            self.windDirection = result[fields.WIND_DIRECTION] as? String
            self.temperature = result[fields.TEMPERATURE]?.doubleValue
            self.weatherDescription = result[fields.WEATHER_DESCRIPTION] as? String
            self.visibility = result[fields.VISIBILITY]?.doubleValue
            self.cloudCover = result[fields.CLOUD_COVER]?.doubleValue
            self.airPressure = result[fields.AIR_PRESSURE]?.doubleValue
            self.humidity = result[fields.HUMIDITY]?.doubleValue
            self.snowDescription = result[fields.SNOW_DESCRIPTION] as? String
            self.snowDepth = result[fields.SNOW_DEPTH]?.doubleValue
            self.snowType = result[fields.SNOW_TYPE] as? String
            self.roadTemperature = result[fields.ROAD_TEMPERATURE]?.doubleValue
            self.dewPoint = result[fields.DEW_POINT]?.doubleValue
            self.cumulativePrecipitation = result[fields.CUMULATIVE_PRECIPITATION]?.doubleValue
            self.id = result[fields.ID]?.int64Value
            self.valid = result[fields.VALID]?.boolValue
        }
        
        func parseResult(response:Dictionary<String, Array<AnyObject>>)  -> Dictionary<String, AnyObject>? {
            guard let result = response["results"] else {
                return nil
            }
            
            if result.count == 0 {
                return nil
            }
            
            guard let firstResult = result[0] as? Dictionary<String, AnyObject> else {
                return nil
            }
            return firstResult
        }
        
        func parseDouble() -> Double? {
            return nil
        }
        
        
        struct WeatherFields {
            let STATION_NAME = "name"
            let TIME = "time"
            let ERROR = "err"
            let LINK = "link"
            let WIND_SPEED = "F"
            let TOP_WIND_SPEED = "FX"
            let TOP_WIND_GUST = "FG"
            let WIND_DIRECTION = "D"
            let TEMPERATURE = "T"
            let WEATHER_DESCRIPTION = "W"
            let VISIBILITY = "V"
            let CLOUD_COVER = "N"
            let AIR_PRESSURE = "P"
            let HUMIDITY = "RH"
            let SNOW_DESCRIPTION = "SNC"
            let SNOW_DEPTH = "SND"
            let SNOW_TYPE = "SED"
            let ROAD_TEMPERATURE = "RTE"
            let DEW_POINT = "TD"
            let CUMULATIVE_PRECIPITATION = "R"
            let ID = "id"
            let VALID = "valid"
        }
    }
    
}
