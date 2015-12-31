//
//  ImageSearchResult.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import UIKit

class ImageSearchResult
{
  let imageURL:String?
  let source:String?
  let attributionURL:String?
  var image:UIImage?
  
  required init(anImageURL: String?, aSource: String?, anAttributionURL: String?) {
    imageURL = anImageURL
    source = aSource
    attributionURL = anAttributionURL
  }
  
    // get all of the attribution data as a single string
      func fullAttribution() -> String {
        var result:String = ""
        if attributionURL != nil && attributionURL!.isEmpty == false {
          result += "Image from \(attributionURL!)"
        }
        if source != nil && source!.isEmpty == false  {
          if result.isEmpty {
            result += "Image from "
          }
          result += " \(source!)"
        }
        return result
      }
}
