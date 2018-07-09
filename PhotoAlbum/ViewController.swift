//
//  ViewController.swift
//  PhotoAlbum
//
//  Created by 大鲨鱼 on 2018/7/9.
//  Copyright © 2018年 大鲨鱼. All rights reserved.
//

import AVFoundation
import UIKit
import Photos
import MobileCoreServices

//添加代理：
//UIImagePickerControllerDelegate，
//UINavigationControllerDelegate

class ViewController: UIViewController {

    let buttonn = UIButton()
    let buttonn2 = UIButton()
    let img = UIImage(named: "testpic")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //下面是按钮1，点击后下载图片到相册
        buttonn.frame = CGRect(x: self.view.bounds.width / 12, y: self.view.bounds.height - 100, width: 150, height: 50)
        buttonn.backgroundColor = UIColor.yellow
        buttonn.setTitle("DOWNLOAD", for: .normal)
        buttonn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        buttonn.setTitleColor(UIColor.black, for: .normal)
        buttonn.addTarget(self, action: #selector(savePhotoAlbum), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonn)
        
        //下面是按钮2，点击打开相册
        buttonn2.frame = CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height - 100, width: 150, height: 50)
        buttonn2.backgroundColor = UIColor.cyan
        buttonn2.setTitle("OPENALBUM", for: .normal)
        buttonn2.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        buttonn2.setTitleColor(UIColor.black, for: .normal)
        buttonn2.addTarget(self, action: #selector(openPhotoAlbum), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonn2)
        
        //设置一个图片view，用于下载这张图片
        let imgView = UIImageView(image: img)
        imgView.frame = CGRect(x: (self.view.bounds.width - 300) / 2, y: self.view.bounds.height / 4, width: 300, height: 300)
        imgView.contentMode = .scaleAspectFill
        self.view.addSubview(imgView)

        // Do any additional setup after loading the view, typically from a nib.
    }

    
    //打开相册的方法，我也不知道为啥要带@objc，不带就报错。-done
    @objc func openPhotoAlbum(){
        let pickImageController:UIImagePickerController=UIImagePickerController.init()
        if  UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            //获取相册权限
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .notDetermined: break
                case .restricted://此应用程序没有被授权访问的照片数据
                break
                case .denied://用户已经明确否认了这一照片数据的应用程序访问
                break
                case .authorized://已经有权限
                    //跳转到相机或者相册
                    pickImageController.delegate=self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
                    pickImageController.allowsEditing = true
                    pickImageController.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                    //弹出相册页面或相机
                    self.present(pickImageController, animated: true, completion: {})
                    break
                }
            })
        }
    }

    //去设置相册权限（如果没有权限的话）-done
    @objc func gotoSetting(){
        let alertController:UIAlertController=UIAlertController.init(title: "去开启相册权限", message: "桌面-设置-通用-权限管理", preferredStyle: UIAlertControllerStyle.alert)
        let sure:UIAlertAction=UIAlertAction.init(title: "去开启权限", style: UIAlertActionStyle.default) { (ac) in
            let url=URL.init(string: UIApplicationOpenSettingsURLString)
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [:], completionHandler: { (ist) in
                })
            }
        }
        alertController.addAction(sure)
        self.present(alertController, animated: true) {
        }
    }
    
    //保存视频到系统相册-没测试
    @objc func saveVideoAlbum(videoPath: String, didFinishSavingWithError error: NSError, contextInfo info: AnyObject) {
        print("视频保存成功")
    }
    
    //保存照片到系统相册-done
    @objc func savePhotoAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: self.img!)
        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                print("照片保存成功!")
            } else{
                print("照片保存失败!", error!.localizedDescription)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

