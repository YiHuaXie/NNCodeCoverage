//
//  ViewController.swift
//  Coverage
//
//  Created by NeroXie on 01/17/2022.
//  Copyright (c) 2022 NeroXie. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD
import Kingfisher
import OCTestModule
import SwiftTestModule

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .custom)
        button.backgroundColor = .yellow
        button.setTitle("show loading hud", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didButtonPressed), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(90)
            $0.size.equalTo(CGSize(width: 200, height: 30))
        }
        
        let button2 = UIButton(type: .custom)
        button2.backgroundColor = .red
        button2.setTitle("development pods test", for: .normal)
        button2.setTitleColor(.black, for: .normal)
        button2.addTarget(self, action: #selector(didButton2Pressed), for: .touchUpInside)
        view.addSubview(button2)
        button2.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(button.snp.bottom).offset(20)
            $0.size.equalTo(CGSize(width: 250, height: 30))
        }
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(button2.snp.bottom).offset(20)
            $0.size.equalTo(CGSize(width: 150, height:300))
        }
        
        let url = URL(string: "https://neroblog.oss-cn-hangzhou.aliyuncs.com/RunLoop_run.png")
        imageView.kf.setImage(with: url)
    }

    @objc func didButtonPressed() {
        MBProgressHUD.showAdded(to: view, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    @objc func didButton2Pressed() {
        OCTestModule.testMethod()
        SwiftTestModule.method()
    }
}
