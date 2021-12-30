//
//  WatchViewController.swift
//  HaishinKitDemo
//
//  Created by Duc Nguyen on 27/12/2021.
//

import UIKit
import AVFoundation
import HaishinKit

class WatchViewController: UIViewController, HKPictureInPictureController {

    var streamUrl: String = ""
    var streamKey: String = ""
    
    private static let maxRetryCount: Int = 5
    
    @IBOutlet private weak var playbackButton: UIButton!
    private var rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream!
    private var retryCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rtmpStream = RTMPStream(connection: rtmpConnection)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)

        let hkView = MTHKView(frame: view.bounds)
        hkView.videoGravity = AVLayerVideoGravity.resizeAspect
        hkView.attachStream(rtmpStream)
        hkView.transform = CGAffineTransform(scaleX: 1, y: -1)
        // add ViewController#view
        view.addSubview(hkView)
        
        rtmpConnection.connect(streamUrl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rtmpConnection.close()
        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
    }
    
    @objc
        private func rtmpStatusHandler(_ notification: Notification) {
            let e = Event.from(notification)
            guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
                return
            }
            print(code)
            switch code {
            case RTMPConnection.Code.connectSuccess.rawValue:
                retryCount = 0
                rtmpStream.play(streamKey)
            case RTMPConnection.Code.connectFailed.rawValue, RTMPConnection.Code.connectClosed.rawValue:
                guard retryCount <= WatchViewController.maxRetryCount else {
                    return
                }
                Thread.sleep(forTimeInterval: pow(2.0, Double(retryCount)))
                rtmpConnection.connect(streamUrl)
                retryCount += 1
            default:
                break
            }
        }
}
