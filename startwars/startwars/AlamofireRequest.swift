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
extension Alamofire.Request {
	func responseSpeciesArray(completionHandler: Response<SpeciesWrapper, NSError> -> Void) -> Self {
		let responseSerializer = ResponseSerializer<SpeciesWrapper, NSError> { request, response, data, error in
			
			guard error == nil else {
				return .Failure(error!)
			}
			
			guard let responseData = data else {
				let failureReason = "Array could not be serialized because input data was nil."
				let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
				return .Failure(error)
			}
			
			// Request.JSONResponseSerializer to get the data as JSON
			let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
			let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
			
			// The top layer contains only 4 elements: next, previous, count and results. Parsing the first 3 by using SwiftyJSON
			switch result {
			case .Success(let value):
				let json = SwiftyJSON.JSON(value)
				let wrapper = SpeciesWrapper()
				
				// And we grab the relevant values from the JSON to fill in the wrapper’s properties:
				// stringValue and intValue try to convert the JSON elements to strings or ints.
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
				return .Success(wrapper)
			case .Failure(let error):
				return .Failure(error)
			}
		}
		
		return response(responseSerializer: responseSerializer,
			completionHandler: completionHandler)
	}
}