//
//  StorageManager.swift
//  Diary
//
//  Created by Anton Zyryanov on 06.02.2022.
//

import RealmSwift

let realm = try? Realm()

class StorageManager {

    static func saveObject(_ task: Task) {
        if realm != nil {
            try? realm!.write {
                realm!.add(task)
            }
        }
    }

    static func deleteObject(_ task: Task) {
        if realm != nil {
            try? realm!.write {
                realm!.delete(task)
            }
        }
    }
}
