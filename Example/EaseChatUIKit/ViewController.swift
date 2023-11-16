//
//  ViewController.swift
//  EaseChatUIKit
//
//  Created by zjc19891106 on 11/01/2023.
//  Copyright (c) 2023 zjc19891106. All rights reserved.
//

import UIKit
import EaseChatUIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let search = EaseChatNavigationBar(showLeftItem: true,textAlignment: .left,rightImages: [UIImage(systemName: "pencil.circle")!,UIImage(systemName: "square.and.arrow.up")!,UIImage(systemName: "trash")!])
        search.title = "Conversations"
        search.subtitle = "online"
        self.view.addSubview(search)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

