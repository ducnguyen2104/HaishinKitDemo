//
//  StreamViewController.swift
//  HaishinKitDemo
//
//  Created by Duc Nguyen on 27/12/2021.
//

import UIKit
import AVFoundation
import HaishinKit
import VideoToolbox

class StreamViewController: UIViewController {
    private static let maxRetryCount: Int = 5
    
    private var rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream!
    private var retryCount: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let session = AVAudioSession.sharedInstance()
        do {
            // https://stackoverflow.com/questions/51010390/avaudiosession-setcategory-swift-4-2-ios-12-play-sound-on-silent
            if #available(iOS 10.0, *) {
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            } else {
                session.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playAndRecord, with: [
                    AVAudioSession.CategoryOptions.allowBluetooth,
                    AVAudioSession.CategoryOptions.defaultToSpeaker]
                )
                try session.setMode(.default)
            }
            try session.setActive(true)
        } catch {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpStream = RTMPStream(connection: rtmpConnection)
        
        rtmpStream.captureSettings = [
            .fps: 30, // FPS
            .sessionPreset: AVCaptureSession.Preset.medium, // input video width/height
//             .isVideoMirrored: false,
            // .continuousAutofocus: false, // use camera autofocus mode
            // .continuousExposure: false, //  use camera exposure mode
            // .preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode.auto
        ]
        rtmpStream.audioSettings = [
            .muted: false, // mute audio
            .bitrate: 32 * 1000,
        ]
        rtmpStream.videoSettings = [
            .width: 640*3/4, // video output width
            .height: 640, // video output height
            .bitrate: 160 * 1000, // video output bitrate
            .profileLevel: kVTProfileLevel_H264_Baseline_3_1, // H264 Profile require "import VideoToolbox"
            .maxKeyFrameIntervalDuration: 2, // key frame / sec
        ]
        
        rtmpStream.orientation = .portrait
        rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
            print(error)
        }
//        rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
//            print(error)
//        }
        
        let hkView = MTHKView(frame: view.bounds)
        hkView.videoGravity = AVLayerVideoGravity.resizeAspect
        hkView.attachStream(rtmpStream)
        
        // add ViewController#view
        view.addSubview(hkView)
        
        rtmpConnection.connect("rtmp://192.168.1.122/live")
        // if you want to record a stream.
        // rtmpStream.publish("streamName", type: .localRecord)
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
            rtmpStream.publish(ViewController.streamKey)
            // sharedObject!.connect(rtmpConnection)
        case RTMPConnection.Code.connectFailed.rawValue, RTMPConnection.Code.connectClosed.rawValue:
            guard retryCount <= StreamViewController.maxRetryCount else {
                return
            }
            Thread.sleep(forTimeInterval: pow(2.0, Double(retryCount)))
            rtmpConnection.connect("rtmp://192.168.1.122/live")
            retryCount += 1
        default:
            break
        }
    }
}
