

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var roll: UITextField!
    
    @IBOutlet weak var save: UIButton!
    
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var showBtn: UIButton!
    
    let mainRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        save.layer.cornerRadius=10.0
        delete.layer.cornerRadius=10.0
        showBtn.layer.cornerRadius=10.0
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func onSaveClicked(_ sender: Any) {
        let name = self.name.text ?? ""
        let roll = self.roll.text ?? ""
        
        if( name.isEmpty || roll.isEmpty){
            self.message.text = "Please fill up all fields"
            return
        }
        
        let dataMap = [
            "name": name,
            "roll": roll,
        ]
        
        mainRef.child("student").childByAutoId().setValue(dataMap){ (err,ref) in
            if( err == nil){
                self.name.text = ""
                self.roll.text = ""
                self.message.text = "Data saved successfully"
            }
            else{
                self.message.text = "User data could not be saved"
            }
        }
        
    }
    
    
    @IBAction func showClicked(_ sender: Any) {
        let firebaseReference = mainRef.child("student").queryOrderedByKey().queryLimited(toLast: 1)
        
        firebaseReference.observe(DataEventType.value, with: { snap in
            
            if( snap.exists() ){
                
                if let lastOne = snap.children.allObjects.first as? DataSnapshot {
                    
                    if let data = lastOne.value as? [String: Any] {
                        let name:String? = data["name"] as? String
                        let roll:String? = data["roll"] as? String
                        
                        
                        self.data.text = "name: \(name!)\nroll: \(roll!)"
                    }
                    
                }
                else {
                    self.data.text = "No child nodes found"
                }
                
            }
            
        })
        
    }
    @IBAction func deleteClicked(_ sender: Any) {
        mainRef.child("student").queryOrderedByKey().queryLimited(toLast: 1)
            .observeSingleEvent(of: .value){ snapshot in
            
            if let lastChild = snapshot.children.allObjects.first as? DataSnapshot {
                
                self.mainRef.child("student").child(lastChild.key).removeValue { err, _ in
                    if let error = err {
                        self.message.text = "Data could not be deleted"
                    }
                    else {
                        self.message.text = "User data deleted successfully"
                        self.data.text=""
                    }
                }
            }
            else {
                self.message.text = "No data found"
            }
        }
    }
    
}

