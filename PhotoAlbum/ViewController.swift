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
import EventKit

class ViewController: UIViewController {

    let buttonn = UIButton()
    let buttonn2 = UIButton()
    let img = UIImage(named: "testpic")
    let eventStore = EKEventStore()
    
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

    
    
    //判断及设置相册权限-done
    @objc func goToSettingPhoto()->Bool{
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            return true
            
        case .notDetermined:
            // 请求授权
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    _ = self.goToSettingPhoto()
                })
            })
            
        default: ()
        DispatchQueue.main.async(execute: { () -> Void in
            let alertController = UIAlertController(title: "照片访问受限",
                                                    message: "点击“设置”，允许访问您的照片",
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
            
            let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
                (action) -> Void in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:],
                                                  completionHandler: {
                                                    (success) in
                        })
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
        }
        return false
    }
    
    
    
    //申请麦克风权限-done
    func getMicro()->Bool{
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        
        switch status {
        case .authorized:
            return true
            
        case .notDetermined:
            // 请求授权
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: {
                (status) in
                DispatchQueue.main.async(execute: { () -> Void in
                    _ = self.getMicro()
                })
            })
        default: ()
        DispatchQueue.main.async(execute: { () -> Void in
            let alertController = UIAlertController(title: "麦克风访问受限",
                                                    message: "点击“设置”，允许访问您的麦克风",
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
            
            let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
                (action) -> Void in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:],
                                                  completionHandler: {
                                                    (success) in
                        })
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
        }
        return false
    }
    
    
    
    //获取日历权限
    func getCanlender(){
        // 'EKEntityType.reminder' or 'EKEntityType.event'
        eventStore.requestAccess(to: .event, completion: {
            granted, error in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error  \(String(describing: error))")
            
                // 新建一个事件
                let event:EKEvent = EKEvent(eventStore: self.eventStore)
                event.title = "新增一个测试事件"
                event.startDate = Date()
                event.endDate = Date()
                event.notes = "这个是备注"
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                
                do{
                    try self.eventStore.save(event, span: .thisEvent)
                    print("Saved Event")
                }catch{}
                
                // 获取所有的事件（前后90天）
                let startDate = Date().addingTimeInterval(-3600*24*90)
                let endDate = Date().addingTimeInterval(3600*24*90)
                let predicate2 = self.self.eventStore.predicateForEvents(withStart: startDate,
                                                               end: endDate, calendars: nil)
                
                print("查询范围 开始:\(startDate) 结束:\(endDate)")
                
                if let eV = self.eventStore.events(matching: predicate2) as [EKEvent]? {
                    for i in eV {
                        print("标题  \(i.title)" )
                        print("开始时间: \(i.startDate)" )
                        print("结束时间: \(i.endDate)" )
                    }
                }
            }
        })
    }
    
    
    //保存视频到系统相册-没测试
    @objc func saveVideoAlbum(videoPath: String, didFinishSavingWithError error: NSError, contextInfo info: AnyObject) {
        print("视频保存成功")
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

