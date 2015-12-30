//
//  SpeciesWrapper.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SpeciesWrapper {
    var species: Array<StarWarsSpecies>?
    var count: Int?
    var next: String?
    var previous: String?
}