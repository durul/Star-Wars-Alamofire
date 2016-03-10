//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
import Eureka

var formVC = FormViewController()

let section = Section("Whitesmith Events")

section <<< TextRow() {
    $0.value = "Surprise!"
}

section <<< DateRow() {
    $0.value = NSDate()
}

formVC.form.append(section)

formVC.view.layer.cornerRadius = 50.0
formVC.view.layer.masksToBounds = true

XCPlaygroundPage.currentPage.liveView = formVC
var str = "Hello, playground"

var square = UIView()
square.backgroundColor = .greenColor()
square.frame = CGRectMake(0, 0, 50, 50)