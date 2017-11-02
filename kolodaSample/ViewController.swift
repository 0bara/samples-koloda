//
//  ViewController.swift
//  kolodaSample
//
//  Created by tomohiro obara on 2017/11/02.
//  Copyright © 2017年 tomohiro obara. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    var photoAssets: Array = [PHAsset]()        // カメラロールの全データ
    var imgView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loadCam()
        self.setupKoloda()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController
{
    func isAvailableCameraRollAccess() -> Bool {
        let stat = PHPhotoLibrary.authorizationStatus()
        switch stat {
        case .restricted:
            fallthrough
        case .denied:
            return false
            
        case .authorized :
            fallthrough
        default:
            break
        }
        return true
    }
    
    /** カメラロールにある画像を読み込む
     */
    fileprivate func loadCam()
    {
        // FIXME: 非同期で返るので、このコードではダメ！
        guard self.isAvailableCameraRollAccess() else {
            print("カメラロールへのアクセスが許可されていません");
            return
        }
        
        // load data
        let opt = PHFetchOptions()
        opt.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        // とりあえず画像のみ列挙
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: opt)
        assets.enumerateObjects({
            (asset, index, stop) -> Void in
            print("asset: \(asset)")
            self.photoAssets.append(asset as PHAsset)
            guard asset.mediaType == PHAssetMediaType.image else {
                print("not image")
                return
            }
        })
        print("load num: \(self.photoAssets.count)")
    }
}

import Koloda

extension ViewController: KolodaViewDelegate
{
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        print("#function call.")
        koloda.reloadData()
    }
    
}

extension ViewController: KolodaViewDataSource
{
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let asset = self.photoAssets[index]
        let manager = PHImageManager()
        let opt = PHImageRequestOptions()
        opt.isSynchronous = true
        manager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: PHImageContentMode.aspectFill,
            options: opt,
            resultHandler: {
                (image, info) in
                guard let outImage = image else {
                    return
                }
                self.imgView.image = outImage
                self.imgView.contentMode = .scaleAspectFit
        })

        return self.imgView
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return self.photoAssets.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return DragSpeed.default
    }
    
    /** kolodaライブラリの初期設定を行う
    */
    fileprivate func setupKoloda()
    {
        guard let kview = self.view as? KolodaView else {
            print("story boardで、kolodaViewに設定しておくこと")
            return
        }
        kview.dataSource = self
        kview.delegate = self
    }
    
    
}




