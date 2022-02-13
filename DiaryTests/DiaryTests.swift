//
//  DiaryTests.swift
//  DiaryTests
//
//  Created by Anton Zyryanov on 10.02.2022.
//

import XCTest
@testable import Diary
import RealmSwift

class DiaryTests: XCTestCase {

    override func setUpWithError() throws {
        super.setUp()

    }

    override func tearDownWithError() throws {

        super.tearDown()
    }

    func testNewTaskIsAddingToDatabase() {
        prepareViewControllers { diaryVC, newTaskVC in
            let tasksCountBeforeAdding = diaryVC.getTasksCountForTests()
            print("Number of tasks before adding: \(tasksCountBeforeAdding)")
            newTaskVC.performTestDBSaving(withTaskName: "Test Task", andDescription: "No description")
            let tasksCountAfterAdding = diaryVC.getTasksCountForTests()
            print("Number of tasks after adding: \(tasksCountAfterAdding)")
            XCTAssert(tasksCountAfterAdding == tasksCountBeforeAdding + 1,
                      "Error: New task should be in Database after adding")
        }
    }

    func testNewTaskAlwaysFilledWithInfo() {
        prepareViewControllers { diaryVC, newTaskVC in
            let tasksCountBeforeAdding = diaryVC.getTasksCountForTests()
            print("Number of tasks before adding: \(tasksCountBeforeAdding)")
            newTaskVC.performTestDBSaving(withTaskName: "", andDescription: "")
            newTaskVC.performTestDBSaving(withTaskName: "", andDescription: "Some description")
            newTaskVC.performTestDBSaving(withTaskName: "Some Name", andDescription: "")
            let tasksCountAfterAdding = diaryVC.getTasksCountForTests()
            print("Number of tasks after adding: \(tasksCountAfterAdding)")
            XCTAssert(tasksCountAfterAdding == tasksCountBeforeAdding,
                      "Error: Only task with filled info should be added into database")
        }
    }

    func prepareViewControllers(completion:((_ diaryVC: DiaryViewController,
                                             _ newTaskVC: NewTaskViewController) -> Void)) {
        let diaryVC = DiaryViewController()
        diaryVC.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newTaskVC = storyboard.instantiateViewController(withIdentifier: "NewTaskVC") as? NewTaskViewController
        if newTaskVC != nil {
            newTaskVC!.loadView()
            newTaskVC!.generateIdClosure = diaryVC.generateIdClosure
            completion(diaryVC, newTaskVC!)
        }
    }

}
