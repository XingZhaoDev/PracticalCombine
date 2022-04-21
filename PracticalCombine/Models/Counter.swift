//
//  Counter.swift
//  PracticalCombine
//
//  Created by Xing Zhao on 2022-04-21.
//

import Foundation
import Combine

class Counter {
    @Published var publishedValue = 1
    var subjectValue = CurrentValueSubject<Int, Never>(1)
}
