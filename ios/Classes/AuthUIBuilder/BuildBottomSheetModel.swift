//
//  BuildBottomSheetModel.swift
//  ali_auth
//
//  Created by kangkang on 2022/10/1.
//

import ATAuthSDK
import Foundation

extension AuthUIBuilder {
    /**
     *  授权页面中，渲染并显示所有控件的view，称content view，不实现该block默认为全屏模式
     *  实现弹窗的方案 x >= 0 || y >= 0 width <= 屏幕宽度 || height <= 屏幕高度
     */

    // MARK: - 创建底部弹窗授权页

    func buildBottomSheetModel(config: AuthUIConfig) -> TXCustomModel {
        let model = TXCustomModel()

        var kHorizontal: Bool?
        let logoOffsetY: Float = 20
        
        model.supportedInterfaceOrientations = UIInterfaceOrientationMask.portrait
        
        if let alertContentViewColor = config.alertContentViewColor {
            model.alertContentViewColor = alertContentViewColor.uicolor()
        }
        
        if let alertBlurViewColor = config.alertBlurViewColor {
            model.alertBlurViewColor = alertBlurViewColor.uicolor()
        }
        
        if let alertBlurViewAlpha = config.alertBlurViewAlpha {
            model.alertBlurViewAlpha = CGFloat(alertBlurViewAlpha)
        }
        
        let borderRadius = NSNumber(value: config.alertBorderRadius ?? 10)
        
        if let backgroundImage = config.backgroundImage {
            if let image = FlutterAssetImage(backgroundImage) {
                model.backgroundImage = image
                model.backgroundImageContentMode = UIView.ContentMode.scaleAspectFill
            }
        }

        // customViewBlock
        if let customViewBlockList = config.customViewBlockList {
            buildCustomViewBlock(model: model, customViewConfigList: customViewBlockList)
        }
        
        model.alertCornerRadiusArray = [borderRadius, borderRadius, borderRadius, borderRadius]
        
        // alertTitle
        var alertTitleAttributes: [NSAttributedString.Key: Any] = [:]

        alertTitleAttributes.updateValue(UIFont(name: PF_Regular, size: CGFloat(config.alertTittleTextSize ?? Font_16))!, forKey: NSAttributedString.Key.font)

        alertTitleAttributes.updateValue(config.alertTitleTextColor?.uicolor() ?? UIColor.white, forKey: NSAttributedString.Key.foregroundColor)
        
        model.alertTitle = NSAttributedString(string: "", attributes: nil)
        
        model.alertTitleBarColor = config.alertTitleBarColor?.uicolor() ?? model.alertContentViewColor
        
        model.alertCloseItemIsHidden = config.alertCloseItemIsHidden ?? false
        
        if let alertCloseImage = config.alertCloseImage {
            if let alertCloseIcon = FlutterAssetImage(alertCloseImage) {
                model.alertCloseImage = alertCloseIcon
            }
            model.alertCloseItemFrameBlock = {
                _, _, frame -> CGRect in
                
                let offsetX = CGFloat((config.alertCloseImageOffsetX ?? 0.0) + kPadding)
                
                let offsetY = CGFloat(config.alertCloseImageOffsetY ?? kPadding)
                
                return CGRect(x: offsetX, y: offsetY, width: frame.width, height: frame.height)
            }
        } else {
            if let alertCloseImage = BundleImage("icon_close_gray") {
                model.alertCloseImage = alertCloseImage
            }
        }
        
        // Logo
        model.logoIsHidden = config.logoIsHidden ?? false
        
        if let logoImage = config.logoImage {
            if let logoImageAssets = FlutterAssetImage(logoImage) {
                model.logoImage = logoImageAssets
            }

            // logo的位置
            model.logoFrameBlock = {
                _, _, frame -> CGRect in
                
                let offsetX: CGFloat = .init(config.logoFrameOffsetX ?? Float(frame.origin.x))
                
                let offsetY: CGFloat = .init(config.logoFrameOffsetY ?? Float(logoOffsetY))
                
                let imageWidth: CGFloat = .init(config.logoWidth ?? kLogoSize)
                let imageHeight: CGFloat = .init(config.logoHeight ?? kLogoSize)
                
                return CGRect(x: offsetX, y: offsetY, width: imageWidth, height: imageHeight)
            }
        }

        // Slogon
        model.sloganIsHidden = config.sloganIsHidden ?? false
        
        var sloganTextAtrributes: [NSAttributedString.Key: Any] = [:]

        sloganTextAtrributes.updateValue((config.sloganTextColor ?? "#151515").uicolor(), forKey: NSMutableAttributedString.Key.foregroundColor)

        sloganTextAtrributes.updateValue(UIFont(name: PF_Regular, size: CGFloat(config.sloganTextSize ?? Font_24))!, forKey: NSMutableAttributedString.Key.font)

        model.sloganText = NSAttributedString(string: config.sloganText ?? "欢迎登录\(AppDisplayName)", attributes: sloganTextAtrributes)
        
        model.sloganFrameBlock = {
            screenSize, _, frame -> CGRect in
            if kHorizontal == nil {
                kHorizontal = self.isHorizontal(screenSize)
            }
            if kHorizontal! {
                return CGRect.zero
            }
            
            let offsetX = CGFloat(config.sloganFrameOffsetX ?? Float(frame.origin.x))

            let offsetY = CGFloat(config.sloganFrameOffsetY ?? kLogoSize + logoOffsetY + kPadding)
            
            return CGRect(x: offsetX, y: offsetY, width: frame.width, height: frame.height)
        }
        // Phone Number
        model.numberColor = (config.numberColor ?? "#2BD180").uicolor()
        model.numberFont = UIFont(name: PF_Bold, size: CGFloat(config.numberFontSize ?? Font_24))!
        
        model.numberFrameBlock = {
            screenSize, _, frame -> CGRect in
            if kHorizontal == nil {
                kHorizontal = self.isHorizontal(screenSize)
            }
            if kHorizontal! {
                return CGRect.zero
            }
            
            let offsetX = CGFloat(config.numberFrameOffsetX ?? Float(frame.origin.x))
            
            let numberFrameOffsetY: Float = config.numberFrameOffsetY ?? (kLogoSize + logoOffsetY + Float(Font_24) + kPadding * 3)
            
            let offsetY = CGFloat(numberFrameOffsetY)
            
            return CGRect(x: offsetX, y: offsetY, width: frame.width, height: frame.height)
        }

        // login button
        var loginBtnBgImgs = [UIImage]()

        if let loginBtnNormalImage = config.loginBtnNormalImage {
            if let loginBtnNormal = FlutterAssetImage(loginBtnNormalImage) {
                loginBtnBgImgs.append(loginBtnNormal)
            }
        }
        if let loginBtnUnableImage = config.loginBtnUnableImage {
            if let loginBtnUnable = FlutterAssetImage(loginBtnUnableImage) {
                loginBtnBgImgs.append(loginBtnUnable)
            }
        }
        if let loginBtnPressedImage = config.loginBtnPressedImage {
            if let loginBtnPressed = FlutterAssetImage(loginBtnPressedImage) {
                loginBtnBgImgs.append(loginBtnPressed)
            }
        }

        if !loginBtnBgImgs.isEmpty {
            model.loginBtnBgImgs = loginBtnBgImgs
        }
        
        var loginAttribute: [NSAttributedString.Key: Any] = [:]

        loginAttribute.updateValue(config.loginBtnTextColor?.uicolor() ?? UIColor.white, forKey: NSAttributedString.Key.foregroundColor)

        loginAttribute.updateValue(UIFont(name: PF_Regular, size: CGFloat(config.loginBtnTextSize ?? Font_17))!, forKey: NSAttributedString.Key.font)

        model.loginBtnText = NSAttributedString(string: config.loginBtnText ?? "一键登录", attributes: loginAttribute)
        
        var loginButtonOffsetY: Float = 0.0
        
        var kLoginButtonSize = CGSize()
        
        model.loginBtnFrameBlock = { _, superViewSize, frame -> CGRect in
            
            let offsetX = CGFloat(config.loginBtnFrameOffsetX ?? Float(frame.origin.x))
            
            loginButtonOffsetY = config.loginBtnFrameOffsetY ?? Float(superViewSize.height) * 0.55
            
            kLoginButtonSize.width = CGFloat(config.loginBtnWidth ?? Float(frame.width))
            
            kLoginButtonSize.height = CGFloat(config.loginBtnHeight ?? Float(frame.height))
            
            return CGRect(x: offsetX, y: CGFloat(loginButtonOffsetY), width: kLoginButtonSize.width, height: kLoginButtonSize.height)
        }
        
        model.changeBtnIsHidden = config.changeBtnIsHidden ?? true
        
        var changeBtnAttribute: [NSAttributedString.Key: Any] = [:]

        changeBtnAttribute.updateValue(config.changeBtnTextColor?.uicolor() ?? UIColor.darkGray, forKey: NSAttributedString.Key.foregroundColor)

        changeBtnAttribute.updateValue(UIFont(name: PF_Regular, size: CGFloat(config.changeBtnTextSize ?? Font_14))!, forKey: NSAttributedString.Key.font)

        model.changeBtnTitle = NSAttributedString(string: config.changeBtnTitle ?? "切换其他登录方式", attributes: changeBtnAttribute)

        model.changeBtnFrameBlock = { screenSize, _, frame -> CGRect in
            if kHorizontal == nil {
                kHorizontal = self.isHorizontal(screenSize)
            }
            if kHorizontal! {
                return CGRect.zero
            }
            let width: CGFloat = frame.width // 150

            let height: CGFloat = frame.height // 38

            let offsetX: CGFloat = frame.origin.x
            // let offsetY: CGFloat = screenSize.width / 2 + kLoginButtonSize.height + CGFloat(kPadding)

            let offsetY = CGFloat(config.changeBtnFrameOffsetY ?? loginButtonOffsetY + Float(kLoginButtonSize.height) + kPadding * 2)

            return CGRect(x: offsetX, y: offsetY, width: width, height: height)
        }

        // CheckBox
        model.checkBoxIsChecked = config.checkBoxIsChecked ?? false
        model.checkBoxIsHidden = config.checkBoxIsHidden ?? true
        
        var checkBoxImages = [UIImage]()
        
        if config.uncheckImage != nil {
            if let uncheckIcon = FlutterAssetImage(config.uncheckImage) {
                checkBoxImages.append(uncheckIcon)
            }
        } else {
            checkBoxImages.append(BundleImage("icon_uncheck")!)
        }

        if config.checkedImage != nil {
            if let checkedIcon = FlutterAssetImage(config.checkedImage) {
                checkBoxImages.append(checkedIcon)
            }
        } else {
            checkBoxImages.append(BundleImage("icon_check")!)
        }
        
        if !checkBoxImages.isEmpty {
            model.checkBoxImages = checkBoxImages
        }

        model.checkBoxImageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        model.checkBoxWH = CGFloat(config.checkBoxWH ?? 15)

        // privacy
        model.privacyOne = [config.privacyOneName ?? "《使用协议》", config.privacyOneUrl ?? "http://******"]

        model.privacyTwo = [config.privacyTwoName ?? "《隐私协议》", config.privacyTwoUrl ?? "http://******"]

        model.privacyConectTexts = [config.privacyConnectTexts ?? "和", config.privacyConnectTexts ?? "和"]

        model.privacyOperatorPreText = config.privacyOperatorPreText ?? "《"

        model.privacyOperatorSufText = config.privacyOperatorSufText ?? "》"

        model.privacyPreText = config.privacyPreText ?? "点击一键登录表示您已经阅读并同意"
        
        model.privacyColors = [UIColor.darkGray, config.privacyFontColor?.uicolor() ?? UIColor.systemBlue]

        model.privacyFont = UIFont(name: PF_Regular, size: CGFloat(config.privacyFontSize ?? Font_14))!
        
        model.privacyFrameBlock = { _, superViewSize, frame -> CGRect in
            
            let offsetX = CGFloat(config.privacyFrameOffsetX ?? Float(frame.origin.x))
            
            let offsetY = CGFloat(config.privacyFrameOffsetX ??
                Float(superViewSize.height - frame.height) - 55
            )
            
            return CGRect(x: offsetX, y: offsetY, width: frame.width, height: frame.height)
        }

        if let privacyNavBackIcon = BundleImage("icon_nav_back_gray") {
            model.privacyNavBackImage = privacyNavBackIcon
        }
        
        model.contentViewFrameBlock = {
            screenSize, superViewSize, frame -> CGRect in
//            print(screenSize) //(414.0, 896.0)
//            print(superViewSize) (414.0, 896.0)
//            print(frame) (0.0, 0.0, 414.0, 896.0)
            
            let width = CGFloat(config.alertWindowWidth ?? Float(screenSize.width) * 0.9)
            
            let height = CGFloat(config.alertWindowHeight ?? Float(screenSize.height) * 0.55)
            
            let offsetX: CGFloat = (screenSize.width - frame.size.width) / 2
            
            let offsetY: CGFloat = superViewSize.height - frame.size.height - 32
            return CGRect(x: offsetX, y: offsetY, width: width, height: height)
        }

        applyPrivacyAlertStyle(model: model, config: config)

        return model
    }

