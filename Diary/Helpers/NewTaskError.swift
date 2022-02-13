//
//  NewTaskErrors.swift
//  Diary
//
//  Created by Anton Zyryanov on 09.02.2022.
//

import Foundation

enum NewTaskError: String {
    case taskName = "Please fill task name"
    case description = "Please fill description"
    case hour = "Please choose at least one hour of a day"
}
