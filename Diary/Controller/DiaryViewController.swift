//
//  ViewController.swift
//  Diary
//
//  Created by Anton Zyryanov on 06.02.2022.
//

import UIKit
import CoreGraphics
import SnapKit
import RealmSwift

class DiaryViewController: UIViewController {
    let topView = UIView()
    let tasksTopView = UIView()
    let datePicker = UIDatePicker()
    var tasksTableView = UITableView()
    let addTaskButton = UIButton()

    let blackPinRight = UIImageView()
    let blackPinLeft = UIImageView()
    let redPinRight = UIImageView()
    let redPinLeft = UIImageView()

    private var tasks: Results<Task>!
    private var filteredTasks: Results<Task>!
    var selectedDayStartTimestamp: TimeInterval = TimeInterval(0)
    var selectedDayEndTimestamp: TimeInterval = TimeInterval(0)

    var generateIdClosure: (() -> Int)?

    override func viewDidLoad() {
        super.viewDidLoad()
        if realm != nil {
            tasks = realm!.objects(Task.self)
        }

        controllerSetup()
        generateIdClosure = {
            return self.tasks.count
        }
        datePickerDateChanged(picker: datePicker)
    }

    override func viewWillAppear(_ animated: Bool) {
        datePickerDateChanged(picker: datePicker)
    }

    // MARK: - Setup controller

    private func controllerSetup () {
        backgroundColorSetup()
        setupTopView()
        datePickerSetup()
        setupTasksTopView()
        tasksTableViewSetup()
        addTaskButtonSetup()
        setupPins()
    }

    private func backgroundColorSetup() {
        view.backgroundColor = .white
    }

    private func setupTopView() {
        view.addSubview(topView)
        topView.backgroundColor = UIColor(red: 250.0 / 255.0, green: 243.0 / 255.0, blue: 127.0 / 255.0, alpha: 1.0)
        topView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }

    private func datePickerSetup() {
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            // Fallback on earlier versions
        }
        datePicker.backgroundColor = .white
        datePicker.tintColor = .black
        datePicker.datePickerMode = .date
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.height.equalTo(330)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(116)
        }
        datePicker.addTarget(self, action: #selector(datePickerDateChanged(picker:)), for: .valueChanged)
    }

    private func setupTasksTopView() {
        view.addSubview(tasksTopView)
        tasksTopView.backgroundColor = UIColor(red: 250.0 / 255.0, green: 243.0 / 255.0,
                                               blue: 127.0 / 255.0, alpha: 1.0)
        tasksTopView.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(datePicker.snp.bottom)
        }
    }

    private func tasksTableViewSetup() {
        tasksTableView.dataSource = self
        tasksTableView.delegate = self
        tasksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DiaryCell")
        view.addSubview(tasksTableView)
        tasksTableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tasksTopView.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func addTaskButtonSetup() {
        addTaskButton.addTarget(self, action: #selector(addTaskButtonTapped), for: .touchUpInside)
        let addTaskButtonImage = UIImage(named: "calendar")
        let addTaskButtonImageView = UIImageView(image: addTaskButtonImage)
        addTaskButtonImageView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
        addTaskButton.setImage(addTaskButtonImage, for: .normal)
        addTaskButton.imageView?.contentMode = .scaleAspectFit
        topView.addSubview(addTaskButton)
        addTaskButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(40)
        }
    }

    private func setupPins() {
        blackPinLeft.image = UIImage(named: "blackPinLeft")
        blackPinRight.image = UIImage(named: "blackPinRight")
        redPinLeft.image = UIImage(named: "redPinLeft")
        redPinRight.image = UIImage(named: "redPinRight")
        tasksTopView.addSubview(blackPinLeft)
        tasksTopView.addSubview(blackPinRight)
        topView.addSubview(redPinLeft)
        topView.addSubview(redPinRight)
        blackPinLeft.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(15)
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        blackPinRight.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(15)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        redPinLeft.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        redPinRight.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.trailing.equalTo(addTaskButton.snp.leading).inset(-20)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - UI refresh

    @objc private func datePickerDateChanged(picker: UIDatePicker) {
        self.selectedDayStartTimestamp = Calendar.current.startOfDay(for: picker.date).timeIntervalSince1970
        self.selectedDayEndTimestamp = Calendar.current.startOfDay(for: picker.date)
                                       .addingTimeInterval(TimeInterval(60*60*24)).timeIntervalSince1970

        self.filteredTasks = tasks.where {
            $0.dateStart >= self.selectedDayStartTimestamp  && $0.dateFinish <= self.selectedDayEndTimestamp
        }
        tasksTableView.reloadData()
    }

    // MARK: - Buttons actions

    @objc private func addTaskButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "NewTaskVC") as? NewTaskViewController
        viewController!.modalPresentationStyle = .fullScreen
        viewController!.generateIdClosure = generateIdClosure
        self.present(viewController!, animated: true)
    }

    // MARK: - Unit test helping methods

    func getTasksCountForTests() -> Int {
        return tasks.count
    }

}

// MARK: - TableView Delegate and DataSource

extension DiaryViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tasksTableView.dequeueReusableCell(withIdentifier: "DiaryCell", for: indexPath)
        cell.selectionStyle = .none
        let currentHourStartDate = Date(timeIntervalSince1970: self.selectedDayStartTimestamp)
                                   .addingTimeInterval(TimeInterval(60*60*indexPath.row))
        let currentHourStartTimestamp = currentHourStartDate.timeIntervalSince1970

        let taskForThisHour: Results<Task> = tasks.where {
            $0.dateStart == currentHourStartTimestamp
        }

        if taskForThisHour.count == 0 {
            cell.textLabel?.text = String(Hours.hours[indexPath.row])
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
        } else {
            cell.textLabel?.text = String(Hours.hours[indexPath.row]) + " " + taskForThisHour.first!.name
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .systemGreen
        }

        return cell
        }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
        }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentHourStartDate = Date(timeIntervalSince1970: self.selectedDayStartTimestamp)
                                   .addingTimeInterval(TimeInterval(60*60*indexPath.row))
        let currentHourStartTimestamp = currentHourStartDate.timeIntervalSince1970

        let taskForThisHour: Results<Task> = tasks.where {
            $0.dateStart == currentHourStartTimestamp
            }

        if taskForThisHour.count != 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TaskVC") as? TaskViewController
            viewController!.modalPresentationStyle = .fullScreen
            viewController?.task = taskForThisHour.first
            self.present(viewController!, animated: true)
            }
        }
}
