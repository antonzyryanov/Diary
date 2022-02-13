//
//  TaskViewController.swift
//  Diary
//
//  Created by TonyMontana on 10.02.2022.
//

import UIKit

class TaskViewController: UIViewController {

    var task: Task?

    @IBOutlet weak var taskNameTextView: UITextView!

    @IBOutlet weak var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }

    // MARK: - Setup controller

    private func setupController() {
        setupTextViews()
    }

    private func setupTextViews() {
        guard let task = self.task else {return}
        taskNameTextView.text = task.name
        descriptionTextView.text = task.taskDescription
        print(task.taskDescription)
    }

    // MARK: - Buttons actions

    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true)
    }
}
