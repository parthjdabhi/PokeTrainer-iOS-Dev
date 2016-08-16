platform :ios, '9.0'
use_frameworks!

target 'PokeTrainerApp' do
    
    pod 'Mixpanel'
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'FBSDKShareKit'
    pod 'Fabric'
    pod 'TwitterKit'
    pod 'TwitterCore'
    pod 'Firebase'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'Firebase/Auth'
    pod 'Firebase/Messaging'
    pod 'InstagramKit', '~> 3.0'
    pod 'InstagramKit/UICKeyChainStore'
    pod 'GTMOAuth2', '~> 1.1.0'
    pod 'OAuthSwift', '~> 0.5.0'
    pod 'SDWebImage', '~>3.8'
    pod 'QRCode', '~> 0.5'
    pod 'CVCalendar', '~> 1.2.9'
    pod 'Batch', '~> 1.5'
    pod 'Google/SignIn'
    pod 'Koloda'
    pod 'IQKeyboardManagerSwift'
    # pod 'OneSignal'
    
    # Added By Parth dabhi #
    pod 'JSQMessagesViewController' # For Chatting UI
    pod 'CryptoSwift', '~> 0.5'     # For MD5 Hash String (use when creates new personal chat)
    pod 'Alamofire', '~> 3.4'
    
    post_install do 'PokeTrainerApp'
        `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
    end

end