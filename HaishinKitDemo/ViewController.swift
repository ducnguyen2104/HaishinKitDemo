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
    
    var streamUrl: String {
        return streamUrlTxtField.text ?? ""
    }
    
    var streamKey: String {
        return streamKeyTxtField.text ?? ""
    }
    
    private lazy var streamUrlTxtField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.placeholder = "rtmp://localhost/live"
        textField.text = "rtmp://127.0.0.1/live"
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var streamKeyTxtField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.placeholder = "streamKey"
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var watchBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Watch", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(watch), for: .touchUpInside)
        button.backgroundColor = .gray
        return button
    }()
    
    @objc private func watch() {
        let vc = WatchViewController()
        vc.streamUrl = streamUrl
        vc.streamKey = streamKey
        present(vc, animated: true, completion: nil)
    }
    
    private lazy var streamBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Stream", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(stream), for: .touchUpInside)
        button.backgroundColor = .gray
        return button
    }()
    
    @objc private func stream() {
        let vc = StreamViewController()
        vc.streamUrl = streamUrl
        vc.streamKey = streamKey
        present(vc, animated: true, completion: nil)
    }
    
    private lazy var closeKbView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKb)))
        return view
    }()
    
    @objc private func closeKb() {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(closeKbView)
        view.addSubview(streamUrlTxtField)
        view.addSubview(streamKeyTxtField)
        view.addSubview(watchBtn)
        view.addSubview(streamBtn)
        
        closeKbView.frame = view.bounds
        
        streamUrlTxtField.frame = CGRect(x: 0,
                                         y: view.frame.height/5 - 50,
                                         width: view.frame.width,
                                         height: 100)
        
        streamKeyTxtField.frame = CGRect(x: 0,
                                         y: 2*view.frame.height/5 - 50,
                                         width: view.frame.width,
                                         height: 100)
        
        watchBtn.frame = CGRect(x: view.frame.width/4,
                                y: 3*view.frame.height/5 - 50,
                                width: view.frame.width/2,
                                height: 100)
        
        streamBtn.frame = CGRect(x: view.frame.width/4,
                                 y: 4*view.frame.height/5 - 50,
                                 width: view.frame.width/2,
                                 height: 100)
    }    

}

