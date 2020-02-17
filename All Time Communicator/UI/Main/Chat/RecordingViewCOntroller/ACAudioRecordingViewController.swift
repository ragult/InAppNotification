//
//  ACAudioRecordingViewController.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 19/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Accelerate
import AVKit
import UIKit

class ACAudioRecordingViewController: UIViewController {
    // Mark: RecordView
    @IBOutlet var recordView: UIView!
    @IBOutlet var recordCloseButton: UIButton!
    @IBOutlet var audioVisualView: UIView!
    var audioView = AudioVisualizerView()

    @IBOutlet var audioSendView: UIStackView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var sendAudioButton: UIButton!
    @IBOutlet var pauseButton: UIButton!

    @IBOutlet var playView: UIView!
    @IBOutlet var pauseView: UIView!
    @IBOutlet var stopView: UIView!
    @IBOutlet var continueView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var sliderView: UIView!

    weak var audioDelegate: processAudioDataDelegate?

    fileprivate var timer: Timer!
    fileprivate var playtimer: Timer!

    var time: Int = 0

    var isPlaying: Bool = false
    var isRecording: Bool = false
    var counter: Int = 0
    @IBOutlet var slider: UISlider!
    @IBOutlet var sendButtonHeightConstraint: NSLayoutConstraint!

    var recordingName = ""
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sendButtonHeightConstraint.constant = 0
        let timestamp = getcurrentTimeStampFOrPubnub()
        let userid = UserDefaults.standard.string(forKey: UserKeys.userGlobalId) ?? ""
        let name = String(format: "%.0f", timestamp)
        recordingName = (userid + name)

