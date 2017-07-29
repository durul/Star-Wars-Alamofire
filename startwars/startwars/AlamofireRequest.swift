//
//  StarWarsSpecies.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// MARK: ResponseSpeciesArray with its custom response serializer:
// The data passes through a custom response serializer in responseSpeciesArray which parses the top layer of the JSON.

extension Alamofire.DataRequest {
	func responseSpeciesArray(_ completionHandler: @escaping (DataResponse<SpeciesWrapper>) -> Void) -> Self {
		let responseSerializer = DataResponseSerializer<SpeciesWrapper> { request, response, data, error in
			
			guard error == nil else {
				return .failure(error!)
			}
			
			guard let responseData = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
			}
			
			// Request.JSONResponseSerializer to get the data as JSON
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
			let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
			
			// The top layer contains only 4 elements: next, previous, count and results. Parsing the first 3 by using SwiftyJSON
			switch result {
			case .success(let value):
				let json = SwiftyJSON.JSON(value)
				
				// check for "message" errors in the JSON
				// After we successfully retrieve the JSON we need to check for for an error message passed by the API in the "message" field.
				if json["message"].string != nil {
                    return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))

				}
				
				let wrapper = SpeciesWrapper()
				
				// And we grab the relevant values from the JSON to fill in the wrapper’s properties: stringValue and intValue try to convert the JSON elements to strings or ints.
				
				// next is load more function from api.
				wrapper.next = json["next"].stringValue
				wrapper.previous = json["previous"].stringValue
				wrapper.count = json["count"].intValue
				
				// Parsing the array of results is a bit more involved
				var allSpecies: Array = Array<StarWarsSpecies>()
				print(json)
				let results = json["results"]
				print(results)
				
				autoreleasepool
				{
					
					for jsonSpecies in results
					{
						print(jsonSpecies.1)
						let species = StarWarsSpecies(json: jsonSpecies.1, id: Int(jsonSpecies.0))
						allSpecies.append(species)
					}
				}
				wrapper.species = allSpecies
				return .success(wrapper)
			case .failure(let error):
				return .failure(error)
			}
		}
		
		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}
