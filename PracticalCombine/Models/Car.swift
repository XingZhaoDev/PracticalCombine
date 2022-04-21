//
//  Car.swift
//  PracticalCombine
//
//  Created by Xing Zhao on 2022-04-21.
//

import Foundation
import Combine

class Car {
    var onBatteryChargeChanged: ((Double) -> Void)?
    
//    var kwhInBattery = 50.0 {
//        didSet {
//            onBatteryChargeChanged?(kwhInBattery)
//        }
//    }
    
    //var kwhInBattery = CurrentValueSubject<Double, Never>(50.0)
    
    @Published var kwhInBattery = 50.0
    
    let kwhPerKilometer = 0.1
    
    // Move this method to ViewModel
    /*
    func drive(kilometers: Double) {
        let kwhNeeded = kilometers * kwhPerKilometer
        
        assert(kwhNeeded <= kwhInBattery, "Can't make trip, no enough charge in battery")
        //kwhInBattery.value -= kwhNeeded
        kwhInBattery -= kwhNeeded
    }*/
}
