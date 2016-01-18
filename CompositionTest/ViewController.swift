//
//  ViewController.swift
//  CompositionTest
//
//  Created by Tim on 1/12/16.
//  Copyright © 2016 Tim. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var player: AVQueuePlayer!
    var playerItem: AVPlayerItem!
    @IBOutlet weak var playerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    override func viewDidAppear(animated: Bool) {
        buildComposition(false)
        buildComposition(true)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            let status : AVPlayerItemStatus = self.playerItem.status as AVPlayerItemStatus
            
            if status == .ReadyToPlay {
                NSLog("ReadyToPlay")
                let playerLayer = AVPlayerLayer(player: player)
                playerView.layer.addSublayer(playerLayer)
                playerLayer.frame = playerView.bounds

                player.play()
                playerItem.removeObserver(self, forKeyPath: "status")

            }
            else if status == .Failed {
                NSLog("Failed")
            }
            else if status == .Unknown {
                NSLog("Unknown")
            }
        }
        else {
            super.observeValueForKeyPath(keyPath,
                ofObject: object,
                change: change,
                context: context)
        }
    }
    
    @IBAction func replayWith(sender: AnyObject) {
        buildComposition(true)
    }
    @IBAction func replay(sender: AnyObject) {
        buildComposition(false)
    }
    func buildComposition(withMusicTrack: Bool) {
//        player.actionAtItemEnd = .Advance
        
        for i in 1...10 {

            let comp = AVMutableComposition()
            let vid = comp.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
            let aud = comp.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            var music: AVMutableCompositionTrack!
            if withMusicTrack {
                music = comp.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            }
            
            let bundleURL = NSBundle.mainBundle().URLForResource("Knoable \(i)", withExtension: "mp4")
            let sourceAsset = AVURLAsset(URL: bundleURL!)
            
            do {
                let range = CMTimeRange(start: kCMTimeZero, duration: sourceAsset.duration)
                try vid.insertTimeRange(range, ofTrack: sourceAsset.tracksWithMediaType(AVMediaTypeVideo)[0] , atTime: kCMTimeZero)
                try aud.insertTimeRange(range, ofTrack: sourceAsset.tracksWithMediaType(AVMediaTypeAudio)[0] , atTime: kCMTimeZero)
                if music != nil {
                    try music.insertTimeRange(range, ofTrack: sourceAsset.tracksWithMediaType(AVMediaTypeAudio)[0] , atTime: kCMTimeZero)
                }
            } catch _ {
                NSLog("error inserting")
            }
            
            let pitem = AVPlayerItem(asset: comp)
            if player == nil {
                playerItem = pitem
                player = AVQueuePlayer(playerItem: pitem)
                playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.Initial, context: nil)
            }
            else {
                player.insertItem(pitem, afterItem: nil)
            }
        }
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

