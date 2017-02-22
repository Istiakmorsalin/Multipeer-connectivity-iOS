//
//  ViewController.swift
//  Multipeer Connectivity
//
//  Created by Slbd on 2/16/17.
//  Copyright © 2017 Slbd. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var connectionsLabel: UILabel!
    
    let colorService = ColorServiceManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        colorService.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func redTapped(sender: AnyObject) {
        self.change(UIColor.redColor())
        colorService.send("red")
    }
    
    
    @IBAction func yellowTapped(sender: AnyObject) {
        self.change(UIColor.yellowColor())
        colorService.send("yellow")
    }
    
    func change(color : UIColor) {
//        UIView.animate(withDuration: 0.2) {
//            self.view.backgroundColor = color
//        }
        UIView.animateWithDuration(0.2, animations: {
            self.view.backgroundColor = color
        })
    }


}

extension ViewController : ColorServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: ColorServiceManager, connectedDevices: [String]) {
        //        OperationQueue.main.addOperation {
        //            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        //        }
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        })
    }
    
    func colorChanged(manager: ColorServiceManager, colorString: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            switch colorString {
            case "red":
                self.change(UIColor.redColor())
            case "yellow":
                self.change(UIColor.yellowColor())
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
    
}


