//
//  KAudioRecorder
//
//  Copyright © 2017 Kenan Atmaca. All rights reserved.
//  kenanatmaca.com
//
//

import AVFoundation
import UIKit

class KAudioRecorder: NSObject {
    static var shared = KAudioRecorder()

    var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
    var timer: Timer!

    var isPlaying: Bool = false
    var isRecording: Bool = false
    var url: URL?
    var time: Int = 0
    var recordName: String?

    override init() {
        super.init()

        isAuth()
    }

    private func recordSetup() {
        let newVideoName = getDir().appendingPathComponent(recordName?.appending(".m4a") ?? "sound.m4a")

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])

            audioRecorder = try AVAudioRecorder(url: newVideoName, settings: settings)
            audioRecorder.delegate = self as AVAudioRecorderDelegate
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()

        } catch {
            print("Recording update error:", error.localizedDescription)
        }
    }

    func record() {
        recordSetup()

        if let recorder = self.audioRecorder {
            if !isRecording {
                do {
                    try audioSession.setActive(true)

                    time = 0
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

                    recorder.record()
                    isRecording = true

                } catch {
                    print("Record error:", error.localizedDescription)
                }
            }
        }
    }

    @objc private func updateTimer() {
        if isRecording, !isPlaying {
            time += 1

        } else {
            timer.invalidate()
        }
    }

    func stop() {
        audioRecorder.stop()

        do {
            try audioSession.setActive(false)
        } catch {
            print("stop()", error.localizedDescription)
        }
    }

    func pause() {
        audioRecorder.pause()
        isRecording = false

//        do {
//            try audioSession.setActive(false)
//        } catch {
//            print("stop()",error.localizedDescription)
//        }
    }

    func continueRecord() {
        audioRecorder.record()
        isRecording = true

//        do {
//            try audioSession.setActive(true)
//        } catch {
//            print("stop()",error.localizedDescription)
//        }
    }

    func play() {
        if !isRecording, !isPlaying {
            if let recorder = self.audioRecorder {
                if recorder.url.path == url?.path, url != nil {
                    do {
                        try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                    } catch _ {}
                    isPlaying = true
                    audioPlayer.play()
                    return
                }

                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: recorder.url)
                    audioPlayer.delegate = self as AVAudioPlayerDelegate

                    try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                    isPlaying = true

                    url = audioRecorder.url
                    audioPlayer.play()

                } catch {
                    print("play(), ", error.localizedDescription)
                }
            }

        } else {
            return
        }
    }

    func play(name: String, slider _: UISlider = UISlider()) {
        let bundle = getDir().appendingPathComponent(name.appending(".m4a"))

        if FileManager.default.fileExists(atPath: bundle.path), !isRecording, !isPlaying {
            do {
//                do {
//                    try audioSession.setActive(false)
//                } catch {
//                    print("stop()",error.localizedDescription)
//                }
//                try AVAudioSession.sharedInstance().setCategory(.playback, options: .defaultToSpeaker)

                audioPlayer = try AVAudioPlayer(contentsOf: bundle)

                audioPlayer.delegate = self as AVAudioPlayerDelegate
//                audioPlayer = try AVAudioPlayer(contentsOf: bundle, fileTypeHint: AVFileType.m4a.rawValue)
                audioPlayer.prepareToPlay()
                isPlaying = true
                audioPlayer.play()

            } catch {
                print("play(with name:), ", error.localizedDescription)
            }

        } else {
            return
        }
    }

    func getDuration(name: String) -> Int {
        let bundle = getDir().appendingPathComponent(name.appending(".m4a"))

        if FileManager.default.fileExists(atPath: bundle.path), !isRecording, !isPlaying {
            do {
                do {
                    try audioSession.setActive(true)
                } catch {
                    print("stop()", error.localizedDescription)
                }
                audioPlayer = try AVAudioPlayer(contentsOf: bundle)
                audioPlayer.delegate = self as AVAudioPlayerDelegate

                audioPlayer.prepareToPlay()
                return Int(audioPlayer.duration)

            } catch {
                print("play(with name:), ", error.localizedDescription)
                return 0
            }

        } else {
            return 0
        }
    }

    func playerCurrentTime() -> Any {
        return audioPlayer.currentTime
    }

    func getData(name: String) -> Data {
        let bundle = getDir().appendingPathComponent(name.appending(".m4a"))

        let fileData = NSData(contentsOfFile: bundle.path)
        if fileData != nil {
            // do something useful
            return fileData! as Data
        }
        return fileData! as Data

//        if FileManager.default.fileExists(atPath: bundle.path) && !isRecording && !isPlaying {
//
//           let data = NSData.dataWithContentsOfURL(bundle.path, options: [], error: nil)
//
//        } else {
//            print("play(with name:)")
//        }
    }

    func delete(name: String) {
        let bundle = getDir().appendingPathComponent(name.appending(".m4a"))
        let manager = FileManager.default

        if manager.fileExists(atPath: bundle.path) {
            do {
                try manager.removeItem(at: bundle)
            } catch {
                print("delete()", error.localizedDescription)
            }

        } else {
            print("File is not exist.")
        }
    }

    func stopPlaying() {
        audioPlayer.stop()
        isPlaying = false
    }

    private func getDir() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let type = fileName.audiomediaFileName
        let fileURL = paths!.appendingPathComponent(type + "/")
        return fileURL
    }

    @discardableResult
    func isAuth() -> Bool {
        var result: Bool = false

        AVAudioSession.sharedInstance().requestRecordPermission { res in
            result = res == true ? true : false
        }

        return result
    }

    func getTime() -> String {
        var result: String = ""

        if time < 60 {
            result = "\(time)"

        } else if time >= 60 {
            result = "\(time / 60):\(time % 60)"
        }

        return result
    }
} //

extension KAudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_: AVAudioRecorder, successfully _: Bool) {
        isRecording = false
        url = nil
        timer.invalidate()
        print("record finish")
    }

    func audioRecorderEncodeErrorDidOccur(_: AVAudioRecorder, error: Error?) {
        print(error.debugDescription)
    }
}

extension KAudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully _: Bool) {
        isPlaying = false
        print("playing finish")
    }

    func audioPlayerDecodeErrorDidOccur(_: AVAudioPlayer, error: Error?) {
        print(error.debugDescription)
    }
}