        statusLabel.text = "Recording..."
        slider.setThumbImage(UIImage(named: "ovalCopy3")!, for: .normal)
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
    }

    override func viewDidAppear(_: Bool) {
        audioView.alpha = 1
        audioView.isHidden = false
        recordView.isHidden = false

        startRecording()
    }

    // MARK: - Recording

    let audioEngine = AVAudioEngine()
    private var renderTs: Double = 0
    private var recordingTs: Double = 0
    private var silenceTs: Double = 0
    private var audioFile: AVAudioFile?
    let settings = [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: true, AVSampleRateKey: Float64(44100), AVNumberOfChannelsKey: 1] as [String: Any]
    var recorder = KAudioRecorder.shared

    private func format() -> AVAudioFormat? {
        let format = AVAudioFormat(settings: settings)
        return format
    }

    fileprivate func setupAudioView() {
        audioSendView.isHidden = true
        audioView.frame = CGRect(x: 20, y: 0, width: 225, height: 60)
        audioVisualView.addSubview(audioView)
        audioView.alpha = 1
        audioView.isHidden = false
    }

    private func startRecording() {
        setupAudioView()

        recorder.recordName = recordingName
        isRecording = true
        time = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

        recorder.record()

        recordingTs = NSDate().timeIntervalSince1970
        silenceTs = 0

        let inputNode = audioEngine.inputNode
        guard let format = self.format() else {
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            let level: Float = -50
            let length: UInt32 = 1024
            buffer.frameLength = length
            let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
            var value: Float = 0
            vDSP_meamgv(channels[0], 1, &value, vDSP_Length(length))
            var average: Float = ((value == 0) ? -100 : 20.0 * log10f(value))
            if average > 0 {
                average = 0
            } else if average < -100 {
                average = -100
            }
            let silent = average < level
            let ts = NSDate().timeIntervalSince1970
            if ts - self.renderTs > 0.1 {
                let floats = UnsafeBufferPointer(start: channels[0], count: Int(buffer.frameLength))
                let frame = floats.map { (f) -> Int in
                    Int(f * Float(Int16.max))
                }
                DispatchQueue.main.async {
                    //                    let seconds = (ts - self.recordingTs)
                    //                    self.timeLabel.text = seconds.toTimeString
                    self.renderTs = ts
                    let len = self.audioView.waveforms.count
                    for i in 0 ..< len {
                        let idx = ((frame.count - 1) * i) / len
                        let f: Float = sqrt(1.5 * abs(Float(frame[idx])) / Float(Int16.max))
                        self.audioView.waveforms[i] = min(49, Int(f * 50))
                    }
                    self.audioView.active = !silent
                    self.audioView.setNeedsDisplay()
                }
            }
        }
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }

    @objc private func updateTimer() {
        if isRecording {
            time = time + 1
            timerLabel.text = formatSecondsToString(TimeInterval(time))
//            slider.value = Float(time)
        }
    }

    @IBAction func onClickOfCloseRecordScreen(_: Any) {
        recorder.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recorder.delete(name: recordingName)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onClickOfPauseButton(_: Any) {
        if continueView.isHidden == true {
            pauseView.isHidden = true
            continueView.isHidden = false
            statusLabel.text = "Paused..."
            isRecording = false
            audioView.isHidden = true
            recorder.pause()

        } else {
            pauseView.isHidden = false
            continueView.isHidden = true
            statusLabel.text = "Recording..."
            isRecording = true
            audioView.isHidden = false

            recorder.continueRecord()
        }
    }

    @IBAction func onClickOfFinishedButton(_: Any) {
        if isPlaying == false {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            sendButtonHeightConstraint.constant = 50
            recorder.stop()
            stopView.isHidden = true
            pauseView.isHidden = true
            continueView.isHidden = true

            statusLabel.text = "Play..."
            isRecording = false
            playView.isHidden = false
            audioSendView.isHidden = false
            sliderView.isHidden = false

        } else {
            recorder.stopPlaying()
            stopView.isHidden = true
            pauseView.isHidden = true
            continueView.isHidden = true
            slider.setValue(0, animated: true)
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            sendButtonHeightConstraint.constant = 50
            statusLabel.text = "Play..."
            isRecording = false
            playView.isHidden = false
            audioSendView.isHidden = false
            sliderView.isHidden = false
            slider.setValue(0, animated: true)
        }
    }

    @IBAction func onClickOfPlayAudioButton(_: Any) {
        playView.isHidden = true
        stopView.isHidden = false
        statusLabel.text = "Playing..."

        let bundle = getDir().appendingPathComponent(recordingName.appending(".m4a"))

        if FileManager.default.fileExists(atPath: bundle.path) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, options: .defaultToSpeaker)
                audioPlayer = try AVAudioPlayer(contentsOf: bundle)
                audioPlayer.delegate = self as? AVAudioPlayerDelegate
                audioPlayer.play()

            } catch {
                print("play(with name:), ", error.localizedDescription)
            }
            recorder.play(name: recordingName, slider: slider)
            // set slider value
            isPlaying = true
            playtimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
        }
    }

    private func getDir() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let type = fileName.audiomediaFileName
        let fileURL = paths!.appendingPathComponent(type + "/")
        return fileURL
    }

    @objc private func updatePlayTimer() {
        if isPlaying {
            updateProgress()
        }
    }

    @IBAction func onClickOfSendButton(_: Any) {
        let data = recorder.getData(name: recordingName)
        if data != nil {
            let mediaObj = MediaUploadObject(path: recordingName, name: "", imgData: data, mediaTyp: messagetype.AUDIO)
            audioDelegate?.processDataForAudio(mediaObj: [mediaObj], type: attachmentType.imageArray)
            dismiss(animated: true, completion: nil)
        }
    }

    func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }

    @IBAction func onCLickOfSLiderValue(_: Any) {
        var wasPlaying: Bool = false
        if isPlaying == true {
            recorder.audioPlayer.pause()
            wasPlaying = true
        }
        recorder.audioPlayer.currentTime = TimeInterval(round(slider.value))
        updateProgress()
        // starts playing track again it it had been playing
        if wasPlaying == true {
            recorder.audioPlayer.play()
            wasPlaying = false
        }
    }

    // Timer delegate method that updates current time display in minutes
    func updateProgress() {
        let total = Float((recorder.audioPlayer.duration / 60) / 2)
        let current_time = Float((recorder.audioPlayer.currentTime / 60) / 2)
        slider.minimumValue = 0.0
        slider.maximumValue = Float(recorder.audioPlayer.duration)
        slider.setValue(Float(recorder.audioPlayer.currentTime), animated: true)
        timerLabel.text = NSString(format: "%.2f/%.2f", current_time, total) as String
        if recorder.audioPlayer.isPlaying == false {
            isPlaying = false
            playView.isHidden = false
            stopView.isHidden = true
            statusLabel.text = "Play..."
            timerLabel.text = NSString(format: "%.2f/%.2f", 0, total) as String
        }
    }
}
