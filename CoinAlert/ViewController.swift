//
//  ViewController.swift
//  CoinAlert
//
//  Created by Brady Sullivan on 12/7/16.
//
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeBar: UIProgressView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var coinbaseLabel: UILabel!
    
    var timer = Timer()
    var currentPrice = "$..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let cb = NSMutableAttributedString(string: "Coinbase")
            cb.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: NSMakeRange(0, cb.length))
        coinbaseLabel.attributedText = cb
        
        coinbaseLabel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.cbPressed))
        coinbaseLabel.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePrice()
        updateDevice()
        errorLabel.isHidden = true
        timeBar.progress = 0.0
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timeBarUpdate), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cbPressed() {
        if let url = URL(string: "https://www.coinbase.com/join/d1str0"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func timeBarUpdate() {
        priceLabel.text = currentPrice
        let prog = timeBar.progress + 0.0066666
        if prog >= 1 {
            timeBar.progress = 0
            updatePrice()
        } else {
            timeBar.progress = prog
        }
        
    }
    
    func updatePrice() {
        let requestURL: NSURL = NSURL(string: "https://whatdoesabitcoincost.com/api/current")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do{
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if let json = json as? [String: Any] {
                        self.currentPrice = "$\(json["currentPrice"]!)"
                        DispatchQueue.main.async {
                            self.errorLabel.isHidden = true
                        }
                    }
                    
                }catch {
                    print("Error with Json: \(error)")
                    DispatchQueue.main.async {
                        self.errorLabel.isHidden = false
                    }
                }
            }
        }
        
        task.resume()
        
    }
    
    func updateDevice() {
        let json = ["Id": UIDevice.current.identifierForVendor!.uuidString, "APNToken": nil, "SysVersion": UIDevice.current.systemVersion, "SysName": UIDevice.current.systemName, "Name": UIDevice.current.name, "Model": UIDevice.current.model]
        do {
          let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        
        let requestURL: NSURL = NSURL(string: "https://whatdoesabitcoincost.com/api/register")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            print(statusCode)
        }
        
        task.resume()
        } catch {
            
        }
        
    }
}

