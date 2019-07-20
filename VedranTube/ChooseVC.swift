//
//  ChooseVC.swift
//  VedranTube
//
//  Created by Dimitar Spasovski on 7/20/19.
//  Copyright © 2019 Dimitar Spasovski. All rights reserved.
//

import UIKit

class ChooseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func masha(_ sender: UITapGestureRecognizer) {
        let vc:ViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.masha = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pepa(_ sender: UITapGestureRecognizer) {
        let vc:ViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
