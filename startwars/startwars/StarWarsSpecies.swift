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

//There’s a little more to the StarWarsSpecies. To avoid typing strings in when we’re parsing the JSON, let’s use an enum of the field names:

enum SpeciesFields: String {
	case Name = "name"
	case Classification = "classification"
	case Designation = "designation"
	case AverageHeight = "average_height"
	case SkinColors = "skin_colors"
	case HairColors = "hair_colors"
	case EyeColors = "eye_colors"
	case AverageLifespan = "average_lifespan"
	case Homeworld = "homeworld"
	case Language = "language"
	case People = "people"
	case Films = "films"
	case Created = "created"
	case Edited = "edited"
	case Url = "url"
}

class StarWarsSpecies {
	
	var wrapper = SpeciesWrapper()
	
	// MARK: Properties and an initializer
	var idNumber: Int?
	var name: String?
	var classification: String?
	var designation: String?
	var averageHeight: Int?
	var skinColors: Array<String>?
	var hairColors: Array<String>?
	var eyeColors: Array<String>?
	var averageLifespan: String?
	var homeworld: String?
	var language: String?
	var people: Array<String>?
	var films: Array<String>?
	var created: NSDate?
	var edited: NSDate?
	var url: String?
	
	required init(json: JSON, id: Int?) {
		print(json)
		
		// Parsing JSON Strings & Integers
		self.idNumber = id
		// strings
		self.name = json[SpeciesFields.Name.rawValue].stringValue
		self.classification = json[SpeciesFields.Classification.rawValue].stringValue
		self.designation = json[SpeciesFields.Designation.rawValue].stringValue
		self.language = json[SpeciesFields.Language.rawValue].stringValue
		// lifespan is sometimes "unknown" or "infinite", so we can't use an int
		self.averageLifespan = json[SpeciesFields.AverageLifespan.rawValue].stringValue
		self.homeworld = json[SpeciesFields.Homeworld.rawValue].stringValue
		self.url = json[SpeciesFields.Url.rawValue].stringValue
		
		// ints
		self.averageHeight = json[SpeciesFields.AverageHeight.rawValue].intValue
		
		// Parsing JSON String Lists
		// strings to arrays like "a, b, c"
		// SkinColors, HairColors, EyeColors
		if let string = json[SpeciesFields.SkinColors.rawValue].string
		{
			self.skinColors = string.splitStringToArray()
		}
		if let string = json[SpeciesFields.HairColors.rawValue].string
		{
			self.hairColors = string.splitStringToArray()
		}
		if let string = json[SpeciesFields.EyeColors.rawValue].string
		{
			self.eyeColors = string.splitStringToArray()
		}
		
		// Parsing JSON Arrays of Strings
		// People, Films
		// there are arrays of JSON objects, so we need to extract the strings from them
		if let jsonArray = json[SpeciesFields.People.rawValue].array
		{
			self.people = Array<String>()
			for entry in jsonArray
			{
				self.people?.append(entry.stringValue)
			}
		}
		
		// We can get the underlying Swift array by calling .array
		if let jsonArray = json[SpeciesFields.Films.rawValue].array
		{
			self.films = Array<String>()
			
			// We loop through the array elements, get their values as strings and add them to our film & people arrays.
			for entry in jsonArray
			{
				self.films?.append(entry.stringValue)
			}
		}
		
		// Parsing Dates in JSON
		// Dates
		// Created, Edited
		let dateFormatter = StarWarsSpecies.dateFormatter()
		if let dateString = json[SpeciesFields.Created.rawValue].string
		{
			self.created = dateFormatter.dateFromString(dateString)
		}
		if let dateString = json[SpeciesFields.Edited.rawValue].string
		{
			self.edited = dateFormatter.dateFromString(dateString)
		}
		
		self.averageHeight = json[SpeciesFields.AverageHeight.rawValue].int
	}
	
	class func dateFormatter() -> NSDateFormatter {
		// create it
		let aDateFormatter = NSDateFormatter()
		
		// set the format as a text string
		// we might get away with just doing this one line configuration for the date formatter
		aDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
		
		// but we if leave it at that then the user's settings for datetime & locale
		// can mess it up. So:
		// the 'Z' at the end means it's UTC (aka, Zulu time), so let's tell
		aDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
		
		// dates coming from an english webserver are generally en_US_POSIX locale
		// this would be different if your server spoke Spanish, Chinese, etc
		aDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		
		return aDateFormatter
	}
	
	// MARK: Endpoints
	class func endpointForSpecies() -> String {
		return "https://swapi.co/api/species/"
	}
	
	/*******************************************************************************
	 Getting & Processing the API Response
	 ******************************************************************************/
	
	private class func getSpeciesAtPath(path: String, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
		Alamofire.request(.GET, path)
			.responseSpeciesArray { response in
				if let error = response.result.error
				{
					completionHandler(nil, error)
					return
				}
				completionHandler(response.result.value, nil)
		}
	}
	
	class func getSpecies(completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
		getSpeciesAtPath(StarWarsSpecies.endpointForSpecies(), completionHandler: completionHandler)
	}
	
	class func getMoreSpecies(wrapper: SpeciesWrapper?, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
		if wrapper == nil || wrapper?.next == nil
		{
			completionHandler(nil, nil)
			return
		}
		getSpeciesAtPath(wrapper!.next!, completionHandler: completionHandler)
	}
}