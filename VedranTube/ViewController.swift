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
    var indexPath =  IndexPath(row: 0, section: 0)
    var masha :Bool = false
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if masha {
            for i in 51...101 {
                array.append(String(i))
            }
        }
        else {
            for i in 1...50 {
                array.append(String(i))
            }
        }
        
        array = array.shuffled()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        guard let name = self.array.first  else { return }
        playVideo(with: name)
        player.seek(to: CMTime(seconds: 0.1, preferredTimescale: 1))
        player.pause()
        
        let duration : CMTime = (player.currentItem?.asset.duration)!
        let seconds : Float64 = CMTimeGetSeconds(duration)
        playBackSlider.minimumValue = 0
        playBackSlider.maximumValue = Float(seconds)
        playBackSlider.isContinuous = true
        playBackSlider.tintColor = UIColor.red
        playBackSlider.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.respondTapGesture))
        playerView.addGestureRecognizer(tapGesture)
        playerView.isUserInteractionEnabled = true
        
        self.periodSliderChange()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        flowLayout.minimumLineSpacing = 30
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.heightCollectionContains.constant = 300
            flowLayout.itemSize.width = 364
            flowLayout.itemSize.height = 289
            
        }else {
            self.heightCollectionContains.constant = 150
            flowLayout.itemSize.width = 150
            flowLayout.itemSize.height = 141
        }
        
        let img = UIImage(named: "b")
        img?.withRenderingMode(.alwaysTemplate)
        self.backButton.setImage(img, for: .normal)
        self.backButton.imageView?.tintColor = .white
        self.backButton.tintColor = .white
    }
    
    // Fix this deinit not called
    deinit {
        print("deinit")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func back(_ sender: UIButton) {
        player.replaceCurrentItem(with: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func respondTapGesture(gesture: UIGestureRecognizer) {
        
        self.collectionViewHelper.alpha = 0.0
        
        UIView.animate(withDuration:1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
            self.playButton.isHidden = !self.playButton.isHidden
            self.playBackSlider.isHidden = !self.playBackSlider.isHidden
            self.collectionViewHelper.isHidden = !self.collectionViewHelper.isHidden
            self.leftLabel.isHidden = !self.leftLabel.isHidden
            self.rightLabel.isHidden =  !self.rightLabel.isHidden
            self.backButton.isHidden = !self.backButton.isHidden
            var x:CGFloat = 0.0
            if UIDevice.current.userInterfaceIdiom == .pad { x = 300 } else { x = 150 }
            self.heightCollectionContains.constant = !self.playButton.isHidden ? x : 0
            self.collectionViewHelper.alpha = 0.5
        }, completion: { (completedAnimation) in
            self.collectionViewHelper.alpha = 1
        })
        
        if !self.player.isPlaying {
            // setTimer()
            self.player.play()
        }
    }
    
    
    @objc func playerDidFinishPlaying(notification : NotificationCenter) {
        self.indexPath = IndexPath(row: self.indexPath.row+1, section: 0)
        let index = self.indexPath.row
        if index < array.count {
            let name = array[index]
            self.playVideo(with: name)
            self.collectionView.scrollToItem(at:IndexPath(item: index, section: 0), at: .right, animated: true)
        }
    }
    
    func periodSliderChange() {
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player.currentItem?.status == .readyToPlay {
                
                if self.player.isPlaying {
                    self.playButton.setImage(UIImage(named: "pause"), for: .normal)
                }else {
                    self.playButton.setImage(UIImage(named: "play"), for: .normal)
                }
                
                
                let time : Float64 = CMTimeGetSeconds(self.player.currentTime());
                self.playBackSlider!.value = Float ( time )
                let timeCurrent = CMTimeGetSeconds(self.player.currentTime())
                let secsCurrent = Int(timeCurrent)
                
                let timeEnd = CMTimeGetSeconds(self.player.currentItem!.duration)
                if !timeEnd.isNaN {
                    let secsEnd = Int(timeEnd)
                    self.leftLabel.text = NSString(format: "%02d:%02d", secsCurrent/60, secsCurrent%60) as String
                    self.rightLabel.text = NSString(format: "%02d:%02d", secsEnd/60, secsEnd%60) as String
                    
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
            }else{
                self.playButton.setImage(UIImage(named: "play"), for: .normal)
            }
        }
        
        self.collectionView.reloadData()

    }
    
    @IBAction func button(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
            self.playButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player.play()
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        self.collectionView.reloadData()
    }
    
    func playVideo(with nameOfVideo:String) {
        player.replaceCurrentItem(with: nil)
        guard let path = Bundle.main.path(forResource: nameOfVideo, ofType:"mp4") else { return }
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
        self.collectionView.reloadData()
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
        let asset = AVAsset(url: fileUrl)
        let timeEnd = CMTimeGetSeconds(asset.duration)
        let secs = Int(timeEnd)
        cell?.lblDuration.text = NSString(format: "%02d:%02d", secs/60, secs%60) as String
        
        let asset1 = self.player.currentItem?.asset as? AVURLAsset
        var assString = asset1?.url.lastPathComponent
        assString = assString?.replacingOccurrences(of: ".mp4", with: "")
        if assString == name && self.player.isPlaying {
            let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "Nt6v", withExtension: "gif")!)
            cell?.imageGif.image = UIImage.gifImageWithData(imageData!)
        }
        else {
            cell?.imageGif.image = UIImage()
        }
        
        
        
        
        
        return cell!
    }
}

extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let name = self.array[indexPath.row] as? String  else { return }
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
