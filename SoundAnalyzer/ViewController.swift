
//
//  ViewController.swift
//  SoundAnalyzer
//
//  Created by Akhil on 28/04/20.
//  Copyright © 2020 IBM. All rights reserved.
//

import UIKit
import SoundAnalysis
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var soundLabel: UILabel!
    var soundRecorder : AVAudioRecorder?
    var soundPlayer : AVAudioPlayer?
    var fileName : String = "audioFile.m4a"
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupRecorder()
         recordButton.backgroundColor = UIColor.init(red: 25/255, green: 95/255, blue: 97/255, alpha: 1.0)
        playButton.isEnabled = false
         //let audioFileName = getDocumentDirectory().appendingPathComponent(fileName)
        //initialSetup(path: audioFileName)
    }
    func initialSetup(path : URL){
        //create a file analyzer
        //let fileAnalyzer = try? SNAudioFileAnalyzer(url: URL(fileURLWithPath:"/Users/akhil/Desktop/DEMO PROJECT/SoundAnalyzer/SoundAnalyzer/flute7.wav"))
        let fileAnalyzer = try? SNAudioFileAnalyzer(url: URL(resolvingAliasFileAt: path))
        
        //create the request with your model
        let request = try? SNClassifySoundRequest(mlModel:SoundClassifier1().model)
        
        //Add the request to the analyzer
        try? fileAnalyzer?.add(request!, withObserver: self)
        
        //Analyze the file
        fileAnalyzer?.analyze()
    }
    
    @IBAction func recordButtonAction(_ sender: UIButton) {
        if recordButton.titleLabel?.text == "SoundAnalyze"{
            soundRecorder?.record()
            recordButton.setTitle("Stop", for: .normal)
            recordButton.backgroundColor = .gray
            playButton.isEnabled = false
        }else{
            soundRecorder?.stop()
            recordButton.backgroundColor = UIColor.init(red: 25/255, green: 95/255, blue: 97/255, alpha: 1.0)
            recordButton.setTitle("SoundAnalyze", for: .normal)
            playButton.isEnabled = false
        }
    }
    
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        if playButton.titleLabel?.text == "Play"{
            playButton.setTitle("Stop", for: .normal)
            recordButton.isEnabled = false
            setupPlayer()
            soundPlayer?.play()
        }else{
            soundPlayer?.stop()
            playButton.setTitle("Play", for: .normal)
            recordButton.isEnabled = false
        }
    }
}

extension ViewController:SNResultsObserving{
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else {return}
        let topClassification = classificationResult.classifications.first
        //let timeRange = classificationResult.timeRange
        //Handle result
        guard let identifier = topClassification?.identifier else {return}
        guard let confidence = topClassification?.confidence else {return}
        //convert double value upto 2 digits.
        let doubleStr = String(format: "%.2f", ceil(confidence*100)/100)
        soundLabel.text = "Sound - \(String(describing: identifier))   Confidence - \(String(describing: doubleStr))"
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        //Handle Error
    }
    
    func requestDidComplete(_ request: SNRequest) {
        //Handle successful end of analysis
    }
}

extension ViewController:AVAudioRecorderDelegate,AVAudioPlayerDelegate{
    func getDocumentDirectory()-> URL{
           let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
           return paths[0]
       }
       
       func setupRecorder(){
           let audioFileName = getDocumentDirectory().appendingPathComponent(fileName)
           let recordSetting = [AVFormatIDKey : kAudioFormatAppleLossless,
                                AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                                AVEncoderBitRateKey : 32000 ,
                                AVNumberOfChannelsKey : 2,
                                AVSampleRateKey : 44100.2] as [String:Any]
           do{
              soundRecorder = try AVAudioRecorder(url: audioFileName, settings: recordSetting)
               soundRecorder?.delegate = self
               soundRecorder?.prepareToRecord()
           }catch{
               print(error)
           }
       }
       
       func setupPlayer(){
           let audioFilename = getDocumentDirectory().appendingPathComponent(fileName)
           do{
             soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
               soundPlayer?.delegate = self
               soundPlayer?.prepareToPlay()
               soundPlayer?.volume = 1.0
           }catch{
               print(error)
           }
       }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
                   let audioFileName = getDocumentDirectory().appendingPathComponent(fileName)
         initialSetup(path: audioFileName)
        playButton.isEnabled = true
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
    }
    
}


