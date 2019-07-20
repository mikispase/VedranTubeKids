//
//  ViewController.swift
//  VedranTube
//
//  Created by Dimitar Spasovski on 4/24/19.
//  Copyright © 2019 Dimitar Spasovski. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    var array:Array = [String]()
    var player = AVPlayer()
    var soundPlayer: AVAudioPlayer?
    
    var playerLayer = AVPlayerLayer()
    var indexPath = IndexPath()
    
    @IBOutlet weak var playBackSlider: UISlider!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var collectionViewHelper: UIView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var heightCollectionContains: NSLayoutConstraint!
    @IBOutlet var playerView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    var masha :Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if masha {
            for  i in 51...101 {
                array.append(String(i))
            }
        }
        else {
            for  i in 1...50 {
                array.append(String(i))
            }
        }
        
        array = array.shuffled()
       
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        guard let name = self.array.first  else { return }
        playVideo(with: name)
        player.seek(to: CMTime(seconds: 50, preferredTimescale: 1))
        player.pause()
        
        let duration : CMTime = (player.currentItem?.asset.duration)!
        let seconds : Float64 = CMTimeGetSeconds(duration)
        playBackSlider.minimumValue = 0
        playBackSlider.maximumValue = Float(seconds)
        playBackSlider.isContinuous = true
        playBackSlider.tintColor = UIColor.red
        
        playerView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.respondTapGesture))
        playerView.addGestureRecognizer(tapGesture)
        
        self.periodSliderChange()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.heightCollectionContains.constant = 300
            flowLayout.itemSize.width = 364
            flowLayout.itemSize.height = 289
            
        }else {
            self.heightCollectionContains.constant = 150
            flowLayout.itemSize.width = 150
            flowLayout.itemSize.height = 141
        }
        flowLayout.minimumLineSpacing = 30
        
        
        let img = UIImage(named: "b")
        img?.withRenderingMode(.alwaysTemplate)
        self.backButton.setImage(img, for: .normal)
        self.backButton.imageView?.tintColor = .white
        self.backButton.tintColor = .white
    }
    
    
    
    @IBAction func back(_ sender: UIButton) {
        player.replaceCurrentItem(with: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func respondTapGesture(gesture: UIGestureRecognizer) {
        UIView.animate(withDuration: 1.5,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        
                        self.playButton.isHidden = !self.playButton.isHidden
                        self.playBackSlider.isHidden = !self.playBackSlider.isHidden
                        self.collectionViewHelper.isHidden = !self.collectionViewHelper.isHidden
                        self.leftLabel.isHidden = !self.leftLabel.isHidden
                        self.rightLabel.isHidden =  !self.rightLabel.isHidden
                        self.backButton.isHidden = !self.backButton.isHidden
                        var x:CGFloat = 0.0
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            x =  300
                        }else {
                            x = 150
                        }
                        
                        self.heightCollectionContains.constant = !self.playButton.isHidden ? x : 0
                        
        }, completion: { (finished) -> Void in
            // ....
        })
        
        if !self.player.isPlaying {
            // setTimer()
            self.player.play()
        }
    }
    
    
    @objc func playerDidFinishPlaying(notification : NotificationCenter) {
        print("video ends")
        
        self.indexPath = IndexPath(row: self.indexPath.row+1, section: 0)
        
        let index = self.indexPath.row
        
        if index < array.count {
            let name = array[index]
            self.playVideo(with: name)
            self.collectionView.scrollToItem(at:IndexPath(item: index, section: 0), at: .right, animated: false)
        }
    }
    
    func periodSliderChange() {
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player.currentTime());
                self.playBackSlider!.value = Float ( time )
                
                let currentTime = CMTimeGetSeconds(self.player.currentItem!.duration)
                let secs = Int(currentTime)
                
                DispatchQueue.main.async {
                    if self.player.isPlaying {
                        self.playButton.setImage(UIImage(named: "pause"), for: .normal)
                    }
                    else {
                        self.playButton.setImage(UIImage(named: "play"), for: .normal)
                    }
                    
                    self.rightLabel.text = NSString(format: "%02d:%02d", secs/60, secs%60) as String//"\(secs/60):\(secs%60)"
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        playerLayer.frame = playerView.bounds
    }
    
    
    @IBAction func sliderChangeValue(_ sender: UISlider) {
        let seconds : Int64 = Int64(playBackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player.seek(to: targetTime)
        
        if player.rate == 0{
            player.play()
        }
        
        DispatchQueue.main.async {
            if self.player.isPlaying {
                self.playButton.setImage(UIImage(named: "pause"), for: .normal)
            }
            else{
                self.playButton.setImage(UIImage(named: "play"), for: .normal)
            }
        }
    }
    
    @IBAction func button(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
            self.playButton.setImage(UIImage(named: "play"), for: .normal)
            
        } else {
            player.play()
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    func playVideo(with nameOfVideo:String) {
        guard let path = Bundle.main.path(forResource: nameOfVideo, ofType:"mp4") else {
            debugPrint("video.mp4 not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        self.playerView.layer.addSublayer(playerLayer)
        player.play()
        self.periodSliderChange()
        self.playerView.bringSubviewToFront(self.playButton)
        self.playerView.bringSubviewToFront(self.collectionViewHelper)
        self.playerView.bringSubviewToFront(self.playBackSlider)
        self.playerView.bringSubviewToFront(self.leftLabel)
        self.playerView.bringSubviewToFront(self.rightLabel)
        self.playerView.bringSubviewToFront(self.backButton)
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "POW - Gaming Sound Effect (HD)", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            soundPlayer = nil
            soundPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = soundPlayer else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        let avAsset = AVURLAsset(url: path, options: nil)
        let imageGenerator = AVAssetImageGenerator(asset: avAsset)
        imageGenerator.appliesPreferredTrackTransform = true
        var thumbnail: UIImage?
        
        do {
            thumbnail = try UIImage(cgImage: imageGenerator.copyCGImage(at: CMTime(seconds: 50, preferredTimescale: 1), actualTime: nil))
            
            return thumbnail
        } catch let e as NSError {
            print("Error: \(e.localizedDescription)")
            return nil
        }
    }
}


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MyCollectionViewCell
        let name = self.array[indexPath.row]
        let path = Bundle.main.path(forResource: name, ofType:"mp4")
        let fileUrl = URL(fileURLWithPath: path!)
        let image =  generateThumbnail(path: fileUrl)
        cell?.moviewImageView.image = image
        return cell!
    }
}

extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let name = self.array[indexPath.row] as? String  else {
            return
        }
        self.indexPath = indexPath
        
        player.pause()
        playerLayer.removeFromSuperlayer()
        playVideo(with: name)
    }
}

extension ViewController : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        playSound()
    }
}



extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
