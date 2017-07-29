//
//  DetailViewController.swift
//  startwars
//
//  Created by durul dalkanat on 12/30/15.
//  Copyright © 2015 durul dalkanat. All rights reserved.
//

import Foundation
import UIKit

    //MARK: - DetailViewController Properties
class DetailViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var descriptionTextView: UITextView!

    var species:StarWarsSpecies?

    //MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.displaySpeciesDetails()
    }

    func displaySpeciesDetails()
    {
        self.descriptionTextView!.text = ""
        if self.species == nil
        {
            return
        }

        if let name =  self.species!.name
        {
            self.title = name
            if let language = self.species!.language
            {
                self.descriptionTextView!.text! += "Members of the \(name) species speak \(language). "
            }

            if let height = self.species!.averageHeight
            {
                self.descriptionTextView!.text! += "The \(self.species!.name!) can be identified by their height, typically \(height)cm."
            }

            var eyeColors:String?
            if let colors = self.species!.eyeColors
            {
                eyeColors = colors.joined(separator: " or ")
            }
            var skinColors:String?
            if let colors = self.species!.skinColors
            {
                skinColors = colors.joined(separator: ", ")
            }
            var hairColors:String?
            if let colors = self.species!.hairColors
            {
                hairColors = colors.joined(separator: ", ")
            }

            if eyeColors != nil && skinColors != nil && hairColors != nil
            {
                // if any of the colors, tack 'em on
                self.descriptionTextView!.text! += "\n\nTypical coloring includes eyes:\n\t\(eyeColors!)\nhair:\n\t\(hairColors!)\nand skin:\n\t\(skinColors!)"
            }
        }

        if self.species?.averageLifespan != nil
        {
            // some species have numeric lifespans (like 100) and some have lifespans like "indefinite", so we handle both by adding " years" to the numeric ones
            if let lifespan = self.species?.averageLifespan {
                self.descriptionTextView!.text! += "\n\nTheir average lifespan is \(lifespan)"
                let numericLifespan = Int(lifespan)
                if numericLifespan != nil {
                    self.descriptionTextView!.text! += " years."
                }
                else
                {
                    self.descriptionTextView!.text! += "."
                }
            }
        }
        self.descriptionTextView!.sizeToFit() // to top-align text
    }
    
}
