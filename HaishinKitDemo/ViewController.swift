//
//  ViewController.swift
//  HaishinKitDemo
//
//  Created by Duc Nguyen on 27/12/2021.
//

import UIKit
import AVFoundation
import HaishinKit

class ViewController: UIViewController {
    
    static let streamKey = "SJVer-vst"
    
    private lazy var watchBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Watch", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(watch), for: .touchUpInside)
        return button
    }()
    
    @objc private func watch() {
        let vc = WatchViewController()
        present(vc, animated: true, completion: nil)
    }
    
    private lazy var streamBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Stream", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(stream), for: .touchUpInside)
        return button
    }()
    
    @objc private func stream() {
        let vc = StreamViewController()
        present(vc, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(watchBtn)
        view.addSubview(streamBtn)
        
        watchBtn.frame = CGRect(x: 0,
                                y: view.frame.height/4 - 50,
                                width: view.frame.width,
                                height: 100)
        
        streamBtn.frame = CGRect(x: 0,
                                 y: 3*view.frame.height/4 - 50,
                                 width: view.frame.width,
                                 height: 100)
    }    

}

