//
//  DuckDuckGoSearchController.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DuckDuckGoSearchController {

    //Make the URL request
    //Search String Formatting
    
    fileprivate class func endpointForSearchString(_ searchString: String) -> String {
            // URL encode it, e.g., "Yoda's Species" -> "Yoda%27s%20Species"
            // and add star wars to the search string so that we don't get random pictures of the Hutt valley or Droid phones
        let encoded = "\(searchString) star wars".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            // create the search string
            // append &t=grokswift so DuckDuckGo knows who's using their services
            return "https://api.duckduckgo.com/?q=\(encoded!)&format=json&t=grokswift"
    }
    
    //Loading UIImages from URLs
    class func imageFromSearchString(_ searchString: String, completionHandler: @escaping (ImageSearchResult?, NSError?) -> Void) {
        
        let searchURLString = endpointForSearchString(searchString)
        Alamofire.request(searchURLString).responseDuckDuckGoImageURL { response in
                if let error = response.result.error
                {
                    completionHandler(response.result.value, error as NSError?)
                    return
                }
                
                let imageURLResult = response.result.value
                
                guard let imageURL = imageURLResult?.imageURL , imageURL.isEmpty == false else {
                    completionHandler(response.result.value, nil)
                    return
                }
                
                // got the URL, now to load it
                Alamofire.request(imageURL, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                        guard let imageData = response.data else {
                            completionHandler(imageURLResult, nil)
                            return
                        }
                        
                        imageURLResult?.image = UIImage(data: imageData)
                        completionHandler(imageURLResult, nil)
                }
        }
    }
}

let IMAGE_KEY = "Image"
let SOURCE_KEY = "AbstractSource"
let ATTRIBUTION_KEY = "AbstractURL"

//Parsing image URL
extension Alamofire.DataRequest {
    func responseDuckDuckGoImageURL(_ completionHandler: @escaping (DataResponse<ImageSearchResult>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<ImageSearchResult> { request, response, data, error in
            
            guard let responseData = data else {
                    return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
                
            case .success(let value):
                let json = SwiftyJSON.JSON(value)
                guard json.error == nil else {
                    print(json.error!)
                    return .failure(json.error!)
                }
                
                let imageURL = json[IMAGE_KEY].string
                let source = json[SOURCE_KEY].string
                let attribution = json[ATTRIBUTION_KEY].string
                let result = ImageSearchResult(anImageURL: imageURL, aSource: source, anAttributionURL: attribution)
                
                return .success(result)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
