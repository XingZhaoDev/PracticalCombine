//
//  CarViewModel.swift
//  PracticalCombine
//
//  Created by Xing Zhao on 2022-04-21.
//

import Foundation
import Combine

struct CarViewModel {
    var car: Car
    
    mutating func drive(kilometers: Double) {
        let kwhNeeded = kilometers * car.kwhPerKilometer
        assert(kwhNeeded <= car.kwhInBattery, "Can't make trip, not enough charge in battery")
        car.kwhInBattery -= kwhNeeded
    }
    
    lazy var batterySubject: AnyPublisher<String?, Never> = {
        return car.$kwhInBattery
            .map { newCharge in
                return "The car now has \(newCharge)kwh in its battery"
            }.eraseToAnyPublisher()
    }()
}
