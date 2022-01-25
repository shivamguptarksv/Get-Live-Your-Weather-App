
import Foundation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager : WeatherManager ,_ weather : WeatherModel)
    func didFailWithError(eror : Error)
}
struct WeatherManager{
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=0cdb8a87c51c485450c2875913c64f96&units=metric"
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName : String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString : String){
        //1. Create a URL
        if let url = URL(string: urlString){
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            //3. Give the session task
            let task = session.dataTask(with: url){(data ,response , error ) in
                if error != nil{
                    self.delegate?.didFailWithError(eror: error!) //print(error)
                    return
                }
                
                if let safedata = data{
                    if let weather = self.parseJSON(safedata){
                        print(weather.cityName,weather.conditionName)
                        self.delegate?.didUpdateWeather(self, weather)
                    }
                
                }
            }
            
            //4. Start the Task
            task.resume()
            
        } //step-1 End
        
    } // performRequest()
    
    func parseJSON(_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self ,from: weatherData)
            let name = decodedData.name
            let temp = decodedData.main.temp
            let id =   decodedData.weather[0].id
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch{
            self.delegate?.didFailWithError(eror: error) //print(error)
            return nil
        }
    }
}
