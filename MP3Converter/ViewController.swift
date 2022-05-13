//
//  ViewController.swift
//  MP3Converter
//
//  Created by Maysam Shahsavari on 2022-05-10.
//
/// Icon credit: https://www.freeiconspng.com/downloadimg/36703
/// Inspired by https://github.com/lixing123/ExtAudioFileConverter/

import UIKit
import AVFoundation
import Combine

class ViewController: UIViewController {
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var disposable = Set<AnyCancellable>()
    
    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.numberOfLines = 0
        statusLabel.lineBreakMode = .byWordWrapping
    }
    
    @IBAction func convertAction(_ sender: UIButton) {
        self.statusLabel.text = "Converting..."
        let input = Bundle.main.url(forResource: "sample4", withExtension: "m4a")!
        let output = getDocumentsDirectory().appendingPathComponent("converted.mp3")
        let converter = MP3Converter()
        convertButton.isEnabled = false
        
        /// Run it in a different queue and update the UI when it's done executing, otherwise your UI will freeze.
        DispatchQueue.global(qos: .userInteractive).async {
            converter.convert(input: input, output: output)
                .receive(on: DispatchQueue.global())
                .sink(receiveCompletion: { result in
                    DispatchQueue.main.async {
                        if case .failure(let error) = result {
                            self.statusLabel.text = "Conversion failed: \n\(error.localizedDescription)"
                            self.convertButton.isEnabled = true
                        }
                    }
                }, receiveValue: { result in
                    DispatchQueue.main.async {
                        let playerItem: AVPlayerItem = AVPlayerItem(url: result)
                        self.player = AVPlayer(playerItem: playerItem)
                        self.player?.play()
                        self.statusLabel.text = "File saved as converted.mp3 in \nthe documents directory."
                    }
                }).store(in: &self.disposable)
        }
    }
    
}
