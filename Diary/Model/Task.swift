//
//  Task.swift
//  Diary
//
//  Created by Anton Zyryanov on 06.02.2022.
//

import RealmSwift

class Task: Object {

    @objc dynamic var id = 10000
    @objc dynamic var dateStart: TimeInterval = TimeInterval(0)
    @objc dynamic var dateFinish: TimeInterval = TimeInterval(0)
    @objc dynamic var name: String = ""
    @objc dynamic var taskDescription: String = ""

    convenience init(id: Int, dateStart: TimeInterval, dateFinish: TimeInterval,
                     name: String, taskDescription: String) {
        self.init()
        self.id = id
        self.dateStart = dateStart
        self.dateFinish = dateFinish
        self.name = name
        self.taskDescription = taskDescription
    }
}
