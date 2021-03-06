//
//  TaskViewController.swift


import UIKit
import TwitterKit


//Class to display the tasks add and further options to add task, settings, rewards etc
class TaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    static var isEmailogin = false
    static var isGoogleLogin = false
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func openProfile(_ sender: Any) {
        
    }
    
    
    var rewards: Int = 0
    var tasks: [Task] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ITask"
        tableView.dataSource = self
        tableView.delegate = self
        addLongPressGesture()

        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        
        addItemView.layer.cornerRadius = 5

        
        // Do any additional setup after loading the view.
    }
    
final class alertController : UIAlertController {
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}
    
    //Create Animation
    func animateIn() {
        
        self.view.addSubview(addItemView)
        addItemView.center = self.view.center
        addItemView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        addItemView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.addItemView.alpha = 1
            self.addItemView.transform = CGAffineTransform.identity
        }
        
    }
    
    //Create animation
    func animateOut(){
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.addItemView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.addItemView.alpha = 0
            
            self.visualEffectView.effect = nil
            
        }) { (sucess: Bool ) in
            
            self.addItemView.removeFromSuperview()
        }
        
    }
    
    
    //Clear out all rewards earned
    @IBAction func ClearReward(_ sender: Any) {
        
        numberOfReward.text = String("No Reward 😔")
        
    }
    
    
    @IBOutlet weak var numberOfReward: UILabel!
    
    
    //Show count of all rewards earned
    @IBAction func ShowReward(_ sender: Any) {
        
        animateIn()
        numberOfReward.text = String.init(describing: rewards)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = false

        
        
        //get the data from core data
        getData()
        
        //reload  the table view
        tableView.reloadData()
    }
    
    //LogOut Button functionality
    @IBAction func LogoutButton(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: "Logout", message: "Are you sure?", preferredStyle: .alert)
        
        // Create OK button
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            if(TaskViewController.isEmailogin == true ) {
                self.navigationController?.popToRootViewController(animated: true)
                print("Email:logout : ok tapped")
            } else if (TaskViewController.isGoogleLogin == true){
                print("Google:logout : ok tapped")
                self.navigationController?.popToRootViewController(animated: true)
            } else {
            
               let store = Twitter.sharedInstance().sessionStore
               if let userID = store.session()?.userID {
                store.logOutUserID(userID)
                print ("logged out")
                
                
                self.navigationController?.popToRootViewController(animated: true) }

            
              // Code in this block will trigger when OK button tapped.
                print("Twitter Logout : Ok button tapped");
            }
            
        }
        alertController.addAction(OKAction)
        
        // Create Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped");
        }
        alertController.addAction(cancelAction)
        
        // Present Dialog message
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    //Function to show the Iphone Calendar
    @IBAction func ShowCalendarView(_ sender: Any) {
        
        open(scheme: "calshow://")
    }
    
    //Function to make a URL call to the Iphone Calendar
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet var addItemView: UIView!
    var effect:UIVisualEffect!
    var cellSnapshot: UIView?
    var initialIndexPath: IndexPath?


    
    @IBAction func dismissPopup(_ sender: UIButton) {
        
        animateOut()
    }
    
    
    //Table View Creation with a table row for each task
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.font = UIFont(name:"AvenirNextCondensed-regular", size: 16)
        
        let task = tasks[indexPath.row]
        
        let taskDate = task.time! as Date
        let dateString = taskDate.toString(withFormat: "yyyy-MM-dd HH:mm:ss")
        
        if (Date().compare(taskDate) == .orderedDescending) {
            task.isOverdue = true
        }
        
        //Check if task is important
        if task.isImportant{
  
            cell.textLabel?.text = " ❗️" + dateString + " :  \(task.name!)"
            
            if(task.isOverdue){
                cell.textLabel?.textColor = UIColor.red
            } else {
                cell.textLabel?.textColor = UIColor.brown
            }
            
        } else {
            
            cell.textLabel?.text = dateString + "  \(task.name!)"
            
            if(task.isOverdue){
                 cell.textLabel?.textColor = UIColor.red
            } else {
                cell.textLabel?.textColor = UIColor.orange
            }
        }

        
        return cell
        
    }
    
    
    //Fetch the data from Core Data
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            tasks = try context.fetch(Task.fetchRequest())
        }
        catch {
            
            print("Fetching failed")
        }
    }
    
    
    //Table row actions for Delete and Task Complete
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action:UITableViewRowAction, indexPath:IndexPath) in
            print("delete at:\(indexPath)")
            
        
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let task = self.tasks[indexPath.row]
            

            context.delete(task)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                self.tasks = try context.fetch(Task.fetchRequest())
            }
            catch {
                print ("Fetching failed")
            }
            tableView.reloadData()
            
        }
        delete.backgroundColor = .red
        
        let more = UITableViewRowAction(style: .default, title: "Done") { (action:UITableViewRowAction, indexPath:IndexPath) in
            print("more at:\(indexPath)")
            
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let task = self.tasks[indexPath.row]
                if (task.isImportant){
                    self.rewards = self.rewards + 1
                    context.delete(task)
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        do {
                            self.tasks = try context.fetch(Task.fetchRequest())
                        }
                        catch {
                            print ("Fetching failed")
                        }
                        tableView.reloadData()
                
            }
                
            else {
                context.delete(task)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                do {
                    self.tasks = try context.fetch(Task.fetchRequest())
                }
                catch {
                    print ("Fetching failed")
                }
                tableView.reloadData()
            }
        }
        more.backgroundColor = .orange
        
        return [delete, more, ]
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return tasks.count
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// code for drag and drop cells



extension TaskViewController {
    
    func addLongPressGesture() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender: )))
        tableView.addGestureRecognizer(longpress)
    }
    
    func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        let locationInView = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        if sender.state == .began {
            if indexPath != nil {
                initialIndexPath = indexPath
                let cell = tableView.cellForRow(at: indexPath!)
                cellSnapshot = snapshotOfCell(inputView: cell!)
                var center = cell?.center
                cellSnapshot?.center = center!
                cellSnapshot?.alpha = 0.0
                tableView.addSubview(cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    self.cellSnapshot?.center = center!
                    self.cellSnapshot?.transform = (self.cellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
                    self.cellSnapshot?.alpha = 0.99
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
        } else if sender.state == .changed {
            var center = cellSnapshot?.center
            center?.y = locationInView.y
            cellSnapshot?.center = center!
            
            if ((indexPath != nil) && (indexPath != initialIndexPath)) {
                swap(&tasks[indexPath!.row], &tasks[initialIndexPath!.row])
                tableView.moveRow(at: initialIndexPath!, to: indexPath!)
                initialIndexPath = indexPath
            }
        } else if sender.state == .ended {
            let cell = tableView.cellForRow(at: initialIndexPath!)
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.cellSnapshot?.center = (cell?.center)!
                self.cellSnapshot?.transform = CGAffineTransform.identity
                self.cellSnapshot?.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    self.initialIndexPath = nil
                    self.cellSnapshot?.removeFromSuperview()
                    self.cellSnapshot = nil
                }
            })
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}


extension Date {
    
    func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let myString = formatter.string(from: self)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format
        
        return formatter.string(from: yourDate!)
    }
}
