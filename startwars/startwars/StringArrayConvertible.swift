//
//  StringArrayConvertible.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import Foundation

extension String {
  func splitStringToArray() -> Array<String>
  {
    var outputArray = Array<String>()
    
    let components = self.componentsSeparatedByString(",")
    for component in components
    {
      let trimmedComponent = component.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      outputArray.append(trimmedComponent)
    }
    
    return outputArray
  }
}
