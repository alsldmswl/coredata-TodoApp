//
//  TodoDetailViewController.swift
//  TodoApp
//
//  Created by eun-ji on 2023/02/24.
//

import UIKit
import CoreData

protocol TodoDetailViewControllerDelegate: AnyObject {
    func didFinishSaveData()
}

class TodoDetailViewController: UIViewController {

    weak var delegate: TodoDetailViewControllerDelegate?
    
    @IBOutlet weak var titleTf: UITextField!
    @IBOutlet weak var normalBtn: UIButton!
    @IBOutlet weak var highBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var lowBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedTodoList: TodoList?
    
    var priority: PriorityLevel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let hasData = selectedTodoList  {
            titleTf.text = hasData.title
            priority = PriorityLevel(rawValue: hasData.priorityLevel)
            makePriorityButtonDesign()
            
            deleteBtn.isHidden = false
            saveBtn.setTitle("Update", for: .normal)
        }else {
            deleteBtn.isHidden = true
            saveBtn.setTitle("Save", for: .normal)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lowBtn.layer.cornerRadius = lowBtn.bounds.height / 2
        normalBtn.layer.cornerRadius = normalBtn.bounds.height / 2
        highBtn.layer.cornerRadius = highBtn.bounds.height / 2
    }
  
    @IBAction func setPriority(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            priority = .level1
        case 2:
            priority = .level2
        case 3:
            priority = .level3
        default:
            break
        }
        makePriorityButtonDesign()
    }
    
    func makePriorityButtonDesign() {
        lowBtn.backgroundColor = .clear
        normalBtn.backgroundColor = .clear
        highBtn.backgroundColor = .clear
 
        switch self.priority {
        case .level1:
            lowBtn.backgroundColor = priority?.color
        case .level2:
            normalBtn.backgroundColor = priority?.color
        case .level3:
            highBtn.backgroundColor = priority?.color
        default:
            break
        }
    }
    
    // 값 저장
    @IBAction func saveTodo(_ sender: Any) {
      
        if selectedTodoList != nil {
            updateTodo()
        }else {
            saveTodo()
        }
        delegate?.didFinishSaveData()
        self.dismiss(animated: true)
    }
    
    func saveTodo() {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "TodoList", in: context) else {return}
        
        guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? TodoList else {return}
        
        object.title = titleTf.text
        object.date = Date()
        object.uuid = UUID()
        object.priorityLevel = priority?.rawValue ?? PriorityLevel.level1.rawValue
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.saveContext()
    }
    
    
    func updateTodo() {
        guard let hasData = selectedTodoList else {return}
        guard let hasUUID = hasData.uuid else {return}
        
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        do{
           let loadedData = try context.fetch(fetchRequest)
            loadedData.first?.title = titleTf.text
            loadedData.first?.date = Date()
            loadedData.first?.priorityLevel = self.priority?.rawValue ?? PriorityLevel.level1.rawValue
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            appDelegate.saveContext()
        }
        catch {
            print(error)
        }
      
    }
    
    
    @IBAction func deleteTodo() {
        guard let hasData = selectedTodoList else {
            return
        }
        guard let hasUUID = hasData.uuid else {
            return
        }
        
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        do{
            let loadedData = try context.fetch(fetchRequest)
            
            if let loadedFirstData = loadedData.first{
                context.delete(loadedFirstData)
                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                appDelegate.saveContext()
            }
            
        }catch {
            print(error)
        }
        
        delegate?.didFinishSaveData()
        self.dismiss(animated: true)
    }
}