    private func applyPrivacyAlertStyle(model: TXCustomModel, config: AuthUIConfig) {
        let linkColor = config.privacyFontColor?.uicolor() ?? UIColor.systemBlue
        let alertWidth = UIScreen.main.bounds.width - 56
        let alertHeight: CGFloat = 230

        model.privacyAlertIsNeedShow = true
        model.privacyAlertIsNeedAutoLogin = true
        model.tapPrivacyAlertMaskCloseAlert = false
        model.privacyAlertMaskIsNeedShow = true
        model.privacyAlertMaskColor = UIColor.black
        model.privacyAlertMaskAlpha = 0.5

        model.privacyAlertBackgroundColor = UIColor.white
        model.privacyAlertAlpha = 1.0
        model.privacyAlertCornerRadiusArray = [12, 12, 12, 12]

        model.privacyAlertTitleContent = "服务协议与隐私政策"
        model.privacyAlertTitleFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        model.privacyAlertTitleColor = UIColor.black
        model.privacyAlertTitleAlignment = .center

        model.privacyAlertContentFont = UIFont.systemFont(ofSize: CGFloat(config.privacyFontSize ?? Font_14))
        model.privacyAlertContentColors = [UIColor.gray, linkColor]
        model.privacyAlertContentOperatorFont = UIFont.systemFont(ofSize: CGFloat(config.privacyFontSize ?? Font_14))
        model.privacyAlertContentUnderline = false
        model.privacyAlertOperatorColor = linkColor
        model.privacyAlertOneColor = linkColor
        model.privacyAlertTwoColor = linkColor
        model.privacyAlertThreeColor = linkColor
        model.privacyAlertContentAlignment = .left
        model.privacyAlertPreText = config.privacyPreText ?? "点击一键登录表示您已经阅读并同意"
        model.privacyAlertSufText = config.privacySufText ?? ""

        model.privacyAlertBtnContent = "确认"
        model.privacyAlertBtnCornerRadius = 8
        let normal = createSolidImage(color: "#1677FF".uicolor())
        let pressed = createSolidImage(color: "#0F5CC0".uicolor())
        model.privacyAlertBtnBackgroundImages = [normal, pressed]
        model.privacyAlertButtonTextColors = [UIColor.white, UIColor.white]
        model.privacyAlertButtonFont = UIFont.systemFont(ofSize: 15, weight: .medium)

        model.privacyAlertCloseButtonIsNeedShow = true
        if let closeImage = BundleImage("icon_close_gray") {
            model.privacyAlertCloseButtonImage = closeImage
        }

        model.privacyAlertFrameBlock = { superFrame, _, _ in
            CGRect(
                x: (superFrame.width - alertWidth) / 2,
                y: (superFrame.height - alertHeight) / 2,
                width: alertWidth,
                height: alertHeight
            )
        }
        model.privacyAlertTitleFrameBlock = { _, _, _ in
            CGRect(x: 20, y: 20, width: alertWidth - 40, height: 26)
        }
        model.privacyAlertPrivacyContentFrameBlock = { _, _, _ in
            CGRect(x: 20, y: 58, width: alertWidth - 40, height: 104)
        }
        model.privacyAlertButtonFrameBlock = { _, _, _ in
            CGRect(x: 20, y: alertHeight - 56, width: alertWidth - 40, height: 40)
        }
    }

    private func createSolidImage(color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
