//
//  ViewController.swift
//  TodoApp
//
//  Created by eun-ji on 2023/02/24.
//

import UIKit
import CoreData

enum PriorityLevel: Int64 {
    case level1
    case level2
    case level3
}

extension PriorityLevel {
    var color: UIColor{
        switch self {
        case .level1:
            return .yellow
        case .level2:
            return .orange
        case .level3:
            return .red
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var todoTableView: UITableView!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate // AppDelegate 접근
    
    var todoList = [TodoList]() // TodoList entity
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "To Do List"
        self.makeNavigaionBar()
        
        todoTableView.delegate = self
        todoTableView.dataSource = self
        todoTableView.backgroundColor = UIColor(white: 245/255, alpha: 1)
        
        fetchData()
        todoTableView.reloadData()
       
 }
    //local db 데이터 불러오기
    func fetchData() {
        // TodoList entity
        let fetchRequest : NSFetchRequest<TodoList> = TodoList.fetchRequest()
        let context =  appdelegate.persistentContainer.viewContext
        // appdelegate -> persistentContainer -> viewContext
        
        do {
            self.todoList = try context.fetch(fetchRequest)
        }catch {
            print(error)
        }
    }
    
    func makeNavigaionBar () {
        // bar item (add) 추가
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTodo)) // 액션
        item.tintColor = .black
        navigationItem.rightBarButtonItem = item
        
        //상단 색깔변경
//        let barAppearance = UINavigationBarAppearance()
//        barAppearance.backgroundColor = .blue
//
//        self.navigationController?.navigationBar.standardAppearance = barAppearance
    }
    @objc func addNewTodo() { // + 버튼 눌리면 화면 전환
        let detailVC = TodoDetailViewController.init(nibName: "TodoDetailViewController", bundle: nil)
        detailVC.delegate = self
        self.present(detailVC, animated: true)
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell //TodoCell 적용
        cell.topTitle.text = todoList[indexPath.row].title //title = entity 속성
        
        if let hasDate = todoList[indexPath.row].date { // date = entity 속성
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd hh:mm:ss"
            let dateString = formatter.string(from: hasDate)
            cell.dataLabel.text = dateString
        }else {
            cell.dataLabel.text = ""
        }

        let priority = todoList[indexPath.row].priorityLevel // priorityLevel = entity 속성
        let priorityColor = PriorityLevel(rawValue: priority)?.color // PriorityLevel 별 색상 적용
        
        cell.priorityView.backgroundColor = priorityColor
        cell.priorityView.layer.cornerRadius = cell.priorityView.bounds.height / 2 //priorityView 모서리 둥글게
        return cell
    }
    
    // 셀 눌렸을 때 화면 전환
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = TodoDetailViewController.init(nibName: "TodoDetailViewController", bundle: nil)
        detailVC.delegate = self
        detailVC.selectedTodoList = todoList[indexPath.row]
        self.present(detailVC, animated: true)
        
    }
    
}

extension ViewController: TodoDetailViewControllerDelegate {
    func didFinishSaveData() {
        self.fetchData()
        self.todoTableView.reloadData()
    }
    
    
}
