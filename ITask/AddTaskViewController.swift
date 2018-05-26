//
//  AddTaskViewController.swift


import UIKit
import EventKit

//Class to add a task
class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFeild: UITextField!
    
    @IBOutlet weak var taskNotes: UITextView!
    
    @IBOutlet weak var isImp: UISwitch!
    
    var selectedDate : Date!

    
    @IBAction func datePickerDidSelectNewDate(_ sender: UIDatePicker) {
        
        selectedDate = sender.date
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.scheduleNotification(at: selectedDate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false

        self.textFeild.delegate = self as UITextFieldDelegate


        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //Function for button tapped to save the task added
    @IBAction func btnTapped(_ sender: Any) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate!).persistentContainer.viewContext
        let task = Task(context: context)
        task.name = textFeild.text!
        task.isImportant = isImp.isOn
        task.isOverdue = false
        task.time = selectedDate as NSDate
        task.notes = taskNotes.text!
        
        
        //Save the data to core data
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        //Save the data to Event Kit to display in calendar
        
        let store = EKEventStore()
        store.requestAccess(to: .event) { (success, error) in
            if  error == nil {
                let event = EKEvent.init(eventStore: store)
                event.title = task.name!
                event.calendar = store.defaultCalendarForNewEvents // this will return default calendar from device calendars
                event.startDate = Date()
                event.endDate = self.selectedDate
                event.notes = task.notes!
                
                let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -3600, since: event.startDate))
                event.addAlarm(alarm)
                
                do {
                    try store.save(event, span: .thisEvent)
                    //event created successfullt to default calendar
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                
            } else {
                //we have error in getting access to device calnedar
                print("error = \(String(describing: error?.localizedDescription))")
            }
         }
        
        navigationController!.popViewController(animated: true)
        
    }


}

    
