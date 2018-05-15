//
//  AddTaskViewController.swift


import UIKit



class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFeild: UITextField!
    
    @IBOutlet weak var isImp: UISwitch!
   
    
    @IBAction func datePickerDidSelectNewDate(_ sender: UIDatePicker) {
        
        let selectedDate = sender.date
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
    
    
    
    
    @IBAction func btnTapped(_ sender: Any) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate!).persistentContainer.viewContext
        let task = Task(context: context)
        task.name = textFeild.text!
        task.isImportant = isImp.isOn
        
        //Save the data to core data
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        
        navigationController!.popViewController(animated: true)
        
    }
    

    }

    
