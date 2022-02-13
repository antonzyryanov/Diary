//
//  TaskViewController.swift
//  Diary
//
//  Created by TonyMontana on 06.02.2022.
//

import UIKit
import CoreGraphics
import SnapKit

class NewTaskViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var taskNameTextField: UITextField!

    @IBOutlet weak var taskDescriptionTextview: UITextView!

    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var hoursCollectionView: UICollectionView!

    private let inset: CGFloat = 10
    private let minimumLineSpacing: CGFloat = 10
    private let minimumInteritemSpacing: CGFloat = 10
    private let cellsPerRow = 3

    private let topView = UIView()

    private var chosenHours: [Int] = []

    var generateIdClosure: (() -> Int)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }

    // MARK: - Setup controller

    private func setupController() {
        setupTapGestureRecognizer()
        setupTextFieldAndTextView()
        setupButtons()
        setupCollectionView()
    }

    private func setupTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
    }

    private func setupTextFieldAndTextView() {
        taskNameTextField.delegate = self
        self.taskNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.taskNameTextField.layer.borderWidth = 1
        self.taskNameTextField.layer.cornerRadius = 5
        self.taskDescriptionTextview.layer.borderColor = UIColor.lightGray.cgColor
        self.taskDescriptionTextview.layer.borderWidth = 1
        self.taskDescriptionTextview.layer.cornerRadius = 5
    }

    private func setupButtons() {
        saveButton.titleLabel?.font =  UIFont.systemFont(ofSize: 22, weight: .bold)
        cancelButton.titleLabel?.font =  UIFont.systemFont(ofSize: 22, weight: .bold)
    }

    private func setupCollectionView() {
        hoursCollectionView.contentInsetAdjustmentBehavior = .always
        hoursCollectionView.register(HourCollectionViewCell.self, forCellWithReuseIdentifier: "HoursCell")
    }

    // MARK: - Database interaction

    private func saveTasksToDB(taskName: String, description: String) {

        for hour in chosenHours {
            let dateStart = Calendar.current.startOfDay(for: datePicker.date)
            .addingTimeInterval(TimeInterval(60*60*hour)).timeIntervalSince1970
            let dateFinish = Calendar.current.startOfDay(for: datePicker.date)
            .addingTimeInterval(TimeInterval(60*60*(hour+1))).timeIntervalSince1970

            let taskID = generateIdClosure!()

            let task = Task(id: taskID, dateStart: dateStart, dateFinish: dateFinish,
            name: taskName, taskDescription: description)

            StorageManager.saveObject(task)

        }

    }

    // MARK: - UI refresh

    private func unhighlightHourCellsForNextControllerUse() {
        for hour in chosenHours {
            HourCells.cells[hour].isChosen = false
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showAlertController(withMessage message: String) {
        let alertViewController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Continue", style: .default, handler: nil)
        alertViewController.addAction(action)
        present(alertViewController, animated: true)
    }

    // MARK: - Buttons actions

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        unhighlightHourCellsForNextControllerUse()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {

        guard let taskName = taskNameTextField.text else {
            showAlertController(withMessage: NewTaskError.taskName.rawValue)
            return
        }
        guard let desciption = taskDescriptionTextview.text else {
            showAlertController(withMessage: NewTaskError.description.rawValue)
            return
        }
        if taskName == "" {
            showAlertController(withMessage: NewTaskError.taskName.rawValue)
            return
        }
        if desciption == "" {
            showAlertController(withMessage: NewTaskError.description.rawValue)
            return
        }
        if chosenHours.count == 0 {
            showAlertController(withMessage: NewTaskError.hour.rawValue)
            return
        }

        saveTasksToDB(taskName: taskName, description: desciption)

        unhighlightHourCellsForNextControllerUse()

        dismiss(animated: true, completion: nil)
    }

    // MARK: - Unit test helping methods

    func performTestDBSaving(withTaskName taskName: String, andDescription description: String) {
        self.chosenHours.append(12)
        self.taskNameTextField.text = taskName
        self.taskDescriptionTextview.text = description
        self.saveButtonTapped(saveButton!)
    }
}

// MARK: - TextField Delegate

extension NewTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CollectionView Delegate and DataSource

extension NewTaskViewController: UICollectionViewDataSource,
UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return minimumLineSpacing
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return minimumInteritemSpacing
        }

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                    sizeForItemAt indexPath: IndexPath) -> CGSize {
            let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right
                                   + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow))
                            .rounded(.down)
            let itemHeight = CGFloat(60)
            return CGSize(width: itemWidth, height: itemHeight)
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 24
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HoursCell",
                                                          for: indexPath) as? HourCollectionViewCell
            cell?.backgroundColor = UIColor.black
            cell?.layer.cornerRadius = 5
            cell?.label.text = Hours.hours[indexPath.row]
            cell?.label.textColor = .white

            if HourCells.cells[indexPath.row].isChosen {
            cell!.backgroundColor = UIColor(red: 250.0 / 255.0, green: 243.0 / 255.0, blue: 127.0 / 255.0, alpha: 1.0)
                cell!.label.textColor = .black
                 } else {
                     cell!.backgroundColor = .black
                     cell!.label.textColor = .white
                }

            return cell!
        }

        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            hoursCollectionView.collectionViewLayout.invalidateLayout()
            super.viewWillTransition(to: size, with: coordinator)
        }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HourCells.cells[indexPath.row].isChosen = !HourCells.cells[indexPath.row].isChosen
        if HourCells.cells[indexPath.row].isChosen {
            chosenHours.append(indexPath.row)
        } else {
            let index = chosenHours.firstIndex(of: indexPath.row)
            if index != nil {
                chosenHours.remove(at: index!)
            }
        }
        print(chosenHours)
        hoursCollectionView.reloadData()
    }
}
